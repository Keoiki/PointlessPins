package funkbucks;

import balphabet.BAlphabet;
import flixel.addons.display.FlxSliceSprite;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkbucks.objects.PinButton;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.mobile.ui.FunkinBackButton;
import funkin.ui.MusicBeatSubState;
import funkin.util.TouchUtil;

class ExchangeMenu extends MusicBeatSubState
{
    var jewelCosts:Array<Int> = [1, 5, 10, 15];
    var buttons:Array<PinButton> = [];
    var selected:Int = 0;
    var savedSelection:Int = -1;
    var allowedMovement:Bool = true;

    var coolBackButton:FunkinBackButton;

    var confirmScreenBG:FlxSliceSprite;
    var confirmScreenText:BAlphabet;
    var yesButton:PinButton;
    var noButton:PinButton;

    override function create():Void
    {
        var bg:FunkinSprite = new FunkinSprite(125, 0).makeSolidColor(450, FlxG.height, 0xFF000000);
        bg.alpha = 0.8;
        add(bg);

        var button01:PinButton = new PinButton(150, 100, 400, 110, '<b>${jewelCosts[0]} ${PTIcon.Jewel} &#x21E8; ${PointlessPins.bucksForBlueJewel} ${PTIcon.Buck}</b>');
        add(button01);
        var button02:PinButton = new PinButton(150, 225, 400, 110, '<b>${jewelCosts[1]} ${PTIcon.Jewel} &#x21E8; 1 ${PTIcon.Legendary}</b>');
        add(button02);
        var button03:PinButton = new PinButton(150, 350, 400, 110, '<b>${jewelCosts[2]} ${PTIcon.Jewel} &#x21E8; 1 ${PTIcon.Mythic}</b>');
        add(button03);
        var button04:PinButton = new PinButton(150, 475, 400, 110, '<b>${jewelCosts[3]} ${PTIcon.Jewel} &#x21E8; 1 ${PTIcon.Divine}</b>');
        add(button04);

        buttons.push(button01);
        buttons.push(button02);
        buttons.push(button03);
        buttons.push(button04);

        confirmScreenBG = new FlxSliceSprite(Assets.getBitmapData("images/pinbutton.png"), FlxRect.get(31, 31, 69, 69), 700, 400);
        confirmScreenBG.x = FlxG.width / 2 - confirmScreenBG.width / 2;
        confirmScreenBG.y = FlxG.height / 2 - confirmScreenBG.height / 2;
        confirmScreenBG.color = 0xFF44447B;
        confirmScreenBG.visible = false;
        add(confirmScreenBG);

        confirmScreenText = new BAlphabet(FlxG.width / 2, confirmScreenBG.y + 75, '<b>Exchange 5 ${PTIcon.Jewel} for:\n1 Unique <c=FFB51C>Legendary</c> Pin?</b>');
        confirmScreenText.alignment = "center";
        confirmScreenText.scale.set(0.6, 0.6);
        confirmScreenText.visible = false;
        add(confirmScreenText);

        yesButton = new PinButton(FlxG.width / 2, 400, 200, 110, '<b>Yes</b>');
        yesButton.x -= yesButton.button.width / 2 + 150;
        add(yesButton);
        yesButton.visible = false;

        noButton = new PinButton(FlxG.width / 2, 400, 200, 110, '<b>No</b>');
        noButton.x -= noButton.button.width / 2 - 150;
        add(noButton);
        noButton.visible = false;

        coolBackButton = new FunkinBackButton(FlxG.width - 220, FlxG.height - 200, 0xFFFFFFFF, goBack, 1.0, true);
        #if !mobile
        coolBackButton.visible = PointlessPins.isMouseActive;
        FlxMouseEvent.add(coolBackButton, coolBackButton.playHoldAnim, coolBackButton.playConfirmAnim);
        #end
        add(coolBackButton);

        // refresh();
        changeSelection();
        checkForOptionAvailability();

        super.create();
    }

    var handledAccept:Bool = false;
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        coolBackButton.visible = !allowedMovement ? false : #if mobile true; #else PointlessPins.isMouseActive; #end
        coolBackButton.active = allowedMovement;

