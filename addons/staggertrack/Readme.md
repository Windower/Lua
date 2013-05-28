**Author:** Ricky Gall  
**Version:** 1.5  
**Description:**  
Very light-weight stagger tracker for voidwatch. Its purpose is to catch the chat lines like "The fiend appears (extremely/highly) vulnerable to (ability/spell/ws)!" and capture this to a box in colored text form. Extremely will color the text white, highly red, and neither is a light blue. It does not track when weaknesses are hit, since that is not easy in the slightest due to it not telling exactly which is hit in the chat log. When one scrolls past in the chatlog it will get captured to the box. Thanks for your interest, and i hope you like it.

**Abbreviation:** //strack

**Commands:**
 1. //strack bgcolor <alpha> <red> <green> <blue> --Sets the color of the box.
 2. //strack text <size> <red> <green> <blue> --Sets text color and size.
 3. //strack pos <posx> <posy> --Sets position of box.
 4. //strack unload --Save settings and close strack.
 5. //strack reset --resets the box back to empty.
 6. //strack help --Shows this menu.

**Changes:**  
v1.09 - v1.5:  
* Added a timeout on the stagger messages.  
* Changed the name from wtbox to stagger track  
* Deprecated the chatlines setting due to the timeout  
* Fixed minor bugs with the text box writing  

v1.08 - v1.09:  
* Added check for aura changing that will reset the list.  
* Changed the way //strack reset works so your settings that you have changed stay.  
* Added check for atma wearing that will reset the list.  
* With the above 2 checks the //strack reset command is not needed but i left it in anyway  

