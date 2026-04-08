package funkbucks.objects.shop;

import balphabet.BAlphabet;
import funkbucks.PointlessPins;
import funkin.data.song.SongRegistry;
import funkin.graphics.FunkinSprite;
import funkin.group.FunkinGroup;

class DailyBoard extends FunkinGroup
{
    var board:FunkinSprite;
    var dailies:BAlphabet;

    override function new(x:Float, y:Float):Void
    {
        super(x, y);
        this.createBoard();
    }

    function createBoard():Void
    {
        board = new FunkinSprite(0, 0).loadTexture("shop/dailyboard");
        board.zIndex = 1;
        board.scrollFactor.set(0.85, 0.85);
        this.add(board);

        dailies = new BAlphabet(0, 0, formatDailySongs());
        dailies.localX = board.x + board.width / 2;
        dailies.localY = board.y + 115;
        dailies.alignment = "center";
        dailies.localScale.set(0.525, 0.525);
        dailies.setScrollFactor(0.85, 0.85);
        dailies.zIndex = 2;
        this.add(dailies);
    }

    function formatDailySongs():String
    {
        var dailies:Array<String> = PointlessPins.getDailies();
        // return "<b><c=00FF00>Dailies</c>\nPhilly Nic. &#xE003;\nSatin Pant. &#xE001;\nWinter Hor.</b>";
        if (dailies.length > 0)
        {
            var dailiesList:String = "";
            for (i in 0...PointlessPins.dailySongCount)
            {
                if (i >= dailies.length)
                {
                    dailiesList += "---";
                    if (i < PointlessPins.dailySongCount - 1) dailiesList += "\n";
                    continue;
                }
                var dailySongID:String = dailies[i].substring(0, dailies[i].lastIndexOf("-"));
                var dailySongVariation:String = dailies[i].substring(dailies[i].lastIndexOf("-") + 1, dailies[i].length);
                var dailySong:Array<SongMetadata> = SongRegistry.instance.fetchEntry(dailySongID);
                var songNameToAdd:String = dailySong.songName.length > 11 ? dailySong.songName.substr(0, 11).trim() + "." : dailySong.songName;
                var variationToAdd:String = " ";
                switch (dailySongVariation)
                {
                    case "default": variationToAdd = ""; // Nothing gets added to default variation names.
                    case "erect": variationToAdd += PTIcon.Erect;
                    case "bf": variationToAdd += PTIcon.Boyfriend;
                    case "pico": variationToAdd += PTIcon.Pico;
                    case "hundrec": variationToAdd += PTIcon.Hundrec;
                    case "gooey": variationToAdd += PTIcon.Gooey;
                    case "remnants": variationToAdd += ["darnell", "lit-up", "2hot", "blazin"].contains(dailySongID) ? PTIcon.RemnantPico : PTIcon.RemnantBF;
                    case "bfremnants": variationToAdd += PTIcon.RemnantBF;
                    case "reimu": variationToAdd += PTIcon.Reimu;
                    case "qt": variationToAdd += PTIcon.QT;
                    case "spookymod": variationToAdd += PTIcon.SpookyKids;
                    default:
                    {
                        variationToAdd += '&#xFFFD;';
                        trace('Not a base variation, how\'d this get in here?? - ${dailySongVariation}');
                    }
                }
                dailiesList += songNameToAdd + variationToAdd;
                if (i < PointlessPins.dailySongCount - 1) dailiesList += "\n";
            }
            return '<b><c=00FF00>Dailies</c>\n${dailiesList}</b>';
        }
        else
        {
            return "<b><c=00FF00>Dailies</c>\n\nNone!\nCome back\ntomorrow!</b>";
        }
    }
}