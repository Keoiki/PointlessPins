package funkbucks.dialog.shop.april;

import funkbucks.FunkBucks;
import funkbucks.Shop;
import funkbucks.dialog.DialogBase;
import funkin.audio.FunkinSound;

class AprilIntro extends DialogBase
{
    var shop:Shop;

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

        var dialog:Dialogue = new Dialogue("april/intro");
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
            switch (dialogueIndex)
            {
                case 1: shop.shopkeeper.playAnimation('OnPhoneLookUp');
                case 2: shop.shopkeeper.playAnimation('ForwardLookUp');
                case 4: shop.shopkeeper.playAnimation('Normal');
                case 6: shop.shopkeeper.playAnimation('LookRightWorried');
                case 7: shop.shopkeeper.playAnimation('LookRight');
                case 8: shop.shopkeeper.playAnimation('LookRightUnamused');
            }
        });

        dialog.onTextEvent.add((event) ->
        {
            switch (event)
            {
                case 'worried': shop.shopkeeper.playAnimation('LookRightWorried');
            }
        });

        dialog.onSkipLine.add((index) ->
        {
            shop.shopkeeper.stopTalking();
        });

        dialog.onCompleteDialogue.add(() ->
        {
            shop.shopkeeper.playAnimation('Normal');
            finish();
        });

        shop.dialog = dialog;
        shop.add(dialog);
    }

    override function finish():Void
    {
        returnControlShop();
    }
}