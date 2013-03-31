Author: Ricky Gall
Modifications: Sebastien Gomez
Version: 2.00
A very simple yarnball replacement for use until timers gets finished.

file requierement:
*windower 4
*Timers plugin for W4
*full libs folder in the addons folder	
*Extend.xml (i made this and must be edited by the user in the exact same manner as it already is)

	thers an example is the file already which is:
	
	<b|id="32"|gearid="14094"|duration="15"|slot="feet"|name="Rogue's Poulaines"|/>
	
	b = nothing, its just a tag, but however must be there
	| = seperators for the addon to differentiate between sections, these MUST be ther with no spaces
	id = the id of the buff you would receive from a jobability or spell (these can be found in the status.xml) and must be correct or will not work.
	gearid = the id of the item in question for example if you search "items_armor.txt" in the resources folder for "rogue's poulaines" you will see the id is as above.
	duration = the time the buff would be extended by.
	slot = where that peice of gear would go.
	name = name of the item. (please use the exact spelling found in the resourses files

*status.xml (can be found in windower4\plugins\resources\status.xml)   (please copy this file from that location to BuffDuration incase you don't have it already or an update has happened)
	
	status.xml is somewhat incomplete and can be user edited to add timers for more spells. a duration of 0 or -1 will make it such that the buff doesnt get used.
	
Abbreviation: //buffDuration

There is only 1 command for buffDuration.
 1. //buffDuration showalt -- Tracks your alt's buffs gained/cast 