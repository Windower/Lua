#Blist v1.0  
####written by Ragnarok.Ikonic  

More detailed blist with tiered display options.  Allows for blist to be active on any or all of several chat types.  

####//Blist and //bl are both valid commands.  
//bl help�: Lists this menu.  
//bl status�: Shows current configuration.  
//bl list�: Displays blacklist.  
//bl useblist|linkshell|party|tell|emote|say|shout|bazaar|examine : Toggles using Blist for said chat mode.  
//bl mutedcolor #�: Sets color for muted communication.  Valid values 1-255.  
//bl add|update name # hidetype reason : Adds to or updates a user on your blist.  
  name� = name of person you want to blist  
  #� = number of days to blist said person; 0 = forever  
  hidetype� = how blacklisted you want said person to be; valid options: hard, soft, muted  
    hard� = full blist, nothing gets through  
    soft� = message saying conversation from name was blocked  
    muted� = message comes through, but in a different color  
  reason� = reason why you are adding said person to blist  
//bl delete|remove name� : Removes a user from your blist.  

###Changelog:  
* v0.0  06/08/13 Created addon.  
* v1.0  06/08/13 Public release.  
