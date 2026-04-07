package funkbucks;

import Date;
import balphabet.BAlphabet;
import balphabet.BAlphabetTyped;
import haxe.ds.StringMap;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import funkbucks.objects.KeyCap;
import funkbucks.objects.PinSprite;
import funkin.Highscore;
import funkin.audio.FunkinSound;
import funkin.data.song.SongRegistry;
import funkin.modding.PolymodHandler;
import funkin.modding.ModStore;
import funkin.modding.module.Module;
import funkin.play.PlayState;
import funkin.play.PlayStatePlaylist;
import funkin.play.ResultState;
import funkin.save.Save;
import funkin.ui.mainmenu.MainMenuState;
import funkin.util.ReflectUtil;
import funkin.util.SerializerUtil;
import funkin.util.TouchUtil;
import funkin.util.VersionUtil;
using StringTools;

typedef PinData = {
    id:String, // The ID of a pin.
    name:String, // The visible name of a pin.
    ?description:String, // The description of a pin. (optional)
    ?scale:Float, // The scale of a pin in the Pins Menu. This value is doubled for the Pin Unlock screen. (optional, default: 0.5)
    ?artist:String, // The artist of a pin. (optional)
    ?source:String, // The source of a pin, whether it's based on a mod, or something else. (optional)
    ?special:Bool, // Whether or not a pin can only be unlocked once. Excludes them from Mystery Boxes. (optional, default: false)
    ?lockedText:String // The text to display when a pin is locked. (optional, use when `special` is true)
}

typedef BoxData = {
    id:String,
    name:String,
    description:String,
    revealTime:Int, // Frames until the pin is shown.
    chances:Array<Array<String, Int>>, // The numerical chance for each rarity as its WEIGHT. Double-check chances in the Box Menu to make sure they're correct.
    cost:Int,
    order:Float,
    ?rollsPins:Bool, // Does the box directly roll pins? (optional, default: false)
    ?special:Bool // Is the box only obtainable by special means? This makes it not purchasable. (optional, default: false)
}

class PointlessPins extends Module
{
    var menuPin;
    var menuPin2;

    static final penalties:Array<Float> = [1.0, 0.66, 0.33, 0.0, -0.5, -1];
    static final penaltyColors:Array<String> = ["FFFFFF", "FFAAAA", "FF5555", "FF0000", "AA0000", "550000"];
    static final opheliaAngerCooldown:Int = 1000 * 60 * 60 * 4;
    static final maximumBlueJewels:Int = 20;
    static final maxBlueJewelPity:Int = 100;
    static final bucksForBlueJewel:Int = 500;
    static final dailySongCount:Int = 5;

    static var save;

	public static var pinData;
    public static var boxData;
    public static var isMouseActive:Bool = false;
    public static var isMouseTooFast:Bool = false;

    function new():Void
    {
        super('PointlessPins', -20000000000);

        FlxG.signals.postGameStart.addOnce(versionCheck);
    }

    function onCreate(event:ScriptEvent):Void
    {
        PointlessPins.save = Save.instance.getModOptions("keoiki.funkbucks");

        loadPinData();

        super.onCreate(event);
    }

