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
   * Triggers when a character is logged in with a specified name.
     * `<name>`: Players name.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged in.
     * Example: \["command"\]="echo {NAME} logged in!"
 
 * ### Logout: `logout_<name>`
   * Triggers when a character is logged out with a specified name.
     * `<name>`: Players name.
   * **String Interpolation:**
     * {NAME} - Name of the player that logged out.
     * Example: \["command"\]="echo {NAME} logged out!"

 * ### jobchange: `jobchange_<main>/<sub>`
   * Triggers when a character changes to the specified jobs. *(Supports Full and Short job names)* [Jobs](https://github.com/Windower/Resources/blob/master/resources_data/jobs.lua)
     * `<main>`: Main job specified to match.
     * `<sub>`: Sub job specified to match.
   * **String Interpolation:**
     * {MAIN_FULL} - Full length English name of current main job.
     * {MAIN_SHORT} - Shortened English name of current main job.
     * {SUB_FULL} - Full length English name of current sub job.
     * {SUB_SHORT} - Shortened English name of current sub job.
     * {MAIN_LV} - Current level of the main job.
     * {SUB_LV} - Current level of the sub job.
     * Example: \["command"\]="echo Current Job: {MAIN_SHORT}{MAIN_LV}/{SUB_FULL}{SUB_LV}."

 * ### jobchangefull: `jobchangefull_<main><main_level>/<sub><sub_level>`
   * Triggers when a character is logged out with a specified name. *(Supports Full and Short job names)* [Jobs](https://github.com/Windower/Resources/blob/master/resources_data/jobs.lua)
     * `<main>`: Main job specified to match.
     * `<sub>`: Sub job specified to match.
   * **String Interpolation:**
     * {MAIN_FULL} - Full length English name of current main job.
     * {MAIN_SHORT} - Shortened English name of current main job.
     * {SUB_FULL} - Full length English name of current sub job.
     * {SUB_SHORT} - Shortened English name of current sub job.
     * {MAIN_LV} - Current level of the main job.
     * {SUB_LV} - Current level of the sub job.
     * Example: \["command"\]="echo Current Job: {MAIN_SHORT}{MAIN_LV}/{SUB_FULL}{SUB_LV}."
 
 * ### Chat: `chat_<mode>_<sender>_<match>`
   * Triggers when a character `<sender>`, sends a chat message with the specified `<mode>` and a matching string `<match>`. [Chat](https://github.com/Windower/Resources/blob/master/resources_data/chat.lua)
     * `<mode>`: String name of the chat mode.
     * `<sender>`: Person that sent the message.
     * `<match>`: A string representation of the word to look for in the senders message.
   * **String Interpolation:**
     * {SENDER} - Name of the player that sent the message.
     * {MODE} - English name of the chat mode.
     * {MATCH} - String that was being searched for.
     * Example: \["command"\]="echo {SENDER} sent a /{MODE}! Match Found: {MATCH}"
 
 * ### Invite: `invite_<name>`
   * Triggers when a player send you a party invite and they have a specified name.
     * `<sender>`: Person that sent the party invite.
   * **String Interpolation:**
     * {SENDER} - Name of the player that sent party invite.
     * Example: \["command"\]="echo {SENDER} sent a party invite!; wait 1; input /join"
 
 * ### Examined: `examined_<name>`
   * Triggers when a character examines you and they have a specified name.
     * `<name>`: Name of the player that examined you.
   * **String Interpolation:**
     * {NAME} - Name of the player that examined you.
     * Example: \["command"\]="input /slap {NAME}"
 
 * ### Status: `status_<name>`
   * Triggers when a characters status changes and matches a specified status. [Statuses](https://github.com/Windower/Resources/blob/master/resources_data/statuses.lua)
     * `<name>`: Name of the new status the player is currently in.
   * **String Interpolation:**
     * {NEW} - English name of the new status.
     * {OLD} - English name of the old status.
     * Example: \["command"\]="echo Went from {OLD} to {NEW}"

 * ### Gainbuff: `gainbuff_<name>`
   * Triggers when a character gains a specified buff. *This DOES NOT include buff overwriting!* [Buffs](https://github.com/Windower/Resources/blob/master/resources_data/buffs.lua)
     * `<name>`: Name of the buff the player gained.
   * **String Interpolation:**
     * {NAME} - English name of the buff gained.
     * {ID} - ID of the buff gained.
     * Example: \["command"\]="echo Gained buff: {NAME}[{ID}]"

 * ### Losebuff: `losebuff_<name>`
   * Triggers when a character loses a specified buff. [Buffs](https://github.com/Windower/Resources/blob/master/resources_data/buffs.lua)
     * `<name>`: Name of the buff the player lost.
   * **String Interpolation:**
     * {NAME} - English name of the buff lost.
     * {ID} - ID of the buff lost.
     * Example: \["command"\]="echo Lost buff: {NAME}[{ID}]"

 * ### Time: `time_<hh.mm>`
   * Triggers when the game time changes and matches a specified time.
     * `<hh>`: 2 digit number representing game hours.
     * `<mm>`: 2 digit number representing game minutes.
     * **Must be separated by a `.`!** *Example: `time_23.05`*
   * **String Interpolation:**
     * {NEW_HOUR} - The new current hour in game.
     * {NEW_MINUTE} - The new current minutes in game.
     * {OLD_HOUR} - The previous hour in game.
     * {OLD_MINUTE} - The previous minutes in game.
     * Example: \["command"\]="echo Time changed from {OLD_HOUR}:{OLD_MINUTES} to (NEW_HOUR}:{NEW_MINUTES}."

 * ### Day: `day_<name>`
   * Triggers when a game day changes and matches a specified day name. [Days](https://github.com/Windower/Resources/blob/master/resources_data/days.lua)
     * `<name>`: Name of the day changing too.
   * **String Interpolation:**
     * {NEW} - English name of the day changed too.
     * {OLD} - English name of the day changed from.
     * Example: \["command"\]="input /p What a glorious new {NEW}!"

 * ### Weather: `weather_<name>`
   * Triggers when a weather changes and matches a specified name. [Weather](https://github.com/Windower/Resources/blob/master/resources_data/weather.lua)
     * `<name>`: Name of the weather being changed too.
   * **String Interpolation:**
     * {NEW} - English name of the new weather.
     * {OLD} - English name of the previous weather.
     * Example: \["command"\]="echo Weather changed from {OLD} to {NEW}."

 * ### Moon: `moon_<name>`
   * Triggers when the moon changes and is a specified phase. [Moon Phases](https://github.com/Windower/Resources/blob/master/resources_data/moon_phases.lua)
     * `<name>`: The Name of the moon being changed too.
   * **String Interpolation:**
     * {NEW} - English name of the new moon phase.
     * {OLD} - English name of the old moon phase.
     * Example: \["command"\]="echo Moon changed from {OLD} to {NEW}."

 * ### Moonpct: `moonpct_<percent>`
   * Triggers when the moon changes and matches a specified percent.
     * `<percent>`: The percent to check for when the moon phase changes.
   * **String Interpolation:**
     * {PERCENT} - Current % the moon phase is at.
     * Example: \["command"\]="echo Moon is at {PERCENT}%!"

 * ### Zone: `zone_<name>`
   * Triggers when a character zones in to a specified zone. [Zones](https://github.com/Windower/Resources/blob/master/resources_data/zones.lua)
     * `<name>`: The Name of the zone currently being entered.
   * **String Interpolation:**
     * {NEW} - English name of the new zone.
     * {OLD} - English name of the previous zone.
     * Example: \["command"\]="input /p I just left {OLD} and entered {NEW}."

 * ### Lvup: `lvup_<number>`
   * Triggers when a character levels up to a specified level.
     * `<number>`: The number of the players level.
   * **String Interpolation:**
     * {LEVEL} - Current new level of the player.
     * Example: \["command"\]="echo Leveled up to Lv.{LEVEL}. :happy:"

 * ### Lvdown: `lvdown_<number>`
   * Triggers when a character levels down to a specified level.
     * `<number>`: The number of the players level.
   * **String Interpolation:**
     * {LEVEL} - Current new level of the player.
     * Example: \["command"\]="echo Leveled down to Lv.{LEVEL}. :sad:"

 * ### Gainexp: `gainexp_<amount>`
   * Triggers when a character gains XP to the specified amount.
     * `<amount>`: The amount of XP being gained.
   * **String Interpolation:**
     * {XP} - Number amount of experience points gained.
     * Example: \["command"\]="echo Gained {XP}xp!"

 * ### Chain: `chain_<number>`
   * Triggers when a character gets a specified XP Chain.
     * `<number>`: The XP chain number to match.
   * **String Interpolation:**
     * {XP} - Number amount of experience points gained.
     * {CHAIN} - Number of the current Experience Chain.
     * Example: \["command"\]="echo Gained {XP}xp! XP Chain #{CHAIN}!"

 * ### Noammo: `noammo`
   * Triggers when a characters ammo is no longer equipped.
     * `NONE!`
   * **String Interpolation:**
     * `NONE!`
     * Example: \["command"\]="input //gs c equip_ammo"

 * ### TP: `tp_<percent>`
   * Triggers when a characters TP reachs a specified TP.
     * `<percent>`: The percent of TP to match.
   * **String Interpolation:**
     * {NEW} - The current amount of TP.
     * {OLD} - The previous amount of TP.

 * ### HP: `hp_<number>`
   * Triggers when a characters HP reachs a specified number.
     * `<number>`: The amount of HP to match.
   * **String Interpolation:**
     * {NEW} - The current amount of HP.
     * {OLD} - The previous amount of HP.

 * ### HPP: `hpp_<percent>`
   * Triggers when a characters HP% matches a specified percent.
     * `<percent>`: The percent of HPP to match.
   * **String Interpolation:**
     * {NEW} - The current amount of HP%.
     * {OLD} - The previous amount of HP%.

 * ### LowHP: `lowhp`
   * Triggers when a characters HP% drops below 20%. *Will not trigger again until above 40%*
     * `NONE!`
   * **String Interpolation:**
     * {NEW} - The current amount of HP%.
     * {OLD} - The previous amount of HP%.

 * ### CriticalHP: `criticalhp`
   * Triggers when a characters HP% drops below 5%. *Will not trigger again until above 20%*
     * `NONE!`
   * **String Interpolation:**
     * {NEW} - The current amount of HP%.
     * {OLD} - The previous amount of HP%.

 * ### HPMax: `hpmax_<number>`
   * Triggers when a characters Max HP reachs a specified number.
     * `<number>`: The amount of Max HP to match.
   * **String Interpolation:**
     * {NEW} - The current amount of HP.
     * {OLD} - The previous amount of HP.

 * ### MP: `mp_<number>`
   * Triggers when a characters MP matches a specified number.
     * `<number>`: The amount of MP to match.
   * **String Interpolation:**
     * {NEW} - The current amount of HPP.
     * {OLD} - The previous amount of HPP.

 * ### MPP: `mpp_<percent>`
   * Triggers when a characters MP% matches a specified percent.
     * `<percent>`: The percent of MP% to match.
   * **String Interpolation:**
     * {NEW} - The current amount of MP%.
     * {OLD} - The previous amount of MP%.

 * ### LowMP: `lowmp`
   * Triggers when a characters HP% drops below 20%. *Will not trigger again until above 40%*
     * `NONE!`
   * **String Interpolation:**
     * {NEW} - The current amount of MP%.
     * {OLD} - The previous amount of MP%.

 * ### CriticalMP: `criticalmp`
   * Triggers when a characters HP% drops below 5%. *Will not trigger again until above 20%*
     * `NONE!`
   * **String Interpolation:**
     * {NEW} - The current amount of MP%.
     * {OLD} - The previous amount of MP%.

 * ### MPMax: `mpmax_<number>`
   * Triggers when a characters Max MP reachs a specified number.
     * `<number>`: The amount of Max MP to match.
   * **String Interpolation:**
     * {NEW} - The current amount of MP%.
     * {OLD} - The previous amount of MP%.

 * ### HPP\<76%: `hpplt76`
   * Triggers when a characters HP% is less than 76%.
   * **String Interpolation:**
     * `NONE!`

 * ### HPP\>75%: `hppgt75`
   * Triggers when a characters HP% is greater than 75%.
   * **String Interpolation:**
     * `NONE!`

 * ### MPP\<50%: `mpplt50`
   * Triggers when a characters MP% is less than 50%.
   * **String Interpolation:**
     * `NONE!`

 * ### MPP\>49%: `mppgt49`
   * Triggers when a characters MP% is greater than 49%.
   * **String Interpolation:**
     * `NONE!`
