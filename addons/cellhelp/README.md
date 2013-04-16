Authors: Balloon, Krizz
Version: 2.0
Date: 20130415
Cell Helper, for old Salvage
Abbreviation: //ch
Commands:
* help - Shows a menu of commands in game
* pos <x> <y> - Positions the Lot Order box. Default location is 1000,250.
* hide - Hides the Lot Order box
* show - Shows the Lot Order box
* set [set id] - Loads set from settings file. Default is set1.
* mode [lots/nolots] - If set to nolots, ll will not lot cells. Default is lots.
Other Information:
* If you need to remove a cell from the Lot Order box, type in "/echo [You] obtains a --[cellname] cell--." You must have the dashes around the cellname, and the period at the end.
* If you have gear you want to pass, add them in the <p#pass> tags. If not, leave the value as 0. * As with the base LL, items already in the pool cannot be lotted/passed when the profile is loaded.
Otherwise you will see errors.
To do:
* Support for more than 4 people
* Remove (or create a toggle) for the Item Counter.
* Adjust player tags so that <pass> and <lot> are available within for each player. Should also resolve the existing pass tag error messages.
Known Issues:
* Pass tag errors
