package funkbucks;

import balphabet.BAlphabet;
import flixel.FlxObject;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkbucks.objects.BoxSprite;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.mobile.ui.FunkinBackButton;
import funkin.ui.MusicBeatSubState;
import funkin.util.ReflectUtil;
import funkin.util.TouchUtil;

class BoxSubMenu extends MusicBeatSubState
{
    // Important
    var STATE:String = "CHOOSING";
    var boxIndex:Int = 0;
    var boxCount:Int = 0;

    var darkOverlay:FunkinSprite;
    var box:BoxSprite;
    var arrowLeft:FunkinSprite;
    var arrowRight:FunkinSprite;
    var menuDots:Array<FunkinSprite> = [];

    // Text
    var boxName:BAlphabet;
    var boxDescription:BAlphabet;
    var boxPrice:BAlphabet;
    var boxOdds:BAlphabet;
    var boxPurchaseLable:BAlphabet;

    var coolBackButton:FunkinBackButton;

    var leftArrowHitbox:FlxObject;
    var rightArrowHitbox:FlxObject;
    var boxHitbox:FlxObject;

    override function create():Void
    {
        // Special boxes are never shown on this menu.
        for (i in 0...FunkBucks.boxData.length)
        {
            if (!FunkBucks.boxData[i].special)
            {
                boxCount++;
            }
        }

        darkOverlay = new FunkinSprite(-64, -64).makeSolidColor(FlxG.width + 128, FlxG.height + 128, 0xFF000000);
        darkOverlay.alpha = 0;
        add(darkOverlay);

        for (i in 0...boxCount)
        {
            var dot:FunkinSprite = new FunkinSprite(FlxG.width / 2 + 40 * i - 20 * boxCount + 10, 680).loadTexture("menucountdot");
            dot.scale.set(0.75, 0.75);
            dot.alpha = 0.2;
            menuDots.push(dot);
            add(dot);
        }

        boxName = new BAlphabet(30, 25, "");
        // boxName.alignment = "center";
        boxName.scale.set(0.7, 0.7);
        add(boxName);

        boxPrice = new BAlphabet(FlxG.width / 2, 560, "");
        boxPrice.alignment = "center";
        boxPrice.scale.set(0.5, 0.5);
        add(boxPrice);

        boxDescription = new BAlphabet(30, boxName.y + 60, "");
        boxDescription.scale.set(0.4, 0.4);
        add(boxDescription);

        boxOdds = new BAlphabet(30, boxPrice.y, "");
        // boxOdds.alignment = "right";
        boxOdds.scale.set(0.3, 0.3);
        add(boxOdds);

        boxPurchaseLable = new BAlphabet(FlxG.width / 2, 510, "");
        boxPurchaseLable.alignment = "center";
        boxPurchaseLable.scale.set(0.4, 0.4);
        add(boxPurchaseLable);

        box = new BoxSprite(FlxG.width / 2, 490);
        add(box);
        
        arrowLeft = new FunkinSprite(FlxG.width / 2 - 250, 315).loadTexture("shop/boxarrow");
        arrowLeft.flipX = true;
        add(arrowLeft);

        arrowRight = new FunkinSprite(FlxG.width / 2 + 250, 315).loadTexture("shop/boxarrow");
        arrowRight.x -= arrowRight.width;
        add(arrowRight);

        leftArrowHitbox = new FlxObject(arrowLeft.x - arrowLeft.width, arrowLeft.y - arrowLeft.height, arrowLeft.width * 3, arrowLeft.height * 3);
        add(leftArrowHitbox);

        rightArrowHitbox = new FlxObject(arrowRight.x - arrowRight.width, arrowRight.y - arrowRight.height, arrowRight.width * 3, arrowRight.height * 3);
        add(rightArrowHitbox);

        boxHitbox = new FlxObject(leftArrowHitbox.x + leftArrowHitbox.width, leftArrowHitbox.y, rightArrowHitbox.x - leftArrowHitbox.x - leftArrowHitbox.width, leftArrowHitbox.height);
        add(boxHitbox);

        coolBackButton = new FunkinBackButton(FlxG.width - 220, FlxG.height / 2, 0xFFFFFFFF, goBack, 1.0, true);
        coolBackButton.y -= coolBackButton.height / 2;
        #if !mobile
        coolBackButton.visible = FunkBucks.isMouseActive;
        FlxMouseEvent.add(coolBackButton, coolBackButton.playHoldAnim, coolBackButton.playConfirmAnim);
        #end
        add(coolBackButton);

        changeSelection();
        updatePurchaseLable();

        persistentUpdate = true;

        super.create();
    }

