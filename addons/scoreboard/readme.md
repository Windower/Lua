Author: Suji
Version: 0.2
Addon to show alliance DPS and damage in real time.
Abbreviation: //sb

This addon allows players to see their DPS live while fighting enemies. Party
and alliance member DPS is also dispalyed. In addition to DPS, each player's
total damage and their percent contribution is also displayed.

Notable features:
* Live DPS
* Ability to filter only the mobs you want to see damage for
* 'Report' command for reporting damage back to your party

DPS accumulation starts whenever someone in your party or alliance damages an enemy.
It then automatically pauses when someone in your party or alliance kills an enemy.
Both stopping and starting can be done manually if you prefer and and you can enable
or disable auto-start/auto-stop in the settings file.

See data/settings.xml for additional configuration options.

All in-game commands are prefixed with "//sb", for example "//sb help".
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
* FILTERS
  Lists the current mob filters that you have set.
* Add <mob1> <mob2> ...
  Adds mob(s) to the filters. These can all be substrings. Legal lua
  patterns are also allowed.
* CLEAR
  Clears all mobs from the filter.
* START
  Manually starts the DPS counter. This also happens automatically when
  someone in your group does damage.
* STOP
  Manually stops the DPS counter to keep your DPS estimate accurate.
  
Caveats:
* DPS is an approximation, although I tested it manually and found it to
  be very accurate.
* Note that if you die to an enemy, auto-stop will not trigger and your
  time will continue to bring your DPS down. You must stop manually in this
  case by using '//sb stop'.


Known issues:
* Enspell and Spike damage are not currently parsed
* Skillchain damage is not currently parsed
* AOE damage is not fully attributed properly
