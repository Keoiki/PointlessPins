## [2.0.0] - ??/03/2026

### Added

- Added Blue Jewels. They have a rare chance to be obtained after completing a song.
    - Your chance to obtain one increases with each song completed, up to 10% at 100 songs.
    - They have a higher chance on Daily Songs.
    - You can only have 20 Blue Jewels at a time, so make sure you spend them once you're at full capacity.
- Added the Exchange section to the Shop.
    - You can exchange one Blue Jewel for 500 FunkBucks, or more to buy a Legendary or higher rarity pin you DON'T already own.
- Added the Rewards section to the Shop.
    - You can claim extra some of the following based on your lifetime FunkBucks or Blue Jewels collected, or how many of each box you've opened:
        - FunkBucks
        - Blue Jewels
        - Pins
        - Boxes
        - Box Discounts
            - A permanent discount when buying boxes.
        - Bonus FunkBucks
            - A permanent multiplier to how many FunkBucks you earn when completing songs and weeks.
- Added 49 new pins:
    - 12 Common
    - 16 Uncommon
    - 10 Rare
    - 6 Epic
    - 4 Legendary
    - 1 Special
- Added support for the following modded variations as Dailies:
    - Remnants (Funkin' Remnants)
    - Gooey (Gooey Mix)
    - Reimu (Funkin' Incident)
    - Spooky Kids (Spooky Mix)
    - QT (QT Rewired, futureproof)
    - Hundrec (Hundrec Mix, futureproof)
- Added descriptions for locked pins explaining how to get them, without being too specific.
- Added "source" text to pins, to show where or what they're from, without clogging the pin description.
- Added more dialogue for Ophelia.

### Changed

- The shop itself has gone under a major visual upgrade.
- The box purchase confirmation is more clearly indicated.
- The FunkBuck text in the Results now show up faster and follows the coloring scheme used for the Modifier lable.
- Increased the cost of Cardboard Boxes from 10 to 20 FunkBucks.
- Added a 1% chance to get a Rare pin from Cardboard Boxes.
- Increased the cost of Small Giftboxes from 25 to 50 FunkBucks.
- Added a 0.25% chance to get a Legendary pin from Small Giftboxes.
- Rewrote how dialogue is handled, it isn't garbage code anymore.

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