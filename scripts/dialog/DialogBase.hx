package funkbucks.dialog;

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
}