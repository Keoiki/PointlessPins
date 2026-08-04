package funkbucks.dialog;

import funkbucks.Shop;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

/**
 * fucked up base class
 */
class DialogBase
{
    /**
     * 2-in-1 for the two variables below.
     */
    var shouldTalk:Bool = true;

    /**
     * Should the person speaking not play their talking animation.
     */
    var playAnim:Bool = true;

    /**
     * Should the person speaking not play their sound.
     */
    var playSound:Bool = true;

    var overrideAnim:Null<String> = null;

    /**
     * calling start() here does nothing, presumably it's calling the empty start of this class and not the overriden ones in the subclasses, Ugh 2
     * so now I have to call start() manually in the subclass constructors
     */
    function new():Void { }

    /**
     * What happens when the dialogue starts. Includes the dialog object creation and other stuff depending on the dialogue.
     */
    function start():Void { }

    /**
     * What happens when the dialogue ends. Clean up, restore controls, etc.
     */
    function finish():Void { }

    /**
     * Default function to call in `finish()` to return controls back in the shop.
     */
    function returnControlShop():Void
    {
        final shop:Shop = Shop.instance;

        // Short timer to stop you from accidentally tapping on the Shopkeeper when choosing a response that would simply close a dialogue box.
        // (That would cause the Converse option to active immediately after ._.)
        new FlxTimer().start(0.25, function(_:FlxTimer)
        {
            shop.disallowInputs = false;    
        });

        FlxTween.tween(shop.camera, { zoom: shop.savedCamZoom }, 1, { ease: FlxEase.cubeOut });

        shop.showMenuItems(true);
        shop.toggleDisplayBucks(true);
        shop.toggleDisplayJewels(true);
    }
}