    var prevMouseActive:Bool = FunkBucks.isMouseActive;
    public function update(elapsed:Float):Void
    {
        if (controls.BACK_P)
        {
            goBack();
        }

        if (controls.UI_LEFT_P || (TouchUtil.pressAction(leftArrowHitbox, camera) && !FunkBucks.isMouseTooFast))
        {
            changeSelection(-1);
        }

        if (controls.UI_RIGHT_P || (TouchUtil.pressAction(rightArrowHitbox, camera) && !FunkBucks.isMouseTooFast))
        {
            changeSelection(1);
        }

        if (controls.ACCEPT_P || (TouchUtil.pressAction(boxHitbox, camera) && !FunkBucks.isMouseTooFast))
        {
            pressedAccept();
        }

        coolBackButton.visible = #if mobile true; #else FunkBucks.isMouseActive; #end

        if (prevMouseActive != FunkBucks.isMouseActive)
        {
            updatePurchaseLable();
        }
        prevMouseActive = FunkBucks.isMouseActive;

        super.update(elapsed);
    }

    function goBack():Void
    {
        switch (STATE)
        {
            case "CHOOSING":
                close();
            case "CONFIRMING":
                STATE = "CHOOSING";
                updatePurchaseLable();
            default:
        }
    }

    function pressedAccept():Void
    {
        switch (STATE)
        {
            case "CHOOSING":
                if (checkIfPlayerIsRichEnough())
                {
                    STATE = "CONFIRMING";
                    updatePurchaseLable();
                    FunkinSound.playOnce(Paths.sound("unfav"));
                    FlxTween.completeTweensOf(boxPurchaseLable);
                    FlxTween.tween(boxPurchaseLable, { y: boxPurchaseLable.y - 10 }, 0.6, { ease: FlxEase.backOut, type: 16 });
                }
            case "CONFIRMING":
                STATE = "OPENING";
                openBox();
            default:
        }
    }

    function changeSelection(change:Int = 0):Void
    {
        if (STATE != "CHOOSING") return;

        boxIndex = PinUtil.wrapAround(boxIndex + change, 0, boxCount - 1);

        for (i in 0...menuDots.length)
        {
            menuDots[i].alpha = i == boxIndex ? 1 : 0.2;
        }

        if (change > 0)
        {
			FlxTween.completeTweensOf(arrowRight);
			FlxTween.completeTweensOf(arrowRight.scale);
			FlxTween.tween(arrowRight, { x: arrowRight.x + 30 }, 0.4, { ease: FlxEase.backOut, type: 16 });
			FlxTween.tween(arrowRight.scale, { y: 0.5 }, 0.4, { ease: FlxEase.backOut, type: 16 });
        }
        else if (change < 0)
        {
			FlxTween.completeTweensOf(arrowLeft);
			FlxTween.completeTweensOf(arrowLeft.scale);
			FlxTween.tween(arrowLeft, { x: arrowLeft.x - 30 }, 0.4, { ease: FlxEase.backOut, type: 16 });
			FlxTween.tween(arrowLeft.scale, { y: 0.5 }, 0.4, { ease: FlxEase.backOut, type: 16 });
        }

        STATE = "COOLDOWN";
        new FlxTimer().start(0.25, function(_:FlxTimer) {
            STATE = "CHOOSING";
        });

        box.updateBoxInfo(change);
        updateBoxInfoText();
    }

    function updatePurchaseLable():Void
    {
        switch (STATE)
        {
            case "CHOOSING", "COOLDOWN":
                boxPurchaseLable.text = FunkBucks.isMouseActive ? "<b><c=2A4DFF>TAP</c> the box to purchase.</b>" : "<b>Press <c=2A4DFF>ACCEPT</c> to purchase.</b>";
            case "CONFIRMING":
                boxPurchaseLable.text = FunkBucks.isMouseActive ? "<b><c=2BFF31>TAP</c> the box again to confirm.</b>" : "<b>Press <c=2BFF31>ACCEPT</c> again to confirm.</b>";
        }
    }

