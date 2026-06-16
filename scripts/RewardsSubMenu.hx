package funkbucks;

import balphabet.BAlphabet;
import flixel.FlxObject;
import flixel.input.mouse.FlxMouseEvent;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import funkbucks.objects.BoxSprite;
import funkbucks.objects.PinSprite;
import funkin.audio.FunkinSound;
import funkin.graphics.FunkinSprite;
import funkin.mobile.ui.FunkinBackButton;
import funkin.modding.base.ScriptedFlxSpriteGroup;
import funkin.ui.MusicBeatSubState;
import funkin.util.MathUtil;
import funkin.util.TouchUtil;
using Lambda;

class RewardsSubMenu extends MusicBeatSubState
{
    // Important
    var STATE:String = "CHOOSING";
    var POSITION:Int = 0;
    var POSITION_ARRAY:Array<Int> = [0, 0];
    var PAGE:Int = 0;
    var CATEGORY:String = "none";
    final categories = [
        "funkbucks" => {
            name: "funkbucks",
            description: "Total FunkBucks obtained.",
            requirementIcon: FBIcon.Buck,
            order: 0,
            rewards: [
                "1" => {id: "funkbucks01", requirement: 100, type: RewardType.FunkBuck, reward: 50},
                "2" => {id: "funkbucks02", requirement: 500, type: RewardType.Box, reward: "cardboard|5"},
                "3" => {id: "funkbucks03", requirement: 1000, type: RewardType.FunkBuck, reward: 100},
                "4" => {id: "funkbucks04", requirement: 2000, type: RewardType.Box, reward: "smallgiftbox|5"},
                "5" => {id: "funkbucks05", requirement: 3000, type: RewardType.FunkBuck, reward: 150},
                "6" => {id: "funkbucks06", requirement: 4000, type: RewardType.FunkBuck, reward: 200},
                "7" => {id: "funkbucks07", requirement: 5000, type: RewardType.BonusFunkBuck, reward: 2.5},
                "8" => {id: "funkbucks08", requirement: 10000, type: RewardType.Jewel, reward: 1},
                "11" => {id: "funkbucks11", requirement: 20000, type: RewardType.BonusFunkBuck, reward: 2.5},
                "12" => {id: "funkbucks12", requirement: 25000, type: RewardType.Pin, reward: "funkbuck"},
                "13" => {id: "funkbucks13", requirement: 30000, type: RewardType.Jewel, reward: 3},
                "14" => {id: "funkbucks14", requirement: 40000, type: RewardType.BonusFunkBuck, reward: 5.0},
                "15" => {id: "funkbucks15", requirement: 50000, type: RewardType.FunkBuck, reward: 5000}
            ]
        },
        "melodystones" => {
            name: "melodystones",
            description: "Total Melody Stones obtained.",
            requirementIcon: FBIcon.Jewel,
            order: 1,
            rewards: [
                "1" => {id: "melodystone01", requirement: 1, type: RewardType.FunkBuck, reward: 1000},
                "2" => {id: "melodystone02", requirement: 2, type: RewardType.Pin, reward: "melodystone"},
                // "3" => {id: "melodystone03", requirement: 5, type: RewardType.Box, reward: "smallgiftbox"},
                "4" => {id: "melodystone04", requirement: 10, type: RewardType.FunkBuck, reward: 10000},
                // "5" => {id: "melodystone05", requirement: 15, type: RewardType.Pin, reward: "funkbuck"},
                "6" => {id: "melodystone06", requirement: 20, type: RewardType.FunkBuck, reward: 20000}
            ]
        },
        "totalboxes" => {
            name: "totalboxes",
            description: "Total Boxes opened.",
            requirementIcon: "total",
            order: 2,
            rewards: [
                "1" => {id: "totalboxes", requirement: 25, type: RewardType.Box, reward: "cardboard|5"}
            ]
        },
        "cardboard" => {
            name: "cardboard",
            description: "Total Cardboard Boxes opened.",
            requirementIcon: FBIcon.CardboardBox,
            order: 3,
            rewards: [
                "1" => {id: "cardboardbox01", requirement: 10, type: RewardType.FunkBuck, reward: 100},
                "2" => {id: "cardboardbox02", requirement: 50, type: RewardType.Pin, reward: "cardboardbox"},
                "3" => {id: "cardboardbox03", requirement: 100, type: RewardType.DiscountBox, reward: 5},
                "4" => {id: "cardboardbox04", requirement: 250, type: RewardType.FunkBuck, reward: 500},
                "5" => {id: "cardboardbox05", requirement: 500, type: RewardType.Jewel, reward: 2},
                "6" => {id: "cardboardbox06", requirement: 750, type: RewardType.FunkBuck, reward: 1500},
                "7" => {id: "cardboardbox07", requirement: 1000, type: RewardType.Jewel, reward: 5}
            ]
        },
        "smallgiftbox" => {
            name: "smallgiftbox",
            description: "Total Small Giftboxes opened.",
            requirementIcon: FBIcon.SmallGiftbox,
            order: 4,
            rewards: [
                "1" => {id: "smallgiftbox01", requirement: 10, type: RewardType.FunkBuck, reward: 250},
                "2" => {id: "smallgiftbox02", requirement: 40, type: RewardType.Pin, reward: "smallgiftbox"},
                "3" => {id: "smallgiftbox03", requirement: 80, type: RewardType.DiscountBox, reward: 5},
                "4" => {id: "smallgiftbox04", requirement: 150, type: RewardType.FunkBuck, reward: 1500},
                "5" => {id: "smallgiftbox05", requirement: 300, type: RewardType.Jewel, reward: 3},
                "6" => {id: "smallgiftbox06", requirement: 550, type: RewardType.FunkBuck, reward: 10000},
                "7" => {id: "smallgiftbox07", requirement: 800, type: RewardType.Jewel, reward: 8}
            ]
        },
        "fancycoffret" => {
            name: "fancycoffret",
            description: "Total Fancy Coffrets opened.",
            requirementIcon: FBIcon.FancyCoffret,
            order: 5,
            rewards: [
                "1" => {id: "fancycoffret", requirement: 10, type: RewardType.FunkBuck, reward: 200},
                // Box Discount: 2.5%
            ]
        },
        "shimmeringpouch" => {
            name: "shimmeringpouch",
            description: "Total Shimmering Pouches opened.",
            requirementIcon: FBIcon.ShimmeringPouch,
            order: 6,
            rewards: [
                "1" => {id: "shimmeringpouch", requirement: 10, type: RewardType.FunkBuck, reward: 200},
                // Box Discount: 2.5%
            ]
        }
    ];
    final X_BETWEEN_ITEMS:Float = 220;
    final Y_BETWEEN_ITEMS:Float = 178;
    var allowedMovement:Bool = true;
    var hasUpdatedRewardText:Bool = false;
    var totalItems:Int = 14;
    var currentShownItems:Array<FlxObject> = [];
    var menuDots:Array<FunkinSprite> = [];

