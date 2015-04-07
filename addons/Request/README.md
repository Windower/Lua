Author: Selindrile
Thanks to: Booshack
LUA coding and support: Montaeg
Beta Testers: Hrothgar & Terezka
Information and Borrowed code: Arcon

Version: 1.1
Automatically perform actions upon request.

Abbreviation: //rq, //request

Commands:
* <whitelist|blacklist> <add|remove> <player> - adds or removes a player from blacklist or whitelist.
* <nickname> <add|remove> <word> - adds or removes a word from nickname list.
* mode <whitelist|blacklist> - changes to whitelist or blacklist, if no mode specified then it will print current mode.
* Partylock <on|off> - turns party lock on or off, if no status specified then it will print current status.
* Requestlock <on|off> - turns request lock on or off, if no status specified then it will print current status.
* Exactlock <on|off> - turns exact command lock on or off, if no status specified then it will print current status.
* status - will print status of current options, including full whitelist, blacklist, and keyword list.

Warnings and Reccomendations:

Be careful with exact lock, if off it will allow anyone on your whitelist or anyone not on your blacklist in that mode to
input whatever they want as if they were at your console.

Without the use of shortcuts, Request has little functionality outside of party management, I highly reccomend using it.
With creative use of aliases, you can have Request do almost anything you want and still be relatively safe.