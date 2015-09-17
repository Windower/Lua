Author: Byrth

Version: 1.0

Date: 15/11/13

Plugin Manager

Abbreviation: None

Commands: None

Purpose: To allow player-customizable plugin management.

Installation Instructions (from the Windower 4 Launcher):

* 1 Start your copy of Windower 4 and select the "Addons" menu up top in the Launcher.
* 2 Click the icon next to "plugin_manager"
* 3 Log in to the game!
* 4 Alter the settings as you wish. (An example file has been included)
* 5 "//lua r plugin_manager" will reload and give you the new settings.

Settings Files:  
The settings file for pluginmanager is one xml file with a format similar to the settings files for plugins. XML files can be opened with Notepad, edited, and closed saved safely. If you are going to "Save As..." an xml from Notepad, be sure to change "Text Documents (.txt)" to "All Files" file type and make sure the file ends in ".xml"  

* data/settings.xml         - contains plugins and addons specific to each character. <global> is loaded if there is not a set of plugins/addons inside tags that are a case-sensitive match to the player's name.