    function versionCheck():Void
    {
        var modVersion:String = null;
        var onlineVersion:String = "0.0.0";
        try
        {
            modVersion = PolymodHandler.modFileSystem.getMetadataById("keoiki.funkbucks", "script_runtime").modVersion.version.join(".");
        }
        catch (err:Dynamic)
        {
            trace(err);
            ModStore.register("pinsIsOutdated", false);
            #if mobile
            throw "Local mod version could not be found!\nThe message I put here for desktop users might be too long for mobile users.\nI can't be bothered to test that, maybe the text box is scrollable?\nJust change the mod ID back, man, so you can get notified of updates again."
            #else
            throw "Local mod version could not be found!\nWhy did you change the mod ID?\nI mean, it couldn't have been an accident, 0.8.4 changed how mod IDs work.\nThey aren't based off of the folder names anymore unless you don't provide an id the the metadata.\nYou had to manually go into the metadata file, and change the \"id\" field to something else.\nDo you NOT want to be notified when a new update drops?\nOkay.\nAre you still reading this?\nYou want me to keep going? Probably not.\nNow go change the mod ID back and continue opening those boxes!\n\n\nAlso, if the reason why you are getting this message is because someone told you that changing the mod ID does something cool,\nyou and that person better watch your backs.";
            #end
            return;
        }
        var request:URLRequest = new URLRequest("https://raw.githubusercontent.com/Keoiki/PointlessPins/main/version.txt");
        var loader:URLLoader = new URLLoader();
        loader.dataFormat = "text";
        var loadSuccessful = () -> {
            onlineVersion = loader.data;
            ModStore.register("pinsIsOutdated", VersionUtil.validateVersionStr(onlineVersion, ">" + modVersion));
            ModStore.register("pinsOnlineVersion", onlineVersion);
        }
        var loadFailed = () -> {
            ModStore.register("pinsIsOutdated", false);
            ModStore.register("pinsOnlineVersion", onlineVersion);
            trace("Failed to load online version!");
        }
        loader.addEventListener("complete", loadSuccessful);
        loader.addEventListener("ioError", loadFailed);
        loader.addEventListener("securityError", loadFailed);
        loader.load(request);
    }

    function loadPinData():Void
    {
        PointlessPins.pinData = SerializerUtil.fromJSON(Assets.getText("data/pointlesspins/pins.json"));

        PointlessPins.boxData = SerializerUtil.fromJSON(Assets.getText("data/pointlesspins/boxes.json"));
        var orderByOrder = function(a, b)
        {
            return FlxSort.byValues(-1, PointlessPins.boxData[a].order, PointlessPins.boxData[b].order);
        }
        PointlessPins.boxData.sort(orderByOrder);
    }

    public static function getPinByID(pinID:String):PinData
    {
        for (rarity in ReflectUtil.getAnonymousFieldsOf(PointlessPins.pinData))
        {
            for (pin in ReflectUtil.getAnonymousField(PointlessPins.pinData, rarity).pins)
            {
                if (pin.id == pinID)
                {
                    pin.rarity = rarity;
                    return pin;
                }
            }
        }
        return null;
    }

    public static function getAllPinIDsOfRarity(rarity:String, includeSpecials:Bool = false):Array<String>
    {
        var pinIDs:Array<String> = [];
        for (pin in ReflectUtil.getAnonymousField(PointlessPins.pinData, rarity).pins)
        {
            if (pin.special && !includeSpecials) continue;
            pinIDs.push(pin.id);
        }
        return pinIDs;
    }

    public static function addFunkCoins(amount:Int, addToLifetime:Bool = true):Void
    {
        PointlessPins.setFunkCoins(amount, addToLifetime);
    }

    public static function setFunkCoins(amount:Int, addToLifetime:Bool = true):Void
    {
        PointlessPins.save.funkBucks = PointlessPins.getFunkCoins() + Std.int(amount);
        if (addToLifetime)
        {
            /** Do not decrease the lifetime amount. **/
            PointlessPins.save.funkBucksLifetime = PointlessPins.getFunkCoinsLifeTime() + Math.max(0, Std.int(amount));
        }
        PointlessPins.saveTheData();
        trace("Current FunkBucks: " + PointlessPins.getFunkCoins());
        trace("Lifetime FunkBucks: " + PointlessPins.getFunkCoinsLifeTime());
    }

    public static function getFunkCoins():Int
    {
        return PointlessPins.save.funkBucks ?? 0;
    }

    public static function getFunkCoinsLifeTime():Int
    {
        return PointlessPins.save.funkBucksLifetime ?? 0;
    }

    public static function addBlueJewels(amount:Int = 1, addToLifetime:Bool = true):Int
    {
        var conversionToBucks:Int = 0;
        if (addToLifetime)
        {
            PointlessPins.save.blueJewelsLifetime = PointlessPins.getBlueJewelsLifeTime() + amount;
        }
        if (PointlessPins.getBlueJewels() + amount > PointlessPins.maximumBlueJewels)
        {
            conversionToBucks = (PointlessPins.getBlueJewels() + amount - PointlessPins.maximumBlueJewels) * PointlessPins.bucksForBlueJewel;
        }
        PointlessPins.save.blueJewels = FlxMath.bound(PointlessPins.getBlueJewels() + amount, 0, PointlessPins.maximumBlueJewels);
        PointlessPins.saveTheData();
        return conversionToBucks;
    }

