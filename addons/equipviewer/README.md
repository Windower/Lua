**Author:**  Tako, Rubenator<br>
**Version:**  3.3.0<br>
**Date:** April 13, 2021<br>

* Displays current equipment grid on screen. Also can show current Ammo count and current Encumbrance.

## Settings

* Most settings can be modified via commands, but you can edit the settings.xml directly for a few uncommon settings.

**Abbreviation:** `//ev`

## Commands
1. position <xpos> <ypos>: move display to position (from top left)
2. size <pixels>: set pixel size of each item slot (defaults to 32 -- same as the size of the item icons)
3. scale <factor>: scale multiplier for size of each item slot (1 is 32px) -- modifies same setting as size
4. alpha <opacity>: set opacity of icons (out of 255)
5. transparency <transparency>: inverse of alpha (out of 255) -- modifies same setting as alpha
6. background <red> <green> <blue> <alpha>: sets color and opacity of background (out of 255)
7. ammocount: toggles showing current ammo count (defaults to on/true)
8. encumbrance: toggles showing encumbrance Xs (defaultis on/true)
9. hideonzone: toggles hiding while crossing zone lines (default is on/true)
10. hideoncutscene: toggles hiding when in cutscene/npc menu/etc (default is on/true)
11. justify: toggles between ammo text being right or left justifed (default is right justified)
12. help: displays explanations of each command
	
### Example Commands
```
//ev pos 700 400
//ev size 64
//ev scale 1.5
//ev alpha 255
//ev transparency 200
//ev background 0 0 0 72
//ev ammocount
//ev encumbrance
//ev hideonzone
//ev hideoncutscene
//ev justify
//ev help
```

## Source
The latest source and information for this addon can be found on [GitHub](https://github.com/Windower/Lua/tree/live/addons/equipviewer).
