package funkbucks.objects;

import balphabet.BAlphabet;
import balphabet.BAlphabetTyped;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSignal;
import flixel.util._FlxSignal.FlxSignal1;
import flixel.util._FlxSignal.FlxSignal2;
import flixel.util.FlxSpriteUtil;
// import flixel.util.FlxTimer;
import funkbucks.FunkBucks;
import funkbucks.shaders.ImposePatternShader;
import funkin.PlayerSettings;
import funkin.graphics.FunkinSprite;
import funkin.group.FunkinGroup;
import funkin.util.SerializerUtil;
import funkin.util.TouchUtil;

typedef PinDialogueFile =
{
    dialogue:Array<PinDialogueLine>,
    ?response:PinDialogueResponses,
    ?canSkipOnRepeat:Bool // Is dialogue skipable on repeat reads? (optional, default: false)
}

typedef PinDialogueLine =
{
    text:String, // The text to be displayed.
    ?speaker:String, // The name of the speaker. The text and box extension will be hidden if omitted. (optional)
    ?speed:Float, // The speed of the text typing. (optional, default: 0.05)
    ?letterStep:Int, // The amount of letters to display each writing step. (optional, default: 1)
    ?canSkip:Bool, // Whether the line can be skipped. (optional, default: true)
    ?cantSkipOnRepeat:Bool, // Whether the line can be skipped on repeat, in case you NEED to make a line unskipable. (optional, default: false)
    ?instantComplete:Bool, // Whether to instantly complete the line. Ignored if the line is delayed. (optional, default: false)
    ?delayLine:Bool, // Whether to delay the line. The line will not start until it's manually triggered. (optional, default: false)
    ?hideDuringDelay:Bool, // If delayed, should the dialogue UI be hidden? (optional, default: false)
    ?boxData:PinDialogueTextbox, // Data for the dialogue box. (optional)
    ?boxPreset:String, // The name of the dialogue box preset to use, instead of manually specifying the box data each time you change it. (optional, default: ophelia)
    ?xPos:String, // The X position of the dialogue, as a preset name (left, right, or center), unlike yPos. (optional, default: center)
    ?yPos:Float // The Y position of the dialogue. (optional, default: 32)
}

typedef PinDialogueTextbox = 
{
    ?shape:String, // The dialogue box shape. (optional, default: "round")
    ?shapeColor:String, // The color of the dialogue box shape. (optional, default: "FFFFFF")
    ?textColor:String, // The color of the text. (optional, default: "3B3939")
    ?pattern:String, // The pattern of the dialogue box. (optional, default: null)
    ?patternColor:String, // The color of the pattern. (optional, default: "FFFFFF")
    ?patternAngle:Float, // The angle of the pattern. (optional, default: -10)
    ?patternDirection:Array<Float>, // The direction of the pattern. (optional, default: [-0.1, -0.03])
    ?patternSpeed:Float, // The speed of the pattern. (optional, default: 0.3)
    ?patternBlend:Float // Whether to use the multiply blend on the pattern or not. (optional, default: 1 (true))
}

typedef PinDialogueResponses =
{
    options:Array<Array<String>>, // The options to be displayed.
    ?boxY:Float // The Y level of the response box, relative to the main box. (optional, default: 500)
}

class PinDialogue extends FunkinGroup
{
    public var currentDialogue:PinDialogueFile;
    public var dialogueLine:PinDialogueLine;

    public var dialogueID:String = "";
    public var dialogueIndex:Int = -1;
    public var responseIndex:Int = 0;

    public var dialogueText:BAlphabetTyped;
    public var dialogueBoxBG:FunkinSprite;
    public var dialogueBox:FunkinSprite;
    public var patternShader:ImposePatternShader;
    public var speakerBox:FunkinSprite;
    public var speakerName:BAlphabet;
    var advanceIcon:FunkinSprite;
    
    public var onNextLine:FlxSignal2 = new FlxSignal2();
    public var onSkipLine:FlxSignal1 = new FlxSignal1();
    public var onTextEvent:FlxSignal1 = new FlxSignal1();
    public var onCompleteLine:FlxSignal1 = new FlxSignal1();
    public var onCompleteDialogue:FlxSignal = new FlxSignal();
    public var onDialogueResponse:FlxSignal1 = new FlxSignal1();

