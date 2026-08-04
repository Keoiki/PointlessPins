package funkbucks.dialog.shop.ophelia;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkbucks.FunkBucks;
import funkbucks.PinUnlockState;
import funkbucks.Shop;
import funkbucks.Shopkeeper;
import funkbucks.dialog.DialogBase;
import funkbucks.dialog.shop.OpheliaPin;
import funkin.audio.FunkinSound;

class ConverseOphelia extends DialogBase
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

        final dialogue:PinDialogueFile =
        {
            dialogue:
            [
                {
                    text: "What do you wanna know?",
                    speaker: "Ophelia"
                }
            ],
            response:
            {
                options: getDialogueOptions()
            }
        };

        var dialog:PinDialogue = new PinDialogue("converseOphelia", dialogue);
        dialog.cameras = [shop.cameraHUD];

        dialog.dialogueText.letterCallback = (code) ->
        {
            if (FunkBucks.skipTalking.contains(code)) return;
            if (!shouldTalk) return;
            if (playSound) FunkinSound.playOnce(Paths.sound("chartingSounds/keyboard" + FlxG.random.int(1, 3)), 1.0);
            if (playAnim) shop.shopkeeper.playAnimation('Talk', false, false);
        }

        dialog.onDialogueResponse.add((response) ->
        {
            shop.remove(shop.dialog);
            if (response != "close") Shopkeeper.annoyance--;
            switch (response)
            {
                case "close":
                    Shopkeeper.annoyance++;
                    if (Shopkeeper.annoyance == 10)
                    {
                        annoyedDialogue();
                    }
                    else if (Shopkeeper.annoyance == 20)
                    {
                        new OpheliaPin();
                    }
                    else if (Shopkeeper.annoyance >= 30 && Shopkeeper.annoyance % 10 == 0)
                    {
                        finish();
                    }
                    else
                    {
                        finish();
                    }
            }
        });

        shop.dialog = dialog;
        shop.add(dialog);
    }

    function getDialogueOptions():Array<Array<String>>
    {
        var options:Array<Array<String>> = [];

        options.push(['Nothing!', 'close']);

        if (Tuntematon.gone && !Shopkeeper.caught)
        {
            options.push(['Hand behind shelf', 'ebgquwwghobehjovbefogbeqir']);
        }

        if (FunkBucks.getEvent("exchangeUnlocked") != 1)
        {
            if (FunkBucks.getBlueJewels() > 0 || FunkBucks.getBlueJewelsLifetime() > 0)
            {
                options.push(['Exchange?', 'unlockExchange']);
            }
            else
            {
                options.push(['Exchange?', 'lockedExchange']);
            }
        }
        else
        {
            options.push(['${FBIcon.Jewel} <c=82E9FF>Exchange</c>', 'openExchange']);
        }

        if (FunkBucks.getEvent("hasMetApril") == 1)
        {
            options.push(['About <c=EA8645>April</c>', 'aboutApril']);
        }

        if (FunkBucks.getOpheliaAnger() == 0)
        {
            options.push(['About yourself', 'aboutOphelia']);
        }

        options.push(['${FBIcon.Buck} FunkBucks', 'funkbucks']);
        options.push(['${FBIcon.Jewel} Melody Stones', 'melodyStones']);
        options.push(['Pins', 'pins']);
        options.push(['Boxes', 'boxes']);
        options.push(['Rewards', 'rewards']);
        options.push(['Daily Songs', 'dailysongs']);

        return options;
    }

    function annoyedDialogue():Void
    {
        if (shop.dialog != null)
        {
            shop.remove(shop.dialog);
        }

        shop.shopkeeper.suffix = "Confused";

        var dialog:PinDialogue = new PinDialogue("anger/warning");
        dialog.cameras = [shop.cameraHUD];

        dialog.dialogueText.letterCallback = (code) ->
        {
            if (FunkBucks.skipTalking.contains(code)) return;
            if (!shouldTalk) return;
            if (playSound) FunkinSound.playOnce(Paths.sound("chartingSounds/keyboard" + FlxG.random.int(1, 3)), 1.0);
            if (playAnim) shop.shopkeeper.playAnimation('Talk', false, false);
        }

        dialog.onCompleteDialogue.add(() ->
        {
            shop.shopkeeper.suffix = "";
            shop.shopkeeper.playAnimation('Idle', true, false);
            finish();
        });

        shop.dialog = dialog;
        shop.add(dialog);
    }

    override function finish():Void
    {
        shop.disallowInputs = false;
        shop.showMenuItems(true);
        FlxTween.tween(shop.camera, { zoom: shop.savedCamZoom }, 1, { ease: FlxEase.cubeOut });
        FlxTween.tween(shop.funkBucksText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
        FlxTween.tween(shop.blueJewelsText, { alpha: 1 }, 1, { ease: FlxEase.cubeOut });
    }
}