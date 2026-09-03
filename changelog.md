## [2.0.0] - ??/??/2026 (hopefully September)

### Added

- Removed Ophelia.
- Added a new character: April.
    - She'd rather not be here.
- Added 62 new pins:
    - 10 Common
    - 14 Uncommon
    - 12 Rare
    - 12 Epic
    - 6 Legendary
    - 1 Mythic
    - 2 Special
- Added the "Fancy Coffret" box, with a cost of 200 FunkBucks.
- Added the "Shimmering Pouch" box, with a cost of 600 FunkBucks.
- Added Melody Stones.
    - They have a rare chance to be obtained after completing a song.
    - Your chance to obtain one increases with each song completed, up to 20% at 100 songs.
    - They have a higher chance to be obtained on Weeks and Daily Songs.
- Added the Converse section to the Shop.
    - In this menu you can talk to and ask April about various things.
    - Some options may change at certain points, so read while you can!
- Added the Exchange.
    - Found as an option in the Converse Menu.
    - You can exchange one Melody Stone for 1000 FunkBucks, or more to buy a Legendary or higher rarity pin you DON'T already own.
    - April will instead offer specific pins in a set sequence, which she has explicitly been told to NOT do.
- Added the Rewards section to the Shop.
    - You can claim extra some of the following based on your lifetime FunkBucks or Melody Stones collected, or how many of each box you've opened:
        - FunkBucks, Melody Stones, Pins, Boxes, Box Discounts, and Bonus FunkBucks Multiplier.
    - FunkBucks, Melody Stones, and Boxes obtained from Rewards don't count towards their respective milestones.
- Added the Clover Coin timed event.
    - Collect 8 Clover Coins scattered through out the menus of the game within the time limit to win!
    - Available once 50 pins have been collected.
    - First successfully completed event grants a pin.
    - Repeat events can only be tried once a day, have a stricter time limit, and grant 1000 FunkBucks.
