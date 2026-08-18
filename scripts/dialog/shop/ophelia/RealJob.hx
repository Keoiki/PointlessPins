package funkbucks.dialog.shop.ophelia;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkbucks.FunkBucks;
import funkbucks.PinUnlockState;
import funkbucks.Shop;
import funkbucks.dialog.DialogBase;
import funkin.audio.FunkinSound;

class RealJob extends DialogBase
{
    var shop:Shop;

    override function new():Void
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

        var dialog:Dialogue = new Dialogue("converse/ophelia/realJob");
        dialog.cameras = [shop.cameraHUD];

        shop.shopkeeper.suffix = "Annoyed";

        dialog.dialogueText.letterCallback = (code) ->
        {
            if (FunkBucks.skipTalking.contains(code)) return;
            if (!shouldTalk) return;
            if (playSound) FunkinSound.playOnce(Paths.sound("chartingSounds/keyboard" + FlxG.random.int(1, 3)), 1.0);
            if (playAnim) shop.shopkeeper.playAnimation('Talk', false, false);
        }

        dialog.onNextLine.add((dialogueIndex, dialogueText) ->
        {
            switch (dialogueIndex)
            {
                case 3: shop.shopkeeper.suffix = "Annoyed";
                case 4: shop.shopkeeper.suffix = "";
            }
        });

        dialog.onTextEvent.add((event) ->
        {
            switch (event)
            {
                case "tt": shouldTalk = !shouldTalk;
                case "ta": playAnim = !playAnim;
                case "ts": playSound = !playSound;
                case "animNormal": shop.shopkeeper.suffix = "";
                case "animAnnoyed": shop.shopkeeper.suffix = "Annoyed";
            }
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
        shop.shopkeeper.suffix = "";
        shop.shopkeeper.playAnimation('Idle', true, true);
        returnControlShop();
    }
}