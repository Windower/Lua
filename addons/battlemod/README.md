Author: Byrth

Version: 3.04

Date: 3/11/13

Battlemod, packet version

Abbreviation: //bm

Commands:  
* help - shows a menu of these commands in game
* colortest - Shows the 509 possible colors for use with the settings file
* reload - Reloads the settings file
* unload - unloads Battlemod
* condensebuffs - Condenses Area of Effect buffs, Default = True
* condensebattle - Condenses battle logs according to your settings file, Default = True
* condensedamage - Condenses similar damage messages within an attack round, Default = True
* cancelmulti - Cancles multiple consecutive identical lines, Default = True
* oxford - Toggle use of oxford comma, Default = True
* commamode - Toggle comma-only mode, Default = False
* targetnumber - Toggle target number display, Default = True

Purpose: To allow chat log customization.

Installation Instructions (from the Windower 4 Launcher):

* 1 Start your copy of Windower 4 and select the "Addons" menu up top in the Launcher.
* 2 Click the icon next to "Battlemod"
* 3 Log in to the game!
* 4 Alter the settings as you wish. ("//bm colortest" will let you see the color options and )
* 5 If you have changed the settings, you can use "//bm reload" to load them in game.

Settings Files:  
The settings files for battlemod are composed of 3 to 25 xml files (depending on how much you like unique filters). XML files can be opened with Notepad, edited, and closed saved safely. If you are going to "Save As..." an xml from Notepad, be sure to change "Text Documents (.txt)" to "All Files" file type and make sure the file ends in ".xml"  

* data/settings.xml         - contains basic flags that control the features of the program.  
* data/colors.xml           - contains all the color codes relevant to the program, which can be adjusted using colors from the colortext command.  
* filters/filters.xml       - contains the chat filter settings and is explained more thoroughly therein.  
* filters/filters-<job>.xml - Several examples are provided, but these are specific filter files that will load for your individual jobs. You can use this to, for instance, make sure your healing jobs can always see damage taken (by unfiltering the <monsters></monsters> section or make sure your zerg jobs don't have to see the entire alliance's damage spam.  

Known Issues:  
* Counters, Spikes, and Retaliations are the wrong color for some reason.  
* The "__damage" colors don't do anything, but have been left in the settings file for potential future uses.  
* Using //bm colortest and then expanding your chat log on small window size clients (640x480) can cause crashes. (Your guess is as good as mine)  
* AoE buffs only use the first message response, so if it has no effect on the user then it will appear to have no effect on everyone even if it did.  
* The settings files are much larger and more complicated than v1. (Sorry, it's because there's more options)  
* This plugin bypasses and renders invalid all chat filters.  