    // UI

    var itemHitboxes:Array<FunkinSprite> = [];

    var darkOverlay:FunkinSprite;
    var cursor:FunkinSprite;
    var arrowLeft:FunkinSprite;
    var arrowRight:FunkinSprite;

    var bottomBar:FunkinSprite;
    var rewardText:BAlphabet;

    var coolBackButton:FunkinBackButton;

    override function create():Void
    {
        cursor = new FunkinSprite(60, 140).loadTexture("cursor");
        add(cursor);

        bottomBar = new FunkinSprite(0, FlxG.height - 130).makeSolidColor(FlxG.width, 130, 0xBF000000);
        add(bottomBar);

        rewardText = new BAlphabet(FlxG.width / 2, FlxG.height - 110, "Reward Text Here", { lineHeight: 70 });
        rewardText.alignment = "center";
        rewardText.scale.set(0.45, 0.45);
        add(rewardText);
        
        arrowLeft = new FunkinSprite(220, 260).loadTexture("shop/boxarrow");
        arrowLeft.flipX = true;
        add(arrowLeft);

        arrowRight = new FunkinSprite(FlxG.width - 220, 260).loadTexture("shop/boxarrow");
        arrowRight.x -= arrowRight.width - 10;
        add(arrowRight);

        for (i in 0...9)
        {
            var hitbox:FunkinSprite = new FunkinSprite(0, 0).makeSolidColor(160, 160, 0x0000FF00);
            hitbox.x = FlxG.width / 2 - X_BETWEEN_ITEMS + (X_BETWEEN_ITEMS * (i % 3)) - 80;
            hitbox.y = 48 + Y_BETWEEN_ITEMS * (Math.floor((i % 9) / 3));
            add(hitbox);
            itemHitboxes.push(hitbox);
        }

        var hitboxArrowLeft:FunkinSprite = new FunkinSprite(arrowLeft.x - 82, arrowLeft.y - arrowLeft.height).makeSolidColor(160, arrowLeft.height * 3, 0x00FF0000);
        add(hitboxArrowLeft);
        itemHitboxes.push(hitboxArrowLeft);

        var hitboxArrowRight:FunkinSprite = new FunkinSprite(arrowRight.x - 32, arrowRight.y - arrowRight.height).makeSolidColor(160, arrowRight.height * 3, 0x000000FF);
        add(hitboxArrowRight);
        itemHitboxes.push(hitboxArrowRight);

        coolBackButton = new FunkinBackButton(FlxG.width - 220, FlxG.height - 200, 0xFFFFFFFF, goBack, 1.0, true);
        #if !mobile
        coolBackButton.visible = FunkBucks.isMouseActive;
        FlxMouseEvent.add(coolBackButton, coolBackButton.playHoldAnim, coolBackButton.playConfirmAnim);
        #end
        add(coolBackButton);

        darkOverlay = new FunkinSprite(-64, -64).makeSolidColor(FlxG.width + 128, FlxG.height + 128, 0xFF000000);
        darkOverlay.alpha = 0;
        darkOverlay.zIndex = 1000;
        add(darkOverlay);

        refresh();

        populateItems("none");

        super.create();       
    }

