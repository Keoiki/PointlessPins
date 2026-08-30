package funkbucks;

import funkin.graphics.FunkinSprite;
import funkbucks.Shop;
using StringTools;

class Shopkeeper extends FunkinSprite
{
    static var annoyance:Int = 0;
    static var caught:Bool = false;
    var name:String;
    var talkAnim:String = "";
    var shop:Shop;

    // These might not be needed in the future
    var animationsWithVariations:Array<String> = ["Idle", "Talk"];
    var suffix:String = "";

    override function new(x:Float, y:Float, ?name:String):Void
    {
        if (FlxG.state != 'PolymodScriptClass<funkbucks.Shop>')
        {
            throw 'Shopkeeper cannot exist outside of the Shop!';
        }

        if (name == "ophelia")
        {
            throw 'Not available.';
        }

        super(x, y, 'shop/$name',
        {
            applyStageMatrix: true
        });

        this.name = name ?? "april";
        shop = Shop.instance;

        animation.onFinish.add((name:String) ->
        {
            if (name.startsWith("GetTapped") || name.startsWith("Talk"))
            {
                playAnimation("Idle", true);
            }
        });

        if (name == "april")
        {
            // tiny offsets because she's evil
            x -= 10;
            y -= 5;
            Shopkeeper.caught = false;
            Shopkeeper.annoyance = 0;
            playAnimation("OnPhone", true);
        }
        else
        {
            playAnimation("Idle", true);
        }

        animation.onFinish.add((name:String) ->
        {
            if (name.endsWith(":Talk"))
            {
                playAnimation(name.split(":")[0], true);
            } 
        });
    }

    function playAnimation(name:String, looped:Bool = false, forced:Bool = false):Void
    {
        if (Shopkeeper.caught)
        {
            animation.play("OutCold", true);
            return;
        }

        var anger:Int = FunkBucks.getOpheliaAnger();
        if (animationsWithVariations.contains(name) && suffix == "" && this.name == "ophelia")
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

    /**
     * Make the shopkeeper talk. This only works with April so far because only her animation names support the naming scheme below.
     */
    function talk():Void
    {
        if (talkAnim == "" || animation.curAnim.name.split(":")[0] != talkAnim)
        {
            talkAnim = animation.curAnim.name;
        }

        // Let's not spam the console with crap about not having an animation.
        // Sometimes not have a talk variant of an animation is intentional.
        // if (!hasAnimation(talkAnim + ":Talk")) return;

        animation.play(talkAnim + ":Talk", false);
    }
}