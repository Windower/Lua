# MsJans overlay

This overlay is a clone of an unmaintained standalone program named MsJans. MsJans was originally written by Janice (BG), was further developed by Ragns (BG), and was most recently maintained by Arcon.

### Settings
The color, contents, and position of the macro can be modified by editing the `...Windower4/Nostrum/overlays/MsJans/data/display_settings.xml` file.
The contents of the palettes can be modified by editing the `...Windower4/Nostrum/overlays/MsJans/data/settings.xml` file.

### Using the display
The display consists of two basic units: a list of your current party members, and a palette of actions. These automatically grow with the party structure. However, in order to avoid constant resizing during bard rotations and other busy moments, the display does not automatically shrink when members leave the party. It can be manually resized by using the 'cut' command.

Use your mouse to interact with the display.

#### Left Click

Region | Action
------ | ------
Status Removal Icons | Casts the corresponding spell on `'<t>'`
Buff Icons | Casts the corresponding spell on `'<t>'`
Party Lists | Targets the corresponding party member
Palette | Inputs the corresponding action, targeting the adjacent party member

#### Right Click

Region | Action
------ | ------
Status Removal Icons | Saves the corresponding action to the right-click button
Buff Icons | Saves the corresponding action to the right-click button
Party Lists | Inputs the corresponding action, targeting the corresponding party member

### Commands

command(shortcut)

##### Abbreviation: //nos
1. cut(c):
  - Trims the display down to size, removing blank spaces.
2. profile(p) &lt;name&gt;:
  - Loads a new palette profile from the settings file.
  