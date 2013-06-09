#ChatPorter v1.32  
####written by Ragnarok.Ikonic  

Displays tell, party, and linkshell chat to alternate character and optional textbox.  
Also, allows you to reply from either character.  

Requires two characters to both be using addon for it to work.  
Currently only tested and supporting two characters.  

####//ChatPorter and //cp are both valid commands.
//cp help         : Lists help menu.  
//cp status       : Shows current configuration.  
//cp textbox      : Shows current textbox configurations.
//cp colors       : Shows possible color codes.  
//cp toggle       : Toggles ChatPorter on/off.  
//cp [l|p|t] [toggle|displaychat]: Toggles linkshell|party|tell messages from showing or not.  
//cp [l|p|t] color #: Sets color of l|p|t text (acceptable values of 1-255).  
//cp [l|p|t] show: Toggles l|p|t textboxes from showing.  
//cp [l|p|t] [fontname|fn, lines, fontsize|fs, x, y, alpha|a, red|r, green|g, blue|b] #: Sets l|p|t textbox specifics.  
//[l2|p2|t2 name|r2] message: Sends message from second character to linkshell|party|tell|reply.  
//[f#|cp f#] message: Sends message from second character to ffochat channel.  
//cp help detail: Shows detailed ChatPorter commands.  
//cp help textbox: Shows detailed textbox commands.  
//cp [l|p|t] [toggle|displaychat]: Toggles linkshell|party|tell messages from showing or not.  
//cp [l|p|t] color #: Sets color of l|p|t text (acceptable values of 1-255).  
//cp [l|p|t] show: Toggles l|p|t textboxes from showing.  
//cp [l|p|t] [fontname|fn, lines, fontsize|fs, x, y, alpha|a, red|r, green|g, blue|b] #: Sets l|p|t textbox specifics.  
//[l2|p2|t2 name|r2] message: Sends message from second character to linkshell|party|tell|reply.  
//[f#|cp f#] message: Sends message from second character to ffochat channel.  
//cp help detail: Shows detailed ChatPorter commands.  
//cp help textbox: Shows detailed textbox commands.  

####ChatPorter detailed commands:  
//l2 message      : Sends message from second character to linkshell.  
//p2 message      : Sends message from second character to party.  
//t2 name message : Sends message from second character to name in tell.  
//r2 message      : Sends reply message from second character.  
//f# message      : Sends message from second character to FFOChat channel #.  Works for 1-5.  
//cp f# message   : Same as f#, but for any #.  

####ChatPorter textbox commands:  
//cp [l|p|t] [toggle|displaychat]: Toggles linkshell|party|tell messages from showing or not.  
//cp [l|p|t] color #: Sets color of l|p|t text (acceptable values of 1-255).  
//cp [l|p|t] show: Toggles l|p|t textboxes from showing.  
//cp [l|p|t] lines #: Sets # of lines to show in textbox.  
//cp [l|p|t] [fontname|fn] *: Sets fontname for textbox.  
//cp [l|p|t] [fontsize|fs] #: Sets fontsize for textbox.  
//cp [l|p|t] x #: Sets x coordinate for textbox (acceptable values: 10-[screen resolution-10]).  
//cp [l|p|t] y #: Sets y coordinate for textbox (acceptable values: 10-[screen resolution-10]).  
//cp [l|p|t] [alpha|a] #: Sets alpha (transparency) for textbox (acceptable values: 1-255; 0=fully transparent, 255=fully visible).  
//cp [l|p|t] [red|r] #: Sets red value for RGB color of text in textbox.  
//cp [l|p|t] [green|g] #: Sets green value for RGB color of text in textbox.  
//cp [l|p|t] [blue|b] #: Sets blue value for RGB color of text in textbox.  

###Changelog:  
* v0.0  05/20/13 Created addon.  
* v1.0  05/22/13 Testing, variable setup, boolean conversion, added toggles.  
* v1.1  05/25/13 Added l2/p2/t2/r2 options to chat on 2nd char from 1st.  
* v1.11 05/25/13 Added support for FFOChat replying.  
* v1.12 05/29/13 Removed testing code, removed unused functions.  
* v1.13 05/29/13 More cleaning of code, added some color functions, variable formatting.  
* v1.2  05/31/13 Added settings.xml data and ability to change/use it.  
* v1.21 05/31/13 Added code to change colors and option to list colors.  
* v1.3  06/06/13 Added textboxes and user settings for l/p/t chat.  Redid help options.  
* v1.31 06/07/13 Settings can now be set for each character and are only saved when a change is made.  
* v1.32 06/09/13 Fixed bug where textboxes would vanish on first run through.  Added clear option for textboxes.  Fixed issue of textbox settings not always saving.  