    public static function getBlueJewels():Int
    {
        return PointlessPins.save.blueJewels ?? 0;
    }

    public static function getBlueJewelsLifeTime():Int
    {
        return PointlessPins.save.blueJewelsLifetime ?? 0;
    }

    public static function addBlueJewelPity(amount:Int = 1):Void
    {
        PointlessPins.save.blueJewelPity = FlxMath.bound(PointlessPins.getBlueJewelPity() + amount, 0, PointlessPins.maxBlueJewelPity);
        PointlessPins.saveTheData();
    }

    public static function getBlueJewelPity():Int
    {
        return PointlessPins.save.blueJewelPity ?? 0;
    }

    public static function addOpenedBox(boxID:String):Void
    {
        var boxesMap = getOpenedBoxCounts();
        boxesMap.set(boxID, (boxesMap.get(boxID) ?? 0) + 1);
        PointlessPins.save.openedBoxes = boxesMap;
        PointlessPins.saveTheData();
    }

    public static function getOpenedBoxCounts():StringMap<String, Int>
    {
        return PointlessPins.save.openedBoxes ?? new StringMap();
    }

    public static function getOpenedBoxCount(boxID:String):Int
    {
        return getOpenedBoxCounts().get(boxID) ?? 0;
    }

    public static function setObtainedPin(pinID:String):Bool
    {
        if (getPinByID(pinID) == null)
        {
            trace('Could not find pin $pinID! Was the name misspelled?');
            return false;
        }
        var isNewPin:Bool = !hasObtainedPin(pinID);
        var isPinSpecial:Bool = getPinByID(pinID)?.special ?? false;
        if (!isNewPin && isPinSpecial)
        {
            trace("Pin is special and has already been unlocked!");
            return false;
        }
        var pinsMap = getObtainedPins();
        pinsMap.set(pinID, isNewPin ? 1 : pinsMap.get(pinID) + 1);
        PointlessPins.save.obtainedPins = pinsMap;
        PointlessPins.saveTheData();
        return isNewPin;
    }

    public static function hasObtainedPin(pinID:String):Bool
    {
        return getObtainedPins().exists(pinID) ? getObtainedPins().get(pinID) > 0 : false;
    }

    public static function getObtainedPins():StringMap<String, Int>
    {
        return PointlessPins.save.obtainedPins ?? new StringMap();
    }

    public static function getObtainedPin(pinID:String):Int
    {
        return getObtainedPins().get(pinID) ?? 0;
    }

    public static function setPrevSongs(songs:Array<String>):Void
    {
        PointlessPins.save.previousSongs = songs;
        PointlessPins.saveTheData();
    }

    public static function getPrevSongs():Array<String>
    {
        return PointlessPins.save.previousSongs ?? new Array();
    }

    public static function addOpheliaAnger(anger:Int, addToTotal:Bool = true):Void
    {
        if (PointlessPins.save.opheliaAnger == null) PointlessPins.save.opheliaAnger = 0;
        PointlessPins.save.opheliaAnger += anger;
        if (addToTotal)
        {
            PointlessPins.save.opheliaAngerTotal = PointlessPins.getOpheliaAngerTotal() + anger;
        }
        PointlessPins.saveTheData();
    }

