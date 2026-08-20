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
        
        if (FunkBucks.save.dialogueFlavor == null)
        {
            // Change default "dialogueFlavor" setting depending on the player's current settings.
            #if mobile
            // FunkBucks.save.dialogueFlavor = "nice";
            #else
            // if (!Preferences.naughtyness || Constants.CENSOR_EXPLETIVES)
            // {
                // FunkBucks.save.dialogueFlavor = "nice";
            // }
            #end
            // FunkBucks.flushSave();
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

            #if !mobile
            // preferences.createPrefItemEnum(
                // "Dialogue Flavor",
                // "Changes how mean dialogue from the shopkeepers is.\n(\"Naughtyness\" being OFF overrides this.)",
                // ["Meaner" => "mean", "Nicer" => "nice"],
                // function(key:String, value:String):Void
                // {
                    // FunkBucks.save.dialogueFlavor = value;
                    // FunkBucks.flushSave();
                // },
                // switch (FunkBucks.save.dialogueFlavor)
                // {
                    // case "nice": "Nicer";
                    // default: "Meaner";
                // }
            // );
            #end
        }
        super.onStateChangeEnd(event);
    }
}