    var prevMouseActive:Bool = FunkBucks.isMouseActive;
    public function update(elapsed:Float):Void
    {
        handleControls(elapsed);

        if (controls.BACK_P && allowedMovement)
        {
            goBack();
        }

        coolBackButton.visible = !allowedMovement ? false : #if mobile true; #else FunkBucks.isMouseActive; #end

        // if (prevMouseActive != FunkBucks.isMouseActive) { }
        prevMouseActive = FunkBucks.isMouseActive;

        super.update(elapsed);
    }

    function goBack():Void
    {
        switch (CATEGORY)
        {
            case "none": close();
            default:
            {
                POSITION_ARRAY = [0, 0];
                PAGE = 0;
                hasUpdatedRewardText = false;
                populateItems("none", PAGE);
            }
        }
    }

    function populateItems(category:String, page:Int = 0):Void
    {
        CATEGORY = category;
        for (item in currentShownItems)
        {
            item.destroy();
        }
        for (dot in menuDots)
        {
            dot.destroy();
        }
        currentShownItems = [];
        menuDots = [];
        totalItems = 0;
        if (CATEGORY == "none")
        {
            var categoryItems:Array = categories.array();
            categoryItems.sort((a, b) -> {
                return FlxSort.byValues(-1, a.order, b.order);
            });
            for (ind => value in categoryItems)
            {
                if (totalItems < page * 9 || totalItems >= (page + 1) * 9) continue;
                var item:RewardItem = new RewardItem(totalItems, null, -1, RewardType.Category, value.name, CATEGORY);
                item.x = FlxG.width / 2 - X_BETWEEN_ITEMS + (X_BETWEEN_ITEMS * item.position[0]);
                item.y = 200 + Y_BETWEEN_ITEMS * item.position[1];
                add(item);
                currentShownItems.push(item);
                totalItems++;
            }
        }
        else
        {
            var categoryItems:Array = categories.get(CATEGORY).rewards.array();
            categoryItems.sort((a, b) -> {
                return FlxSort.byValues(-1, a.requirement, b.requirement);
            });
            for (ind => value in categoryItems)
            {
                totalItems++;
                if (totalItems - 1 < page * 9 || totalItems - 1 >= (page + 1) * 9) continue;
                var item:RewardItem = new RewardItem(totalItems - 1, value.id, value.requirement, value.type, value.reward, CATEGORY);
                item.x = FlxG.width / 2 - X_BETWEEN_ITEMS + (X_BETWEEN_ITEMS * item.position[0]);
                item.y = 200 + Y_BETWEEN_ITEMS * item.position[1];
                add(item);
                currentShownItems.push(item);
            }
        }

        var pages:Int = Math.ceil(totalItems / 9);
        for (i in 0...pages)
        {
            var dot:FunkinSprite = new FunkinSprite(FlxG.width / 2 + 40 * i - 20 * pages + 10, 680).loadTexture("menucountdot");
            dot.scale.set(0.75, 0.75);
            dot.alpha = 0.2;
            menuDots.push(dot);
            add(dot);
        }
        // trace(currentShownItems.length);
    }

