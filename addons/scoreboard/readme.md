Author: Suji
Version: 0.3b
Addon to show alliance DPS and damage in real time.
Abbreviation: //sb

This addon allows players to see their DPS live while fighting enemies. Party
and alliance member DPS is also dispalyed. In addition to DPS, each player's
total damage and their percent contribution is also displayed.

Notable features:
* Live DPS
* You can still parse damage even if you enable chat filters.
* Ability to filter only the mobs you want to see damage for
* 'Report' command for reporting damage back to your party

DPS accumulation is active whenever anyone in your alliance is currently
in battle.

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

  
Caveats:
* DPS is an approximation, although I tested it manually and found it to
  be very accurate.
* The methods used in here create some discrepancies with the data reported
  by KParser. In some cases, Scoreboard will report more damage, which 
  generally indicates that KParser is not including something (ie, Scoreboard
  will be more accurate). However, there are cases where KParser is reporting
  damage that Scoreboard is not, and I'm currently focused on resolving this
  issue in particular.
* This addon is still in development. Please report any issues you find to me
  on FFXIAH or Guildwork (Suji on Phoenix)
