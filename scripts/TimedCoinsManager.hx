package funkbucks;

import balphabet.BAlphabet;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkbucks.objects.ui.TimedCoinsHUD;
import funkin.audio.FunkinSound;
import funkin.data.song.SongRegistry;
import funkin.data.story.level.LevelRegistry;
import funkin.graphics.FunkinCamera;
import funkin.modding.ModStore;
import funkin.modding.module.Module;
import funkin.ui.FullScreenScaleMode;
import funkin.ui.charSelect.CharSelectSubState;
import funkin.ui.freeplay.FreeplayState;
import funkin.ui.mainmenu.MainMenuState;
import funkin.ui.story.StoryMenuState;
import funkin.util.ReflectUtil;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
using StringTools;

class TimedCoinsManager extends Module
{
    static final coinLocations:Array<String> = ["shop", "main", "story", "story", "freeplay", "freeplay", "freeplay", "charSelect"];
    static var chosenCoinLocations:Array<String> = [];
    static var spawnedCoins:Array<CloverCoin> = [];
    static var time:Float = 0;
    static var running:Bool = false;
    static var hud:TimedCoinsHUD = null;
    static var coinsCollected:Int = 0;
    static var eventMusic:FunkinSound = null;

    public function new():Void
    {
        super("FunkBucks-TimedCoinsManager", 10);
    }

    public function onCreate(event:ScriptEvent):Void
    {
        // FlxG.plugins.remove(ModStore.get("FBTimedCoinsHUDPluginInstance"));
        // ModStore.remove("FBTimedCoinsHUDPluginInstance");
        if (ModStore.get("FBTimedCoinsHUDPluginInstance") == null)
        {
            TimedCoinsManager.hud = new TimedCoinsHUD(20, 550);
            TimedCoinsManager.hud.angle = -7.5;
            ModStore.register("FBTimedCoinsHUDPluginInstance", FlxG.plugins.addPlugin(TimedCoinsManager.hud));
        }
        else
        {
            TimedCoinsManager.hud = ModStore.get("FBTimedCoinsHUDPluginInstance");
        }

        super.onCreate(event);
    }

    public function onUpdate(event:ScriptEvent):Void
    {
        // This works?? wow.
        TimedCoinsManager.hud?.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        if (TimedCoinsManager.running)
        {
            if (FlxG.keys.justPressed.F4)
            {
                FunkinSound.stopAllAudio(true, true);
                FlxG.sound.music = null;
                TimedCoinsManager.stopEvent();
            }

            if ((FlxG.state is StoryMenuState) && TimedCoinsManager.spawnedCoins.length > 0)
            {
                for (i in 0...TimedCoinsManager.spawnedCoins.length)
                {
                    var coin:CloverCoin = TimedCoinsManager.spawnedCoins[i];
                    if (!coin.canCollect) continue;
                    if (coin.data.split("|")[5] == FlxG.state.currentLevelId + "-" + FlxG.state.currentDifficultyId)
                    {
                        coin.visible = true;
                    }
                    else
                    {
                        coin.visible = false;
                    }
                }
            }

            TimedCoinsManager.time -= FlxG.elapsed;
            FlxG.sound.music?.stop();

            if (TimedCoinsManager.time <= 0)
            {
                TimedCoinsManager.time = 0;
                FunkinSound.playOnce(Paths.sound("ranks/rankinbad"));
                TimedCoinsManager.stopEvent();
            }
        }

        super.onUpdate(event);
    }

    public static function startEvent(length:Float):Void
    {
        TimedCoinsManager.chooseCoinLocations();

        if (TimedCoinsManager.eventMusic == null)
        {
            TimedCoinsManager.eventMusic = FunkinSound.load(Paths.music("girlfriendsRingtone/girlfriendsRingtone"), 1.0, true, false, false, true);
        }
        TimedCoinsManager.eventMusic.play();

        TimedCoinsManager.time = length;
        TimedCoinsManager.running = true;
        TimedCoinsManager.hud.doIntro();
        TimedCoinsManager.coinsCollected = 0;
        TimedCoinsManager.hud.updateCounter(TimedCoinsManager.coinsCollected);
        TimedCoinsManager.checkForCoinsInState(FlxG.state);
    }

