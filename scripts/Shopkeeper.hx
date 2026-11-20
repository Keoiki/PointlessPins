package funkbucks;

import animate.internal.elements.FlxSpriteElement;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.graphics.FunkinSprite;
import funkbucks.Shop;
import haxe.ds.StringMap;
using StringTools;

class Shopkeeper extends FunkinSprite
{
    static var annoyance:Int = 0;
    static var caught:Bool = false;
    var name:String;
    var talkAnim:String = "";
    var shop:Shop;

    var eyes:FunkinSprite;
    var eyeAnimName:String = "";
    var mouth:FunkinSprite;
    var mouthAnimName:String = "";
    var mouthTalkName:String = "open";

    var canInterract:Bool = true;

    var canBlink:Bool = true;
    var isBlinking:Bool = false;
    var prevEyeFrame:Int = -1;
    var blinkTimer:Float = 0;
    var blinkTimerGoal:Float = 1;

    var isTalking:Bool = false;
    var prevMouthFrame:Int = -1;
    var prevMouthScale:Array<Float> = [];

    var canIdle:Bool = true;
    var idleTimer:Float = 0;
    var idleTimerGoal:Float = 0;

    // These might not be needed in the future
    var animationsWithVariations:Array<String> = ["Idle", "Talk"];
    var suffix:String = "";

    override public function new(x:Float, y:Float, ?name:String):Void
    {
        // This doesn't work, awesome.
        if (FlxG.state != funkbucks.Shop)
        {
            //throw 'Shopkeeper cannot exist outside of the Shop!';
        }

        if (name == "ophelia")
        {
            throw 'Not available.';
        }

        super(x, y, 'ui/funkbucks/shop/$name',
        {
            applyStageMatrix: true
        });

        this.name = name ?? "april";
        shop = Shop.instance;

        if (name == "april")
        {
            // tiny offsets because she's evil, not as evil as Nene of course
            x -= 10;
            Shopkeeper.caught = false;
            Shopkeeper.annoyance = 0;

            setupSwapableFace();
            playAnimSwap("normal", "side", "normal", false);
        }
        else
        {
            playAnimation("Idle", true);
        }

        animation.onFrameChange.add((name:String, frameNumber:Int, frameIndex:Int) ->
        {
            // Go back to the previous mouth on the last frame.
            // That's just how the animations were made previously and I want to keep that.
            if (name.endsWith(":talk") && frameNumber == animation.curAnim.numFrames - 1)
            {
                FlxTween.completeTweensOf(mouth.scale);
                FlxTween.completeTweensOf(mouth.skew);
                mouth.scale.set(prevMouthScale[0], prevMouthScale[1]);
                mouth.animation.curAnim.curFrame = prevMouthFrame;
            }
        });

        animation.onFinish.add((name:String) ->
        {
            if (name.endsWith(":talk"))
            {
                playAnimation(name.split(":")[0], true);
                isTalking = false;
            }
            if (name.endsWith(":In"))
            {
                playAnimation(name.split(":")[0], true);
            }
        });
    }

    override function update(elapsed:Float):Void
    {
        //if (FlxG.keys.justPressed.O)
        //{
            //eyes.animation.curAnim.curFrame = FBUtil.wrapAround(eyes.animation.curAnim.curFrame - 1, 0, eyes.animation.curAnim.numFrames - 1);
        //}
        //if (FlxG.keys.justPressed.P)
        //{
            //eyes.animation.curAnim.curFrame = FBUtil.wrapAround(eyes.animation.curAnim.curFrame + 1, 0, eyes.animation.curAnim.numFrames - 1);
        //}
        //if (FlxG.keys.justPressed.K)
        //{
            //mouth.animation.curAnim.curFrame = FBUtil.wrapAround(mouth.animation.curAnim.curFrame - 1, 0, mouth.animation.curAnim.numFrames - 1);
        //}
        //if (FlxG.keys.justPressed.L)
        //{
            //mouth.animation.curAnim.curFrame = FBUtil.wrapAround(mouth.animation.curAnim.curFrame + 1, 0, mouth.animation.curAnim.numFrames - 1);
        //}

        if (canBlink)
        {
            blinkTimer += elapsed;
            if (blinkTimer >= blinkTimerGoal)
            {
                if (!isBlinking)
                {
                    isBlinking = true;
                    blinkTimer = 0;
                    prevEyeFrame = eyes.animation.curAnim.curFrame;
                    eyes.animation.curAnim.curFrame = getBlinkFrame();
                    blinkTimerGoal = FlxG.random.float(0.05, 0.15);
                }
                else
                {
                    isBlinking = false;
                    blinkTimer = 0;
                    eyes.animation.curAnim.curFrame = prevEyeFrame;
                    if (FlxG.random.bool(20))
                    {
                        // Quickly blink again
                        blinkTimerGoal = FlxG.random.float(0.2, 0.5);
                    }
                    else
                    {
                        blinkTimerGoal = FlxG.random.float(1.2, 3.7);
                    }
                }
            }
        }
        else
        {
            isBlinking = false;
            blinkTimer = 0;
        }

        if (canIdle)
        {
            idleTimer += elapsed;
            if (idleTimer >= idleTimerGoal)
            {
                idleTimer = 0;
                // Put stuff here later.
            }
        }
        else
        {
            idleTimer = 0;
        }

        super.update(elapsed);
    }