    var arrowLeft:FunkinSprite;
    var arrowLeftHitbox:FlxObject;
    var arrowRight:FunkinSprite;
    var arrowRightHitbox:FlxObject;
    public var responseText:BAlphabet;
    var responseHitbox:FlxObject;
    var responseDots:Array<FunkinSprite> = [];

    public function new(dialogueID:String, ?dialogueObject:PinDialogueFile):Void
    {
        super();

        loadDialogue(dialogueID, dialogueObject);

        dialogueBoxBG = new FunkinSprite(0, 0).loadTexture("pointlesspins/dialogue/dialogue-round-bg");
        this.add(dialogueBoxBG);

        dialogueBox = new FunkinSprite(0, 0).loadTexture("pointlesspins/dialogue/dialogue-round");
        dialogueBox.localAlpha = 0.9;
        dialogueBox.localX = dialogueBoxBG.localX + 10;
        dialogueBox.localY = dialogueBoxBG.localY + 10;
        dialogueBox.color = 0xFF264967;
        this.add(dialogueBox);

        patternShader = new ImposePatternShader();
        // patternShader.setValues([dialogueBox.width, dialogueBox.height], Assets.getBitmapData(Paths.image("pointlesspins/dialogue/pattern-diamonds-alt")), 0xFF67B1D8, null, null, null);
        // dialogueBox.shader = patternShader;

        dialogueText = new BAlphabetTyped(0, 0, "");
        dialogueText.localX = dialogueBoxBG.width / 2;
        dialogueText.localY = 48;
        dialogueText.localScale.set(0.5, 0.5);
        dialogueText.alignment = "center";
        this.add(dialogueText);

        speakerBox = new FunkinSprite(0, 0);
        // speakerBox.localX = 24;
        // speakerBox.localY = -16;
        // speakerBox.frames = FlxG.bitmap.create(1, 16, 0xBF000000, false, 'pinDialogueSpeakerBox').imageFrame;
        // speakerBox.origin.x = 0;
        this.add(speakerBox);

        speakerName = new BAlphabet(0, 0, "");
        speakerName.localX = 24;
        speakerName.localY = 16;
        speakerName.localScale.set(0.5, 0.5);
        speakerName.alignment = "center";
        this.add(speakerName);

        advanceIcon = new FunkinSprite(0, 0);
        advanceIcon.loadSparrow("pointlesspins/dialogue/end-icons");
        advanceIcon.animation.addByPrefix("endIcons", "dialogue-end-icons", 0, false);
        advanceIcon.animation.play("endIcons");
        advanceIcon.localScale.set(0.8, 0.8);
        // advanceIcon.localVisible = false;
        this.add(advanceIcon);

        if (currentDialogue.response != null)
        {
            // trace(currentDialogue.response.options);

            arrowLeftHitbox = new FlxObject(0, 0, 200, 200);
            this.add(arrowLeftHitbox);

            arrowRightHitbox = new FlxObject(FlxG.width - 128, 0, 200, 200);
            this.add(arrowRightHitbox);

            arrowLeft = new FunkinSprite(0, 0).loadTexture("shop/boxarrow");
            arrowLeft.localX = arrowLeftHitbox.x + arrowLeftHitbox.width / 2 - arrowLeft.width / 2;
            arrowLeft.localY = arrowLeftHitbox.y + arrowLeftHitbox.height / 2 - arrowLeft.height / 2;
            arrowLeft.flipX = true;
            arrowLeft.localVisible = false;
            this.add(arrowLeft);

            arrowRight = new FunkinSprite(0, 0).loadTexture("shop/boxarrow");
            arrowRight.localX = arrowRightHitbox.x + arrowRightHitbox.width / 2 - arrowRight.width / 2;
            arrowRight.localY = arrowRightHitbox.y + arrowRightHitbox.height / 2 - arrowRight.height / 2;
            arrowRight.localVisible = false;
            this.add(arrowRight);

            arrowLeft.setColorTransform(0, 0, 0, 1, 255, 255, 255);
            arrowLeft.localScale.set(0.7, 0.45);
            arrowRight.setColorTransform(0, 0, 0, 1, 255, 255, 255);
            arrowRight.localScale.set(0.7, 0.45);

            responseText = new BAlphabet(0, 0, currentDialogue.response.options[0][0]);
            responseText.localScale.set(0.5, 0.5);
            responseText.alignment = "center";
            responseText.localVisible = false;
            this.add(responseText);

            responseHitbox = new FlxObject(0, 0, 400, 200);
            this.add(responseHitbox);

            final count:Int = currentDialogue.response.options.length;
            for (i in 0...count)
            {
                var dot:FunkinSprite = new FunkinSprite(0, 0).loadTexture("menucountdot");
                dot.localScale.set(0.75, 0.75);
                dot.localAlpha = 0.2;
                dot.localVisible = false;
                responseDots.push(dot);
                this.add(dot);
            }
        }

        dialogueText.finishCallback = () ->
        {
            canSkip = true;
            onCompleteLine.dispatch(dialogueIndex);

            advanceIcon.localVisible = true;
            if (dialogueIndex >= currentDialogue.dialogue.length - 1)
            {
                if (currentDialogue.response != null)
                {
                    advanceIcon.animation.curAnim.curFrame = 2;
                }
                else
                {
                    advanceIcon.animation.curAnim.curFrame = 1;
                }
            }
            else
            {
                advanceIcon.animation.curAnim.curFrame = 0;
            }
        }

        dialogueText.eventCallback = (event) ->
        {
            // trace('Dispatching event $event');
            onTextEvent.dispatch(event);
        }

        this.x = FlxG.width / 2 - dialogueBoxBG.width / 2;

        doNextLine();
    }

