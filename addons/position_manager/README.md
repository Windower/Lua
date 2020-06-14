# Position Manager

Set and save screen position per-character.  

Command: //pm set <Charactername|all> pos_x pos_y

### Examples:  
`//pm set all 0 60`  
Will set the default positioning for all characters to X: 0 and Y: 60 (the height of the Windows 10 taskbar with 150% UI scaling.)  

`//pm set Yourname 1920 0`  
Will set the default position for the character called "Yourname" to X: 1920 and Y: 0.  
This will make the character appear on the secondary screen that is to the right of the main screen - useful for multi-screen setups.

`//pm set Yourmain 0 40`  
`//pm set Youralt 800 40`  
Will set your main to X: 0, Y: 40, and your alt to the X: 800, Y: 40.  
If your laptop screen is 1600px wide, and your instances are both set at 800x600, this will put them side by side.

Note: Characters are only moved after they're logged in. The <all> position will be used for the character login screen as well.

**Warning:** the `all` name will delete every other character-specific settings that are already saved! It's best to use it only once after you install the addon, to set default position for non-specified characters.

Enjoy.
