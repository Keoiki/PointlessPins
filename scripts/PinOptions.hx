package funkbucks;

import funkin.modding.module.Module;
import funkin.ui.options.OptionsState;

class PinOptions extends Module
{
    public function new():Void
    {
        super("PPOptions", -200000, { state: OptionsState });
    }

    public function onCreate(event:ScriptEvent):Void
    {
        if (FunkBucks.save.modifierText == null)
        {
            FunkBucks.save.modifierText = "percentage";
            FunkBucks.flushSave();
        }
    }

    public function onStateChangeEnd(event:StateChangeScriptEvent):Void
    {
        var preferences = event.targetState.optionsCodex.pages.get("preferences");
        if (preferences != null)
        {
            preferences.createPrefItemEnum(
                "FunkBuck Modifier",
                "Changes how to display the FunkBuck modifier.",
                ["Percentage" => "percentage", "Multiplier" => "multiplier"],
                function(key:String, value:String):Void
                {
                    FunkBucks.save.modifierText = value;
                    FunkBucks.flushSave();
                },
                switch (FunkBucks.save.modifierText)
                {
                    case "multiplier": "Multiplier";
                    default: "Percentage";
                }
            );
        }
        super.onStateChangeEnd(event);
    }
}