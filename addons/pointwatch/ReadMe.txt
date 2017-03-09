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

Other Commands:
* message_printing - See FIXING POINTWATCH.txt in this directory for a full explanation.



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
* lp.maximum_merits       = Maximum number of merits you can store.

* cp.current              = Current Capacity Points (number from 0 to 29,999 CP)
* cp.rate                 = Current CP gain rate per hour. This is calculated over a 10 minute window and requires at least two gains within the window.
* cp.total                = Total Capacity Points gained since the last time the addon was loaded (number)
* cp.tnjp                 = Similar to a "To Next Level", but this value is always 30,000 because that's always the number of CPs per job point.
* cp.number_of_job_points = Number of job points you currently have on your current job.

* sparks.current          = Current number of RoE Sparks (number between 0 and 50,000)
* sparks.maximum          = Maximum number of RoE Sparks (always 50,000)

* accolades.current       = Current number of Unity Accolades (number between 0 and 50,000)
* accolades.maximum       = Maximum number of Unity Accolades (always 50,000)

* dynamis.KIs             = Series of Xs and Os indicating whether or not you have the 5 KIs.
* dynamis.entry_time      = Your Dynamis entry time, in seconds. -- If the addon is loaded in dynamis, this will be the time of addon load.
* dynamis.time_limit      = Your current Dynamis time limit, in seconds. -- If the addon is loaded in dynamis, you will need to gain a KI for this to be accurate.
* dynamis.time_remaining  = The current dynamis time remaining, in seconds. -- Will not be accurate if the addon is loaded in dynamis.

* abyssea.amber           = Amber light estimation
* abyssea.azure           = Azure light estimation
* abyssea.ruby            = Ruby light estimation
* abyssea.pearlescent     = Pearlescent light estimation
* abyssea.golden          = Gold light estimation
* abyssea.silvery         = Silvery light estimation
* abyssea.ebon            = Ebon light estimation
* abyssea.last_time       = The last time you got a time message, in seconds.  -- Not implemented
* abyssea.time_limit      = The current abyssea time remaining, in seconds. -- Approximate to the minute, not fully implemented
* abyssea.time_remaining  = The current abyssea time remaining, in seconds. -- Approximate to the minute, not fully implemented



Version History:
0.150811 - Changed job_points from a char to a short.
0.150201 - Added Unity Accolades.
0.141111 - Adjusted Pointwatch to account for a recent packet change.
0.141101 - Reversed my versioning scheme, adjusted the limit point and experience point calculations slightly.
0.101214 - Made pointwatch hide itself while zoning.
0.062014 - Added lp.maximum_merits.
0.050214 - Fixed the Dynamis clock. Added Abyssea lights.
0.042314 - Addition of strings system
0.042014 - Addition of strings system
0.041214 - Initial commit