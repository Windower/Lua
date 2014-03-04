name = 'SubTarget'
version = '1.0'
author = 'Sebyg666'

Must have the "send" addon to work

can use //subtarget or //sta

Command "HELP" or no command:

	Explanation of the addons usage printed to the console, essentially the 2 commands below.

Command "GO":     
                                                        
	subtarget|sta go mule_name spell_name                              
	- Main usage.                                                       
	- create an ingame macro with 2 lines                               
		- line 1: /target <stal>                                     
		- line 2: /con sta go mule_name spell_name                 
	- This sends your mule the spell + the target selected from <stal> 
 
Command "TOGGLE":              
                                           
	subtarget|sta toggle                                                
	- turns on|off ingame text verification for debugging  

I created this addon for the perpous of fasilitating casting buffs from my alt to the chosen party member from my mains
window without having to write 6 macros for the same spell. If you use <stal> in your macro you can easily target
alliance members too. you can also use this with <stpc>. 

Currently due to the limitations of mob targeting this does not apply to <stnpc> as i do not know how to force the alt to target a mob by ID.

**********************************************************************************

example macro:

line 1:  /target <stal>
line 2:  /con sta go Arcon haste

if main name is Iroku, Arcon the mule and Byrth the target of <stal>, then essentially the macro makes your mule,
Arcon, cast haste on Byrth.