    public static function stopEvent():Void
    {
        TimedCoinsManager.running = false;
        TimedCoinsManager.hud.alpha = 0.0;
        TimedCoinsManager.eventMusic?.stop();
        TimedCoinsManager.chosenCoinLocations = [];
    }

    public static function registerCoin(data:String):Void
    {
        TimedCoinsManager.chosenCoinLocations.remove(data);
        for (i in 0...TimedCoinsManager.spawnedCoins.length)
        {
            var coin:CloverCoin = TimedCoinsManager.spawnedCoins[i];
            if (coin.data == data)
            {
                TimedCoinsManager.spawnedCoins.splice(i, 1);
                break;
            }
        }
        TimedCoinsManager.coinsCollected++;
        TimedCoinsManager.hud.updateCounter(TimedCoinsManager.coinsCollected);

        if (TimedCoinsManager.coinsCollected >= 8)
        {
            if (FunkBucks.hasObtainedPin("clovercoin"))
            {
                // 1000 Funkbuck
            }
            else
            {
                // the clover coin pin
            }
            FunkinSound.playOnce(Paths.sound("ranks/rankinperfect"));
            TimedCoinsManager.stopEvent();
        }
    }

    public static function chooseCoinLocations():Void
    {
        var spotInfo:Array<Float> = [0.0, 0.0, 0.0, 0.0]; // x, y, scroll x, scroll y
        for (menu in TimedCoinsManager.coinLocations)
        {
            switch (menu)
            {
                case "shop":
                {
                    final location:Int = FlxG.random.int(0, 2);
                    switch (location)
                    {
                        case 0: spotInfo = [FlxG.random.float(-1150, 2340), FlxG.random.float(-360, -320), 0.85, 0.85];
                        case 1: spotInfo = [FlxG.random.float(-1150, 1850), FlxG.random.float(650, 740), 1.0, 1.0];
                        case 2: spotInfo = [1440, 345, 1.0, 1.0];
                    }
                    final spot:String = '$menu|${spotInfo[0]}|${spotInfo[1]}|${spotInfo[2]}|${spotInfo[3]}';
                    TimedCoinsManager.chosenCoinLocations.push(spot);
                }
                case "main":
                {
                    final location:Int = FlxG.random.int(0, 1);
                    switch (location)
                    {
                        case 0: spotInfo = [FlxG.random.float(20, 160), FlxG.random.float(180, 420), 0.0, 0.0];
                        case 1: spotInfo = [FlxG.random.float(FlxG.width - 220, FlxG.width - 100), FlxG.random.float(20, 420), 0.0, 0.0];
                    }
                    final spot:String = '$menu|${spotInfo[0]}|${spotInfo[1]}|${spotInfo[2]}|${spotInfo[3]}';
                    TimedCoinsManager.chosenCoinLocations.push(spot);
                }
                case "story":
                {
                    var baseGameLevelIDs:Array<String> = LevelRegistry.instance.listBaseGameEntryIds();
                    var levelID:String = baseGameLevelIDs[FlxG.random.int(0, baseGameLevelIDs.length - 1)];
                    final difficulty:String = Constants.DEFAULT_DIFFICULTY_LIST[FlxG.random.int(0, Constants.DEFAULT_DIFFICULTY_LIST.length - 1)];
                    final location:Int = FlxG.random.int(0, 3);
                    spotInfo = [FlxG.random.float(10, FlxG.width - 80), FlxG.random.float(65, 360), 0.0, 0.0]; // x, y, scroll x, scroll y
                    final spot:String = '$menu|${spotInfo[0]}|${spotInfo[1]}|${spotInfo[2]}|${spotInfo[3]}|${levelID}-${difficulty}';
                    TimedCoinsManager.chosenCoinLocations.push(spot);
                }
                case "freeplay":
                {
                    var baseGameSongIDs:Array<String> = SongRegistry.instance.listBaseGameEntryIds();
                    baseGameSongIDs.remove("test");
                    var songID:String = baseGameSongIDs[FlxG.random.int(0, baseGameSongIDs.length - 1)];
                    var songVariations:Array<String> = SongRegistry.instance.fetchEntry(songID).variations;
                    songVariations = songVariations.filter(function(variationID:String):Bool
                    {
                        return Constants.DEFAULT_VARIATION_LIST.contains(variationID);
                    });
                    final song:String = songID + "-" + songVariations[FlxG.random.int(0, songVariations.length - 1)];
                    final location:Int = FlxG.random.int(0, 3);
                    switch (location)
                    {
                        case 0: spotInfo = [155 + FreeplayState.CUTOUT_WIDTH * FreeplayState.DJ_POS_MULTI, 200, 0.0, 0.0];
                        case 1: spotInfo = [FlxG.width - 440, 120, 0.0, 0.0];
                        case 2: spotInfo = [FlxG.width - 110, 190, 0.0, 0.0];
                        case 3: spotInfo = [FlxG.random.float(FlxG.width - 310, FlxG.width - 160), FlxG.random.float(280, 435), 0.0, 0.0];
                    }
                    final spot:String = '$menu|${spotInfo[0]}|${spotInfo[1]}|${spotInfo[2]}|${spotInfo[3]}|${song}';
                    TimedCoinsManager.chosenCoinLocations.push(spot);
                }
                case "charSelect":
                {
                    final location:Int = FlxG.random.int(0, 2);
                    switch (location)
                    {
                        case 0: spotInfo = [FlxG.width - 100, 55, 1.0, 1.0];
                        case 1: spotInfo = [FlxG.random.float(15, 320), 60, 1.0, 1.0];
                        case 2: spotInfo = [FlxG.width / 2 - 25, 25, 1.0, 1.0];
                    }
                    final spot:String = '$menu|${spotInfo[0]}|${spotInfo[1]}|${spotInfo[2]}|${spotInfo[3]}';
                    TimedCoinsManager.chosenCoinLocations.push(spot);
                }
                default: trace("?????????????????");
            }
        }
    }