    var handleAccept:Bool = false;
    var tappedPosition:Int = -1;
    function handleControls(elapsed:Float):Void
    {
        var prevX:Int = POSITION_ARRAY[0];
        var prevY:Int = POSITION_ARRAY[1];

        if (allowedMovement)
        {
            if (controls.UI_LEFT_P)
            {
                POSITION_ARRAY[0]--;
            }
            if (controls.UI_RIGHT_P)
            {
                POSITION_ARRAY[0]++;
            }
            if (controls.UI_UP_P)
            {
                POSITION_ARRAY[1]--;
            }
            if (controls.UI_DOWN_P)
            {
                POSITION_ARRAY[1]++;
            }

            for (i in 0...itemHitboxes.length)
            {
                if (TouchUtil.pressAction(itemHitboxes[i], camera))
                {
                    switch(i)
                    {
                        case 9:
                        {
                            if (arrowLeft.visible)
                            {
                                PAGE--;
                                POSITION_ARRAY = [0, 0];
                                populateItems(CATEGORY, PAGE);
                            }
                        }
                        case 10:
                        {
                            if (arrowRight.visible)
                            {
                                PAGE++;
                                POSITION_ARRAY = [0, 0];
                                populateItems(CATEGORY, PAGE);
                            }
                        }
                        default:
                        {
                            tappedPosition = i;
                            POSITION_ARRAY = [i % 3, Math.floor((i % 9) / 3)];
                            if (tappedPosition == POSITION % 9) handleAccept = true;
                        }       
                    }
                }
            }
        }

        var previousPosition:Int = POSITION;
        var previousPage:Int = PAGE;
        POSITION = (POSITION_ARRAY[0] + ((POSITION_ARRAY[1]) * 3) + (PAGE * 9));
        var resultingPosition = POSITION % 9;
        var itemsOnPage:Int = Math.min(9, totalItems - (PAGE * 9));

        // This shit is so ass.
        if (POSITION_ARRAY[0] < 0)
        {
            if (PAGE == 0)
            {
                POSITION_ARRAY[0] = 0;
            }
            else
            {
                PAGE--;
                populateItems(CATEGORY, PAGE);
                POSITION_ARRAY[0] = 2;
            }
        }
        else if (POSITION_ARRAY[0] > 2)
        {
            if (totalItems > (PAGE + 1) * 9)
            {
                PAGE++;
                populateItems(CATEGORY, PAGE);
                POSITION_ARRAY[0] = 0;
                POSITION = (POSITION_ARRAY[0] + ((POSITION_ARRAY[1]) * 3) + (PAGE * 9));
                resultingPosition = POSITION % 9;
                while (POSITION >= totalItems)
                {
                    POSITION_ARRAY[1]--;
                    POSITION = (POSITION_ARRAY[0] + ((POSITION_ARRAY[1]) * 3) + (PAGE * 9));
                    resultingPosition = POSITION % 9;
                }
                while (resultingPosition > itemsOnPage - 1)
                {
                    POSITION_ARRAY[0]--;
                }
            }
            else
            {
                POSITION_ARRAY[0] = 2;
            }
        }
        else
        {
            if (resultingPosition > itemsOnPage - 1)
            {
                POSITION_ARRAY[0] = prevX;
            }
        }

        if (POSITION_ARRAY[1] < 0)
        {
            POSITION_ARRAY[1] = 0;
        }
        else
        {
            if (resultingPosition > itemsOnPage - 1 || POSITION >= (PAGE + 1) * 9)
            {
                POSITION_ARRAY[1] = prevY;
            }
        }
        
        POSITION = (POSITION_ARRAY[0] + ((POSITION_ARRAY[1]) * 3) + (PAGE * 9));
        resultingPosition = POSITION % 9;

        for (i in 0...menuDots.length)
        {
            menuDots[i].alpha = i == PAGE ? 1 : 0.2;
        }

        arrowLeft.visible = PAGE > 0;
        arrowRight.visible = totalItems > (PAGE + 1) * 9;

        var intendedCursorX:Float = (FlxG.width / 2 - X_BETWEEN_ITEMS + (X_BETWEEN_ITEMS * POSITION_ARRAY[0])) - cursor.width / 2;
        var intendedCursorY:Float = (200 + Y_BETWEEN_ITEMS * POSITION_ARRAY[1]) - cursor.height + 10;

        cursor.x = MathUtil.smoothLerpPrecision(cursor.x, intendedCursorX, elapsed, 0.5);
        cursor.y = MathUtil.smoothLerpPrecision(cursor.y, intendedCursorY, elapsed, 0.5);

        if (prevX != POSITION_ARRAY[0] || prevY != POSITION_ARRAY[1])
        {
            // pinMoveSound.play(true);
            hasUpdatedRewardText = false;
        }

        var currentItem = currentShownItems[resultingPosition];
        if (!hasUpdatedRewardText)
        {
            if (currentItem == null) return;
            if (CATEGORY == "none")
            {
                var count:Int = 0;
                switch (categories.get(currentItem.reward).name)
                {
                    case "funkbucks": count = FunkBucks.getFunkCoinsLifetime();
                    case "melodystones": count = FunkBucks.getBlueJewelsLifetime();
                    case "totalboxes":
                        for (box => opens in FunkBucks.getOpenedBoxCounts())
                        {
                            if (!["cardboard", "smallgiftbox", "fancycoffret", "shimmeringpouch"].contains(box)) continue;
                            count += opens;
                        }
                    default: count = FunkBucks.getOpenedBoxCount(categories.get(currentItem.reward).name);
                }
                rewardText.text = '${categories.get(currentItem.reward).description}\n<scale=0.8><color=00FF00>Total:</color> $count</scale>';
            }
            else
            {
                var currentCategory = categories.get(CATEGORY);
                var beforeReq:String = "open";
                var afterReq:String = "in total";
                if (CATEGORY == "funkbucks" || CATEGORY == "melodystones")
                {
                    beforeReq = "obtain";
                    afterReq = "total";
                }
                else if (CATEGORY == "totalboxes")
                {
                    afterReq = "boxes";
                }
                if (!currentItem.claimed)
                {
                    if (!currentItem.reached)
                    {
                        rewardText.text = 'You must $beforeReq ${currentItem.requirement} ${currentCategory.requirementIcon} $afterReq to unlock this reward.';
                    }
                    else
                    {
                        rewardText.text = 'You have ${beforeReq}ed ${currentItem.requirement} ${currentCategory.requirementIcon} $afterReq to unlock this reward.\n<c=FF0000>Not claimed!</c>';
                    }
                }
                else
                {
                    rewardText.text = 'You have ${beforeReq}ed ${currentItem.requirement} ${currentCategory.requirementIcon} $afterReq to unlock this reward.\n<c=00FF00>Claimed!</c>';
                }
            }
            hasUpdatedRewardText = true;
        }

        if (controls.ACCEPT_P || handleAccept)
        {
            if (CATEGORY == "none")
            {
                POSITION_ARRAY = [0, 0];
                PAGE = 0;
                populateItems(currentItem.reward, PAGE);
                hasUpdatedRewardText = false;
            }
            else
            {
                if (currentItem.reached && !currentItem.claimed)
                {
                    trace("Attempting to claim reward: " + currentItem.rID);
                    FunkBucks.addClaimedMilestone(currentItem.rID);
                    switch (currentItem.type)
                    {
                        case RewardType.FunkBuck:
                        {
                            _parentState.addFunkBucks(currentItem.reward);
                            populateItems(CATEGORY, PAGE);
                            rewardText.text = 'You got ${currentItem.reward} ${FBIcon.Buck} FunkBucks!';
                            // hasUpdatedRewardText = false;
                        }
                        case RewardType.Jewel:
                        {
                            _parentState.addBlueJewel(currentItem.reward);
                            populateItems(CATEGORY, PAGE);
                            rewardText.text = 'You got ${currentItem.reward} ${FBIcon.Jewel} Melody Stones!';
                            // hasUpdatedRewardText = false;
                        }
                        case RewardType.Box:
                        {
                            FunkBucks.addFreeBox(currentItem.reward, currentItem._rollCount);
                            populateItems(CATEGORY, PAGE);
                            rewardText.text = 'You got ${currentItem._rollCount} free rolls for ${currentItem._boxName}!';
                            // hasUpdatedRewardText = false;
                        }
                        case RewardType.Pin:
                        {
                            var unlockState:PinUnlockState = new PinUnlockState(FunkBucks.getPinByID(currentItem.reward));
                            unlockState.cameras = [camera];
                            unlockState.closeCallback = () -> {
                                populateItems(CATEGORY, PAGE);
                                hasUpdatedRewardText = false;
                            };
                            openSubState(unlockState);
                        }
                        case RewardType.BonusFunkBuck:
                        {
                            populateItems(CATEGORY, PAGE);
                            rewardText.text = 'The amount of FunkBucks you earn from songs\nhas been permanently increased by <c=00FF00>${currentItem.reward}%</c>!';
                        }
                        case RewardType.DiscountBox:
                        {
                            populateItems(CATEGORY, PAGE);
                            rewardText.text = 'The cost of boxes has been permanently\ndecreased by <c=00FF00>${currentItem.reward}%</c>!';
                        }
                        default: 
                        {
                            populateItems(CATEGORY, PAGE);
                            hasUpdatedRewardText = false;
                        }
                    }
                }
                else
                {
                    FunkinSound.playOnce(Paths.sound("CS_locked"));
                    cursor.x += FlxG.random.float(-20, 20);
                    cursor.y += FlxG.random.float(-20, 20);
                }
            }
        }

        handleAccept = false;

        if (FlxG.keys.justPressed.SHIFT)
        {
            trace("Page: " + PAGE + ", Position: " + POSITION, resultingPosition);
            trace("Items on page: " + itemsOnPage);
            trace("Total Items: " + totalItems);
            trace(handleAccept);
        }
    }

