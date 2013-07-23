Author: Jandel
Version: 0.2
Addon to help manage alliance while shouting.
Abbreviation: //sh

This addon allows you to create a virtual alliance list in game. Why using the old piece of paper
or switching to a file .txt to manage your alliance shout?
This addon will allow you to create a job list and assign a player to the wanted job
Example:
Alliance
PARTY 1
[JOB]
[JOB]
[JOB]
...

PARTY 2
[JOB]
[JOB]
[JOB]
...

PARTY 3
[JOB]
[JOB]
[JOB]
...

All in-game commands are prefixed with "//sh", for example: "//sh help".

Command list:
* HELP
  Displays the help text

* POS <x> <y>
  Positions the alliance list to the given coordinates

* Clear [<party>]
  Clears the alliance list if no <party> is given. It will clear all the jobs
  only on <party> list if <party> is given.
  <party> formats are 'party1', 'pt1', '1', 'party2', 'pt2', '2',
  'party3', 'pt3', '3'

* SET <party> <job1> <job2> ...
  Insert the <job> into the <party> list.
  Both <party> and <job> are required.
  Support <party> formats are 'party1', 'pt1', '1', 'party2', 'pt2', '2',
  'party3', 'pt3', '3'
  Support <job> formats are all FFXI short jobs name ('whm', 'rdm', 'mnk', ...)
  and 'healer', 'support', 'dd'
  Examples:
  //sh set pt1 mnk				Adds a mnk to the party1 job list
  //sh set party2 mnk healer dd			Adds a mnk, an healer and a dd to the party2 job list
  //sh set 3 healer support brd dd dd dd	Adds the six jobs to the party3 job list

* DEL [<party>] <job>
  removes a job from the job list. <party> is optional and if is not given, the first
  occurrence of the given job will be deleted

* VISIBLE
  Toggles the visibility of the scoreboard. Data will continue to
  accumulate even while it is hidden.

* ADD [<job>] <player>
  Adds the <player> to the first free slot.
  If <job> is given then the <player> will be added to the first free slot of
  that corresponding <job>
  Examples:
  //sh add mnk Grievesk				Put the name Grievesk near the first free MNK slot in 
                                                the three party
  //sh add Jandel           			Put the name Jandel near the first job slot that is free

* RM <player>
  Removes the <player> from the party list

* SAVE <name>
  This function is not implemented yet

* LOAD <name>
  This function is not implemented yet

The settings file, located in addons/shoutHelper/data/settings.xml, contains
additional configuration options:
* posX - x coordinate for position
* posY - y coordinate for position
* bgTransparency - Transparency level for the background. 0-255 range
 
Caveats:

* This addon is still in development. Please report any issues or feedback to
  to me (Jandel on Ragnarok) on FFXIAH or Guildwork.

Thanks to Grievesk for encouraging me to write this addon :)