    public static function getOpheliaAnger():Int
    {
        var prevAngerTimestamp:Float = PointlessPins.save.opheliaAngerTime ?? -1;
        if (prevAngerTimestamp == -1)
        {
            // trace("No stored anger timestamp!");
            return 0;
        }
        var currentAnger:Int = PointlessPins.save.opheliaAnger ?? 0;
        if (currentAnger == 0)
        {
            // trace("No stored anger!");
            return 0;
        }
        var currentTimestamp:Float = Date.now().getTime();
        var angerGone:Int = Math.floor((Math.floor(currentTimestamp - prevAngerTimestamp)) / opheliaAngerCooldown);
        // trace(currentTimestamp, prevAngerTimestamp);
        // trace(PointlessPins.save.opheliaAnger);
        // trace(Math.floor(currentTimestamp) - Math.floor(prevAngerTimestamp));
        // trace("Anger gone: " + angerGone);
        PointlessPins.save.opheliaAnger = Math.max(0, currentAnger - angerGone);
        if (PointlessPins.save.opheliaAnger == 0)
        {
            PointlessPins.save.opheliaAngerTime = -1;
        }
        else
        {
            PointlessPins.save.opheliaAngerTime = prevAngerTimestamp + angerGone * opheliaAngerCooldown;
        }
        PointlessPins.saveTheData();
        return PointlessPins.save.opheliaAnger;
    }

    public static function getOpheliaAngerTotal():Int
    {
        return PointlessPins.save.opheliaAngerTotal ?? 0;
    }

    /**
     * DAILIES
     * Each day, 3 songs are randomly picked that will have a +50% FunkBuck modifier on them.
     * The +50% modifier will override any negative modifiers, however the song will still be added to the list of previous songs.
     * The following are not eligible for daily bonuses:
     * - modded songs,
     * - modded variations to base game songs, and (Subject to be supported in the future)
     * - any and all levels.
     */
    public static function setDailies(dailies:Array<String>):Void
    {
        PointlessPins.save.dailies = dailies;
        PointlessPins.saveTheData();
    }

    public static function getDailies():Array<String>
    {
        var dailyDateNum:Int = PointlessPins.save.dailyDate ?? -1;
        var date:Date = Date.now();
        var currentDate:Int = date.getDate();
        final supportedModdedVariations:Array<String> = PointlessPins.getSupportedModdedVariations();
        if (dailyDateNum != currentDate)
        {
            var baseGameSongIDs:Array<String> = SongRegistry.instance.listBaseGameEntryIds();
            baseGameSongIDs.remove("test"); // Test isn't easily available. (Does it even work properly? No.)
            baseGameSongIDs.remove("tutorial"); // Boring.
            baseGameSongIDs.remove("spaghetti"); // I'm removing this out of spite for how many DAMN TIMES it has appeared. No game, I do NOT want SPAGHETTI (feat. j-hope of BTS) (Clean ver.) 4 days IN A ROW!
            var dailies:Array<String> = [];
            for (i in 0...PointlessPins.dailySongCount)
            {
                var songID:String = baseGameSongIDs[FlxG.random.int(0, baseGameSongIDs.length - 1)];
                var songVariations:Array<String> = SongRegistry.instance.fetchEntry(songID).variations;
                songVariations = songVariations.filter(function(variationID:String):Bool
                {
                    return Constants.DEFAULT_VARIATION_LIST.contains(variationID) || supportedModdedVariations.contains(variationID);
                });
                dailies.push(songID + "-" + songVariations[FlxG.random.int(0, songVariations.length - 1)]);
                // Only one variation per song, thanks!
                baseGameSongIDs.remove(songID);
            }
            PointlessPins.save.dailyDate = currentDate;
            PointlessPins.setDailies(dailies);
            return dailies;
        }
        else
        {
            // The default empty array should never get returned, but I'll keep it here just in case.
            return PointlessPins.save.dailies ?? new Array();
        }
    }

    public static function addClaimedMilestone(milestone:String):Void
    {
        var _obtainedMilestones:Array<String> = PointlessPins.getClaimedMilestones();
        if (_obtainedMilestones.contains(milestone))
        {
            trace("User already obtained milestone: " + milestone);
            return;
        }
        _obtainedMilestones.push(milestone);
        PointlessPins.save.obtainedMilestones = _obtainedMilestones;
        PointlessPins.saveTheData();
    }

    public static function hasClaimedMilestone(milestone:String):Bool
    {
        return PointlessPins.getClaimedMilestones().contains(milestone);
    }

    public static function getClaimedMilestones():Array<String>
    {
        return PointlessPins.save.obtainedMilestones ?? new Array();
    }

