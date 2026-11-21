**Author:** Ricky Gall  
**Version:** 1.26
**Description:**  
Addon to make setting blue spells easier. Currently only works as blu main.

**Abbreviations:** aset, azureset

**Commands:**
 1. //aset removeall - Unsets all spells and stops a spellset being set.
 2. //aset spellset <setname> [ClearFirst|PreserveTraits] -- Set (setname)'s spells,
                  optional parameter: ClearFirst or PreserveTraits: overrides
                  setting to clear spells first or remove individually,
                  preserving traits where possible. Default: use settings or
                  preservetraits if settings not configured.
                  Takes over from a spellset still being set.
 3. //aset set <setname> [ClearFirst|PreserveTraits] -- Same as spellset
 4. //aset add &lt;slot&gt; &lt;spell&gt; -- Set (spell) to slot (slot (number)).
 5. //aset save &lt;setname&gt; -- Saves current spellset as (setname).
 6. //aset currentlist -- Lists currently set spells.
 7. //aset setlist -- Lists all spellsets with their spells and points.
 8. //aset spelllist &lt;setname&gt; -- List spells in (setname) with points and problems
 9. //aset stop -- Stops setting the spellset currently being set.
10. //aset check [setname] -- Lists spells that can't be set, in (setname) or all sets.
11. //aset help --Shows this menu.

**Changes:**  
v1.26
* Each change now waits until the game shows it, instead of a fixed timer.
* setspeed is now an optional minimum time between changes, default 0. Values already in your settings still apply.
* Added setting setjitter: a short random pause between changes. Default: 0.15 seconds.
* Added setting replace: swaps a spell straight into an unwanted spell's slot. Default: true.
* PreserveTraits now fills empty slots before removing anything.
* Spells that can't be set are skipped and listed at the end, instead of stopping the set.
* Warns before setting if a spellset needs more slots or points than you have.
* Setting a spellset while another is being set now takes over from it. removeall also stops it.
* Added //aset stop and //aset check.
* The cooldown timer only starts when spells changed.
* A set counts as equipped once everything this character can set from it is set.
* setlist and spelllist now show points and problems.
* save notes when a set has the same spells as another.
* add checks the spell is learned and counts the points of the spell it replaces.
* Set names work in any case, and full names work for abbreviated spells.
* //aset with no command now shows help.

v1.25
* Added compatibility for settings spells while sub job blu.

v1.23 - v1.24
 * Changed default spellset method to preserve traits.
 * Added setting for setmethod to either PresereTraits or ClearFirst.
 * Added setting for setspeed. Wait time between each spell being set. Faster timing
        may result in multiple attempts at setting the spell and could lead to
        increased total set time. Default: 0.65 seconds.
        
v1.15 - v1.22  
 * Fixed spells that were missing
 * Recoded for 4.1

v1.1 - v1.15  
 * Added spellset listing
 * Added listing a given set's spells
 * Added default VW sets (VW1 and VW2) which include Wind, Thunder, Light, Dark and Fire, Ice, Water, Earth (respectively)
 * Added //aset list into the help menu given in game (it worked before but i forgot to include it)

v1.0 - v1.1  
 * Fixed issue with saving sets.
