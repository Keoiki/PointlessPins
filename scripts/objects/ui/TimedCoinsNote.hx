package funkbucks.objects.ui;

import balphabet.BAlphabet;
import funkin.graphics.FunkinSprite;
import funkin.group.FunkinGroup;

class TimedCoinsNote extends FunkinGroup
{
    public var note:FunkinSprite;
    public var text:BAlphabet;

    public function new(x:Float, y:Float):Void
    {
        super(x, y);
    }
}