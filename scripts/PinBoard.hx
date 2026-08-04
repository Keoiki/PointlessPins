package funkbucks;

import balphabet.BAlphabet;
import flixel.FlxObject;
import flixel.addons.display.FlxSliceSprite;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import funkbucks.objects.PinSprite;
import funkbucks.shaders.ImposePatternShader;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinCamera;
import funkin.graphics.FunkinSprite;
import funkin.mobile.ui.FunkinBackButton;
import funkin.ui.MusicBeatSubState;
import funkin.util.MathUtil;
import funkin.util.ReflectUtil;
import funkin.util.SwipeUtil;
import funkin.util.TouchUtil;

class PinBoard extends MusicBeatSubState
{   
    static var rememberedPin:Array<Int> = [];

    var PINS_PER_ROW:Int = 16;
    var PIN_X_START:Int = 140;
    var PIN_X_RANGE:Int = 2200;
    var PIN_X_DIFF:Float = PIN_X_RANGE / (PINS_PER_ROW - 1);
    var PIN_Y_START:Int = 220;

    var PINS_BY_RARITY:Array<Int> = [];
    var PIN_RARITIES:Array<String> = [];

    var pinsCreated:Bool = false;
    var pinCount:Int = 0;
    var pinRows:Int = 0;
    var pinRowLengths:Array<Int> = [];

    var pinMoveSound:FunkinSound;

    var cursorX:Float = 0;
    var cursorY:Float = 0;
    var pinMidpoint:FlxPoint = null;

    var subCamHUD:FunkinCamera;
    var cameraFollowPoint:FlxObject;

    var cursor:FunkinSprite;
    var pins:Array<PinSprite> = [];
    var pinNameBox:FunkinSprite;
    var pinName:BAlphabet;
    var pinDescription:BAlphabet;
    var pinArtist:BAlphabet;
    var pinUnlockCount:BAlphabet;
    var pinSource:BAlphabet;

    var unlockedPinsData;
    var unlockedPins:Int = 0;
    var unlockedPinsPerRarity:Array<Int> = [];

    var hasUpdatedPinText:Bool = false;

    var coolBackButton:FunkinBackButton;

    override function new():Void
    {
        super();
    }

