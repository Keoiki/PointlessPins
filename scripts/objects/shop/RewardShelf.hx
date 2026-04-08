package funkbucks.objects.shop;

import funkin.graphics.FunkinSprite;
import funkin.group.FunkinGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class RewardShelf extends FunkinGroup
{
    var shelf:FunkinSprite;
    var randomItems:Array<FunkinSprite> = [];
    var randomItemsTop:Array<FunkinSprite> = [];

    final items:Array<String> = [
        "funkbuck01",
        "funkbuck02",
        "funkbuck03",
        "funkbuck04",
        "lock"
    ];

    override function new(x:Float, y:Float):Void
    {
        super(x, y);
        this.createShelf();
    }

    function createShelf():Void
    {
        shelf = new FunkinSprite(0, 0).loadTexture("shop/rewardsshelf");
        shelf.scrollFactor.set(0.85, 0.85);
        this.add(shelf);

        for (i in 0...9)
        {
            // 15% chance to not add an item.
            if (FlxG.random.bool(15)) 
            {
                randomItems.push(null);
                continue;
            }

            var item:FunkinSprite = new FunkinSprite(0, 0).loadTexture('shop/rewards/${items[FlxG.random.int(0, items.length - 1)]}');
            item.localX = shelf.width / 2 - 175 + (175 * (i % 3)) - item.width / 2 + FlxG.random.float(-25, 25);
            item.localY = 160 + (149 * Math.floor(i / 3)) - item.height + 6;
            item.scrollFactor.set(0.85, 0.85);
            this.add(item);
            randomItems.push(item);
        }

        for (i in 0...3)
        {
            var item:FunkinSprite = new FunkinSprite(0, 0).loadTexture('shop/rewards/${items[FlxG.random.int(0, items.length - 2)]}');
            item.localX = shelf.width / 2 - 175 + (175 * (i % 3)) - item.width / 2 - FlxG.random.float(-100, 100);
            item.localY = -item.height;
            item.scrollFactor.set(0.85, 0.85);
            this.add(item);
            randomItemsTop.push(item);
        }
    }

    public function toggleItems(show:Bool = false):Void
    {
        var targetAlpha:Float = show ? 1.0 : 0.0;
        for (item in randomItems)
        {
            if (item == null) continue;
            FlxTween.tween(item, { localAlpha: targetAlpha }, 0.35, { startDelay: FlxG.random.float(0, 0.5) });
        }
    }
}