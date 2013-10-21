**Author:** Giuliano Riccio
**Version:** v 1.20131021

# Plasmon #
This addon tracks plasm, killed mobs and dropped airlixirs during a delve.

## Commands ##
### help ###
Shows the help text.

```
plasmon help
```

### test ###
Fills the chat log with some messages to show how the plugin will work.

```
plasmon test
```

### reset ###
sets current gained plasm, monster kill count and dropped airlixirs to 0.

```
plasmon reset
```

### full-reset ###
sets both current and total gained plasm, monster kill count and dropped airlixirs to 0.

```
plasmon full-reset
```

### show ###
Shows the tracking window.

```
plasmon show
```

### hide ###
Hides the tracking window.

```
plasmon hide
```

### toggle ###
Toggles the tracking window's visibility.

```
plasmon toggle
```

### light ###
Enables or disables light mode. When enabled, the addon will never show the window and just print a summary in the chat box at the end of the run. If the _enabled_ parameter is not specified, the help text will be shown.

```
plasmon light <enabled>
```
* **enabled:** specifies the status of the light mode. **default**, **false** or **0** mean disabled. **true** or **1** mean enabled.

### timer ###
Enables or disables the timer. When enabled, the addon will never show the window and just print a summary in the chat box at the end of the run. If the _enabled_ parameter is not specified, the help text will be shown.

```
plasmon timer <enabled>
```
* **enabled:** specifies the status of the timer. **false** or **0** mean disabled. **default**, **true** or **1** mean enabled.

### position ###
Sets the horizontal and vertical position of the window relative to the upper-left corner. If no parameter is specified, the help text will be shown.

```
plasmon position [[-h]|[-x <x>] [-y <y>]]
```
* **-h:** shows the help text.
* **-x _x_:** specifies the horizontal position of the window.
* **-y _y_:** specifies the vertical position of the window.

### font ###
Sets the style of the font used in the window. If no parameter is specified, the help text will be shown.

```
plasmon font [[-h]|[-f <font>] [-s <size>] [-a <alpha>] [-b [<bold>]] [-i [<italic>]]]
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
plasmon color [[-h]|[-o <objects>] [-d] [-r <red>] [-g <green>] [-b <blue>] [-a <alpha>]]
```
* **-h:** shows the help text.
* **-o _objects_:** specifies the item/s which will have its/their color changed. If this parameter is missing all the objects will be changed. The accepted values are: **all**, **background**, **bg**, **title**, **label**, **value**, **plasmon**, **plasmon.title**, **plasmon.label**, **plasmon.value**, **airlixir**, **airlixir.title**, **airlixir.label**, **airlixir.value**.
* **-d:** sets the red, green, blue and alpha values of the specified objects to their default values.
* **-r _red_:** specifies the intensity of the red color. The value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.
* **-g _green_:** specifies the intensity of the greencolor. The value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.
* **-b _blue_:** specifies the intensity of the blue color. The value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.
* **-a _alpha_:** specifies the text's transparency. The value must be set between 0 (transparent) and 255 (opaque), inclusive.

----

## Changelog ##

### v1.20130613 ###
* **add**: Stop tracking on zone change.

### v1.20130610 ###
* **add**: Added a function to enable/disable the fracture timer.

### v1.20130609 ###
* **fix**: Fix for ally leaders and mobs counting.

### v1.20130604 ###
* **add**: Added a 45 minutes timer. Requires Timers plugin's custom timers function.

### v1.20130529 ###
* **change**: Aligned to Windower's addon development guidelines.

### v1.20130528 ###
* **add:** Added a recovery mode in case of crash/reload.
* **fix:** Fixed the mob kill count.

### v1.20130517 ###
* **fix:** Fixed a bug that kept the addon from counting airlixirs.

### v1.20130516 ###
* **change:** A "light mode" has been added. while active, the window will be kept hidden and only a summary will be shown at the end of the run.

### v1.20130515###
* First release.
