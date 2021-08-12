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
     * `<name>`: Players name.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="echo {NAME} logged in!"
 
 * ### Logout: `logout_<name>`
   * Triggers when a character is logged out.
     * `<name>`: Players name.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged out.
     * Example: \["command"\]="echo {NAME} logged out!"
 
 * ### Chat: `chat_<mode>_<sender>_<match>`
   * Triggers when a character `<sender>`, sends a chat message with the specified `<mode>` and a mathching string `<match>`.
     * `<mode>`: String name of the chat mode. [Chat](https://github.com/Windower/Resources/blob/master/resources_data/chat.lua)
     * `<sender>`: Person that sent the message.
     * `<match>`: A string representation of the word to look for in the senders message.
   * **String Interpolation:**
     * {SENDER} - Name of the player that sent the message.
     * {MODE} - English name of the chat mode.
     * {MATCH} - String that was being searched for.
     * Example: \["command"\]="echo {SENDER} sent a /{MODE}! Match Found: {MATCH}"
 
 * ### Invite: `invite_<name>`
   * Triggers when a player send you a party invite.
     * `<sender>`: Person that sent the party invite.
   * **String Interpolation:**
     * {SENDER} - Name of the player that sent party invite.
     * Example: \["command"\]="echo {SENDER} sent a party invite!; wait 1; input /join"
 
 * ### Examined: `examined_<name>`
   * Triggers when a character examines you.
     * `<name>`: Name of the player that examined you.
   * **String Interpolation:**
     * {NAME} - Name of the player that examined you.
     * Example: \["command"\]="input /slap {NAME}"
 
 * ### Status: `status_<name>`
   * Triggers when a characters status changes.
     * `<name>`: Name of the new status the player is currently in. [Statuses](https://github.com/Windower/Resources/blob/master/resources_data/statuses.lua)
   * **String Interpolation:**
     * {NEW} - English name of the new status.
     * {OLD} - English name of the old status.
     * Example: \["command"\]="echo Went from {OLD} to {NEW}"

 * ### Gainbuff: `gainbuff_<name>`
   * Triggers when a character gains a buff. *This DOES NOT include buff overwriting!*
     * `<name>`: Name of the buff the player gained.
   * **String Interpolation:**
     * {NAME} - English name of the buff gained.
     * {ID} - ID of the buff gained.
     * Example: \["command"\]="echo Gained buff: {NAME}[{ID}]"

 * ### Losebuff: `losebuff_<name>`
   * Triggers when a character loses a buff.
     * `<name>`: Name of the buff the player lost.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Time: `time_<hh.mm>`
   * Triggers when the game time changes.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Day: `day_<name>`
   * Triggers when a game day changes.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Weather: `weather_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Moon: `moon_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Moonpct: `moonpct_<percent>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Zone: `zone_<name>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Lvup: `lvup_<number>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Lvdown: `lvdown_<number>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Gainexp: `gainexp_<amount>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Chain: `chain_<number>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### Noammo: `noammo`
   * Triggers when a characters ammo is no longer equipped.
   * **String Interpolation:**
     * NONE!
     * Example: \["command"\]="input //gs c equip_ammo"

 * ### TP: `tp_<percent>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### HP: `hp_<number>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### HPP: `hpp_<percent>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### LowHP: `lowhp`
   * Triggers when a characters HP% drops below 20%. *Will not trigger again until above 40%*
   * **String Interpolation:**
     * {NEW} - New HP% value.
     * {OLD} - Old HP% value.
     * Example: \["command"\]="input /p HP is getting low! Currently {NEW}%"

 * ### CriticalHP: `criticalhp`
   * Triggers when a characters HP% drops below 5%. *Will not trigger again until above 20%*
   * **String Interpolation:**
     * {NEW} - New HP% value.
     * {OLD} - Old HP% value.
     * Example: \["command"\]="input /p HP is getting low! Currently {NEW}%"

 * ### HPMax: `hpmax_<number>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### MP: `mp_<number>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### MPP: `mpp_<percent>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### LowMP: `lowmp`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### CriticalMP: `criticalmp`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"

 * ### MPMax: `mpmax_<number>`
   * Triggers when a character is logged in.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="input /acmd add {SENDER}"
