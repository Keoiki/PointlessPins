package funkbucks.dialog.shop.april;

import funkbucks.FunkBucks;
import funkbucks.PinUnlockState;
import funkbucks.Shop;
import funkbucks.dialog.DialogBase;
import funkin.audio.FunkinSound;

class ExchangeApril extends DialogBase
{
    var shop:Shop;

    /**
     * -1 = Intro.
     * 
     * 0 = All bought.
     * 
     * Other = The pin to be bought, in order from `FunkBucks.aprilPinOrder`
     */
    var pinOrder:Int = 0;

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

        var dialogueToLoad:String = "exchangeInitial";
        if (FunkBucks.hasSeenDialogue("converse/april/exchangeInitial"))
        {
            for (index => entry in FunkBucks.aprilPinOrder)
            {
                if (!FunkBucks.hasPin(entry[index][0]))
                {
                    dialogueToLoad = 'exchange${index + 1}';
                    pinOrder = index + 1;
                    break;
                }
            }

            // If pinOrder remains 0, that should mean all pins have already been bought.
            if (pinOrder == 0)
            {
                dialogueToLoad = "exchangeEnd";
            }
        }
        else
        {
            pinOrder = -1;
        }

        var dialog:Dialogue = new Dialogue('converse/april/$dialogueToLoad');
        dialog.cameras = [shop.cameraHUD];

        dialog.dialogueText.letterCallback = (code) ->
        {
            if (pinOrder == 3 && dialog.dialogueIndex == 3) dialog.dialogueText.speed -= 0.005;
            if (FunkBucks.skipTalking.contains(code)) return;
            if (!shouldTalk) return;
            if (playSound) FunkinSound.playOnce(Paths.sound(dialogueSound + FlxG.random.int(dialogueSoundRange[0], dialogueSoundRange[1])), 1.0);
            if (playAnim) shop.shopkeeper.talk();
        }

        dialog.onNextLine.add((dialogueIndex, dialogueText) ->
        {
            switch (pinOrder)
            {
                case -1:
                case 0:
                case 1:
                    switch (dialogueIndex)
                    {
                        case 2: shop.shopkeeper.playAnimation('normalHandOpenUp');
                    }
                case 2:
                case 3:
            }
        });

        dialog.onSkipLine.add((index) ->
        {
            shop.shopkeeper.stopTalking();
        });

        dialog.onCompleteDialogue.add(() ->
        {
            switch (pinOrder)
            {
                case -1: // Immediately start the first pin dialog.
                    start();
                case 0: // End normally.
                    new ConverseApril("exchange");
                default: // Nothing, the PinUnlockState closing will handle it.
            }
        });

        if (pinOrder > 0)
        {
            FunkBucks.moneyHUD.setDisplay(false, true);
        }

        shop.dialog = dialog;
        shop.add(dialog);
    }

    override function finish():Void
    {
        returnControlShop();
    }
}