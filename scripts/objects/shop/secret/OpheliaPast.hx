package funkbucks.objects.shop.secret;

import funkin.graphics.FunkinSprite;
import funkin.util.TouchUtil;
import funkbucks.FunkBucks;
import funkbucks.Shop;
import flixel.util.FlxTimer;
using StringTools;

class OpheliaPast extends FunkinSprite
{
    var shop:Shop;

    override function new(x:Float, y:Float):Void
    {
        super(x, y, 'shop/old/opheliaPast',
        {
            applyStageMatrix: true,
            swfMode: true
        });

        shop = Shop.instance;

        // Manually size the hitbox because otherwise its HUGE
        setSize(340, 720);

        playAnimation("Idle", true);
    }

    function playAnimation(name:String, looped:Bool = false, forced:Bool = false):Void
    {
        animation.play(name, forced);
        animation.curAnim.looped = looped;
    }

    override function update(elapsed:Float)
    {
        if (TouchUtil.pressAction(super, super.camera) && !shop.disallowInputs && !FunkBucks.isMouseTooFast)
        {
            if (shop.dialog != null)
            {
                shop.remove(shop.dialog);
            }

            shop.disallowInputs = true;
            final dialogueYPos = shop.cameraFollowPoint.y > 330 ? 500 : 32;

            final possibleText:Array<String> =
            [
                "(It's Ophelia.<d=0.25/>.<d=0.5/>.<d=0.75/> but something seems different.)",
                "(She's busy on the phone.)",
                "(She appears to be waiting for someone.)",
                "(She's purposefully ignoring you.)",
                "(Best not to bother her.)",
                "..."
            ];
            var chosenText:String = possibleText[FlxG.random.int(0, possibleText.length - 1)];
            if (FlxG.random.bool(1)) chosenText = "(It's an illusionary replica of what\nOphelia was like 20 years ago...)";

            final dialogue:FBDialogueFile =
            {
                canSkipOnRepeat: true,
                dialogue:
                [
                    {
                        text: chosenText,
                        canSkip: false,
                        boxPreset: "default",
                        yPos: dialogueYPos
                    }
                ]
            };

            var dialog:Dialogue = new Dialogue("opheliaPastSecret", dialogue);
            dialog.cameras = [shop.cameraHUD];

            dialog.onCompleteDialogue.add(() ->
            {
                new FlxTimer().start(0.25, function(_:FlxTimer)
                {
                    shop.disallowInputs = false;    
                });
            });

            shop.dialog = dialog;
            shop.add(dialog);
        }

        super.update(elapsed);
    }
}