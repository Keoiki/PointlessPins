package funkbucks.objects;

import balphabet.BAlphabet;
import balphabet.BAlphabetTyped;
import flixel.util.FlxSignal;
import flixel.util._FlxSignal.FlxSignal1;
import flixel.util._FlxSignal.FlxSignal2;
import funkbucks.FunkBucks;
import funkin.PlayerSettings;
import funkin.graphics.FunkinSprite;
import funkin.group.FunkinGroup;
import funkin.util.SerializerUtil;
import funkin.util.TouchUtil;

typedef PinDialogueLine =
{
    text:String, // The text to be displayed.
    ?speaker:String, // The name of the speaker. The text and box extension will be hidden if omitted. (optional)
    ?speed:Float, // The speed of the text typing. (optional, default: 0.05)
    ?letterStep:Int, // The amount of letters to display each writing step. (optional, default: 1)
    ?canSkip:Bool, // Whether the line can be skipped. (optional, default: true)
    ?instantComplete:Bool, // Whether to instantly complete the line. Ignored if the line is delayed. (optional, default: false)
    ?delayLine:Bool, // Whether to delay the line. The line will not start until it's manually triggered. (optional, default: false)
    ?hideDuringDelay:Bool, // If delayed, should the dialogue UI be hidden? (optional, default: false)
    ?boxY:Float // The Y level of the dialogue. (optional, default: ???)
}

class PinDialogue extends FunkinGroup
{
    var currentDialogue:Array<PinDialogueLine>;

    public var dialogueID:String = "";
    public var dialogueIndex:Int = -1;

    public var dialogueText:BAlphabetTyped;
    public var dialogueBox:FunkinSprite;
    public var speakerBox:FunkinSprite;
    public var speakerName:BAlphabet;
    var advanceIcon:FunkinSprite;
    
    public var onNextLine:FlxSignal2 = new FlxSignal2();
    public var onSkipLine:FlxSignal1 = new FlxSignal1();
    public var onTextEvent:FlxSignal1 = new FlxSignal1();
    public var onCompleteLine:FlxSignal1 = new FlxSignal1();
    public var onCompleteDialogue:FlxSignal = new FlxSignal();

    public function new(dialogueID:String):Void
    {
        super();
        this.dialogueID = dialogueID;
        this.currentDialogue = SerializerUtil.fromJSON(Assets.getText('data/pointlesspins/dialogue/$dialogueID.json'));

        dialogueBox = new FunkinSprite(0, 0);
        dialogueBox.frames = FlxG.bitmap.create(FlxG.width, 128, 0xBF000000, false, 'pinDialogueMainBox').imageFrame;
        this.add(dialogueBox);

        dialogueText = new BAlphabetTyped(0, 0, "");
        dialogueText.localX = FlxG.width / 2;
        dialogueText.localY = 48;
        dialogueText.localScale.set(0.5, 0.5);
        dialogueText.alignment = "center";
        this.add(dialogueText);

        dialogueText.finishCallback = () ->
        {
            canSkip = true;
            onCompleteLine.dispatch(dialogueIndex);
        }

        dialogueText.eventCallback = (event) ->
        {
            // trace('Dispatching event $event');
            onTextEvent.dispatch(event);
        }

        speakerBox = new FunkinSprite(0, 0);
        speakerBox.localX = 24;
        speakerBox.localY = -16;
        speakerBox.frames = FlxG.bitmap.create(1, 16, 0xBF000000, false, 'pinDialogueSpeakerBox').imageFrame;
        speakerBox.origin.x = 0;
        this.add(speakerBox);

        speakerName = new BAlphabet(0, 0, "");
        speakerName.localX = 40;
        speakerName.localY = -8;
        speakerName.localScale.set(0.4, 0.4);
        this.add(speakerName);

        doNextLine();
    }

    var hasEnded:Bool = false;
    var canSkip:Bool = true;
    var isDelayed:Bool = false;
    var delayHidden:Bool = false;

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!hasEnded)
        {
            if (isDelayed)
            {
                if (delayHidden) this.visible = false;
                canSkip = false;
            }

            if ((PlayerSettings.player1.controls.CUTSCENE_ADVANCE || TouchUtil.pressAction()) && canSkip)
            {
                if (!dialogueText.finishedText)
                {
                    dialogueText.finish();
                    onSkipLine.dispatch(dialogueIndex);
                }
                else
                {
                    doNextLine();
                }
            }
        }
        else
        {
            this.kill();
            this.destroy();
        }
    }

    public function doNextLine():Void
    {
        var dialogueLine:PinDialogueLine = null;
        dialogueIndex++;
        if (dialogueIndex >= currentDialogue.length)
        {
            onCompleteDialogue.dispatch();
            hasEnded = true;
            return;
        }
        else
        {
            dialogueLine = currentDialogue[dialogueIndex];
        }

        dialogueLine.text ??= "I forgor.";
        dialogueLine.speaker ??= null;
        dialogueLine.speed ??= 0.05;
        dialogueLine.letterStep ??= 1;
        dialogueLine.canSkip ??= true;
        dialogueLine.instantComplete ??= false;
        dialogueLine.delayLine ??= false;
        dialogueLine.hideDuringDelay ??= false;
        dialogueLine.boxY ??= 32;

        if (dialogueLine.speaker?.toLowerCase() == "ophelia" && !FunkBucks.hasObtainedPin("ophelia"))
        {
            dialogueLine.speaker = null;
        }

        if (dialogueLine.speaker != null)
        {
            speakerName.text = dialogueLine.speaker;
            speakerName.localVisible = true;
            speakerBox.localVisible = true;
        }
        else
        {
            speakerBox.localVisible = false;
            speakerName.localVisible = false;
        }
        speakerBox.localScale.x = speakerName.width + 32;

        dialogueText.text = dialogueLine.text;
        dialogueText.speed = dialogueLine.speed;
        dialogueText.letterStep = dialogueLine.letterStep;
        canSkip = dialogueLine.canSkip;

        this.y = dialogueLine.boxY;
        this.visible = true;

        isDelayed = dialogueLine.delayLine;
        delayHidden = isDelayed && dialogueLine.hideDuringDelay;

        dialogueText.localY -= dialogueText.rows * 16;

        if (!isDelayed)
        {
            dialogueText.start();

            if (dialogueLine.instantComplete)
            {
                dialogueText.finish();
            }
        }
        else
        {
            dialogueText.localVisible = false;
        }

        onNextLine.dispatch(dialogueIndex, dialogueText);
    }

    public function startFromDelay():Void
    {
        if (!isDelayed) return;
        isDelayed = false;
        if (delayHidden) this.visible = true;
        dialogueText.localVisible = true;
        dialogueText.start();
    }
}