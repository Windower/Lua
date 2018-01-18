**Author:**  Cairthenn<br>
**Version:**  1.1<br>
**Date:** Nov. 11, 2015<br>

# DressUp #

* Allows you to specify custom gear models for yourself, others, or individual players. Also allows for 1:1 model replacement similar to the functionality of .DAT swapping.
* Emulates BlinkMeNot functionality to prevent model blinking.
* **Uses packets**.

----

#### Settings ####

* DressUp uses 'settings.xml' in its data folder for all settings related to models and blinking.
* If you choose to edit this manually, this file uses **model IDs** for gear. You can look up the appropriate model IDs in the files in the main directory.

**Abbreviation:** //du

#### Commands: ####
1. help : Shows a menu of commands in game
2. self/others/player &lt;player name (if player was selected)&gt; [race/face/&lt;item slot&gt;] [&lt;item name&gt;/&lt;race nam&gt;/&lt;face&gt;]
  - Assigns models to yourself, others, or an individual player as specified.
  - Supports IDs as well as names for items/races. Specify male or female if necessary.
3. clear [self/others/player] <player name> [race/face/<item slot>]
	- Clears settings for the selection. Player name specific to player option.
4. replace [race/face/&lt;item slot&gt;] &lt;selection1&gt; &lt;selection2&gt;
	- Handles 1:1 replacement, similar to .DAT swapping. 
5. blinking [self/others/party/follow/all] [always/target/combat/all] [on/off]
	- Changes blinking settings. Toggles if nothing is specified.
	- Also accepts "bmn" and "blinkmenot" as command prefix.
6. autoupdate
	- Your character's appearance will update as you type commands if this setting is on.
7. load/save/delete <profile name>
	- Creates a profile to be used for your own characters appearance.
	- Profiles named JOB or NAME_JOB will be checked for on job changes.
	
--

#### To do: ####
* Add weapons, ranged weapons, and shield models.
* Allow for monster models.
 * While this is currently possible, others seem to lose their animations if transformed into a monster. 
* Refine profile system
