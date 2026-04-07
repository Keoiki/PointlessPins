package funkbucks.objects;

import balphabet.BAlphabet;
import flixel.addons.display.FlxSliceSprite;
import flixel.math.FlxRect;
import funkin.group.FunkinGroup;

class PinButton extends FunkinGroup
{
    public var button:FlxSliceSprite;
    public var text:BAlphabet;

    public var isActive(default, set):Bool = true;

    public function set_isActive(value:Bool):Bool
    {
        isActive = value;
        updateColor();
        return value;
    }

    public var isSelected(default, set):Bool = false;

    public function set_isSelected(value:Bool):Void
    {
        isSelected = value;
        updateColor();
        return value;
    }

    public function new(x:Float, y:Float, w:Float, h:Float, text:String):Void
    {
        super(x, y);

        button = new FlxSliceSprite(Assets.getBitmapData("images/pinbutton.png"), FlxRect.get(31, 31, 69, 69), w, h);
        button.zIndex = this.zIndex;
        button.scrollFactor.set();
        add(button);

        text = new BAlphabet(0, 0, text);
        text.alignment = "center";
        text.localScale.set(0.6, 0.6);
        text.localX = button.width / 2;
        text.localY = button.height / 2 - text.height * text.localScale.y / 3;
        text.zIndex = this.zIndex + 1;
        text.setScrollFactor();
        add(text);
    }

    function updateColor()
    {
        if (isSelected)
        {
            button.color = isActive ? 0xFFA3A3FF : 0xFF22227B;
        }
        else
        {
            button.color = isActive ? 0xFFFFFFFF : 0xFF3F3F3F;
        }
    }
}