- Added support for several modded variations as Dailies:
    - Remnants (Funkin' Remnants)
    - Gooey (Gooey Mix)
    - Reimu (Funkin' Incident)
    - Spooky Kids (Spooky Mix)
    - QT (QT Rewired, futureproof)
    - Hundrec (Hundrec Mix, futureproof)

### Changed

- The "PointlessPins" class and module name have been changed to "FunkBucks".
- The shop itself has gone under a major visual upgrade.
- Updated the currency display.
    - It can now be displayed anywhere in the game, if needed.
- The Pin Board graphics have been updated.
- The Pin Board now remembers the last pin you scrolled over and will snap to it when re-opening the menu.
- The text in the Box Menu has been moved around.
    - The opened box count text has been removed and the counts can now be seen in the new Rewards menu.
- Increased the amount of daily songs from 3 to 5.
- Increased the cost of the Cardboard Boxes from 15 to 20 FunkBucks.
- Increased the cost of the Small Giftboxes from 30 to 50 FunkBucks.
- Adjusted the chances of the Cardboard Boxes and Small Giftboxes.
- Rewrote how dialogue is handled, it isn't garbage code anymore.
- Redesigned dialogue boxes to be cooler.
- For every 12 loops in Endless Mode, the FunkBuck gain % raises by 25%, capping at 125% after the 48th loop.
    - When the pause menu states Loop #49, you're at max percentage.
    - For those insane enough to go over 1½ hours playing the same song, looking at you thelargelad on GameBanana.
    - 1-12: 25%
    - 13-24: 50%
    - 25-36: 75%
    - 37-48: 100%
    - 49 and after: 125%
    
## [1.3.0] - 18/08/2026

### Added

- Added 11 new pins:
    - 3 Commons
    - 5 Uncommons
    - 2 Rares
    - 1 Epic

### Changed

- Updated the "New Update Available" popup to have the ability to show summarised patch notes.
- Changed "Exchange" to "Converse".
- Changed both of the boxes' chances to match their chances in 2.0.
    - Mythics will be removed from Small Giftboxes in 2.0.
- Raised both boxes' costs by 5 FunkBucks.

### Fixed

- Fixes for FNF 0.8.6.

## [1.2.0] - 04/06/2026

### Added

- Added descriptions for locked pins explaining how to get them.
- Added "source" text to pins, to show where or what they're from, without clogging the pin description.

### Changed

- The box purchase confirmation is more clearly indicated.
- The FunkBuck text in the Results now shows up faster and follows the coloring scheme used for the Modifier lable.

## [1.1.2] - 26/03/2026

### Changed

- Added support for Game Version **0.8.4**.
- Changed **Better Alphabet** version requirement to **2.0.0 or higher**.
- Changed the "Help" option to "Exchange".

## [1.1.1] - 26/02/2026

### Fixed

- Fixed a crash when closing Freeplay on a song that requires scrolling to show its full name.

## [1.1.0] - 25/02/2026

### Added

- Added an option to display the Modifier Text as either: Percentage or Multiplier.
    - Percentage is the default.
- Implemented a version check system. Your local version and the version number from GitHub are compared, and alerts you if a new version exists.

### Changed

- Shop Upgrade! The Daily Board now has it's own light, so a part of it is no longer dark.
- Changed the Pin in the Main Menu from Boyfriend to a FunkBuck.
- Increased the size of the textbox in the Pins menu.
- Moved the text in the Boxes menu to be slightly further away from the edges of the screen.

### Fixed

- Fixed "PinData" throwing errors when accessing the save's fields. :obese_cat:

## [1.0.1] - 25/02/2026

### Fixed

- Attempt at fixing an occasional crash when exiting Freeplay.
- Force visibility on the back button on Mobile, HOPEFULLY fixing them not appearing sometimes, apparently.
- Fixed the Pins menu throwing an error when trying to load the board background file, due to filename case sensitivity on some platforms.
- Fixed immediately annoying Ophelia when closing the Boxes menu if the back button was overlaying her.

## [1.0.0] - 25/02/2026

Initial Release

### Added

- Added FunkBucks, the currency used in this mod. Can be obtained by beating weeks or individual songs.
- Added Penalties.
    - The previous 5 songs or weeks completed are stored, for each entry the penalty for the current song/week you're about to play increases as per the following list:
        - 66%, 33%, 0%, -50%, and -100% of the expected reward.
    - Discourages playing the same songs and weeks over and over to gain copious amounts of FunkBucks.
    - The current song or week penalty can be seen in the:
        - bottom-left of Freeplay, or
        - bottom-right of Story Mode.
    - Each song is added on variation basis, playing "Fresh" isn't the same as "Fresh Erect" or "Fresh (Pico Mix)".
- Added dailies; a random selection of 3 songs that grant an extra +50% bonus to your FunkBuck gains.
    - A song is removed from the daily list after completion AND added to the penalty list.
    - The +50% bonus overrides any penalties you might've otherwise had.
    - "Tutorial", "Test", and "Spaghetti" are excluded.
    - Weeks are excluded.
    - Modded songs and modded variations to vanilla songs are excluded.
    - Dailies reset at 0:00/12:00am, at your local time.
- Added the Shop, accessible by either pressing P on a keyboard or tapping/clicking with a mouse on the Boyfriend Pin shown at the top-left of the Main Menu.
- Added Ophelia, the 'shopkeeper' tasked with keeping track of your progress.
    - She keeps track of how many FunkBucks you've earned and how many of each box you've opened.
        - These values will be used in the *Rewards* section later, she was rushed and couldn't get everything done in time.
    - Do not annoy or insult her.
- Added 34 pins:
    - 22 Common
    - 7 Uncommon
    - 2 Rare
    - 2 Mythic
    - 1 Special
- Added 2 mystery boxes:
    - **Cheap Cardboard Box**; can give Commons or Uncommons. Costs 10 FunkBucks.
    - **Small Giftbox**; can give Commons, Uncommons, Rares, or Mythics. *(Subject to change.)* Costs 25 FunkBucks.
- Added compatibility with the "Endless Mode" mod. **(Version 2.0.0 and above)**
    - FunkBuck gain is reduced to 25% when Endless Mode is enabled.