package funkbucks;

import balphabet.BAlphabet;
import flixel.addons.display.FlxSliceSprite;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxRect;
import flixel.util.FlxGradient;
import funkbucks.objects.PinButton;
import funkbucks.objects.PinButtonColor;
import funkin.graphics.FunkinCamera;
import funkin.mobile.ui.FunkinBackButton;
import funkin.ui.MusicBeatSubState;

class ConverseMenuApril extends MusicBeatSubState
{
    var sCam:FunkinCamera;

    var bg:FlxGradient;
    var buttons:Array<PinButton> = [];
    var dIDs:Array<String> = [];

    var coolBackButton:FunkinBackButton;

    override function create():Void
    {
        sCam = new FunkinCamera("converseCamera");
		FlxG.cameras.add(sCam, false);
        sCam.bgColor = 0x007F7F7F;

        // bg = FlxGradient.createGradientFlxSprite(540, FlxG.height, [0xFFEA8645, 0x00EA8745], 1, 0);
        var bg:FlxSliceSprite = new FlxSliceSprite(Assets.getBitmapData("images/pinboard.png"), FlxRect.get(60, 60, 180, 180), 680, 1400);
        // bg.blend = 0;
        // bg.alpha = 0.75;
        bg.x = -80;
        bg.y = -80;
        bg.cameras = [sCam];
        add(bg);

        checkForAvailableOptions();
        // buttons[4].isSelected = true;

        coolBackButton = new FunkinBackButton(FlxG.width - 220, FlxG.height - 200, 0xFFFFFFFF, goBack, 1.0, true);
        #if !mobile
        coolBackButton.visible = FunkBucks.isMouseActive;
        FlxMouseEvent.add(coolBackButton, coolBackButton.playHoldAnim, coolBackButton.playConfirmAnim);
        #end
        add(coolBackButton);

        super.create();
    }

    var handledAccept:Bool = false;
    override function update(elapsed:Float):Void
    {
        if (controls.BACK_P)
        {
            goBack();
        }

        super.update(elapsed);
    }

    function goBack():Void
    {
        close();
    }

    function checkForAvailableOptions():Void
    {
        addButton("exchange", '${FBIcon.Jewel} Exchange', PinButtonColor.BLUE_STONE);
        addButton("april", 'About yourself', PinButtonColor.ORANGE_APRIL);
        addButton("ophelia", 'About Ophelia', PinButtonColor.BLUE_OPHELIA);
        addButton("funkbucks", '${FBIcon.Buck} FunkBucks', PinButtonColor.BROWN);
        addButton("melodystones", '${FBIcon.Jewel} Melody Stones', PinButtonColor.BROWN);
        addButton("pins", 'Pins', PinButtonColor.BROWN);
        addButton("boxes", 'Boxes', PinButtonColor.BROWN);
        addButton("rewards", 'Rewards', PinButtonColor.BROWN);
        addButton("dailysongs", 'Daily Songs', PinButtonColor.BROWN);
    }

    var btnIndex:Int = 0;
    function addButton(dID:String, text:String, color:PinButtonColor = PinButtonColor.BROWN):Void
    {
        var button:PinButton = new PinButton(35, 50 + btnIndex * 125, 500, 110, text, color);
        add(button);
        button.cameras = [sCam];
        button.isActive = true;
        buttons.push(button);
        dIDs.push(dID);

        btnIndex++;
    }

    override function destroy():Void
    {
        #if !mobile
        FlxMouseEvent.remove(coolBackButton);
        #end
        super.destroy();
    }
}