EasyNuke provides universal commands for casting single target and area of effect BLM and GEO nukes, and WHM cures.

Commands:

#### element XXX
* Changes current element mode to XXX.
  * EX: //ez element ice <<<< Sets mode to ice.
    * Macro usage: /con ez element XXX
  * Valid arguments: Fire, Wind, Thunder, Light, Ice, Water, Earth, Dark, Drain, Aspir, Absorb, Cure
    * Cure Mode: Follows standard single/ga/ra pattern and usage
    * Drain and Aspir Mode: Aspir, Aspir II, Aspir III, Drain, Drain II, Drain III
    * Absorb Mode: Absorb-Acc, Absorb-TP, Absorb-Attri, Absorb-STR, Absorb-DEX, Absorb-VIT, Absorb-AGI, Absorb-INT, Absorb-MND, Absorb-CHR
  * EX: //ez element absorb  >>> //ez boom 4 <<<< Casts Absorb-STR
  * Macro usage: /con ez element XXX

#### cycle
* Cycles through element modes in the following left-to-right order: Fire, Wind, Thunder, Light, Ice, Water, Earth, Dark
  * EX: //ez cycle <<<< If you were in Light mode, then you will change to Ice mode.
  * Macro usage: /con ez cycle

#### cycle back
* Same as "cycle", but goes in right-to-left order.
  * EX: //ez cycle back <<<< If you were in Light mode, then you will change to Thunder mode.
  * Macro usage: /con ez cycle back

#### cycle dark
* Cycles through element modes in the following order: Ice, Water, Earth, Dark
  * EX: //ez cycle dark <<<< If you were in Dark mode, then you will change to Ice mode.
  * Macro usage: /con ez cycle dark

#### cycle light
* Cycles through element modes in the following order: Fire, Wind, Thunder, Light
  * EX: //ez cycle light <<<< If you were in Light mode, then you will change to Fire mode.
  * Macro usage: /con ez cycle light

#### cycle XXX
* Cycles between the two elements of a T2 skillchain.
  * Valid commands: Elements included
    * Fusion, Fus: Fire, Light
    * Fragmentation, Frag: Thunder, Wind
    * Distortion, Dist: Ice, Water
    * Gravitation, Grav: Earth, Dark
  * EX: //ez cycle dist <<<< If you were in Ice mode, will change you to Water mode. If you were in any other mode, will change you to Ice mode.
  * Macro usage: /con ez cycle fragmentation

#### target XXX
* Changes targeting mode to #.  This sets what's between the < > brackets used for targeting in macros.
  * EX: //ez target bt <<<< Spells will be cast using <bt>.
    * There are no failsafes for this. Any given argument will be accepted, even if it does not function as a targeting argument.
    * If no argument is given, then will cycle through target modes in the following order: t, bt, stnpc
  * Macro usage: /con ez target #   OR   /con ez target

#### showcurrent / show / current
* Echoes the current elemental and targeting modes in the chat log.
  * EX: //ez showcurrent
  * Macro usage: /con ez show

#### boom XXX
* Casts a single target tierXXX nuke of the current element, and using the current targeting mode.
  * EX: //ez boom 4 <<<< If Element Mode is Fire, and targeting mode is "t", you will cast Fire IV on your current target.
  * EX2: //boom 6 <<<< If Element Mode is Ice, and targeting mode is "bt", you will cast Blizzard VI on the current battle target.
  * Macro usage: /con ez boom #    /OR/    /con boom #

#### boomga XXX
* Casts an area of effect tierXXX nuke of the current element: BLM: -ga, -ga II, -ga III, -ja. (Also works for Curaga's while in Cure mode.)
  * EX: //ez boomga 4 <<<< If Element Mode is Ice, and targeting mode is "t", will cast Blizzaja on your current target.
  * EX2: //boomga 3 <<<< If Element Mode is Ice, and targeting mode is "bt", you will cast Blizzaga III on the current battle target.
  * Macro usage: /con ez boomga #    /OR/    /con boomga #

#### boomra XXX
* Casts an area of effect nuke of tier XXX. GEO's -ra AOE nukes and WHM's Cura line
  * EX: //ez boomra 3 <<<< If Element Mode is Ice, and mode is "bt", will cast Blizzara III on your current battle target.
  * EX2: //boomra 2 <<<< If Element Mode is Cure, and mode is "me", you will cast Cura II on yourself.
  * Macro usage: /con ez boomra #    /OR/    /con boomra #
  
#### boomhelix
* Casts the appropriate SCH Helix spell of tier XXX.
  * EX: //ez boomhelix 2 <<<< If Element Mode is Ice, and target mode is "t", will cast Cryohelix II on your current target.
  * EX2: //boomhelix <<<< If Element Mode is Fire, and target mode is "bt", will cast Pyrohelix on your current battle target.
  * Macro usage: /con ez boomhelix # /OR/ /con boomhelix #
* Also supports a short version //bhelix # or //ez bhelix