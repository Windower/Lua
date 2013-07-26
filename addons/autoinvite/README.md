Author: Registry
Version: 1.0
Automatically invites players when sent a tell with a specified keyword.

Abbreviation: //ai, //autoinvite

Commands:
* <whitelist|blacklist> <add|remove> <player> - adds or removes a player from blacklist or whitelist.
* <keyword> <add|remove> <word> - adds or removes a word from keyword list.
* mode <whitelist|blacklist> - changes to whitelist or blacklist, if no mode specified then it will print current mode.
* tellback <on|off> - turns tellback mode on or off, if no status specified then it will print current status.
* status - will print status of current options, including full whitelist, blacklist, and keyword list.


If tellback mode is turned on and you are unable to send an invite to the player who sent you a tell with the 
specified keyword, you will automatically send them a tell back saying that you were unable to invite them. 