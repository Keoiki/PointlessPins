package funkbucks.dialog.shop.april;

import funkbucks.FunkBucks;
import funkbucks.Shop;
import funkbucks.FBUtil;
import funkbucks.dialog.DialogBase;
import funkin.audio.FunkinSound;

class YourselfApril extends DialogBase
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

        YourselfApril.dialogNum = FBUtil.wrapAround(YourselfApril.dialogNum + 1, 1, 2);

        var dialog:Dialogue = new Dialogue('converse/april/aboutYourself${YourselfApril.dialogNum}');
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
            switch (YourselfApril.dialogNum)
            {
                case 1:
                    switch (dialogueIndex)
                    {
                        case 2: shop.shopkeeper.playAnimSwap(null, 'sideRight');
                        case 4: shop.shopkeeper.playAnimSwap(null, 'sideUpLeft');
                        case 5: // shop.shopkeeper.playAnimation('Smirk');
                    }
                case 2:
                    switch (dialogueIndex)
                    {
                        case 1: shop.shopkeeper.playAnimSwap(null, 'sideRight');
                        case 4: shop.shopkeeper.playAnimSwap(null, 'sideRightAwkward');
                        case 5: shop.shopkeeper.playAnimSwap(null, 'side');
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
        shop.shopkeeper.playAnimSwap('normal', 'side', 'normal');
        new ConverseApril('aboutYourself');
    }
}