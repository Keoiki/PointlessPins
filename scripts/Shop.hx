package funkbucks;

import Date;
import balphabet.BAlphabet;
import balphabet.BAlphabetTyped;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.particles.FlxEmitter;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkbucks.dialog.shop.OpheliaPin;
import funkbucks.dialog.shop.ophelia.ConverseOphelia;
import funkbucks.dialog.shop.ophelia.RealJob;
import funkbucks.objects.KeyCap;
import funkbucks.objects.Dialogue;
import funkbucks.objects.shop.Clock;
import funkbucks.objects.shop.DailyBoard;
import funkbucks.objects.shop.RewardShelf;
import funkbucks.shaders.ImposePatternShader;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinCamera;
import funkin.graphics.FunkinSprite;
import funkin.mobile.ui.FunkinBackButton;
import funkin.modding.ModStore;
import funkin.ui.MusicBeatState;
import funkin.ui.mainmenu.MainMenuState;
import funkin.util.ReflectUtil;
import funkin.util.TouchUtil;
using StringTools;

class Shop extends MusicBeatState
{
    // Important
    public var savedCamZoom:Float = 0.0;
    public var cameraHUD:FunkinCamera;
    public var cameraSubState:FunkinCamera;
    var spriteNudge:Float = (1600 - FlxG.width) / 2;
    public var disallowInputs:Bool = false;
    public var cameraFollowPoint:FlxObject;
    public var cameraFollowPointMarker:FunkinSprite;
    var justGainedFocus:Bool = false;
    public var subToSub:Bool = false;

    public var talkingToOphelia:Bool = false;
    public var isShopkeeperGone:Bool = false;
    var extendBounds:Bool = false;
    var cannotDoText:BAlphabet;

    var buckSound:FunkinSound;

    // Dialogue
    public var dialog:Dialogue;

    // Shop
    var shopkeeperHitbox:FlxObject;
    public var shopkeeper:Shopkeeper;

    public var wall:FunkinSprite;
    public var lighting:FunkinSprite;

    public var clock:Clock;
    public var dailyBoard:DailyBoard;
    public var rewardShelf:RewardShelf;
    public var cloverEventButton:FunkinSprite;

    var counterItems = [];
    public var skcItem1:FunkinSprite;
    public var skcItem2:FunkinSprite;

    public var iconPins:FunkinSprite;
    var lablePins:BAlphabet;
    var keycapPins:KeyCap;

    public var iconBoxes:FunkinSprite;
    var lableBoxes:BAlphabet;
    var keycapBoxes:KeyCap;

    public var iconConverse:FunkinSprite;
    var lableConverse:BAlphabet;
    var keycapConverse:KeyCap;

    public var iconRewards:FunkinSprite;
    var lableRewards:BAlphabet;
    var keycapRewards:KeyCap;
    var rewardsSparkles:FlxEmitter;

    // UI
    public var funkBucksText:BAlphabet;
    public var blueJewelsText:BAlphabet;
    public var screenBlack:FunkinSprite;
    
    var updateText:BAlphabet;

    public var coolBackButton:FunkinBackButton;

    public static var instance:Shop;

    override function new():Void
    {
        super();
    }

