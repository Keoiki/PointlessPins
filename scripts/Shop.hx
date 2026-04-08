package funkbucks;

import Date;
import balphabet.BAlphabet;
import balphabet.BAlphabetTyped;
import flixel.FlxObject;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkbucks.objects.KeyCap;
import funkbucks.objects.PinDialogue;
import funkbucks.objects.shop.Clock;
import funkbucks.objects.shop.DailyBoard;
import funkbucks.objects.shop.RewardShelf;
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
    var cameraHUD:FunkinCamera;
    var cameraSubState:FunkinCamera;
    var spriteNudge:Float = (1600 - FlxG.width) / 2;
    var disallowInputs:Bool = false;
    var cameraFollowPoint:FlxObject;
    var justGainedFocus:Bool = false;

    var isOpheliaGone:Bool = false;
    var cannotDoText:BAlphabet;

    var buckSound:FunkinSound;

    // Dialogue
    var dialog:PinDialogue;

    // Shop
    var opheliaHitbox:FlxObject;
    var ophelia:Ophelia;

    var wall:FunkinSprite;
    var lighting:FunkinSprite;

    var clock:Clock;
    var dailyBoard:DailyBoard;
    var rewardShelf:RewardShelf;

    var television:FunkinSprite;
    var dailiesText:BAlphabet;

    var counterItems = [];

    var iconPins:FunkinSprite;
    var lablePins:BAlphabet;
    var keycapPins:KeyCap;

    var iconBoxes:FunkinSprite;
    var lableBoxes:BAlphabet;
    var keycapBoxes:KeyCap;

    var iconRewards:FunkinSprite;
    var lableRewards:BAlphabet;
    var keycapRewards:KeyCap;

    var iconExchange:FunkinSprite;
    var lableExchange:BAlphabet;
    var keycapExchange:KeyCap;

    // UI
    var funkBucksText:BAlphabet;
    var blueJewelsText:BAlphabet;
    var screenBlack:FunkinSprite;
    
    var updateText:BAlphabet;

    var coolBackButton:FunkinBackButton;

    override function new():Void
    {
        super();
    }

    override public function create():Void
    {
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

        if (FlxG.random.bool(1))
        {
            // she forgor to show up
            isOpheliaGone = true;
        }

        if (isOpheliaGone)
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

        lighting = new FunkinSprite(-800, -440).makeSolidColor(3000, 1600, 0xFF3C1B41);
        lighting.zIndex = 5000;
        lighting.scrollFactor.set(0, 0);
        lighting.blend = 9;
        lighting.alpha = isOpheliaGone ? 0.85 : 0;
        add(lighting);

        ophelia = new Ophelia(1170 - spriteNudge, 150);
        ophelia.zIndex = 400;
        ophelia.scrollFactor.set(0.98, 1);
        add(ophelia);

        opheliaHitbox = new FlxObject(ophelia.x + 20, ophelia.y + 20, 280, 320);
        ophelia.scrollFactor.set(0.98, 1);
        add(opheliaHitbox);

        counter = new FunkinSprite(-950 - spriteNudge, 490).loadTexture("shop/counter");
        counter.zIndex = 500;
        counter.scrollFactor.set(1, 1);
        add(counter);

        var fbStack10:FunkinSprite = new FunkinSprite(1120 - spriteNudge, 444).loadTexture("shop/rewards/funkbuck01");
        fbStack10.zIndex = 490;
        add(fbStack10);

        var fbStack11:FunkinSprite = new FunkinSprite(-100 - spriteNudge, 444).loadTexture("shop/rewards/funkbuck01");
        fbStack11.zIndex = 490;
        add(fbStack11);

        var fbStack20:FunkinSprite = new FunkinSprite(2050 - spriteNudge, 424).loadTexture("shop/rewards/funkbuck02");
        fbStack20.zIndex = 491;
        add(fbStack20);

        var fbStack21:FunkinSprite = new FunkinSprite(1420 - spriteNudge, 424).loadTexture("shop/rewards/funkbuck02");
        fbStack21.zIndex = 491;
        add(fbStack21);

        var fbStack30:FunkinSprite = new FunkinSprite(-700 - spriteNudge, 384).loadTexture("shop/rewards/funkbuck03");
        fbStack30.zIndex = 492;
        add(fbStack30);

        counterItems.push(fbStack10);
        counterItems.push(fbStack11);
        counterItems.push(fbStack20);
        counterItems.push(fbStack21);
        counterItems.push(fbStack30);

        for (i in 0...3)
        {
            var lamp:FunkinSprite = new FunkinSprite(-400 + (i * 1020) - spriteNudge, -460, "shop/lamp");
            lamp.zIndex = 1000;
            lamp.scrollFactor.set(1.1, 1.0);
            add(lamp);
            lamp.scale.set(0.8, 0.8);
            lamp.anim.play(isOpheliaGone ? "off" : "on");
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

        // lableExchange = new BAlphabet(1200 - spriteNudge, 520, "<b>Exchange\n<s=-0.45>ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz.,-=?!*^+</s></b>");
        lableExchange = new BAlphabet(1100 - spriteNudge, 520, "<b>Exchange</b>");
        lableExchange.scale.set(0.65, 0.65);
        lableExchange.alignment = "center";
        lableExchange.zIndex = 516;
        add(lableExchange);

        // var box:FunkinSprite = new FunkinSprite(lableExchange.x - 200, lableExchange.y).makeSolidColor(400, 60 * lableExchange.scale.y, 0x7B00FF00);
        // box.zIndex = 520;
        // add(box);

        // var box:FunkinSprite = new FunkinSprite(lableExchange.x - 200, lableExchange.y + 85 * lableExchange.scale.y).makeSolidColor(400, 60 * lableExchange.scale.y, 0x7B00FF00);
        // box.zIndex = 520;
        // add(box);

        // var box:FunkinSprite = new FunkinSprite(lableExchange.x - 200, lableExchange.y + 85 * 2 * lableExchange.scale.y).makeSolidColor(400, 60 * lableExchange.scale.y, 0x7B00FF00);
        // box.zIndex = 520;
        // add(box);

        lableRewards = new BAlphabet(1850 - spriteNudge, 520, "<b>Rewards</b>");
        lableRewards.alignment = "center";
        lableRewards.scale.set(0.65, 0.65);
        lableRewards.zIndex = 514;
        add(lableRewards);

        counterItems.push(iconPins);
        counterItems.push(iconBoxes);
        // counterItems.push(iconRewards);
        // counterItems.push(iconExchange);
        counterItems.push(lablePins);
        counterItems.push(lableBoxes);
        counterItems.push(lableRewards);
        counterItems.push(lableExchange);

        #if !mobile
        keycapPins = new KeyCap(lablePins.x - 45, 570, "1", false);
        keycapPins.zIndex = 512;
        add(keycapPins);

        keycapBoxes = new KeyCap(lableBoxes.x - 45, 570, "2", false);
        keycapBoxes.zIndex = 514;
        add(keycapBoxes);

        keycapExchange = new KeyCap(lableExchange.x - 45, 570, "3", false);
        keycapExchange.zIndex = 518;
        add(keycapExchange);

        keycapRewards = new KeyCap(lableRewards.x - 45, 570, "4", false);
        keycapRewards.zIndex = 520;
        add(keycapRewards);

        counterItems.push(keycapPins);
        counterItems.push(keycapBoxes);
        counterItems.push(keycapRewards);
        counterItems.push(keycapExchange);
        #end
        
        // UI

        screenBlack = new FunkinSprite(-2, -2).makeSolidColor(FlxG.width + 4, FlxG.height + 4, 0xFF000000);
        screenBlack.alpha = 0.0;
        screenBlack.scrollFactor.set(0, 0);
        add(screenBlack);

        funkBucksText = new BAlphabet(FlxG.width - 20, 25, '<b>${PointlessPins.getFunkCoins()}</b> ${PTIcon.Buck}');
        funkBucksText.scale.set(0.65, 0.65);
        funkBucksText.alignment = "right";
        // funkBucksText.setScrollFactor(0, 0);
        add(funkBucksText);

        blueJewelsText = new BAlphabet(FlxG.width - 20, funkBucksText.y + 70, '<b><c=82E9FF>${PointlessPins.getBlueJewels()}<s=0.5>/${PointlessPins.maximumBlueJewels}</s></c></b> ${PTIcon.Jewel}');
        blueJewelsText.alignment = "right";
        blueJewelsText.scale.set(0.65, 0.65);
        // blueJewelsText.setScrollFactor(0, 0);
        add(blueJewelsText);

        cannotDoText = new BAlphabet(FlxG.width / 2, FlxG.height - 100, "<b><c=FF0000>You cannot do that right now.</c></b>");
        cannotDoText.alignment = "center";
        cannotDoText.scale.set(0.5, 0.5);
        cannotDoText.alpha = 0.0001;
        // cannotDoText.setScrollFactor(0, 0);
        add(cannotDoText);

        coolBackButton = new FunkinBackButton(FlxG.width - 220, FlxG.height - 200, 0xFFFFFFFF, goBack, 0.5);
        #if !mobile
        coolBackButton.visible = PointlessPins.isMouseActive;
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

        if (ModStore.get("pinsIsOutdated") && ModStore.get("pinsHasShownOutdate") == null)
        {
            var alert:BAlphabet = new BAlphabet(30, 30, '<c=00FF00><b>Version ${ModStore.get("pinsOnlineVersion")} is available!</b></c>');
            alert.scale.set(0.4, 0.4);
            alert.zIndex = 100000;
            add(alert);
            alert.cameras = [cameraHUD];
            new FlxTimer().start(8, (_:FlxTimer) -> {
                FlxTween.tween(alert, { alpha: 0 }, 2, { ease: FlxEase.quintOut });
            });
            ModStore.register("pinsHasShownOutdate", true);
        }

        persistentUpdate = true;

        camera.minScrollX = wall.x - 100;
        camera.maxScrollX = wall.x + wall.width + 100;
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

        if (isOpheliaGone)
        {
            ophelia.visible = false;
        }

        if (controls.BACK_P)
        {
            goBack();
        }

        if (disallowInputs)
        {
            coolBackButton.enabled = false;
            return;
        }
        coolBackButton.visible = #if mobile true; #else PointlessPins.isMouseActive; #end
        coolBackButton.enabled = true;

        handleCameraMovement();
        checkIfAnnoyedOphelia();

        justGainedFocus = false;

        // Pins

        if (FlxG.keys.justPressed.ONE || (TouchUtil.pressAction(iconPins) && !PointlessPins.isMouseTooFast && !TouchUtil.overlaps(coolBackButton, cameraHUD)))
        {
            disallowInputs = true;
            cameraFollowPoint.setPosition(iconPins.x + iconPins.width / 2, iconPins.y + 50);

            var substate = new PinBoard();
            substate.closeCallback = function()
            {
                FlxTween.tween(coolBackButton, { alpha: 0.5 }, 1, { ease: FlxEase.cubeOut });
                FlxTween.tween(camera, { zoom: 1 }, 1, { ease: FlxEase.cubeOut });
                FlxTween.tween(funkBucksText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
                FlxTween.tween(blueJewelsText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
                FlxTween.tween(screenBlack, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
            };
            substate.cameras = [cameraSubState];

            FlxTween.tween(coolBackButton, { alpha: 0 }, 1, { ease: FlxEase.cubeIn });
            FlxTween.tween(camera, { zoom: 1.5 }, 1, { ease: FlxEase.cubeIn });
            FlxTween.tween(funkBucksText, { alpha: 0 }, 1, { ease: FlxEase.cubeIn });
            FlxTween.tween(blueJewelsText, { alpha: 0 }, 1, { ease: FlxEase.cubeIn });
            FlxTween.tween(screenBlack, { alpha: 0.8 }, 1, { ease: FlxEase.cubeIn, onComplete: function()
            {
                openSubState(substate);
            }});
        }

        // Boxes

        if (FlxG.keys.justPressed.TWO || (TouchUtil.pressAction(iconBoxes) && !PointlessPins.isMouseTooFast && !TouchUtil.overlaps(coolBackButton, cameraHUD)))
        {
            if (isOpheliaGone)
            {
                FlxTween.completeTweensOf(cannotDoText);
                FlxTween.tween(cannotDoText, { alpha: 1 }, 2, { ease: FlxEase.cubeOut, type: 16 });
                return;
            }

            disallowInputs = true;
            cameraFollowPoint.setPosition(iconBoxes.x + iconBoxes.width / 2, iconBoxes.y - 4);
            showMenuItems(false);

            var substate = new BoxSubMenu();
            substate.closeCallback = function()
            {
                FlxTween.tween(coolBackButton, { alpha: 0.5 }, 1, { ease: FlxEase.cubeOut });
                FlxTween.tween(camera, { zoom: 1 }, 1, { ease: FlxEase.cubeOut });
                FlxTween.tween(blueJewelsText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
                FlxTween.tween(screenBlack, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
                showMenuItems();
            }
            substate.cameras = [cameraSubState];

            FlxTween.tween(coolBackButton, { alpha: 0 }, 1, { ease: FlxEase.cubeIn });
            FlxTween.tween(screenBlack, { alpha: 0.5 }, 1, { ease: FlxEase.cubeIn });
            FlxTween.tween(blueJewelsText, { alpha: 0 }, 1, { ease: FlxEase.cubeIn });
            FlxTween.tween(camera, { zoom: 0.9 }, 1, { ease: FlxEase.cubeOut, onComplete: function()
            {
                openSubState(substate);
            }});
        }

        // Exchange

        if (FlxG.keys.justPressed.THREE || (TouchUtil.pressAction(lableExchange) && !PointlessPins.isMouseTooFast && !TouchUtil.overlaps(coolBackButton, cameraHUD)))
        {
            if (isOpheliaGone)
            {
                FlxTween.completeTweensOf(cannotDoText);
                FlxTween.tween(cannotDoText, { alpha: 1 }, 2, { ease: FlxEase.cubeOut, type: 16 });
                return;
            }

            disallowInputs = true;
            cameraFollowPoint.setPosition(ophelia.x - 50, 305);
            showMenuItems(false);

            var substate = new ExchangeMenu();
            substate.closeCallback = function()
            {
                FlxTween.tween(coolBackButton, { alpha: 0.5 }, 1, { ease: FlxEase.cubeOut });
                FlxTween.tween(camera, { zoom: 1 }, 1, { ease: FlxEase.cubeOut });
                showMenuItems();
            }
            substate.cameras = [cameraSubState];

            FlxTween.tween(camera, { zoom: 1.4 }, 1, { ease: FlxEase.cubeOut, onComplete: function()
            {
                openSubState(substate);
            }});
        }

        // Rewards

        if (FlxG.keys.justPressed.FOUR || (TouchUtil.pressAction(lableRewards) && !PointlessPins.isMouseTooFast && !TouchUtil.overlaps(coolBackButton, cameraHUD)))
        {
            if (isOpheliaGone)
            {
                FlxTween.completeTweensOf(cannotDoText);
                FlxTween.tween(cannotDoText, { alpha: 1 }, 2, { ease: FlxEase.cubeOut, type: 16 });
                return;
            }

            disallowInputs = true;
            cameraFollowPoint.setPosition(1705, 240);
            showMenuItems(false);
            rewardShelf.toggleItems();

            var substate = new RewardsSubMenu();
            substate.closeCallback = function()
            {
                ophelia.playAnimation("Idle", true, true);
                FlxTween.tween(coolBackButton, { alpha: 0.5 }, 1, { ease: FlxEase.cubeOut });
                // FlxTween.tween(counter, { alpha: 1 }, 1, { ease: FlxEase.cubeIn });
                FlxTween.tween(camera, { zoom: 1 }, 1, { ease: FlxEase.cubeOut });
                showMenuItems();
                rewardShelf.toggleItems(true);
            }
            substate.cameras = [cameraSubState];

            FlxTween.tween(coolBackButton, { alpha: 0 }, 1, { ease: FlxEase.cubeIn });
            // FlxTween.tween(counter, { alpha: 0 }, 1, { ease: FlxEase.cubeIn });
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

    function showMenuItems(show:Bool = true):Void
    {
        if (show)
        {
            for (item in counterItems)
            {
                FlxTween.tween(item, { alpha: 1 }, 1, { ease: FlxEase.cubeIn });
            }
        }
        else
        {
            for (item in counterItems)
            {
                FlxTween.tween(item, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
            }
        }
    }

    /**
     * 50 taps: Ophelia gives a Pin of herself.
     * 75 taps: Warning.
     * 100 taps: +1 to her anger count.
     */
    function checkIfAnnoyedOphelia():Void
    {
        if (isOpheliaGone || !ophelia.canAnnoy)
        {
            return;
        }

        // Ophelia's sprite extends behind the counter, we don't wanna count pressing in that area as well.
        if (TouchUtil.pressAction(opheliaHitbox, camera) && !TouchUtil.overlaps(coolBackButton, cameraHUD) && !PointlessPins.isMouseTooFast)
        {
            ophelia.annoyance++;
            trace("Boop! " + ophelia.annoyance);

            if (ophelia.annoyance == 50 &&!PointlessPins.hasObtainedPin("ophelia"))
            {
                new FlxTimer().start(0.5, function(_:FlxTimer)
                {
                    opheliaPinDialogue();
                });

                disallowInputs = true;
                showMenuItems(false);
                cameraFollowPoint.setPosition(opheliaHitbox.x + opheliaHitbox.width / 2, opheliaHitbox.y + 115);
                FlxTween.tween(camera, { zoom: 1.5 }, 1, { ease: FlxEase.cubeOut });
                FlxTween.tween(funkBucksText, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
                FlxTween.tween(blueJewelsText, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
                coolBackButton.visible = false;
                trace("Enough booping!");
                return;
            }

            if (ophelia.annoyance == 75 && PointlessPins.getOpheliaAnger() == 0)
            {
                if (dialog != null) remove(dialog);
                dialog = new PinDialogue("angerWarning");
                add(dialog);
                dialog.cameras = [cameraHUD];
                ophelia.canAnnoy = false;

                dialog.dialogueText.letterCallback = () ->
                {
                    FunkinSound.playOnce(Paths.sound("chartingSounds/keyboard" + FlxG.random.int(1, 3)), 1.0);
                    ophelia.playAnimation('Talk', false, false);
                }

                dialog.onCompleteDialogue.add(() ->
                {
                    ophelia.canAnnoy = true;
                });
            }

            if (ophelia.annoyance % 100 == 0)
            {
                if (PointlessPins.getOpheliaAnger() == 0)
                {
                    // PointlessPins.save.opheliaAngerTime = Date.now().getTime();
                }
                disallowInputs = true;
                if (PointlessPins.getOpheliaAngerTotal() > 0)
                {
                    if (PointlessPins.getOpheliaAnger() > 5)
                    {
                        opheliaAngerDialogue("Repeat3");
                    }
                    else if (PointlessPins.getOpheliaAnger() > 0)
                    {
                        opheliaAngerDialogue("Repeat2");
                    }
                    else
                    {
                        opheliaAngerDialogue("Repeat");
                    }
                }
                else
                {
                    opheliaAngerDialogue("Initial");
                }
                // PointlessPins.addOpheliaAnger(1);
                trace("FUCK YOU!!!!");
                return;
            }

            ophelia.playAnimation("GetTappedOn1", false, true);
        }
    }

    function opheliaPinDialogue():Void
    {
        if (dialog != null) remove(dialog);
        dialog = new PinDialogue("opheliaPin");
        add(dialog);
        dialog.cameras = [cameraHUD];

        dialog.dialogueText.letterCallback = () ->
        {
            FunkinSound.playOnce(Paths.sound("chartingSounds/keyboard" + FlxG.random.int(1, 3)), 1.0);
            ophelia.playAnimation('Talk', false, false);
        }

        dialog.onCompleteDialogue.add(() ->
        {
            unlockOpheliaPin();
        });
    }

    function unlockOpheliaPin():Void
    {
        ophelia.playAnimation("PickingPin", false, true);
        FlxTween.tween(cameraFollowPoint, { x: cameraFollowPoint.x - 50, y: cameraFollowPoint.y + 25 }, 2, { ease: FlxEase.cubeOut });
        var substate = new PinUnlockState(PointlessPins.getPinByID("ophelia"));
        substate.cameras = [cameraSubState];
        substate.closeCallback = () -> {
            disallowInputs = false;
            showMenuItems(true);
            FlxTween.tween(camera, { zoom: 1 }, 1, { ease: FlxEase.cubeOut });
            FlxTween.tween(funkBucksText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
            FlxTween.tween(blueJewelsText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
        }
        new FlxTimer().start(68 / 24, (_:FlxTimer) -> {
            FlxTween.tween(cameraFollowPoint, { x: cameraFollowPoint.x - 100, y: cameraFollowPoint.y + 50 }, 14 / 24, { ease: FlxEase.cubeOut });
        });
        new FlxTimer().start(84 / 24, (_:FlxTimer) -> {
            openSubState(substate);
            FlxTween.tween(camera, { zoom: 1.25 }, 1, { ease: FlxEase.cubeOut });
            ophelia.playAnimation("Idle", true, true);
        });
    }

    function opheliaAngerDialogue(variant:String):Void
    {
        if (dialog != null) remove(dialog);
        dialog = new PinDialogue("anger" + variant);
        add(dialog);
        dialog.cameras = [cameraHUD];

        dialog.dialogueText.letterCallback = () ->
        {
            FunkinSound.playOnce(Paths.sound("chartingSounds/keyboard" + FlxG.random.int(1, 3)), 1.0);
            ophelia.playAnimation('Talk', false, false);
        }

        dialog.onCompleteDialogue.add(() ->
        {
            disallowInputs = false;
            showMenuItems(true);
            FlxTween.tween(camera, { zoom: 1 }, 1, { ease: FlxEase.cubeOut });
            FlxTween.tween(funkBucksText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
            FlxTween.tween(blueJewelsText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
        });
        
        showMenuItems(false);
        cameraFollowPoint.setPosition(opheliaHitbox.x + opheliaHitbox.width / 2, opheliaHitbox.y + 100);
        FlxTween.tween(camera, { zoom: 1.35 }, 1, { ease: FlxEase.cubeOut });
        FlxTween.tween(funkBucksText, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
        FlxTween.tween(blueJewelsText, { alpha: 0 }, 1, { ease: FlxEase.cubeOut });
        coolBackButton.visible = false;
    }

    var previousFunkBucks:Int;
    public function deductFunkBucks(amount:Int):Void
    {
        var currentFunkBucks:Int = previousFunkBucks = PointlessPins.getFunkCoins();
        var remainingFunkBucks:Int = currentFunkBucks - amount;

        buckSound.pitch = 1.0;
        var easeToUse:FlxEase = amount >= 500 ? FlxEase.expoOut : FlxEase.quartOut;
        FlxTween.num(currentFunkBucks, remainingFunkBucks, 2.5, { ease: easeToUse, onComplete: function(_) {
            funkBucksText.text = '<b>${Math.floor(remainingFunkBucks)}</b> ${PTIcon.Buck}';
        }}, updateFunkBucks);

        PointlessPins.addFunkCoins(-amount, false);
    }

    public function addFunkBucks(amount:Int):Void
    {
        var currentFunkBucks:Int = PointlessPins.getFunkCoins() + amount;

        funkBucksText.text = '<b>$currentFunkBucks</b> ${PTIcon.Buck}';
        funkBucksText.y -= 20;
        FunkinSound.playOnce(Paths.sound("fav"), 0.35);

        funkBucksText.forEach((letter) -> {
            FlxTween.color(letter, 0.5, 0xFF00FF00, 0xFFFFFFFF);
        });

        PointlessPins.addFunkCoins(amount, false);
    }

    public function deductBlueJewel(amount:Int):Void
    {
        var currentJewels:Int = PointlessPins.getBlueJewels();
        var remainingJewels:Int = currentJewels - amount;

        blueJewelsText.text = '<b><c=82E9FF>$remainingJewels<s=0.5>/${PointlessPins.maximumBlueJewels}</s></c></b> ${PTIcon.Jewel}';
        blueJewelsText.y += 20;
        FunkinSound.playOnce(Paths.sound("bluejewel"));

        PointlessPins.addBlueJewels(-amount, false);
    }

    public function addBlueJewel(amount:Int):Void
    {
        var currentJewels:Int = PointlessPins.getBlueJewels() + amount;

        blueJewelsText.text = '<b><c=82E9FF>$currentJewels<s=0.5>/${PointlessPins.maximumBlueJewels}</s></c></b> ${PTIcon.Jewel}';
        blueJewelsText.y -= 20;
        FunkinSound.playOnce(Paths.sound("bluejewel"));

        blueJewelsText.forEach((letter) -> {
            FlxTween.color(letter, 0.5, 0xFF00FF00, letter.curLetter.colored ? 0xFFFFFFFF : 0xFF82E9FF);
        });

        PointlessPins.addBlueJewels(amount, false);
    }

    function updateFunkBucks(value:Float):Void
    {
        if (previousFunkBucks != Math.floor(value))
        {
            funkBucksText.text = '<b>${Math.floor(value)}</b> ${PTIcon.Buck}';
            funkBucksText.y += 5;
            FunkinSound.playOnce(Paths.sound("fav"), 0.35);
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

    override function onFocus():Void
    {
        justGainedFocus = true;
    }

    override function openSubState(state):Void
    {
        cameraSubState.scroll.set(0, 0);
        cameraSubState.follow(null);
         // Necessary, otherwise you can move the camera during transitions, which sets this to false?????
        disallowInputs = true;

        super.openSubState(state);
    }

    override function closeSubState():Void
    {
        new FlxTimer().start(0.1, function(_:FlxTimer) {
            disallowInputs = false;
        });
        super.closeSubState();
    }

    override function destroy():Void
    {
        #if !mobile
        FlxMouseEvent.remove(coolBackButton);
        #end
        super.destroy();
    }
}