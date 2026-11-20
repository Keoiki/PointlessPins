package funkbucks.dialog.shop.april;

import funkbucks.FunkBucks;
import funkbucks.Shop;
import funkbucks.FBUtil;
import funkbucks.dialog.DialogBase;
import funkin.audio.FunkinSound;

class AboutPins extends DialogBase
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

        AboutPins.dialogNum = FBUtil.wrapAround(AboutPins.dialogNum + 1, 1, 3);
        if (FlxG.random.bool(0.5)) AboutPins.dialogNum = 99;

        var dialog:Dialogue = new Dialogue('converse/april/pins${AboutPins.dialogNum}');
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
            switch (AboutPins.dialogNum)
            {
                case 1:
                    switch (dialogueIndex)
                    {
                    }
                case 2:
                    switch (dialogueIndex)
                    {
                        case 0:
                            shop.iconPins.alpha = 1;
                            shop.iconBoxes.alpha = 1;
                            shop.cameraFollowPoint.setPosition(shop.iconPins.x + shop.iconPins.width / 2, shop.iconPins.y + 45);
                        case 4:
                            shop.cameraFollowPoint.setPosition(shop.shopkeeperHitbox.x + shop.shopkeeperHitbox.width / 2, shop.shopkeeperHitbox.y + 115);
                        case 5:
                            shop.iconPins.alpha = 0;
                            shop.iconBoxes.alpha = 0;

                    }
                case 3:
                    switch (dialogueIndex)
                    {
                    }
                case 99:
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
        new ConverseApril('pins');
    }
}