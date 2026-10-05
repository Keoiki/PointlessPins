package funkbucks;

import balphabet.BAlphabet;
import flixel.effects.particles.FlxEmitter;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkbucks.objects.PinSprite;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.ui.MusicBeatSubState;
import funkin.util.ReflectUtil;
import funkin.util.TouchUtil;

class PinUnlockState extends MusicBeatSubState
{
    var pinData:PinData;
    var canClose:Bool = false;
    var closeTimer:Float = 0.0;
    var sparkles:FlxEmitter;
    var glow1:FunkinSprite;
    var glow2:FunkinSprite;
    var glow1spin:Float = 0;
    var glow2spin:Float = 0;
    public var debug:Bool = false;

    override function new(_pinData, _time:Float = 1.0):Void
    {
        this.pinData = _pinData;
        this.closeTimer = _time;
        super();
    }

    override function create():Void
    {
        if (pinData == null)
        {
            trace("PinUnlockState was given no PinData!");
            close();
        }

        if (pinData.rarity == null)
        {   
            trace("Pin " + pinData.name + " was given no rarity!");
            pinData.rarity = "Unknown";
        }

        var rarityColor:String = pinData.rarity == "Unknown" ? "7F7F7F" : ReflectUtil.getAnonymousField(FunkBucks.pinData, pinData.rarity).color;

        glow1spin = FlxG.random.bool(50) ? FlxG.random.float(-2, -0.2) : FlxG.random.float(0.2, 2);
        glow2spin = FlxG.random.float(0.2, 2) * (glow1spin < 0 ? 1 : -1);

        var darkOverlay:FunkinSprite = new FunkinSprite(-64, -64).makeSolidColor(FlxG.width + 128, FlxG.height + 128, 0xFF000000);
        darkOverlay.alpha = 0;
        add(darkOverlay);

        glow1 = new FunkinSprite(FlxG.width / 2, 400).loadTexture("pinunlockglow");
        glow1.x -= glow1.width / 2;
        glow1.y -= glow1.height / 2;
        glow1.alpha = 0;
        glow1.color = Std.parseInt('0xFF$rarityColor');
        glow1.blend = 0;
        add(glow1);

        glow2 = new FunkinSprite(FlxG.width / 2, 400).loadTexture("pinunlockglowsmall");
        glow2.x -= glow2.width / 2;
        glow2.y -= glow2.height / 2;
        glow2.alpha = 0;
        glow2.color = Std.parseInt('0xFF$rarityColor');
        glow2.blend = 0;
        add(glow2);

        var pin:PinSprite = new PinSprite(FlxG.width / 2, 400);
        pin.isUnlocked = true;
        pin.pixel = pinData.pixel ?? false;
        pin.setupPin(pinData.id, pinData.name, pinData.description, 0.2, 1, true);
        add(pin);

        var sparkleGoBoom:Bool = FlxG.random.bool(0.1);
        var sparkData = getSparkleData(pinData.rarity);
        sparkles = new FlxEmitter(FlxG.width / 2 - 50, 200);
        sparkles.setSize(100, 100);
        sparkles.loadParticles(Paths.image("pinsparkle"), sparkleGoBoom ? 5000 : sparkData.amount, 0);
        sparkles.acceleration.set(0, 50, 0, 150, 0, 400, 0, 600);
        sparkles.scale.set(0.3, null, 1.2, null, 0.1, null, 0.7, null);
        sparkles.keepScaleRatio = true;
        sparkles.color.set(Std.parseInt('0xFF$rarityColor'));
        sparkles.speed.set(sparkleGoBoom ? 50 : sparkData.speedMin, sparkleGoBoom ? 3000 : sparkData.speedMax, 0, 0);
        sparkles.alpha.set(1.0, 1.0, 0.0, 0.0);
        sparkles.angle.set(-180, 180, -180, 180);
        sparkles.ignoreAngularVelocity = true;
        sparkles.lifespan.set(0.5, 2.5);
        sparkles.blend = 0;
        add(sparkles);
        sparkles.start();

        var unlockMsgText:String = "";
        if (FunkBucks.debug_pins != null || debug || FunkBucks.setObtainedPin(pinData.id))
        {
            unlockMsgText = "<b>You got a <c=00FF00>NEW</c> pin!</b>";
        }
        else
        {
            if (pinData.special ?? false)
            {
                unlockMsgText = '<b>You got a <c=FF0000>duplicate special</c> pin... oops?</b>';
            }
            else
            {
                var duplicatePinCount:Int = FunkBucks.getObtainedPins().get(pinData.id);
                unlockMsgText = '<b>You got a <c=434253>duplicate ($duplicatePinCount)</c> pin!</b>';
            }
        }

        var unlockMessage:BAlphabet = new BAlphabet(FlxG.width / 2, 420, unlockMsgText);
        unlockMessage.alignment = "center";
        unlockMessage.scale.set(0.55, 0.55);
        add(unlockMessage);

        var unlockedPinName:BAlphabet = new BAlphabet(FlxG.width / 2, 475, '<b><s=0.75><c=$rarityColor>${pinData.rarity}</c></s>\n${pinData.name}</b>');
        unlockedPinName.alignment = "center";
        unlockedPinName.scale.set(0.75, 0.75);
        add(unlockedPinName);

        if (pinData.description != null && pinData.description != "")
        {
            var unlockedPinDescription:BAlphabet = new BAlphabet(FlxG.width / 2, unlockedPinName.y + 140, pinData.description, { lineHeight: 60 });
            unlockedPinDescription.alignment = "center";
            unlockedPinDescription.scale.set(0.45, 0.45);
            add(unlockedPinDescription);
        }

        var targetScale:Float = (pinData.scale ?? 0.5) * 2;
        FunkinSound.playOnce(Paths.sound("tickleFight"));
        FlxTween.tween(darkOverlay, { alpha: 0.85 }, 0.5, { ease: FlxEase.cubeOut });
        FlxTween.tween(pin, { y: pin.y - 150 }, 0.8, { ease: FlxEase.quintOut });
        FlxTween.tween(glow1, { y: glow1.y - 150, alpha: 1.0 }, 0.8, { ease: FlxEase.quintOut });
        FlxTween.tween(glow2, { y: glow2.y - 150, alpha: 1.0 }, 0.8, { ease: FlxEase.quintOut });
        FlxTween.tween(pin.scale, { x: targetScale, y: targetScale }, 1.0, { ease: FlxEase.backOut });
        new FlxTimer().start(closeTimer, function(_:FlxTimer) {
            canClose = true;
        });

        super.create();
    }

    override function update(elapsed:Float):Void
    {
        glow1.angle += glow1spin;
        glow2.angle += glow2spin;

        if (canClose && ((controls.ACCEPT_P || controls.BACK_P) || TouchUtil.pressAction()))
        {
            close();
        }

        super.update(elapsed);
    }

    function getSparkleData(rarity:String):Void
    {
        return switch (rarity)
        {
            case "Special": { amount: 25, speedMin: 150, speedMax: 400 };
            case "Divine": { amount: 32, speedMin: 250, speedMax: 450 };
            case "Mythic": { amount: 25, speedMin: 250, speedMax: 450 };
            case "Legendary": { amount: 21, speedMin: 250, speedMax: 350 };
            case "Epic": { amount: 16, speedMin: 200, speedMax: 300 };
            case "Rare": { amount: 12, speedMin: 150, speedMax: 200 };
            case "Uncommon": { amount: 7, speedMin: 150, speedMax: 200 };
            default: { amount: 3, speedMin: 150, speedMax: 200 };
        }
    }
}