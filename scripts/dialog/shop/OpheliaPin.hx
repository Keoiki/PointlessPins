package funkbucks.dialog.shop;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkbucks.FunkBucks;
import funkbucks.PinUnlockState;
import funkbucks.Shop;
import funkbucks.dialog.DialogBase;
import funkin.audio.FunkinSound;

class OpheliaPin extends DialogBase
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

        var dialog:PinDialogue = new PinDialogue("opheliaPin");
        dialog.cameras = [shop.cameraHUD];

        dialog.dialogueText.letterCallback = (code) ->
        {
            if (FunkBucks.skipTalking.contains(code)) return;
            if (!shouldTalk) return;
            if (playSound) FunkinSound.playOnce(Paths.sound("chartingSounds/keyboard" + FlxG.random.int(1, 3)), 1.0);
            if (playAnim) shop.shopkeeper.playAnimation('Talk', false, false);
        }

        dialog.onTextEvent.add((event) ->
        {
            switch (event)
            {
                case "tt": shouldTalk = !shouldTalk;
                case "ta": playAnim = !playAnim;
                case "ts": playSound = !playSound;
            }
        });

        dialog.onDialogueResponse.add((response) ->
        {
            shop.remove(shop.dialog);
            switch (response)
            {
                case "yes":
                    givePin();
                case "no":
                    responseNo();
            }
        });

        shop.dialog = dialog;
        shop.add(dialog);
    }

    function givePin():Void
    {
        shop.shopkeeper.playAnimation("PickingPin", false, true);
        FlxTween.tween(shop.cameraFollowPoint, { x: shop.cameraFollowPoint.x - 50, y: shop.cameraFollowPoint.y + 25 }, 2, { ease: FlxEase.cubeOut });

        var substate = new PinUnlockState(FunkBucks.getPinByID("ophelia"));
        substate.cameras = [shop.cameraSubState];
        substate.closeCallback = finish;

        new FlxTimer().start(68 / 24, (_:FlxTimer) -> {
            FlxTween.tween(shop.cameraFollowPoint, { x: shop.cameraFollowPoint.x - 100, y: shop.cameraFollowPoint.y + 50 }, 14 / 24, { ease: FlxEase.cubeOut });
        });
        new FlxTimer().start(84 / 24, (_:FlxTimer) -> {
            shop.openSubState(substate);
            FlxTween.tween(shop.camera, { zoom: 1.25 }, 1, { ease: FlxEase.cubeOut });
            shop.shopkeeper.playAnimation("Idle", true, true);
        });
    }

    function responseNo():Void
    {
        if (shop.dialog != null)
        {
            shop.remove(shop.dialog);
        }

        final dialogue:PinDialogueFile =
        {
            dialogue:
            [
                {
                    text: "...",
                    speaker: "Ophelia",
                    canSkip: false
                }
            ]
        };

        shop.shopkeeper.playAnimation('IdleAnnoyed', true, false);

        var dialog:PinDialogue = new PinDialogue("opheliaPin-noResponse", dialogue);
        dialog.cameras = [shop.cameraHUD];

        dialog.onCompleteDialogue.add(() ->
        {
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