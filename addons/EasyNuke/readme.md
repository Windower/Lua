EasyNuke provides universal commands for casting single target and area of effect BLM and GEO nukes, and WHM cures.

Commands:

element #
* Changes current element mode to #.
** EX: //ez element ice <<<< Sets mode to ice.
** Macro usage: /con ez element #
** Valid arguments: Fire, Wind, Thunder, Light, Ice, Water, Earth, Dark, Drain, Aspir, Absorb, Cure
*** Drain and Aspir Mode: Aspir, Aspir II, Aspir III, Drain, Drain II, Drain III
*** Absorb Mode: Absorb-Acc, Absorb-TP, Absorb-Attri, Absorb-STR, Absorb-DEX, Absorb-VIT, Absorb-AGI, Absorb-INT, Absorb-MND, Absorb-CHR
*** EX: //ez element absorb  >>> //ez boom 4 <<<< Casts Absorb-STR

cycle
* Cycles through element modes in the following left-to-right order: Fire, Wind, Thunder, Light, Ice, Water, Earth, Dark
** EX: //ez cycle <<<< If you were in Light mode, then you will change to Ice mode.
** Macro usage: /con ez cycle

cycle back
* Same as "cycle", but goes in right-to-left order.
** EX: //ez cycle back <<<< If you were in Light mode, then you will change to Thunder mode.
** Macro usage: /con ez cycle back

cycle dark
* Cycles through element modes in the following order: Ice, Water, Earth, Dark
** EX: //ez cycle dark <<<< If you were in Light mode, then you will change to Ice mode.
** Macro usage: /con ez cycle dark

cycle light
* Cycles through element modes in the following order: Fire, Wind, Thunder, Light
** EX: //ez cycle light <<<< If you were in Light mode, then you will change to Ice mode.
** Macro usage: /con ez cycle light

cycle #
* Cycles between the two elements of a T2 skillchain.
** Fusion: Fire, Light
** Fragmentation, Frag, F: Thunder, Wind
** Distortion, Dist, D: Ice, Water
** Gravitation, Grav, G: Earth, Dark
*** EX: //ez cycle dist <<<< If you were in Ice mode, will change you to Water mode. If you were in any other mode, will change you to Ice mode.
*** Macro usage: /con ez cycle fragmentation

target #
* Changes targeting mode to #.  This sets what's between the < > brackets used for targeting in macros.
** EX: //ez target bt <<<< Spells will be cast using <bt>.
*** There are no failsafes for this. Any given argument will be accepted, even if it does not function as a targeting argument.
*** If no argument is given, then will cycle through target modes in the following order: t, bt, stnpc
** Macro usage: /con ez target #   OR   /con ez target

showcurrent
* Echoes the current elemental and targeting modes in the chat log.
** EX: //ez showcurrent
** Macro usage: /con ez showcurrent

boom #
* Casts a single target tier# nuke of the current element, and using the current targeting mode.
** EX: //ez boom 4 <<<< If in "fire" mode, and mode is "t", will cast Fire IV on your current target.
** Macro usage: /con ez boom #

boomga #
* Casts an area of effect nuke of tier#. BLM: -ga, -ga II, -ga III, -ja. (Also works for Curaga's while in Cure mode.)
** EX: //ez boomga 4 <<<< If in "ice" mode, and mode is "t", will cast Blizzaja on your current target.
** Macro usage: /con ez boomga #

boomra #
* Casts an area of effect nuke of tier#. GEO's -ra AOE nukes and WHM's Cura line
** EX: //ez boomga 4 <<<< If in "ice" mode, and mode is "t", will cast Blizzaja on your current target.
** Macro usage: /con ez boomga #