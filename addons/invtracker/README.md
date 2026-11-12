# invtracker
This addon displays a grid detailing empty and filled inventory slots, similar to the FFXIV Inventory Grid HUD widget.

![Imgur](https://i.imgur.com/PgiMxRZ.png)

## How to edit the settings
1. Login to your character in FFXI
2. Edit the addon settings file: **_Windower4\addons\invtracker\data\settings.xml_**
3. Save the file
4. Press Insert in FFXI to access the windower console
5. Type ``` lua r invtracker ``` to reload the addon
6. Press Insert in FFXI again to close the windower console

### Slot size

The size of the inventory dots can be adjusted in `settings.xml` using the
`slotImage.box.size` and `slotImage.background.size` height and width values.

## Issues:
1. There is no way to get the inventory sort order, so all items in the grid will be ordered by status and item count.
