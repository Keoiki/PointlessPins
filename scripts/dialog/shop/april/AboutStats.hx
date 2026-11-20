package funkbucks.dialog.shop.april;

import funkbucks.FunkBucks;
import funkbucks.Shop;
import funkbucks.FBUtil;
import funkbucks.dialog.DialogBase;
import funkin.audio.FunkinSound;

class AboutStats extends DialogBase
{
    var shop:Shop;
    static var dialogNum:Int = 0;

    override public function new():Void
    {
        super();
        shop = Shop.instance;
        start();
    }

    override function start():Void
    {
        if (shop.dialog != null) 
        {
            shop.remove(shop.dialog);
        }

        AboutStats.dialogNum = FBUtil.wrapAround(AboutStats.dialogNum + 1, 1, 1);

        var dialog:Dialogue = new Dialogue('converse/april/stats${AboutStats.dialogNum}');
        dialog.cameras = [shop.cameraHUD];

        dialog.dialogueText.letterCallback = (code) ->
        {
            if (FunkBucks.skipTalking.contains(code)) return;
            if (!shouldTalk) return;
            if (playSound) FunkinSound.playOnce(Paths.sound(dialogueSound + FlxG.random.int(dialogueSoundRange[0], dialogueSoundRange[1])), 1.0);
            if (playAnim) shop.shopkeeper.talk();
        }

        dialog.onNextLine.add((dialogueIndex, dialogueText) ->
        {
            switch (AboutStats.dialogNum)
            {
                case 1:
                    switch (dialogueIndex)
                    {
                    }
            }
        });

        dialog.onSkipLine.add((index) ->
        {
            shop.shopkeeper.stopTalking();
        });

        dialog.onCompleteDialogue.add(() ->
        {
            finish();
        });

        shop.dialog = dialog;
        shop.add(dialog);
    }

    override function finish():Void
    {
        new ConverseApril('stats');
    }
}