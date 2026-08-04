package funkbucks.objects.shop;

import Date;
import funkin.graphics.FunkinSprite;
import funkin.group.FunkinGroup;

class Clock extends FunkinGroup
{
    var clock:FunkinSprite;
    var handHour:FunkinSprite;
    var handMinute:FunkinSprite;

    override function new(x:Float, y:Float):Void
    {
        super(x, y);
        this.createClock();
    }

    function createClock()
    {
        clock = new FunkinSprite(0, 0).loadTexture("shop/clock");
        clock.zIndex = 1;
        clock.scrollFactor.set(0.85, 0.85);
        this.add(clock);

        handHour = new FunkinSprite(0, 0).loadTexture("shop/clockHandHour");
        handHour.scrollFactor.set(0.85, 0.85);
        handHour.zIndex = 2;
        handHour.origin.y = handHour.height;
        handHour.localX = 68;
        handHour.localY = 45;
        this.add(handHour);

        handMinute = new FunkinSprite(0, 0).loadTexture("shop/clockHandMinute");
        handMinute.scrollFactor.set(0.85, 0.85);
        handMinute.zIndex = 3;
        handMinute.origin.y = handMinute.height;
        handMinute.localX = 68;
        handMinute.localY = 20;
        this.add(handMinute);
    }

    override function update(elapsed:Float)
    {
        var time:Date = Date.now();
        handHour.localAngle = (time.getHours() + time.getMinutes() / 60) / 12 * 360;
        handMinute.localAngle = (time.getMinutes() + time.getSeconds() / 60) / 60 * 360;

        super.update(elapsed);
    }
}