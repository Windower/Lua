**Author:** Ricky Gall  
**Version:** 2.55 
**Description:**  
Replacement for yarnregex for Windower 4 I made for a friend. Uses the chat log so filters must be off. At least until i figure out another way to do it. Keeps track of various event related things. Such as, VW proc messages, mob casting, mob tp moves, TH procs and cor rolls, as well as others. Digi of shiva created the icon and was the driving force behind testing/giving me the idea to do this. Digi also created the default mob list/danger list and chose the name.

**Abbreviation:** //ohShi

**Commands:**
  1. help - Brings up this menu.
  2. showrolls | selfrolls - Show corsair rolls in tracker | only own rolls.
  3. staggeronly - Only show voidwatch stagger notices.
  4. track(on/off) &lt;abyssea/dangerous/legion/meebles/other/voidwatch&gt; (name) - Begin or stop tracking (type (default: other)) of mob (name).
  5. spell/ws(on/off) &lt;name&gt; - Start or stop watching for &lt;name&gt; spell|ws.  
**The following commands all correspond to the tracker:**
  6. fonttype &lt;name&gt; - change to (name) font 
  7. fontsize &lt;size&gt; - change to (size) font
  8. pos &lt;x&gt; &lt;y&gt; - change boxes x/y coordinates (can click/drag as well)
  9. bgcolor &lt;r&gt; &lt;g&gt; &lt;b&gt; - change background color (r: red) (g: green) (b: blue)
 10. txtcolor &lt;r&gt; &lt;g&gt; &lt;b&gt; - change text color  (r: red) (g: green) (b: blue)
 11. duration &lt;time&gt; - Changes the duration things stay in tracker.
 12. settings - shows current textbox settings
 13. show/hide - toggles visibility of the tracker so you can make changes.
 
**Changes:**  
* v2.55  
 * Added vagary weakness tracking  
* v2.5  
 * Complete overhaul.  
 * Added ability to click/drag the text box  
 * Add selfrolls command (if this is on only your rolls will show)  
 * Due to the overhaul, all of your settings (except your moblist) will be reset to default.  
* v2.1  
 * On load/help command announce addon version  
* v2.0  
 * Fixed issue with nil value on ws or blue magic cast from player  
 * Fixed magic messages due to the spell resources being different  
 * Added confirmation and boxflash on settings change  
 * Settings file updated. moblist.xml deprecated  

