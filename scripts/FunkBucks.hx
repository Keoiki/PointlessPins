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
import funkin.graphics.FunkinSprite;
import funkin.modding.PolymodHandler;
import funkin.modding.ModStore;
import funkin.modding.module.Module;
import funkin.play.PlayState;
import funkin.play.PlayStatePlaylist;
import funkin.play.ResultState;
import funkin.play.scoring.Scoring;
import funkin.play.scoring.ScoringRank;
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
    ?scale:Float, // The scale of a pin on the Pin Board. (optional, default: 0.5)
    ?artist:String, // The artist of a pin. (optional)
    ?source:String, // The source of a pin, whether it's based on a mod, or something else. (optional)
    ?special:Bool, // Whether or not a pin can only be unlocked once. Excludes them from Mystery Boxes. (optional, default: false)
    ?lockedText:String, // The text to display when a pin is locked. (optional, use when `special` is true)
    ?noCount:Bool // Use sparringly.
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

class FunkBucks extends Module
{
    var menuPin:PinSprite;
    var menuPin2:PinSprite;

    public static final penalties:Array<Float> = [1.0, 0.66, 0.33, 0.0, -0.5, -1];
    public static final penaltyColors:Array<String> = ["FFFFFF", "FFAAAA", "FF5555", "FF0000", "AA0000", "550000"];
    public static final opheliaAngerCooldown:Int = 1000 * 60 * 60 * 4;
    public static final maxBlueJewelPity:Int = 100;
    public static final bucksForBlueJewel:Int = 1000;
    public static final dailySongCount:Int = 5;
    public static final skipTalking:Array<Int> = [33, 44, 46, 63];

    public static var save;

	public static var pinData:PinData;
    public static var boxData:BoxData;
    public static var isMouseActive:Bool = false;
    public static var isMouseTooFast:Bool = false;

    /**
     * Set this value to determine how to show the pins on the Pin Board.
     * 
     * Null is default behavior. False shows them as locked and True shows them as unlocked.
     * 
     * A red * indicates if this is on.
     */
    public static var debug_pins:Null<Bool> = true;

    /**
     * Set this value to True to test opening boxes.
     * 
     * Boxes opened with this enabled:
     * - don't cost anything,
     * - don't count towards your opened total,
     * - don't take away from your free boxes count,
     * - and the pins unlocked do not actually unlock but rather show up as NEW no matter what.
     * 
     * A red * indicates if this is on.
     */
    public static var debug_boxes:Bool = false;

    /**
     * Add pin IDs to this array when you want to show unlocked pins the next time the player enters the shop.
     * 
     * Remember that the PinUnlockState marks pins as unlocked inside itself, so be sure you want the player to have that pin!
     */
    public static var pinUnlockQueue:Array<String> = [];

    /**
     * The order in which April will sell her pins in the "Exchange" option, with the ID and Melody Stone price.
     */
    public static final aprilPinOrder:Array<Array<Dynamic>> = [
        ["april", 2], 
        ["funkbuck-pixel", 4],
        ["ophelia-business", 10]
    ];

    function new():Void
    {
        super('FunkBucks', -20000000000);

        FlxG.signals.postGameStart.addOnce(versionCheck);
    }

    function onCreate(event:ScriptEvent):Void
    {
        FunkBucks.save = Save.instance.getModOptions("keoiki.funkbucks");

        // Load default values if there are no saved values, such as when a new player begins their journey to gather all of the Pointless Pins. (roll credits)
        if (ReflectUtil.fields(FunkBucks.save).length == 0)
        {
            FunkBucks.save = FunkBucks.getDefaultSaveValues();
            // Change default "dialogueFlavor" setting depending on the player's current settings.
            #if mobile
            FunkBucks.save.dialogueFlavor = "nice";
            #else
            if (!Preferences.naughtyness || Constants.CENSOR_EXPLETIVES)
            {
                FunkBucks.save.dialogueFlavor = "nice";
            }
            #end
            FunkBucks.flushSave();
        }

        loadPinData();

        super.onCreate(event);
    }

