return {
    ['Accuracy Bonus'] = {
        name = "Accuracy Bonus",
        spells = { 
            { name = "Dimensional Death", points = 4, cost = 5, id = 589 },
            { name = "Frenetic Rip", points = 4, cost = 3, id = 560 },
            { name = "Disseverment", points = 4, cost = 5, id = 611 },
            { name = "Vanity Dive", points = 4, cost = 2, id = 667 },
            { name = "Nat. Meditation", points = 8, cost = 6, id = 700 },
            { name = "Anvil Lightning", points = 8, cost = 8, id = 721 },
        },
        --tiers = { 8, 16, 24, 32 },
        tiers = { [8] = 10, [16] = 22, [24] = 35, [32] = 48, [40] = 60, [48] = 72 },
        subs = { ['DNC'] = 8, ['DRG'] = 8, ['RNG'] = 16 },
    },
    ['Attack Bonus'] = {
        name = "Attack Bonus",
        spells = { 
            { name = "Battle Dance", points = 4, cost = 3, id = 620 },
            { name = "Uppercut", points = 4, cost = 3, id = 594 },
            { name = "Death Scissors", points = 4, cost = 5, id = 554 },
            { name = "Spinal Cleave", points = 4, cost = 4, id = 540 },
            { name = "Temporal Shift", points = 4, cost = 5, id = 616 },
            { name = "Thermal Pulse", points = 4, cost = 3, id = 675 },
            { name = "Embalming Earth", points = 8, cost = 6, id = 703 },
            { name = "Searing Tempest", points = 8, cost = 8, id = 719 },
        },
        tiers = { [8] = 10, [16] = 22, [24] = 35, [32] = 48, [40] = 60, [48] = 72 },
        subs = { ['WAR'] = 8, ['DRG'] = 8, ['DRK'] = 16 },
    },
    ['Auto Refresh'] = {
        name = "Auto Refresh",
        spells = { 
            { name = "Stinking Gas", points = 1, cost = 2, id = 537 },
            { name = "Frightful Roar", points = 2, cost = 3, id = 561 },
            { name = "Self-Destruct", points = 2, cost = 3, id = 533 },
            { name = "Cold Wave", points = 1, cost = 1, id = 535 },
            { name = "Light of Penance", points = 2, cost = 5, id = 634 },
            { name = "Voracious Trunk", points = 3, cost = 4, id = 576 },
            { name = "Actinic Burst", points = 4, cost = 4, id = 612 },
            { name = "Plasma Charge", points = 4, cost = 5, id = 615 },
            { name = "Winds of Promy.", points = 4, cost = 5, id = 681 },
        },
        tiers = { [8] = 1 },
        subs = { ['PLD'] = 8, ['SMN'] = 8 },
    },
    ['Auto Regen'] = {
        name = "Auto Regen",
        spells = { 
            { name = "Sheep Song", points = 4, cost = 2, id = 584 },
            { name = "Healing Breeze", points = 4, cost = 4, id = 581 },
            { name = "White Wind", points = 4, cost = 5, id = 690 },
        },
        tiers = { [8] = 1, [16] = 2, [24] = 3 },
        tiers = { [8] = 1, [16] = 2, [24] = 3 },
        subs = { ['WHM'] = 8, ['RUN'] = 8 },
    },
    ['Beast Killer'] = {
        name = "Beast Killer",
        spells = { 
            { name = "Wild Oats", points = 4, cost = 3, id = 603 },
            { name = "Sprout Smack", points = 4, cost = 2, id = 597 },
            { name = "Seedspray", points = 4, cost = 4, id = 650 },
            { name = "1000 Needles", points = 4, cost = 5, id = 595 },
            { name = "Nectarous Deluge", points = 8, cost = 6, id = 716 },
        },
        tiers = { [8] = "I" },
        subs = { },
    },
    ['Clear Mind'] = {
        name = "Clear Mind",
        spells = { 
            { name = "Poison Breath", points = 4, cost = 1, id = 536 },
            { name = "Sopoforic", points = 4, cost = 4, id = 598 },
            { name = "Venom Shell", points = 4, cost = 3, id = 513 },
            { name = "Awful Eye", points = 4, cost = 2, id = 606 },
            { name = "Filamented Hold", points = 4, cost = 3, id = 548 },
            { name = "Maelstrom", points = 4, cost = 5, id = 515 },
            { name = "Feather Tickle", points = 4, cost = 3, id = 573 },
            { name = "Corrosive Ooze", points = 4, cost = 4, id = 651 },
            { name = "Sandspray", points = 4, cost = 2, id = 621 },
            { name = "Warm-Up", points = 4, cost = 4, id = 636 },
            { name = "Lowing", points = 4, cost = 2, id = 588 },
            { name = "Mind Blast", points = 4, cost = 4, id = 644 },
        },
        tiers = { [8] = 3, [16] = 6, [24] = 9, [32] = 12, [40] = 15 },
        subs = { ['SMN'] = 24, ['BLM'] = 24, ['SCH'] = 16, ['GEO'] = 16, ['RDM'] = 8, },
    },
    ['Conserve MP'] = {
        name = "Conserve MP",
        spells = { 
            { name = "Chaotic Eye", points = 4, cost = 2, id = 582 },
            { name = "Zephyr Mantle", points = 4, cost = 2, id = 647 },
            { name = "Frost Breath", points = 4, cost = 3, id = 608 },
            { name = "Firespit", points = 4, cost = 5, id = 637 },
            { name = "Water Bomb", points = 4, cost = 2, id = 687 },
            { name = "Retinal Glare", points = 8, cost = 6, id = 707 },
        },
        tiers = { [8] = 25, [16] = 28, [24] = 31, [32] = 34, [40] = 37 },
        subs = { ['SCH'] = 8, ['BLM'] = 16, ['GEO'] = 24, },
    },
    ['Counter'] = {
        name = "Counter",
        spells = { 
            { name = "Enervation", points = 4, cost = 5, id = 633 },
            { name = "Asuran Claws", points = 4, cost = 2, id = 653 },
            { name = "Dark Orb", points = 4, cost = 3, id = 689 },
            { name = "O. Counterstance", points = 4, cost = 5, id = 696 },
        },
        tiers = { [8] = 10, [16] = 12 },
        subs = { ['MNK'] = 8 },
    },
    ['Defense Bonus'] = {
        name = "Defense Bonus",
        spells = { 
            { name = "Grand Slam", points = 4, cost = 2, id = 622 },
            { name = "Terror Touch", points = 4, cost = 3, id = 539 },
            { name = "Saline Coat", points = 4, cost = 3, id = 614 },
            { name = "Vertical Cleave", points = 4, cost = 3, id = 617 },
            { name = "Atra. Libations", points = 8, cost = 6, id = 718 },
            { name = "Entomb", points = 8, cost = 8, id = 722 },
        },
        tiers = { [8] = 10, [16] = 22, [24] = 35, [32] = 48, [40] = 60, [48] = 72 },
        subs = { ['WAR'] = 8, ['PLD'] = 16 },
    },
    ['Double/Triple Attack'] = {
        name = "Double/Triple Attack",
        spells = { 
            { name = "Acrid Stream", points = 4, cost = 3, id = 656 },
            { name = "Demoralizing Roar", points = 4, cost = 4, id = 659 },
            { name = "Empty Thrash", points = 4, cost = 3, id = 677 },
            { name = "Heavy Strike", points = 4, cost = 2, id = 688 },
            { name = "Thrashing Assault", points = 8, cost = 7, id = 709 },
        },
        tiers = { [8] = "DA", [16] = "TA" },
        subs = { ['WAR'] = 8, ['THF'] = 16  },
    },
    ['Dual Wield'] = {
        name = "Dual Wield",
        spells = { 
            { name = "Animating Wail", points = 4, cost = 5, id = 661 },
            { name = "Blazing Bound", points = 4, cost = 3, id = 657 },
            { name = "Quad. Continuum", points = 4, cost = 4, id = 673 },
            { name = "Delta Thrust", points = 4, cost = 2, id = 682 },
            { name = "Mortal Ray", points = 4, cost = 4, id = 686 },
            { name = "Barbed Crescent", points = 4, cost = 2, id = 699 },
            { name = "Molting Plumage", points = 8, cost = 6, id = 715 },
        },
        tiers = { [8] = 10, [16] = 15, [24] = 25, [32] = 30, [40] = 35 },
        subs = { ['NIN'] = 24, ['DNC'] = 16  },
    },
    ['Evasion Bonus'] = {
        name = "Evasion Bonus",
        spells = { 
            { name = "Screwdriver", points = 4, cost = 3, id = 519 },
            { name = "Hysteric Barrage", points = 4, cost = 5, id = 641 },
            { name = "Occultation", points = 4, cost = 3, id = 679 },
            { name = "Tem. Upheaval", points = 8, cost = 6, id = 701 },
            { name = "Silent Storm", points = 8, cost = 8, id = 727 },
        },
        tiers = { [8] = 10, [16] = 22, [24] = 35, [32] = 48, [40] = 60 },
        subs = { ['THF'] = 16, ['DNC'] = 16, ['PUP'] = 8  },
    },
    ['Fast Cast'] = {
        name = "Fast Cast",
        spells = { 
            { name = "Bad Breath", points = 4, cost = 5, id = 604 },
            { name = "Sub-Zero Smash", points = 4, cost = 4, id = 654 },
            { name = "Auroral Drape", points = 4, cost = 4, id = 671 },
            { name = "Wind Breath", points = 4, cost = 2, id = 698 },
            { name = "Erratic Flutter", points = 8, cost = 6, id = 710 },
        },
        tiers = { [8] = 5, [16] = 10, [24] = 15, [32] = 20, [40] = 25 },
        subs = { ['RDM'] = 24 },
    },
    ['Gilfinder/TH'] = {
        name = "Gilfinder/TH",
        spells = { 
            { name = "Charged Whisker", points = 6, cost = 5, id = 680 },
            { name = "Evryone. Grudge", points = 6, cost = 4, id = 683 },
            { name = "Amorphic Spikes", points = 6, cost = 4, id = 697 },
        },
        tiers = { [8] = "GF", [16] = "TH" },
        subs = { ['THF'] = 16 },
    },
    ['Lizard Killer'] = {
        name = "Lizard Killer",
        spells = { 
            { name = "Foot Kick", points = 4, cost = 2, id = 577 },
            { name = "Claw Cyclone", points = 4, cost = 2, id = 587 },
            { name = "Ram Charge", points = 4, cost = 4, id = 585 },
            { name = "Sweeping Gouge", points = 8, cost = 6, id = 717 },
        },
        tiers = { [8] = "I" },
        subs = { ['BST'] = 8 },
    },
    ['Magic Attack Bonus'] = {
        name = "Magic Attack Bonus",
        spells = { 
            { name = "Cursed Sphere", points = 4, cost = 2, id = 544 },
            { name = "Sound Blast", points = 4, cost = 1, id = 572 },
            { name = "Eyes On Me", points = 4, cost = 4, id = 557 },
            { name = "Memento Mori", points = 4, cost = 4, id = 538 },
            { name = "Heat Breath", points = 4, cost = 4, id = 591 },
            { name = "Reactor Cool", points = 4, cost = 5, id = 613 },
            { name = "Magic Hammer", points = 4, cost = 4, id = 646 },
            { name = "Dream Flower", points = 4, cost = 3, id = 678 },
            { name = "Subduction", points = 8, cost = 6, id = 708 },
            { name = "Spectral Floe", points = 8, cost = 8, id = 720 },
        },
        tiers = { [8] = 20, [16] = 24, [24] = 28, [32] = 32, [40] = 36, [48] = 40 },
        subs = { ['BLM'] = 16, ['RDM'] = 16  },
    },
    ['Magic Burst Bonus'] = {
        name = "Magic Burst Bonus",
        spells = { 
            { name = "Leafstorm", points = 6, cost = 4, id = 663 },
            { name = "Cimicine Discharge", points = 6, cost = 3, id = 660 },
            { name = "Reaving Wind", points = 6, cost = 4, id = 684 },
            { name = "Rail Cannon", points = 8, cost = 6, id = 712 },
        },
        tiers = { [8] = 5, [16] = 7, [24] = 9, [32] = 11, [40] = 13 },
        subs = { ['BLM'] = 8 },
    },
    ['Magic Defense Bonus'] = {
        name = "Magic Defense Bonus",
        spells = { 
            { name = "Magnetite Cloud", points = 4, cost = 3, id = 555 },
            { name = "Ice Break", points = 4, cost = 3, id = 531 },
            { name = "Osmosis", points = 4, cost = 5, id = 672 },
            { name = "Rending Deluge", points = 8, cost = 6, id = 702 },
            { name = "Scouring Spate", points = 8, cost = 8, id = 726 },
        },
        tiers = { [8] = 10, [16] = 12, [24] = 14, [32] = 16, [40] = 18 },
        subs = { ['RUN'] = 16, ['WHM'] = 16, ['RDM'] = 16  },
    },
    ['Max HP Boost'] = {
        name = "Max HP Boost",
        spells = { 
            { name = "Flying Hip Press", points = 4, cost = 3, id = 629 },
            { name = "Body Slam", points = 4, cost = 4, id = 564 },
            { name = "Frypan", points = 4, cost = 3, id = 628 },
            { name = "Barrier Tusk", points = 4, cost = 3, id = 685 },
            { name = "Thunder Breath", points = 4, cost = 4, id = 695 },
            { name = "Glutinous Dart", points = 4, cost = 2, id = 706 },
            { name = "Restoral", points = 8, cost = 7, id = 711 },
        },
        tiers = { [8] = 30, [16] = 60, [24] = 120, [32] = 180, [40] = 240, [48] = 280 },
        subs = { ['RUN'] = 16, ['MNK'] = 16, ['NIN'] = 16, ['WAR'] = 8, ['PLD'] = 8  },
    },
    ['Max MP Boost'] = {
        name = "Max MP Boost",
        spells = { 
            { name = "Metallic Body", points = 4, cost = 1, id = 517 },
            { name = "Mysterious Light", points = 4, cost = 4, id = 534 },
            { name = "Hecatomb Wave", points = 4, cost = 3, id = 563 },
            { name = "Magic Barrier", points = 4, cost = 3, id = 668 },
            { name = "Vapor Spray", points = 4, cost = 3, id = 694 },
        },
        tiers = { [8] = 10, [16] = 20, [24] = 40, [32] = 60 },
        subs = { ['SMN'] = 16, ['GEO'] = 8, ['SCH'] = 8 },
    },
    ['Plantoid Killer'] = {
        name = "Plantoid Killer",
        spells = { 
            { name = "Power Attack", points = 4, cost = 1, id = 551 },
            { name = "Mandibular Bite", points = 4, cost = 2, id = 543 },
            { name = "Spiral Spin", points = 4, cost = 3, id = 652 },
        },
        tiers = { [8] = "I" },
        subs = { },
    },
    ['Rapid Shot'] = {
        name = "Rapid Shot",
        spells = { 
            { name = "Feather Storm", points = 4, cost = 3, id = 638 },
            { name = "Jet Stream", points = 4, cost = 4, id = 569 },
            { name = "Hydro Shot", points = 4, cost = 3, id = 631 },
        },
        tiers = { [8] = "I" },
        subs = { ['RNG'] = 8, ['COR'] = 8 },
    },
    ['Resist Silence'] = {
        name = "Resist Silence",
        spells = { 
            { name = "Foul Waters", points = 8, cost = 3, id = 705 },
        },
        tiers = { [8] = "I" },
        subs = { ['BRD'] = 8, ['SCH'] = 8 },
    },
    ['Resist Gravity'] = {
        name = "Resist Gravity",
        spells = { 
            { name = "Feather Barrier", points = 4, cost = 2, id = 574 },
            { name = "Regurgitation", points = 4, cost = 1, id = 648 },
        },
        tiers = { [8] = "I", [16] = "II", [24] = "III" },
        subs = { ['THF'] = 16 },
    },
    ['Resist Sleep'] = {
        name = "Resist Sleep",
        spells = { 
            { name = "Pollen", points = 4, cost = 1, id = 549 },
            { name = "Wild Carrot", points = 4, cost = 3, id = 578 },
            { name = "Magic Fruit", points = 4, cost = 3, id = 593 },
            { name = "Yawn", points = 4, cost = 3, id = 576 },
            { name = "Exuviation", points = 4, cost = 4, id = 645 },
        },
        tiers = { [8] = "I", [16] = "II", [24] = "III", [32] = "IV" },
        subs = { ['PLD'] = 16 },
    },
    ['Skillchain Bonus'] = {
        name = "Skillchain Bonus",
        spells = { 
            { name = "Goblin Rush", points = 6, cost = 3, id = 666 },
            { name = "Benthic Typhoon", points = 6, cost = 4, id = 670 },
            { name = "Quadrastrike", points = 6, cost = 5, id = 693 },
            { name = "Paralyzing Triad", points = 8, cost = 6, id = 704 },
        },
        tiers = { [8] = 8, [16] = 12, [24] = 16, [32] = 20, [40] = 23 },
        subs = { ['DNC'] = 8 },
    },
    ['Store TP'] = {
        name = "Store TP",
        spells = { 
            { name = "Sickle Slash", points = 4, cost = 4, id = 545 },
            { name = "Tail Slap", points = 4, cost = 4, id = 640 },
            { name = "Fantod", points = 4, cost = 1, id = 674 },
            { name = "Sudden Lunge", points = 4, cost = 4, id = 692 },
            { name = "Diffusion Ray", points = 8, cost = 6, id = 713 },
        },
        tiers = { [8] = 10, [16] = 15, [24] = 20, [32] = 25, [40] = 30 },
        subs = { ['SAM'] = 16 },
    },
    ['Undead Killer'] = {
        name = "Undead Killer",
        spells = { 
            { name = "Bludgeon", points = 4, cost = 2, id = 529 },
            { name = "Smite of Rage", points = 4, cost = 3, id = 527 },
        },
        tiers = { [8] = "I" },
        subs = { ['PLD'] = 8 },
    },
    ['Zanshin'] = {
        name = "Zanshin",
        spells = { 
            { name = "Final Sting", points = 4, cost = 1, id = 665 },
            { name = "Whirl of Rage", points = 4, cost = 2, id = 669 },
        },
        tiers = { [8] = 15, [16] = 25, [24] = 35, },
        subs = { ['SAM'] = 16 },
    },
    ['Critical Attack Bonus'] = {
        name = "Critical Attack Bonus",
        spells = { 
            { name = "Sinker Drill", points = 8, cost = 6, id = 714 },
        },
        tiers = { [8] = 5, [16] = 8, [24] = 11 },
        subs = { },
    },
    ['Inquartata'] = {
        name = "Inquartata",
        spells = { 
            { name = "Saurian Slide", points = 8, cost = 7, id = 723 },
        },
        tiers = { [8] = 5, [16] = 7, [24] = 9 },
        subs = { ['RUN'] = 24 },
    },
    ['Tenacity'] = {
        name = "Tenacity",
        spells = { 
            { name = "Palling Salvo", points = 8, cost = 7, id = 724 },
        },
        tiers = { [8] = 5, [16] = 7, [24] = 9 },
        subs = { ['RUN'] = 24 },
    },
    ['Magic Accuracy Bonus'] = {
        name = "Magic Accuracy Bonus",
        spells = { 
            { name = "Tenebral Crush", points = 8, cost = 8, id = 728 },
        },
        tiers = {  [8] = "I", [16] = "II", [24] = "III" },
        subs = { },
    },
    ['Magic Evasion Bonus'] = {
        name = "Magic Evasion Bonus",
        spells = { 
            { name = "Blinding Fulgor", points = 8, cost = 8, id = 725 },
        },
        tiers = {  [8] = "I", [16] = "II", [24] = "III" },
        subs = { },
    },
    ['Resist Slow'] = {
        name = "Resist Slow",
        spells = { 
            { name = "Refueling", points = 4, cost = 4, id = 530 },
        },
        tiers = { [8] = "I" },
        subs = { ['PUP'] = 16, ['BST'] = 16, ['SMN'] = 16, ['DNC'] = 8, },
    },
}
--Copyright © 2015, Anissa
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of bluGuide nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL ANISSA BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
