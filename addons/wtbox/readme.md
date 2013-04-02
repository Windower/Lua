Author: Ricky Gall

Version: 1.09

Very light-weight weakness tracker for voidwatch. Its purpose is to catch the chat lines like "The fiend appears (extremely/highly) vulnerable to (ability/spell/ws)!" and capture this to a box in colored text form. Extremely will color the text white, highly red, and neither is a light blue. It does not track when weaknesses are hit, since that is not easy in the slightest due to it not telling exactly which is hit in the chat log. When one scrolls past in the chatlog it will get captured to the box. Currently a max of 6 are shown in the box at a time (i'm not sure why it's 6 cause chatlines is defaulted to 5 but i'll work on that) when this limit is reached it'll just push the top proc off the list. Thanks for your interest, and i hope you like it.

Abbreviation: //wtbox

You have access to the following commands:
 1. //wtbox bgcolor &lt;alpha&gt; &lt;red&gt; &lt;green&gt; &lt;blue&gt; --Sets the color of the box.
 2. //wtbox text &lt;size&gt; &lt;red&gt; &lt;green&gt; &lt;blue&gt; --Sets text color and size.
 3. //wtbox pos &lt;posx&gt; &lt;posy&gt; --Sets position of box.
 4. //wtbox unload --Save settings and close wtbox.
 5. //wtbox reset --resets the box back to empty.
 6. //wtbox help --Shows this menu.

changes:
v1.08 - v1.09
	-Added check for aura changing that will reset the list.
	-Changed the way //wtbox reset works so your settings that you have changed stay.
	-Added check for atma wearing that will reset the list.
	-With the above 2 checks the //wtbox reset command is not needed but i left it in anyway
