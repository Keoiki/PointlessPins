package funkbucks;

import balphabet.BAlphabet;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.modding.module.Module;
import funkin.modding.module.ModuleHandler;
import funkin.play.PlayState;
import funkin.ui.charSelect.CharSelectSubState;
import funkin.ui.freeplay.FreeplayState;
import funkin.ui.story.StoryMenuState;

class FunkBucksModifierLable extends Module
{
    var pinModule:Module;
    var modifierText:BAlphabet;

    var addedToState:Bool = false;

    var prevStorySel:String = "tutorial";

    var canBeUpdated:Bool = false;
    var prevText:String = "";
    var onRandom:Bool = false;

    var bonusPercentage:Float = 0.0;

    var isEndlessOn(get, default):Bool = false;

    function get_isEndlessOn():Bool
    {
        #if keoiki.endlessmode
        return EndlessStatus.incompatibleSong ? false : EndlessStatus.isEndless;
        #else
        return false;
        #end
    }

    public function new():Void
    {
        super("FunkBucks-ModifierLabel", 2);
    }

    public function onUpdate(event:UpdateScriptEvent):Void
    {
        if (!(FlxG.state.subState is FreeplayState))
        {
            if (!(FlxG.state is StoryMenuState))
            {
                addedToState = false;
                modifierText = null;
            }
        }
        else
        {
            if (isEndlessOn && canBeUpdated && addedToState)
            {
                canBeUpdated = false;
                modifierText.text = '\n<b><c=00BBFF>${formatModifier(0.25)} ${FBIcon.Buck} (Endless)</c></b>';
                modifierText.alpha = 1;
            }
            else if (!isEndlessOn && !canBeUpdated && addedToState)
            {
                canBeUpdated = true;
                FlxG.state.subState.changeSelection();
            }
        }

        if (FlxG.state is StoryMenuState)
        {
            if (FlxG.state.currentLevelId != prevStorySel)
            {
                updateStoryModeText();
            }
            prevStorySel = FlxG.state.currentLevelId;
        }

        super.onUpdate(event);
    }

    public function onStateChangeEnd(event:StateChangeScriptEvent):Void
    {
        if (event.targetState is StoryMenuState)
        {
            addTextToStoryMode();
            updateStoryModeText();
        }

        if (event.targetState is CharSelectSubState ||
            event.targetState is PlayState)
        {
            canBeUpdated = false;
        }

        super.onStateChangeEnd(event);
    }

    public function addTextToStoryMode()
    {
        if (addedToState) return;

        bonusPercentage = FlxMath.roundDecimal(FunkBucks.getFunkCoinBonus(), 2);

        modifierText = new BAlphabet(FlxG.width - 20, 640, "", { lineHeight: 70 });
        modifierText.scale.set(0.5, 0.5);
        modifierText.alignment = "right";
        FlxG.state.add(modifierText);

        #if mobile 
        modifierText.x = FlxG.state.backButton.x - 20;
        #end

        addedToState = true;
    }

    public function updateStoryModeText()
    {
        if (modifierText == null) return;

        var bonusDisplay:String = bonusPercentage > 1.0 ? '<s=0.75><b><c=00FFFF>(${formatBonusModifier(bonusPercentage)})</c></b></s>\n' : '\n';

        modifierText.alpha = 1;

        var currentWeek:String = FlxG.state.currentLevelId;
        var repeatPenalty:Float = FunkBucks.getPrevSongs().filter(week -> week == currentWeek).length;

        modifierText.text = '$bonusDisplay<b><c=${FunkBucks.penaltyColors[repeatPenalty]}>${formatModifier(FunkBucks.penalties[repeatPenalty])}</c></b> ${FBIcon.Buck}';
    }

    override public function onFreeplayIntroDone(event:FreeplayScriptEvent)
    {
        bonusPercentage = FlxMath.roundDecimal(FunkBucks.getFunkCoinBonus(), 2);

        modifierText = new BAlphabet(20, FlxG.height + 10, "", { lineHeight: 70 });
        modifierText.scale.set(0.5, 0.5);

        FlxG.state.subState.add(modifierText);
        modifierText.camera = FlxG.state.subState.funnyCam;

        FlxTween.tween(modifierText, { y: FlxG.height - 80 }, 0.5, { ease: FlxEase.backOut });

        addedToState = true;
        canBeUpdated = true;
    }

    override public function onFreeplayOutro(event:FreeplayScriptEvent)
    {
        canBeUpdated = false;
        addedToState = false;

        if (modifierText == null) return;

        FlxTween.tween(modifierText, { y: FlxG.height + 20 }, 0.35, { ease: FlxEase.backIn });
    }

    override public function onCharacterConfirm(event:CharacterSelectScriptEvent)
    {
        canBeUpdated = false;
    }

    override public function onCapsuleSelected(event:CapsuleScriptEvent)
    {
        if (modifierText == null) return;
        if (!canBeUpdated || isEndlessOn) return;

        var bonusDisplay:String = bonusPercentage > 1.0 ? '<s=0.75><b><c=00FFFF>(${formatBonusModifier(bonusPercentage)})</c></b></s>\n' : '\n';

        modifierText.alpha = 1;
        if (event.capsule.freeplayData == null)
        {
            onRandom = true;
            modifierText.alpha = 0.5;
            modifierText.text = '<b>\nN/A</b>';
        }
        else
        {
            onRandom = false;
            var currentSong:String = event.capsule.freeplayData.data.id + "-" + event.variationId;
            if (FunkBucks.getDailies().contains(currentSong))
            {
                modifierText.text = '$bonusDisplay<b><c=00FF00>${formatModifier(1.5)}</c> ${FBIcon.Buck} (Daily)</b>';
            }
            else
            {
                var repeatPenalty:Float = FunkBucks.getPrevSongs().filter(song -> song == currentSong).length;
                modifierText.text = '$bonusDisplay<b><c=${FunkBucks.penaltyColors[repeatPenalty]}>${formatModifier(FunkBucks.penalties[repeatPenalty])}</c></b> ${FBIcon.Buck}';
            }
        }
    }

    override public function onSongSelected(event:CapsuleScriptEvent)
    {
        canBeUpdated = false;
    }

    function formatModifier(modifier:Float):String
    {
        switch (FunkBucks.save.modifierText)
        {
            case "multiplier": return '${modifier}x';
            default: return '${modifier * 100}%';
        }
    }

    function formatBonusModifier(modifier:Float):String
    {
        switch (FunkBucks.save.modifierText)
        {
            case "multiplier": return '+${modifier}x';
            default: return '+${modifier * 100 - 100}%';
        }
    }
}