    override function create():Void
    {
        var pinJSON = FunkBucks.pinData;
        PIN_RARITIES = ReflectUtil.getAnonymousFieldsOf(pinJSON);

        var rarityByOrder = function(a, b) {
            return FlxSort.byValues(-1, ReflectUtil.getAnonymousField(pinJSON, a).order, ReflectUtil.getAnonymousField(pinJSON, b).order);
        }
        PIN_RARITIES.sort(rarityByOrder);

        var a:Int = 0;
        for (tier in PIN_RARITIES)
        {
            PINS_BY_RARITY[a] = ReflectUtil.getAnonymousField(pinJSON, tier).pins;
            a++;
        }

        subCamHUD = new FunkinCamera("pinsSubCamHUD");
		FlxG.cameras.add(subCamHUD, false);
        subCamHUD.bgColor = 0x007F7F7F;

		cameraFollowPoint = new FlxObject(640, 360, 1, 1);
        add(cameraFollowPoint);
        camera.follow(cameraFollowPoint, null, 0.07);

        var dzW:Float = camera.width;
        var dzH:Float = 0;
        camera.deadzone = FlxRect.get(camera.width / 4, (camera.height - dzH) / 2 - dzH * 0.25, dzW / 3, dzH);

        pinMoveSound = new FunkinSound();
        pinMoveSound.loadEmbedded(Paths.sound("unfav"));
        pinMoveSound.volume = 0.25;

        FlxG.sound.defaultSoundGroup.add(pinMoveSound);
        FlxG.sound.list.add(pinMoveSound);

        cursor = new FunkinSprite(60, 140).loadTexture("cursor");
        add(cursor);

        unlockedPinsData = FunkBucks.getObtainedPins();
        // trace(unlockedPinsData);

        var currentRow:Int = -1;
        var categoryRow:Int = -1;
        var categoryOffset:Int = 0;
        var textOffset:Float = 80;
        for (i in 0...PIN_RARITIES.length)
        {
            if (PINS_BY_RARITY[i].length == 0) continue;

            var pinsInRarity:Int = 0;
            pinRows = Math.ceil(PINS_BY_RARITY[i].length / PINS_PER_ROW);

            for (j in 0...PINS_BY_RARITY[i].length)
            {
                if (j % PINS_PER_ROW == 0)
                {
                    currentRow++;
                    categoryRow++;
                }

                var pinX:Float = PIN_X_START + (j % PINS_PER_ROW) * PIN_X_DIFF;
                var pinY:Float = PIN_Y_START + currentRow * 150;
                var pinColumn:Int = j % PINS_PER_ROW;

                pinY += categoryOffset;

                // Makes this look a bit cleaner some amount of lines down the... line.
                var pinData = PINS_BY_RARITY[i][j];
                var pin:PinSprite = new PinSprite(pinX, pinY);
                pin.position = [pinColumn, currentRow];
                pin.rarity = PIN_RARITIES[i];
                var isPinUnlocked:Bool = unlockedPinsData.exists(pinData.id);
                if (FunkBucks.debug_pins != null) isPinUnlocked = FunkBucks.debug_pins;
                if (isPinUnlocked)
                {
                    unlockedPins++;
                    unlockedPinsPerRarity[i]++;
                    pin.unlockCount = unlockedPinsData.get(pinData.id);
                }
                pin.isUnlocked = isPinUnlocked;
                pin.artist = pinData.artist;
                pin.source = pinData.source;
                pin.special = pinData.special ?? false;
                pin.pixel = pinData.pixel ?? false;
                pin.lockedText = pinData.lockedText ?? (pin.special ? "This pin has a special unlock condition." : "This pin can be unlocked from a box.");
                pin.setupPin(pinData.id, pinData.name, pinData.description, pinData.scale);
                add(pin);
                pins.push(pin);

                pinRowLengths[currentRow]++;

                if (!pinData.noCount ?? false)
                {
                    pinCount++;
                    pinsInRarity++;
                }
            }

            var tc:String = ReflectUtil.getAnonymousField(pinJSON, PIN_RARITIES[i]).color;
            var star:String = unlockedPinsPerRarity[i] >= pinsInRarity ? '${FBIcon.Star} ' : '';
            var rarityText = new BAlphabet(PIN_X_START - 24, textOffset, '<b>$star<c=$tc>${PIN_RARITIES[i]}</c> <s=0.5>(${(unlockedPinsPerRarity[i] ?? 0)}/$pinsInRarity)</s>${FunkBucks.debug_pins ? "<c=FF0000>*</c>" : ""}</b>');
            rarityText.scale.set(0.8, 0.8);
            add(rarityText);

            textOffset += (150 * (categoryRow + 1)) + 90;
            categoryRow = -1;
            categoryOffset += 90;
        }
        // trace(pinRowLengths);

        pinRows = pinRowLengths.length;
        pinsCreated = true;

        pinNameBox = new FunkinSprite(0, 540);
        pinNameBox.makeSolidColor(FlxG.width, 180, 0xFF000000);
        pinNameBox.alpha = 0.80;
        pinNameBox.screenCenter(0x01);
        add(pinNameBox);

        var __shader:ImposePatternShader = new ImposePatternShader();
        __shader.setBlend(0);
        __shader.setValues([pinNameBox.width, pinNameBox.height], Assets.getBitmapData(Paths.image("pointlesspins/dialogue/pattern-diamonds")),
            0xFF0C0C0C, 5.0, [-0.05, -0.1], 0.5);
        pinNameBox.shader = __shader;

        pinName = new BAlphabet(FlxG.width / 2, pinNameBox.y + 40, "");
        pinName.scale.set(0.55, 0.55);
        pinName.alignment = "center";
        add(pinName);

        pinDescription = new BAlphabet(FlxG.width / 2, pinName.y + 55, "", { lineHeight: 60 });
        pinDescription.scale.set(0.4, 0.4);
        pinDescription.alignment = "center";
        add(pinDescription);

        pinArtist = new BAlphabet(pinNameBox.x + pinNameBox.width - 25, FlxG.height - 35, "");
        pinArtist.scale.set(0.3, 0.3);
        pinArtist.alignment = "right";
        add(pinArtist);

        pinUnlockCount = new BAlphabet(pinNameBox.x + 25, FlxG.height - 35, "");
        pinUnlockCount.scale.set(0.3, 0.3);
        add(pinUnlockCount);

        pinSource = new BAlphabet(pinNameBox.x + pinNameBox.width - 25, pinNameBox.y + 25, "");
        pinSource.scale.set(0.3, 0.3);
        pinSource.alignment = "right";
        add(pinSource);

        pinNameBox.cameras = [subCamHUD];
        pinName.cameras = [subCamHUD];
        pinDescription.cameras = [subCamHUD];
        pinArtist.cameras = [subCamHUD];
        pinUnlockCount.cameras = [subCamHUD];
        pinSource.cameras = [subCamHUD];
        // menuUnlockedText.cameras = [subCamHUD];

        var boardWidth:Float = pins[15].getGraphicMidpoint(pinMidpoint).x - pins[0].getGraphicMidpoint(pinMidpoint).x + 300;
        var boardHeight:Float = pins[pins.length - 1].getGraphicMidpoint(pinMidpoint).y - pins[0].getGraphicMidpoint(pinMidpoint).y + 390;
        var pinBoard:FlxSliceSprite = new FlxSliceSprite(Assets.getBitmapData("images/pinboard.png"), FlxRect.get(60, 60, 180, 180), boardWidth, boardHeight);
        add(pinBoard);
        pinBoard.x = pins[0].getGraphicMidpoint(pinMidpoint).x - 150;
        pinBoard.y = pins[0].getGraphicMidpoint(pinMidpoint).y - 225;
        pinBoard.zIndex = -1000;

        var star:String = unlockedPins >= pinCount ? '<s=1.5>${FBIcon.Star}</s><o=20,20/> ' : '';
        var menuUnlockedText = new BAlphabet(PIN_X_START - 24, pinBoard.y - 50, '$star<b>Total: $unlockedPins/$pinCount${FunkBucks.debug_pins ? "<c=FF0000>*</c>" : ""}</b>');
        menuUnlockedText.scale.set(0.7, 0.7);
        menuUnlockedText.zIndex = -990;
        add(menuUnlockedText);

        var pinBoardExt:FlxSliceSprite = new FlxSliceSprite(Assets.getBitmapData("images/pinboardext.png"), FlxRect.get(15, 15, 70, 25),
            menuUnlockedText.width + 60, 100);
        add(pinBoardExt);
        pinBoardExt.x = menuUnlockedText.x - 30;
        pinBoardExt.y = menuUnlockedText.y - 30;
        pinBoardExt.zIndex = -995;
        
        camera.minScrollX = pins[0].getGraphicMidpoint(pinMidpoint).x - 300;
        camera.maxScrollX = pins[15].getGraphicMidpoint(pinMidpoint).x + 300;
        camera.minScrollY = pins[0].getGraphicMidpoint(pinMidpoint).y - 500;
        camera.maxScrollY = pins[pins.length - 1].getGraphicMidpoint(pinMidpoint).y + 300;

        pinMidpoint = pins[0].getGraphicMidpoint(pinMidpoint);
        cursor.x = pinMidpoint.x - cursor.width / 2;
        cursor.y = pinMidpoint.y - cursor.height / 2;

        FlxG.touches.swipeThreshold.set(100, 100);
        coolBackButton = new FunkinBackButton(FlxG.width - 220, 100, 0xFFFFFFFF, goBack, 1.0, true);
        coolBackButton.y -= coolBackButton.height / 2;
        #if !mobile
        coolBackButton.visible = FunkBucks.isMouseActive;
        FlxMouseEvent.add(coolBackButton, coolBackButton.playHoldAnim, coolBackButton.playConfirmAnim);
        #end
        coolBackButton.zIndex = 100000;
        add(coolBackButton);

        coolBackButton.cameras = [subCamHUD];

        refresh();

        if (PinBoard.rememberedPin.length > 0)
        {
            cursorX = PinBoard.rememberedPin[0];
            cursorY = PinBoard.rememberedPin[1];

            var availablePin = pins.filter(function(pin) {
                return pin.position[0] == cursorX && pin.position[1] == cursorY;
            })[0];

            pinMidpoint = availablePin.getGraphicMidpoint(pinMidpoint);
            cursor.x = pinMidpoint.x - cursor.width / 2;
            cursor.y = pinMidpoint.y - cursor.height / 2;
            cameraFollowPoint.setPosition(cursor.x, cursor.y + 75);

            camera.snapToTarget();
        }

        super.create();
    }