    override function onStateChangeEnd(event:StateChangeScriptEvent):Void
    {
        super.onStateChangeEnd(event);

        if (!TimedCoinsManager.running)
        {
            return;
        }

        TimedCoinsManager.spawnedCoins = [];

        checkForCoinsInState(event.targetState);
    }

    public static function checkForCoinsInState(state):Void
    {
        if (state == "PolymodScriptClass<funkbucks.Shop>")
        {
            for (i in 0...TimedCoinsManager.chosenCoinLocations.length)
            {
                if (TimedCoinsManager.chosenCoinLocations[i].startsWith("shop"))
                {
                    var spotInfo:Array<Float> = TimedCoinsManager.chosenCoinLocations[i].split("|");
                    var coin:CloverCoin = new CloverCoin(0, 0);
                    coin.x = spotInfo[1];
                    coin.y = spotInfo[2];
                    coin.scrollFactor.set(spotInfo[3], spotInfo[4]);
                    coin.data = TimedCoinsManager.chosenCoinLocations[i];
                    coin.zIndex = 1500;
                    coin.visible = true;
                    coin.canCollect = true;
                    state.add(coin);
                    state.refresh();
                }
            }
        }

        if (state is MainMenuState)
        {
            for (i in 0...TimedCoinsManager.chosenCoinLocations.length)
            {
                if (TimedCoinsManager.chosenCoinLocations[i].startsWith("main"))
                {
                    var spotInfo:Array<Float> = TimedCoinsManager.chosenCoinLocations[i].split("|");
                    var coin:CloverCoin = new CloverCoin(0, 0);
                    coin.x = spotInfo[1];
                    coin.y = spotInfo[2];
                    coin.scrollFactor.set(spotInfo[3], spotInfo[4]);
                    coin.data = TimedCoinsManager.chosenCoinLocations[i];
                    coin.zIndex = 1500;
                    coin.visible = true;
                    coin.canCollect = true;
                    state.add(coin);
                    state.refresh();
                }
            }
        }

        if (state is StoryMenuState)
        {
            for (i in 0...TimedCoinsManager.chosenCoinLocations.length)
            {
                if (TimedCoinsManager.chosenCoinLocations[i].startsWith("story"))
                {
                    var spotInfo:Array<Float> = TimedCoinsManager.chosenCoinLocations[i].split("|");
                    var coin:CloverCoin = new CloverCoin(0, 0);
                    coin.x = spotInfo[1];
                    coin.y = spotInfo[2];
                    coin.scrollFactor.set(spotInfo[3], spotInfo[4]);
                    coin.data = TimedCoinsManager.chosenCoinLocations[i];
                    coin.zIndex = 1500;
                    coin.visible = true;
                    coin.canCollect = true;
                    state.add(coin);
                    state.refresh();
                    TimedCoinsManager.spawnedCoins.push(coin);
                }
            }
        }

        if (state is CharSelectSubState)
        {
            for (i in 0...TimedCoinsManager.chosenCoinLocations.length)
            {
                if (TimedCoinsManager.chosenCoinLocations[i].startsWith("charSelect"))
                {
                    var spotInfo:Array<Float> = TimedCoinsManager.chosenCoinLocations[i].split("|");
                    var coin:CloverCoin = new CloverCoin(0, 0);
                    coin.x = spotInfo[1];
                    coin.y = spotInfo[2];
                    coin.scrollFactor.set(spotInfo[3], spotInfo[4]);
                    coin.data = TimedCoinsManager.chosenCoinLocations[i];
                    coin.zIndex = 1500;
                    coin.visible = true;
                    coin.canCollect = true;
                    state.add(coin);
                    state.refresh();
                }
            }
        }
    }

