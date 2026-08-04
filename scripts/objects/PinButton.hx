package funkbucks.objects;

import balphabet.BAlphabet;
import flixel.addons.display.FlxSliceSprite;
import flixel.math.FlxRect;
import funkbucks.shaders.RGBSwap;
import funkin.group.FunkinGroup;

class PinButton extends FunkinGroup
{
    public var button:FlxSliceSprite;
    public var text:BAlphabet;
    public var buttonShader:RGBSwap;
    public var buttonColor:PinButtonColor;

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

    public function new(x:Float, y:Float, w:Float, h:Float, text:String, ?color:PinButtonColor = PinButtonColor.BROWN):Void
    {
        super(x, y);

        buttonColor = color;

        button = new FlxSliceSprite(Assets.getBitmapData("images/pinbuttonrgb.png"), FlxRect.get(31, 31, 69, 69), w, h);
        button.zIndex = this.zIndex;
        button.scrollFactor.set();
        add(button);

        buttonShader = new RGBSwap();
        button.shader = buttonShader;

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
            buttonShader.setColorsArray(buttonColor[isActive ? 1 : 3]);
        }
        else
        {
            buttonShader.setColorsArray(buttonColor[isActive ? 0 : 2]);
        }
    }
}

/**
 * This class holds preset colors to use with buttons.
 * Active, Active (selected), Inactive, Inactive (selected)
 */
class PinButtonColor
{
    public static var BROWN:Array<Array<FlxColor>> = [
        [0xFF9D322C, 0xFF872324, 0xFF611320],
        [0xFF611320, 0xFF510D25, 0xFF3B0A29],
        [0xFF361E26, 0xFF2D1322, 0xFF000000],
        [0xFF1C0A15, 0xFF0D040A, 0xFF000000]
    ];

    public static var BLUE_OPHELIA:Array<Array<FlxColor>> = [
        [0xFF606FA2, 0xFF264967, 0xFF111B39],
        [0xFF611320, 0xFF510D25, 0xFF3B0A29],
        [0xFF361E26, 0xFF2D1322, 0xFF000000],
        [0xFF1C0A15, 0xFF0D040A, 0xFF000000]
    ];

    public static var BLUE_STONE:Array<Array<FlxColor>> = [
        [0xFF32A8E7, 0xFF1C56A5, 0xFF000000],
        [0xFF611320, 0xFF510D25, 0xFF3B0A29],
        [0xFF361E26, 0xFF2D1322, 0xFF000000],
        [0xFF1C0A15, 0xFF0D040A, 0xFF000000]
    ];

    public static var ORANGE_APRIL:Array<Array<FlxColor>> = [
        [0xFFD9471C, 0xFFB21D0B, 0xFF770003],
        [0xFF611320, 0xFF510D25, 0xFF3B0A29],
        [0xFF361E26, 0xFF2D1322, 0xFF000000],
        [0xFF1C0A15, 0xFF0D040A, 0xFF000000]
    ];
}