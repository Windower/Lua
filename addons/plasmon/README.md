**Author:** Giuliano Riccio

**Version:** v 1.20130515

**Description:**
This plugin tracks plasm, killed mobs and dropped airlixirs during a delve.
There is only one configuration file called settings.xml in the data folder of the plugin.

**Abbreviation:** //plasmon

**Commands:**

* plasmon test -- fills the chat log to show how the plugin will work. reload the plugin after the test (lua r plasmon)
* plasmon reset -- sets gained exp and bayld to 0
* plasmon show -- shows the tracking window
* plasmon hide -- hides the tracking window
* plasmon toggle -- toggles the tracking window
* plasmon position [[-h]|[-x x] [-y y]] -- sets the horizontal and vertical position of the window relative to the upper-left corner
* plasmon font [[-h]|[-f font] [-s size] [-a alpha] [-b[ bold]] [-i[ italic]]] -- sets the style of the font used in the window
* plasmon color [[-h]|[-o objects] [-d] [-r red] [-g green] [-b blue] [-a alpha]] -- sets the colors used by the plugin

#changelog
## v1.20130515
* first release, please report any bug you may find :)

#config
## position
* **x:** horizontal position of the window from top left
* **y:** vertical position of the window from top left

## font
* **family:** the name of the font to use
* **size:** the size of the text
* **bold:** **true** or **false**, makes the text bold
* **italic:** **true** or **false**, makes the text italic
* **a:** the text transparency from 0 (transparent) to 255 (opaque)

## colors
### background
* **r:** the amount of red from 0 to 255
* **g:** the amount of green from 0 to 255
* **b:** the amount of blue from 0 to 255
* **a:** the background transparency from 0 (transparent) to 255 (opaque)

### delve
#### title
* **r:** the amount of red from 0 to 255
* **g:** the amount of green from 0 to 255
* **b:** the amount of blue from 0 to 255

#### label
* **r:** the amount of red from 0 to 255
* **g:** the amount of green from 0 to 255
* **b:** the amount of blue from 0 to 255

#### value
* **r:** the amount of red from 0 to 255
* **g:** the amount of green from 0 to 255
* **b:** the amount of blue from 0 to 255

### airlixir
#### title
* **r:** the amount of red from 0 to 255
* **g:** the amount of green from 0 to 255
* **b:** the amount of blue from 0 to 255

#### label
* **r:** the amount of red from 0 to 255
* **g:** the amount of green from 0 to 255
* **b:** the amount of blue from 0 to 255

#### value
* **r:** the amount of red from 0 to 255
* **g:** the amount of green from 0 to 255
* **b:** the amount of blue from 0 to 255
