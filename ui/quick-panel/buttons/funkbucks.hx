package funkbucks.ui.quickpanel;

import funkin.ui.quickpanel.PanelEntry;
import funkin.ui.transition.FadeType;
import funkin.ui.transition.Transition;
import funkin.ui.transition.Transition.TransitionType;
import funkin.ui.quickpanel.QuickPanelState;
import funkin.ui.quickpanel.PanelActions;

class FunkbucksShopPanelEntry extends PanelEntry
{
    public function new()
    {
      super('funkbucks');
    }

    override public function onAccept():Void
    {
        QuickPanelState.stopMusic();
        Transition.switchState(() -> new funkbucks.Shop(), {
            assetQuery: funkbucks.Shop.queryAssets,
            transition: TransitionType.BlackWithThrobber(FadeType.Fade("North"), FadeType.Fade("South"))
        });
    }
}