    override public function create():Void
    {
        Shop.instance = this;

        if (!FunkBucks.hasObtainedPin("shockedcat") && FlxG.random.bool(0.05))
        {
            FunkBucks.pinUnlockQueue.push("shockedcat");
        }

        camera.bgColor = 0xFF616182;

        cameraHUD = new FunkinCamera("shopCamHUD");
		FlxG.cameras.add(cameraHUD, false);
        cameraHUD.bgColor = 0x007F7F7F;

        cameraSubState = new FunkinCamera("shopCamSubState");
        FlxG.cameras.add(cameraSubState, false);
        cameraSubState.bgColor = 0x007F7F7F;

        cameraFollowPoint = new FlxObject(800 - spriteNudge, 300, 1, 1);
        add(cameraFollowPoint);
        camera.follow(cameraFollowPoint, null, 0.05);

        cameraFollowPointMarker = new FunkinSprite(800 - spriteNudge, 300).makeSolidColor(5, 5, 0xFF00FF00);
        cameraFollowPointMarker.zIndex = 9999999;
        // add(cameraFollowPointMarker);

        final skName:String = FunkBucks.getShopkeeper();

        if (FlxG.random.bool(1) && !Shopkeeper.caught && skName == "ophelia")
        {
            // Ophelia forgor to show up
            isShopkeeperGone = true;
            if (FlxG.random.bool(10))
            {
                extendBounds = true;
            }
        }

        if (TimedCoinsManager.running || isShopkeeperGone || Shopkeeper.caught)
        {
            FlxG.sound.music.stop();
        }
        else
        {
            FunkinSound.playMusic('chartEditorLoop',
            {
                startingVolume: 0.75,
                overrideExisting: true,
                restartTrack: false,
                persist: true
            });
        }

        buckSound = new FunkinSound();
        buckSound.loadEmbedded(Paths.sound("fav"));
        buckSound.volume = 0.35;

        FlxG.sound.defaultSoundGroup.add(buckSound);
        FlxG.sound.list.add(buckSound);

        // Shop

        wall = new FunkinSprite(-950 - spriteNudge, -400).loadTexture("shop/wall");
        wall.zIndex = -1000;
        wall.scrollFactor.set(0.85, 0.85);
        add(wall);

        dailyBoard = new DailyBoard(615 - spriteNudge, 0);
        dailyBoard.zIndex = -998;
        add(dailyBoard);

        rewardShelf = new RewardShelf(1350 - spriteNudge, -35);
        rewardShelf.zIndex = -995;
        add(rewardShelf);

        clock = new Clock(1168 - spriteNudge, -200);
        clock.zIndex = -993;
        add(clock);

        cloverEventButton = new FunkinSprite(2055 - spriteNudge, -250).makeSolidColor(150, 150, 0xFF00FF00);
        cloverEventButton.scrollFactor.set(0.85, 0.85);
        cloverEventButton.zIndex = -990;
        cloverEventButton.visible = FunkBucks.getUnlockedPinsCount() >= 30;
        add(cloverEventButton);

        if (!FunkBucks.hasObtainedPin("tuntematon") && FunkBucks.getUnlockedPinsCount() >= 75 && FlxG.random.bool(0.1) && !Tuntematon.gone && !Shopkeeper.caught)
        {
            var t:Tuntematon = new Tuntematon(1350 - spriteNudge + rewardShelf.shelf.width, 80);
            t.zIndex = -979;
            t.scrollFactor.set(0.85, 0.85);
            add(t);
        }

        lighting = new FunkinSprite(-800, -440).makeSolidColor(3000, 1600, 0xFF3C1B41);
        lighting.zIndex = 10000;
        lighting.scrollFactor.set(0, 0);
        lighting.blend = 9;
        lighting.alpha = isShopkeeperGone ? 0.85 : 0;
        add(lighting);

        shopkeeper = new Shopkeeper(1045 - spriteNudge, 150, "ophelia");
        shopkeeper.zIndex = 400;
        shopkeeper.scrollFactor.set(0.98, 1);
        add(shopkeeper);

        shopkeeperHitbox = new FlxObject(shopkeeper.x + 20, shopkeeper.y + 20, 280, 320);
        shopkeeper.scrollFactor.set(0.98, 1);
        add(shopkeeperHitbox);

        counter = new FunkinSprite(-950 - spriteNudge, 490).loadTexture("shop/counter");
        counter.zIndex = 500;
        counter.scrollFactor.set(1, 1);
        add(counter);

        var fbStack1:FunkinSprite = new FunkinSprite(-100 - spriteNudge, 444).loadTexture("shop/rewards/funkbuck01");
        fbStack1.zIndex = 490;
        add(fbStack1);

        var fbStack2:FunkinSprite = new FunkinSprite(2050 - spriteNudge, 424).loadTexture("shop/rewards/funkbuck02");
        fbStack2.zIndex = 491;
        add(fbStack2);

        var fbStack3:FunkinSprite = new FunkinSprite(-700 - spriteNudge, 384).loadTexture("shop/rewards/funkbuck03");
        fbStack3.zIndex = 492;
        add(fbStack3);

        if (shopkeeper.name == "ophelia")
        {
            skcItem1 = new FunkinSprite(1000 - spriteNudge, 444).loadTexture("shop/rewards/funkbuck01");
            skcItem1.zIndex = 490;
            add(skcItem1);

            skcItem2 = new FunkinSprite(1300 - spriteNudge, 424).loadTexture("shop/rewards/funkbuck02");
            skcItem2.zIndex = 491;
            add(skcItem2);

            // counterItems.push(skcItem1);
            // counterItems.push(skcItem2);
        }
        else if (shopkeeper.name == "april")
        {
            skcItem1 = new FunkinSprite(1350 - spriteNudge, 353).loadTexture("shop/aprilDrink");
            skcItem1.zIndex = 490;
            add(skcItem1);

            skcItem2 = new FunkinSprite(900 - spriteNudge, 440).loadTexture("shop/aprilChipBag");
            skcItem2.zIndex = 490;
            add(skcItem2);

            // counterItems.push(skcItem1);
            // counterItems.push(skcItem2);
        }

        if (Shopkeeper.caught)
        {
            remove(dailyBoard);
            remove(rewardShelf);
            remove(fbStack1);
            remove(fbStack2);
            remove(fbStack3);
            lighting.alpha = 0.9;
        }
        else
        {
            counterItems.push(fbStack1);
            counterItems.push(fbStack2);
            counterItems.push(fbStack3);
        }

        for (i in 0...3)
        {
            if (Shopkeeper.caught) break;

            var lamp:FunkinSprite = new FunkinSprite(-400 + (i * 1020) - spriteNudge, -460, "shop/lamp");
            lamp.zIndex = 2000;
            lamp.scrollFactor.set(1.1, 1.0);
            add(lamp);
            lamp.scale.set(0.8, 0.8);
            lamp.anim.play(isShopkeeperGone ? "off" : "on");
        }

        iconPins = new FunkinSprite(-400 - spriteNudge, 330).loadTexture("shop/iconpins");
        iconPins.zIndex = 490;
        add(iconPins);

        lablePins = new BAlphabet(iconPins.x + iconPins.width / 2, 520, "<b>Pins</b>");
        lablePins.alignment = "center";
        lablePins.scale.set(0.65, 0.65);
        lablePins.zIndex = 510;
        add(lablePins);

        iconBoxes = new FunkinSprite(160 - spriteNudge, 356).loadTexture("shop/iconboxes");
        iconBoxes.zIndex = 491;
        add(iconBoxes);

        lableBoxes = new BAlphabet(iconBoxes.x + iconBoxes.width / 2, 520, "<b>Boxes</b>");
        lableBoxes.alignment = "center";
        lableBoxes.scale.set(0.65, 0.65);
        lableBoxes.zIndex = 512;
        add(lableBoxes);

        // lableConverse = new BAlphabet(1200 - spriteNudge, 520, "<b>Exchange\n<s=-0.45>ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz.,-=?!*^+</s></b>");
        lableConverse = new BAlphabet(1200 - spriteNudge, 520, "<b>Converse</b>");
        lableConverse.scale.set(0.65, 0.65);
        lableConverse.alignment = "center";
        lableConverse.zIndex = 516;
        add(lableConverse);

        // var box:FunkinSprite = new FunkinSprite(lableConverse.x - 200, lableConverse.y).makeSolidColor(400, 60 * lableConverse.scale.y, 0x7B00FF00);
        // box.zIndex = 520;
        // add(box);

        // var box:FunkinSprite = new FunkinSprite(lableConverse.x - 200, lableConverse.y + 85 * lableConverse.scale.y).makeSolidColor(400, 60 * lableConverse.scale.y, 0x7B00FF00);
        // box.zIndex = 520;
        // add(box);

        // var box:FunkinSprite = new FunkinSprite(lableConverse.x - 200, lableConverse.y + 85 * 2 * lableConverse.scale.y).makeSolidColor(400, 60 * lableConverse.scale.y, 0x7B00FF00);
        // box.zIndex = 520;
        // add(box);

        iconRewards = new FunkinSprite(1740 - spriteNudge, 330).loadTexture("shop/iconrewards");
        iconRewards.zIndex = 493;
        add(iconRewards);

        lableRewards = new BAlphabet(1850 - spriteNudge, 520, "<b>Rewards</b>");
        lableRewards.alignment = "center";
        lableRewards.scale.set(0.65, 0.65);
        lableRewards.zIndex = 514;
        add(lableRewards);

        rewardsSparkles = new FlxEmitter(1740 - spriteNudge, 330);
        rewardsSparkles.setSize(150, 150);
        rewardsSparkles.loadParticles(Paths.image("pinsparkle"), 30, 0);
        rewardsSparkles.acceleration.set(1, 1, -1, -3, 5, 5, -5, -10);
        rewardsSparkles.scale.set(0.1, null, 0.3, null, 0.0, null, 0.1, null);
        rewardsSparkles.keepScaleRatio = true;
        rewardsSparkles.color.set(0xFFFFFFFF, 0xFFFFFF00);
        rewardsSparkles.speed.set(0, -1, 0, 0);
        rewardsSparkles.alpha.set(0.3, 0.9, 0.0, 0.0);
        rewardsSparkles.angle.set(-180, 180, -180, 180);
        rewardsSparkles.ignoreAngularVelocity = true;
        rewardsSparkles.lifespan.set(10, 15);
        rewardsSparkles.blend = 0;
        rewardsSparkles.zIndex = 502;
        add(rewardsSparkles);
        rewardsSparkles.focusOn(iconRewards);
        rewardsSparkles.start(false, 0.45);

        counterItems.push(iconPins);
        counterItems.push(iconBoxes);
        counterItems.push(iconRewards);
        counterItems.push(lablePins);
        counterItems.push(lableBoxes);
        counterItems.push(lableConverse);
        counterItems.push(lableRewards);

        #if !mobile
        keycapPins = new KeyCap(lablePins.x - 45, 570, "1", false);
        keycapPins.zIndex = 512;
        add(keycapPins);

        keycapBoxes = new KeyCap(lableBoxes.x - 45, 570, "2", false);
        keycapBoxes.zIndex = 514;
        add(keycapBoxes);

        keycapConverse = new KeyCap(lableConverse.x - 45, 570, "3", false);
        keycapConverse.zIndex = 518;
        add(keycapConverse);

        keycapRewards = new KeyCap(lableRewards.x - 45, 570, "4", false);
        keycapRewards.zIndex = 520;
        add(keycapRewards);

        counterItems.push(keycapPins);
        counterItems.push(keycapBoxes);
        counterItems.push(keycapRewards);
        counterItems.push(keycapConverse);
        #end
        
        // UI

        screenBlack = new FunkinSprite(-2, -2).makeSolidColor(FlxG.width + 4, FlxG.height + 4, 0xFF000000);
        screenBlack.alpha = 0.0;
        screenBlack.scrollFactor.set(0, 0);
        add(screenBlack);

        funkBucksText = new BAlphabet(FlxG.width - 20, 25, '<b>${FunkBucks.getFunkCoins()}</b> ${FBIcon.Buck}');
        funkBucksText.scale.set(0.65, 0.65);
        funkBucksText.alignment = "right";
        add(funkBucksText);

        blueJewelsText = new BAlphabet(FlxG.width - 20, funkBucksText.y + 70, '<b><c=82E9FF>${FunkBucks.getBlueJewels()}</c></b> ${FBIcon.Jewel}');
        blueJewelsText.alignment = "right";
        blueJewelsText.scale.set(0.65, 0.65);
        add(blueJewelsText);

        cannotDoText = new BAlphabet(FlxG.width / 2, FlxG.height - 100, "<b><c=FF0000>You cannot do that right now.</c></b>");
        cannotDoText.alignment = "center";
        cannotDoText.scale.set(0.5, 0.5);
        cannotDoText.alpha = 0.0001;
        add(cannotDoText);

        coolBackButton = new FunkinBackButton(FlxG.width - 220, FlxG.height - 200, 0xFFFFFFFF, goBack, 0.5);
        #if !mobile
        coolBackButton.visible = FunkBucks.isMouseActive;
        FlxMouseEvent.add(coolBackButton, coolBackButton.playHoldAnim, coolBackButton.playConfirmAnim);
        #end
        add(coolBackButton);

        // var box:FunkinSprite = new FunkinSprite(0, 0).makeSolidColor(1600, 60, 0xFFFFFFFF);
        // box.cameras = [cameraHUD];
        // add(box);

        // var test = new BAlphabet(FlxG.width / 2, 0, "<b>Aa<s=0.9>Bb</s><s=0.8>Cc</s><s=0.7>Dd</s><s=0.6>Ee</s><s=0.5>Ff</s><s=0.4>Gg</s><s=0.3>Hh</s><s=0.2>Ii</s><s=0.1>Jj</s></b>");
        // test.scale.set(0.75, 0.75);
        // test.alignment = "center";
        // add(test);
        // test.cameras = [cameraHUD];

        // var box:FunkinSprite = new FunkinSprite(FlxG.width / 2, 0).makeSolidColor(800, 60 * test.scale.y, 0x7B00FF00);
        // box.cameras = [cameraHUD];
        // add(box);

        // var box:FunkinSprite = new FunkinSprite(FlxG.width / 2 - 200, 0).makeSolidColor(200, 60 * test.scale.y, 0x7BFF0000);
        // box.cameras = [cameraHUD];
        // add(box);

        screenBlack.cameras = [cameraHUD];
        funkBucksText.cameras = [cameraHUD];
        blueJewelsText.cameras = [cameraHUD];
        cannotDoText.cameras = [cameraHUD];
        coolBackButton.cameras = [cameraHUD];

        if (ModStore.get("funkbucksOutdated") && ModStore.get("funkbucksShownOutdate") == null)
        {
            var alert:BAlphabet = new BAlphabet(30, 30,
                '<c=FFB51C><b>New version is available:</c> <c=00FF00>${ModStore.get("funkbucksNewVersion")}</c>\n<s=0.75>${ModStore.get("funkbucksNewVersionInfo")}</s></b>',
                { lineHeight: 60 });
            alert.scale.set(0.4, 0.4);
            alert.zIndex = 100000;
            add(alert);
            alert.cameras = [cameraHUD];

            var alertBG:FunkinSprite = new FunkinSprite(0, 0).makeSolidColor(alert.width + 60, alert.height + 60, 0xFF000000);
            alertBG.zIndex = 99999;
            alertBG.alpha = 0.5;
            alertBG.cameras = [cameraHUD];
            add(alertBG);
            
            new FlxTimer().start(14, (_:FlxTimer) -> {
                FlxTween.tween(alert, { alpha: 0 }, 2, { ease: FlxEase.quintOut });
                FlxTween.tween(alertBG, { alpha: 0 }, 2, { ease: FlxEase.quintOut });
            });

            ModStore.register("funkbucksShownOutdate", true);
        }

        persistentUpdate = true;

        final leftXLimit:Float = extendBounds ? 5000 : 100;
        final rightXLimit:Float = extendBounds ? 100000 : 100;

        if (extendBounds)
        {
            constructOldShop();
        }

        var bound001:FunkinSprite = new FunkinSprite(10000, wall.y).makeSolidColor(3, wall.height, 0xFFFF0000);
        bound001.zIndex = 88888888;
        // add(bound001);

        var bound002:FunkinSprite = new FunkinSprite(30000, wall.y).makeSolidColor(3, wall.height, 0xFFFF0000);
        bound002.zIndex = 88888888;
        // add(bound002);

        var bound002:FunkinSprite = new FunkinSprite(50000, wall.y).makeSolidColor(3, wall.height, 0xFFFF0000);
        bound002.zIndex = 88888888;
        // add(bound002);

        camera.minScrollX = wall.x - leftXLimit;
        camera.maxScrollX = wall.x + wall.width + rightXLimit;
        camera.minScrollY = wall.y;
        camera.maxScrollY = counter.y + counter.height - 25;

        refresh();

        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        var lerpval:Float = FlxMath.bound(elapsed * 9.6, 0, 1);
        funkBucksText.y = FlxMath.lerp(funkBucksText.y, 25, lerpval);
        blueJewelsText.y = FlxMath.lerp(blueJewelsText.y, 95, lerpval);

        if (isShopkeeperGone)
        {
            shopkeeper.visible = false;
        }

        if (controls.BACK_P)
        {
            goBack();
        }

        if (disallowInputs)
        {
            coolBackButton.enabled = false;
            coolBackButton.visible = false;
            return;
        }
        coolBackButton.visible = #if mobile true; #else FunkBucks.isMouseActive; #end
        coolBackButton.enabled = true;

        handleCameraMovement();
        // checkIfAnnoyedShopkeeper();

        if (cameraFollowPointMarker != null)
        {
            cameraFollowPointMarker.x = cameraFollowPoint.x - 2;
            cameraFollowPointMarker.y = cameraFollowPoint.y - 2;
        }

        if (extendBounds && cameraFollowPoint.x >= 10000)
        {
            final targetUIAlpha:Float = 1.0 - (1.0 * (cameraFollowPoint.x - 10000) / 20000);
            funkBucksText.alpha = targetUIAlpha;
            blueJewelsText.alpha = targetUIAlpha;
            final targetDarkness:Float = 0.85 + (0.15 * (cameraFollowPoint.x - 10000) / 20000);
            lighting.alpha = targetDarkness;
            camera.minScrollY = wall.y + 360;
            coolBackButton.enabled = false;
            coolBackButton.visible = false;
        }
        else
        {
            camera.minScrollY = wall.y;
        }

        justGainedFocus = false;

        // Pins

        if (FlxG.keys.justPressed.ONE || (TouchUtil.pressAction(iconPins) && !FunkBucks.isMouseTooFast && !TouchUtil.overlaps(coolBackButton, cameraHUD)))
        {
            if (TimedCoinsManager.running)
            {
                FlxTween.completeTweensOf(cannotDoText);
                FlxTween.tween(cannotDoText, { alpha: 1 }, 2, { ease: FlxEase.cubeOut, type: 16 });
                return;
            }

            disallowInputs = true;
            cameraFollowPoint.setPosition(iconPins.x + iconPins.width / 2, iconPins.y + 45);
            savedCamZoom = camera.zoom;

            var substate = new PinBoard();
            substate.closeCallback = function()
            {
                FlxTween.tween(coolBackButton, { alpha: 0.5 }, 1, { ease: FlxEase.cubeOut });
                FlxTween.tween(camera, { zoom: savedCamZoom }, 1, { ease: FlxEase.cubeOut });
                toggleDisplayBucks(true);
                toggleDisplayJewels(true);
                FlxTween.tween(screenBlack, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
            };
            substate.cameras = [cameraSubState];

            FlxTween.tween(coolBackButton, { alpha: 0 }, 1, { ease: FlxEase.cubeIn });
            FlxTween.tween(camera, { zoom: 1.5 }, 1, { ease: FlxEase.cubeIn });
            toggleDisplayBucks(false);
            toggleDisplayJewels(false);
            FlxTween.tween(screenBlack, { alpha: 0.8 }, 1, { ease: FlxEase.cubeIn, onComplete: function()
            {
                openSubState(substate);
            }});
        }

        // Boxes

        if (FlxG.keys.justPressed.TWO || (TouchUtil.pressAction(iconBoxes) && !FunkBucks.isMouseTooFast && !TouchUtil.overlaps(coolBackButton, cameraHUD)))
        {
            if (isShopkeeperGone || Shopkeeper.caught || TimedCoinsManager.running)
            {
                FlxTween.completeTweensOf(cannotDoText);
                FlxTween.tween(cannotDoText, { alpha: 1 }, 2, { ease: FlxEase.cubeOut, type: 16 });
                return;
            }

            disallowInputs = true;
            cameraFollowPoint.setPosition(iconBoxes.x + iconBoxes.width / 2, iconBoxes.y - 4);
            showMenuItems(false);
            savedCamZoom = camera.zoom;

            var substate = new BoxSubMenu();
            substate.closeCallback = function()
            {
                FlxTween.tween(coolBackButton, { alpha: 0.5 }, 1, { ease: FlxEase.cubeOut });
                FlxTween.tween(camera, { zoom: savedCamZoom }, 1, { ease: FlxEase.cubeOut });
                toggleDisplayJewels(true);
                FlxTween.tween(screenBlack, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
                showMenuItems();
            }
            substate.cameras = [cameraSubState];

            FlxTween.tween(coolBackButton, { alpha: 0 }, 1, { ease: FlxEase.cubeIn });
            FlxTween.tween(screenBlack, { alpha: 0.5 }, 1, { ease: FlxEase.cubeIn });
            toggleDisplayJewels(false);
            FlxTween.tween(camera, { zoom: 0.9 }, 1, { ease: FlxEase.cubeOut, onComplete: function()
            {
                openSubState(substate);
            }});
        }

        // Converse

        if (FlxG.keys.justPressed.THREE || (TouchUtil.pressAction(shopkeeperHitbox) && !FunkBucks.isMouseTooFast && !TouchUtil.overlaps(coolBackButton, cameraHUD)))
        {
            if (isShopkeeperGone || Shopkeeper.caught || TimedCoinsManager.running)
            {
                FlxTween.completeTweensOf(cannotDoText);
                FlxTween.tween(cannotDoText, { alpha: 1 }, 2, { ease: FlxEase.cubeOut, type: 16 });
                return;
            }

            new FlxTimer().start(0.5, function(_:FlxTimer)
            {
                switch (shopkeeper.name)
                {
                    case "ophelia":
                        new ConverseOphelia();
                    case "april":
                    default:
                        return;
                }
            });

            disallowInputs = true;
            showMenuItems(false);
            cameraFollowPoint.setPosition(shopkeeperHitbox.x + shopkeeperHitbox.width / 2, shopkeeperHitbox.y + 115);
            savedCamZoom = camera.zoom;
            FlxTween.tween(camera, { zoom: 1.5 }, 1, { ease: FlxEase.cubeOut });
            toggleDisplayBucks(false);
            toggleDisplayJewels(false);
            coolBackButton.visible = false;
        }

        // Rewards

        if (FlxG.keys.justPressed.FOUR || (TouchUtil.pressAction(iconRewards) && !FunkBucks.isMouseTooFast && !TouchUtil.overlaps(coolBackButton, cameraHUD)))
        {
            if (isShopkeeperGone || Shopkeeper.caught || TimedCoinsManager.running)
            {
                FlxTween.completeTweensOf(cannotDoText);
                FlxTween.tween(cannotDoText, { alpha: 1 }, 2, { ease: FlxEase.cubeOut, type: 16 });
                return;
            }

            disallowInputs = true;
            cameraFollowPoint.setPosition(rewardShelf.x + rewardShelf.shelf.width / 1.35 - 2.5, 240);
            showMenuItems(false);
            rewardShelf.toggleItems();
            savedCamZoom = camera.zoom;
            
            rewardsSparkles.kill();

            var substate = new RewardsSubMenu();
            substate.closeCallback = function()
            {
                shopkeeper.playAnimation("Idle", true, true);
                FlxTween.tween(coolBackButton, { alpha: 0.5 }, 1, { ease: FlxEase.cubeOut });
                FlxTween.tween(camera, { zoom: savedCamZoom }, 1, { ease: FlxEase.cubeOut });
                showMenuItems();
                rewardShelf.toggleItems(true);
                rewardsSparkles.revive();
                rewardsSparkles.start(false, 0.45);
            }
            substate.cameras = [cameraSubState];

            FlxTween.tween(coolBackButton, { alpha: 0 }, 1, { ease: FlxEase.cubeIn });
            FlxTween.tween(camera, { zoom: 1.2 }, 1, { ease: FlxEase.cubeOut, onComplete: function()
            {
                openSubState(substate);
            }});
        }
    }

    function goBack():Void
    {
        if (disallowInputs) return;
        FlxG.switchState(() -> new MainMenuState());
    }

    public function toggleDisplayBucks(show:Bool = true):Void
    {
        FlxTween.completeTweensOf(funkBucksText);
        if (show)
        {
            FlxTween.tween(funkBucksText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
        }
        else
        {
            FlxTween.tween(funkBucksText, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
        }
    }

    public function toggleDisplayJewels(show:Bool = true):Void
    {
        FlxTween.completeTweensOf(blueJewelsText);
        if (show)
        {
            FlxTween.tween(blueJewelsText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
        }
        else
        {
            FlxTween.tween(blueJewelsText, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
        }
    }

    var touchPoint:Null<FlxPoint>;
    var touchPoint2:Null<FlxPoint>;
    var pinchDistance:Float = 0;
    var previousZoom:Float = 1;
    function handleCameraMovement():Void
    {
        var moveSpeed:Float = 50;

        // Stop flinging the camera if we just got focus.
        if (justGainedFocus || disallowInputs) return;

        // No using FlxG.updateFramerate, as it seems to shorten down the dragging distance drastically when at higher framerates.

        #if mobile
        // Pinch Zooming
        if (FlxG.touches.list.length >= 2)
        {
            var firstTouch = FlxG.touches.list[0];
            var secondTouch = FlxG.touches.list[1];

            if (firstTouch == null || secondTouch == null) return;

            if (firstTouch.pressed && secondTouch.pressed)
            {
                if (touchPoint == null || touchPoint2 == null) 
                {
                    touchPoint = new FlxPoint(firstTouch.gameX, firstTouch.gameY);
                    touchPoint2 = new FlxPoint(secondTouch.gameX, secondTouch.gameY);
                    pinchDistance = distance(touchPoint, touchPoint2);
                    previousZoom = camera.zoom;
                }
                var currentPinchDistance = distance(FlxPoint.weak(firstTouch.gameX, firstTouch.gameY), FlxPoint.weak(secondTouch.gameX, secondTouch.gameY));
                var pinchRatio:Float = pinchDistance / currentPinchDistance;
                camera.zoom = previousZoom * pinchRatio;
                camera.zoom = FlxMath.bound(camera.zoom, 0.7, 2);
                FlxTween.cancelTweensOf(camera);
                // trace(pinchDistance, currentPinchDistance, pinchRatio);
                return;
            }
            else
            {
                touchPoint = null;
                touchPoint2 = null;
                pinchDistance = 0;
            }
        }
        else // Touch Dragging
        {
            for (touch in FlxG.touches.list)
            {
                if (touch.pressed)
                {
                    final deltaX = touch.deltaViewX;
                    if (Math.abs(deltaX) > 2)
                    {
                        var dpiScale = FlxG.stage.window.display.dpi / 160;
                        dpiScale = FlxMath.bound(dpiScale, 0.5, 1);
                        var moveLength = (deltaX * moveSpeed * 1.5) / 60 / dpiScale;
                        cameraFollowPoint.x -= moveLength;
                    }

                    final deltaY = touch.deltaViewY;
                    if (Math.abs(deltaY) > 2)
                    {
                        var dpiScale = FlxG.stage.window.display.dpi / 160;
                        dpiScale = FlxMath.bound(dpiScale, 0.5, 1);
                        var moveLength = (deltaY * moveSpeed * 1.5) / 60 / dpiScale;
                        cameraFollowPoint.y -= moveLength;
                    }
                }
            }
        }
        #else
        // Mouse Dragging
        if (FlxG.mouse.pressed)
        {
            final deltaX = FlxG.mouse.deltaViewX;
            if (Math.abs(deltaX) > 2)
            {
                var dpiScale = FlxG.stage.window.display.dpi / 160;
                dpiScale = FlxMath.bound(dpiScale, 0.5, 1);
                var moveLength = (deltaX * moveSpeed) / 60 / dpiScale;
                cameraFollowPoint.x -= moveLength;
            }

            final deltaY = FlxG.mouse.deltaViewY;
            if (Math.abs(deltaY) > 2)
            {
                var dpiScale = FlxG.stage.window.display.dpi / 160;
                dpiScale = FlxMath.bound(dpiScale, 0.5, 1);
                var moveLength = (deltaY * moveSpeed) / 60 / dpiScale;
                cameraFollowPoint.y -= moveLength;
            }
        }

        // Mouse Scrolling - Zoom
        if (FlxG.mouse.wheel != 0)
        {
            camera.zoom = FlxMath.bound(camera.zoom + 0.1 * FlxG.mouse.wheel, 0.7, 2);
            FlxTween.cancelTweensOf(camera);
        }

        // Let's not go Mach 3 while at 500 FPS, ok?
        moveSpeed *= elapsed;
        // Keyboard Controls
        if (controls.UI_LEFT) cameraFollowPoint.x -= moveSpeed * 30;
        if (controls.UI_RIGHT) cameraFollowPoint.x += moveSpeed * 30;
        if (controls.UI_UP) cameraFollowPoint.y -= moveSpeed * 30;
        if (controls.UI_DOWN) cameraFollowPoint.y += moveSpeed * 30;
        #end

        cameraFollowPoint.x = FlxMath.bound(cameraFollowPoint.x, camera.minScrollX, camera.maxScrollX);
        cameraFollowPoint.y = FlxMath.bound(cameraFollowPoint.y, camera.minScrollY, camera.maxScrollY);
    }

    // FlxPoint.distanceTo is not a known function, thanks Polymod!
    function distance(point1:FlxPoint, point2:FlxPoint):Float
    {
        return Math.sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y));
    }

    public function showMenuItems(show:Bool = true):Void
    {
        var targetAlpha:Float = show ? 1.0 : 0.0;
        for (item in counterItems)
        {
            FlxTween.tween(item, { alpha: targetAlpha }, 1, { ease: FlxEase.cubeIn });
        }
    }

    /**
     * (Ophelia) 50 taps: Ophelia gives a Pin of herself.
     * (Ophelia) 75 taps: Warning.
     * (Ophelia) Every 100 taps: +1 to her anger count.
     */
    function checkIfAnnoyedShopkeeper():Void
    {
        if (isShopkeeperGone || !shopkeeper.canAnnoy || TimedCoinsManager.running)
        {
            return;
        }

        // The shopkeeper's sprite extends behind the counter, we don't wanna count pressing in that area as well.
        if (TouchUtil.pressAction(shopkeeperHitbox, camera) && !TouchUtil.overlaps(coolBackButton, cameraHUD) && !FunkBucks.isMouseTooFast)
        {
            if (Tuntematon.gone && !Shopkeeper.caught)
            {
                Shopkeeper.annoyance = 0;
                disallowInputs = true;
                ebgquwwghobehjovbefogbeqir();
                return;
            }
            else if (Shopkeeper.caught)
            {
                FlxTween.completeTweensOf(cannotDoText);
                FlxTween.tween(cannotDoText, { alpha: 1 }, 2, { ease: FlxEase.cubeOut, type: 16 });
                return;
            }

            Shopkeeper.annoyance++;
            trace("Boop! " + Shopkeeper.annoyance);

            if (shopkeeper.name == "ophelia")
            {
                trace("ugh 2", shopkeeper.canAnnoy);
                if (Shopkeeper.annoyance == 5)
                {
                    new FlxTimer().start(0.5, function(_:FlxTimer)
                    {
                        new OpheliaPin();
                    });

                    disallowInputs = true;
                    showMenuItems(false);
                    cameraFollowPoint.setPosition(shopkeeperHitbox.x + shopkeeperHitbox.width / 2, shopkeeperHitbox.y + 115);
                    savedCamZoom = camera.zoom;
                    FlxTween.tween(camera, { zoom: 1.5 }, 1, { ease: FlxEase.cubeOut });
                    toggleDisplayBucks(false);
                    FlxTween.tween(blueJewelsText, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
                    coolBackButton.visible = false;
                    trace("Enough booping!");
                    return;
                }

                if (Shopkeeper.annoyance == 75 && FunkBucks.getOpheliaAnger() == 0)
                {
                    if (dialog != null) remove(dialog);
                    dialog = new Dialogue("anger/warning");
                    add(dialog);
                    dialog.cameras = [cameraHUD];
                    shopkeeper.canAnnoy = false;

                    dialog.dialogueText.letterCallback = (code) ->
                    {
                        if (FunkBucks.skipTalking.contains(code)) return;
                        FunkinSound.playOnce(Paths.sound("chartingSounds/keyboard" + FlxG.random.int(1, 3)), 1.0);
                        shopkeeper.playAnimation('Talk', false, false);
                    }

                    dialog.onCompleteDialogue.add(() ->
                    {
                        shopkeeper.canAnnoy = true;
                    });
                }

                if (Shopkeeper.annoyance % 100 == 0)
                {
                    if (FunkBucks.getOpheliaAnger() == 0)
                    {
                        // FunkBucks.save.opheliaAngerTime = Date.now().getTime();
                    }
                    disallowInputs = true;
                    if (FunkBucks.getOpheliaAngerTotal() > 0)
                    {
                        if (FunkBucks.getOpheliaAnger() > 5)
                        {
                            opheliaAngerDialogue("repeat3");
                        }
                        else if (FunkBucks.getOpheliaAnger() > 0)
                        {
                            opheliaAngerDialogue("repeat2");
                        }
                        else
                        {
                            opheliaAngerDialogue("repeat");
                        }
                    }
                    else
                    {
                        opheliaAngerDialogue("initial");
                    }
                    // FunkBucks.addOpheliaAnger(1);
                    trace("FUCK YOU!!!!");
                    return;
                }
            }

            shopkeeper.playAnimation("GetTappedOn1", false, true);
        }
    }

    function opheliaAngerDialogue(variant:String):Void
    {
        if (dialog != null) remove(dialog);
        dialog = new Dialogue("anger/" + variant);
        add(dialog);
        dialog.cameras = [cameraHUD];

        dialog.dialogueText.letterCallback = (code) ->
        {
            if (FunkBucks.skipTalking.contains(code)) return;
            FunkinSound.playOnce(Paths.sound("chartingSounds/keyboard" + FlxG.random.int(1, 3)), 1.0);
            shopkeeper.playAnimation('Talk', false, false);
        }

        dialog.onCompleteDialogue.add(() ->
        {
            disallowInputs = false;
            showMenuItems(true);
            FlxTween.tween(camera, { zoom: savedCamZoom }, 1, { ease: FlxEase.cubeOut });
            FlxTween.tween(funkBucksText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
            FlxTween.tween(blueJewelsText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
        });
        
        showMenuItems(false);
        cameraFollowPoint.setPosition(shopkeeperHitbox.x + shopkeeperHitbox.width / 2, shopkeeperHitbox.y + 100);
        savedCamZoom = camera.zoom;
        FlxTween.tween(camera, { zoom: 1.35 }, 1, { ease: FlxEase.cubeOut });
        FlxTween.tween(funkBucksText, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
        FlxTween.tween(blueJewelsText, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
        coolBackButton.visible = false;
    }

    function ebgquwwghobehjovbefogbeqir():Void
    {
        if (dialog != null) remove(dialog);
        dialog = new Dialogue("secret/nightmare");
        add(dialog);
        dialog.cameras = [cameraHUD];

        dialog.dialogueText.letterCallback = (code) ->
        {
            if (dialog.dialogueIndex == 3 || dialog.dialogueIndex == 4 || dialog.dialogueIndex == 7) return;
            if (FunkBucks.skipTalking.contains(code)) return;
            FunkinSound.playOnce(Paths.sound("chartingSounds/keyboard" + FlxG.random.int(1, 3)), 1.0);
            shopkeeper.playAnimation('Talk', false, false);
        }

        dialog.onNextLine.add((dialogueIndex, dialogueText) ->
        {
            switch (dialogueIndex)
            {
                case 1: shopkeeper.suffix = "Confused";
                case 3: FlxG.sound.music.stop(); shopkeeper.suffix = ""; shopkeeper.playAnimation("Idle", true, true);
                case 5: shopkeeper.suffix = "Confused";
                case 8: shopkeeper.suffix = "Annoyed";
            }
        });

        dialog.onCompleteDialogue.add(() ->
        {
            shopkeeper.suffix = "";
            shopkeeper.playAnimation("LookAtShelf");
            FlxTween.tween(cameraFollowPoint, { x: cameraFollowPoint.x + 200 }, 0.5, { ease: FlxEase.cubeOut });

            // new FlxTimer().start(3.0, function(_:FlxTimer) {
                // remove(dailyBoard);
            // });

            // new FlxTimer().start(4.0, function(_:FlxTimer) {
                // rewardShelf.removeItems();
            // });

            // new FlxTimer().start(9.5, function(_:FlxTimer) {
                // remove(rewardShelf);
            // });

            new FlxTimer().start(10.0, function(_:FlxTimer) {
                var t2:Tuntematon = new Tuntematon(FlxG.width - 110, 320);
                t2.animation.play("grab", true, true);
                t2.scrollFactor.set();
                t2.cameras = [cameraHUD];
                t2.scale.set(1.5, 1.5);
                add(t2);

                var staticSound:FunkinSound = FunkinSound.load(Paths.sound("static loop"), 0, true, false, true, false);
                staticSound.volume = 0.0;
                staticSound.fadeOut(6.0, 0.1);

                var t3:FunkinSprite = new FunkinSprite(2000 - spriteNudge, 230).loadTexture("shop/t");
                t3.zIndex = 390;
                add(t3);
                refresh();

                FlxTween.tween(lighting, { alpha: 1.0 }, 5.4, { ease: FlxEase.cubeIn });
                FlxTween.tween(t3, { x: shopkeeper.x + shopkeeper.width / 2 + 100 }, 0.50, { startDelay: 5.0, ease: FlxEase.expoIn, onComplete: function() {
                    // FunkBucks.setObtainedPin("tuntematon");
                    Shopkeeper.caught = true;
                    screenBlack.alpha = 1.0;
                    t2.alpha = 0.0;
                    FlxTransitionableState.skipNextTransIn = true;
                    FlxG.switchState(() -> new MainMenuState());
                }});
            });
        });
        
        showMenuItems(false);
        cameraFollowPoint.setPosition(shopkeeperHitbox.x + shopkeeperHitbox.width / 2, shopkeeperHitbox.y + 115);
        FlxTween.tween(camera, { zoom: 1.5 }, 1, { ease: FlxEase.cubeOut });
        FlxTween.tween(funkBucksText, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
        FlxTween.tween(blueJewelsText, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
        coolBackButton.visible = false;
    }

    function cloverCoinButtonIntro():Void
    {
        if (dialog != null) remove(dialog);
        dialog = new Dialogue('cloverButton');
        add(dialog);
        dialog.cameras = [cameraHUD];

        dialog.dialogueText.letterCallback = (code) ->
        {
            if (FunkBucks.skipTalking.contains(code)) return;
            FunkinSound.playOnce(Paths.sound("chartingSounds/keyboard" + FlxG.random.int(1, 3)), 1.0);
            shopkeeper.playAnimation('Talk', false, false);
        }

        dialog.onNextLine.add((dialogueIndex, dialogueText) ->
        {
            switch (dialogueIndex)
            {
                case 2:
                    shopkeeper.suffix = "Confused";
                    cameraFollowPoint.setPosition(2300 - spriteNudge, -200);
                    FlxTween.tween(camera, { zoom: 2 }, 1, { ease: FlxEase.cubeOut, onComplete: function() {
                        dialog.startFromDelay();
                    }});
                case 4:
                    cameraFollowPoint.setPosition(shopkeeperHitbox.x + shopkeeperHitbox.width / 2, shopkeeperHitbox.y + 100);
                    FlxTween.tween(camera, { zoom: 1.35 }, 1, { ease: FlxEase.cubeOut, onComplete: function() {
                        dialog.startFromDelay();
                    }});
                case 5: shopkeeper.suffix = "Annoyed";
                case 6: shopkeeper.suffix = "";
            }
        });

        dialog.onCompleteDialogue.add(() ->
        {
            shopkeeper.suffix = "";
            disallowInputs = false;
            showMenuItems(true);
            FlxTween.tween(camera, { zoom: savedCamZoom }, 1, { ease: FlxEase.cubeOut });
            FlxTween.tween(funkBucksText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
            FlxTween.tween(blueJewelsText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
            // FunkBucks.setEvent("cloverCoinButton", 1);
        });
        
        disallowInputs = true;
        showMenuItems(false);
        cameraFollowPoint.setPosition(shopkeeperHitbox.x + shopkeeperHitbox.width / 2, shopkeeperHitbox.y + 100);
        savedCamZoom = camera.zoom;
        FlxTween.tween(camera, { zoom: 1.35 }, 1, { ease: FlxEase.cubeOut });
        FlxTween.tween(funkBucksText, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
        FlxTween.tween(blueJewelsText, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
        coolBackButton.visible = false;
    }

    var previousFunkBucks:Int;
    var passingThroughCost:Int = 0;
    public function deductFunkBucks(amount:Int):Void
    {
        var currentFunkBucks:Int = previousFunkBucks = FunkBucks.getFunkCoins();
        var remainingFunkBucks:Int = currentFunkBucks - amount;
        passingThroughCost = amount;

        buckSound.pitch = 1.0;
        var easeToUse:FlxEase = amount >= 500 ? FlxEase.circOut : FlxEase.quartOut;
        FlxTween.num(currentFunkBucks, remainingFunkBucks, 2.5, { ease: easeToUse, onComplete: function(_) {
            funkBucksText.text = '<b>${Math.floor(remainingFunkBucks)}</b> ${FBIcon.Buck}';
        }}, updateFunkBucks);

        FunkBucks.addFunkCoins(-amount, false);
    }

    public function addFunkBucks(amount:Int):Void
    {
        var currentFunkBucks:Int = FunkBucks.getFunkCoins() + amount;

        funkBucksText.text = '<b>$currentFunkBucks</b> ${FBIcon.Buck}';
        funkBucksText.y -= 20;
        FunkinSound.playOnce(Paths.sound("fav"), 0.35);

        funkBucksText.forEach((letter) -> {
            FlxTween.color(letter, 0.5, 0xFF00FF00, 0xFFFFFFFF);
        });

        FunkBucks.addFunkCoins(amount, false);
    }

    public function deductBlueJewel(amount:Int):Void
    {
        var currentJewels:Int = FunkBucks.getBlueJewels();
        var remainingJewels:Int = currentJewels - amount;

        blueJewelsText.text = '<b><c=82E9FF>$remainingJewels</c></b> ${FBIcon.Jewel}';
        blueJewelsText.y += 20;
        FunkinSound.playOnce(Paths.sound("bluejewel"));

        FunkBucks.addBlueJewels(-amount, false);
    }

    public function addBlueJewel(amount:Int):Void
    {
        var currentJewels:Int = FunkBucks.getBlueJewels() + amount;

        blueJewelsText.text = '<b><c=82E9FF>$currentJewels</c></b> ${FBIcon.Jewel}';
        blueJewelsText.y -= 20;
        FunkinSound.playOnce(Paths.sound("bluejewel"));

        blueJewelsText.forEach((letter) -> {
            FlxTween.color(letter, 0.5, 0xFF00FF00, letter.curLetter.colored ? 0xFFFFFFFF : 0xFF82E9FF);
        });

        FunkBucks.addBlueJewels(amount, false);
    }

    final soundThresholds:Array<Int> = [100, 500, 1000, 2500];
    function updateFunkBucks(value:Float):Void
    {
        if (previousFunkBucks != Math.floor(value))
        {
            var mod:Int = 0;
            for (index => value in soundThresholds)
            {
                if (passingThroughCost >= value)
                {
                    mod = index + 1;
                }
            }
            funkBucksText.text = '<b>${Math.floor(value)}</b> ${FBIcon.Buck}';
            funkBucksText.y += 5;
            if (Math.abs(Math.floor(value) % (mod + 1)) == 0) FunkinSound.playOnce(Paths.sound("fav"), 0.35);
        }
        previousFunkBucks = Math.floor(value);
    }

    function insufficientFunkBucks():Void
    {
        funkBucksText.y += 20;
        funkBucksText.forEach((letter) -> {
            FlxTween.color(letter, 0.5, 0xFFFF0000, 0xFFFFFFFF);
        });
        FunkinSound.playOnce(Paths.sound("CS_locked"), 0.5);
    }

    function insufficientBlueJewels():Void
    {
        blueJewelsText.y += 20;
        blueJewelsText.forEach((letter) -> {
            FlxTween.color(letter, 0.5, 0xFFFF0000, letter.curLetter.colored ? 0xFFFFFFFF : 0xFF82E9FF);
        });
        FunkinSound.playOnce(Paths.sound("CS_locked"), 0.5);
    }

    function unlockPinsInQueue():Void
    {
        disallowInputs = true;
        var nextPin:String = FunkBucks.pinUnlockQueue.shift();
        if (nextPin != null)
        {
            trace("Unlocking pin: " + nextPin);
            var substate = new PinUnlockState(FunkBucks.getPinByID(nextPin));
            substate.cameras = [cameraSubState];
            openSubState(substate);
        }
        else
        {
            disallowInputs = false;
            checkForEvents();
        }
    }

    function checkForEvents():Void
    {
        if (FunkBucks.getUnlockedPinsCount() >= 30 /*&& FunkBucks.getEvent("cloverCoinButton") == 0*/)
        {
            cloverEventButton.visible = true;
            // cloverCoinButtonIntro();
        }
    }

    override function onFocus():Void
    {
        justGainedFocus = true;
        super.onFocus();
    }

    override function openSubState(state):Void
    {
        cameraSubState.scroll.set(0, 0);
        cameraSubState.follow(null);
        // Necessary, otherwise you can move the camera during transitions, which sets this to false?????
        disallowInputs = true;
        subToSub = false;

        super.openSubState(state);
    }

    override function closeSubState():Void
    {
        new FlxTimer().start(0.1, function(_:FlxTimer)
        {
            disallowInputs = false;
            if (!subToSub)
            {
                unlockPinsInQueue();
            }
        });
        super.closeSubState();
    }

    override function destroy():Void
    {
        #if !mobile
        FlxMouseEvent.remove(coolBackButton);
        #end
        if (dialog != null) remove(dialog);
        camera.bgColor = 0xFF000000;
        super.destroy();
    }

    function constructOldShop():Void
    {
        final offsetDueToScrollFactor:Float = 7500;
        final offsetDueToScrollFactor2:Float = 5000;

        var old_wall:FunkinSprite = new FunkinSprite(49300 - offsetDueToScrollFactor, -220).loadTexture("shop/old/wall");
        old_wall.zIndex = -1000;
        old_wall.scrollFactor.set(0.85, 0.85);
        add(old_wall);

        var old_dailyboard:FunkinSprite = new FunkinSprite(50300 - offsetDueToScrollFactor, 0).loadTexture("shop/old/dailyboard");
        old_dailyboard.zIndex = -998;
        old_dailyboard.scrollFactor.set(0.85, 0.85);
        add(old_dailyboard);

        var old_counter:FunkinSprite = new FunkinSprite(49550, 510).loadTexture("shop/old/counter");
        old_counter.zIndex = 500;
        old_counter.scrollFactor.set(1, 1);
        old_counter.scale.set(1.5, 1.0);
        add(old_counter);

        var old_fbStack1:FunkinSprite = new FunkinSprite(51100, 446).loadTexture("shop/old/funkbuckstack");
        old_fbStack1.zIndex = 490;
        add(old_fbStack1);

        var old_fbStack2:FunkinSprite = new FunkinSprite(52050, 446).loadTexture("shop/old/funkbuckstack");
        old_fbStack2.zIndex = 490;
        old_fbStack2.flipX = true;
        add(old_fbStack2);

        var old_fbStack3:FunkinSprite = new FunkinSprite(49500, 446).loadTexture("shop/old/funkbuckstack");
        old_fbStack3.zIndex = 490;
        add(old_fbStack3);

        var old_randomBox1:FunkinSprite = new FunkinSprite(51600 + offsetDueToScrollFactor2, 700).loadTexture("shop/old/randombox01");
        old_randomBox1.zIndex = 1100;
        old_randomBox1.scrollFactor.set(1.1, 1.0);
        add(old_randomBox1);

        var old_randomBox2:FunkinSprite = new FunkinSprite(49700 + offsetDueToScrollFactor2, 740).loadTexture("shop/old/randombox01");
        old_randomBox2.zIndex = 1100;
        old_randomBox2.scrollFactor.set(1.1, 1.0);
        add(old_randomBox2);

        var old_randomBox3:FunkinSprite = new FunkinSprite(52070, 350).loadTexture("shop/old/randombox01");
        old_randomBox3.zIndex = 480;
        add(old_randomBox3);

        var old_iconPins:FunkinSprite = new FunkinSprite(49900, 350).loadTexture("shop/iconpins");
        old_iconPins.zIndex = 490;
        add(old_iconPins);

        var old_iconBoxes:FunkinSprite = new FunkinSprite(50440, 376).loadTexture("shop/iconboxes");
        old_iconBoxes.zIndex = 490;
        add(old_iconBoxes);
    }
}