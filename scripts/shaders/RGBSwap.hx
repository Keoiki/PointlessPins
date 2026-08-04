package funkbucks.shaders;

import flixel.addons.display.FlxRuntimeShader;
// import openfl.display.BitmapData;

/**
 * blah blah
 */
class RGBSwap extends FlxRuntimeShader
{
    public var red(default, set):Int;
    public var green(default, set):Int;
    public var blue(default, set):Int;

    function set_red(value:Int):Int
    {
        red = value;
        this.setFloatArray("uRed", [((value >> 16) & 0xff) / 255.0, ((value >> 8) & 0xff) / 255.0, ((value) & 0xff) / 255.0]);
        return value;
    }

    function set_green(value:Int):Int
    {
        green = value;
        this.setFloatArray("uGreen", [((value >> 16) & 0xff) / 255.0, ((value >> 8) & 0xff) / 255.0, ((value) & 0xff) / 255.0]);
        return value;
    }

    function set_blue(value:Int):Int
    {
        blue = value;
        this.setFloatArray("uBlue", [((value >> 16) & 0xff) / 255.0, ((value >> 8) & 0xff) / 255.0, ((value) & 0xff) / 255.0]);
        return value;
    }

    public function new()
    {
        super(Assets.getText(Paths.frag("rgbSwap")));
        this.setFloat("uApply", 1.0);
    }

    public function setColors(r:Int, g:Int, b:Int):Void
    {
        red = r;
        green = g;
        blue = b;
    }

    public function setColorsArray(color:Array<Int>):Void
    {
        this.setColors(color[0], color[1], color[2]);
    }
}