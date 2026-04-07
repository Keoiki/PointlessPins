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
        if (PointlessPins.save.modifierText == null)
        {
            PointlessPins.save.modifierText = "percentage";
            PointlessPins.saveTheData();
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
                    PointlessPins.save.modifierText = value;
                    PointlessPins.saveTheData();
                },
                switch (PointlessPins.save.modifierText)
                {
                    case "multiplier": "Multiplier";
                    default: "Percentage";
                }
            );
        }
        super.onStateChangeEnd(event);
    }
}