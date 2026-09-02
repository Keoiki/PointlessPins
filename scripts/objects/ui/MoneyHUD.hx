package funkbucks.objects.ui;

import balphabet.BAlphabet;
import flixel.addons.display.FlxSliceSprite;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.group.FunkinGroup;

class MoneyHUD extends FunkinGroup
{
    public var buckText:BAlphabet;
    public var jewelText:BAlphabet;
    public var background:FlxSliceSprite;

    public var currentDisplayBucks:Bool = false;
    public var currentDisplayJewels:Bool = false;
    public var currentBGAlpha:Float = DEFAULT_BACKGROUND_ALPHA;

    var buckDiffText:BAlphabet;
    var jewelDiffText:BAlphabet;

    final DEFAULT_BACKGROUND_ALPHA:Float = 0.75;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        background = new FlxSliceSprite(Assets.getBitmapData("images/pointlesspins/dialogue/speaker-round.png"), FlxRect.get(32, 0, 238, 60), 500, 64);
        background.localX = -background.width;
        background.localY = -14;
        background.scrollFactor.set(0, 0);
        background.stretchLeft = true;
        background.stretchRight = true;
        background.color = 0xFF000000;
        background.localAlpha = 0.75;
        this.add(background);

        buckText = new BAlphabet(0, 0, '<b>${FunkBucks.getFunkCoins()}</b> ${FBIcon.Buck}');
        buckText.alignment = "right";
        buckText.localScale.set(0.65, 0.65);
        buckText.setScrollFactor(0, 0);
        this.add(buckText);
        
        jewelText = new BAlphabet(0, 0, '<b><c=82E9FF>${FunkBucks.getBlueJewels()}</c></b> ${FBIcon.Jewel}');
        jewelText.alignment = "right";
        jewelText.localScale.set(0.65, 0.65);
        jewelText.setScrollFactor(0, 0);
        jewelText.localX = -(buckText.width - 64);
        this.add(jewelText);

        buckDiffText = new BAlphabet(0, 0, "");
        buckDiffText.alignment = "center";
        buckDiffText.localScale.set(0.4, 0.4);
        buckDiffText.setScrollFactor(0, 0);
        this.add(buckDiffText);

        jewelDiffText = new BAlphabet(0, 0, "");
        jewelDiffText.alignment = "center";
        jewelDiffText.localScale.set(0.4, 0.4);
        jewelDiffText.setScrollFactor(0, 0);
        this.add(jewelDiffText);

        background.width = buckText.width + jewelText.width - 77;
        background.localX = -background.width + 15;

