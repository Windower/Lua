**Authors:** Braden, Sechs  
**Version:** 1.3  
**Date:** 08/03/2017

**Description:**  
Omen is an addon that creates a custom window that tracks the current floor's Primary and Secondary objectives.
The addon also tracks time left for secondary objs and their current in-progress status.
Text colour, font size and window position can be configured inside the config.xml file that gets created the first time you run the addon, alternatively the window can be dragged and dropped wherever on the screen.

**Config file:**  
Add a `<yourcharname></yourcharname>` section into the config.xml and report the fields you wish to set to different values from the default ones.
Colours are expressed in R, G, B values and they range from 0 to 255

**To-Do list:**
* Fix or remove completely the audio warnings for main and secondary floor completitions
* Evaluate the possibility to add custom in-game commands to change values without having to manually edit the xml config file
* The addon, once loaded, is always active and waiting for relative messages in the chatlog. I would like to change this and make so the addon is in full sleep mode when loaded and activates only on zone change into Reisen_Henge

**Bugs list:**
* After completing mini-boss or mega-boss floors, the text window contracts and covers part of the text on the left side
* If you get a "free floor", the addon stops tracking for possible secondary objectives
* If a packet is lost and a successful or partial completition messages won't be displayed in your chatlog, the addon will of course fail to catch to get it and won't update the tracking window. I don't think there is a way around to fix this though.
* The addon has never been tested in the alternative path that branches after floor 2 is completed. It is supposed to handle up to 10 objetives but I've never got a chance to personally test it, yet.