    var hasEnded:Bool = false;
    var canSkip:Bool = true;
    var isDelayed:Bool = false;
    var delayHidden:Bool = false;
    var isResponding:Bool = false;

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        patternShader.update(elapsed);
        if (!hasEnded)
        {
            if (isDelayed && !isResponding)
            {
                if (delayHidden) this.visible = false;
                canSkip = false;
            }

            if (isResponding)
            {
                if (PlayerSettings.player1.controls.UI_LEFT_P || TouchUtil.pressAction(arrowLeftHitbox, camera))
                {
                    changeResponse(-1);
                }
                else if (PlayerSettings.player1.controls.UI_RIGHT_P || TouchUtil.pressAction(arrowRightHitbox, camera))
                {
                    changeResponse(1);
                }
                else if (PlayerSettings.player1.controls.CUTSCENE_ADVANCE || TouchUtil.pressAction(responseHitbox, camera))
                {
                    onDialogueResponse.dispatch(currentDialogue.response.options[responseIndex][1]);
                }
            }
            else if ((PlayerSettings.player1.controls.CUTSCENE_ADVANCE || TouchUtil.pressAction()) && canSkip)
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
        dialogueIndex++;
        if (dialogueIndex >= currentDialogue.dialogue.length)
        {
            if (currentDialogue.response != null)
            {
                if (!dialogueText.finishedText)
                {
                    dialogueText.finish();
                    onSkipLine.dispatch(dialogueIndex);
                }
                showResponses();
            }
            else
            {
                endDialogue();
            }
            return;
        }
        else
        {
            dialogueLine = currentDialogue.dialogue[dialogueIndex];
        }

        dialogueLine.text ??= "I forgor.";
        dialogueLine.speaker ??= null;
        dialogueLine.speed ??= 0.05;
        dialogueLine.letterStep ??= 1;
        dialogueLine.canSkip ??= true;
        dialogueLine.instantComplete ??= false;
        dialogueLine.delayLine ??= false;
        dialogueLine.hideDuringDelay ??= false;
        dialogueLine.xPos ??= "center";
        dialogueLine.yPos ??= 32;
        dialogueLine.boxData ??= null;

        if (dialogueLine.boxData == null)
        {
            dialogueLine.boxPreset ??= "ophelia";
            dialogueLine.boxData = dialogueBoxPatternPreset(dialogueLine.boxPreset);
        }

        updateDialogueBox(dialogueLine.boxData);

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

        dialogueText.text = dialogueLine.text;
        dialogueText.speed = dialogueLine.speed;
        dialogueText.letterStep = dialogueLine.letterStep;
        canSkip = checkForSkippingDialogue();

        this.x = switch (xPos.toLowerCase())
        {
            case "left": return 64;
            case "right": return FlxG.width - 64 - dialogueBoxBG.width;
            default: return FlxG.width / 2 - dialogueBoxBG.width / 2;
        }
        this.y = dialogueLine.yPos;
        this.visible = true;

        isDelayed = dialogueLine.delayLine;
        delayHidden = isDelayed && dialogueLine.hideDuringDelay;

        dialogueText.localY = dialogueBox.localY + dialogueBox.height / 2 - (dialogueText.lineHeight / 2 * dialogueText.localScale.y) - (dialogueText.rows * 16);

        advanceIcon.localVisible = false;

        onNextLine.dispatch(dialogueIndex, dialogueText);

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

        updateChildren();
    }

