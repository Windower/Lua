**Author:** Ricky Gall  
**Version:** 1.24
**Description:**  
Addon to make setting blue spells easier. Currently only works as blu main.

**Abbreviations:** aset, azureset

**Commands:**
 1. //aset removeall - Unsets all spells.
 2. //aset spellset <setname> [ClearFirst|PreserveTraits] -- Set (setname)'s spells,
                  optional parameter: ClearFirst or PreserveTraits: overrides
                  setting to clear spells first or remove individually,
                  preserving traits where possible. Default: use settings or
                  preservetraits if settings not configured.
 3. //aset set <setname> [ClearFirst|PreserveTraits] -- Same as spellset
 4. //aset add &lt;slot&gt; &lt;spell&gt; -- Set (spell) to slot (slot (number)).
 5. //aset save &lt;setname&gt; -- Saves current spellset as (setname).
 6. //aset currentlist -- Lists currently set spells.
 7. //aset setlist -- Lists all spellsets.
 8. //aset spelllist &lt;setname&gt; -- List spells in (setname)
 9. //aset help --Shows this menu.

**Changes:**  
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