    override function destroy():Void
    {
        #if !mobile
        FlxMouseEvent.remove(coolBackButton);
        #end
        super.destroy();
    }
}

class RewardItem extends ScriptedFlxSpriteGroup
{
    var icon:FunkinSprite;
    var number:BAlphabet;
    var lock:FunkinSprite;
    var checkmark:FunkinSprite;

    var position:Array<Int>;
    var rID:String;
    var requirement:Int;
    var type:RewardType;
    var reward:String;
    var category:String;

    var reached:Bool;
    var claimed:Bool;

    // Only used for Boxes
    var _rollCount:Int = 0;
    var _boxName:String;

    public function new(_position:Int, _rID:String, _requirement:Int, _type:RewardType, _reward:String, _category:String):Void
    {
        super(0, 0);
        position = [_position % 3, Math.floor((_position % 9) / 3)];
        rID = _rID;
        requirement = _requirement;
        type = _type;
        reward = _reward;
        category = _category;

        // mfw no "type == RewardType.Box"
        switch (type)
        {
            case RewardType.Box:
            {
                var ass:Array<String> = reward.split("|");
                reward = ass[0];
                _rollCount = Std.parseInt(ass[1]);
                for (box in FunkBucks.boxData)
                {
                    if (box.id == reward)
                    {
                        _boxName = box.name;
                        break;
                    }
                }
            }
            default:
        }

        setupItem();

        // trace(rID, requirement, reward, position);
    }

