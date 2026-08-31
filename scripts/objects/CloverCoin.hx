package funkbucks.objects;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.util.TouchUtil;
import funkin.ui.mainmenu.MainMenuState;
using StringTools;

class CloverCoin extends FunkinSprite
{
    public var canCollect:Bool = false;
    public var data:String = "";

    public function new(x:Float, y:Float):Void
    {
        super(x, y);
        loadSparrow("clovercoin");
        animation.addByPrefix("spin", "spin", 24, true);
        animation.play("spin", true);
        visible = false;
    }

    public function update(elapsed:Float):Void
    {
        if (TouchUtil.pressAction(super, super.camera) && canCollect && TimedCoinsManager.running && visible)
        {
            // Don't allow Main Menu coins to be collected while Freeplay is open.
            if (data.startsWith("main") && (FlxG.state is MainMenuState) && FlxG.state.subState != null) return;

            canCollect = false;
            velocity.x = FlxG.random.bool(50) ? FlxG.random.int(-100, -40) : FlxG.random.int(40, 100);
            velocity.y = -300;
            FlxTween.tween(super.velocity, { y: 1500 }, 0.75, { ease: FlxEase.cubicIn });
            FlxTween.tween(super.scale, { x: 0.75, y: 0.75 }, 0.3, { ease: FlxEase.backIn });
            FlxTween.tween(super, { alpha: 0.0 }, 0.75, { ease: FlxEase.cubicIn });
            FunkinSound.playOnce(Paths.sound("fav"), 1.0);
            TimedCoinsManager.registerCoin(data);
        }
        super.update(elapsed);
    }
}