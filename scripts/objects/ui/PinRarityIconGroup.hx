package funkbucks.objects.ui;

import funkbucks.FunkBucks;
import funkin.graphics.FunkinSprite;
import funkin.group.FunkinGroup;
import funkin.util.ReflectUtil;
import funkin.util.TouchUtil;
import flixel.util.FlxSort;
import openfl.filters.BitmapFilter;
import openfl.filters.DropShadowFilter;

class PinRarityIconGroup extends FunkinGroup
{
    final SELECTED_FILTER:Array<BitmapFilter> =
    [
        new DropShadowFilter(0, 0, 0xFFFFFF, 1, 4, 4, 40, 1, false, false, false)
    ];

    final ICON_X_DIFF:Float = 100;

    var currentRarity(default, set):String = "Common";

    function set_currentRarity(value:String):String
    {
        currentRarity = value;
        for (i in 0...rarityObjects.length)
        {
            if (rarityOrder[i] == currentRarity)
            {
                rarityObjects[i].filters = SELECTED_FILTER;
                rarityObjects[i].localScale.set(1.2, 1.2);
                rarityObjects[i].localY = -rarityObjects[i].height - 10;
            }
            else
            {
                rarityObjects[i].filters = null;
                rarityObjects[i].localScale.set(1.0, 1.0);
                rarityObjects[i].localY = -rarityObjects[i].height;
            }
        }
        return currentRarity;
    }

    var rarityOrder:Array<String> = [];
    var rarityObjects:Array<FunkinSprite> = [];

    public var parentState:FlxState;
    public var noControl:Bool = false;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        var pinJSON = FunkBucks.pinData;
        var PIN_RARITIES = ReflectUtil.getAnonymousFieldsOf(pinJSON);

        PIN_RARITIES = PIN_RARITIES.filter(function(rarity)
        {
            return ReflectUtil.getAnonymousField(pinJSON, rarity).pins.length > 0;
        });

        var rarityByOrder = function(a, b)
        {
            return FlxSort.byValues(-1, ReflectUtil.getAnonymousField(pinJSON, a).order, ReflectUtil.getAnonymousField(pinJSON, b).order);
        }
        PIN_RARITIES.sort(rarityByOrder);

        final rarityCount:Int = PIN_RARITIES.length;
        for (i in 0...rarityCount)
        {
            var rarityIcon:FunkinSprite = new FunkinSprite(0, 0).loadTexture('pinboard/rarity-${PIN_RARITIES[i]}');
            if (rarityIcon.frames == null) rarityIcon.loadTexture('pinboard/rarity-Common');
            rarityIcon.localX = ICON_X_DIFF * i - ICON_X_DIFF / 2 * rarityCount + 10;
            rarityIcon.localY = -rarityIcon.height;
            this.add(rarityIcon);
            rarityOrder.push(PIN_RARITIES[i]);
            rarityObjects.push(rarityIcon);
        }
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (noControl) return;

        for (i in 0...rarityObjects.length)
        {
            if (TouchUtil.pressAction(rarityObjects[i], super.camera))
            {
                parentState.quickSwitchRarity(i - rarityOrder.indexOf(currentRarity));
            }
        }
    }
}