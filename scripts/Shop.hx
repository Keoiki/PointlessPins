package funkbucks;

import Date;
import balphabet.BAlphabet;
import flixel.FlxObject;
import flixel.effects.particles.FlxEmitter;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkbucks.dialog.shop.april.AprilIntro;
import funkbucks.dialog.shop.april.ConverseApril;
import funkbucks.dialog.shop.ophelia.ConverseOphelia;
import funkbucks.objects.KeyCap;
import funkbucks.objects.Dialogue;
import funkbucks.objects.shop.Clock;
import funkbucks.objects.shop.DailyBoard;
import funkbucks.objects.shop.StatsSheet;
import pointlesspins.objects.shop.secret.Tuntematon;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinCamera;
import funkin.graphics.FunkinSprite;
import funkin.mobile.ui.FunkinBackButton;
import funkin.modding.ModStore;
import funkin.ui.MusicBeatState;
import funkin.ui.mainmenu.MainMenuState;
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

    // Dialogue
    public var dialog:Dialogue;

    // Shop
    var shopkeeperHitbox:FlxObject;
    public var shopkeeper:Shopkeeper;

    public var wall:FunkinSprite;
    public var lighting:FunkinSprite;
    public var counter:FunkinSprite;

    public var clock:Clock;
    public var dailyBoard:DailyBoard;
    // public var cloverEventButton:FunkinSprite;

    public var elevator:FunkinSprite;

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

    public var iconStats:FunkinSprite;
    var lableStats:BAlphabet;
    var keycapStats:KeyCap;
    var rewardsSparkles:FlxEmitter;
    var viewingStats:Bool = false;
    var statsSheet:StatsSheet;

    // UI
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

        if (FlxG.random.bool(0.05)) FunkBucks.pushPinToUnlockQueue("shockedcat");
        if (FunkBucks.getFunkCoinsLifetime() >= 25000) FunkBucks.pushPinToUnlockQueue("funkbuck");
        if (FunkBucks.getBlueJewelsLifetime() >= 5) FunkBucks.pushPinToUnlockQueue("melodystone");
        if (FunkBucks.getOpenedBoxCount("cardboard") >= 100) FunkBucks.pushPinToUnlockQueue("cardboardbox");
        if (FunkBucks.getOpenedBoxCount("smallgiftbox") >= 75) FunkBucks.pushPinToUnlockQueue("smallgiftbox");
        if (FunkBucks.getOpenedBoxCount("fancycoffret") >= 50) FunkBucks.pushPinToUnlockQueue("fancycoffret");
        if (FunkBucks.getOpenedBoxCount("glimmeringpouch") >= 40) FunkBucks.pushPinToUnlockQueue("glimmeringpouch");

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

        if (FlxG.random.bool(1))
        {
             isShopkeeperGone = true;
             if (FlxG.random.bool(50))
             {
                 extendBounds = true;
             }
        }

        if (!isShopkeeperGone) FunkBucks.moneyHUD.setDisplay(true, true);

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

        // Shop

        wall = new FunkinSprite(-950 - spriteNudge, -400).loadTexture("shop/wall");
        wall.zIndex = -1000;
        wall.scrollFactor.set(0.85, 0.85);
        add(wall);

        dailyBoard = new DailyBoard(615 - spriteNudge, 0);
        dailyBoard.zIndex = -998;
        add(dailyBoard);

        clock = new Clock(1168 - spriteNudge, -200);
        clock.zIndex = -993;
        add(clock);

        // cloverEventButton = new FunkinSprite(2055 - spriteNudge, -250).makeSolidColor(150, 150, 0xFF00FF00);
        // cloverEventButton.scrollFactor.set(0.85, 0.85);
        // cloverEventButton.zIndex = -990;
        // cloverEventButton.visible = FunkBucks.getUnlockedPinsCount() >= 30;
        // add(cloverEventButton);

        // lighting = new FunkinSprite(-800, -440).makeSolidColor(3000, 1600, 0xFF3C1B41);
        lighting = new FunkinSprite(-800, -440).makeSolidColor(3000, 1600, 0xFFFFC38B);
        lighting.zIndex = 10000;
        lighting.scrollFactor.set(0, 0);
        lighting.blend = 14;
        lighting.alpha = isShopkeeperGone ? 0.35 : 0;
        add(lighting);

        shopkeeper = new Shopkeeper(1045 - spriteNudge, 150, skName);
        shopkeeper.zIndex = 400;
        shopkeeper.scrollFactor.set(0.98, 1);
        shopkeeper.visible = !isShopkeeperGone;
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
            // Somehow this has to be the other way around, a chance for the lamp to be on, not off. fuck everything man
            if (FlxG.random.bool(95) && !isShopkeeperGone) lamp.animation.play("on");
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

        lableConverse = new BAlphabet(1200 - spriteNudge, 520, "<b>Converse</b>");
        lableConverse.scale.set(0.65, 0.65);
        lableConverse.alignment = "center";
        lableConverse.zIndex = 516;
        add(lableConverse);

        iconStats = new FunkinSprite(1775 - spriteNudge, 279).loadTexture("shop/iconstats");
        iconStats.zIndex = 493;
        add(iconStats);

        lableStats = new BAlphabet(1850 - spriteNudge, 520, "<b>Stats</b>");
        lableStats.alignment = "center";
        lableStats.scale.set(0.65, 0.65);
        lableStats.zIndex = 514;
        add(lableStats);

        // rewardsSparkles = new FlxEmitter(1740 - spriteNudge, 330);
        // rewardsSparkles.setSize(150, 150);
        // rewardsSparkles.loadParticles(Paths.image("pinsparkle"), 30, 0);
        // rewardsSparkles.acceleration.set(1, 1, -1, -3, 5, 5, -5, -10);
        // rewardsSparkles.scale.set(0.1, null, 0.3, null, 0.0, null, 0.1, null);
        // rewardsSparkles.keepScaleRatio = true;
        // rewardsSparkles.color.set(0xFFFFFFFF, 0xFFFFFF00);
        // rewardsSparkles.speed.set(0, -1, 0, 0);
        // rewardsSparkles.alpha.set(0.3, 0.9, 0.0, 0.0);
        // rewardsSparkles.angle.set(-180, 180, -180, 180);
        // rewardsSparkles.ignoreAngularVelocity = true;
        // rewardsSparkles.lifespan.set(3, 7);
        // rewardsSparkles.blend = 0;
        // rewardsSparkles.zIndex = 502;
        // add(rewardsSparkles);
        // rewardsSparkles.focusOn(iconStats);
        // rewardsSparkles.start(false, 0.25);

        counterItems.push(iconPins);
        counterItems.push(iconBoxes);
        counterItems.push(iconStats);
        counterItems.push(lablePins);
        counterItems.push(lableBoxes);
        counterItems.push(lableConverse);
        counterItems.push(lableStats);

        elevator = new FunkinSprite(-2800 - spriteNudge, -50).loadTexture("shop/elevator");
        elevator.scrollFactor.set(0.85, 1.0);
        elevator.zIndex = 500;
        add(elevator);

        #if !mobile
        keycapPins = new KeyCap(lablePins.x - 33, 570, "1", null, false);
        keycapPins.zIndex = 512;
        add(keycapPins);

        keycapBoxes = new KeyCap(lableBoxes.x - 33, 570, "2", null, false);
        keycapBoxes.zIndex = 514;
        add(keycapBoxes);

        keycapConverse = new KeyCap(lableConverse.x - 33, 570, "3", null, false);
        keycapConverse.zIndex = 518;
        add(keycapConverse);

        keycapStats = new KeyCap(lableStats.x - 33, 570, "4", null, false);
        keycapStats.zIndex = 520;
        add(keycapStats);

        counterItems.push(keycapPins);
        counterItems.push(keycapBoxes);
        counterItems.push(keycapConverse);
        counterItems.push(keycapStats);
        #end
        
        // UI

        screenBlack = new FunkinSprite(-2, -2).makeSolidColor(FlxG.width + 4, FlxG.height + 4, 0xFF000000);
        screenBlack.alpha = 0.0;
        screenBlack.scrollFactor.set(0, 0);
        screenBlack.cameras = [cameraHUD];
        add(screenBlack);

        cannotDoText = new BAlphabet(FlxG.width / 2, FlxG.height - 100, "<b><c=FF0000>You cannot do that right now.</c></b>");
        cannotDoText.alignment = "center";
        cannotDoText.scale.set(0.5, 0.5);
        cannotDoText.alpha = 0.0001;
        cannotDoText.cameras = [cameraHUD];
        add(cannotDoText);

        coolBackButton = new FunkinBackButton(FlxG.width - 220, FlxG.height - 200, 0xFFFFFFFF, goBack, 0.5);
        #if !mobile
        coolBackButton.visible = FunkBucks.isMouseActive;
        FlxMouseEvent.add(coolBackButton, coolBackButton.playHoldAnim, coolBackButton.playConfirmAnim);
        #end
        coolBackButton.cameras = [cameraHUD];
        add(coolBackButton);

        statsSheet = new StatsSheet(FlxG.width / 2 - 370, 1000);
        statsSheet.cameras = [cameraHUD];
        add(statsSheet);

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

        final leftXLimit:Float = 100; // 3000
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

    var forceBackButtonInactive:Bool = false;

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        var lerpval:Float = FlxMath.bound(elapsed * 9.6, 0, 1);

        if (cameraFollowPointMarker != null)
        {
            cameraFollowPointMarker.x = cameraFollowPoint.x - 2;
            cameraFollowPointMarker.y = cameraFollowPoint.y - 2;
        }

        if (extendBounds)
        {
            if (cameraFollowPoint.x >= 10000)
            {
                final targetUIAlpha:Float = 1.0 - (1.0 * (cameraFollowPoint.x - 10000) / 20000);
                FunkBucks.moneyHUD.alpha = targetUIAlpha;
                final targetDarkness:Float = 0.35 + Math.min(0.35, (0.35 * (cameraFollowPoint.x - 10000) / 20000));
                lighting.alpha = targetDarkness;
                camera.minScrollY = wall.y + 360;
                forceBackButtonInactive = true;
            }
            else
            {
                camera.minScrollY = wall.y;
                forceBackButtonInactive = false;
                FunkBucks.moneyHUD.alpha = 1.0;
            }
        }

        if (controls.BACK_P)
        {
            goBack();
        }

        if (disallowInputs && !viewingStats)
        {
            coolBackButton.enabled = false;
            coolBackButton.visible = false;
            return;
        }

        if (forceBackButtonInactive)
        {
            coolBackButton.enabled = false;
            coolBackButton.visible = false;
        }
        else
        {
            coolBackButton.visible = #if mobile true; #else FunkBucks.isMouseActive; #end
            coolBackButton.enabled = true;
        }

        if (viewingStats)
        {
            coolBackButton.instant = true;
            return;
        }
        else
        {
            coolBackButton.instant = false;
        }

        handleCameraMovement();
        justGainedFocus = false;

        // Pins

        if (FlxG.keys.justPressed.ONE || (TouchUtil.pressAction(iconPins) && !FunkBucks.isMouseTooFast && !TouchUtil.overlaps(coolBackButton, cameraHUD)))
        {
            if (TimedCoinsManager.running || (extendBounds && cameraFollowPoint.x >= 10000))
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
                FunkBucks.moneyHUD.setDisplay(true, true);
                FlxTween.tween(screenBlack, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
            };
            substate.cameras = [cameraSubState];

            FlxTween.tween(coolBackButton, { alpha: 0 }, 1, { ease: FlxEase.cubeIn });
            FlxTween.tween(camera, { zoom: 1.5 }, 1, { ease: FlxEase.cubeIn });
            FunkBucks.moneyHUD.setDisplay(false, false, 0);
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
                FunkBucks.moneyHUD.setDisplay(true, true);
                FlxTween.tween(screenBlack, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
                showMenuItems();
            }
            substate.cameras = [cameraSubState];

            FlxTween.tween(coolBackButton, { alpha: 0 }, 1, { ease: FlxEase.cubeIn });
            FlxTween.tween(screenBlack, { alpha: 0.5 }, 1, { ease: FlxEase.cubeIn });
            FunkBucks.moneyHUD.setDisplay(true, false, 0);
            FlxTween.tween(camera, { zoom: 0.9 }, 1, { ease: FlxEase.cubeOut, onComplete: function()
            {
                openSubState(substate);
            }});
        }

        // Converse

        if (FlxG.keys.justPressed.THREE || (TouchUtil.pressAction(shopkeeperHitbox) && !FunkBucks.isMouseTooFast && !TouchUtil.overlaps(coolBackButton, cameraHUD)))
        {
            if (isShopkeeperGone || Shopkeeper.caught || TimedCoinsManager.running || !shopkeeper.canInterract)
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
                        new ConverseApril();
                        // new AprilIntro();
                    default:
                        return;
                }
            });

            disallowInputs = true;
            showMenuItems(false);
            cameraFollowPoint.setPosition(shopkeeperHitbox.x + shopkeeperHitbox.width / 2, shopkeeperHitbox.y + 115);
            savedCamZoom = camera.zoom;
            FlxTween.tween(camera, { zoom: 1.5 }, 1, { ease: FlxEase.cubeOut });
            FunkBucks.moneyHUD.setDisplay(false, false, 0);
            coolBackButton.visible = false;
        }

        // Stats

        if (FlxG.keys.justPressed.FOUR || (TouchUtil.pressAction(iconStats) && !FunkBucks.isMouseTooFast && !TouchUtil.overlaps(coolBackButton, cameraHUD)))
        {
            if (Shopkeeper.caught || TimedCoinsManager.running || (extendBounds && cameraFollowPoint.x >= 10000))
            {
                FlxTween.completeTweensOf(cannotDoText);
                FlxTween.tween(cannotDoText, { alpha: 1 }, 2, { ease: FlxEase.cubeOut, type: 16 });
                return;
            }

            viewingStats = true;
            disallowInputs = true;

            FlxTween.tween(statsSheet, { y: 200 }, 1, { ease: FlxEase.cubeOut });
        }

        // Elevator

        if (TouchUtil.pressAction(elevator) && !FunkBucks.isMouseTooFast && !TouchUtil.overlaps(coolBackButton, cameraHUD))
        {
            if (isShopkeeperGone || Shopkeeper.caught || TimedCoinsManager.running)
            {
                FlxTween.completeTweensOf(cannotDoText);
                FlxTween.tween(cannotDoText, { alpha: 1 }, 2, { ease: FlxEase.cubeOut, type: 16 });
                return;
            }

            disallowInputs = true;
            var substate = new ElevatorMenu();
            substate.closeCallback = function()
            {
                FlxTween.tween(coolBackButton, { alpha: 0.5 }, 1, { ease: FlxEase.cubeOut });
            }
            substate.cameras = [cameraSubState];
            openSubState(substate);

            FlxTween.tween(coolBackButton, { alpha: 0 }, 1, { ease: FlxEase.cubeIn });
        }
    }

    function goBack():Void
    {
        if (viewingStats)
        {
            FlxTween.tween(statsSheet, { y: 1000 }, 1, { ease: FlxEase.cubeIn });
            viewingStats = false;
            disallowInputs = false;
            return;
        }
        if (disallowInputs) return;
        FlxG.switchState(() -> new MainMenuState());
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
            camera.zoom = camera.zoom + 0.1 * FlxG.mouse.wheel;
        }

        if (controls.RESET) camera.zoom = 1;
        if (controls.FREEPLAY_LEFT) camera.zoom -= 0.1;
        if (controls.FREEPLAY_RIGHT) camera.zoom += 0.1;

        if (FlxG.mouse.wheel != 0 || controls.RESET || controls.FREEPLAY_LEFT || controls.FREEPLAY_RIGHT)
        {
            FlxTween.cancelTweensOf(camera);
        }

        camera.zoom = FlxMath.bound(camera.zoom, 0.7, 2);

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

    function unlockPinsInQueue():Void
    {
        disallowInputs = true;
        var nextPin:String = FunkBucks.pinUnlockQueue.shift();
        if (nextPin != null)
        {
            trace("Unlocking next pin in queue: " + nextPin);
            var substate = new PinUnlockState(nextPin);
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
        // if (FunkBucks.getUnlockedPinsCount() >= 50 && FunkBucks.getEvent("cloverCoinButton") == 0)
        // {
            // cloverEventButton.visible = true;
        // }
    }

    override function onFocus():Void
    {
        justGainedFocus = true;
        super.onFocus();
    }

    override function openSubState(state:FlxSubState):Void
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
        final offsetDueToScrollFactor:Float = -7500;
        final offsetDueToScrollFactor2:Float = 5000;

        var old_wall:FunkinSprite = new FunkinSprite(49300 + offsetDueToScrollFactor, -220).loadTexture("shop/old/wall");
        old_wall.zIndex = -1000;
        old_wall.scrollFactor.set(0.85, 0.85);
        add(old_wall);

        var old_dailyboard:FunkinSprite = new FunkinSprite(50300 + offsetDueToScrollFactor, 0).loadTexture("shop/old/dailyboard");
        old_dailyboard.zIndex = -998;
        old_dailyboard.scrollFactor.set(0.85, 0.85);
        add(old_dailyboard);

        var old_counter:FunkinSprite = new FunkinSprite(49550, 510).loadTexture("shop/old/counter");
        old_counter.zIndex = 500;
        old_counter.scrollFactor.set(1, 1);
        old_counter.scale.set(1.5, 1.0);
        add(old_counter);

        var old_fbStack1:FunkinSprite = new FunkinSprite(50700, 446).loadTexture("shop/old/funkbuckstack");
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