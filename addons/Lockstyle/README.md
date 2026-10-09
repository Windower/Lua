**Authors:** Sechs  
**Version:** 1.2
**Date:** 09/09/2026
  
  
**Description:**  
Lockstyle is a very simple addon that allows you to define a list of lockstyles for each job, customizable for each of your character.
Once you have a list ready for the current job you're on, Lockstyle will pick a random one in the list and will apply that lockstyle, mantaining it if for any reason it gets removed.
Lockstyle won't reapply your lockstyle if you manually change to another one through the in-game commands.
Lockstyle picks a random style each time you swap your main job to a job that has a list defined in the config file.
Alternatively you can use the manual command to force a reroll.
By default the delay is set to 10 seconds but this number can be changed in the config file.
The delay is ignored when you use the reroll manual command.
The apply_on_login setting if set on true (default) also applies the lockstyle when you login or relog coming from a mule. If set to false it only applies it when you change job, subjob, manual command etc.
  
  
**Commands:**  
* //ls reload
* //ls random
* //ls reroll
* //ls status


**Commands details:**  
* full command is //lockstyle but //ls is also accepted
* reload - Reloads the xml file
* random - rerolls the current lockstyle
* reroll - same as above
* status - displays a list of the currently defined sets

**Special Note on Delay:**
If you put a delay under 10 seconds (which is the default value) it will probably work most of the time, but there is at least one specific situation where you will incur into an error. If you remove the lockstyle (with the in-game command /lockstyle off) that counts as a lockstyle command, the same as the one that apply it. As such, it DOES incur into the serverwide 10 seconds cooldown. Which means the addon would try to reapply the just lost lockstyle again with a delay of under 10 seconds, resulting in an in-game error because the cooldown is not over yet. So I warmly suggest to not put the delay under 10.
