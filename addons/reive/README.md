**Author:** Giuliano Riccio
**Version:** v 1.20131021

# Reive #
This addon tracks exp, bayld, momentum scores and bonuses during a reive.

## Commands ##
### help ###
Shows the help text.  
```
reive help
```

### test ###
Fills the chat log with some messages to show how the plugin will work.  
```
reive test
```

### reset ###
Sets gained exp and bayld to 0.  
```
reive reset
```

### full-reset ###
Sets gained exp/total exp and bayld/total bayld to 0.  
```
reive full-reset
```

### show ###
Shows the tracking window.  
```
reive show
```

### hide ###
Hides the tracking window.  
```
reive hide
```

### toggle ###
Toggles the tracking window's visibility.  
```
reive toggle
```

### light ###
Enables or disabled light mode. When enabled, the addon will never show the window and just print a summary in the chat box at the end of the run. If the _enabled_ parameter is not specified, the help text will be shown.  
```
reive light <enabled>
```
* **enabled:** specifies the status of the light mode. **default**, **false** or **0** mean disabled. **true** or **1** mean enabled.

### max-scores ###
Sets the max amount of scores to show in the window. If the _amount_ parameter is not specified, the help text will be shown.  
```
reive max-scores <amount>
```
* **amount:** specifies the max amount of status scores that will be show. By default this value is 5. setting this value to 0 will hide the scores section.

### track ###
Specifies the visibility of a bonus in the window.  
```
reive track <bonus> <visible>
```
* **bonus:** specifies the item which will have its visibility changed. The accepted values are **abilities-recovery**, **hp-mp-boost**, **hp-recovery**, **mp-recovery**, **status-recovery**, **stoneskin**, **tp-recovery**.
* **visible:** specifies the visibility of the bonus. **false** or **0** mean disabled. **default**, **true** or **1** mean enabled.

### position ###
Sets the horizontal and vertical position of the window relative to the upper-left corner. If no parameter is specified, the help text will be shown.  
```
reive position [[-h]|[-x <x>] [-y <y>]]
```
* **-h:** shows the help text.
* **-x _x_:** specifies the horizontal position of the window.
* **-y _y_:** specifies the vertical position of the window.

### font ###
Sets the style of the font used in the window. If no parameter is specified, the help text will be shown.  
```
reive font [[-h]|[-f <font>] [-s <size>] [-a <alpha>] [-b [<bold>]] [-i [<italic>]]]
```
* **-h:** shows the help text.
* **-f _font_:** specifies the text's font.
* **-s _size_:** specifies the text's size.
* **-a _alpha_:** specifies the text's transparency. The value must be set between 0 (transparent) and 255 (opaque), inclusive.
* **-b [ _bold_ ]:** specifies if the text should be rendered bold. **default**, **false** or **0** mean disabled. **true**, **1** or no value mean enabled.
* **-i [ _italic_ ]:** specifies if the text should be rendered italic. **default**, **false** or **0** mean disabled. **true**, **1** or no value mean enabled.

### color ###
Sets the colors of the various elements present in the addon's window. If no parameter is specified, the help text will be shown.  
```
reive color [[-h]|[-o <objects>] [-d] [-r <red>] [-g <green>] [-b <blue>] [-a <alpha>]]
```
* **-h:** shows the help text.
* **-o _objects_:** specifies the item/s which will have its/their color changed. If this parameter is missing all the objects will be changed. the accepted values are **all**, **background**, **bg**, **title**, **label**, **value**, **reive**, **reive.title**, **reive.label**, **reive.value**, **score**, **score.title**, **score.label**, **bonus**, **bonus.title**, **bonus.label**, **bonus.value**.
* **-d:** sets the red, green, blue and alpha values of the specified objects to their default values.
* **-r _red_:** specifies the intensity of the red color. The value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.
* **-g _green_:** specifies the intensity of the greencolor. The value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.
* **-b _blue_:** specifies the intensity of the blue color. The value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.
* **-a _alpha_:** specifies the text's transparency. The value must be set between 0 (transparent) and 255 (opaque), inclusive.

----

## Changelog ##

### v1.20130802 ###
* **fix**: 4.1 compatibility fix.

### v1.20130603 ###
* **fix**: Fixed an issue that prevented the addon to start tracking info.

### v1.20130529 ###
* **change**: Aligned to Windower's addon development guidelines.

### v1.20130525 ###
* **fix:** Fixed a bug that prevented the addon from tracking correctly the total gained exp.

### v1.20130516 ###
* **add:** A "light mode" has been added. While active, the window will be kept hidden and only a summary will be shown at the end of the run.

### v1.20130514 ###
* **change:** Current/total bayld/exp will be shown at the same time. "reset_on_start" has no use anymore and has been removed.

### v1.20130419 ###
* **add:** The user can change the settings from the console or the text box.

### v1.20130417 ###
* **add:** The user can decide which bonuses will appear in the window.

### v1.20130416 ###
* First release.
