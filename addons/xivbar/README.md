# xivbar
This addon displays vital bars for easy tracking

![alt text](http://i.imgur.com/QA6WSUY.png)

You can choose from 3 different styles 'ffxiv', 'ffxi' and 'ffxiv-legacy'.

![alt text](http://i.imgur.com/vMlZoAl.png)

and you can use a compact version for a smaller resolution:
![alt text](http://i.imgur.com/0vgfDq1.png)

## Available Settings
##### Bars
* **Offset X** - moves the entire addon left (negative number) or right (positive number) the given number of pixels
* **Offset Y** - moves the entire addon up (negative number) or down (positive number) the given number of pixels

##### Theme
* **Name** - Name of the theme to use - 'ffxi', 'ffxiv', 'ffxiv-legacy', or your own custom one
* **Compact** - Enables or disables compact mode
* **Bar** - Values for bar width, spacing, offset and compact mode. Useful for creating a custom theme. 

##### Texts
* **Color** - The font color for the HP, MP and TP numbers
* **Font** - The font for the HP, MP and TP numbers
* **Offset** - moves the HP, MP and TP numbers left (negative number) or right (positive number) the given number of pixels
* **Size** - The font size for the HP, MP and TP numbers
* **Stroke** - The font stroke the HP, MP and TP numbers
* **FullTpColor** - The font color for the TP numbers when the bar is full
* **DimTpBar** - dim the TP bar when not full

## How to edit the settings
1. Login to your character in FFXI
2. Edit the addon's settings file: **_Windower4\addons\xivbar\data\settings.xml_**
3. Save the file 
4. Press Insert in FFXI to access the windower console 
5. Type ``` lua r xivbar ``` to reload the addon
6. Press Insert in FFXI again to close the windower console

## How to create my own custom theme
1. Create a folder inside the *theme* directory of the addon: **_Windower4\addons\xivbar\themes\MY_CUSTOM_THEME_**
2. Create the necessary images. A theme is composed of 5 images: a background for the bars (*bar_bg.png*), a background for the compact mode (*bar_compact.png*), and one image for each bar (*hp_fg.png, mp_fg.png and tp_fg.png*). You can take a look at the default themes.
3. Edit the name of the theme in the settings to yours. This setting must match the name of the folder you just created.
4. Adjust the bar width, spacing and offset for your custom theme in the settings.
