**Author:** Byrth

**Version:** 1.0

**Date:** 15/11/13

# Plugin Manager

**Abbreviation:** None

**Commands:** None

**Purpose:** To allow player-customizable plugin management.

## Installation

1. Start your copy of Windower 4 and select the "Addons" menu up top in the Launcher.
1. Click the icon next to "plugin_manager"
1. Log in to the game!
1. Alter the settings as you wish. (An example file has been included)
1. `//lua r plugin_manager` will reload and give you the new settings.

> **Note:** Plugin Manager will *not* automatically disable or unload any plugins or addons that you have enabled in the Windower launcher. Anything enabled in the launcher will be loaded for all characters, regardless of how you have configured your Plugin Manager settings.
> If you want Plugin Manager to handle a plugin or addon, be sure to disable it in the launcher.

## Settings Files 
The settings file for Plugin Manager are found in a single XML file with a format similar to the settings files for plugins.

* `data/settings.xml` - contains plugins and addons specific to each character. \<global\> is loaded if there is not a set of plugins/addons inside tags that are a case-sensitive match to the player's name.
