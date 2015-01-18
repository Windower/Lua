# Chars #
This addon lets you input special chars using simple tags (e.g.: ```<note>``` for ♪). Using the pattern ```<j:text>``` any alphanumeric character will be replaced with their full-width version ("japanese style" characters). The available characters depend on the [data](https://github.com/Windower/Lua/blob/master/addons/libs/chat/chars.lua) gathered by the Windower team. If anything in there is incorrect or missing, open an issue on [Windower's Lua issue tracker](https://github.com/Windower/Lua/issues).

![screenshot](http://i39.tinypic.com/spdwz6.png) 

## Commands ##

```
chars
```

Shows the available characters.

----

## Changelog ##

### v1.20141219 ###
* **fix:** Target-related tags were removed incorrectly

### v1.20141218 ###
* **fix:** Adjusted to Windower's new Lua libs API

### v1.20130529 ###
* **change:** Aligned to Windower's addon development guidelines.

### v1.20130525 ###
* **fix:** ```<j:text>``` pattern wasn't working with some special chars.

###  v1.20130521 ###
* **add:** added the pattern to write using alphanumeric japanese characters.

###  v1.20130421 ###
* first release.
