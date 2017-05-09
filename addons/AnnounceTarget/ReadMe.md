**Authors:** JoshK6656, Sechs  
**Version:** 1.2.1  
**Date:** 12/02/2015  
  
**Description:**  
AnnounceTarget checks your current target and produces various chat messages according to settings.  
At the moment it works for Incursion: if target is an Incursion Adherent it will send a message to the preferred chat mode saying the Adherent's job and the buffs it gives to the linked Boss.  
  
  
**Commands:**  
//announcetarget reload  
//announcetarget unload  
//announcetarget chatmode say|party|linkshell|linkshell2|shout  
//announcetarget autoannounce on|true|off|false  
//announcetarget announce  
//announcetarget clear  
  
  
**Short commands:**  
//at reload  
//at unload  
//at cm s|p|l|l2|sh  
//at aa t|f|0|1  
//at a  
//at c  
  
  
**Commands details:**  
*Reload/Unload: Reloads or Unloads the addon, respectively  
*Chatmode: Used to change the output chat mode. By default it's set to party.  
*AutoAnnounce: If AutoAnnounce is turned on the addon will automatically announce in the selected chat mode whenever you target an Adherent.  
It will remember, through mob_id, the Adherents it has already announced, so there won't be any risk of spamming chat with the same Adherent over and over.  
This list is temporary and clears up each time you reload the addon, otherwise you can manually clear it by using the specific command  
*Announce: Manual command to announce the current target. Works regardles of AutoAnnounce being on or off  
*Clear: Used to clear the list of "already announced mobs". This list already clears each time you zone or reload the addon.  
