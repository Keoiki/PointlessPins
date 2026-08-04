package funkbucks.objects;

import flixel.math.FlxMath;
import funkbucks.FunkBucks;
import funkbucks.PinUtil;
import funkin.graphics.FunkinSprite;
import funkin.util.ReflectUtil;

/**
 * Changed from the previous iteration, boxes now roll their rewards themselves, instead of the Box Menu doing it.
 * TODO: Add support for rolling specific pins instead of a random pin from a rarity.
 */
class BoxSprite extends FunkinSprite
{
    var pinData:PinData;
    var boxData:BoxData;
    var boxDataIndex:Int = 0;

    var bID:String;
    var name:String;
    var description:String;
    var price:Int;
    var revealTime:Int;
    var chances:Array<Array<Dynamic>>;
    var rollsPins:Bool;

    var totalWeight:Int;

    var angerModifier:Float = 1.0;
    var discountModifier:Float = 1.0;

    override function new(x:Float, y:Float)
    {
        pinData = FunkBucks.pinData;
        boxData = FunkBucks.boxData;

        super(x, y, "pointlesspins/boxes/" + boxData[0].id, {
            applyStageMatrix: true,
            useRenderTexture: true
        });
        updateBoxInfo(0);
    }

    public function updateBoxInfo(change:Int = 0, forceSpecial:Bool = false):Void
    {
        boxDataIndex = PinUtil.wrapAround(boxDataIndex + change, 0, boxData.length - 1);
        while ((boxData[boxDataIndex].special ?? false) && !forceSpecial)
        {
            boxDataIndex = PinUtil.wrapAround(boxDataIndex + FlxMath.signOf(change), 0, boxData.length - 1);
        }

        bID = boxData[boxDataIndex].id;
        name = boxData[boxDataIndex].name;
        description = boxData[boxDataIndex].description;
        revealTime = boxData[boxDataIndex].revealTime;
        chances = boxData[boxDataIndex].chances;
        rollsPins = boxData[boxDataIndex].rollsPins ?? false;
        totalWeight = 0;

        for (weight in chances)
        {
            totalWeight += weight[1];
        }

        updatePrice();

        if (change != 0)
        {
            loadTextureAtlas("pointlesspins/boxes/" + bID, null, {
                applyStageMatrix: true,
                useRenderTexture: true
            });
        }
    }

    public function updateBoxInfoByID(id:String, forceSpecial:Bool = false):Void
    {
        for (i in 0...boxData.length)
        {
            if (boxData[i].id == id)
            {
                updateBoxInfo(i - boxDataIndex, forceSpecial);
                return;
            }
        }
    }

    public function updatePrice():Void
    {
        if (FunkBucks.getFreeBoxCount(bID) > 0)
        {
            price = 0;
            discountModifier = 0.0;
        }
        else
        {
            price = boxData[boxDataIndex].cost;

            var opheliaAnger:Int = FunkBucks.getOpheliaAnger();
            if (opheliaAnger > 0)
            {
                angerModifier = 1.0 + (0.2 * opheliaAnger);
                price += price * (angerModifier - 1.0);
            }
            else
            {
                angerModifier = 1.0;
            }

            var discount:Float = FunkBucks.getBoxDiscount();
            price = FlxMath.roundDecimal(price * discount, 0);
            discountModifier = (1 - discount) * 100;
        }
    }

    public function rollRandomPin():PinData {}

    public function rollRandomRarityPin():PinData
    {
        var rarities:Array<String> = getRarities();
        var odds:Array<Int> = getOdds();
        var resultingRarity:String = rarities[FlxG.random.weightedPick(odds)];

        var rarityPins = ReflectUtil.getAnonymousField(pinData, resultingRarity).pins;

        // Remove pins intended as one-time rewards.
        rarityPins = rarityPins.filter(function(pin):Bool {
            var special = pin.special ?? false;
            return !special;
        });

        var randomPin = rarityPins[FlxG.random.int(0, rarityPins.length - 1)];
        randomPin.rarity = resultingRarity;
        return randomPin;
    }

    function getRarities():Array<String>
    {
        var rarities = [];
        for (i in 0...chances.length)
        {
            rarities.push(chances[i][0]);
        }
        return rarities;
    }

    function getOdds():Array<Int>
    {
        var odds = [];
        for (i in 0...chances.length)
        {
            odds.push(chances[i][1]);
        }
        return odds;
    }
}