package funkbucks.dialog.shop.april;

import funkbucks.FunkBucks;
import funkbucks.Shop;
import funkbucks.dialog.DialogBase;
import funkin.audio.FunkinSound;

class ConverseApril extends DialogBase
{
    var shop:Shop;
    static var timesNothinged:Int = 0;

    override public function new(?autoStart:Null<String>):Void
    {
        super();
        shop = Shop.instance;
        start(autoStart);
    }

    override function start(?autoStart:Null<String>):Void
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

        if (autoStart != null)
        {
            shouldTalk = false;
            dialog.doNextLine();
            for (index => entry in getDialogueOptions())
            {
                if (entry[1] == autoStart)
                {
                    dialog.changeResponse(index);
                    break;
                }
            }
        }

        dialog.dialogueText.letterCallback = (code) ->
        {
            if (FunkBucks.skipTalking.contains(code)) return;
            if (!shouldTalk) return;
            if (playSound) FunkinSound.playOnce(Paths.sound(dialogueSound + FlxG.random.int(dialogueSoundRange[0], dialogueSoundRange[1])), 1.0);
            if (playAnim) shop.shopkeeper.talk();
        }

        dialog.onSkipLine.add((index) ->
        {
            shop.shopkeeper.stopTalking();
        });

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
                case 'exchange': new ExchangeApril();
                case 'aboutYourself': new YourselfApril();
                case 'aboutOphelia': new AboutOphelia();
                case 'funkbucks': new AboutFunkBucks();
                case 'melodyStones': new AboutMelodyStones();
                case 'pins': new AboutPins();
                case 'boxes': new AboutBoxes();
                case 'awards': new AboutAwards();
                case 'stats': new AboutStats();
                case 'endlessMode': new AboutEndlessMode();
                default: finish();
            }
        });

        shop.shopkeeper.playAnimation('normal', true, true);
        shop.dialog = dialog;
        shop.add(dialog);
    }

    function getDialogueOptions():Array<Array<String>>
    {
        var options:Array<Array<String>> = [];

        options.push(['Nothing!', 'close']);

        if (FunkBucks.getBlueJewels() > 0 || FunkBucks.getBlueJewelsLifetime() > 0)
        {
            options.push(['${FBIcon.Jewel} <c=82E9FF>Exchange</c>', 'exchange']);
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
        options.push(['Awards', 'awards']);
        options.push(['Stats', 'stats']);

        // Not finished for 2.0.
        // options.push(['${FBIcon.Clover} Clover Coins', 'cloverCoins']);

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
            shop.shopkeeper.playAnimation('normal');
            finish();
        });

        shop.dialog = dialog;
        shop.add(dialog);
    }

    override function finish():Void
    {
        shop.shopkeeper.playAnimation('normal', true, true);
        returnControlShop();
    }
}