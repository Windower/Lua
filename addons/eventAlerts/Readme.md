Author: Ricky Gall
Version: 1.15

Replacement for yarnregex for Windower 4 I made for a friend. Uses the chat log so filters must be off. At least until i figure out another way to do it. Keeps track of various event related things. Such as, VW proc messages, mob casting, mob tp moves, TH procs and cor rolls, as well as others. Digi of shiva created the icon and was the driving force behind testing/giving me the idea to do this.

Abbreviation: //eAlert

You have access to the following commands:
 1. //eAlert bgcolor &lt;alpha&gt; &lt;red&gt; &lt;green&gt; &lt;blue&gt; --Sets the color of the box.
 2. //eAlert text &lt;red&gt; &lt;green&gt; &lt;blue&gt; --Sets text color.
 2. //eAlert font &lt;size&gt; &lt;name&gt; --Sets text font and size.
 3. //eAlert pos &lt;posx&gt; &lt;posy&gt; --Sets position of box.
 4. //eAlert duration &lt;seconds&gt; --Sets the timeout on the notices.
 5. //eAlert track &lt;mobname&gt; --Adds mob to the tracking list.
 6. //eAlert danger &lt;dangerword&gt; --Adds danger word to list. Danger words atm need the mob name to match too.
 7. //eAlert unload --Save settings and close eventAlerts.
 8. //eAlert reset --resets the box back to empty.
 9. //eAlert help --Shows this menu.


Requirements:
 data folder in eventAlerts folder
 warning.png in data folder
 eventAlerts.lua