PetSchool v 1.0.0

PetSchool is a simple helper addon for Spellcast.  I created this because before lua, I had to make really strange XML's for both Spellcast and Autoexec to let spellcast know when sneak attack and trick attack were no longer in effect (landed or wore).  This addon is merely a middleman that tells spellcast when it wears and switches to your appropriate gear sets.  Another function of this addon is to inform spellcast when Treasure Hunter has been initially placed on the mob.

To install, have the PetSchool folder containing this readme, the PetSchool.lua, and a "data" folder in your "addons" folder for windower v4.

To use, simply type "//lua l PetSchool" in game.  This can be added to init.txt or loaded automatically via the windower v4 launcher.  All updates will be available via the launcher.

Upon initial load, a settings file will be created with default values.  YOU WILL WANT TO EDIT THIS SETTINGS FILE TO SUPPORT YOUR SPELLCAST XML.

The settings that are loaded are:

PetNuke Set: <name_of_Pet_Nuking_Set_in_your_spellcast_XML>
PetHeal Set: <name_of_Pet_Healing_Set_in_your_spellcast_XML>
TP Set: <name_of_TP_Set_in_your_spellcast_XML>
Idle Set: <name_of_Idle_Set_in_your_spellcast_XML>

Simply type the names of the respective sets after the colon (:) exactly how they appear in your spellcast XML.  If you use spaces in the spellcast XML, they will need to be removed or this addon will not function correctly.

Commands:

//ps [options]
	reload - Reloads Settings
	help   - Displays Version information and commands
