package funkbucks.shaders;

import Math;
import flixel.addons.display.FlxRuntimeShader;

class ImposePatternShader extends FlxRuntimeShader
{
    var TIME:Float = 0.0;
    var BASEOBJSIZE:Array<Int> = [0, 0];
    var BITMAP:BitmapData = null;
    var COLOR:Int = 0xFFFFFFFF;
    var ANGLE:Float = 0;
    var DIRECTION:Array<Float> = [0, 0];
    var SPEED:Float = 0;

    public function new():Void
    {
        super(Assets.getText(Paths.frag("imposePattern")));
        this.setInt("BLEND", 1);
    }

    public function setValues(?baseObjSize:Null<Array<Int>>, ?bitmap:Null<BitmapData>, ?color:Null<Int>, ?angle:Null<Float>, ?direction:Null<Array<Float>>, ?speed:Null<Float>):Void
    {
        if (baseObjSize != null) BASEOBJSIZE = baseObjSize;
        if (bitmap != null) BITMAP = bitmap;
        if (color != null) COLOR = color;
        if (angle != null) ANGLE = angle;
        if (direction != null) DIRECTION = direction;
        if (speed != null) SPEED = speed;

        this.setFloatArray("RES", [BASEOBJSIZE[0], BASEOBJSIZE[1], 1.0]);
        this.setBitmapData("patternTexture", BITMAP);
        this.setFloatArray("patternTexSize", [BITMAP.width, BITMAP.height]);
        this.setFloatArray("patternColor", [((COLOR >> 16) & 0xff) / 255.0, ((COLOR >> 8) & 0xff) / 255.0, ((COLOR) & 0xff) / 255.0, 1.0]);
        this.setFloat("patternAngle", ANGLE * Math.PI / 180);
        this.setFloatArray("DIRECTION", DIRECTION);
        this.setFloat("SPEED", SPEED);
    }

    public function setBlend(mode:Int):Void
    {
        this.setInt("BLEND", mode);
    }

    public function update(elapsed:Float):Void
    {
        TIME += elapsed;
        this.setFloat("TIME", TIME);
        // ANGLE += elapsed / 4;
        // this.setFloat("patternAngle", ANGLE);
        // super.update(elapsed);
    }
}