# xivhotbar - [WIP]
This addon adds a hotbar to FFXI, akin to those of more modern MMOs, along with recast times and mp/tp costs. It can also trigger custom commands.

![alt text](http://i.imgur.com/RnpVLbZ.png)

You can choose from 3 different styles 'ffxiv', 'ffxi' and 'classic'.

![alt text](http://i.imgur.com/g72PpaG.png)

Or you can mix and match and choose a different style for each component.

![alt text](http://i.imgur.com/8r6m2hq.png)

The hotbar is also very customizable. You can use custom icons, hide the ability names, recast, elements, mp/tp cost and even empty slots.

![alt text](http://i.imgur.com/ObDnDPG.png)

## WIP Version 
This is a very simple version with a lot of features still missing and A LOT of bugs.

##### Latest Changes:
```
 09/05/17
    - Added various addon commands
 08/05/17
    - Hotbar files are now inside a server directory so characters with same name don't override each other
    - fixed chat input triggering hotbar
    - removed key to hide bar and added setting ToggleBattleMode
    - fixed job change and battle notice bugs. 
    - added PSDs for custom icons to repository
 07/05/17
    - released WIP version
 ```

##### Limitations:
1. The addon doesn't override the game's keys. So when activating the third hotbar with CTRL, the macro bar ingame will show and activate too. To go around it, you can use an empty macro page.
2. The skill icons and info used were copied from the Timers plugin (you don't need to have it installed). As such, there are some icons that don't work and wrong elements on some skills
3. 2hours recast is not working

##### Still todo:
1. Add key mapping
3. Allow number of hotbars to be customizable
4. Add click events
5. Add option to disable autoswitching in battle
6. Fix wrong icons / elements
7. Add skillchain info
8. Allow vertical hotbars
9. Add multiple hotbar pages
10. Allow multi-line commands

##### Current Bugs:
1. Mp and Tp cost text changes color

## How to install:
1. Download the repository [here](https://github.com/SirEdeonX/FFXIAddons/archive/master.zip)
2. Extract the **_xivhotbar_** folder to your **_Windower4/addons_** folder

## How to enable it in-game:
1. Login to your character in FFXI
2. Press insert to access the windower console
3. Type ``` lua l xivhotbar ```

## How to have windower load it automatically:
1. Go to your windower folder
2. Open the file **_Windower4/scripts/init.txt_**
3. Add the following line to the end of the file ``` lua l xivhotbar ```

## Controls:
1. Hotbars are controlled with 1-0, SHIFT+1-0 and CTRL+1-0
2. You can toggle between battle mode using backslash \ (customizable through ToggleBattleMode setting)

## Addon Commands:
To use these commands:
1. Login to your character in FFXI
2. Press insert to access the windower console
3. Type ``` xivhotbar ``` or ```htb``` along with the command you want to execute

**Note:** ```<mode>``` designates which hotbar mode you want to edit. Either "battle" (b) or "field" (f) 

------
### Set action in hotbar 
 - ```htb set <mode> <hotbar> <slot> <type> <action> <target (optional)> <alias (optional)> <icon (optional)>```
 
Examples:
 - Set Cure II on hotbar 1, slot 1 for battle mode: ```htb set battle 1 1 ma "Cure II" stpc```
 - Set Raptor Mount on hotbar 2, slot 10 for field mode with "Raptor" as text and a custom icon: ```htb set f 2 10 ct "mount raptor" me "Raptor" "mounts/mount-raptor"```

------
### Remove action from hotbar 
 - ```htb delete <mode> <hotbar> <slot>```
 
Example:
- Remove action on battle hotbar 3, slot 1: ```htb del battle 3 1```

------
### Copy action from one slot to another 
 - ```htb copy <from mode> <from hotbar> <from slot> <to mode> <to hotbar> <to slot>```
 
Example: 
- Copy action from field hotbar 1, slot 2 to battle hotbar 2 slot 3: ```htb cp f 1 2 b 2 3```
  
------
### Move action from one slot to another 
- ```htb move <from mode> <from hotbar> <from slot> <to mode> <to hotbar> <to slot>```

Example: 
- Move action from field hotbar 3, slot 2 to slot 3: ```htb mv f 3 2 f 3 3```
------
### Change action alias 
- ```htb alias <mode> <hotbar> <slot> <new alias>```

Example: 
- Change alias from field hotbar 1, slot 2 to "Kupo": ```htb al f 1 2 "Kupo"```
------
### Change action icon 
- ```htb icon <mode> <hotbar> <slot> <new alias>```

Example: 
- Change icon from battle hotbar 1, slot 1 to "blue/blue-cocoon": ```htb ic b 1 1 "blue/blue-cocoon"```
------
### Reload hotbar to apply manual changes to the hotbar XML file
- ```htb reload```
------

## How to manually add actions to the hotbar
In addition to windower commands, the hotbar can be changed by editing the hotbar file:
1. Login to your character in FFXI. A default hotbar will be created
2. Edit the hotbar file: **_Windower4\addons\xivhotbar\data\hotbar\SERVER\CHARACTER_NAME\MAIN_SUB.xml_**
3. Save the file 
4. Press Insert in FFXI to access the windower console 
5. Type ``` htb reload ``` to reload the addon
6. Press Insert in FFXI again to close the windower console

#### File Structure:
```
 <hotbar>
     <field>
         <hotbar_1>
            <slot_1></slot_1>
                  ...
            <slot_0></slot_0>
         </hotbar_1>
         <hotbar_2></hotbar_2>
         <hotbar_3></hotbar_3>
     </field>
     <battle>
          <hotbar_1></hotbar_1>
          <hotbar_2></hotbar_2>
          <hotbar_3></hotbar_3>
      </battle>
 <hotbar>
 ```

### Actions Fields:
##### < type >
type of action:
* ct - custom command for things like /attack, /check, emotes, etc.
* ma - magic
* ja - job ability
* ws - weaponskill
* item - item
##### < action >
command or magic/ability/item to use
##### < target >
(optional) target to use it on. All macro targets are available, such as t, stpc, me, p1-8, etc.
##### < alias >
(optional) alias for the text that appears under each slot
##### < icon >
(optional) custom icon name. The file must be available under **_Windower4\addons\xivhotbar\data\images\icons\custom\_**

#### Examples:
* Check current target:
```
 <slot_2>
     <target>t</target>
     <type>ct</type>
     <action>check</action>
     <alias>Check</alias>
     <icon>check</icon>
 </slot_2>
 ```
 
 * Mount Raptor:
 ```
<slot_8>
  <type>ct</type>
  <action>mount raptor</action>
  <alias>Raptor</alias>
  <icon>mounts/mount-raptor</icon>
</slot_8>
  ```
  
* Trust Shantotto:
```
<slot_5>
    <target>me</target>
    <type>ma</type>
    <action>Shantotto</action>
    <icon>trusts/trust-shantotto</icon>
</slot_5>
```

* Dia current target:
```
<slot_1>
    <target>t</target>
    <type>ma</type>
    <action>Dia II</action>
</slot_1>
```

* Protect (choose target ingame)
```
<slot_1>
    <target>stpc</target>
    <type>ma</type>
    <action>Protect</action>
</slot_1>
```

* Warp Ring (must be equipped)
```
<slot_7>
    <target>me</target>
    <type>item</type>
    <action>Warp Ring</action>
    <alias>WarpRing</alias>
</slot_7>
```

* Job Ability
```
<slot_2>
    <target>me</target>
    <type>ja</type>
    <action>Chain Affinity</action>
    <alias>Chain Aff</alias>
</slot_2>
```

## Available Settings
##### Hotbar
* **HideEmptySlots** - if true, hides the background of slots with no action
* **HideActionName** - if true, hides the names and alias of the actions
* **HideActionCost** - if true, hides the mp/tp costs
* **HideActionElement** - if true, hides the actions elements
* **HideRecastAnimation** - if true, hides the recast bar, but maintains the countdown
* **HideRecastText** - if true, hides the recast countdown text, but maintains the recast bar
* **HideBattleNotice** - if true, hides notice indicating the "battle" hotbar is active

##### Controls
* **ToggleBattleMode** - key code for keyboard key that toggles Battle mode. Default is 43 for the \ key.

##### Theme
* **Slot** - Name of the theme to use for slots - 'ffxi', 'ffxiv', 'classic', or your own custom one
* **Frame** - Name of the theme to use for frames - 'ffxi', 'ffxiv', 'classic', or your own custom one
* **BattleNotice** - Name of the theme to use for the battle notice - 'ffxi', 'ffxiv', 'classic', or your own custom one 

##### Style
* **SlotAlpha** - background opacity for empty slots
* **SlotSpacing** - spacing between slots in pixels
* **HotbarSpacing** - spacing between hotbars in pixels
* **Offset X** - moves the entire addon left (negative number) or right (positive number) the given number of pixels
* **Offset Y** - moves the entire addon up (negative number) or down (positive number) the given number of pixels

##### Color
* **MpCost** - The font color for the mp cost
* **TpCost** - The font color for the tp cost
* **Feedback.Opacity** - opacity for the feedback for when a key is pressed
* **Feedback.Speed** - speed for the feedback for when a key is pressed
* **Disabled.Opacity** - opacity for disabled actions

##### Texts
* **Color** - The font color for the action names
* **Font** - The font for all the text
* **Size** - The font size for all the text
* **Stroke** - The font stroke for all the text

## How to edit the settings
1. Login to your character in FFXI
2. Edit the addon's settings file: **_Windower4\addons\xivhotbar\data\settings.xml_**
3. Save the file 
4. Press Insert in FFXI to access the windower console 
5. Type ``` lua r xivhotbar ``` to reload the addon
6. Press Insert in FFXI again to close the windower console

## How to create my own custom theme
1. Create a folder inside the *theme* directory of the addon: **_Windower4\addons\xivhotbar\themes\MY_CUSTOM_THEME_**
2. Create the necessary images. A theme is composed of 3 images: a background each slot (*slot.png*), a frame (*frame.png*), and one image for the battle mode notice (*notice.png*). You can take a look at the default themes.
3. Edit the name of the theme in the settings to yours. This setting must match the name of the folder you just created.