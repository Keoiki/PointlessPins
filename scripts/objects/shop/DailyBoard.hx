package funkbucks.objects.shop;

import balphabet.BAlphabet;
import funkbucks.FunkBucks;
import funkin.data.song.SongRegistry;
import funkin.graphics.FunkinSprite;
import funkin.group.FunkinGroup;
using StringTools;

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
        var dailies:Array<String> = FunkBucks.getDailies();
        // return "<b><c=00FF00>Dailies</c>\nPhilly Nic. &#xE003;\nSatin Pant. &#xE001;\nWinter Hor.</b>";
        if (dailies.length > 0)
        {
            var dailiesList:String = "";
            for (i in 0...FunkBucks.dailySongCount)
            {
                if (i >= dailies.length)
                {
                    dailiesList += "---";
                    if (i < FunkBucks.dailySongCount - 1) dailiesList += "\n";
                    continue;
                }
                var dailySongID:String = dailies[i].substring(0, dailies[i].lastIndexOf("-"));
                var dailySongVariation:String = dailies[i].substring(dailies[i].lastIndexOf("-") + 1, dailies[i].length);
                var dailySong:Array<SongMetadata> = SongRegistry.instance.fetchEntry(dailySongID);
                var songNameToAdd:String = dailySong.songName.length > 11 ? dailySong.songName.substr(0, 11).trim() + "." : dailySong.songName;
                if ('$dailySongID-$dailySongVariation' == "spaghetti-default") songNameToAdd = "SPAGHETTI";
                var variationToAdd:String = " ";
                switch (dailySongVariation)
                {
                    case "default": variationToAdd = ""; // Nothing gets added to default variation names.
                    case "erect": variationToAdd += FBIcon.Erect;
                    case "bf": variationToAdd += FBIcon.Boyfriend;
                    case "pico": variationToAdd += FBIcon.Pico;
                    case "hundrec": variationToAdd += FBIcon.Hundrec;
                    case "gooey": variationToAdd += FBIcon.Gooey;
                    case "remnants": variationToAdd += ["darnell", "lit-up", "2hot", "blazin"].contains(dailySongID) ? FBIcon.RemnantPico : FBIcon.RemnantBF;
                    case "bfremnants": variationToAdd += FBIcon.RemnantBF;
                    case "reimu": variationToAdd += FBIcon.Reimu;
                    case "qt": variationToAdd += FBIcon.QT;
                    case "spookymod": variationToAdd += FBIcon.SpookyKids;
                    default:
                    {
                        variationToAdd += '&#xFFFD;';
                        trace('Not a base or supported modded variation, how\'d this get in here?? - ${dailySongVariation}');
                    }
                }
                dailiesList += songNameToAdd + variationToAdd;
                if (i < FunkBucks.dailySongCount - 1) dailiesList += "\n";
            }
            return '<b><c=00FF00>Dailies</c>\n${dailiesList}</b>';
        }
        else
        {
            return "<b><c=00FF00>Dailies</c>\n\nNone!\nCome back\ntomorrow!</b>";
        }
    }
}