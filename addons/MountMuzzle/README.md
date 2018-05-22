**Author:** Sjshovan (Apogee)  
**Version:** v0.9.1

# Mount Muzzle

Allows the user to change or remove the default mount music.  

___
### Usage

**Manually load** the addon by using the following command:
    
    //lua load mountmuzzle or //lua l mountmuzzle
    
**Automatically load** this addon by adding one the above commands to the bottom of your `Windower4/scripts/init.txt` file.
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
### Change Log

**v0.9.1**
- **Fix:** Chosen music does not start upon login if mounted. 
- **Fix:** Chosen music does not persist upon changing zones.
- **Add:** Known issues added to README.
- **Add:** TODOS added to README.

**v0.9.0**
- Initial release

___
### Known Issues

**v0.9.1**
- **Issue:** If Mount Muzzle is selected to automatically load and the player is mounted upon login, there is a significant delay before the chosen music will begin to play.
- **Issue:** Upon changing zones the default music can be heard for a moment before the chosen music begins to play. 

___    
### TODOS

- **Todo:** Investigate alternative methods for music change as packet injection/swap allows the player to hear the default music upon zone change and login, regardless of chosen music. 