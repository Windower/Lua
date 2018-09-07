**Author:** [Sjshovan (Apogee)](https://github.com/Ap0gee)  
**Version:** v0.9.4  


# Mount Muzzle

> A Windower 4 addon that allows the user to change or remove the default mount music in Final Fantasy 11 Online.


### Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Aliases](#aliases)
- [Usage](#usage)
- [Commands](#commands)
- [Support](#support)
- [Change Log](#change-log)
- [Known Issues](#known-issues)
- [TODOs](#todos)
- [License](#license)

___
### Prerequisites
1. [Final Fantasy 11 Online](http://www.playonline.com/ff11us/index.shtml)
2. [Windower 4](http://windower.net/)

___
### Installation

**Windower:**   
1. Navigate to the `Addons` section at the top of Windower.
2. Locate the `MountMuzzle` addon.
3. Click the download button.
4. Ensure the addon is switched on.

**Manual:**
1. Navigate to <https://github.com/Ap0gee/MountMuzzle>.
2. Click on `Releases`. 
3. Click on the `Source code (zip)` link within the latest release to download.
4. Extract the zipped folder to `Windower4/addons/`.
5. Rename the folder to remove the version tag (`-v0.9.4`). The folder should be named `MountMuzzle`.

___
### Aliases
The following aliases are available to Mount Muzzle commands:    

**mountmuzzle:** muzzle | mm  
**list:** l     
**set:** s  
**get:** g  
**default:** d  
**unload:** u  
**reload:** r  
**about:** a  
**silent:** s  
**mount:** m   
**chocobo:** c  
**zone:** z    
**help:** h  
 
 ___
### Usage

Manually load the addon by using one of the following commands:
    
    //lua load mountmuzzle  
    //lua l mountmuzzle

___    
### Commands

**help**

Displays available Mount Muzzle commands. Below are the equivalent ways of calling the command:

    //mountmuzzle help
    //muzzle help
    //mm help
    //mountmuzzle h
    //muzzle h
    //mm h

**list** 

Displays the available muzzle types. Below are the equivalent ways of calling the command:

    //mountmuzzle list
    //muzzle list
    //mm list
    //mm l
   
**set _\<muzzle>_**

Sets the current muzzle to the given muzzle type. This command takes a single argument represented by `<muzzle>`. Below are the equivalent ways of calling the command:

    //mountmuzzle set <muzzle>
    //muzzle set <muzzle>
    //mm set <muzzle>
    //mm s <muzzle>
    
Here are some usage examples for the **set _\<muzzle>_** command: `mm set silent` and `muzzle set zone` etc...

**get**

Displays the current muzzle that is set. Below are the equivalent ways of calling the command:
	
    //mountmuzzle get
    //muzzle get
    //mm get
    //mm g
    
**default**

Sets the current muzzle to the default muzzle type: `Silent`. Below are the equivalent ways of calling the command:

	//mountmuzzle default
    //muzzle default
    //mm default
    //mm d
    
**unload**

Unloads the Mount Muzzle addon. Below are the equivalent ways of calling the command:
	
    //mountmuzzle unload
    //muzzle unload
    //mm unload
    //mm u
    
**reload**

Reloads the Mount Muzzle addon. Below are the equivalent ways of calling the command:
	
    //mountmuzzle reload
    //muzzle reload
    //mm reload
    //mm r

**about**

Displays information about the Mount Muzzle addon. Below are the equivalent ways of calling the command:
	
    //mountmuzzle about
    //muzzle about
    //mm about
    //mm a
    
___
### Support
**Having Issues with this addon?**
* Please let me know [here](https://github.com/Ap0gee/MountMuzzle/issues/new).
  
**Have something to say?**
* Send me some feedback here: <sjshovan@gmail.com>

**Want to stay in the loop with my work?**
* You can follow me at: <https://twitter.com/Sjshovan>

**Want to show your love and help me make more awesome stuff?**
* You can do so here: <https://www.paypal.me/Sjshovan>  

___
### Change Log

**v0.9.4** - 9/06/2018
- **Fix:** Music wouldn't change if addon loaded while on mount.
- **Fix:** Music wouldn't change if addon unloaded while on mount.
- **Fix:** Muzzle type 'Silent' was playing incorrect track.
- **Update:** Licences now display correct addon name.
- **Update:** Muzzle type 'Normal' changed to 'Mount'.
- **Update:** Muzzle type 'Choco' changed to 'Chocobo'.
- **Update:** mountmuzzle.lua refactored and condensed.
- **Update:** README Commands updated.
- **Update:** README Installation updated.
- **Update:** README Table of Contents updated.
- **Update:** README Known Issues updated.
- **Update:** README TODOS updated.
- **Add:** New commands added (about, unload).
- **Add:** Shorthand aliases added to all commands.
- **Add:** Aliases added to README.

**v0.9.3** - 5/31/2018
- **Remove:** Removed /data/settings.xml file.
- **Update:** licences now display correct author name.
- **Update:** helpers.lua now requires only colors from constants.lua.
- **Update:** constants.lua now returns table of globals for modular support.
- **Update:** mountmuzzle.lua refactored in attempt to meet merge criteria.
- **Update:** README refactored in attempt to meet merge criteria.

**v0.9.2** - 5/24/2018
- **Fix:** Zone music gets silenced if player enters reive on mount with zone muzzle selected.
- **Fix:** Player reaches error if no arguments are given upon invoking the addon.  
- **Update:** Convert tab characters to spaces, simplify code.  
- **Update:** README Usage Instructions updated.
- **Update:** README Known Issues updated.
- **Add:** Table of Contents added to README.
- **Add:** Prerequisites added to README.
- **Add:** Installation added to README. 
- **Add:** Support added to README.
- **Add:** License added to README.

**v0.9.1** - 5/22/2018
- **Fix:** Chosen music does not start upon login if mounted. 
- **Fix:** Chosen music does not persist upon changing zones.
- **Add:** Known Issues added to README.
- **Add:** TODOS added to README.

**v0.9.0** - 5/21/2018
- Initial release

___
### Known Issues

- **Issue:** If Mount Muzzle is selected to automatically load and the player is mounted upon login, there is a significant delay before the chosen music will begin to play.
- **Issue:** Upon changing zones the default music can be heard for a moment before the chosen music begins to play.
- **Issue:** Unable to correctly set mount music to original if Mount Muzzle is unloaded while mounted. 

___    
### TODOs

- **TODO:** Investigate alternative methods for music change as packet injection/swap allows the player to hear the default music upon zone change and login, regardless of chosen music.
- **TODO:** Investigate methods for determining which mount type the player is on when loading/unloading Mount Muzzle.
___

### License

Copyright © 2018, [Sjshovan (Apogee)](https://github.com/Ap0gee).
Released under the [BSD License](LICENSE).

***