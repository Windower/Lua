**Author:** [Sjshovan (Apogee)](https://github.com/Ap0gee)  
**Version:** v0.9.3  


# Mount Muzzle

> A Windower 4 addon that allows the user to change or remove the default mount music in Final Fantasy 11 Online.


### Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
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
1. Navigate to <https://github.com/Ap0gee/MountMuzzle>.
2. Click on `Releases`. 
3. Click on the `Source code (zip)` link within the latest release to download.
4. Extract the zipped folder to `Windower4/addons/`.
5. Rename the folder to remove the version tag (`-v0.9.3`). The folder should be named `MountMuzzle`.
 
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
   
**set _\<muzzle>_**

Sets the current muzzle to the given muzzle type. This command takes a single argument represented by `<muzzle>`. Below are the equivalent ways of calling the command:

    //mountmuzzle set <muzzle>
    //muzzle set <muzzle>
    //mm set <muzzle>
    
Here are some usage examples for the **set _\<muzzle>_** command: `mm set silent` and `muzzle set zone` etc...

**get**

Displays the current muzzle that is set. Below are the equivalent ways of calling the command:
	
    //mountmuzzle get
    //muzzle get
    //mm get
    
**default**

Sets the current muzzle to the default muzzle type: `Silent`. Below are the equivalent ways of calling the command:

	//mountmuzzle default
    //muzzle default
    //mm default

**reload**

Reloads the Mount Muzzle addon. Below are the equivalent ways of calling the command:
	
    //mountmuzzle reload
    //muzzle reload
    //mm reload

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

**v0.9.3** - 5/31/2018
- **Remove:** Removed /data/settings.xml file.
- **Update:** licences now display correct author name.
- **Update:** README refactored in attempt to meet merge criteria.
- **Update:** helpers.lua now requires only colors from constants.lua.
- **Update:** constants.lua now returns table of globals for modular support.
- **Update:** mountmuzzle.lua refactored in attempt to meet merge criteria.

**v0.9.2** - 5/24/2018
- **Fix:** Zone music gets silenced if player enters reive on mount with zone muzzle selected.
- **Fix:** Player reaches error if no arguments are given upon invoking the addon.  
- **Update:** Convert tab characters to spaces, simplify code.  
- **Update:** README Usage instructions updated.
- **Update:** README Known Issues updated.
- **Add:** Table of Contents added to README.
- **Add:** Prerequisites added to README.
- **Add:** Installation added to README. 
- **Add:** Support added to README.
- **Add:** License added to README.

**v0.9.1** - 5/22/2018
- **Fix:** Chosen music does not start upon login if mounted. 
- **Fix:** Chosen music does not persist upon changing zones.
- **Add:** Known issues added to README.
- **Add:** TODOS added to README.

**v0.9.0** - 5/21/2018
- Initial release

___
### Known Issues

- **Issue:** If Mount Muzzle is selected to automatically load and the player is mounted upon login, there is a significant delay before the chosen music will begin to play.
- **Issue:** Upon changing zones the default music can be heard for a moment before the chosen music begins to play. 

___    
### TODOS

- **Todo:** Investigate alternative methods for music change as packet injection/swap allows the player to hear the default music upon zone change and login, regardless of chosen music. 
___

### License

Copyright © 2018, [Sjshovan (Apogee)](https://github.com/Ap0gee).
Released under the [BSD License](LICENSE).

***