package funkbucks;

import funkin.graphics.FunkinSprite;
using StringTools;

class Shopkeeper extends FunkinSprite
{
    static var annoyance:Int = 0;
    var canAnnoy:Bool = true;
    var animationsWithVariations:Array<String> = ["Idle", "Talk"];
    var suffix:String = "";
    var name:String;
    static var caught:Bool = false;

    override function new(x:Float, y:Float, ?name:String):Void
    {
        super(x, y, 'shop/$name', {
            applyStageMatrix: true
        });

        this.name = name ?? "ophelia";
        playAnimation("Idle", true);

        animation.onFinish.add((name:String) ->
        {
            if (name.startsWith("GetTapped") || name.startsWith("Talk"))
            {
                playAnimation("Idle", true);
            }
        });

        if (name == "april")
        {
            x -= 10;
            y -= 5;
            canAnnoy = false;
            Shopkeeper.caught = false;
            Shopkeeper.annoyance = 0;
        }
    }

    function playAnimation(name:String, looped:Bool = false, forced:Bool = false):Void
    {
        if (Shopkeeper.caught)
        {
            animation.play("OutCold", true);
            return;
        }

        var anger:Int = FunkBucks.getOpheliaAnger();
        if (animationsWithVariations.contains(name) && suffix == "")
        {
            var nameToUse:String = name;

            if (anger > 0 || Shopkeeper.annoyance > 50)
            {
                nameToUse += "Annoyed";
            }

            if (hasAnimation(nameToUse))
            {
                name = nameToUse;
            }
        }
        animation.play(name + suffix, forced);
        animation.curAnim.looped = looped;
    }
}