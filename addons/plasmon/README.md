**Author:** Giuliano Riccio  
**Version:** v 1.20130528

# Plasmon #
This addon tracks plasm, killed mobs and dropped airlixirs during a delve.

## Commands ##
### help ###
shows the help text.

```
plasmon help
```

### test ###
fills the chat log with some messages to show how the plugin will work.

```
plasmon test
```

### reset ###
sets gained exp and bayld to 0.

```
plasmon reset
```

### show ###
shows the tracking window.

```
plasmon show
```

### hide ###
hides the tracking window.

```
plasmon hide
```

### toggle ###
toggles the tracking window's visibility.

```
plasmon toggle
```

### light ###
enables or disabled light mode. when enabled, the addon will never show the window and just print a summary in the chat box at the end of the run. if the _enabled_ parameter is not specified, the help text will be shown.

```
plasmon light <enabled>
```
* **enabled:** specifies the status of the light mode. **default**, **false** or **0** mean disabled. **true** or **1** mean enabled.

### position ###
sets the horizontal and vertical position of the window relative to the upper-left corner. if the no parameter is specified, the help text will be shown.

```
plasmon position [[-h]|[-x <x>] [-y <y>]]
```
* **-h:** shows the help text.
* **-x _x_:** specifies the horizontal position of the window.
* **-y _y_:** specifies the vertical position of the window.
* 
### font ###
sets the style of the font used in the window. if the no parameter is specified, the help text will be shown.

```
plasmon font [[-h]|[-f <font>] [-s <size>] [-a <alpha>] [-b[ <bold>]] [-i[ <italic>]]]
```
* **-h:** shows the help text.
* **-f _font_:** specifies the text's font.
* **-s _size_:** specifies the text's size.
* **-a _alpha_:** specifies the text's transparency. the value must be set between 0 (transparent) and 255 (opaque), inclusive.
* **-b[ _bold_]:** specifies if the text should be rendered bold. **default**, **false** or **0** mean disabled. **true**, **1** or no value mean enabled.
* **-i[ _italic_]:** specifies if the text should be rendered italic. **default**, **false** or **0** mean disabled. **true**, **1** or no value mean enabled.

### color ###
sets the colors of the various elements present in the addon's window. if the no parameter is specified, the help text will be shown.

```
plasmon color [[-h]|[-o <objects>] [-d] [-r <red>] [-g <green>] [-b <blue>] [-a <alpha>]]
```
* **-h:** shows the help text.
* **-o _objects_:** specifies the item/s which will have its/their color changed. if this parameter is missing all the objects will be changed. the accepted values are **all**, **background**, **bg**, **title**, **label**, **value**, **plasmon**, **plasmon.title**, **plasmon.label**, **plasmon.value**, **airlixir**, **airlixir.title**, **airlixir.label**, **airlixir.value**.
* **-d:** sets the red, green, blue and alpha values of the specified objects to their default values.
* **-r _red_:** specifies the intensity of the red color. the value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.
* **-g _green_:** specifies the intensity of the greencolor. the value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.
* **-b _blue_:** specifies the intensity of the blue color. the value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.
* **-a _alpha_:** specifies the text's transparency. the value must be set between 0 (transparent) and 255 (opaque), inclusive.

----

## Changelog ##

### v1.20130528 ###
* **add:** added a recovery mode in case of crash/reload.
* **fix:** fixed the mob kill count.

### v1.20130517 ###
* **fix:** fixed a bug that kept the addon from counting airlixirs.

### v1.20130516 ###
* **change:** a "light mode" has been added. while active, the window will be kept hidden and only a summary will be shown at the end of the run.

### v1.20130515###
* first release.