        background.localAlpha = 0;
        buckText.localAlpha = 0;
        jewelText.localAlpha = 0;
    }

    override function update(elapsed:Float)
    {
        this.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        if (FlxG.keys.justPressed.F9)
        {
            setDisplay(FlxG.keys.pressed.CONTROL, FlxG.keys.pressed.ALT);
        }

        if (FlxG.keys.justPressed.F10)
        {
            if (FlxG.keys.pressed.CONTROL)
            {
                showBuckChange(FlxG.random.int(-1000, 1000));
            }
            else if (FlxG.keys.pressed.ALT)
            {
                showJewelChange(FlxG.random.int(-1000, 1000));
            }
        }

        if (background.localAlpha <= 0.01)
        {
            background.width = 1;
        }

        super.update(elapsed);
    }

    public function setDisplay(showBucks:Null<Bool>, showJewels:Null<Bool>, ?bgAlpha:Null<Float>):Void
    {
        trace(showBucks, showJewels, bgAlpha);
        if (showBucks != null)
        {
            currentDisplayBucks = showBucks;
            if (showBucks)
            {
                FlxTween.tween(buckText, { localAlpha: 1 }, 1, { ease: FlxEase.cubeOut });
            }
            else
            {
                FlxTween.tween(buckText, { localAlpha: 0 }, 1, { ease: FlxEase.cubeOut });
                if ((showJewels || currentDisplayJewels) && showJewels)
                {
                    FlxTween.tween(jewelText, { localX: 0 }, 1, { ease: FlxEase.cubeOut });
                }
            }
        }

        if (showJewels != null)
        {
            currentDisplayJewels = showJewels;
            if (showJewels)
            {
                FlxTween.tween(jewelText, { localAlpha: 1 }, 1, { ease: FlxEase.cubeOut });
                if (showBucks || currentDisplayBucks)
                {
                    FlxTween.tween(jewelText, { localX: -(buckText.width + 20) }, 1, { ease: FlxEase.cubeOut });
                }
            }
            else
            {
                if (currentDisplayBucks)
                {
                    FlxTween.tween(jewelText, { localX: 0 }, 1, { ease: FlxEase.cubeOut });
                }
                FlxTween.tween(jewelText, { localAlpha: 0 }, 1, { ease: FlxEase.cubeOut, onComplete: () ->
                {
                    jewelText.localX = 0;
                }});
            }
        }

        // You can pass in these as null to keep their respective displays,
        // but we need these to not be null after this point.
        showBucks ??= currentDisplayBucks;
        showJewels ??= currentDisplayJewels;

        var updateBGWidth:Bool = showBucks || showJewels;
        
        if (!showBucks && !showJewels)
        {
            bgAlpha = 0;
        }
        else if (bgAlpha == null && updateBGWidth)
        {
            bgAlpha = DEFAULT_BACKGROUND_ALPHA;
        }

        if (bgAlpha != null)
        {
            currentBGAlpha = bgAlpha;
            FlxTween.cancelTweensOf(background.localAlpha);
            FlxTween.tween(background, { localAlpha: bgAlpha }, 1, { ease: FlxEase.cubeOut });
        }

        if (updateBGWidth)
        {
            final desiredWidth:Float = (showBucks ? buckText.width + 30 : 0) + (showJewels ? jewelText.width + 30 : 0);
            FlxTween.cancelTweensOf(background.width);
            FlxTween.tween(background, { width: desiredWidth }, 0.95, { ease: FlxEase.cubeOut, onUpdate: () ->
            {
                background.localX = -background.width + 15;
            }});
        }
    }

    public function showBuckChange(diff:Float):Void
    {
        if (!currentDisplayBucks) return;

        FlxTween.completeTweensOf(buckText);
        FlxTween.cancelTweensOf(buckDiffText);

        buckText.text = '<b>${FunkBucks.getFunkCoins()}</b> ${FBIcon.Buck}';
        FlxTween.tween(buckText, { localY: 16 }, 0.6, { ease: FlxEase.bounceOut, type: 16 });
        if (currentDisplayJewels) FlxTween.tween(jewelText, { localX: -(buckText.width + 20) }, 1, { ease: FlxEase.cubeOut });

        var prefix:String = "";
        var _color:String = "FFFFFF";
        var sound:String = "";

        if (diff != 0)
        {
            if (diff > 0)
            {
                prefix = "+";
                _color = "2BFF31";
                sound = "fav";
            }
            else
            {
                _color = "FF4C50";
                sound = "unfav";
            }
        }

        buckDiffText.localX = -(buckText.width / 2) - 10;
        buckDiffText.localY = 40;
        buckDiffText.text = '<b><c=$_color>$prefix$diff</c></b>';
        FlxTween.tween(buckDiffText, { localY: 60 }, 4, { ease: FlxEase.circOut });
        FlxTween.tween(buckDiffText, { localAlpha: 1 }, 0.2, { ease: FlxEase.cubeOut });
        FlxTween.tween(buckDiffText, { localAlpha: 0 }, 1, { startDelay: 3, ease: FlxEase.cubeOut });
        if (sound != "") FunkinSound.playOnce(Paths.sound(sound));

        setDisplay(null, null, currentBGAlpha);
    }

    public function showJewelChange(diff:Float):Void
    {
        if (!currentDisplayJewels) return;

        FlxTween.completeTweensOf(jewelText);
        FlxTween.cancelTweensOf(jewelDiffText);

        jewelText.text = '<b><c=82E9FF>${FunkBucks.getBlueJewels()}</c></b> ${FBIcon.Jewel}';
        FlxTween.tween(jewelText, { localY: 16 }, 0.6, { ease: FlxEase.bounceOut, type: 16 });

        var prefix:String = "";
        var _color:String = "FFFFFF";
        var sound:String = "";

        if (diff != 0)
        {
            if (diff > 0)
            {
                prefix = "+";
                _color = "2BFF31";
                sound = "fav";
            }
            else
            {
                _color = "FF4C50";
                sound = "unfav";
            }
        }

        jewelDiffText.localX = jewelText.localX - (jewelText.width / 2) - 10;
        jewelDiffText.localY = 40;
        jewelDiffText.text = '<b><c=$_color>$prefix$diff</c></b>';
        FlxTween.tween(jewelDiffText, { localY: 60 }, 4, { ease: FlxEase.circOut });
        FlxTween.tween(jewelDiffText, { localAlpha: 1 }, 0.2, { ease: FlxEase.cubeOut });
        FlxTween.tween(jewelDiffText, { localAlpha: 0 }, 1, { startDelay: 3, ease: FlxEase.cubeOut });
        if (sound != "") FunkinSound.playOnce(Paths.sound(sound));

        setDisplay(null, null, currentBGAlpha);
    }
}