    public function update(elapsed:Float):Void
    {
        if (controls.BACK_P)
        {
            goBack();
        }

        pinNameBox.shader.update(elapsed);

        handleControls(elapsed);
        handleTouchControls();

        coolBackButton.visible = #if mobile true; #else FunkBucks.isMouseActive; #end

        // trace(FlxG.mouse.wheel);

        super.update(elapsed);
    }

    function goBack():Void
    {
        PinBoard.rememberedPin = [cursorX, cursorY];
        close();
    }

    public function handleControls(elapsed:Float):Void
    {
        if (!pinsCreated) return;

        var prevCurX:Int = cursorX;
        var prevCurY:Int = cursorY;

        if (#if mobile SwipeUtil.swipeLeft #else controls.UI_LEFT_P || (FlxG.mouse.justMovedRight && FlxG.mouse.pressed) #end)
        {
            cursorX--;
        }
        if (#if mobile SwipeUtil.swipeRight #else controls.UI_RIGHT_P || (FlxG.mouse.justMovedLeft && FlxG.mouse.pressed) #end)
        {
            cursorX++;
        }
        if (#if mobile SwipeUtil.swipeUp #else controls.UI_UP_P || (FlxG.mouse.justMovedDown && FlxG.mouse.pressed) || (FlxG.mouse.wheel >= 1) #end)
        {
            cursorY--;
        }
        if (#if mobile SwipeUtil.swipeDown #else controls.UI_DOWN_P || (FlxG.mouse.justMovedUp && FlxG.mouse.pressed) || (FlxG.mouse.wheel <= -1) #end)
        {
            cursorY++;
        }
        if (controls.ACCEPT_P)
        {
            trace("Pin selected.");
        }

        if (cursorY < 0) cursorY = pinRows - 1;
        if (cursorY > pinRows - 1) cursorY = 0;
        if (cursorX < 0) cursorX = pinRowLengths[cursorY] - 1;
        if (cursorX > pinRowLengths[cursorY] - 1) cursorX = prevCurY == cursorY ? 0 : (pinRowLengths[cursorY] - 1);

        if (prevCurX != cursorX || prevCurY != cursorY)
        {
            pinMoveSound.play(true);
            hasUpdatedPinText = false;
        }

        var availablePin = pins.filter(function(pin) {
            return pin.position[0] == cursorX && pin.position[1] == cursorY;
        })[0];

        if (!hasUpdatedPinText)
        {
            pinDescription.alpha = 0;
            pinArtist.alpha = 0;
            pinSource.alpha = 0;
            pinUnlockCount.alpha = 0;
            pinSource.alpha = 0;
            pinName.y = pinNameBox.y + 70;
            pinDescription.y = pinName.y + 40;
            if (!availablePin.isUnlocked)
            {
                // pinName.y -= 20;
                pinDescription.alpha = 1;

                if (pinName.text != 'Not unlocked yet!')
                {
                    pinName.text = 'Not unlocked yet!';
                }
                
                if (availablePin.lockedText != pinDescription.text)
                {
                    pinDescription.text = availablePin.lockedText;
                }
                
                pinName.y -= pinDescription.rows * 20;
            }
            else
            {
                if (availablePin.description != null)
                {
                    pinDescription.text = availablePin.description;
                    pinDescription.alpha = 1;
                    pinName.y -= pinDescription.rows * 20;
                    pinDescription.y -= pinDescription.rows * 20;
                }

                if (availablePin.artist != null)
                {
                    pinArtist.text = 'Created by: ${availablePin.artist}';
                    pinArtist.alpha = 1;
                }

                if (availablePin.source != null)
                {
                    pinSource.text = availablePin.source;
                    pinSource.alpha = 1;
                }

                pinName.text = availablePin.name;

                if (!availablePin.special)
                {
                    pinUnlockCount.alpha = 1;
                    pinUnlockCount.text = 'Unlocked ${availablePin.unlockCount} time${availablePin.unlockCount == 1 ? "" : "s"}';
                }
                else
                {
                    pinUnlockCount.alpha = 1;
                    pinUnlockCount.text = 'One-Time Reward';
                }
                
                availablePin?.rotationTween?.cancel();
                availablePin.angle = 0;
                var rotationAngle:Int = FlxG.random.bool(50) ? FlxG.random.int(-30, -21) : FlxG.random.int(21, 30);
                availablePin.rotationTween = FlxTween.tween(availablePin, { angle: rotationAngle }, 0.75, { ease: FlxEase.backOut, type: 16 });
            }
            hasUpdatedPinText = true;
        }

        pinMidpoint = availablePin.getGraphicMidpoint(pinMidpoint);
        var intendedCursorX:Float = pinMidpoint.x - cursor.width / 2;
        var intendedCursorY:Float = pinMidpoint.y - cursor.height / 2;

        cursor.x = MathUtil.smoothLerpPrecision(cursor.x, intendedCursorX, elapsed, 0.5);
        cursor.y = MathUtil.smoothLerpPrecision(cursor.y, intendedCursorY, elapsed, 0.5);
        cameraFollowPoint.setPosition(cursor.x, cursor.y + 75);
    }

    function handleTouchControls():Void
    {
        if (TouchUtil.pressAction())
        {
            for (i in 0...pins.length)
            {
                var pin = pins[i];

                if (pin == null) continue;
                if (!TouchUtil.overlaps(pin, camera)) continue;
                if (TouchUtil.overlaps(coolBackButton, subCamHUD)) continue;
                if (SwipeUtil.swipeAny) continue;

                if (pin.position[0] == cursorX && pin.position[1] == cursorY)
                {
                    trace("Pin selected.");
                }
                else
                {
                    cursorX = pin.position[0];
                    cursorY = pin.position[1];
                    pinMoveSound.play(true);
                    hasUpdatedPinText = false;
                }
                break;
            }
        }
    }

    override function destroy():Void
    {
        #if !mobile
        FlxMouseEvent.remove(coolBackButton);
        #end
        super.destroy();
    }
}