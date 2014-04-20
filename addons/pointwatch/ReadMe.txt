=== PointWatch ===
Allows you to monitor your XP/CP gains and keep track of the Dynamis time limit.

Abbreviation: //pw

Text Box Commands:  
* show - Shows the text box.
* hide - Hides the text box.
* pos <X> <Y> - Moves the upper left corner of the text box to the coordinates X/Y.
* font <font name> - Changes the text's font.
* size <point size> - Changes the size of the text's font.
* color <R> <G> <B> - Changes the text color. Numbers should be between 0 and 255.
* bg_color <R> <G> <B> - Changes the background color. Numbers should be between 0 and 255.
* bg_transparency <number> - Changes the background transparency. Number should be between 0 and 1
** pos_x, pos_y, pad, transparency, alpha, and bg_alpha are also valid commands and are documented in the texts library.



Strings Options:  
The two strings options in settings.xml are loaded as Lua code and run accordingly,
so you can do things like adjust numbers and format things as you wish. The default
is designed to look somewhat like the Attainment plugin, but you are free to change
it however you wish. Be aware that the code will give very unhelpful errors when it fails.

Here are the available values:  
* xp.current              = Current Experience Points (number from 0 to 55,999 XP)
* xp.tnl                  = Number of Experience Points in your current level (number from 500 to 56,000)
* xp.rate                 = Current XP gain rate per hour. This is calculated over a 10 minute window and requires at least two gains within the window.
* xp.total                = Total Experience Points gained since the last time the addon was loaded (number)

* lp.current              = Current Experience Points (number from 0 to 55,999 XP)
* lp.tnl                  = Similar to a "To Next Level", but this value is always 10,000 because that's always the number of Limit Points per merit point.
* lp.number_of_merits     = Number of merit points you have.

* cp.current              = Current Capacity Points (number from 0 to 29,999 CP) -- Yet to be implemented
* cp.rate                 = Current CP gain rate per hour. This is calculated over a 10 minute window and requires at least two gains within the window.
* cp.total                = Total Capacity Points gained since the last time the addon was loaded (number)
* cp.tnjp                 = Similar to a "To Next Level", but this value is always 30,000 because that's always the number of CPs per job point.
* cp.number_of_job_points = Number of job points you currently have on your current job. -- Yet to be implemented

* dynamis.KIs             = Series of Xs and Os indicating whether or not you have the 5 KIs.
* dynamis.entry_time      = Your Dynamis entry time, in seconds. -- If the addon is loaded in dynamis, this will be the time of addon load.
* dynamis.time_limit      = Your current Dynamis time limit, in seconds. -- If the addon is loaded in dynamis, you will need to gain a KI for this to be accurate.
* dynamis.time_remaining  = The current dynamis time remaining, in seconds. -- Will not be accurate if the addon is loaded in dynamis.



Version History:
0.04202014 - Addition of strings system
0.04122014 - Initial commit