    /**
     * I could've made dialogue skipping universally not possible on first reads, and universally possible on repeats.
     * 
     * but fuck it, I like doing it this way
     */
    function checkForSkippingDialogue():Bool
    {
        if (FunkBucks.hasSeenDialogue(dialogueID))
        {
            if (dialogueLine.cantSkipOnRepeat ?? false) return false;
            return (currentDialogue.canSkipOnRepeat ?? false) || dialogueLine.canSkip;
        }
        else
        {
            return dialogueLine.canSkip;
        }
    }

    public function startFromDelay():Void
    {
        if (!isDelayed) return;
        isDelayed = false;
        if (delayHidden) this.visible = true;
        dialogueText.localVisible = true;
        dialogueText.start();
        if (dialogueLine.instantComplete)
        {
            dialogueText.finish();
        }
    }

    public function endDialogue():Void
    {
        FunkBucks.addSeenDialogue(dialogueID);
        isResponding = false;
        onCompleteDialogue.dispatch();
        hasEnded = true;
    }

    public function loadDialogue(id:String, ?obj:PinDialogueFile):Void
    {
        dialogueID = id;
        if (obj != null)
        { 
            currentDialogue = obj;
        }
        else
        {
            var filePath:String = 'data/pointlesspins/dialogue/$id.json';
            // Dialogue with "dialogueFlavor" set to "nice" will be less meaner.
            if (!Preferences.naughtyness || FunkBucks.save.dialogueFlavor == "nice")
            {
                if (Assets.exists('data/pointlesspins/dialogue/$id-c.json'))
                {
                    filePath = 'data/pointlesspins/dialogue/$id-c.json';
                }
            }
            currentDialogue = SerializerUtil.fromJSON(Assets.getText(filePath));
        }
        dialogueIndex = -1;
        responseIndex = 0;
        isResponding = false;
    }

    public function showResponses():Void
    {
        isResponding = true;
        changeResponse(0);

        dialogueText.localY -= 40;
        dialogueText.localAlpha = 0.50;
        dialogueText.localScale.set(0.2, 0.2);
        speakerBox.localVisible = false;
        speakerName.localVisible = false;
        advanceIcon.localVisible = false;

        arrowLeftHitbox.setSize(dialogueBox.height, dialogueBox.height);
        arrowLeftHitbox.setPosition(this.x + 10, this.y + 10);
        arrowLeft.localX = dialogueBox.localX + arrowLeftHitbox.width / 2 - arrowLeft.width / 2;
        arrowLeft.localY = dialogueBox.localY + arrowLeftHitbox.height / 2 - arrowLeft.height / 2;
        arrowLeft.localVisible = true;

        arrowRightHitbox.setSize(dialogueBox.height, dialogueBox.height);
        arrowRightHitbox.setPosition(this.x + dialogueBox.width - 10 - arrowRightHitbox.width, this.y + 10);
        arrowRight.localX = dialogueBox.localX + dialogueBox.width - arrowRightHitbox.width / 2 - arrowRight.width / 2;
        arrowRight.localY = dialogueBox.localY + arrowRightHitbox.height / 2 - arrowRight.height / 2;
        arrowRight.localVisible = true;

        responseText.localVisible = true;
        responseHitbox.setSize(dialogueBox.width - arrowLeftHitbox.width - arrowRightHitbox.width, dialogueBox.height);
        responseHitbox.setPosition(arrowLeftHitbox.x + arrowLeftHitbox.width, arrowLeftHitbox.y);

        for (i in 0...responseDots.length)
        {
            responseDots[i].localVisible = true;
        }
    }

    public function changeResponse(change:Int = 0)
    {
        responseIndex += change;
        responseIndex = FlxMath.bound(responseIndex, 0, currentDialogue.response.options.length - 1);

        for (i in 0...responseDots.length)
        {
            responseDots[i].localAlpha = i == responseIndex ? 1 : 0.2;
        }

        responseText.text = currentDialogue.response.options[responseIndex][0];
        responseText.localY = dialogueBox.localY + dialogueBox.height / 2 - (responseText.lineHeight / 2.5 * responseText.localScale.y) - (responseText.rows * 16);

        arrowLeft.localAlpha = responseIndex != 0 ? 1 : 0.2;
        arrowRight.localAlpha = responseIndex != currentDialogue.response.options.length - 1 ? 1 : 0.2;
    }

