package funkbucks.objects.shop;

import balphabet.BAlphabet;
import funkbucks.FunkBucks;
import funkin.graphics.FunkinSprite;
import funkin.group.FunkinGroup;

class StatsSheet extends FunkinGroup
{
    public function new(x:Float, y:Float):Void
    {
        super(x, y);

        var statsPaper:FunkinSprite = new FunkinSprite(0, 0).loadTexture("statssheet");
        statsPaper.zIndex = 0;
        statsPaper.localX = -19;
        statsPaper.localY = -60;
        this.add(statsPaper);

        var statNames:BAlphabet = new BAlphabet(0, 0, '${FBIcon.Buck} Total FunkBucks earned:
${FBIcon.Jewel} Total Melody Stones earned:
${FBIcon.CardboardBox} Total Boxes opened:
${FBIcon.CardboardBox} Total Cardboard Boxes opened:
${FBIcon.SmallGiftbox} Total Small Giftboxes opened:
${FBIcon.FancyCoffret} Total Fancy Coffrets opened:
${FBIcon.GlimmeringPouch} Total Glimmering Pouches opened:
${FBIcon.Buck} Total Daily Songs completed:', { baseColor: "2D2E48" });
        statNames.zIndex = 1;
        statNames.localScale.set(0.5, 0.5);
        this.add(statNames);

        var statCounts:BAlphabet = new BAlphabet(0, 0, '${FunkBucks.getFunkCoinsLifetime()}
${FunkBucks.getBlueJewelsLifetime()}
${FunkBucks.getOpenedBoxCount("cardboard") + FunkBucks.getOpenedBoxCount("smallgiftbox") + FunkBucks.getOpenedBoxCount("fancycoffret") + FunkBucks.getOpenedBoxCount("glimmeringpouch")}
${FunkBucks.getOpenedBoxCount("cardboard")}
${FunkBucks.getOpenedBoxCount("smallgiftbox")}
${FunkBucks.getOpenedBoxCount("fancycoffret")}
${FunkBucks.getOpenedBoxCount("glimmeringpouch")}
${FunkBucks.save.dailiesCompleted}', { baseColor: "2D2E48", alignment: "right" });
        statCounts.zIndex = 2;
        statCounts.localX = 700;
        statCounts.localScale.set(0.5, 0.5);
        this.add(statCounts);
    }
}