    function versionCheck():Void
    {
        var localVersion:String = null;
        var onlineVersion:String = "0.0.0";
        var onlineVersionInfo:String = "";

        try
        {
            // For 0.9.0: getMetadataById -> getMetadataByModId
            localVersion = PolymodHandler.modFileSystem.getMetadataById("keoiki.funkbucks", "script_runtime").modVersion.version.join(".");
        }
        catch (err:Dynamic)
        {
            trace(err);
            ModStore.register("funkbucksOutdated", false);
            return;
        }

        var request:URLRequest = new URLRequest("https://raw.githubusercontent.com/Keoiki/PointlessPins/main/version.txt");
        var loader:URLLoader = new URLLoader();
        loader.dataFormat = "text";

        var loadSuccessful = () ->
        {
            var versionData:Null<String> = Std.string(loader.data);

            if (versionData == null)
            {
                ModStore.register("funkbucksOutdated", false);
                ModStore.register("funkbucksNewVersion", onlineVersion);
                ModStore.register("funkbucksNewVersionInfo", onlineVersionInfo);
                trace("Somehow got no version data despite the request being successful?");
            }

            if (versionData.indexOf("|||") != -1)
            {
                var versionInfo:Array<String> = versionData.split("|||");
                onlineVersion = versionInfo[0];
                onlineVersionInfo = versionInfo[1];
            }
            else
            {
                onlineVersion = versionData;
            }

            ModStore.register("funkbucksOutdated", VersionUtil.validateVersionStr(onlineVersion, ">" + localVersion));
            ModStore.register("funkbucksNewVersion", onlineVersion);
            ModStore.register("funkbucksNewVersionInfo", onlineVersionInfo);
        }

        var loadFailed = () ->
        {
            ModStore.register("funkbucksOutdated", false);
            ModStore.register("funkbucksNewVersion", onlineVersion);
            ModStore.register("funkbucksNewVersionInfo", onlineVersionInfo);
            trace("Failed to fetch online version!");
        }

        loader.addEventListener("complete", loadSuccessful);
        loader.addEventListener("ioError", loadFailed);
        loader.addEventListener("securityError", loadFailed);
        loader.load(request);

        // Testing stuff.

        // ModStore.remove("funkbucksOutdated");
        // ModStore.remove("funkbucksNewVersion");
        // ModStore.remove("funkbucksNewVersionInfo");
        // ModStore.remove("funkbucksShownOutdate");
        // ModStore.register("funkbucksOutdated", true);
        // ModStore.register("funkbucksNewVersion", "2.1.0");
        // ModStore.register("funkbucksNewVersionInfo", "- Removed Hundrec.");
    }

    /**
     * load the pin and box data graaahhh
     */
    function loadPinData():Void
    {
        FunkBucks.pinData = SerializerUtil.fromJSON(Assets.getText("data/pointlesspins/pins.json"));

        FunkBucks.boxData = SerializerUtil.fromJSON(Assets.getText("data/pointlesspins/boxes.json"));
        var orderByOrder = function(a, b)
        {
            return FlxSort.byValues(-1, FunkBucks.boxData[a].order, FunkBucks.boxData[b].order);
        }
        FunkBucks.boxData.sort(orderByOrder);
    }

