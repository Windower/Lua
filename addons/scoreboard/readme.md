Author: Suji
Version: 0.5b
Addon to show alliance DPS and damage in real time.
Abbreviation: //sb

This addon allows players to see their DPS live while fighting enemies. Party
and alliance member DPS is also dispalyed. In addition to DPS, each player's
total damage and their percent contribution is also displayed.

Notable features:
* Live DPS
* You can still parse damage even if you enable chat filters.
* Ability to filter only the mobs you want to see damage for.
* 'Report' command for reporting damage back to where you like.

DPS accumulation is active whenever anyone in your alliance is currently
in battle.

All in-game commands are prefixed with "//sb" or "//scoreboard", for
example: "//sb help".

Command list:
* HELP
  Displays the help text

* POS <x> <y>
  Positions the scoreboard to the given coordinates

* RESET
  Resets all the data that's been tracked so far.

* REPORT [<target>]
  Reports the damage. With no argument, it will go to whatever you have
  your current chatmode set to. You may also pass the standard FFXI chat
  abbreviations as arguments. Support arguments are 's', 't', 'p', 'l'.
  If you pass 't' (for tell), you must also pass a player name to send
  the tell to. Examples:
  //sb report          Reports to current chatmode
  //sb report l        Reports to your linkshell
  //sb report t suji   Reports in tell to Suji

* FILTERS
  Lists the current mob filters that you have set.

* ADD <mob1> <mob2> ...
  Adds mob(s) to the filters. These can all be substrings. Legal lua
  patterns are also allowed.

* CLEAR
  Clears all mobs from the filter.

The settings file, located in addons/scoreboard/data/settings.xml, contains
additional configuration options:
* posX - x coordinate for position
* posY - y coordinate for position
* numPlayers - The maximum number of players to display damage for
* bgTransparency - Transparency level for the background. 0-255 range


Caveats:
* DPS is an approximation, although I tested it manually and found it to
  be very accurate. Because DPS accumulation is based on the game's notion
  of when you are in battle, if someone else engages before you, your DPS
  will suffer. Try to engage fast to get a better approximation.

* The methods used in here cause some discrepancies with the data reported
  by KParser. In some cases, Scoreboard will report more damage, which 
  generally indicates that KParser is not including something (ie, Scoreboard
  will be more accurate). However, there are cases where KParser is reporting
  damage that Scoreboard is not, and I'm currently focused on resolving this
  issue in particular.

* This addon is still in development. Please report any issues or feedback to
  to me (Suji on Phoenix) on FFXIAH or Guildwork.
