## Adding a new Pin

Adding a new pin is as simple as a json merge! Create a `pins.json` in `_merge/YOURMOD/data/pointlesspins/` and put the following in:
```json
[
    { "op": "add", "path": "/Common/pins/-", "value": { "id": "merge-test", "name": "Merging Test Pin" }}
]
```
Remember to change the `id` and `name`. The `Common` can be changed to a different rarity to add a pin into that one instead. `Common`, `Uncommon`, `Rare`, `Epic`, `Legendary`, `Mythic`, `Divine`, and `Special` are valid rarities by default.

Images for pins are found in `images/pointlesspins/pins/`. Create this location within your mod to add the pin sprites into.

Valid pin fields are:
* `id`: The ID the mod uses to save your pin as in the save data. The file the game looks for to load as a sprite is also named as such.
* `name`: The name of the pin shown on the Unlock State and the Pin Board.
* `description`: A description for pins to show on the Unlock State and the Pin Board. `Optional.`
* `scale`: Scale of the pin as shown in the Pin Board. Double of this value is used in the Unlock State. Default is `0.5`. `Optional.`
* `artist`: Used to show who made the pin. Recommended in case of multiple pin artists. `Optional.`
* `source`: Used to show where a specific pin originates from, be it an FNF Mod, a show, a comic, etc. `Optional.`
  * You can use pre-defined tags to add an icon to this text, the current tags are:
    * MOD
    * INTERNET
    * GAME
  * All tags are enclosed in "#" (such as `#MOD#`) and are lowercased for the tag checking.
* `special`: Used to make a pin a single-time unlock. Also makes it unobtainable from Boxes. You must create an unlock condition yourself. `Optional.`
* `lockedText`: Used to show a different text when hovered over in the Pin Board while the Pin is still locked. `Optional, but heavily recommended if special is true.`
* `hidden`: Used to completely hide a Pin from the board until it's unlocked. It also isn't counted for in the Rarity and Total numbers while locked. `Optional.`

## Unlocking custom Pins

New pins by default are available to be opened from Boxes. If that's not what you want, set `special` on the pin you want to `true` and set the `lockedText` to inform players on how to get it, or don't `¯\_(ツ)_/¯`.

Now you have to come up with an unlock method, be it completing a song or something else. When that condition is met, call the function `FunkBucks.pushPinToUnlockQueue(pinID)` which takes the Pin ID of the pin you want to be unlocked. Now the next time the player enters the Shop, the pin will be unlocked before control to move around is given to the player.

Do note that:
* `pushPinToUnlockQueue` checks if the pin is already unlocked and if so, skips over it.
* The queue is automatically unlocked when exiting the game without any popups.
  * If you think players might close the game before entering the Shop again, use `FunkBucks.setObtainedPin(pinID)` to instantly unlock a pin, without showing any popup.
  * If you do want to show a pin is unlocked immediately, you can create an Unlock State and open it immediately:
```haxe
// ... be mindful of where you open it though as it may interfere with other game functions.
import funkbucks.PinUnlockState;
// ...
var substate = new PinUnlockState(FunkBucks.getPinByID("pinID"));
openSubState(substate);
```

## Adding a new Rarity

Adding a new rarity is just another json merge. You must give it an order, so it gets sorted properly, a color, and a pins array.
```json
[
    { "op": "add", "path": "/Trash", "value": { "order": 800, "color": "404040", "pins": [] }},
    { "op": "add", "path": "/Trash/pins/-", "value": { "id": "merge-test", "name": "Merging Test Pin" }}
]
```
The order value for all default rarities is at every 100, with Common at `0` and Special at `700`.
If a rarity has no pins it won't show up on the Pin Board. (Like with `Divine` currently.)