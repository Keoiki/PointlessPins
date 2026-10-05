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
import funkbucks.objects.KeyCap;
import funkbucks.objects.PinSprite;
import funkbucks.objects.ui.PinRarityIconGroup;
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

    final PINS_PER_ROW:Int = 16;
    final PIN_X_START:Int = 140;
    final PIN_X_RANGE:Int = 2200;
    final PIN_X_DIFF:Float = PIN_X_RANGE / (PINS_PER_ROW - 1);
    final PIN_Y_START:Int = 220;

    var PINS_BY_RARITY:Array<Int> = [];
    var PIN_RARITIES:Array<String> = [];

    var pinsCreated:Bool = false;
    var pinCount:Int = 0;
    var pinRows:Int = 0;
    var pinRowLengths:Array<Int> = [];
    var raritiesByFirstRow:Array<Array<Dynamic>> = [];
    var currentRarity(default, set):String = "Common";

    function set_currentRarity(value:String):String
    {
        currentRarity = value;
        rarityIcons.currentRarity = value;
        return value;
    }

    var pinMoveSound:FunkinSound;

    var cursorX:Float = 0;
    var cursorY:Float = 0;
    var selectedPin:PinSprite;
    var pinMidpoint:FlxPoint = null;
    var hasUpdatedPin:Bool = false;

    var subCamHUD:FunkinCamera;
    var cameraFollowPoint:FlxObject;

    var cursor:FunkinSprite;
    var pins:Array<PinSprite> = [];
    var menuFooter:FunkinSprite;
    var rarityIcons:PinRarityIconGroup;
    var leftRarityKeycap:KeyCap;
    var rightRarityKeycap:KeyCap;

    var isViewingPin:Bool = false;
    var previewPin:PinSprite;
    var pinPreviewBlack:FunkinSprite;
    var pinName:BAlphabet;
    var pinDescription:BAlphabet;
    var pinArtist:BAlphabet;
    var pinUnlockCount:BAlphabet;
    var pinSource:BAlphabet;

    var unlockedPinsData;
    var unlockedPins:Int = 0;
    var unlockedPinsPerRarity:Array<Int> = [];

    var coolBackButton:FunkinBackButton;

    override function new():Void
    {
        super();
    }

    override function create():Void
    {
        var pinJSON = FunkBucks.pinData;
        PIN_RARITIES = ReflectUtil.getAnonymousFieldsOf(pinJSON);

        PIN_RARITIES = PIN_RARITIES.filter(function(rarity)
        {
            return ReflectUtil.getAnonymousField(pinJSON, rarity).pins.length > 0;
        });

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
        var hiddenOffset:Int = 0;
        for (i in 0...PIN_RARITIES.length)
        {
            var pinsInRarity:Int = 0;
            pinRows = Math.ceil(PINS_BY_RARITY[i].length / PINS_PER_ROW);
            raritiesByFirstRow.push([PIN_RARITIES[i], currentRow + 1]);

            for (j in 0...PINS_BY_RARITY[i].length)
            {
                if (j % PINS_PER_ROW == 0)
                {
                    currentRow++;
                    categoryRow++;
                    hiddenOffset = 0;
                }

                var pinData = PINS_BY_RARITY[i][j];
                var isPinUnlocked:Bool = unlockedPinsData.exists(pinData.id);
                if (FunkBucks.debug_pins != null) isPinUnlocked = FunkBucks.debug_pins;

                if (!isPinUnlocked && pinData.hidden ?? false)
                {
                    hiddenOffset++;
                    continue;
                }

                var pinX:Float = PIN_X_START + ((j - hiddenOffset) % PINS_PER_ROW) * PIN_X_DIFF;
                var pinY:Float = PIN_Y_START + currentRow * 150;
                var pinColumn:Int = (j - hiddenOffset) % PINS_PER_ROW;

                pinY += categoryOffset;

                var pin:PinSprite = new PinSprite(pinX, pinY);
                pin.position = [pinColumn, currentRow];
                pin.rarity = PIN_RARITIES[i];
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
                pin.hidden = pinData.hidden ?? false;
                pin.lockedText = pinData.lockedText ?? (pin.special ? "This pin has a special unlock condition." : "This pin can be unlocked from a box.");
                pin.setupPin(pinData.id, pinData.name, pinData.description, pinData.scale);
                add(pin);
                pins.push(pin);

                pinRowLengths[currentRow]++;
                pinCount++;
                pinsInRarity++;
            }

            var tc:String = ReflectUtil.getAnonymousField(pinJSON, PIN_RARITIES[i]).color;
            var star:String = unlockedPinsPerRarity[i] >= pinsInRarity ? '${FBIcon.Star} ' : '';
            var rarityText = new BAlphabet(PIN_X_START - 24, textOffset, '<b>$star<c=$tc>${PIN_RARITIES[i]}</c> <s=0.5>(${(unlockedPinsPerRarity[i] ?? 0)}/$pinsInRarity)</s>${(FunkBucks.debug_pins ? " <c=FF0000>*</c>" : "")}</b>');
            rarityText.scale.set(0.8, 0.8);
            add(rarityText);

            textOffset += (150 * (categoryRow + 1)) + 90;
            categoryRow = -1;
            categoryOffset += 90;
        }
        // trace(pinRowLengths);

        pinRows = pinRowLengths.length;
        pinsCreated = true;

        menuFooter = new FunkinSprite(0, 620);
        menuFooter.makeSolidColor(FlxG.width, 100, 0xFF000000);
        menuFooter.screenCenter(0x01);
        add(menuFooter);

        var __shader:ImposePatternShader = new ImposePatternShader();
        __shader.setBlend(0);
        __shader.setValues([menuFooter.width, menuFooter.height], Assets.getBitmapData(Paths.image("pointlesspins/dialogue/pattern-diamonds")),
            0xFF191919, 5.0, [-0.05, -0.1], 0.5);
        menuFooter.shader = __shader;

        rarityIcons = new PinRarityIconGroup(FlxG.width / 2, 710);
        rarityIcons.cameras = [subCamHUD];
        rarityIcons.parentState = super;
        add(rarityIcons);

        // leftRarityKeycap = new KeyCap(40, 635, '← ${controls.getDialogueNameFromToken("FREEPLAY_LEFT", true)}', 120);
        // leftRarityKeycap.cameras = [subCamHUD];
        // add(leftRarityKeycap);

        // rightRarityKeycap = new KeyCap(FlxG.width - 160, 635, '${controls.getDialogueNameFromToken("FREEPLAY_RIGHT", true)} →', 120);
        // rightRarityKeycap.cameras = [subCamHUD];
        // add(rightRarityKeycap);

        pinPreviewBlack = new FunkinSprite(-2, -2).makeSolidColor(FlxG.width + 4, FlxG.height + 4, 0xFF000000);
        pinPreviewBlack.alpha = 0.0;
        add(pinPreviewBlack);

        pinName = new BAlphabet(FlxG.width / 2, 40, "", { lineHeight: 60 });
        pinName.scale.set(0.7, 0.7);
        pinName.alignment = "center";
        add(pinName);

        pinDescription = new BAlphabet(FlxG.width / 2, 555, "", { lineHeight: 70 });
        pinDescription.scale.set(0.5, 0.5);
        pinDescription.alignment = "center";
        add(pinDescription);

        pinArtist = new BAlphabet(FlxG.width - 25, FlxG.height - 50, "");
        pinArtist.scale.set(0.5, 0.5);
        pinArtist.alignment = "right";
        add(pinArtist);

        pinUnlockCount = new BAlphabet(25, FlxG.height - 50, "");
        pinUnlockCount.scale.set(0.5, 0.5);
        add(pinUnlockCount);

        pinSource = new BAlphabet(FlxG.width / 2, pinName.y + 60, "");
        pinSource.scale.set(0.3, 0.3);
        pinSource.alignment = "center";
        add(pinSource);

        previewPin = new PinSprite(FlxG.width / 2, FlxG.height / 2);
        previewPin.visible = false;
        add(previewPin);

        menuFooter.cameras = [subCamHUD];
        pinPreviewBlack.cameras = [subCamHUD];
        pinName.cameras = [subCamHUD];
        pinDescription.cameras = [subCamHUD];
        pinArtist.cameras = [subCamHUD];
        pinUnlockCount.cameras = [subCamHUD];
        pinSource.cameras = [subCamHUD];
        previewPin.cameras = [subCamHUD];
        // menuUnlockedText.cameras = [subCamHUD];

        var boardWidth:Float = pins[15].getGraphicMidpoint(pinMidpoint).x - pins[0].getGraphicMidpoint(pinMidpoint).x + 300;
        var boardHeight:Float = pins[pins.length - 1].getGraphicMidpoint(pinMidpoint).y - pins[0].getGraphicMidpoint(pinMidpoint).y + 390;
        var pinBoard:FlxSliceSprite = new FlxSliceSprite(Assets.getBitmapData("images/pinboard.png"), FlxRect.get(60, 60, 180, 180), boardWidth, boardHeight);
        add(pinBoard);
        pinBoard.x = pins[0].getGraphicMidpoint(pinMidpoint).x - 150;
        pinBoard.y = pins[0].getGraphicMidpoint(pinMidpoint).y - 225;
        pinBoard.zIndex = -1000;

        var star:String = unlockedPins >= pinCount ? '<s=1.5>${FBIcon.Star}</s><o=20,20/> ' : '';
        var menuUnlockedText = new BAlphabet(PIN_X_START - 24, pinBoard.y - 50, '$star<b>Total: $unlockedPins/$pinCount${(FunkBucks.debug_pins ? "<c=FF0000>*</c>" : "")}</b>');
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

            selectedPin = pins.filter(function(pin) {
                return pin.position[0] == cursorX && pin.position[1] == cursorY;
            })[0];

            currentRarity = selectedPin.rarity;
            pinMidpoint = selectedPin.getGraphicMidpoint(pinMidpoint);
            cursor.x = pinMidpoint.x - cursor.width / 2;
            cursor.y = pinMidpoint.y - cursor.height / 2;
            cameraFollowPoint.setPosition(cursor.x, cursor.y + 75);

            camera.snapToTarget();
        }
        else
        {
            selectedPin = pins[0];
            currentRarity = selectedPin.rarity;
        }

        super.create();
    }

    public function update(elapsed:Float):Void
    {
        if (controls.BACK_P)
        {
            goBack();
        }

        menuFooter.shader.update(elapsed);

        handleControls(elapsed);
        handleTouchControls();

        coolBackButton.visible = #if mobile true; #else FunkBucks.isMouseActive; #end

        // trace(FlxG.mouse.wheel);

        super.update(elapsed);
    }

    function goBack():Void
    {
        if (isViewingPin)
        {
            closePinView();
        }
        else
        {
            PinBoard.rememberedPin = [cursorX, cursorY];
            close();
        }
    }

    var holdTimers:Array<Float> = [0, 0, 0, 0];

    public function handleControls(elapsed:Float):Void
    {
        if (!pinsCreated || isViewingPin) return;

        // For some reason checking for these more than once doesn't work.
        var mouseMovedLeft:Bool = FlxG.mouse.justMovedLeft;
        var mouseMovedRight:Bool = FlxG.mouse.justMovedRight;

        var prevCurX:Int = cursorX;
        var prevCurY:Int = cursorY;
        var yChange:Int = 0;

        if (#if mobile SwipeUtil.swipeLeft && !TouchUtil.overlaps(menuFooter, subCamHUD) #else
            controls.UI_LEFT_P || (mouseMovedRight && FlxG.mouse.pressed && !FlxG.mouse.overlaps(menuFooter, subCamHUD)) #end)
        {
            cursorX--;
        }

        if (#if mobile SwipeUtil.swipeRight && !TouchUtil.overlaps(menuFooter, subCamHUD) #else
            controls.UI_RIGHT_P || (mouseMovedLeft && FlxG.mouse.pressed && !FlxG.mouse.overlaps(menuFooter, subCamHUD)) #end)
        {
            cursorX++;
        }

        if (#if mobile SwipeUtil.swipeUp && !TouchUtil.overlaps(menuFooter, subCamHUD) #else
            controls.UI_UP_P || (FlxG.mouse.justMovedDown && FlxG.mouse.pressed && !FlxG.mouse.overlaps(menuFooter, subCamHUD)) #end)
        {
            yChange = -1;
        }

        if (#if mobile SwipeUtil.swipeDown && !TouchUtil.overlaps(menuFooter, subCamHUD) #else
            controls.UI_DOWN_P || (FlxG.mouse.justMovedUp && FlxG.mouse.pressed && !FlxG.mouse.overlaps(menuFooter, subCamHUD)) #end)
        {
            yChange = 1;
        }

        if (controls.UI_LEFT) holdTimers[0] += elapsed; else holdTimers[0] = 0;
        if (controls.UI_RIGHT) holdTimers[1] += elapsed; else holdTimers[1] = 0;
        if (controls.UI_UP) holdTimers[2] += elapsed; else holdTimers[2] = 0;
        if (controls.UI_DOWN) holdTimers[3] += elapsed; else holdTimers[3] = 0;

        for (i in 0...holdTimers.length)
        {
            if (holdTimers[i] > 0.4)
            {
                switch (i)
                {
                    case 0: cursorX--;
                    case 1: cursorX++;
                    case 2: yChange = -1;
                    case 3: yChange = 1;
                }
                holdTimers[i] = 0.3;
            }
        }

        if (controls.ACCEPT_P)
        {
            openPinView();
        }

        if (cursorX < 0) cursorX = pinRowLengths[cursorY] - 1;
        if (cursorX > pinRowLengths[cursorY] - 1) cursorX = 0;
        if (yChange != 0)
        {
            cursorY += yChange;
            while (pinRowLengths[cursorY] - 1 < cursorX)
            {
                cursorY += yChange;
                if (cursorY < 0) cursorY = pinRows - 1;
                if (cursorY > pinRows - 1) cursorY = 0;
                if (cursorY == prevCurY) break;
            }
        }

        if (prevCurX != cursorX || prevCurY != cursorY)
        {
            selectedPin = pins.filter(function(pin) {
                return pin.position[0] == cursorX && pin.position[1] == cursorY;
            })[0];
            currentRarity = selectedPin.rarity;
            pinMoveSound.play(true);
            hasUpdatedPin = true;
        }

        if (controls.FREEPLAY_LEFT) quickSwitchRarity(-1);
        if (controls.FREEPLAY_RIGHT) quickSwitchRarity(1);

        if (selectedPin.isUnlocked && hasUpdatedPin)
        {
            selectedPin?.rotationTween?.cancel();
            selectedPin.angle = 0;
            var rotationAngle:Int = FlxG.random.bool(50) ? FlxG.random.int(-30, -21) : FlxG.random.int(21, 30);
            selectedPin.rotationTween = FlxTween.tween(selectedPin, { angle: rotationAngle }, 0.75, { ease: FlxEase.backOut, type: 16 });
            hasUpdatedPin = false;
        }

        pinMidpoint = selectedPin.getGraphicMidpoint(pinMidpoint);
        var intendedCursorX:Float = pinMidpoint.x - cursor.width / 2;
        var intendedCursorY:Float = pinMidpoint.y - cursor.height / 2;

        cursor.x = MathUtil.smoothLerpPrecision(cursor.x, intendedCursorX, elapsed, 0.5);
        cursor.y = MathUtil.smoothLerpPrecision(cursor.y, intendedCursorY, elapsed, 0.5);
        cameraFollowPoint.setPosition(cursor.x, cursor.y + 75);
    }

    function handleTouchControls():Void
    {
        if (isViewingPin) return;

        if (TouchUtil.pressAction())
        {
            for (i in 0...pins.length)
            {
                var pin:PinSprite = pins[i];

                if (pin == null) continue;
                if (!TouchUtil.overlaps(pin, camera)) continue;
                if (TouchUtil.overlaps(coolBackButton, subCamHUD)) continue;
                if (TouchUtil.overlaps(menuFooter, subCamHUD)) continue;
                if (SwipeUtil.swipeAny) continue;

                if (pin.position[0] == cursorX && pin.position[1] == cursorY)
                {
                    openPinView();
                }
                else
                {
                    selectedPin = pin;
                    currentRarity = selectedPin.rarity;
                    cursorX = pin.position[0];
                    cursorY = pin.position[1];
                    pinMoveSound.play(true);
                    hasUpdatedPin = true;
                }
                break;
            }
        }
    }

    function quickSwitchRarity(change:Int = 0):Void
    {
        var newRarityIndex:Int = PinUtil.wrapAround(PIN_RARITIES.indexOf(currentRarity) + change, 0, PIN_RARITIES.length - 1);
        currentRarity = PIN_RARITIES[newRarityIndex];
        selectedPin = pins.filter(function(pin) {
            return pin.rarity == currentRarity;
        })[0];
        cursorX = selectedPin.position[0];
        cursorY = selectedPin.position[1];
        pinMoveSound.play(true);
        hasUpdatedPin = true;
    }

    function openPinView():Void
    {
        for (obj in [pinName, pinDescription, pinArtist, pinSource, pinUnlockCount, selectedPin, previewPin, cursor, selectedPin.scale, previewPin.scale, pinPreviewBlack,
                    menuFooter, rarityIcons])
        {
            FlxTween.completeTweensOf(obj);
        }
        rarityIcons.noControl = true;
        isViewingPin = true;
        selectedPin.visible = false;
        previewPin.visible = true;
        previewPin.setPosition(selectedPin.getScreenPosition().x + selectedPin.width / 2, selectedPin.getScreenPosition().y + selectedPin.height / 2);
        previewPin.pixel = selectedPin.pixel;
        previewPin.isUnlocked = selectedPin.isUnlocked;
        previewPin.isUnknown = !selectedPin.isUnlocked;
        var name:String = previewPin.isUnknown ? "???" : selectedPin.name;
        var description:String = previewPin.isUnknown ? selectedPin.lockedText : selectedPin.description;
        previewPin.setupPin(selectedPin.pID, name, description, selectedPin.scaleOverride, 1.0, true);
        previewPin.shader = selectedPin.shader;
        previewPin.visible = true;
        for (obj in [cursor, menuFooter, rarityIcons])
        {
            FlxTween.tween(obj, { alpha: 0.0 }, 0.5, { ease: FlxEase.cubeOut });
        }
        FlxTween.tween(pinPreviewBlack, { alpha: 0.85 }, 0.5, { ease: FlxEase.cubeOut });
        FlxTween.tween(previewPin, { x: FlxG.width / 2 - previewPin.width / 2, y: FlxG.height / 2 - previewPin.height / 2 - 10 }, 1.0, { ease: FlxEase.quintOut });
        FlxTween.tween(previewPin.scale, { x: previewPin.scaleOverride * 2, y: previewPin.scaleOverride * 2 }, 1.0, { ease: FlxEase.backOut });

        var rarityColor:String = selectedPin.rarity == "Unknown" ? "7F7F7F" : ReflectUtil.getAnonymousField(FunkBucks.pinData, selectedPin.rarity).color;
        pinName.text = '${previewPin.name}\n\n<s=0.75><c=$rarityColor>${selectedPin.rarity}</c></s>';
        pinDescription.text = previewPin.description ?? "";
        pinArtist.text = selectedPin.artist != null ? 'Created by: ${selectedPin.artist}' : "";
        pinSource.text = selectedPin.source ?? "";

        var countText:String = "";
        if (!selectedPin.special)
        {
            countText = 'Unlocked ${selectedPin.unlockCount} time${(selectedPin.unlockCount == 1 ? "" : "s")}';
        }
        else
        {
            countText = 'One-Time Reward';
        }
        if (selectedPin.hidden) countText += ' (Hidden)';
        pinUnlockCount.text = countText;

        for (obj in [pinName, pinDescription, pinArtist, pinSource, pinUnlockCount])
        {
            FlxTween.tween(obj, { alpha: 1.0 }, 0.5, { ease: FlxEase.cubeOut });
        }
    }

    function closePinView():Void
    {
        for (obj in [pinName, pinDescription, pinArtist, pinSource, pinUnlockCount, selectedPin, previewPin, cursor, selectedPin.scale, previewPin.scale, pinPreviewBlack,
                    menuFooter, rarityIcons])
        {
            FlxTween.completeTweensOf(obj);
        }
        rarityIcons.noControl = true;
        isViewingPin = false;
        selectedPin.zIndex = 50;
        // It's possible to select another pin before the zIndex is reset, so we save the object blah blah blah
        var pinToResetZIndex:PinSprite = selectedPin;
        for (obj in [cursor, menuFooter, rarityIcons])
        {
            FlxTween.tween(obj, { alpha: 1.0 }, 0.5, { ease: FlxEase.cubeOut });
        }
        FlxTween.tween(selectedPin, { x: camera.viewX + camera.width / 2 - selectedPin.width / 2,
                                        y: camera.viewY + camera.height / 2 - selectedPin.height / 2 - 10 },
                                        1.0, { ease: FlxEase.quintOut, type: 16, onComplete: function(_:FlxTween) {
                                            pinToResetZIndex.zIndex = 0;
                                            refresh();
                                        }});
        FlxTween.tween(selectedPin.scale, { x: previewPin.scaleOverride * 2, y: previewPin.scaleOverride * 2 }, 1.0, { ease: FlxEase.backOut, type: 16 });
        for (obj in [pinName, pinDescription, pinArtist, pinSource, pinUnlockCount, pinPreviewBlack])
        {
            FlxTween.tween(obj, { alpha: 0.0 }, 0.5, { ease: FlxEase.cubeOut });
        }
        selectedPin.visible = true;
        previewPin.visible = false;
        refresh();
    }

    override function destroy():Void
    {
        #if !mobile
        FlxMouseEvent.remove(coolBackButton);
        #end
        super.destroy();
    }
}