# Position Manager

Set and save screen position per-character. Requires the WinControl addon.  

Command:  
`//pm set <pos_x> <pos_y> [name]`

`pos_x` and `pos_y` are obligatory and must be numbers.  
`name` is optional. If no name is provided, settings will be saved for the current character.  
`:all` is a special name that can be used to set the default position.  

**Note**: Characters are only moved after they're logged in. The `:all` position will be used for the character login screen as well.

**Note**: On some systems with very fast or very slow disks, it can happen that the `WinControl` addon does not get loaded in time for `position_manager` to send the proper command. In that case, you can use this command:  
`//pm set delay <seconds> [name]`  
(where `seconds` is obligatory and must be a positive number, and `name` follows the same rules as before), to set a delay that will hopefully let the plugin load in time.

### Examples:  
`//pm set 0 0`  
Will set your _current_ character to the position X: 0, Y: 0.

`//pm set 0 60 :all`  
Will set the default positioning for all characters to X: 0 and Y: 60 (the height of the Windows 10 taskbar with 150% UI scaling.), and delete all other character-specific settings.  

`//pm set 1920 0 Yourname`  
Will set the default position for the character called "Yourname" to X: 1920 and Y: 0.  
This will make the character appear on the secondary screen that is to the right of the main screen - useful for multi-screen setups.

`//pm set delay 1 all`  
`//pm set Yourmain 0 40`  
`//pm set Youralt 800 40`  
Will set delay to 1 for all characters, then set the position of your main to X: 0, Y: 40, and your alt to X: 800, Y: 40.  
If your laptop screen is 1600px wide, and your instances are both set at 800x600, this will put them side by side.

**Warning:** the `all` name will delete every other character-specific settings that are already saved! It's best to use it only once after you install the addon, to set default position and delay for non-specified characters.

Enjoy.
