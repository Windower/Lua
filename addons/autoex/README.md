# AutoEX: Autoexec Add-on Replacement
*This is a direct replacement for the old Autoexec Plugin.*

## Commands:
//ax convert \<filename\>: Converts an old .XML file that is placed in the `"/convert/"` folder.  
//ax load \<filename\>: Loads a file from the `"/settings/"` folder.  
//ax migrate: This will automatically convert, and load the old standard `AutoExec.xml` file.  
//ax reload: Reloads the addon. *(Also accepts `r` and `rl`)*  
//ax help: Displays information about the addon in the Windower console. *(Also accepts `h`)*  

## Loading:
The addon by default now stores `Autoex` list by character name. If another file is wished to be used, then load that filename instead.

## Exmple Events:
```
return {
    [1]={
        ["silent"]="false", 
        ["name"]="chat_tell_*_invite", 
        ["once"]="false", 
        ["command"]="input /pcmd add {SENDER}"
    },
    [2]={
        ["silent"]="true", 
        ["name"]="chat_tell_*_ally", 
        ["once"]="false", 
        ["command"]="input /acmd add {SENDER}"
    },
    [3]={
        ["silent"]="false", 
        ["name"]="invite_*", 
        ["once"]="false", 
        ["command"]="input /join"
    },
}
```

## Events: *All values are case-insensitive.*
 * ### Login: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="echo {NAME} logged in!"
 
 * ### Logout: `logout_<name>`
   * Triggers when a character is logged out.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged out.
     * Example: \["command"\]="echo {NAME} logged out!"
 
 * ### Chat: `chat_<mode>_<sender>_<match>`
   * Triggers when a character `<sender>`.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"
 
 * ### Invite: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"
 
 * ### Examined: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"
 
 * ### Status: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Gainbuff: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Losebuff: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Login: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Time: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Day: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Weather: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Moon: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Moonpct: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Zone: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Llup: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Lvdown: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Gainexp: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Chain: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Noammo: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### TP: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### HP: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### HPP: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### LowHP: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### CriticalHP: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### HPMax: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### MP: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### MPP: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### LowMP: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### CriticalMP: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### MPMax: `login_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"
