Author: Sebastien Gomez
Original Author: Ricky Gall
Version: 2.02
A very substancial yarnball replacement for use until timers gets finished or to use permanently.

file requierement:
*windower 4
*Timers plugin for W4
*full libs folder in the addons folder	
*Extend.xml (i made this and must be edited by the user in the exact same manner as it already is)

	thers an example in the file already which is:
	
	<b id="32" gearid="14094" duration="15" slot="feet">Rogue's Poulaines</b>
	
	b = nothing, its just a tag, but however must be there
	id = the id of the buff you would receive from a jobability or spell (these can be found in the status.xml) and must be correct or will not work.
	gearid = the id of the item in question for example if you search "items_armor.txt" in the resources folder for "rogue's poulaines" you will see the id is as above.
	duration = the time the buff would be extended by.
	slot = where that peice of gear would go.
	name of the item must go inbetween > .... </b> (please use the exact spelling found in the resourses files)

*status.xml (can be found in windower4\plugins\resources\status.xml)
	
	status.xml is somewhat incomplete and can be user edited to add timers for more spells. a duration of 0 or -1 will make it such that the buff doesnt get used.

* a seperate icons folder is required if you wish to have icons for the buffs. i populated one for people to use download here:
	http://www.mediafire.com/download.php?ln055jcbvbb5q2c
	this folder will go in :
	windower4/plugins/icons
	its a seperate folder so dont merge it into spells or abilitys folder that already exists.
	if you choose to not use this folder your icon will default to the ? icon.

* In buffDuration.lua more Etendables may be added if they can be extended by perpetuance, lightArts, tabula rasa or composure.
	perpetuance time extension is 2.5 currently. if you do not have the af3+2 hands you may edit it to 2 to get correct time.
	
*Because this addon uses the Timers plugin to create timers if you find errors it is not necessarily from this end, also this means that you can edit Timers settings to place the timers where you want.
	<customX>200</customX>
	<customY>350</customY>
	<customTimerLimit>8</customTimerLimit>
the above is what you want to edit in Timers to relocate your addon position.
	
Abbreviation: //buffDuration

There is only 1 command for buffDuration.
 1. //buffDuration showalt -- Tracks your alt's buffs gained/cast 
