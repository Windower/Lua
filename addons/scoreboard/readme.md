Author: Suji
Version: 0.1
Addon to show alliance DPS and damage in real time.
Abbreviation: //sb

This addon allows players to see their DPS live while fighting enemies. Party
and alliance member DPS is also dispalyed. In addition to DPS, each player's
total damage and their percent contribution is also displayed.

Notable features:
* Live DPS
* Ability to filter only the mobs you want to see damage for
* 'Report' command for reporting damage back to your party

All commands are prefixed with "//sb", for example "//sb help".
Command list:
* HELP
  Displays the help text
* POS <x> <y>
  Positions the scoreboard to the given (x,y) coordinates
* RESET
  Resets all the data that's been tracked so far.
* REPORT
  Reports the damage to your party. This will go to whatever you have
  your chatmode set to.
* Filters
  Lists the current mob filters that you have set.
* Add <mob1> <mob2> ...
  Adds mob(s) to the filters. These can all be substrings. Legal lua
  patterns are also allowed.
* Clear
  Clears all mobs from the filter.
* Start
  Manually starts the DPS counter. This also happens automatically when
  someone in your group does damage.
* Stop
  Stops the DPS counter to keep your DPS estimate accurate.
  
For convenience, binding "//sb stop" to a free key is suggested.
  
Limitations:
* There's no way to correctly and automatically stop DPS tracking so users
  must do this manually for the DPS value to remain accurate.

Known issues:
* Enspell and Spike damage are not currently parsed
* User settings not yet storable
