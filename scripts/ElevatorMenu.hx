package funkbucks;

import balphabet.BAlphabet;
import flixel.addons.display.FlxSliceSprite;
import flixel.math.FlxRect;
import funkin.ui.MusicBeatSubState;
import funkin.util.TouchUtil;

class ElevatorMenu extends MusicBeatSubState
{
    var options:Array<String> = ['${FBIcon.Lock} Ophelia\'s Office', '${FBIcon.Lock} April\'s Office', '${FBIcon.Lock} The Chest Hall', 'The Shop'];
    var buttons:Array<FlxSliceSprite> = [];

    var justOpened:Bool = true;

    override public function create()
    {
        super();

        for (i in 0...4)
        {
            var background:FlxSliceSprite = new FlxSliceSprite(Assets.getBitmapData("images/pointlesspins/dialogue/speaker-round.png"), FlxRect.get(32, 0, 238, 60), 500, 80);
            background.x = FlxG.width / 2 - background.width / 2;
            background.y = 130 + 120 * i;
            background.scrollFactor.set(0, 0);
            background.stretchLeft = true;
            background.stretchRight = true;
            background.color = 0xFF000000;
            background.alpha = i == 3 ? 0.75 : 0.25;
            add(background);
            buttons.push(background);

            var optionText:BAlphabet = new BAlphabet(FlxG.width / 2, 150 + 120 * i, options[i], { alignment: "center" });
            optionText.alpha = i == 3 ? 1.0 : 0.5;
            optionText.scale.set(0.65, 0.65);
            optionText.setScrollFactor(0, 0);
            add(optionText);
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if ((controls.BACK_P || TouchUtil.pressAction(buttons[3], camera)) && !justOpened)
        {
            goBack();
        }

        justOpened = false;
    }

    public function goBack():Void
    {
        close();
    }
}