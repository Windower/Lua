WTBox v1.05
This addon (wtbox for short) is a very light-weight weakness tracker for voidwatch. Its purpose is to catch the chat lines like "The fiend appears (extremely/highly) vulnerable to (ability/spell/ws)!" and capture this to a box in colored text form. Extremely will color the text white, highly red, and neither is a light blue. It does not track when weaknesses are hit, since that is not easy in the slightest due to it not telling exactly which is hit in the chat log. When one scrolls past in the chatlog it will get captured to the box. Currently a max of 6 are shown in the box at a time (i'm not sure why it's 6 cause chatlines is defaulted to 5 but i'll work on that) when this limit is reached it'll just push the top proc off the list. Thanks for your interest, and i hope you like it.

You have access to the following commands:
 1. wtbox bgcolor <alpha> <red> <green> <blue> --Sets the color of the box.
 2. wtbox text <size> <red> <green> <blue> --Sets text color and size.
 3. wtbox pos <posx> <posy> --Sets position of box.
 4. wtbox unload --Save settings and close wtbox.
 5. wtbox reset --resets the box back to empty.
 6. wtbox help --Shows this menu.