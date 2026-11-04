package funkbucks.objects.ui;

#if desktop
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import funkin.graphics.FunkinSprite;
import funkin.audio.FunkinSound;

/**
 * Custom back button specifically for Desktop versions. Mobile versions use the built-in back button.
 * The built-in one doesn't have mouse support, and my previous attempt was shoddy.
 * You could get accidental presses if you're swiping too quickly, that doesn't happen with this.
 */
class FBBackButton extends FunkinSprite
{
    var isHovering:Bool = false;
    var isHolding:Bool = false;

    var idleOpacity:Float = 0.5;
    var scaleTarget:Float = 1.0;

    var confirmCallback:Void->Void;

    public var enabled:Bool = true;
    public var instant:Bool = false;

    public function new(x:Float, y:Float, ?onConfirm:Void->Void, ?_idleOpacity:Float = 0.5):Void
    {
        super(x, y);

        loadSparrow("pointlesspins/backbutton");
        animation.addByIndices("idle", "backbutton", [0], '', 0, false);
        animation.addByIndices("active", "backbutton", [1], '', 0, false);
        animation.play("idle");

        idleOpacity = _idleOpacity;
        alpha = idleOpacity;
        confirmCallback = onConfirm;

        FlxMouseEvent.add(super, onStartPress, onEndPress, onMouseEnter, onMouseExit);
    }

    function onStartPress(obj:FlxObject)
    {
        if (!enabled) return;

        isHolding = true;
        animation.play("active");
        alpha = 1.0;
        scaleTarget = 0.85;
    }

    function onEndPress(obj:FlxObject)
    {
        if (!enabled) return;

        if (isHolding && isHovering)
        {
            doConfirm();
            scale.set(1.3, 1.3);
        }

        isHolding = false;
        animation.play("idle");
        alpha = idleOpacity;
        scaleTarget = 1.0;
    }

    function onMouseEnter(obj:FlxObject)
    {
        if (!enabled) return;

        isHovering = true;
    }

    function onMouseExit(obj:FlxObject)
    {
        if (!enabled) return;

        isHovering = false;
        if (isHolding)
        {
            isHolding = false;
            animation.play("idle");
            alpha = idleOpacity;
            scaleTarget = 1.0;
        }
    }

    function doConfirm():Void
    {
        enabled = false;
        if (instant)
        {
            confirmCallback();
        }
        else
        {
            FunkinSound.playOnce(Paths.sound('cancelMenu'));
            new FlxTimer().start(0.25, (_:FlxTimer) ->
            {
                confirmCallback();
            });
        }
    }

    override function update(elapsed:Float):Void
    {
        var lerpval:Float = FlxMath.bound(elapsed * 9.6, 0, 1);
        scale.x = FlxMath.lerp(scale.x, scaleTarget, lerpval);
        scale.y = FlxMath.lerp(scale.y, scaleTarget, lerpval);

        if (!enabled)
        {
            isHovering = false;
            isHolding = false;
            animation.play("idle");
            scaleTarget = 1.0;
        }

        super.update(elapsed);
    }

    override function destroy():Void
    {
        FlxMouseEvent.remove(super);
        super.destroy();
    }
}
#else
class FBBackButton
{
    public function new(x:Float, y:Float, ?onConfirm:Void->Void, ?_idleOpacity:Float = 0.5):Void
    {
        throw 'FunkBucks specific back button is not supported on mobile!';
    }
}
#end