    public function onSubStateOpenEnd(event:SubStateScriptEvent):Void
    {
        super.onSubStateOpenEnd(event);

        if (!TimedCoinsManager.running)
        {
            return;
        }

        if (event.targetState is FreeplayState)
        {
            TimedCoinsManager.spawnedCoins = [];
            for (i in 0...TimedCoinsManager.chosenCoinLocations.length)
            {
                if (TimedCoinsManager.chosenCoinLocations[i].startsWith("freeplay"))
                {
                    var spotInfo:Array<Float> = TimedCoinsManager.chosenCoinLocations[i].split("|");
                    var coin:CloverCoin = new CloverCoin(0, 0);
                    coin.x = spotInfo[1];
                    coin.y = spotInfo[2];
                    coin.scrollFactor.set(spotInfo[3], spotInfo[4]);
                    coin.data = TimedCoinsManager.chosenCoinLocations[i];
                    coin.camera = event.targetState.funnyCam;
                    coin.zIndex = 5000;
                    coin.canCollect = true;
                    event.targetState.add(coin);
                    event.targetState.refresh();
                    TimedCoinsManager.spawnedCoins.push(coin);
                }
            }
        }
    }

    public function onCapsuleSelected(event:CapsuleScriptEvent)
    {
        super.onCapsuleSelected(event);

        if (!TimedCoinsManager.running || TimedCoinsManager.spawnedCoins.length == 0)
        {
            return;
        }

        for (i in 0...TimedCoinsManager.spawnedCoins.length)
        {
            var coin:CloverCoin = TimedCoinsManager.spawnedCoins[i];
            if (!coin.canCollect) return;
            if (coin.data.split("|")[5] == event.capsule.freeplayData?.data?.id + "-" + event.variationId)
            {
                // trace("True...");
                coin.visible = true;
            }
            else
            {
                // trace("False.");
                coin.visible = false;
            }
        }
    }
}