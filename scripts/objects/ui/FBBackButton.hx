package funkbucks.objects.ui;

import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import funkin.graphics.FunkinSprite;
import funkin.audio.FunkinSound;
import funkin.util.TouchUtil;

/**
 * Custom back button :DDD
 * The built-in one doesn't have mouse support, and my previous attempt was shoddy.
 * (Desktop) You could get accidental presses if you're swiping too quickly, that doesn't happen with this.
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
    }

    function handleInput():Void
    {
        if (TouchUtil.justPressed)
        {
            isHovering = true;
        }

        if (TouchUtil.pressed)
        {
            if (TouchUtil.overlaps(super, super.camera) && isHovering)
            {
                isHolding = true;
                animation.play("active");
                alpha = 1.0;
                scaleTarget = 0.85;
            }
            else
            {
                isHovering = false;
                isHolding = false;
                animation.play("idle");
                alpha = idleOpacity;
                scaleTarget = 1.0;
            }
        }
        else
        {
            if (isHolding && isHovering)
            {
                doConfirm();
                scale.set(1.3, 1.3);
            }

            isHovering = false;
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
        else
        {
            handleInput();
        }

        super.update(elapsed);
    }
}