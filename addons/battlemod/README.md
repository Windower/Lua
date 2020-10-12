Author: Byrth

Version: 3.21

Date: 20/9/15

Battlemod, packet version

Abbreviation: //bm

Commands:

Toggles:  
* simplify - Condenses battle text using custom messages (Default: True)
* condensetargets - Collapse similar messages with multiple targets (Default: True)
    * targetnumber - Toggle condensed target number display (Default: True)
    * condensetargetname - Toggle target name condensation (Default: False)
    * oxford - Toggle use of oxford comma (Default: True)
    * commamode - Toggle comma-only mode (Default: False)
* condensedamage - Collapses similar damage messages with the same target (Default: True)
    * swingnumber - Toggle condensed damage number display (Default: True)
    * sumdamage - Sums condensed damage if true, comma-separated if false (Default: True)
    * condensecrits - Condenses critical hits and normal hits together (Default: False)
* cancelmulti - Cancels multiple consecutive identical lines (Default: True)
* showonernames - Shows the name of the owner on pet messages (Default: False)
* crafting - Toggle early display of crafting results (Default: True)

Utilities:  
* colortest - Shows the 509 possible colors for use with the settings file
* reload - Reloads the settings file
* unload - unloads Battlemod
* help - shows a menu of these commands in game

Purpose: To allow chat log customization.

Settings Files:  
The settings files for battlemod are composed of 3 to 25 xml files (depending on how much you like unique filters). XML files can be opened with Notepad, edited, and saved safely. If you are going to "Save As..." an xml from Notepad, be sure to change "Text Documents (.txt)" to "All Files" file type and make sure the file ends in ".xml"  

* data/settings.xml         - contains basic flags that control the features of the program.  
* data/colors.xml           - contains all the color codes relevant to the program, which can be adjusted using colors from the colortext command.  
* filters/filters.xml       - contains the chat filter settings and is explained more thoroughly therein.  
* filters/filters-<job>.xml - Several examples are provided, but these are specific filter files that will load for your individual jobs. You can use this to, for instance, make sure your healing jobs can always see damage taken (by unfiltering the <monsters></monsters> section or make sure your zerg jobs don't have to see the entire alliance's damage spam. The filter file is organized by actor, so if you wanted to filter by target you would have to go through each class of actor and change the setting that affected the given target.  
