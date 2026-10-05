package funkbucks.objects;

import balphabet.BAlphabet;
import flixel.addons.display.FlxSliceSprite;
import flixel.math.FlxRect;
import funkin.graphics.FunkinSprite;
import funkin.group.FunkinGroup;

/**
 * This class displays a cool keycap sprite with a letter.
 * Only really has space for 1 letter though, so "ESC" isn't going to work too well..
 */
class KeyCap extends FunkinGroup
{
    public var keycap:FunkinSprite;
    public var letter:BAlphabet;

    public function new(x:Float, y:Float, character:String, ?keywidth:Null<Float> = 70, ?isUI:Null<Bool> = true):Void
    {
        super(x, y);

        keycap = new FlxSliceSprite(Assets.getBitmapData("images/keycap70x70.png"), FlxRect.get(13, 0, 44, 70), keywidth, 70);
        keycap.zIndex = this.zIndex;
        this.add(keycap);

        letter = new BAlphabet(0, 0, character);
        letter.alignment = "center";
        letter.localX = keycap.width / 2;
        letter.localY = 10;
        letter.localScale.set(0.6, 0.6);
        letter.zIndex = this.zIndex + 1;
        this.add(letter);

        if (isUI)
        {
            keycap.scrollFactor.set();
            letter.setScrollFactor();
        }
    }

    override function update(elapsed:Float):Void
    {
        this.visible = !FunkBucks.isMouseActive;

        super.update(elapsed);
    }
}