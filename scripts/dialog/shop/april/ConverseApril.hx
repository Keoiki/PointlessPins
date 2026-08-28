package funkbucks.dialog.shop.april;

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

class ConverseApril extends DialogBase
{
    var shop:Shop;
    static var timesNothinged:Int = 0;

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

        final dialogue:FBDialogueFile =
        {
            dialogue:
            [
                {
                    text: "What do you want?",
                    speaker: "April"
                }
            ],
            response:
            {
                options: getDialogueOptions()
            }
        };

        var dialog:Dialogue = new Dialogue("converseApril", dialogue);
        dialog.cameras = [shop.cameraHUD];

        dialog.dialogueText.letterCallback = (code) ->
        {
            if (FunkBucks.skipTalking.contains(code)) return;
            if (!shouldTalk) return;
            if (playSound) FunkinSound.playOnce(Paths.sound(dialogueSound + FlxG.random.int(dialogueSoundRange[0], dialogueSoundRange[1])), 1.0);
            if (playAnim) shop.shopkeeper.talk();
        }

        dialog.onDialogueResponse.add((response) ->
        {
            shop.remove(shop.dialog);
            if (response != 'close') ConverseApril.timesNothinged = 0;
            switch (response)
            {
                case 'close':
                    ConverseApril.timesNothinged++;
                    if (ConverseApril.timesNothinged >= 10)
                    {
                        annoyedDialogue();
                    }
                    else
                    {
                        finish();
                    }
                default: finish();
            }
        });

        shop.shopkeeper.playAnimation('Normal');
        shop.dialog = dialog;
        shop.add(dialog);
    }

    function getDialogueOptions():Array<Array<String>>
    {
        var options:Array<Array<String>> = [];

        options.push(['Nothing!', 'close']);

        if (FunkBucks.getBlueJewels() > 0 || FunkBucks.getBlueJewelsLifetime() > 0)
        {
            options.push(['${FBIcon.Jewel} <c=82E9FF>Exchange</c>', 'openExchange']);
        }

        options.push(['About yourself', 'aboutYourself']);
        options.push(['About <c=67B1D8>Ophelia</c>', 'aboutOphelia']);
        options.push(['${FBIcon.Buck} FunkBucks', 'funkbucks']);

        if (FunkBucks.getBlueJewels() > 0 || FunkBucks.getBlueJewelsLifetime() > 0)
        {
            options.push(['${FBIcon.Jewel} Melody Stones', 'melodyStones']);
        }

        options.push(['Pins', 'pins']);
        options.push(['Boxes', 'boxes']);
        options.push(['Rewards', 'rewards']);
        options.push(['${FBIcon.Clover} Clover Coins', 'cloverCoins']);

        #if keoiki.endlessmode
        options.push(['<c=00BBFF>∞</c> Endless Mode <c=00BBFF>∞</c>', 'endlessMode']);
        #end

        return options;
    }

    function annoyedDialogue():Void
    {
        if (shop.dialog != null)
        {
            shop.remove(shop.dialog);
        }

        var dialog:Dialogue = new Dialogue("converse/april/annoyed");
        dialog.cameras = [shop.cameraHUD];

        dialog.dialogueText.letterCallback = (code) ->
        {
            if (FunkBucks.skipTalking.contains(code)) return;
            if (!shouldTalk) return;
            if (playSound) FunkinSound.playOnce(Paths.sound(dialogueSound + FlxG.random.int(dialogueSoundRange[0], dialogueSoundRange[1])), 1.0);
            if (playAnim) shop.shopkeeper.talk();
        }

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