    public static function getBoxDiscount():Float
    {
        var discount:Float = 1.0;
        var claimedRewards:Array<String> = PointlessPins.getClaimedMilestones();
        for (i in 0...claimedRewards.length)
        {
            switch (claimedRewards[i])
            {
                case "cardboardbox03", "smallgiftbox03": discount -= 0.025;
            }
        }
        return discount;
    }

    public static function getFunkCoinBonus():Float
    {
        var bonusMultiplier:Float = 1.0;
        var claimedRewards:Array<String> = PointlessPins.getClaimedMilestones();
        for (i in 0...claimedRewards.length)
        {
            switch (claimedRewards[i])
            {
                case "funkbucks08": bonusMultiplier += 0.025;
                case "funkbucks11", "funkbucks14": bonusMultiplier += 0.05;
            }
        }
        return bonusMultiplier;
    }

    public static function saveTheData():Void
    {
        Save.instance.setModOptions("keoiki.funkbucks", PointlessPins.save);
    }

    /**
     * Supported modded variations:
     * - Funkin' Remnants
     * - Gooey Mix
     * - Spooky Mix
     * - Funkin' Incident (Reimu)
     * - QT Rewired (Futureproof)
     * - Hundrec Mix (Futureproof)
     * @return Array<String>
     */
    static function getSupportedModdedVariations():Array<String>
    {
        return ["remnants", "bfremnants", "gooey", "spookymod", "reimu", "qt", "hundrec"];
    }

    function onUpdate(event:UpdateScriptEvent):Void
    {
        super.onUpdate(event);

        #if !mobile
        if (FlxG.keys.pressed.ANY)
        {
            PointlessPins.isMouseActive = false;
        }
        else if (Math.abs(FlxG.mouse.deltaViewX) > 24 || Math.abs(FlxG.mouse.deltaViewY) > 24)
        {
            PointlessPins.isMouseActive = true;
        }
        PointlessPins.isMouseTooFast = Math.abs(FlxG.mouse.deltaViewX) > 1 || Math.abs(FlxG.mouse.deltaViewY) > 1;
        #else  
        PointlessPins.isMouseActive = true;
        PointlessPins.isMouseTooFast = false;
        #end

        if (FlxG.state is MainMenuState && FlxG.state.subState == null)
        {
            if (FlxG.keys.justPressed.P || TouchUtil.pressAction(menuPin))
            {
                FlxG.switchState(new Shop());
            }

            if (FlxG.keys.justPressed.Q)
            {
                // PointlessPins.save.obtainedMilestones = [];
                // PointlessPins.saveTheData();
                trace(PointlessPins.getClaimedMilestones());
            }

            if (FlxG.keys.justPressed.J)
            {
                // for (i in 0...101)
                // {
                    // trace(i, Math.pow(i, 2) / 1000);
                // }
                trace(getDailies());
            }

            if (FlxG.keys.justPressed.T)
            {
                trace(getPrevSongs());
            }

            // if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.K)
            // {
                // ZIPUtil.zipModFiles(FlxG.keys.pressed.M);
            // }
        }
    }

    function onSongStart(event)
    {
        // trace(FlxG.sound.music.length);
        // trace(Math.ceil((6000 * 500) / (1020000 * 0.01) / 4 * 1.0 * 1.2 * 1.3));
        // trace(Math.ceil((Highscore.tallies.totalNotes * 500) / (FlxG.sound.music.length / 100) / 4 * 1.0 * 1.2 * 1.3));
    }

    override function onStateChangeEnd(event:StateChangeScriptEvent):Void
    {
        if (event.targetState is MainMenuState)
        {
            menuPin = new PinSprite(100, 100);
            menuPin.isUnlocked = true;
            menuPin.setupPin("funkbuck", "", "", 0.5, 1, true);
            menuPin.scrollFactor.set(0, 0);
            event.targetState.add(menuPin);

            #if !mobile
            var keycap01 = new KeyCap(115, 115, "P");
            event.targetState.add(keycap01);
            #end

            // var test:BAlphabetTyped = new BAlphabetTyped(0, 400, "Test <b>of</b> some<d=1.0/> events.");
            // test.scale.set(0.75, 0.75);
            // test.setScrollFactor(0, 0);
            // event.targetState.add(test);
            // test.start();
        }

        super.onStateChangeEnd(event);
    }