    function updateBoxInfoText():Void
    {
        boxName.text = '<b>${box.name}</b>';
        boxDescription.text = box.description;

        var freeRolls:Int = FunkBucks.getFreeBoxCount(box.bID);
        var boxPriceText:String = '<b>${freeRolls > 0 ? "FREE" : box.price} ${FBIcon.Buck}</b>\n';

        if (freeRolls > 0)
        {
            boxPriceText += '<b><s=0.75>(<c=00FF00>x${freeRolls}</c>)</s></b>';
        }
        else
        {
            if (box.angerModifier > 1.0)
            {
                boxPriceText += '<b><s=0.75>(${FBIcon.OpheliaMad} <c=FF0000>x${box.angerModifier}</c>)</s></b>';
            }
            if (box.discountModifier > 0.0)
            {
                if (box.angerModifier > 1.0) boxPriceText += " ";
                boxPriceText += '<b><s=0.75>(<c=00FF00>-${box.discountModifier}%</c>)</s></b>';
            }
        }
        
        boxPrice.text = boxPriceText;

        var boxOddsText = "";
        for (i in 0...box.chances.length)
        {
            var rarityColor:String = ReflectUtil.getAnonymousField(FunkBucks.pinData, box.chances[i][0]).color;
            boxOddsText += '<c=$rarityColor>${box.chances[i][0]}</c>: ${FlxMath.roundDecimal(box.chances[i][1] / box.totalWeight * 100, 2)}%';
            if (i < box.chances.length - 1) boxOddsText += "\n";
        }
        boxOdds.text = boxOddsText;
        boxOdds.y = FlxG.height - 20 - boxOdds.height;
    }

    function checkIfPlayerIsRichEnough():Bool
    {
        if (FunkBucks.getFunkCoins() < box.price)
        {
            _parentState.insufficientFunkBucks();
            return false;
        }
        return true;
    }

    function openBox():Void
    {
        if (box.price > 0)
        {
            _parentState.deductFunkBucks(box.price);
            FunkBucks.addOpenedBox(box.bID);
        }
        if (FunkBucks.getFreeBoxCount(box.bID) > 0) FunkBucks.addFreeBox(box.bID, -1);
        
        var randomPin:PinData = box.rollRandomRarityPin();
        var unlockState:PinUnlockState = new PinUnlockState(randomPin);
        unlockState.closeCallback = closeBox;
        unlockState.cameras = [camera];

        new FlxTimer().start(1, function(_:FlxTimer) {
            FlxTween.tween(darkOverlay, { alpha: 0.33 }, 1.1 + box.revealTime / 24, { ease: FlxEase.quadInOut });
            FlxTween.tween(_parentState.camera, { zoom: 1.15 }, 1 + box.revealTime / 24, { ease: FlxEase.quadInOut });
            FlxTween.tween(camera, { zoom: 1.25 }, 1 + box.revealTime / 24, { ease: FlxEase.quadInOut });
        });

        new FlxTimer().start(2.25, function(_:FlxTimer) {
            box.animation.play("Opening");
            new FlxTimer().start(box.revealTime / 24, function(_:FlxTimer) {
                FlxTween.tween(darkOverlay, { alpha: 0 }, 0.5, { ease: FlxEase.expoOut });
                FlxTween.tween(_parentState.camera, { zoom: 0.9 }, 1, { ease: FlxEase.backOut });
                FlxTween.tween(camera, { zoom: 1 }, 1, { ease: FlxEase.backOut, onComplete: () -> {
                    STATE = "OPENED";
                }});
                openSubState(unlockState);
            });
        });

        FlxTween.tween(boxName, { alpha: 0 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(boxDescription, { alpha: 0 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(boxPrice, { alpha: 0 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(boxOdds, { alpha: 0 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(boxPurchaseLable, { alpha: 0 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(arrowLeft, { alpha: 0 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(arrowRight, { alpha: 0 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(coolBackButton, { alpha: 0 }, 0.5, { ease: FlxEase.quartOut });
        for (i in 0...menuDots.length)
        {
            FlxTween.tween(menuDots[i], { alpha: 0 }, 0.5, { ease: FlxEase.quartOut });
        }
    }

    function closeBox():Void
    {
        box.animation.play("Closed");
        box.updatePrice();
        STATE = "CHOOSING";
        updatePurchaseLable();
        updateBoxInfoText();

        FlxTween.tween(boxName, { alpha: 1 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(boxDescription, { alpha: 1 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(boxPrice, { alpha: 1 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(boxOdds, { alpha: 1 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(boxPurchaseLable, { alpha: 1 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(arrowLeft, { alpha: 1 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(arrowRight, { alpha: 1 }, 0.5, { ease: FlxEase.quartOut });
        FlxTween.tween(coolBackButton, { alpha: 1 }, 0.5, { ease: FlxEase.quartOut });
        for (i in 0...menuDots.length)
        {
            FlxTween.tween(menuDots[i], { alpha: boxIndex == i ? 1 : 0.2 }, 0.5, { ease: FlxEase.quartOut });
        }
    }
}