    /**
     * Gets a pin's data by its ID.
     * @param pinID The pin's ID.
     * @return **(PinData)** The pin's data, rarity included.
     */
    public static function getPinByID(pinID:String):PinData
    {
        for (rarity in ReflectUtil.getAnonymousFieldsOf(FunkBucks.pinData))
        {
            for (pin in ReflectUtil.getAnonymousField(FunkBucks.pinData, rarity).pins)
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

    /**
     * @return How many unique pins have been unlocked.
     */
    public static function getUnlockedPinsCount():Int
    {
        var count:Int = 0;
        for (rarity in ReflectUtil.getAnonymousFieldsOf(FunkBucks.pinData))
        {
            for (pin in ReflectUtil.getAnonymousField(FunkBucks.pinData, rarity).pins)
            {
                if (FunkBucks.hasObtainedPin(pin.id))
                {
                    count++;
                }
            }
        }
        return count;
    }
    
    /**
     * Gets all pins of a given rarity.
     * @param rarity The rarity name.
     * @param includeSpecials Should the return include special pins.
     * @return Array<String>
     */
    public static function getAllPinIDsOfRarity(rarity:String, includeSpecials:Bool = false):Array<String>
    {
        var pinIDs:Array<String> = [];
        for (pin in ReflectUtil.getAnonymousField(FunkBucks.pinData, rarity).pins)
        {
            if (pin.special && !includeSpecials) continue;
            pinIDs.push(pin.id);
        }
        return pinIDs;
    }

    public static function addFunkCoins(amount:Int, addToLifetime:Bool = true):Void
    {
        FunkBucks.setFunkCoins(amount, addToLifetime);
    }

    public static function setFunkCoins(amount:Int, addToLifetime:Bool = true):Void
    {
        FunkBucks.save.funkBucks = FunkBucks.getFunkCoins() + Std.int(amount);
        if (addToLifetime)
        {
            /** Do not decrease the lifetime amount. **/
            FunkBucks.save.funkBucksLifetime = FunkBucks.getFunkCoinsLifetime() + Math.max(0, Std.int(amount));
        }
        FunkBucks.flushSave();
        trace("Current FunkBucks: " + FunkBucks.getFunkCoins());
        trace("Lifetime FunkBucks: " + FunkBucks.getFunkCoinsLifetime());
    }

    public static function getFunkCoins():Int
    {
        if (FunkBucks.save.funkBucks == null) FunkBucks.save.funkBucks = 0;
        return FunkBucks.save.funkBucks;
    }

    public static function getFunkCoinsLifetime():Int
    {
        if (FunkBucks.save.funkBucksLifetime == null) FunkBucks.save.funkBucksLifetime = 0;
        return FunkBucks.save.funkBucksLifetime;
    }

    public static function addBlueJewels(amount:Int = 1, addToLifetime:Bool = true):Int
    {
        if (addToLifetime)
        {
            FunkBucks.save.blueJewelsLifetime = FunkBucks.getBlueJewelsLifetime() + amount;
        }
        FunkBucks.save.blueJewels = FunkBucks.getBlueJewels() + amount;
        FunkBucks.flushSave();
    }

    public static function getBlueJewels():Int
    {
        if (FunkBucks.save.blueJewels == null) FunkBucks.save.blueJewels = 0;
        return FunkBucks.save.blueJewels;
    }

    public static function getBlueJewelsLifetime():Int
    {
        if (FunkBucks.save.blueJewelsLifetime == null) FunkBucks.save.blueJewelsLifetime = 0;
        return FunkBucks.save.blueJewelsLifetime;
    }

    public static function addBlueJewelPity(amount:Int = 1):Void
    {
        FunkBucks.save.blueJewelPity = FlxMath.bound(FunkBucks.getBlueJewelPity() + amount, 0, FunkBucks.maxBlueJewelPity);
        FunkBucks.flushSave();
    }

    public static function getBlueJewelPity():Int
    {
        if (FunkBucks.save.blueJewelPity == null) FunkBucks.save.blueJewelPity = 0;
        return FunkBucks.save.blueJewelPity;
    }

    /**
     * BOXES 
     */

    public static function addOpenedBox(boxID:String):Void
    {
        var boxesMap = getOpenedBoxCounts();
        boxesMap.set(boxID, (boxesMap.get(boxID) ?? 0) + 1);
        FunkBucks.save.openedBoxes = boxesMap;
        FunkBucks.flushSave();
    }

    public static function getOpenedBoxCounts():StringMap<String, Int>
    {
        if (FunkBucks.save.openedBoxes == null) FunkBucks.save.openedBoxes = new StringMap();
        return FunkBucks.save.openedBoxes;
    }

    public static function getOpenedBoxCount(boxID:String):Int
    {
        return getOpenedBoxCounts().get(boxID) ?? 0;
    }

    /**
     * FREE BOXES
     */

    public static function addFreeBox(boxID:String, amount:Int):Void
    {
        var boxesMap = getFreeBoxCounts();
        boxesMap.set(boxID, (boxesMap.get(boxID) ?? 0) + amount);
        FunkBucks.save.freeBoxes = boxesMap;
        FunkBucks.flushSave();
    }

    public static function getFreeBoxCounts():StringMap<String, Int>
    {
        if (FunkBucks.save.freeBoxes == null) FunkBucks.save.freeBoxes = new StringMap();
        return FunkBucks.save.freeBoxes;
    }

    public static function getFreeBoxCount(boxID:String):Int
    {
        return getFreeBoxCounts().get(boxID) ?? 0;
    }

    /**
     * PINS
     * All of the stuff related to pins.
     */

    /**
     * Set a pin as being obtained.
     * 
     * Will return early if pin ID wasn't found.
     * 
     * Will also return early if pin is special and has already been obtained.
     * 
     * @param pinID The pin ID.
     * @return **(Bool)** Whether or not the pin was a brand new one or not.
     */
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
        FunkBucks.save.obtainedPins = pinsMap;
        FunkBucks.flushSave();
        return isNewPin;
    }

    public static function hasObtainedPin(pinID:String):Bool
    {
        return getObtainedPins().exists(pinID) ? getObtainedPins().get(pinID) > 0 : false;
    }

    public static function getObtainedPins():StringMap<String, Int>
    {
        if (FunkBucks.save.obtainedPins == null) FunkBucks.save.obtainedPins = new StringMap();
        return FunkBucks.save.obtainedPins;
    }

    public static function getObtainedPin(pinID:String):Int
    {
        return getObtainedPins().get(pinID) ?? 0;
    }

    /**
     * PREVIOUS SONGS
     * Keeps track of the 5 previous songs or weeks you've played.
     * Used for penalizing repeated plays.
     */

    public static function setPrevSongs(songs:Array<String>):Void
    {
        FunkBucks.save.previousSongs = songs;
        FunkBucks.flushSave();
    }

    public static function getPrevSongs():Array<String>
    {
        if (FunkBucks.save.previousSongs == null) FunkBucks.save.previousSongs = new Array();
        return FunkBucks.save.previousSongs;
    }

    /**
     * OPHELIA'S ANGER
     * If you annoy Ophelia too much, she'll mad at you, raising prices by 20%.
     * You can keep doing this to increase box prices even more.
     * 
     * Anger drops by 1 every 4 hours.
     */
    
    public static function addOpheliaAnger(anger:Int, addToTotal:Bool = true):Void
    {
        if (FunkBucks.save.opheliaAnger == null) FunkBucks.save.opheliaAnger = 0;
        FunkBucks.save.opheliaAnger += anger;
        if (addToTotal)
        {
            FunkBucks.save.opheliaAngerTotal = FunkBucks.getOpheliaAngerTotal() + anger;
        }
        FunkBucks.flushSave();
    }

    public static function getOpheliaAnger():Int
    {
        if (FunkBucks.save.opheliaAnger == null) FunkBucks.save.opheliaAnger = 0;
        if (FunkBucks.save.opheliaAngerTime == null) FunkBucks.save.opheliaAngerTime = -1;

        var prevAngerTimestamp:Float = FunkBucks.save.opheliaAngerTime;
        if (prevAngerTimestamp == -1)
        {
            // trace("No stored anger timestamp!");
            return 0;
        }
        var currentAnger:Int = FunkBucks.save.opheliaAnger;
        if (currentAnger == 0)
        {
            // trace("No stored anger!");
            return 0;
        }
        var currentTimestamp:Float = Date.now().getTime();
        var angerGone:Int = Math.floor((Math.floor(currentTimestamp - prevAngerTimestamp)) / opheliaAngerCooldown);
        // trace(currentTimestamp, prevAngerTimestamp);
        // trace(FunkBucks.save.opheliaAnger);
        // trace(Math.floor(currentTimestamp) - Math.floor(prevAngerTimestamp));
        // trace("Anger gone: " + angerGone);
        FunkBucks.save.opheliaAnger = Math.max(0, currentAnger - angerGone);
        if (FunkBucks.save.opheliaAnger == 0)
        {
            FunkBucks.save.opheliaAngerTime = -1;
        }
        else
        {
            FunkBucks.save.opheliaAngerTime = prevAngerTimestamp + angerGone * opheliaAngerCooldown;
        }
        FunkBucks.flushSave();
        return FunkBucks.save.opheliaAnger;
    }

    public static function getOpheliaAngerTotal():Int
    {
        if (FunkBucks.save.opheliaAngerTotal == null) FunkBucks.save.opheliaAngerTotal = 0;
        return FunkBucks.save.opheliaAngerTotal;
    }

    /**
     * DAILIES
     * Each day, 3 songs are randomly picked that will have a +50% FunkBuck modifier on them.
     * The +50% modifier will override any negative modifiers, however the song will still be added to the list of previous songs.
     * The following are not eligible for daily bonuses:
     * 
     * - modded songs,
     * - modded variations to base game songs, and (Subject to be supported in the future)
     * - any and all levels.
     * 
     * (Daily song selection has been moved to `checkForNewDay()`)
     */
    
    public static function setDailies(dailies:Array<String>):Void
    {
        FunkBucks.save.dailies = dailies;
        FunkBucks.flushSave();
    }

    public static function getDailies():Array<String>
    {
        FunkBucks.checkForNewDay();
        // The default empty array should never get returned, but I'll keep it here just in case.
        if (FunkBucks.save.dailies == null) FunkBucks.save.dailies = new Array();
        return FunkBucks.save.dailies;
    }

    /**
     * MILESTONES
     * or rather, Rewards.
     */

    public static function addClaimedMilestone(milestone:String):Void
    {
        var _obtainedMilestones:Array<String> = FunkBucks.getClaimedMilestones();
        if (_obtainedMilestones.contains(milestone))
        {
            trace("User already obtained milestone: " + milestone);
            return;
        }
        _obtainedMilestones.push(milestone);
        FunkBucks.save.obtainedMilestones = _obtainedMilestones;
        FunkBucks.flushSave();
    }

    public static function hasClaimedMilestone(milestone:String):Bool
    {
        return FunkBucks.getClaimedMilestones().contains(milestone);
    }

    public static function getClaimedMilestones():Array<String>
    {
        if (FunkBucks.save.obtainedMilestones == null) FunkBucks.save.obtainedMilestones = new Array();
        return FunkBucks.save.obtainedMilestones;
    }

    public static function getBoxDiscount():Float
    {
        var discount:Float = 1.0;
        var claimedRewards:Array<String> = FunkBucks.getClaimedMilestones();
        for (i in 0...claimedRewards.length)
        {
            switch (claimedRewards[i])
            {
                case "cardboardbox03", "smallgiftbox03": discount -= 0.05;
                case "fancycoffret03", "shimmeringpouch03": discount -= 0.025;
            }
        }
        return discount;
    }

    public static function getFunkCoinBonus():Float
    {
        var bonusMultiplier:Float = 1.0;
        var claimedRewards:Array<String> = FunkBucks.getClaimedMilestones();
        for (i in 0...claimedRewards.length)
        {
            switch (claimedRewards[i])
            {
                case "funkbucks07", "funkbucks11": bonusMultiplier += 0.025;
                case "funkbucks14": bonusMultiplier += 0.05;
            }
        }
        return bonusMultiplier;
    }

    /**
     * EVENTS
     */

    public static function getEvent(event:String):Int
    {
        return FunkBucks.getEvents().get(event) ?? 0;
    }

    static function getEvents():StringMap<String, Int>
    {
        if (FunkBucks.save.events == null) FunkBucks.save.events = new StringMap();
        return FunkBucks.save.events;
    }

    public static function setEvent(event:String, value:Int):Void
    {
        var _events:StringMap<String, Int> = FunkBucks.getEvents();
        _events.set(event, value);
        FunkBucks.save.events = _events;
        FunkBucks.flushSave();
    }

    /**
     * Check if the current local time has rolled over to the next day (or previous, fucking time traveller >_>)
     * If so, set all daily things in the mod to new values / reset them.
     */
    public static function checkForNewDay():Void
    {
        if (FunkBucks.save.dailyDate == null) FunkBucks.save.dailyDate = -1;
        var dailyDateNum:Int = FunkBucks.save.dailyDate;
        var date:Date = Date.now();
        var currentDate:Int = date.getDate();

        if (dailyDateNum != currentDate)
        {
            /**
             * Daily Songs
             */
            final supportedModdedVariations:Array<String> = FunkBucks.getSupportedModdedVariations();
            var baseGameSongIDs:Array<String> = SongRegistry.instance.listBaseGameEntryIds();
            baseGameSongIDs.remove("test"); // Test isn't easily available. (Does it even work properly? No.)
            baseGameSongIDs.remove("tutorial"); // Boring.
            // baseGameSongIDs.remove("spaghetti"); // Fine, you get to go.
            var dailySongs:Array<String> = [];
            for (i in 0...FunkBucks.dailySongCount)
            {
                var songID:String = baseGameSongIDs[FlxG.random.int(0, baseGameSongIDs.length - 1)];
                var songVariations:Array<String> = SongRegistry.instance.fetchEntry(songID).variations;
                songVariations = songVariations.filter(function(variationID:String):Bool
                {
                    return Constants.DEFAULT_VARIATION_LIST.contains(variationID) || supportedModdedVariations.contains(variationID);
                });
                dailySongs.push(songID + "-" + songVariations[FlxG.random.int(0, songVariations.length - 1)]);
                // Only one variation per song, thanks!
                baseGameSongIDs.remove(songID);
            }
            FunkBucks.setDailies(dailySongs);

            /**
             * Clover Coin Event
             */
            if (FunkBucks.hasObtainedPin("clovercoin"))
            {

            }

            FunkBucks.save.dailyDate = currentDate;
        }
    }

    public static function flushSave():Void
    {
        Save.instance.setModOptions("keoiki.funkbucks", FunkBucks.save);
    }

    /**
     * Returns a new save object with default values.
     */
    static function getDefaultSaveValues():Void
    {
        return
        {
            // Map of all pin IDs that have been unlocked.
            obtainedPins: new StringMap(),

            // Map of all box IDs that have been opened.
            openedBoxes: new StringMap(),

            // Map of all the current free boxes available.
            freeBoxes: new StringMap(),

            /**
            * An array of the current remaining dailies.
            * The date of the last daily. Works based on local time.
            * Number of dailies completed.
            */
            dailies: new Array(),
            dailyDate: 0,
            dailiesCompleted: 0,

            // An array of the previous 5 songs played, used for penalizing repeated songs.
            previousSongs: new Array(),

            /**
             * Number of FunkBucks currently held.
             * Number of FunkBucks obtained ever. Rewards do not increase this value.
             */
            funkBucks: 0,
            funkBucksLifetime: 0,

            /**
             * Number of Melody Stones currently held.
             * Number of Melody Stones obtained ever. Rewards do not increase this value.
             * The current pity for a Melody Stone. Has a range of 0-100, which equals to 0%-20%. (0%-60% on Dailies)
             */
            blueJewels: 0,
            blueJewelsLifetime: 0,
            blueJewelPity: 0,

            /**
             * Ophelia's current anger.
             * Ophelia's total anger.
             * Timestamp of the last initial anger.
             */
            opheliaAnger: 0,
            opheliaAngerTotal: 0,
            opheliaAngerTime: -1,
            
            // An array of all Reward IDs that have been collected.
            obtainedMilestones: new Array(),

            /**
             * Map of all event IDs that have been registered.
             * The meaning of each value of each event ID can vary.
             */
            events: new StringMap(),

            // The current modifier format. Either "multiplier" or "percentage".
            modifierText: "percentage",

            // Whether to show meaner or nicer dialogue.
            dialogueFlavor: "mean"
        }
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

    /**
     * Can you believe it, workschedules in MY funkin mod?
     * @return Name of the shopkeeper at work.
     */
    public static function getShopkeeper():String
    {
        var date:Date = Date.now();
        var day:Int = date.getDay();
        var hour:Int = date.getHours();
        if (day == 6 || day == 0 || (day == 5 && hour >= 18) || (day == 1 && hour < 12))
        {
            return "april";
        }
        return "ophelia";
    }

    function onUpdate(event:UpdateScriptEvent):Void
    {
        super.onUpdate(event);

        #if !mobile
        if (FlxG.keys.pressed.ANY)
        {
            FunkBucks.isMouseActive = false;
        }
        else if (Math.abs(FlxG.mouse.deltaViewX) > 24 || Math.abs(FlxG.mouse.deltaViewY) > 24)
        {
            FunkBucks.isMouseActive = true;
        }
        FunkBucks.isMouseTooFast = Math.abs(FlxG.mouse.deltaViewX) > 0 || Math.abs(FlxG.mouse.deltaViewY) > 0;
        #else  
        FunkBucks.isMouseActive = true;
        FunkBucks.isMouseTooFast = false;
        #end

        if (FlxG.keys.justPressed.L)
        {
            TimedCoinsManager.startEvent(90);
        }

        if (FlxG.keys.justPressed.FIVE)
        {
            // trace(ReflectUtil.getClassNameOf(FlxG.state));
            trace(FlxG.mouse.gameX, FlxG.mouse.gameY);
            trace(FlxG.mouse.x, FlxG.mouse.y);
        }

        if (FlxG.state is MainMenuState && FlxG.state.subState == null)
        {
            if (FlxG.keys.justPressed.P || TouchUtil.pressAction(menuPin))
            {
                FlxG.switchState(new Shop());
            }

            if (FlxG.keys.justPressed.Q)
            {
                // FunkBucks.save.obtainedMilestones = [];
                // FunkBucks.flushSave();
                trace(FunkBucks.getClaimedMilestones());
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

    override function onStateChangeEnd(event:StateChangeScriptEvent):Void
    {
        // trace(event.targetState);
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

            // var aaaa:FunkinSprite = new FunkinSprite(1100, 20).makeSolidColor(70, 70, 0xFFFF00FF);
            // aaaa.scrollFactor.set(0, 0);
            // event.targetState.add(aaaa);

            // var test:BAlphabet = new BAlphabet(0, 400, "<b>AA <c=00FF00>Color testing.</c></b>\nAAAAAAA\nBBBBB", { lineHeight: 90 });
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

            var talliesToUse = PlayStatePlaylist.isStoryMode ? Highscore.talliesLevel : Highscore.tallies;
            var scoreToUse:Float = PlayStatePlaylist.isStoryMode ? PlayStatePlaylist.campaignScore : PlayState.instance.songScore;

            var scoreData =
            {
                score: scoreToUse,
                tallies:
                {
                    sick: talliesToUse.sick,
                    good: talliesToUse.good,
                    bad: talliesToUse.bad,
                    shit: talliesToUse.shit,
                    missed: talliesToUse.missed,
                    combo: talliesToUse.combo,
                    maxCombo: talliesToUse.maxCombo,
                    totalNotesHit: talliesToUse.totalNotesHit,
                    totalNotes: talliesToUse.totalNotes
                }
            }

            var rank:ScoringRank = Scoring.calculateRank(scoreData) ?? ScoringRank.SHIT;
            
            // Effectively 40 coins per 100k score. (10 per 25k)
            var bucksToAward:Float = scoreToUse / 2500;
            // +50% for All Sicks, the great get richer, yikes.
            if (Highscore.tallies.totalNotes == Highscore.tallies.sick) bucksToAward *= 1.5;
            bucksToAward *= FunkBucks.getFunkCoinBonus();

            // No playing the same songs or weeks multiple times in a row!
            var previousSongs:Array<String> = FunkBucks.getPrevSongs();
            var currentDailies:Array<String> = FunkBucks.getDailies();
            var currentSongOrWeek:String = PlayStatePlaylist.isStoryMode ? PlayStatePlaylist.campaignId :
                    Std.string(PlayState.instance.currentChart.song.id + "-" + PlayState.instance.currentVariation);
            var penaltyCount:Int = previousSongs.filter(entry -> entry == currentSongOrWeek).length;
            var repeatPenalty:Float = FunkBucks.penalties[penaltyCount];
            var resultTextColor:String = FunkBucks.penaltyColors[penaltyCount];
            var jewelsToAward:Int = 0;
            var awardNormalCompletionJewel:Bool = false;

            FunkBucks.addBlueJewelPity(#if keoiki.endlessmode EndlessStatus.isEndless ? Math.floor(EndlessStatus.currentLoopFloat) : #end 1);

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
                if (FunkBucks.save.dailiesCompleted == null) FunkBucks.save.dailiesCompleted = -0;
                if (FlxG.random.bool(0.5))
                {
                    jewelsToAward = 2;
                }
                else if (FlxG.random.bool(2))
                {
                    jewelsToAward = 1;
                }
                bucksToAward *= 1.5;
                resultTextColor = "00FF00";
                awardNormalCompletionJewel = FlxG.random.bool((Math.pow(FunkBucks.getBlueJewelPity(), 2) / 1000) * 6);
                currentDailies.remove(currentSongOrWeek);
                FunkBucks.save.dailiesCompleted++;
                FunkBucks.setDailies(currentDailies);
                trace("Daily Bonus +50%! Remaining dailies: " + currentDailies);
            }
            else
            {
                bucksToAward *= repeatPenalty;
                awardNormalCompletionJewel = FlxG.random.bool((Math.pow(FunkBucks.getBlueJewelPity(), 2) / 1000) * 2);
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
                FunkBucks.setPrevSongs(previousSongs);
            }

            // Normal completion jewel stacks with the Daily Song one(s).
            if (awardNormalCompletionJewel)
            {
                jewelsToAward++;
                FunkBucks.save.blueJewelPity = 0;
                FunkBucks.flushSave();
            }
            
            bucksToAward = Math.ceil(bucksToAward);
            FunkBucks.addFunkCoins(bucksToAward);
            FunkBucks.addBlueJewels(jewelsToAward);

            trace(currentSongOrWeek, rank, bucksToAward, jewelsToAward, previousSongs);
            trace(awardNormalCompletionJewel, FunkBucks.getBlueJewelPity(), (Math.pow(FunkBucks.getBlueJewelPity(), 2) / 1000) * 2);

            var funkBucksText = new BAlphabet(40, 50, '<b><c=$resultTextColor>${bucksToAward > 0 ? "+" : ""}$bucksToAward</c></b> ${FBIcon.Buck}');
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

            if (jewelsToAward > 0)
            {
                var jewelsText = new BAlphabet(30, 70, '<b><c=82E9FF>+${jewelsToAward}</c></b> ${FBIcon.Jewel}');
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

            checkForSpecials(currentSongOrWeek, rank);
        }

        super.onSubStateOpenEnd(event);
    }

    function checkForSpecials(completionID:String, rank:ScoringRank):Void
    {
        #if keoiki.endlessmode
        if (EndlessStatus.isEndless) return;
        #end

        var wantedPinIDs:Array<String> = [];
        switch (completionID)
        {
            case "sserafim", "spaghetti-default": wantedPinIDs.push("spaghetti");
            default:
        }
        switch (rank)
        {
            case ScoringRank.PERFECT_GOLD: wantedPinIDs.push("rank-goldperfect");
            case ScoringRank.PERFECT: wantedPinIDs.push("rank-perfect");
            case ScoringRank.EXCELLENT: wantedPinIDs.push("rank-excellent");
            case ScoringRank.GREAT: wantedPinIDs.push("rank-great");
            case ScoringRank.GOOD: wantedPinIDs.push("rank-good");
            case ScoringRank.SHIT: wantedPinIDs.push("rank-shit");
            default: trace("Rank should've default to SHIT?");
        }
        if (wantedPinIDs.length > 0)
        {
            for (pinID in wantedPinIDs)
            {
                if (FunkBucks.hasObtainedPin(pinID)) continue;
                FunkBucks.pinUnlockQueue.push(pinID);
            }
        }
    }
}

/**
 * This class contains a constant for each text icon the mod adds.
 */
class FBIcon
{
    static final Buck:String = "&#xE000;";
    static final Jewel:String = "&#xE001;";
    static final Erect:String = "&#xE002;";
    static final Boyfriend:String = "&#xE003;";
    static final Pico:String = "&#xE004;";

    static final OpheliaMad:String = "&#xE010;";
    static final Star:String = "&#xE011;";
    static final Clover:String = "&#xE012;";
    static final Ophelia:String = "&#xE013;";
    static final April:String = "&#xE014;";
    
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
    static final FancyCoffret:String = "&#xE032;";
    static final ShimmeringPouch:String = "&#xE033;";

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