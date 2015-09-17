#Nostrum

Creates a click-able onscreen macro to help avoid targeting issues while curing. (MsJans clone)
MsJans was originally written by Janice (BG), was further developed by Ragns (BG), and was most recently maintained by Arcon.

### Settings
The color, contents, and position of the macro can be modified by editing the Nostrum/data/settings.xml file.

### Using the Macro
The macro consists of two basic units: a list of your current party members, and a palette of cure spells. These automatically resize when the party structure changes. However, in order to avoid constant resizing during bard rotations and other busy moments, the macro does not automatically shrink when members leave the party. It can be manually resized by using the 'cut' command.

To use the macro, click on the appropriate region of the display.


####Left Click

Region | Action
------ | ------
Status Removal Icons | Casts the corresponding spell on `'<t>'`
Buff Icons | Casts the corresponding spell on `'<t>'`
Party Lists | Targets the corresponding party member
Cure Palette | Casts the corresponding cure on the party member

####Right Click

Region | Action
------ | ------
Status Removal Icons | Saves the corresponding spell to the right-click button
Buff Icons | Saves the corresponding spell to the right-click button
Party Lists | Casts the saved spell on the corresponding party member

### Commands

command(shortcut)

#####Abbreviation: //nos
1. help(h):
  - Prints a list of these commands in the console.
2. refresh(r):
  - Compares the macro's current party structures to the party structure in memory. Adds new members and removes any old members (trusts). Only people nearby you will be added to the macro, and current party members who are not nearby will be removed.
3. hide(h):
  - Toggles the macro's visibility.
4. cut(c):
  - Trims the macro down to size, removing blank spaces.
5. send(s) &lt;name&gt;: 
  - Requires send addon. Sends commands to the character whose name was provided. If no name was provided, send settings will reset and Nostrum will function normally.
6. profile(p) &lt;name&gt;:
  - Loads a new profile from the settings file.
        
###Issues
1.Loading profiles in a busy area may be a bad idea.