    function setupItem():Void
    {
        var isCategory:Bool = false;

        claimed = switch (type)
        {
            case RewardType.Category: false;
            default: FunkBucks.hasClaimedMilestone(rID);
        }

        switch (type)
        {
            case RewardType.Category:
            {
                isCategory = true;

                icon = new FunkinSprite(0, 8).loadTexture('shop/rewards/category-$reward');
                icon.x -= icon.width / 2;
                icon.y -= icon.height;
            }
            case RewardType.Pin:
            {
                icon = new PinSprite(0, 0);
                icon.isUnknown = !FunkBucks.hasObtainedPin(reward);
                if (!icon.isUnknown) icon.isUnlocked = true;
                icon.setupPin(reward, "", "", 0.5, claimed ? 0.5 : 1, true);
                icon.y -= 70;
            }
            case RewardType.Box:
            {
                icon = new BoxSprite(0, 0);
                icon.updateBoxInfoByID(reward, true);
                icon.scale.set(0.8, 0.8);
                icon.x -= 30;
                icon.y -= 20;

                number = new BAlphabet(0, 0, '<b><c=00FF00>$_rollCount Free</c></b>');
                number.alignment = "center";
                number.scale.set(0.4, 0.4);
            }
            case RewardType.FunkBuck:
            {
                final funkbuckThresholds:Array<Int> = [100, 250, 500];

                var i:Int = 0;
                for (ind => value in funkbuckThresholds)
                {
                    if (reward - 1 >= value)
                    {
                        i = ind + 1;
                    }
                }

                icon = new FunkinSprite(0, 0).loadTexture('shop/rewards/funkbuck0${i + 1}');
                icon.x -= icon.width / 2;
                icon.y -= icon.height - 8;

                number = new BAlphabet(0, 0, '<b>$reward</b> ${FBIcon.Buck}');
                number.alignment = "center";
                number.scale.set(0.4, 0.4);
            }
            case RewardType.Jewel:
            {
                number = new BAlphabet(0, 0, '<b>$reward</b> ${FBIcon.Jewel}');
                number.alignment = "center";
                number.scale.set(0.4, 0.4);
            }
            case RewardType.Song:
            {
                trace("SONG reward type is not implemented");
            }
            case RewardType.DiscountBox:
            {
                icon = new BAlphabet(0, -100, '<b>Box\nDiscount</b>');
                icon.alignment = "center";
                icon.scale.set(0.5, 0.5);

                number = new BAlphabet(0, 0, '<b><c=00FF00>-$reward%</c></b>');
                number.alignment = "center";
                number.scale.set(0.4, 0.4);
            }
            case RewardType.BonusFunkBuck:
            {
                icon = new BAlphabet(0, -100, '<b>FunkBuck\nBonus</b>');
                icon.alignment = "center";
                icon.scale.set(0.5, 0.5);

                number = new BAlphabet(0, 0, '<b><c=00FF00>+$reward%</c></b>');
                number.alignment = "center";
                number.scale.set(0.4, 0.4);
            }
            default: trace("Invalid reward type.");
        }

        if (claimed)
        {
            reached = true;
        }
        else if (!isCategory)
        {
            switch (category)
            {
                case "funkbucks": reached = FunkBucks.getFunkCoinsLifetime() >= requirement;
                case "melodystones": reached = FunkBucks.getBlueJewelsLifetime() >= requirement;
                default: reached = FunkBucks.getOpenedBoxCount(category) >= requirement;
            }
        }
        else
        {
            reached = true;
        }

        if (icon != null) 
        {
            icon.alpha = claimed ? 0.5 : 1;
            icon.color = reached ? 0xFFFFFFFF : 0xFF3F3F3F;
            if (!reached)
            {
                switch (type)
                {
                    case RewardType.DiscountBox, RewardType.BonusFunkBuck:
                    {
                        icon.forEach((letter) ->
                        {
                            letter.setColor(0);
                        });
                    }
                    default:
                }
            }
            this.add(icon);
        }
        if (number != null)
        {
            number.alpha = claimed ? 0.5 : 1;
            number.visible = reached;
            this.add(number);
        }
        if (!reached)
        {
            lock = new FunkinSprite(-40, -120).loadTexture("shop/rewards/lock");
            this.add(lock);
        }
        if (claimed)
        {
            switch (type)
            {
                // case RewardType.Box: icon.animation.play("Opened");
                default:
            }
        }
    }
}

enum RewardType
{
    Category;
    Pin;
    Box;
    FunkBuck;
    Jewel;
    Song;
    DiscountBox;
    BonusFunkBuck;
}