    /**
     * Play an animation. Doesn't change eye or mouth frame, for that, use `playAnimSwap`.
     **/
    function playAnimation(name:String, looped:Bool = false, forced:Bool = false):Void
    {
        if (Shopkeeper.caught)
        {
            animation.play("OutCold", true);
            return;
        }

        animation.play(name + suffix, forced);
        animation.curAnim.looped = looped;
    }

    /**
     * Play an animation. Doesn't change eye or mouth frame, for that, use `playAnimSwap`.
     * 
     * Shorthand alias for `playAnimation`.
     **/
    function playAnim(name:String, looped:Bool = false, forced:Bool = false):Void
    {
        playAnimation(name, looped, forced);
    }

    /**
     * Play an animation, but also set the eyes and mouth to specific frames.
     * Will `throw` if either the eye or mouth variant is invalid, having valid frames is very important!
     * If no change is wanted, leave either at `null`.
     * 
     * Some animations have dedicated facial animations, for those, use `playAnimation`.
     **/
    function playAnimSwap(name:Null<String> = null, eyeName:Null<String> = null, mouthName:Null<String> = null, looped:Bool = false, forced:Bool = false):Void
    {
        if (name != null)
        {
            playAnimation(name, looped, forced);
        }

        if (eyeName != null)
        {
            if (APRIL_EYES.contains(eyeName))
            {
                eyes.animation.curAnim.curFrame = APRIL_EYES.get(eyeName);
                eyeAnimName = eyeName;
            }
            else
            {
                throw 'Invalid eye variant $eyes';
            }
        }

        if (mouthName != null)
        {
            if (APRIL_MOUTHS.contains(mouthName))
            {
                mouth.animation.curAnim.curFrame = APRIL_MOUTHS.get(mouthName);
                mouthAnimName = mouthName;
            }
            else
            {
                throw 'Invalid mouth variant $mouthName';
            }
        }
    }

    /**
     * Make the shopkeeper talk. This only works with April so far because only her animation names support the naming scheme below.
     */
    function talk():Void
    {
        // Do not talk again during talking.
        // This is mainly because of prevMouthFrame.
        if (isTalking || animation.curAnim.name.endsWith(":talk")) return;
        
        if (talkAnim == "" || animation.curAnim.name.split(":")[0] != talkAnim)
        {
            talkAnim = animation.curAnim.name;
        }

        // Let's not spam the console with crap about not having an animation.
        // Sometimes not have a talk variant of an animation is intentional.
        if (!hasAnimation(talkAnim + ":talk")) return;

        prevMouthFrame = mouth.animation.curAnim.curFrame;
        prevMouthScale = [mouth.scale.x, mouth.scale.y];
        playAnimSwap(talkAnim + ":talk", null, mouthTalkName, false, false);
        isTalking = true;

        mouth.scale.set(0.85, 0.55);
        FlxTween.tween(mouth.scale, { x: 1.2, y: 1.5 }, 5 / 24, { type: 16, ease: FlxEase.expoIn });
        FlxTween.tween(mouth.skew, { x: FlxG.random.int(-10, -20) }, 5 / 24, { type: 16, ease: FlxEase.cubeIn });
    }

    /**
     * Make the shopkeeper stop talking immediately. Quickly skipping dialogue used to mess up the mouth and the talking flag.
     */
    function stopTalking():Void
    {
        FlxTween.cancelTweensOf(mouth.scale);
        FlxTween.cancelTweensOf(mouth.skew);
        playAnimSwap(talkAnim, eyeAnimName, null, false, true);
        mouth.scale.set(prevMouthScale[0] ?? 1.0, prevMouthScale[1] ?? 1.0);
        mouth.skew.x = 0;
        mouth.animation.curAnim.curFrame = prevMouthFrame;
        isTalking = false;
    }

    function setupSwapableFace():Void
    {
        eyes = FunkinSprite.createTextureAtlas(-1, -2.5, 'ui/funkbucks/shop/$name-eyes');
        eyes.animation.addByPrefix("eyes", "eyes", 0, false);
        eyes.animation.play("eyes", true);

        mouth = FunkinSprite.createTextureAtlas(-16, -4, 'ui/funkbucks/shop/$name-mouth');
        mouth.animation.addByPrefix("mouth", "mouth", 0, false);
        mouth.animation.play("mouth", true);

        var eyeElement:FlxSpriteElement = new FlxSpriteElement(eyes);
        eyeElement.active = false;
        var mouthElement:FlxSpriteElement = new FlxSpriteElement(mouth);
        mouthElement.active = false;

        for (frame in getFramesWithKeyword("temp-eyes"))
        {
            frame.elements.splice(0, frame.elements.length);
            frame.add(eyeElement);
        }

        for (frame in getFramesWithKeyword("temp-mouth"))
        {
            frame.elements.splice(0, frame.elements.length);
            frame.add(mouthElement);
        }
    }

    function getBlinkFrame():Int
    {
        if (eyeAnimName.startsWith("front"))
        {
            return APRIL_EYES.get("frontBlink");
        }
        else
        {
            return APRIL_EYES.get("sideBlink");
        }
    }

    final APRIL_EYES:StringMap<Int> =
    [
        "sideTemplate" => 0,
        "frontTemplate" => 1,
        "frontDown" => 2,
        "frontBlink" => 3,
        "frontUp" => 4,
        "frontUpSmall" => 5,
        "side" => 6,
        "sideUpLeft" => 7,
        "sideRight" => 8,
        "sideRightAwkward" => 9,
        "sideBlink" => 10
    ];

    final APRIL_MOUTHS:StringMap<Int> =
    [
        "normal" => 0,
        "open" => 1,
        "awkwardSmile" => 2
    ];
}