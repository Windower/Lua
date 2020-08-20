**Author:**  Snaps<br>
**Version:**  1.0<br>
**Date:** June 13th, 2017<br>

# craft #

* A Final Fantasy XI Crafting Addon

#### Commands: ####
1. help - Shows a menu of commands in game.
2. repeat [count] - Repeats synthesis (default 1) using the lastsynth command.
- repeat - Repeats 1 synthesis.
- r 13 - Repeats 13 synthesis.
3. make [recipe] [count] - Issue a synthesis command using a recipe name.
- make "Sheep Leather" - Makes 1 Sheep Leather.
- m "Sheep Leather" 5 - Makes 5 Sheep Leather.
4. put [bag] - Moves all copies of an item into available bags.
- put "Dragon Mask" - Moves all Dragon Masks in inventory to any available bags.
- put "Dragon Mask" satchel - Moves all Dragon Masks inventory to Mog Satchel.
- put "Dragon Mask" safe2 - Moves all Dragon Masks to Mog Safe 2 (if available).
5. delay - Sets the delay between crafting attempts (default 24s)
- delay 30 - Sets the delay between crafting to 30 seconds.
6. food [item] - Sets a food item that will be consumed automatically while crafting (default None.)
- food - Sets the auto food to None.
- food "Kitron Macaron" - Sets the auto food to Kitron Macaron.
7. pause - Pauses the addon.
8. resume - Resumes the addon.
9. clear - Clears all pending items in the queue.
10. jiggle [key] - Set a key that will be pressed between every queue item (default disabled.)
- jiggle - Disables the jiggle feature.
- jiggle escape - Sets the jiggle key to escape.
11. support - Toggles auto support/ionis (default off)
- Must be near an NPC that offers Ionis or advanced imagery support to work.
12. find [details] - Search for a recipe fromt the recipes list using a string.
- find "Pizza" - Finds and displays all recipes containing the string "Pizza".
- find "Pizza" details - Finds and displays all recipes containing the string "Pizza".  The recipe ingredients and crystal are also displayed.
13. status - Display some information about the addon's current state.
14. display - Toggles whether outgoing crafting packets are displayed in the chat log.
