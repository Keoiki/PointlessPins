package funkbucks.objects.ui;

import balphabet.BAlphabet;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.graphics.FunkinSprite;
import funkin.group.FunkinGroup;

class TimedCoinsHUD extends FunkinGroup
{
    var background:FunkinSprite;
    public var counter:BAlphabet;
    public var timer:BAlphabet;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        background = new FunkinSprite(0, 0);
        background.frames = FlxG.bitmap.create(450, 350, 0xFF000000, true, 'timedEventBackground').imageFrame;
        background.localX = -100;
        background.localY = -90;
        background.scrollFactor.set(0, 0);
        background.zIndex = 1;
        this.add(background);

        counter = new BAlphabet(0, 0, '${FBIcon.Clover}× <b><c=2BFF31>0</c> / <c=2BFF31>8</c></b>');
        counter.setScrollFactor(0, 0);
        counter.localScale.set(0.8, 0.8);
        counter.zIndex = 2;
        this.add(counter);

        timer = new BAlphabet(0, 0, "<c=2BFF31><b><s=0.5>TIME</s>\n<m>00:00:00</b></c></m>");
        timer.localX = 0;
        timer.localY = 60;
        timer.setScrollFactor(0, 0);
        timer.localScale.set(0.8, 0.8);
        timer.zIndex = 3;
        this.add(timer);

        background.localAlpha = 0.0;
        for (letter in counter.letters)
        {
            letter.localAlpha = 0.0;
        }
        timer.localAlpha = 0.0;
    }

    public function update(elapsed:Float)
    {
        if (TimedCoinsManager.running)
        {
            var timeRemaining:String = "";
            var minutes:Int = Math.floor(TimedCoinsManager.time / 60);
            timeRemaining += '<c=FFB51C>${(minutes < 10 ? "0" + minutes : minutes)}</c>:';
            var seconds:Int = Math.floor(TimedCoinsManager.time % 60);
            timeRemaining += '<c=FFB51C>${(seconds < 10 ? "0" + seconds : seconds)}</c>.';
            timeRemaining += '<c=FFB51C>${Math.floor(TimedCoinsManager.time % 1 * 100 / 10)}</c>';
            timer.text = "<c=FFB51C><b><s=0.65>TIME</s></c>\n<m>" + timeRemaining + "</b></m>";
        }

        super.update(elapsed);
    }

    public function doIntro():Void
    {
        FlxTween.tween(background, { localY: background.localY + 30, localAlpha: 0.8 }, 0.5, { ease: FlxEase.quartOut });
        var i:Int = 0;
        for (letter in counter.letters)
        {
            letter.localY -= 20;
            FlxTween.tween(letter, { localY: letter.localY + 20, localAlpha: 1.0 }, 0.5, { ease: FlxEase.quartOut, startDelay: i * 0.1 });
            i++;
        }
        FlxTween.tween(timer, { localAlpha: 1.0 }, 0.5, { ease: FlxEase.quartOut });
    }

    public function updateCounter(count:Int = 0):Void
    {
        counter.text = '${FBIcon.Clover}× <b><c=2BFF31>$count</c> / <c=2BFF31>8</c></b>';
    }
}