    override function onSubStateOpenEnd(event:SubStateScriptEvent):Void
    {
        /**
         * Change this later to be on song end instead?
         * So that mods that don't use the default results can still give FunkBucks on song/week completions.
         */
        if (event.targetState is ResultState)
        {
            if (PlayState.instance == null) return;

            // :whattheshit:
            if (PlayState.instance.isPlaytestResults) return;
            
            // Effectively 40 coins per 100k score. (10 per 25k)
            var bucksToAward:Float = (PlayStatePlaylist.isStoryMode ? PlayStatePlaylist.campaignScore : PlayState.instance.songScore) / 2500;
            // +50% for All Sicks, the great get richer, yikes.
            if (Highscore.tallies.totalNotes == Highscore.tallies.sick) bucksToAward *= 1.5;
            bucksToAward *= PointlessPins.getFunkCoinBonus();

            // No playing the same songs or weeks multiple times in a row!
            var previousSongs:Array<String> = PointlessPins.getPrevSongs();
            var currentDailies:Array<String> = PointlessPins.getDailies();
            var currentSongOrWeek:String = PlayStatePlaylist.isStoryMode ? PlayStatePlaylist.campaignId :
                    Std.string(PlayState.instance.currentChart.song.id + "-" + PlayState.instance.currentVariation);
            var penaltyCount:Int = previousSongs.filter(entry -> entry == currentSongOrWeek).length;
            var repeatPenalty:Float = PointlessPins.penalties[penaltyCount];
            var resultTextColor:String = PointlessPins.penaltyColors[penaltyCount];
            var awardedJewels:Int = 0;
            var awardNormalCompletionJewel:Bool = false;

            PointlessPins.addBlueJewelPity(#if keoiki.endlessmode EndlessStatus.isEndless ? Math.floor(EndlessStatus.currentLoopFloat) : #end 1);

            // Sorry Endless Mode...
            // NVM Endless Mode players stay winning!
            #if keoiki.endlessmode
            if (EndlessStatus.isEndless)
            {
                bucksToAward *= 0.25;
                resultTextColor = "00BBFF";
                trace("Endless Mode! Cut your earnings in 4, ha!");
            }
            else #end if (currentDailies.contains(currentSongOrWeek))
            {
                if (FlxG.random.bool(0.5))
                {
                    awardedJewels = 2;
                }
                else if (FlxG.random.bool(2))
                {
                    awardedJewels = 1;
                }
                bucksToAward *= 1.5;
                currentDailies.remove(currentSongOrWeek);
                PointlessPins.setDailies(currentDailies);
                resultTextColor = "00FF00";
                trace("Daily Bonus +50%! Remaining dailies: " + currentDailies);
            }
            else
            {
                awardNormalCompletionJewel = FlxG.random.bool(Math.pow(PointlessPins.getBlueJewelPity(), 2) / 1000);
                bucksToAward *= repeatPenalty;
                trace("Repeat penalty: " + repeatPenalty * 100 + "%");
            }

            if (#if keoiki.endlessmode EndlessStatus.isEndless && EndlessStatus.currentLoop < 2 #else false #end)
            {
                trace("Thought you could easily clear your penalties by giving up immediately in Endless Mode? Think again!");
            }
            else
            {
                previousSongs.unshift(currentSongOrWeek);
                while (previousSongs.length > 5)
                {
                    // Make sure we're working with a 5 long array at most.
                    previousSongs.pop();
                }
                PointlessPins.setPrevSongs(previousSongs);
            }

            // Normal completion jewel stacks with the Daily Song one(s).
            if (awardNormalCompletionJewel)
            {
                awardedJewels++;
                PointlessPins.save.blueJewelPity = 0;
                PoinltessPins.saveTheData();
            }
            
            bucksToAward = Math.ceil(bucksToAward);
            var excessFunkBucks:Int = PointlessPins.addBlueJewels(awardedJewels);
            bucksToAward += excessFunkBucks;
            awardedJewels -= excessFunkBucks / PointlessPins.bucksForBlueJewel;
            PointlessPins.addFunkCoins(bucksToAward);

            trace(currentSongOrWeek, bucksToAward, awardedJewels, excessFunkBucks, previousSongs);
            trace(awardNormalCompletionJewel, PointlessPins.getBlueJewelPity(), Math.pow(PointlessPins.getBlueJewelPity(), 2) / 1000);

            var funkBucksText = new BAlphabet(40, 50, '<b><c=$resultTextColor>${bucksToAward > 0 ? "+" : ""}$bucksToAward</c></b> ${PTIcon.Buck}');
            funkBucksText.scale.set(0.65, 0.65);
            funkBucksText.alpha = 0;
            funkBucksText.zIndex = 5000;
            event.targetState.add(funkBucksText);
            event.targetState.refresh();

            new FlxTimer().start(37 / 24, _ -> {
                funkBucksText.alpha = 1;
                FlxTween.tween(funkBucksText, { x: funkBucksText.x - 15 }, 0.5, { ease: FlxEase.backOut, type: 16 });
                FunkinSound.playOnce(Paths.sound(bucksToAward >= 0 ? "fav" : "unfav"), 1.5);
            });

            if (awardedJewels > 0)
            {
                var jewelsText = new BAlphabet(30, 70, '<b><c=82E9FF>+${awardedJewels}</c></b> ${PTIcon.Jewel}');
                jewelsText.resetOrigin();
                jewelsText.scale.set(0.65, 0.65);
                jewelsText.alpha = 0;
                jewelsText.zIndex = 5001;
                event.targetState.add(jewelsText);
                event.targetState.refresh();

                new FlxTimer().start(49 / 24, _ -> {
                    jewelsText.alpha = 1;
                    FlxTween.tween(funkBucksText, { y: 20 }, 0.5, { ease: FlxEase.backOut });
                    FlxTween.tween(jewelsText, { x: jewelsText.x - 15 }, 0.75, { ease: FlxEase.backOut, type: 16 });
                    FlxTween.tween(jewelsText.scale, { x: 1.0, y: 1.0 }, 0.75, { ease: FlxEase.bounceOut, type: 16 });
                    FunkinSound.playOnce(Paths.sound("bluejewel"), 1.5).pitch = 1.5;
                });
            }

            checkForSpecials(currentSongOrWeek);
        }

        super.onSubStateOpenEnd(event);
    }

    function checkForSpecials(completionID:String):Void
    {
        #if keoiki.endlessmode
        if (EndlessStatus.isEndless) return;
        #end

        var wantedPinID:Null<String> = null;
        switch (completionID)
        {
            case "sserafim", "spaghetti-default": wantedPinID = "spaghetti";
            default:
        }
        if (wantedPinID != null) setObtainedPin(wantedPinID);
    }
}

/**
 * This class contains a constant for each text icon the mod adds.
 */
class PTIcon
{
    static final Buck:String = "&#xE000;";
    static final Jewel:String = "&#xE001;";
    static final Erect:String = "&#xE002;";
    static final Boyfriend:String = "&#xE003;";
    static final Pico:String = "&#xE004;";

    static final OpheliaMad:String = "&#xE010;";
    static final Star:String = "&#xE011;";
    
    static final Common:String = "&#xE020;";
    static final Uncommon:String = "&#xE021;";
    static final Rare:String = "&#xE022;";
    static final Epic:String = "&#xE023;";
    static final Legendary:String = "&#xE024;";
    static final Mythic:String = "&#xE025;";
    static final Divine:String = "&#xE026;";
    static final Special:String = "&#xE027;";
    
    static final CardboardBox:String = "&#xE030;";
    static final SmallGiftbox:String = "&#xE031;";

    static final Modded:String = "&#xE070;";
    static final Internet:String = "&#xE071;";
    static final Game:String = "&#xE072;";

    static final Hundrec:String = "&#xE080;";
    static final Gooey:String = "&#xE081;";
    static final RemnantBF:String = "&#xE082;";
    static final RemnantPico:String = "&#xE083;";
    static final Reimu:String = "&#xE084;";
    static final QT:String = "&#xE085;";
    static final SpookyKids:String = "&#xE086;";
}