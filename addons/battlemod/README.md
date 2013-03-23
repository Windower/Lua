Author: Byrth

Version: 0.8

Battlemod, beta version

Abbreviation: //bm

Commands:
* help - shows a menu of these commands in game
* colortest - Shows the 509 possible colors for use with the settings file
* condensebuffs - Condenses Area of Effect buffs, Default = True
* condensebattle - Condenses battle logs according to your settings file, Default = True
* cancelmulti - Cancles multiple consecutive identical lines, Default = True
* oxford - Toggle use of oxford comma, Default = True
* commamode - Toggle comma-only mode, Default = False
* targetnumber - Toggle target number display, Default = True
* colorful - Colors the output by alliance member, Default = True

Purpose: To allow chat log customization.

Installation Instructions:

* 1 Download the lua file. (https://raw.github.com/Windower/Lua/master/addons/answeringmachine/answeringmachine.lua)
* 2 Place it in the (..\windower4\addons\battlemod\) folder, which you will have to create.
* 3 Also make a folder named "data" in that directory, ..\windower4\addons\battlemod\data.
* 4 Start your copy of Windower 4, use //lua l battlemod. This will create a default settings file for you in the data folder.
* 5 Alter the settings as you wish. (//bm colortest will let you see the color options)
* 6 If you have changed the settings, you can use //lua r battlemod to affect them in game.
* 7 If you like the changes and want them to happen every time you play, add "lua l battlemod" to the bottom of your init.txt script.