    // Avoid unnescessary updates.
    var prevShape:String;
    var prevShapeColor:String;
    var prevTextColor:String;

    function updateDialogueBox(data:PinDialogueTextbox):Void
    {
        final basePath:String = "pointlesspins/dialogue/";

        if (data.shape != null && data.shape != prevShape)
        {
            if (!Assets.exists('images/${basePath}shape-${data.shape}-bg.png') || !Assets.exists('images/${basePath}shape-${data.shape}.png'))
            {
                data.shape = "round";
            }
            dialogueBoxBG.loadTexture('${basePath}shape-${data.shape}-bg');
            dialogueBoxBG.localX += 800 - dialogueBoxBG.width;
            dialogueBoxBG.localY += 200 - dialogueBoxBG.height;

            dialogueBox.loadTexture('${basePath}shape-${data.shape}');
            dialogueBox.localX = dialogueBoxBG.localX + 10;
            dialogueBox.localY = dialogueBoxBG.localY + 10;

            dialogueText.localX = dialogueBoxBG.width / 2;

            if (!Assets.exists('images/${basePath}speaker-${data.shape}.png'))
            {
                data.shape = "round";
            }
            speakerBox.loadTexture('${basePath}speaker-${data.shape}');
            speakerBox.localScale.set(0.9, 0.9);
            speakerBox.localX = 32;
            speakerBox.localY = -24;

            speakerName.localX = speakerBox.localX + speakerBox.width / 2;
            speakerName.localY = speakerBox.localY + speakerBox.height / 2 - (speakerName.lineHeight / 2.5 * speakerName.localScale.y);

            advanceIcon.localX = dialogueBox.localX + dialogueBox.width - 120;
            advanceIcon.localY = dialogueBox.localY + dialogueBox.height - 40;

            responseText?.localX = dialogueBoxBG.width / 2;
            responseText?.localY = dialogueBox.localY + dialogueBox.height / 2 - (responseText?.lineHeight / 2 * responseText?.localScale.y) - (responseText?.rows * 16);

            for (i in 0...responseDots.length)
            {
                var dot:FunkinSprite = responseDots[i];
                dot.localX = 10 + dialogueBox.width / 2 + 30 * i - 15 * responseDots.length + 10;
                dot.localY = dialogueBox.localY + dialogueBox.height - 30;
            }

            prevShape = data.shape;
        }

        if (data.shapeColor != null && data.shapeColor != prevShapeColor)
        {
            dialogueBox.color = Std.parseInt('0xFF${data.shapeColor}');
            speakerBox.color = Std.parseInt('0xFF${data.shapeColor}');

            prevShapeColor = data.shapeColor;
        }
        
        if (data.textColor != null && data.textColor != prevTextColor)
        {
            dialogueText.baseColor = data.textColor;
            speakerName.baseColor = data.textColor;
            responseText?.baseColor = data.textColor;

            advanceIcon.color = Std.parseInt('0xFF${data.textColor}');

            prevTextColor = data.textColor;
        }
        
        if (data.pattern != null)
        {
            patternShader.setBlend(data.patternBlend);
            patternShader.setValues([dialogueBox.width, dialogueBox.height], Assets.getBitmapData(Paths.image('${basePath}pattern-${data.pattern}')),
                Std.parseInt('0xFF${data.patternColor}'), data.patternAngle, data.patternDirection, data.patternSpeed);
            dialogueBox.shader = patternShader;
        }
        else
        {
            dialogueBox.shader = null;
        }
    }

    function dialogueBoxPatternPreset(name:String):PinDialogueTextbox
    {
        return switch (name)
        {
            case "ophelia":
            {
                shape: "round",
                shapeColor: "264967",
                textColor: "FFFFFF",
                pattern: "diamonds-alt",
                patternColor: "67B1D8",
                patternAngle: 10,
                patternDirection: [0.1, 0.03],
                patternSpeed: 0.3,
                patternBlend: 1
            }
            default:
            {
                shape: "round",
                shapeColor: "FFFFFF",
                textColor: "3B3939",
                pattern: null,
                patternColor: "FFFFFF",
                patternAngle: 0,
                patternDirection: [0, 0],
                patternSpeed: 0,
                patternBlend: 0
            }
        }
    }
}