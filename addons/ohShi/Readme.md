**Author:** Ricky Gall  
**Version:** 2.0  
**Description:**  
Replacement for yarnregex for Windower 4 I made for a friend. Uses the chat log so filters must be off. At least until i figure out another way to do it. Keeps track of various event related things. Such as, VW proc messages, mob casting, mob tp moves, TH procs and cor rolls, as well as others. Digi of shiva created the icon and was the driving force behind testing/giving me the idea to do this. Digi also created the default mob list/danger list and chose the name.

**Abbreviation:** //ohShi

**Commands:**
 1. ohShi bgcolor &lt;alpha&gt; &lt;red&gt; &lt;green&gt; &lt;blue&gt; --Sets the color of the box.
 2. ohShi text &lt;red&gt; &lt;green&gt; &lt;blue&gt; --Sets text color.
 2. ohShi font &lt;size&gt; &lt;name&gt; --Sets text font and size.
 3. ohShi pos &lt;posx&gt; &lt;posy&gt; --Sets position of box.
 4. ohShi duration &lt;seconds&gt; --Sets the timeout on the notices.
 5. ohShi track &lt;vw/legion/other/abyssea/meebles/dangerous&gt; &lt;mobname&gt; --Add mob to tracking list. <br/>--dangerous will cause all tpmoves/spell casting to trigger the warning icon/color
 6. ohShi track &lt;vw/legion/other/abyssea/meebles/dangerous&gt; &lt;mobname&gt; --Remove mob from tracking list.
 7. ohShi danger &lt;spell/ws&gt; &lt;dangerword&gt; --Adds danger word to list.
 8. ohShi staggeronly (true/false) --Switches on/off stagger only mode.
 9. ohShi unload --Save settings and close ohShi.
 10. ohShi help --Shows this menu.
 
**Changes:**
*v2.0
 *Fixed issue with nil value on ws or blue magic cast from player
 *Fixed magic messages due to the spell resources being different
 *Added confirmation and boxflash on settings change
 *Settings file updated. moblist.xml deprecated