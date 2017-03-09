Author: Suji
Version: 1.09
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

* REPORTSTAT <stat> [<playerName>] [<target>]
  RS <stat> [<playerName>] [<target>]
  Reports the given stat. Supported stats are:
      mavg, mrange, acc, ravg, rrange, racc, critavg, critrange, crit,
      rcritavg, rcritrange, rcrit, wsavg, wsacc
  
  'playerName' may be the name of a player if you wish to see only one player.
  
  For 'target', with no argument, it will go to whatever you have
  your current chatmode set to. You may also pass the standard FFXI chat
  abbreviations as arguments. Support arguments are 's', 't', 'p', 'l'.
  If you pass 't' (for tell), you must also pass a player name to send
  the tell to.

  Examples:
  //sb reportstat acc       -- Sends acc report your default chatmode
  //sb rs crit              -- Same as above
  //sb rs crit p            -- Explicitly to party
  //sb rs acc tell suji     -- Sends acc to Suji
  //sb rs acc t suji        -- Same as above
  //sb rs acc tulia t suji  -- Report accuracy for Tulia only and send it in tell to Suji
  
* FILTER
  This takes one of three sub-commands.
  * FILTER SHOW
  Shows the current mob filters.

* FILTER ADD <mob1> <mob2> ...
  Adds mob(s) to the filters. These can all be substrings. Legal Lua
  patterns are also allowed.

  * FILTER CLEAR
  Clears all mobs from the filter.

* VISIBLE
  Toggles the visibility of the scoreboard. Data will continue to
  accumulate even while it is hidden.

* STAT <statname> [<player>]
  View specific parser stats. This will respect the current filter settings.
  Valid stats are: acc, racc, crit, rcrit
  Examples:
  //sb stat acc            Shows accuracy for everyone
  //sb stat crit Flippant  Only show crit rate for Flippant

The settings file, located in addons/scoreboard/data/settings.xml, contains
additional configuration options:
* posX - x coordinate for position
* posY - y coordinate for position
* numPlayers - The maximum number of players to display damage for
* bgTransparency - Transparency level for the background. 0-255 range
* font - The font for the Scoreboard. This defaults to Courier but it
         it may be changed to one of the following fonts:
         Fixedsys, Lucida Console, Courier, Courier New, MS Mincho,
         Consolas, Dejavu Sans Mono.
* fontsize - Size of Scoreboard's font
* sbcolor - Color of scoreboard's chat log output
* showallidps - Set to true to display the alliance DPS, false otherwise.
* resetfilters - Set to true if you want filters reset when you "//sb reset", false otherwise.
* showfellow - Set to true to display your adventuring fellow's DPS, false otherwise.
 
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

Thanks to Flippant for all of the helpful feedback and comments and to Zumi
for encouraging me to write this in the first place.
