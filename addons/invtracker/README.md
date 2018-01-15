# invtracker
This addon displays a grid detailing empty and filled inventory slots, similar to the FFXIV Inventory Grid HUD widget.

![Imgur](https://i.imgur.com/PgiMxRZ.png)

## How to install:
1. Download the repository [here](https://github.com/azamorapl/Lua/archive/personal.zip)
2. Extract the **_invtracker_** folder to your **_Windower4/addons_** folder

## How to enable it in-game:
1. Login to your character in FFXI
2. Press insert to access the windower console
3. Type ``` lua l invtracker ```

## How to have windower load it automatically:
1. Go to your windower folder
2. Open the file **_Windower4/scripts/init.txt_**
3. Add the following line to the end of the file ``` lua l invtracker ```

## How to edit the settings
1. Login to your character in FFXI
2. Edit the addon settings file: **_Windower4\addons\invtracker\data\settings.xml_**
3. Save the file
4. Press Insert in FFXI to access the windower console
5. Type ``` lua r invtracker ``` to reload the addon
6. Press Insert in FFXI again to close the windower console

## Issues:
1. Since there is no way to know many items determine a full stack, all regular items are painted blue. Instead, bazaar equipped items are painted orange, linkshell and equipped items are painted green, and temporary items are painted red.
2. There is no way to get the inventory sort order, so all items in the grid will be ordered by status and item count.
3. You may need to log out from you character and enter again in order to have the addon display properly if loaded manually.