        if (allowedMovement)
        {
            if (handledAccept) return;

            var confirmedItem:Int = -1;
            if (controls.UI_UP_P)
            {
                changeSelection(-1);
            }
            if (controls.UI_DOWN_P)
            {
                changeSelection(1);
            }
            if (controls.ACCEPT_P)
            {
                confirmedItem = selected;
            }

            for (i in 0...buttons.length)
            {
                if (TouchUtil.pressAction(buttons[i].button, camera))
                {
                    if (selected == i) confirmedItem = i;
                    changeSelection(i - selected);
                }
            }

            if (confirmedItem != -1)
            {
                var tooPoor:Bool = PointlessPins.getBlueJewels() < jewelCosts[confirmedItem];
                // var tooPoor:Bool = false;
                if (!buttons[confirmedItem].isActive)
                {
                    FunkinSound.playOnce(Paths.sound("CS_locked"), 0.5);
                    FlxTween.completeTweensOf(buttons[confirmedItem]);
                    FlxTween.tween(buttons[confirmedItem], { y: buttons[confirmedItem].y + 10 }, 0.5, { ease: FlxEase.cubeOut, type: 16 });
                    return;
                }
                if (tooPoor)
                {
                    _parentState.insufficientBlueJewels();
                    return;
                }
                switch (confirmedItem)
                {
                    case 0: confirmScreenText.text = '<b>Exchange ${jewelCosts[0]} ${PTIcon.Jewel} for:\n500 ${PTIcon.Buck}?</b>';
                    case 1: confirmScreenText.text = '<b>Exchange ${jewelCosts[1]} ${PTIcon.Jewel} for:\n1 Unique <c=FFB51C>Legendary</c> Pin?</b>\n<s=0.5>(A pin you don\'t own yet!)</s>';
                    case 2: confirmScreenText.text = '<b>Exchange ${jewelCosts[2]} ${PTIcon.Jewel} for:\n1 Unique <c=FF57F7>Mythic</c> Pin?</b>\n<s=0.5>(A pin you don\'t own yet!)</s>';
                    case 3: confirmScreenText.text = '<b>Exchange ${jewelCosts[3]} ${PTIcon.Jewel} for:\n1 Unique <c=66FFFF>Divine</c> Pin?</b>\n<s=0.5>(A pin you don\'t own yet!)</s>';
                }
                savedSelection = selected;
                allowedMovement = false;
                confirmScreenBG.visible = true;
                confirmScreenText.visible = true;
                yesButton.visible = true;
                noButton.visible = true;
                selected = 1;
                changeSelectionConfirmation();
            }
        }
        else
        {
            if (handledAccept) return;

            var confirmedItem:Int = -1;
            if (controls.UI_LEFT_P)
            {
                changeSelectionConfirmation(-1);
            }
            if (controls.UI_RIGHT_P)
            {
                changeSelectionConfirmation(1);
            }
            if (controls.ACCEPT_P)
            {
                confirmedItem = selected;
            }

            if (TouchUtil.pressAction(yesButton.button, camera))
            {
                if (selected == 0) confirmedItem = 0;
                selected = 0;
                changeSelectionConfirmation();
            }
            else if (TouchUtil.pressAction(noButton.button, camera))
            {
                if (selected == 1) confirmedItem = 1;
                selected = 1;
                changeSelectionConfirmation();
            }

            if (confirmedItem == 0)
            {
                handledAccept = true;
                _parentState.deductBlueJewel(jewelCosts[savedSelection]);
                switch (savedSelection)
                {
                    case 0:
                    {
                        _parentState.addFunkBucks(PointlessPins.bucksForBlueJewel);
                        goBack();
                        new FlxTimer().start(0.25, function(_:FlxTimer) {
                            allowedMovement = true;
                            handledAccept = false;
                        });
                    }
                    default:
                    {
                        goBack();
                        var rarities:Array<String> = ["Legendary", "Mythic", "Divine"];
                        var lockedPinsOfRarity:Array<String> = PointlessPins.getAllPinIDsOfRarity(rarities[savedSelection - 1]).filter(function(pinID:String):Bool {
                            return !PointlessPins.hasObtainedPin(pinID);
                        });
                        var substate = new PinUnlockState(PointlessPins.getPinByID(lockedPinsOfRarity[FlxG.random.int(0, lockedPinsOfRarity.length - 1)]));
                        substate.cameras = [camera];
                        substate.closeCallback = () ->
                        {
                            allowedMovement = true;
                            handledAccept = false;
                            checkForOptionAvailability();
                        }
                        new FlxTimer().start(1.5, function(_:FlxTimer) {
                            openSubState(substate);
                        });
                    }
                }
            }
            else if (confirmedItem == 1)
            {
                goBack();
            }
        }

        if (controls.BACK_P)
        {
            goBack();
        }
    }

    function goBack():Void
    {
        if (!allowedMovement)
        {
            allowedMovement = true;
            confirmScreenBG.visible = false;
            confirmScreenText.visible = false;
            yesButton.visible = false;
            noButton.visible = false;
            selected = savedSelection;
            changeSelection();
            return;
        }
        close();
    }

    function changeSelection(change:Int = 0)
    {
        buttons[selected].isSelected = false;
        selected = PinUtil.wrapAround(selected + change, 0, buttons.length - 1);
        buttons[selected].isSelected = true;
        if (change != 0) FunkinSound.playOnce(Paths.sound("unfav"), 0.5);
    }

    function changeSelectionConfirmation(change:Int = 0)
    {
        selected = PinUtil.wrapAround(selected + change, 0, 1);
        yesButton.isSelected = selected == 0;
        noButton.isSelected = selected == 1;
        if (change != 0) FunkinSound.playOnce(Paths.sound("unfav"), 0.5);
    }

    function checkForOptionAvailability():Void
    {
        buttons[1].isActive = false;
        buttons[2].isActive = false;
        buttons[3].isActive = false;

        var legendaries:Array<String> = PointlessPins.getAllPinIDsOfRarity("Legendary");
        for (pin in legendaries)
        {
            if (!PointlessPins.hasObtainedPin(pin))
            {
                buttons[1].isActive = true;
                break;
            }
        }

        var mythics:Array<String> = PointlessPins.getAllPinIDsOfRarity("Mythic");
        for (pin in mythics)
        {
            if (!PointlessPins.hasObtainedPin(pin))
            {
                buttons[2].isActive = true;
                break;
            }
        }

        var divines:Array<String> = PointlessPins.getAllPinIDsOfRarity("Divine");
        for (pin in divines)
        {
            if (!PointlessPins.hasObtainedPin(pin))
            {
                buttons[3].isActive = true;
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