package pointlesspins.objects.shop.secret;

import funkin.graphics.FunkinSprite;
import funkin.util.TouchUtil;

class Tuntematon extends FunkinSprite
{
    static var gone:Bool = false;

    public function new(x:Float, y:Float):Void
    {
        super(x, y);
        loadSparrow("shop/t2");
        animation.addByIndices("idle", "tuntematonShelf", [0], "", 24, false);
        animation.addByPrefix("disappear", "tuntematonShelf", 24, false);
        animation.addByPrefix("grab", "tuntematonShelf", 12, false, true);
    }

    override function update(elapsed:Float)
    {
        if (!Tuntematon.gone && TouchUtil.pressAction(super, super.camera))
        {
            Tuntematon.gone = true;
            animation.play("disappear", true);
        }

        super.update(elapsed);
    }
}