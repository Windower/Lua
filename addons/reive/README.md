**Author:** Giuliano Riccio

**Version:** v 1.20130419

**Description:**
This plugin tracks exp, bayld, momentum scores and bonuses during a reive.
There is only one configuration file called settings.xml in the data folder of the plugin.

![screenshot](https://raw.github.com/giulianoriccio/Lua/master/addons/reive/ss.gif)

**Abbreviation:** //reive

**Commands:**

* reive test -- fills the chat log to show how the plugin will work. reload the plugin after the test (lua r reive)
* reive reset -- sets gained exp and bayld to 0
* reive show -- shows the tracking window
* reive hide -- hides the tracking window
* reive toggle -- toggles the tracking window
* reive max-scores amount -- sets the max amount of scores to show in the window
* reive reset-on-start reset -- specifies if the exp and bayld will be reset at the begin of a reive
* reive track score visible -- specifies the visibility of a score in the window
* reive position [[-h]|[-x x] [-y y]] -- sets the horizontal and vertical position of the window relative to the upper-left corner
* reive font [[-h]|[-f font] [-s size] [-a alpha] [-b[ bold]] [-i[ italic]]] -- sets the style of the font used in the window
* reive color [[-h]|[-o objects] [-d] [-r red] [-g green] [-b blue] [-a alpha]] -- sets the colors used by the plugin

**TODO**

- [x] allow the user to change the settings using the console

#changelog
## v1.20130419
* **add:** the user can change the settings from the console or the text box

## v1.20130417
* **add:** the user can decide which bonuses will appear in the window

## v1.20130416
* first release

#global
* **reset_on_start:** **true** or **false**, will set exp and bayld to 0 at the begin of each reive
* **max_scores:** sets the max amount of momentum scores to show in the window

##track
* **hp_mp_boost**: **true** or **false**, tracks the momentum bonus "Ability cast recovery"
* **hp_recovery**: **true** or **false**, tracks the momentum bonus "HP recovery"
* **mp_recovery**: **true** or **false**, tracks the momentum bonus "MP recovery"
* **tp_recovery**: **true** or **false**, tracks the momentum bonus "TP recovery"
* **abilities_recovery**: **true** or **false**, tracks the momentum bonus "Ability cast recovery"
* **status_recovery**: **true** or **false**, tracks the momentum bonus "Status ailment recovery"
* **stoneskin**: **true** or **false**, tracks the momentum bonus "Stoneskin"

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

### reive
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

### score
#### title
* **r:** the amount of red from 0 to 255
* **g:** the amount of green from 0 to 255
* **b:** the amount of blue from 0 to 255

#### label
* **r:** the amount of red from 0 to 255
* **g:** the amount of green from 0 to 255
* **b:** the amount of blue from 0 to 255

### bonus
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