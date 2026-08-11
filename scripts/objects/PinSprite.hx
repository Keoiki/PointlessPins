package funkbucks.objects;

import flixel.addons.display.FlxRuntimeShader;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.graphics.FunkinSprite;

class PinSprite extends FunkinSprite
{
    public var position:Array<Int> = [0, 0];
    public var pID:String;
    public var name:String;
    public var description:String;
    public var scaleOverride:Float;
    public var rarity:String = "Unknown";
    public var artist:String = "Keoiki";
    public var source(default, set):String = "Unknown";
    public var pixel:Bool;
    public var lockedText(default, set):String = "Unknown";
    public var special:Bool = false;
    public var isUnlocked:Bool = false;
    public var isUnknown:Bool = false;
    public var unlockCount:Int = 0;
    public var rotationTween:FlxTween = null;

    final tagRegex:EReg = new EReg('#([a-zA-Z0-9_-]+)#', "g");

    function set_source(value:String):String
    {
        value = tagRegex.map(value, (e) ->
        {
            switch (e.matched(1).toLowerCase())
            {
                case "mod": return FBIcon.Modded;
                case "internet": return FBIcon.Internet;
                case "game": return FBIcon.Game;
                default: return "<color=FF0000>!Unknown Source Tag!</color>";
            }
        });

        source = value;
        return source;
    }

    function set_lockedText(value:String):String
    {
        value = tagRegex.map(value, (e) ->
        {
            switch (e.matched(1).toLowerCase())
            {
                case "april_purchase": return FunkBucks.getEvent("hasMetApril") == 1 ? "Can be purchased from <c=EA8645>April</c>." : "???";
                default: return "<color=FF0000>!Unknown Locked Tag!</color>";
            }
        });

        lockedText = value;
        return lockedText;
    }

    public function new(x:Float, y:Float)
    {
        super(x, y);
    }

    /**
     * Setup function for all pin data and graphic.
     * @param _id The Pin's ID (also used for filename)
     * @param _name The Pin's name.
     * @param _description The Pin's description (optional)
     * @param _scale The Pin's scale in the menu (optional, default: 0.5)
     */
    public function setupPin(_id:String, _name:String, _description:String, _scale:Float = 0.5, alphaDest:Float = 1, loadImmediately:Bool = false)
    {
        pID = _id;
        name = _name;
        description = _description;
        scaleOverride = _scale;

        var fileToLoad:String = "images/pointlesspins/pins/" + pID + ".png";
        
        if ((!Assets.exists(fileToLoad) && isUnlocked) || isUnknown)
        {
            fileToLoad = "images/unknownpin.png";
            scaleOverride = 0.45;
        }
        else if (!isUnlocked)
        {
            fileToLoad = "images/pinknob.png";
            scaleOverride = 1;
        }

        if (loadImmediately)
        {
            loadTexture(fileToLoad.substring(fileToLoad.indexOf("/") + 1, fileToLoad.lastIndexOf(".")));
            scale.set(scaleOverride, scaleOverride);
            updateHitbox();
            x -= width / 2;
            y -= height / 2;
            alpha = alphaDest;
        }
        else
        {
            var fadeTween:Null<FlxTween> = null;
            fadeTween = FlxTween.tween(super, { alpha: 0 }, 0.25);

            Assets.loadBitmapData(fileToLoad).onComplete(function(bitmapData)
            {
                if (!exists) return;

                loadBitmapData(bitmapData, true);
                scale.set(scaleOverride, scaleOverride);
                updateHitbox();
                x -= width / 2;
                y -= height / 2;

                if (fadeTween != null)
                {
                    fadeTween.cancel();
                    FlxTween.tween(super, { alpha: alphaDest }, 0.25);
                }
            });
        }
        antialiasing = !pixel;

        pinSpecificSetup();
    }

    override function update(elapsed:Float):Void
    {
        if (pID == 'tuntematon') visible = false;

        super.update(elapsed);
    }

    /**
     * When script merging works again properly, other modders can add their own crap to do with pins here.
     * Be it effects or text changes, whatever.
     */
    function pinSpecificSetup():Void
    {
        switch (pID)
        {
            case "pinhead":
            {
                // replace the shader reference to the actual shader within 0.9, for the time being it's copied over to make this as accurate as possible
                var replaceColor:FlxRuntimeShader = new FlxRuntimeShader(Assets.getText(Paths.frag("replaceColor")));
                replaceColor.setFloatArray('uTargetColor', [0, 1, 0.04]);
                replaceColor.setFloat('uThreshold', 0.12);
                final hue:Float = Math.random() * 360;
                final sat:Float = (75 + Math.random() * 5) / 240;
                final lum:Float = (80 + Math.random() * 79) / 240;
                final color:FlxColor = FlxColor.fromHSL(hue, sat, lum);
                replaceColor.setFloatArray('uReplaceColor', [((color >> 16) & 0xff) / 255.0, ((color >> 8) & 0xff) / 255.0, ((color) & 0xff) / 255.0]);
                super.shader = replaceColor;

                if (!Preferences.naughtyness)
                {
                    description = 'are you ${getCensor(7)} kidding me';
                }
            }
            default: // Nothing
        }
    }

    function getCensor(length:Int):Void
    {
        final censorChars:Array<String> = ["#", "!", "$", "@", "&", "*", "?"];
        var censor = "";
        for (i in 0...length)
        {
            censor += censorChars[FlxG.random.int(0, censorChars.length - 1)];
        }
        return censor;
    }
}