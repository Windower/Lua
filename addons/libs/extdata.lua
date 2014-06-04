-- Extdata lib first pass

require 'strings'
res = require 'resources'
require 'pack'

local extdata = {}

potencies = {
        zeros = {[0]=0,[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0,[7]=0,[8]=0,[9]=0,[10]=0,[11]=0,[12]=0,[13]=0,[14]=0,[15]=0},
        family = {
            attack = {[0]=4,[1]=5,[2]=6,[3]=7,[4]=8,[5]=9,[6]=10,[7]=12,[8]=12,[9]=12,[10]=12,[11]=12,[12]=12,[13]=12,[14]=12,[15]=12}, -- Atk and RAtk
            defense = {[0]=2,[1]=4,[2]=6,[3]=8,[4]=10,[5]=12,[6]=15,[7]=18,[8]=18,[9]=18,[10]=18,[11]=18,[12]=18,[13]=18,[14]=18,[15]=18},
            accuracy = {[0]=2,[1]=3,[2]=4,[3]=5,[4]=7,[5]=9,[6]=12,[7]=15,[8]=15,[9]=15,[10]=15,[11]=15,[12]=15,[13]=15,[14]=15,[15]=15}, -- Acc, RAcc, and MEva
            evasion = {[0]=3,[1]=4,[2]=5,[3]=6,[4]=8,[5]=10,[6]=13,[7]=16,[8]=16,[9]=16,[10]=16,[11]=16,[12]=16,[13]=16,[14]=16,[15]=16},
            magic_bonus = {[0]=1,[1]=1,[2]=1,[3]=2,[4]=2,[5]=3,[6]=4,[7]=6,[8]=6,[9]=6,[10]=6,[11]=6,[12]=6,[13]=6,[14]=6,[15]=6}, -- MAB and MDB
            magic_accuracy = {[0]=2,[1]=2,[2]=3,[3]=4,[4]=5,[5]=6,[6]=7,[7]=9,[8]=9,[9]=9,[10]=9,[11]=9,[12]=9,[13]=9,[14]=9,[15]=9},
        },
        sp_recast = {[0]=-1,[1]=-1,[2]=-1,[3]=-2,[4]=-2,[5]=-3,[6]=-3,[7]=-4,[8]=-4,[9]=-4,[10]=-4,[11]=-4,[12]=-4,[13]=-4,[14]=-4,[15]=-4},
    }


augment_values = {
    [1] = {
        [0x000] = {{stat="none",offset=0}},
        [0x001] = {{stat="HP", offset=1}},
        [0x002] = {{stat="HP", offset=33}},
        [0x003] = {{stat="HP", offset=65}},
        [0x004] = {{stat="HP", offset=97}},
        [0x005] = {{stat="HP", offset=1,multiplier=-1}},
        [0x006] = {{stat="HP", offset=33,multiplier=-1}},
        [0x007] = {{stat="HP", offset=65,multiplier=-1}},
        [0x008] = {{stat="HP", offset=97,multiplier=-1}},
        [0x009] = {{stat="MP", offset=1}},
        [0x00A] = {{stat="MP", offset=33}},
        [0x00B] = {{stat="MP", offset=65}},
        [0x00C] = {{stat="MP", offset=97}},
        [0x00D] = {{stat="MP", offset=1,multiplier=-1}},
        [0x00E] = {{stat="MP", offset=33,multiplier=-1}},
        [0x00F] = {{stat="MP", offset=65,multiplier=-1}},
        [0x010] = {{stat="MP", offset=97,multiplier=-1}},
        [0x011] = {{stat="HP", offset=1}, {stat="MP", offset=1}},
        [0x012] = {{stat="HP", offset=33}, {stat="MP", offset=33}},
        [0x013] = {{stat="HP", offset=1}, {stat="MP", offset=1,multiplier=-1}},
        [0x014] = {{stat="HP", offset=33}, {stat="MP", offset=33,multiplier=-1}},
        [0x015] = {{stat="HP", offset=1,multiplier=-1}, {stat="MP", offset=1}},
        [0x016] = {{stat="HP", offset=33,multiplier=-1}, {stat="MP", offset=33}},
        [0x017] = {{stat="Accuracy", offset=1}},
        [0x018] = {{stat="Accuracy", offset=1,multiplier=-1}},
        [0x019] = {{stat="Attack", offset=1}},
        [0x01A] = {{stat="Attack", offset=1,multiplier=-1}},
        [0x01B] = {{stat="Rng.Acc.", offset=1}},
        [0x01C] = {{stat="Rng.Acc.", offset=1,multiplier=-1}},
        [0x01D] = {{stat="Rng.Atk.", offset=1}},
        [0x01E] = {{stat="Rng.Atk.", offset=1,multiplier=-1}},
        [0x01F] = {{stat="Evasion", offset=1}},
        [0x020] = {{stat="Evasion", offset=1,multiplier=-1}},
        [0x021] = {{stat="DEF", offset=1}},
        [0x022] = {{stat="DEF", offset=1,multiplier=-1}},
        [0x023] = {{stat="Mag. Acc.", offset=1}},
        [0x024] = {{stat="Mag. Acc.", offset=1,multiplier=-1}},
        [0x025] = {{stat="Mag. Evasion", offset=1}},
        [0x026] = {{stat="Mag. Evasion", offset=1,multiplier=-1}},
        [0x027] = {{stat="Enmity", offset=1}},
        [0x028] = {{stat="Enmity", offset=1,multiplier=-1}},
        [0x029] = {{stat="Crit.hit rate", offset=1}},
        [0x02A] = {{stat="Enemy crit. hit rate ", offset=1,multiplier=-1}},
        [0x02B] = {{stat='"Charm"', offset=1}},
        [0x02C] = {{stat='"Store TP"', offset=1}, {stat='"Subtle Blow"', offset=1}},
        [0x02D] = {{stat="DMG:", offset=1}},
        [0x02E] = {{stat="DMG:", offset=1,multiplier=-1}},
        [0x02F] = {{stat="Delay:", offset=1,percent=true}},
        [0x030] = {{stat="Delay:", offset=1,multiplier=-1,percent=true}},
        [0x031] = {{stat="Haste", offset=1}},
        [0x032] = {{stat='"Slow"', offset=1}},
        [0x033] = {{stat="HP recovered while healing ", offset=1}},
        [0x034] = {{stat="MP recovered while healing ", offset=1}},
        [0x035] = {{stat="Spell interruption rate down ", offset=1,multiplier=-1,percent=true}},
        [0x036] = {{stat="Phys. dmg. taken ", offset=1,multiplier=-1,percent=true}},
        [0x037] = {{stat="Magic dmg. taken ", offset=1,multiplier=-1,percent=true}},
        [0x038] = {{stat="Breath dmg. taken ", offset=1,multiplier=-1,percent=true}},
        [0x039] = {{stat="Magic crit. hit rate ", offset=1}},
        [0x03A] = {{stat='"Mag.Def.Bns."', offset=1,multiplier=-1}},
        [0x03B] = {{stat='Latent effect: "Regain"', offset=1}},
        [0x03C] = {{stat='Latent effect: "Refresh"', offset=1}},
        [0x03D] = {{stat="Occ. inc. resist. to stat. ailments ", offset=1}},

        
        -- Need to figure out how to handle this section. The Pet: prefix is only used once despite how many augments are used.
        [0x060] = {{stat="Pet: Accuracy", offset=1}, {stat="Pet: Rng. Acc.", offset=1}}, -- Pet: Accuracy+5 Rng.Acc.+5
        [0x061] = {{stat="Pet: Attack", offset=1}, {stat="Pet: Rng.Atk.", offset=1}}, -- Pet: Attack +5 Rng.Atk.+5
        [0x062] = {{stat="Pet: Evasion", offset=1}},
        [0x063] = {{stat="Pet: DEF", offset=1}},
        [0x064] = {{stat="Pet: Mag. Acc.", offset=1}},
        [0x065] = {{stat='Pet: "Mag.Atk.Bns."', offset=1}},
        [0x066] = {{stat="Pet: Crit.hit rate ", offset=1}},
        [0x067] = {{stat="Pet: Enemy crit. hit rate ", offset=1,multiplier=-1}},
        [0x068] = {{stat="Pet: Enmity", offset=1}},
        [0x069] = {{stat="Pet: Enmity", offset=1,multiplier=-1}},
        [0x06A] = {{stat="Pet: Accuracy", offset=1}, {stat="Pet: Rng. Acc.", offset=1}},
        [0x06B] = {{stat="Pet: Attack", offset=1}, {stat="Pet: Rng.Atk.", offset=1}},
        [0x06C] = {{stat="Pet: Mag. Acc.", offset=1}, {stat='Pet: "Mag.Atk.Bns."', offset=1}},
        [0x06D] = {{stat='Pet: "Dbl.Atk."', offset=1}, {stat="Pet: Crit.hit rate ", offset=1}},
        [0x06E] = {{stat='Pet: "Regen"', offset=1}},
        [0x06F] = {{stat="Pet: Haste", offset=1}},
        [0x070] = {{stat="Pet: Damage taken ", offset=1,multiplier=-1,percent=true}},
        [0x071] = {{stat="Pet: Rng.Acc.", offset=1}},
        [0x072] = {{stat="Pet: Rng.Atk.", offset=1}},
        [0x073] = {{stat='Pet: "Store TP"', offset=1}},
        [0x074] = {{stat='Pet: "Subtle Blow"', offset=1}},
        [0x075] = {{stat="Pet: Mag. Evasion", offset=1}},
        [0x076] = {{stat="Pet: Phys. dmg. taken ", offset=1,multiplier=-1,percent=true}},
        [0x077] = {{stat='Pet: "Mag.Def.Bns."', offset=1}},
        [0x078] = {{stat='Avatar: "Mag.Atk.Bns."', offset=1}},

        [0x080] = {{stat="Pet:",offset = 0}},
        --[0x081: Accuracy +1 Ranged Acc. +0 | value + 1
        --[0x082: Attack +1 Ranged Atk. +0 | value + 1
        --[0x083: Mag. Acc. +1 "Mag.Atk.Bns."+0 | value + 1
        --[0x084: "Double Atk."+1 "Crit. hit +0 | value + 1

        --0x080~0x084 are pet augs with a pair of stats with 0x080 being just "Pet:"
        --the second stat starts at 0. the previous pet augs add +2. the first previous non pet aug adds +2. any other non pet aug will add +1.
        --any aug >= 0x032 will be added after the pet stack and will not be counted to increase the 2nd pet's aug stat and will be prolly assigned to the pet.
        --https://gist.github.com/giulianoriccio/6df4fbd1f2a166fed041/raw/4e1d1103e7fe0e69d25f8264387506b5e38296a7/augs
        
        -- Byrth's note: These augments are just weird and I have no evidence that SE actually uses them.
        -- The first argument of the augment has its potency calculated normally (using the offset). The second argument
        -- has its potency calculated using an offset equal to 2*its position in the augment list (re-ordered from biggest to lowest IDs)
        -- So having 0x80 -> 0x81 -> 0x82 results in the same augments as 0x80 -> 0x82 -> 0x81
        -- In that case, Acc/Atk would be determined by the normal offset, but Racc would be +2 and RAtk would be +4

        [0x085] = {{stat='"Mag.Atk.Bns."', offset=1}},
        [0x086] = {{stat='"Mag.Def.Bns."', offset=1}},

        [0x087] = {{stat="Avtar:",offset=0}},
        [0x089] = {{stat='"Regen"', offset=1}},
        [0x08A] = {{stat='"Refresh"', offset=1}},
        [0x08B] = {{stat='"Rapid Shot"', offset=1}},
        [0x08C] = {{stat='"Fast Cast"', offset=1}},
        [0x08D] = {{stat='"Conserve MP"', offset=1}},
        [0x08E] = {{stat='"Store TP"', offset=1}},
        [0x08F] = {{stat='"Dbl.Atk."', offset=1}},
        [0x090] = {{stat='"Triple Atk."', offset=1}},
        [0x091] = {{stat='"Counter"', offset=1}},
        [0x092] = {{stat='"Dual Wield"', offset=1}},
        [0x093] = {{stat='"Treasure Hunter"', offset=1}},
        [0x094] = {{stat='"Gilfinder"', offset=1}},
        [0x099] = {{stat='"Shield Mastery"', offset=1}},
        [0x0B0] = {{stat='"Resist Sleep"', offset=1}},
        [0x0B1] = {{stat='"Resist Poison"', offset=1}},
        [0x0B2] = {{stat='"Resist Paralyze"', offset=1}},
        [0x0B3] = {{stat='"Resist Blind"', offset=1}},
        [0x0B4] = {{stat='"Resist Silence"', offset=1}},
        [0x0B5] = {{stat='"Resist Petrify"', offset=1}},
        [0x0B6] = {{stat='"Resist Virus"', offset=1}},
        [0x0B7] = {{stat='"Resist Curse"', offset=1}},
        [0x0B8] = {{stat='"Resist Stun"', offset=1}},
        [0x0B9] = {{stat='"Resist Bind"', offset=1}},
        [0x0BA] = {{stat='"Resist Gravity"', offset=1}},
        [0x0BB] = {{stat='"Resist Slow"', offset=1}},
        [0x0BC] = {{stat='"Resist Charm"', offset=1}},
        [0x0C2] = {{stat='"Kick Attacks"', offset=1}},
        [0x0C3] = {{stat='"Subtle Blow"', offset=1}},

        [0x0C6] = {{stat='"Zanshin"', offset=1}},

        [0x0D3] = {{stat='"Snapshot"', offset=1}},
        [0x0D4] = {{stat='"Recycle"', offset=1}},

        [0x0D7] = {{stat='"Ninja tool expertise"', offset=1}},

        [0x101] = {{stat="Hand-to-Hand skill ", offset=1}},
        [0x102] = {{stat="Dagger skill ", offset=1}},
        [0x103] = {{stat="Sword skill ", offset=1}},
        [0x104] = {{stat="Great Sword skill ", offset=1}},
        [0x105] = {{stat="Axe skill ", offset=1}},
        [0x106] = {{stat="Great Axe skill ", offset=1}},
        [0x107] = {{stat="Scythe skill ", offset=1}},
        [0x108] = {{stat="Polearm skill ", offset=1}},
        [0x109] = {{stat="Katana skill ", offset=1}},
        [0x10A] = {{stat="Great Katana skill ", offset=1}},
        [0x10B] = {{stat="Club skill ", offset=1}},
        [0x10C] = {{stat="Staff skill ", offset=1}},

        [0x116] = {{stat="Melee skill ", offset=1}}, -- Automaton
        [0x117] = {{stat="Ranged skill ", offset=1}}, -- Automaton
        [0x118] = {{stat="Magic skill ", offset=1}}, -- Automaton
        [0x119] = {{stat="Archery skill ", offset=1}},
        [0x11A] = {{stat="Marksmanship skill ", offset=1}},
        [0x11B] = {{stat="Throwing skill ", offset=1}},

        [0x11E] = {{stat="Shield skill ", offset=1}},

        [0x120] = {{stat="Divine magic skill ", offset=1}},
        [0x121] = {{stat="Healing magic skill ", offset=1}},
        [0x122] = {{stat="Enha.mag. skill ", offset=1}},
        [0x123] = {{stat="Enfb.mag. skill ", offset=1}},
        [0x124] = {{stat="Elem. magic skill ", offset=1}},
        [0x125] = {{stat="Dark magic skill ", offset=1}},
        [0x126] = {{stat="Summoning magic skill ", offset=1}},
        [0x127] = {{stat="Ninjutsu skill ", offset=1}},
        [0x128] = {{stat="Singing skill ", offset=1}},
        [0x129] = {{stat="String instrument skill ", offset=1}},
        [0x12A] = {{stat="Wind instrument skill ", offset=1}},
        [0x12B] = {{stat="Blue Magic skill ", offset=1}},
        [0x12C] = {{stat="Geomancy Skill ", offset=1}},
        [0x12D] = {{stat="Handbell Skill ", offset=1}},

        [0x140] = {{stat='"Blood Pact" ability delay ', offset=1,multiplier=-1}},
        [0x141] = {{stat='"Avatar perpetuation cost" ', offset=1,multiplier=-1}},
        [0x142] = {{stat="Song spellcasting time ", offset=1,multiplier=-1,percent=true}},
        [0x143] = {{stat='"Cure" spellcasting time ', offset=1,multiplier=-1,percent=true}},
        [0x144] = {{stat='"Call Beast" ability delay ', offset=1,multiplier=-1}},
        [0x145] = {{stat='"Quick Draw" ability delay ', offset=1,multiplier=-1}},
        [0x146] = {{stat="Weapon Skill Acc.", offset=1}},
        [0x147] = {{stat="Weapon skill damage ", offset=1,percent=true}},
        [0x148] = {{stat="Crit. hit damage ", offset=1,percent=true}},
        [0x149] = {{stat='"Cure" potency ', offset=1,percent=true}},
        [0x14A] = {{stat='"Waltz" potency ', offset=1,percent=true}},
        [0x14B] = {{stat='"Waltz" ability delay ', offset=1,multiplier=-1}},
        [0x14C] = {{stat="Sklchn.dmg.", offset=1,percent=true}},
        [0x14D] = {{stat='"Conserve TP"', offset=1}},
        [0x14E] = {{stat="Magic burst mdg.", offset=1,percent=true}},
        [0x14F] = {{stat="Mag. crit. hit dmg. ", offset=1,percent=true}},
        [0x150] = {{stat='"Sic" and "Ready" ability delay ', offset=1,multiplier=-1}},
        [0x151] = {{stat="Song recast delay ", offset=1,multiplier=-1}},
        [0x152] = {{stat='"Barrage"', offset=1}},
        [0x153] = {{stat='"Elemental Siphon"', offset=1, multiplier=5}},
        [0x154] = {{stat='"Phantom Roll" ability delay ', offset=1,multiplier=-1}},
        [0x155] = {{stat='"Repair" potency ', offset=1,percent=true}},
        [0x156] = {{stat='"Waltz" TP cost ', offset=1,multiplier=-1}},

        [0x15E] = {{stat="Occ. maximizes magic accuracy ", offset=1,percent=true}},
        [0x15F] = {{stat="Occ. quickens spellcasting ", offset=1,percent=true}},
        [0x160] = {{stat="Occ. grants dmg. bonus based on TP ", offset=1,percent=true}},
        [0x161] = {{stat="TP Bonus ", offset=1, multiplier=5}},
        -- Empties are Numbered up to 0x17F. Their stat is their index + 1
        [0x200] = {{stat="STR", offset=1}},
        [0x201] = {{stat="DEX", offset=1}},
        [0x202] = {{stat="VIT", offset=1}},
        [0x203] = {{stat="AGI", offset=1}},
        [0x204] = {{stat="INT", offset=1}},
        [0x205] = {{stat="MND", offset=1}},
        [0x206] = {{stat="CHR", offset=1}},
        [0x207] = {{stat="STR", offset=1,multiplier=-1}},
        [0x208] = {{stat="DEX", offset=1,multiplier=-1}},
        [0x209] = {{stat="VIT", offset=1,multiplier=-1}},
        [0x20A] = {{stat="AGI", offset=1,multiplier=-1}},
        [0x20B] = {{stat="INT", offset=1,multiplier=-1}},
        [0x20C] = {{stat="MND", offset=1,multiplier=-1}},
        [0x20D] = {{stat="CHR", offset=1,multiplier=-1}},
        
        -- The below values aren't really right
        -- They need to be "Ceiling'd"
        [0x20E] = {{stat="STR", offset=1}, {stat="DEX", offset=1, multiplier=-0.5}, {stat="VIT", offset=1, multiplier=-0.5}},
        [0x20F] = {{stat="STR", offset=1}, {stat="DEX", offset=1, multiplier=-0.5}, {stat="AGI", offset=1, multiplier=-0.5}},
        [0x210] = {{stat="STR", offset=1}, {stat="VIT", offset=1, multiplier=-0.5}, {stat="AGI", offset=1, multiplier=-0.5}},
        [0x211] = {{stat="STR", offset=1, multiplier=-0.5}, {stat="DEX", offset=1}, {stat="VIT", offset=1, multiplier=-0.5}},
        [0x212] = {{stat="STR", offset=1, multiplier=-0.5}, {stat="DEX", offset=1}, {stat="AGI", offset=1, multiplier=-0.5}},
        [0x213] = {{stat="DEX", offset=1}, {stat="VIT", offset=1, multiplier=-0.5}, {stat="AGI", offset=1, multiplier=-0.5}},
        [0x214] = {{stat="STR", offset=1, multiplier=-0.5}, {stat="DEX", offset=1, multiplier=-0.5}, {stat="VIT", offset=1}},
        [0x215] = {{stat="STR", offset=1, multiplier=-0.5}, {stat="VIT", offset=1}, {stat="AGI", offset=1, multiplier=-0.5}},
        [0x216] = {{stat="DEX", offset=1, multiplier=-0.5}, {stat="VIT", offset=1}, {stat="AGI", offset=1, multiplier=-0.5}},
        [0x217] = {{stat="STR", offset=1, multiplier=-0.5}, {stat="DEX", offset=1, multiplier=-0.5}, {stat="AGI", offset=1}},
        [0x218] = {{stat="STR", offset=1, multiplier=-0.5}, {stat="VIT", offset=1, multiplier=-0.5}, {stat="AGI", offset=1}},
        [0x219] = {{stat="DEX", offset=1, multiplier=-0.5}, {stat="VIT", offset=1, multiplier=-0.5}, {stat="AGI", offset=1}},
        [0x21A] = {{stat="AGI", offset=1}, {stat="INT", offset=1, multiplier=-0.5}, {stat="MND", offset=1, multiplier=-0.5}},
        [0x21B] = {{stat="AGI", offset=1}, {stat="INT", offset=1, multiplier=-0.5}, {stat="CHR", offset=1, multiplier=-0.5}},
        [0x21C] = {{stat="AGI", offset=1}, {stat="MND", offset=1, multiplier=-0.5}, {stat="CHR", offset=1, multiplier=-0.5}},
        [0x21D] = {{stat="AGI", offset=1, multiplier=-0.5}, {stat="INT", offset=1}, {stat="MND", offset=1, multiplier=-0.5}},
        [0x21E] = {{stat="AGI", offset=1, multiplier=-0.5}, {stat="INT", offset=1}, {stat="CHR", offset=1, multiplier=-0.5}},
        [0x21F] = {{stat="INT", offset=1}, {stat="MND", offset=1, multiplier=-0.5}, {stat="CHR", offset=1, multiplier=-0.5}},
        [0x220] = {{stat="AGI", offset=1, multiplier=-0.5}, {stat="INT", offset=1, multiplier=-0.5}, {stat="MND", offset=1}},
        [0x221] = {{stat="AGI", offset=1, multiplier=-0.5}, {stat="MND", offset=1}, {stat="CHR", offset=1, multiplier=-0.5}},
        [0x222] = {{stat="INT", offset=1, multiplier=-0.5}, {stat="MND", offset=1}, {stat="CHR", offset=1, multiplier=-0.5}},
        [0x223] = {{stat="AGI", offset=1, multiplier=-0.5}, {stat="INT", offset=1, multiplier=-0.5}, {stat="CHR", offset=1}},
        [0x224] = {{stat="AGI", offset=1, multiplier=-0.5}, {stat="MND", offset=1, multiplier=-0.5}, {stat="CHR", offset=1}},
        [0x225] = {{stat="INT", offset=1, multiplier=-0.5}, {stat="MND", offset=1, multiplier=-0.5}, {stat="CHR", offset=1}},

        [0x2E4] = {{stat="DMG:", offset=1}},
        [0x2E5] = {{stat="DMG:", offset=33}},
        [0x2E6] = {{stat="DMG:", offset=65}},
        [0x2E7] = {{stat="DMG:", offset=97}},
        [0x2E8] = {{stat="DMG:", offset=1,multiplier=-1}},
        [0x2E9] = {{stat="DMG:", offset=33,multiplier=-1}},
        [0x2EA] = {{stat="DMG:", offset=1}},
        [0x2EB] = {{stat="DMG:", offset=33}},
        [0x2EC] = {{stat="DMG:", offset=65}},
        [0x2ED] = {{stat="DMG:", offset=97}},
        [0x2EE] = {{stat="DMG:", offset=1,multiplier=-1}},
        [0x2EF] = {{stat="DMG:", offset=33,multiplier=-1}},
        [0x2F0] = {{stat="Delay:", offset=1}},
        [0x2F1] = {{stat="Delay:", offset=33}},
        [0x2F2] = {{stat="Delay:", offset=65}},
        [0x2F3] = {{stat="Delay:", offset=97}},
        [0x2F4] = {{stat="Delay:", offset=1,multiplier=-1}},
        [0x2F5] = {{stat="Delay:", offset=33,multiplier=-1}},
        [0x2F6] = {{stat="Delay:", offset=65,multiplier=-1}},
        [0x2F7] = {{stat="Delay:", offset=97,multiplier=-1}},
        [0x2F8] = {{stat="Delay:", offset=1}},
        [0x2F9] = {{stat="Delay:", offset=33}},
        [0x2FA] = {{stat="Delay:", offset=65}},
        [0x2FB] = {{stat="Delay:", offset=97}},
        [0x2FC] = {{stat="Delay:", offset=1,multiplier=-1}},
        [0x2FD] = {{stat="Delay:", offset=33,multiplier=-1}},
        [0x2FE] = {{stat="Delay:", offset=65,multiplier=-1}},
        [0x2FF] = {{stat="Delay:", offset=97,multiplier=-1}},

        [0x300] = {{stat="Fire resistance", offset=1}},
        [0x301] = {{stat="Ice resistance", offset=1}},
        [0x302] = {{stat="Wind resistance", offset=1}},
        [0x303] = {{stat="Earth resistance", offset=1}},
        [0x304] = {{stat="Lightning resistance", offset=1}},
        [0x305] = {{stat="Water resistance", offset=1}},
        [0x306] = {{stat="Light resistance", offset=1}},
        [0x307] = {{stat="Dark resistance", offset=1}},
        [0x308] = {{stat="Fire resistance", offset=1,multiplier=-1}},
        [0x309] = {{stat="Ice resistance", offset=1,multiplier=-1}},
        [0x30A] = {{stat="Wind resistance", offset=1,multiplier=-1}},
        [0x30B] = {{stat="Earth resistance", offset=1,multiplier=-1}},
        [0x30C] = {{stat="Lightning resistance", offset=1,multiplier=-1}},
        [0x30D] = {{stat="Water resistance", offset=1,multiplier=-1}},
        [0x30E] = {{stat="Light resistance", offset=1,multiplier=-1}},
        [0x30F] = {{stat="Dark resistance", offset=1,multiplier=-1}},
        [0x310] = {{stat="Fire resistance", offset=1}, {stat="Water resistance", offset=1,multiplier=-1}},
        [0x311] = {{stat="Fire resistance", offset=1,multiplier=-1}, {stat="Ice resistance", offset=1}},
        [0x312] = {{stat="Ice resistance", offset=1,multiplier=-1}, {stat="Wind resistance", offset=1}},
        [0x313] = {{stat="Wind resistance", offset=1,multiplier=-1}, {stat="Earth resistance", offset=1}},
        [0x314] = {{stat="Earth resistance", offset=1,multiplier=-1}, {stat="Lightning resistance", offset=1}},
        [0x315] = {{stat="Lightning resistance", offset=1,multiplier=-1}, {stat="Water resistance", offset=1}},
        [0x316] = {{stat="Light resistance", offset=1}, {stat="Dark resistance", offset=1,multiplier=-1}},
        [0x317] = {{stat="Light resistance", offset=1,multiplier=-1}, {stat="Dark resistance", offset=1}},
        [0x318] = {{stat="Fire resistance", offset=1}, {stat="Wind resistance", offset=1}, {stat="Lightning resistance", offset=1}, {stat="Light resistance", offset=1}},
        [0x319] = {{stat="Ice resistance", offset=1}, {stat="Earth resistance", offset=1}, {stat="Water resistance", offset=1}, {stat="Dark resistance", offset=1}},
        [0x31A] = {{stat="Fire resistance", offset=1}, {stat="Ice resistance", offset=1,multiplier=-1}, {stat="Wind resistance", offset=1}, {stat="Earth resistance", offset=1,multiplier=-1}, {stat="Lightning resistance", offset=1}, {stat="Water resistance", offset=1,multiplier=-1}, {stat="Light resistance", offset=1}, {stat="Dark resistance", offset=1,multiplier=-1}},
        [0x31B] = {{stat="Fire resistance", offset=1,multiplier=-1}, {stat="Ice resistance", offset=1}, {stat="Wind resistance", offset=1,multiplier=-1}, {stat="Earth resistance", offset=1}, {stat="Lightning resistance", offset=1,multiplier=-1}, {stat="Water resistance", offset=1}, {stat="Light resistance", offset=1,multiplier=-1}, {stat="Dark resistance", offset=1}},
        [0x31C] = {{stat="Fire resistance", offset=1}, {stat="Ice resistance", offset=1}, {stat="Wind resistance", offset=1}, {stat="Earth resistance", offset=1}, {stat="Lightning resistance", offset=1}, {stat="Water resistance", offset=1}, {stat="Light resistance", offset=1}, {stat="Dark resistance", offset=1}},
        [0x31D] = {{stat="Fire resistance", offset=1,multiplier=-1}, {stat="Ice resistance", offset=1,multiplier=-1}, {stat="Wind resistance", offset=1,multiplier=-1}, {stat="Earth resistance", offset=1,multiplier=-1}, {stat="Lightning resistance", offset=1,multiplier=-1}, {stat="Water resistance", offset=1,multiplier=-1}, {stat="Light resistance", offset=1,multiplier=-1}, {stat="Dark resistance", offset=1,multiplier=-1}},

        [0x340] = {{stat="Add.eff.:Fire Dmg.", offset=5}},
        [0x341] = {{stat="Add.eff.:Ice Dmg.", offset=5}},
        [0x342] = {{stat="Add.eff.:Wind Dmg.", offset=5}},
        [0x343] = {{stat="Add.eff.:Earth Dmg.", offset=5}},
        [0x344] = {{stat="Add.eff.:Lightning Dmg.", offset=5}},
        [0x345] = {{stat="Add.eff.:Water Dmg.", offset=5}},
        [0x346] = {{stat="Add.eff.:Light Dmg.", offset=5}},
        [0x347] = {{stat="Add.eff.:Dark Dmg.", offset=5}},
        [0x348] = {{stat="Add.eff.:Disease", offset=1}},
        [0x349] = {{stat="Add.eff.:Paralysis", offset=1}},
        [0x34A] = {{stat="Add.eff.:Silence", offset=1}},
        [0x34B] = {{stat="Add.eff.:Slow", offset=1}},
        [0x34C] = {{stat="Add.eff.:Stun", offset=1}},
        [0x34D] = {{stat="Add.eff.:Poison", offset=1}},
        [0x34E] = {{stat="Add.eff.:Flash", offset=1}},
        [0x34F] = {{stat="Add.eff.:Blindness", offset=1}},
        [0x350] = {{stat="Add.eff.:Weakens def.", offset=1}},
        [0x351] = {{stat="Add.eff.:Sleep", offset=1}},
        [0x352] = {{stat="Add.eff.:Weakens atk.", offset=1}},
        [0x353] = {{stat="Add.eff.:Impairs evasion", offset=1}},
        [0x354] = {{stat="Add.eff.:Lowers acc.", offset=1}},
        [0x355] = {{stat="Add.eff.:Lowers mag.eva.", offset=1}},
        [0x356] = {{stat="Add.eff.:Lowers mag.atk.", offset=1}},
        [0x357] = {{stat="Add.eff.:Lowers mag.def.", offset=1}},
        [0x358] = {{stat="Add.eff.:Lowers mag.acc.", offset=1}},
        -- 0x359 = 475
        [0x380] = {{stat="Sword enhancement spell damage ", offset=1}},
        [0x381] = {{stat='Enhances "Souleater" effect ', offset=1,percent=true}},
        
        
        -- The below enhancements aren't visible if their value is 0.
        [0x3A0] = {{stat="Fire Affinity ", offset=0}},
        [0x3A1] = {{stat="Ice Affinity ", offset=0}},
        [0x3A2] = {{stat="Wind Affinity ", offset=0}},
        [0x3A3] = {{stat="Earth Affinity ", offset=0}},
        [0x3A4] = {{stat="Lightning Affinity ", offset=0}},
        [0x3A5] = {{stat="Water Affinity ", offset=0}},
        [0x3A6] = {{stat="Light Affinity ", offset=0}},
        [0x3A7] = {{stat="Dark Affinity ", offset=0}},
        [0x3A8] = {{stat="Fire Affinity: Magic Accuracy", offset=0}},
        [0x3A9] = {{stat="Ice Affinity: Magic Accuracy", offset=0}},
        [0x3AA] = {{stat="Wind Affinity: Magic Accuracy", offset=0}},
        [0x3AB] = {{stat="Earth Affinity: Magic Accuracy", offset=0}},
        [0x3AC] = {{stat="Lightning Affinity: Magic Accuracy", offset=0}},
        [0x3AD] = {{stat="Water Affinity: Magic Accuracy", offset=0}},
        [0x3AE] = {{stat="Light Affinity: Magic Accuracy", offset=0}},
        [0x3AF] = {{stat="Dark Affinity: Magic Accuracy", offset=0}},
        [0x3B0] = {{stat="Fire Affinity: Magic Damage", offset=0}},
        [0x3B1] = {{stat="Ice Affinity: Magic Damage", offset=0}},
        [0x3B2] = {{stat="Wind Affinity: Magic Damage", offset=0}},
        [0x3B3] = {{stat="Earth Affinity: Magic Damage", offset=0}},
        [0x3B4] = {{stat="Lightning Affinity: Magic Damage", offset=0}},
        [0x3B5] = {{stat="Water Affinity: Magic Damage", offset=0}},
        [0x3B6] = {{stat="Light Affinity: Magic Damage", offset=0}},
        [0x3B7] = {{stat="Dark Affinity: Magic Damage", offset=0}},
        [0x3B8] = {{stat="Fire Affinity: Avatar perp. cost", offset=0}},
        [0x3B9] = {{stat="Ice Affinity: Avatar perp. cost", offset=0}},
        [0x3BA] = {{stat="Wind Affinity: Avatar perp. cost", offset=0}},
        [0x3BB] = {{stat="Earth Affinity: Avatar perp. cost", offset=0}},
        [0x3BC] = {{stat="Lightning Affinity: Avatar perp. cost", offset=0}},
        [0x3BD] = {{stat="Water Affinity: Avatar perp. cost", offset=0}},
        [0x3BE] = {{stat="Light Affinity: Avatar perp. cost", offset=0}},
        [0x3BF] = {{stat="Dark Affinity: Avatar perp. cost", offset=0}},
        [0x3C0] = {{stat="Fire Affinity: Magic Accuracy", offset=0},{stat="Fire Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3C1] = {{stat="Ice Affinity: Magic Accuracy", offset=0},{stat="Ice Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3C2] = {{stat="Wind Affinity: Magic Accuracy", offset=0},{stat="Wind Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3C3] = {{stat="Earth Affinity: Magic Accuracy", offset=0},{stat="Earth Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3C4] = {{stat="Lightning Affinity: Magic Accuracy", offset=0},{stat="Lightning Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3C5] = {{stat="Water Affinity: Magic Accuracy", offset=0},{stat="Water Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3C6] = {{stat="Light Affinity: Magic Accuracy", offset=0},{stat="Light Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3C7] = {{stat="Dark Affinity: Magic Accuracy", offset=0},{stat="Dark Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3C8] = {{stat="Fire Affinity: Magic Damage", offset=0},{stat="Fire Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3C9] = {{stat="Ice Affinity: Magic Damage", offset=0},{stat="Ice Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3CA] = {{stat="Wind Affinity: Magic Damage", offset=0},{stat="Wind Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3CB] = {{stat="Earth Affinity: Magic Damage", offset=0},{stat="Earth Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3CC] = {{stat="Lightning Affinity: Magic Damage", offset=0},{stat="Lightning Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3CD] = {{stat="Water Affinity: Magic Damage", offset=0},{stat="Water Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3CE] = {{stat="Light Affinity: Magic Damage", offset=0},{stat="Light Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3CF] = {{stat="Dark Affinity: Magic Damage", offset=0},{stat="Dark Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3D0] = {{stat='Fire Affin.: "Blood Pact" delay ', offset=1}},
        [0x3D1] = {{stat='Ice Affin.: "Blood Pact" delay ', offset=1}},
        [0x3D2] = {{stat='Wind Affin.: "Blood Pact" delay ', offset=1}},
        [0x3D3] = {{stat='Earth Affin.: "Blood Pact" delay ', offset=1}},
        [0x3D4] = {{stat='Lightning Affin.: "Blood Pact" delay ', offset=1}},
        [0x3D5] = {{stat='Water Affin.: "Blood Pact" delay ', offset=1}},
        [0x3D6] = {{stat='Light Affin.: "Blood Pact" delay ', offset=1}},
        [0x3D7] = {{stat='Dark Affin.: "Blood Pact" delay ', offset=1}},
        [0x3D8] = {{stat="Fire Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3D9] = {{stat="Ice Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3DA] = {{stat="Wind Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3DB] = {{stat="Earth Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3DC] = {{stat="Lightning Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3DD] = {{stat="Water Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3DE] = {{stat="Light Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3DF] = {{stat="Dark Affinity: Recast time", offset=1, multiplier=-2, percent=true}},
        [0x3E0] = {{stat="Fire Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3E1] = {{stat="Ice Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3E2] = {{stat="Wind Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3E3] = {{stat="Earth Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3E4] = {{stat="Lightning Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3E5] = {{stat="Water Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3E6] = {{stat="Light Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3E7] = {{stat="Dark Affinity: Casting time", offset=1, multiplier=-2, percent=true}},
        [0x3E8] = {{stat="Fire Affinity: Magic Accuracy", offset=0},{stat="Fire Affinity: Casting time", offset=1, multiplier=-6, percent=true}},
        [0x3E9] = {{stat="Ice Affinity: Magic Accuracy", offset=0},{stat="Ice Affinity: Casting time", offset=1, multiplier=-6, percent=true}},
        [0x3EA] = {{stat="Wind Affinity: Magic Accuracy", offset=0},{stat="Wind Affinity: Casting time", offset=1, multiplier=-6, percent=true}},
        [0x3EB] = {{stat="Earth Affinity: Magic Accuracy", offset=0},{stat="Earth Affinity: Casting time", offset=1, multiplier=-6, percent=true}},
        [0x3EC] = {{stat="Lightning Affinity: Magic Accuracy", offset=0},{stat="Lightning Affinity: Casting time", offset=1, multiplier=-6, percent=true}},
        [0x3ED] = {{stat="Water Affinity: Magic Accuracy", offset=0},{stat="Water Affinity: Casting time", offset=1, multiplier=-6, percent=true}},
        [0x3EE] = {{stat="Light Affinity: Magic Accuracy", offset=0},{stat="Light Affinity: Casting time", offset=1, multiplier=-6, percent=true}},
        [0x3EF] = {{stat="Dark Affinity: Magic Accuracy", offset=0},{stat="Dark Affinity: Casting time", offset=1, multiplier=-6, percent=true}},
        [0x3F0] = {{stat="Fire Affinity: Magic Damage", offset=0},{stat="Fire Affinity: Recast time", offset=1, multiplier=-6, percent=true}},
        [0x3F1] = {{stat="Ice Affinity: Magic Damage", offset=0},{stat="Ice Affinity: Recast time", offset=1, multiplier=-6, percent=true}},
        [0x3F2] = {{stat="Wind Affinity: Magic Damage", offset=0},{stat="Wind Affinity: Recast time", offset=1, multiplier=-6, percent=true}},
        [0x3F3] = {{stat="Earth Affinity: Magic Damage", offset=0},{stat="Earth Affinity: Recast time", offset=1, multiplier=-6, percent=true}},
        [0x3F4] = {{stat="Lightning Affinity: Magic Damage", offset=0},{stat="Lightning Affinity: Recast time", offset=1, multiplier=-6, percent=true}},
        [0x3F5] = {{stat="Water Affinity: Magic Damage", offset=0},{stat="Water Affinity: Recast time", offset=1, multiplier=-6, percent=true}},
        [0x3F6] = {{stat="Light Affinity: Magic Damage", offset=0},{stat="Light Affinity: Recast time", offset=1, multiplier=-6, percent=true}},
        [0x3F7] = {{stat="Dark Affinity: Magic Damage", offset=0},{stat="Dark Affinity: Recast time", offset=1, multiplier=-6, percent=true}},
        [0x400] = {{stat="Backhand Blow:DMG:", offset=1,multiplier=5,percent=true}},
        [0x401] = {{stat="Spinning Attack:DMG:", offset=1,multiplier=5,percent=true}},
        [0x402] = {{stat="Howling Fist:DMG:", offset=1,multiplier=5,percent=true}},
        [0x403] = {{stat="Dragon Kick:DMG:", offset=1,multiplier=5,percent=true}},
        [0x404] = {{stat="Viper Bite:DMG:", offset=1,multiplier=5,percent=true}},
        [0x405] = {{stat="Shadowstitch:DMG:", offset=1,multiplier=5,percent=true}},
        [0x406] = {{stat="Cyclone:DMG:", offset=1,multiplier=5,percent=true}},
        [0x407] = {{stat="Evisceration:DMG:", offset=1,multiplier=5,percent=true}},
        [0x408] = {{stat="Burning Blade:DMG:", offset=1,multiplier=5,percent=true}},
        [0x409] = {{stat="Shining Blade:DMG:", offset=1,multiplier=5,percent=true}},
        [0x40A] = {{stat="Circle Blade:DMG:", offset=1,multiplier=5,percent=true}},
        [0x40B] = {{stat="Savage Blade:DMG:", offset=1,multiplier=5,percent=true}},
        [0x40C] = {{stat="Freezebite:DMG:", offset=1,multiplier=5,percent=true}},
        [0x40D] = {{stat="Shockwave:DMG:", offset=1,multiplier=5,percent=true}},
        [0x40E] = {{stat="Ground Strike:DMG:", offset=1,multiplier=5,percent=true}},
        [0x40F] = {{stat="Sickle Moon:DMG:", offset=1,multiplier=5,percent=true}},
        [0x410] = {{stat="Gale Axe:DMG:", offset=1,multiplier=5,percent=true}},
        [0x411] = {{stat="Spinning Axe:DMG:", offset=1,multiplier=5,percent=true}},
        [0x412] = {{stat="Calamity:DMG:", offset=1,multiplier=5,percent=true}},
        [0x413] = {{stat="Decimation:DMG:", offset=1,multiplier=5,percent=true}},
        [0x414] = {{stat="Iron Tempest:DMG:", offset=1,multiplier=5,percent=true}},
        [0x415] = {{stat="Sturmwind:DMG:", offset=1,multiplier=5,percent=true}},
        [0x416] = {{stat="Keen Edge:DMG:", offset=1,multiplier=5,percent=true}},
        [0x417] = {{stat="Steel Cyclone:DMG:", offset=1,multiplier=5,percent=true}},
        [0x418] = {{stat="Nightmare Scythe:DMG:", offset=1,multiplier=5,percent=true}},
        [0x419] = {{stat="Spinning Scythe:DMG:", offset=1,multiplier=5,percent=true}},
        [0x41A] = {{stat="Vorpal Scythe:DMG:", offset=1,multiplier=5,percent=true}},
        [0x41B] = {{stat="Spiral Hell:DMG:", offset=1,multiplier=5,percent=true}},
        [0x41C] = {{stat="Leg Sweep:DMG:", offset=1,multiplier=5,percent=true}},
        [0x41D] = {{stat="Skewer:DMG:", offset=1,multiplier=5,percent=true}},
        [0x41E] = {{stat="Vorpal Thrust:DMG:", offset=1,multiplier=5,percent=true}},
        [0x41F] = {{stat="Impulse Drive:DMG:", offset=1,multiplier=5,percent=true}},
        [0x420] = {{stat="Blade: To:DMG:", offset=1,multiplier=5,percent=true}},
        [0x421] = {{stat="Blade: Chi:DMG:", offset=1,multiplier=5,percent=true}},
        [0x422] = {{stat="Blade: Ten:DMG:", offset=1,multiplier=5,percent=true}},
        [0x423] = {{stat="Blade: Ku:DMG:", offset=1,multiplier=5,percent=true}},
        [0x424] = {{stat="Tachi: Goten:DMG:", offset=1,multiplier=5,percent=true}},
        [0x425] = {{stat="Tachi: Jinpu:DMG:", offset=1,multiplier=5,percent=true}},
        [0x426] = {{stat="Tachi: Koki:DMG:", offset=1,multiplier=5,percent=true}},
        [0x427] = {{stat="Tachi: Kasha:DMG:", offset=1,multiplier=5,percent=true}},
        [0x428] = {{stat="Brainshaker:DMG:", offset=1,multiplier=5,percent=true}},
        [0x429] = {{stat="Skullbreaker:DMG:", offset=1,multiplier=5,percent=true}},
        [0x42A] = {{stat="Judgment:DMG:", offset=1,multiplier=5,percent=true}},
        [0x42B] = {{stat="Black Halo:DMG:", offset=1,multiplier=5,percent=true}},
        [0x42C] = {{stat="Rock Crusher:DMG:", offset=1,multiplier=5,percent=true}},
        [0x42D] = {{stat="Shell Crusher:DMG:", offset=1,multiplier=5,percent=true}},
        [0x42E] = {{stat="Full Swing:DMG:", offset=1,multiplier=5,percent=true}},
        [0x42F] = {{stat="Retribution:DMG:", offset=1,multiplier=5,percent=true}},
        [0x430] = {{stat="Dulling Arrow:DMG:", offset=1,multiplier=5,percent=true}},
        [0x431] = {{stat="Blast Arrow:DMG:", offset=1,multiplier=5,percent=true}},
        [0x432] = {{stat="Arching Arrow:DMG:", offset=1,multiplier=5,percent=true}},
        [0x433] = {{stat="Empyreal Arrow:DMG:", offset=1,multiplier=5,percent=true}},
        [0x434] = {{stat="Hot Shot:DMG:", offset=1,multiplier=5,percent=true}},
        [0x435] = {{stat="Split Shot:DMG:", offset=1,multiplier=5,percent=true}},
        [0x436] = {{stat="Sniper Shot:DMG:", offset=1,multiplier=5,percent=true}},
        [0x437] = {{stat="Detonator:DMG:", offset=1,multiplier=5,percent=true}},
        [0x438] = {{stat="Weapon Skill:DMG:", offset=1,multiplier=5,percent=true}},
        --0x43F to 0x4FF are bullshit augments like Viper Bite:Fire+5 and Spinning Attack:173
        -- They do not exist in game afaik, so I'm not going to bother writing them
        [0x500] = {{stat='Enhances "Mighty Strikes" effect', offset=0,multiplier=0}},
        [0x501] = {{stat='Enhances "Hundred Fists" effect', offset=0,multiplier=0}},
        [0x502] = {{stat='Enhances "Benediction" effect', offset=0,multiplier=0}},
        [0x503] = {{stat='Enhances "Manafont" effect', offset=0,multiplier=0}},
        [0x504] = {{stat='Enhances "Chainspell" effect', offset=0,multiplier=0}},
        [0x505] = {{stat='Enhances "Perfect Dodge" effect', offset=0,multiplier=0}},
        [0x506] = {{stat='Enhances "Invincible" effect', offset=0,multiplier=0}},
        [0x507] = {{stat='Enhances "Blood Weapon" effect', offset=0,multiplier=0}},
        [0x508] = {{stat='Enhances "Familiar" effect', offset=0,multiplier=0}},
        [0x509] = {{stat='Enhances "Soul Voice" effect', offset=0,multiplier=0}},
        [0x50A] = {{stat='Enhances "Eagle Eye Shot" effect', offset=0,multiplier=0}},
        [0x50B] = {{stat='Enhances "Meikyo Shisui" effect', offset=0,multiplier=0}},
        [0x50C] = {{stat='Enhances "Mijin Gakure" effect', offset=0,multiplier=0}},
        [0x50D] = {{stat='Enhances "Spirit Surge" effect', offset=0,multiplier=0}},
        [0x50E] = {{stat='Enhances "Astral Flow" effect', offset=0,multiplier=0}},
        [0x50F] = {{stat='Enhances "Azure Lore" effect', offset=0,multiplier=0}},
        [0x510] = {{stat='Enhances "Wild Card" effect', offset=0,multiplier=0}},
        [0x511] = {{stat='Enhances "Overdrive" effect', offset=0,multiplier=0}},
        [0x512] = {{stat='Enhances "Trance" effect', offset=0,multiplier=0}},
        [0x513] = {{stat='Enhances "Tabula Rasa" effect', offset=0,multiplier=0}},
        [0x514] = {{stat='Enhances "Bolster" effect', offset=0,multiplier=0}},
        [0x515] = {{stat='Enhances "Elemental Sforzo" effect', offset=0,multiplier=0}},
        
        [0x530] = {{stat='Enhances "Savagery" effect', offset=0,multiplier=0}},
        [0x531] = {{stat='Enhances "Aggressive Aim" effect', offset=0,multiplier=0}},
        [0x532] = {{stat='Enhances "Warrior\'s Charge" effect', offset=0,multiplier=0}},
        [0x533] = {{stat='Enhances "Tomahawk" effect', offset=0,multiplier=0}},

        [0x536] = {{stat='Enhances "Penance" effect', offset=0,multiplier=0}},
        [0x537] = {{stat='Enhances "Formless Strikes" effect', offset=0,multiplier=0}},
        [0x538] = {{stat='Enhances "Invigorate" effect', offset=0,multiplier=0}},
        [0x539] = {{stat='Enhances "Mantra" effect', offset=0,multiplier=0}},

        [0x53C] = {{stat='Enhances "Protectra V" effect', offset=0,multiplier=0}},
        [0x53D] = {{stat='Enhances "Martyr" effect', offset=0,multiplier=0}},
        [0x53E] = {{stat='Enhances "Shellra V" effect', offset=0,multiplier=0}},
        [0x53F] = {{stat='Enhances "Devotion" effect', offset=0,multiplier=0}},
        
        [0x542] = {{stat='Increases Ancient Magic II damage', offset=0,multiplier=0}},
        [0x543] = {{stat='Reduces Ancient Magic II casting time', offset=0,multiplier=0}},
        [0x544] = {{stat='Increases Ancient Magic II accuracy', offset=0,multiplier=0}},
        [0x545] = {{stat='Increases Ancient Magic II MP cost', offset=0,multiplier=0}},

        [0x548] = {{stat='Enhances "Dia III" effect', offset=0,multiplier=0}},
        [0x549] = {{stat='Enhances "Slow II" effect', offset=0,multiplier=0}},
        [0x54A] = {{stat='Enhances "Phalanx II" effect', offset=0,multiplier=0}},
        [0x54B] = {{stat='Enhances "Bio III" effect', offset=0,multiplier=0}},
        [0x54C] = {{stat='Enhances "Blind II" effect', offset=0,multiplier=0}},
        [0x54D] = {{stat='Enhances "Paralyze II" effect', offset=0,multiplier=0}},
        [0x54E] = {{stat='Enhances "Aura Steal" effect', offset=0,multiplier=0}},
        [0x54F] = {{stat='Enhances "Ambush" effect', offset=0,multiplier=0}},
        [0x550] = {{stat='Enhances "Feint" effect', offset=0,multiplier=0}},
        [0x551] = {{stat='Enhances "Assassin\'s Charge" effect', offset=0,multiplier=0}},
        
        [0x554] = {{stat='Enhances "Iron Will" effect', offset=0,multiplier=0}},
        [0x555] = {{stat='Enhances "Fealty" effect', offset=0,multiplier=0}},
        [0x556] = {{stat='Enhances "Chivalry" effect', offset=0,multiplier=0}},
        [0x557] = {{stat='Enhances "Guardian" effect', offset=0,multiplier=0}},
        
        [0x55A] = {{stat='Enhances "Dark Seal" effect', offset=0,multiplier=0}},
        [0x55B] = {{stat='Enhances "Diabolic Eye" effect', offset=0,multiplier=0}},
        [0x55C] = {{stat='Enhances "Muted Soul" effect', offset=0,multiplier=0}},
        [0x55D] = {{stat='Enhances "Desperate Blows" effect', offset=0,multiplier=0}},
        
        [0x560] = {{stat='Enhances "Killer Instinct" effect', offset=0,multiplier=0}},
        [0x561] = {{stat='Enhances "Feral Howl" effect', offset=0,multiplier=0}},
        [0x562] = {{stat='Enhances "Beast Affinity" effect', offset=0,multiplier=0}},
        [0x563] = {{stat='Enhances "Beast Healer" effect', offset=0,multiplier=0}},
        
        [0x566] = {{stat='Enhances "Foe Sirvente" effect', offset=0,multiplier=0}},
        [0x567] = {{stat='Enhances "Troubadour" effect', offset=0,multiplier=0}},
        [0x568] = {{stat='Enh. "Adventurer\'s Dirge" effect', offset=0,multiplier=0}},
        [0x569] = {{stat='Enhances "Nightingale" effect', offset=0,multiplier=0}},
        
        [0x56C] = {{stat='Enhances "Recycle" effect', offset=0,multiplier=0}},
        [0x56D] = {{stat='Enhances "Snapshot" effect', offset=0,multiplier=0}},
        [0x56E] = {{stat='Enhances "Flashy Shot" effect', offset=0,multiplier=0}},
        [0x56F] = {{stat='Enhances "Stealth Shot" effect', offset=0,multiplier=0}},
        
        [0x572] = {{stat='Enhances "Shikikoyo" effect', offset=0,multiplier=0}},
        [0x573] = {{stat='Enhances "Overwhelm" effect', offset=0,multiplier=0}},
        [0x574] = {{stat='Enhances "Blade Bash" effect', offset=0,multiplier=0}},
        [0x575] = {{stat='Enhances "Ikishoten" effect', offset=0,multiplier=0}},
        
        [0x578] = {{stat='Increases elem. ninjutsu III damage', offset=0,multiplier=0}},
        [0x579] = {{stat='Enhances "Sange" effect', offset=0,multiplier=0}},
        [0x57A] = {{stat='Enh. "Ninja Tool Expertise" effect', offset=0,multiplier=0}},
        [0x57B] = {{stat='Reduces elem. ninjutsu III cast time', offset=0,multiplier=0}},
        
        [0x57E] = {{stat='Enhances "Deep Breathing" effect', offset=0,multiplier=0}},
        [0x57F] = {{stat='Enhances "Angon" effect', offset=0,multiplier=0}},
        [0x580] = {{stat='Enhances "Strafe" effect', offset=0,multiplier=0}},
        [0x581] = {{stat='Enhances "Empathy" effect', offset=0,multiplier=0}},
        
        [0x584] = {{stat='Reduces Sp. "Blood Pact" MP cost', offset=0,multiplier=0}},
        [0x585] = {{stat='Inc. Sp. "Blood Pact" magic burst dmg.', offset=0,multiplier=0}},
        [0x586] = {{stat='Increases Sp. "Blood Pact" accuracy', offset=0,multiplier=0}},
        [0x587] = {{stat='Inc. Sp. "Blood Pact" magic crit. dmg.', offset=0,multiplier=0}},
        
        [0x58A] = {{stat='Enhances "Convergence" effect', offset=0,multiplier=0}},
        [0x58B] = {{stat='Enhances "Enchainment" effect', offset=0,multiplier=0}},
        [0x58C] = {{stat='Enhances "Assimilation" effect', offset=0,multiplier=0}},
        [0x58D] = {{stat='Enhances "Diffusion" effect', offset=0,multiplier=0}},
        
        [0x590] = {{stat='Enhances "Winning Streak" effect', offset=0,multiplier=0}},
        [0x591] = {{stat='Enhances "Loaded Deck" effect', offset=0,multiplier=0}},
        [0x592] = {{stat='Enhances "Fold" effect', offset=0,multiplier=0}},
        [0x593] = {{stat='Enhances "Snake Eye" effect', offset=0,multiplier=0}},
        
        [0x596] = {{stat='Enhances "Optimization" effect', offset=0,multiplier=0}},
        [0x597] = {{stat='Enhances "Fine-Tuning" effect', offset=0,multiplier=0}},
        [0x598] = {{stat='Enhances "Ventriloquy" effect', offset=0,multiplier=0}},
        [0x599] = {{stat='Enhances "Role Reversal" effect', offset=0,multiplier=0}},
        
        [0x59C] = {{stat='Enhances "No Foot Rise" effect', offset=0,multiplier=0}},
        [0x59D] = {{stat='Enhances "Fan Dance" effect', offset=0,multiplier=0}},
        [0x59E] = {{stat='Enhances "Saber Dance" effect', offset=0,multiplier=0}},
        [0x59F] = {{stat='Enhances "Closed Position" effect', offset=0,multiplier=0}},
        
        [0x5A2] = {{stat='Enh. "Altruism" and "Focalization"', offset=0,multiplier=0}},
        [0x5A3] = {{stat='Enhances "Enlightenment" effect', offset=0,multiplier=0}},
        [0x5A4] = {{stat='Enh. "Tranquility" and "Equanimity"', offset=0,multiplier=0}},
        [0x5A5] = {{stat='Enhances "Stormsurge" effect', offset=0,multiplier=0}},
        
        [0x5A8] = {{stat='Enhances "Mending Halation" effect', offset=0,multiplier=0}},
        [0x5A9] = {{stat='Enhances "Radial Arcana" effect', offset=0,multiplier=0}},
        [0x5AA] = {{stat='Enhances "Curative Recantation" effect', offset=0,multiplier=0}},
        [0x5AB] = {{stat='Enhances "Primeval Zeal" effect', offset=0,multiplier=0}},
        
        [0x5AE] = {{stat='Enhances "Battuta" effect', offset=0,multiplier=0}},
        [0x5AF] = {{stat='Enhances "Rayke" effect', offset=0,multiplier=0}},
        [0x5B0] = {{stat='Enhances "Inspire" effect', offset=0,multiplier=0}},
        [0x5B1] = {{stat='Enhances "Sleight of Sword" effect', offset=0,multiplier=0}},
        
        [0x7FF] = {{stat='???', offset=0}},
    },
    [2] = {
        [0x00] = {{stat="none",offset=0}},
        [0x01] = {{stat="----------------",offset=0}},
        [0x02] = {{stat="HP",offset=1}},
        [0x03] = {{stat="HP",offset=256}},
        [0x04] = {{stat="MP",offset=1}},
        [0x05] = {{stat="MP",offset=256}},
        [0x08] = {{stat="Attack",offset=1}},
        [0x09] = {{stat="Attack",offset=256}},
        [0x0A] = {{stat="Rng.Atk.",offset=1}},
        [0x0B] = {{stat="Rng.Atk.",offset=256}},
        [0x0C] = {{stat="Accuracy",offset=1}},
        [0x0D] = {{stat="Accuracy",offset=256}},
        [0x0E] = {{stat="Rng.Acc.",offset=1}},
        [0x0F] = {{stat="Rng.Acc.",offset=256}},
        [0x10] = {{stat="DEF",offset=1}},
        [0x11] = {{stat="DEF",offset=256}},
        [0x12] = {{stat="Evasion",offset=1}},
        [0x13] = {{stat="Evasion",offset=256}},
        [0x14] = {{stat='"Mag.Atk.Bns."',offset=1}},
        [0x15] = {{stat='"Mag.Atk.Bns."',offset=256}},
        [0x16] = {{stat='"Mag.Def.Bns."',offset=1}},
        [0x17] = {{stat='"Mag.Def.Bns."',offset=256}},
        [0x18] = {{stat="Mag. Acc.",offset=1}},
        [0x19] = {{stat="Mag. Acc.",offset=256}},
        [0x1A] = {{stat="Mag. Evasion",offset=1}},
        [0x1B] = {{stat="Mag. Evasion",offset=256}},
        [0x1C] = {{stat="DMG:",offset=1}},
        [0x1D] = {{stat="DMG:",offset=256}},
        [0x80] = {{stat='Pet: "Mag.Atk.Bns."',offset=1}},
        [0x81] = {{stat="Pet: Mag. Acc.",offset=1}},
        [0x82] = {{stat="Pet: Attack",offset=1}},
        [0x83] = {{stat="Pet: Accuracy",offset=1}},
        [0xB9] = {{stat='"Store TP"',offset=1}},
        [0xBA] = {{stat='"Dbl.Atk."',offset=1}},
        [0xBB] = {{stat='"Snapshot"',offset=1}},
        [0xBC] = {{stat="Phys. dmg. taken ",offset=1,multiplier=-1}},
        [0xBD] = {{stat="Magic dmg. taken ",offset=1,multiplier=-1}},
        [0xBE] = {{stat="Breath dmg. taken ",offset=1,multiplier=-1}},
        [0xBF] = {{stat="STR",offset=1}},
        [0xC0] = {{stat="DEX",offset=1}},
        [0xC1] = {{stat="VIT",offset=1}},
        [0xC2] = {{stat="AGI",offset=1}},
        [0xC3] = {{stat="INT",offset=1}},
        [0xC4] = {{stat="MND",offset=1}},
        [0xC5] = {{stat="CHR",offset=1}},
        [0xC6] = {{stat="none",offset=0}},
        [0xC7] = {{stat="none",offset=0}},
        [0xC8] = {{stat="none",offset=0}},
        [0xC9] = {{stat="none",offset=0}},
        [0xCA] = {{stat="none",offset=0}},
        [0xCB] = {{stat="none",offset=0}},
        [0xCC] = {{stat="none",offset=0}},
        [0xCD] = {{stat="none",offset=0}},
        [0xCE] = {{stat="STR",offset=1},{stat="DEX",offset=1},{stat="VIT",offset=1},{stat="AGI",offset=1},{stat="INT",offset=1},{stat="MND",offset=1},{stat="CHR",offset=1}},
        [0xCF] = {{stat="none",offset=0}},
        [0xD0] = {{stat="Hand-to-Hand skill ",offset=1}},
        [0xD1] = {{stat="Dagger skill ",offset=1}},
        [0xD2] = {{stat="Sword skill ", offset=1}},
        [0xD3] = {{stat="Great Sword skill ", offset=1}},
        [0xD4] = {{stat="Axe skill ", offset=1}},
        [0xD5] = {{stat="Great Axe skill ", offset=1}},
        [0xD6] = {{stat="Scythe skill ", offset=1}},
        [0xD7] = {{stat="Polearm skill ", offset=1}},
        [0xD8] = {{stat="Katana skill ", offset=1}},
        [0xD9] = {{stat="Great Katana skill ", offset=1}},
        [0xDA] = {{stat="Club skill ", offset=1}},
        [0xDB] = {{stat="Staff skill ", offset=1}},
        [0xDC] = {{stat="269", offset=0}},
        [0xDD] = {{stat="270", offset=0}},
        [0xDE] = {{stat="271", offset=0}},
        [0xDF] = {{stat="272", offset=0}},
        [0xE0] = {{stat="273", offset=0}},
        [0xE1] = {{stat="274", offset=0}},
        [0xE2] = {{stat="275", offset=0}},
        [0xE3] = {{stat="276", offset=0}},
        [0xE4] = {{stat="277", offset=0}},
        [0xE5] = {{stat="Melee skill ", offset=1}}, -- Automaton
        [0xE6] = {{stat="Ranged skill ", offset=1}}, -- Automaton
        [0xE7] = {{stat="Magic skill ", offset=1}}, -- Automaton
        [0xE8] = {{stat="Archery skill ", offset=1}},
        [0xE9] = {{stat="Marksmanship skill ", offset=1}},
        [0xEA] = {{stat="Throwing skill ", offset=1}},
        [0xEB] = {{stat="284", offset=0}},
        [0xEC] = {{stat="285", offset=0}},
        [0xED] = {{stat="Shield skill ", offset=1}},
        [0xEE] = {{stat="287", offset=0}},
        [0xEF] = {{stat="Divine magic skill ", offset=1}},
        [0xF0] = {{stat="Healing magic skill ", offset=1}},
        [0xF1] = {{stat="Enha.mag. skill ", offset=1}},
        [0xF2] = {{stat="Enfb.mag. skill ", offset=1}},
        [0xF3] = {{stat="Elem. magic skill ", offset=1}},
        [0xF4] = {{stat="Dark magic skill ", offset=1}},
        [0xF5] = {{stat="Summoning magic skill ", offset=1}},
        [0xF6] = {{stat="Ninjutsu skill ", offset=1}},
        [0xF7] = {{stat="Singing skill ", offset=1}},
        [0xF8] = {{stat="String instrument skill ", offset=1}},
        [0xF9] = {{stat="Wind instrument skill ", offset=1}},
        [0xFA] = {{stat="Blue Magic skill ", offset=1}},
        [0xFB] = {{stat="Geomancy Skill ", offset=1}},
        [0xFC] = {{stat="Handbell Skill", offset=1}},
        [0xFD] = {{stat="302", offset=0}},
        [0xFE] = {{stat="303", offset=0}}
    },
    [3] = {
        [0x000] = {{stat='----------------',potency=potencies.zero}},
        [0x001] = {{stat='Vs. beasts: Attack',potency=potencies.family.attack}},
        [0x002] = {{stat='Vs. beasts: DEF',potency=potencies.family.defense}},
        [0x003] = {{stat='Vs. beasts: Accuracy',potency=potencies.family.accuracy}},
        [0x004] = {{stat='Vs. beasts: Evasion',potency=potencies.family.evasion}},
        [0x005] = {{stat='Vs. beasts: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x006] = {{stat='Vs. beasts: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x007] = {{stat='Vs. beasts: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x008] = {{stat='Vs. beasts: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x009] = {{stat='Vs. beasts: Rng.Atk.',potency=potencies.family.attack}},
        [0x00A] = {{stat='Vs. beasts: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x00B] = {{stat='Vs. plantoids: Attack',potency=potencies.family.attack}},
        [0x00C] = {{stat='Vs. plantoids: DEF',potency=potencies.family.defense}},
        [0x00D] = {{stat='Vs. plantoids: Accuracy',potency=potencies.family.accuracy}},
        [0x00E] = {{stat='Vs. plantoids: Evasion',potency=potencies.family.evasion}},
        [0x00F] = {{stat='Vs. plantoids: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x010] = {{stat='Vs. plantoids: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x011] = {{stat='Vs. plantoids: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x012] = {{stat='Vs. plantoids: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x013] = {{stat='Vs. plantoids: Rng.Atk.',potency=potencies.family.attack}},
        [0x014] = {{stat='Vs. plantoids: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x015] = {{stat='Vs. vermin: Attack',potency=potencies.family.attack}},
        [0x016] = {{stat='Vs. vermin: DEF',potency=potencies.family.defense}},
        [0x017] = {{stat='Vs. vermin: Accuracy',potency=potencies.family.accuracy}},
        [0x018] = {{stat='Vs. vermin: Evasion',potency=potencies.family.evasion}},
        [0x019] = {{stat='Vs. vermin: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x01A] = {{stat='Vs. vermin: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x01B] = {{stat='Vs. vermin: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x01C] = {{stat='Vs. vermin: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x01D] = {{stat='Vs. vermin: Rng.Atk.',potency=potencies.family.attack}},
        [0x01E] = {{stat='Vs. vermin: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x01F] = {{stat='Vs. lizards: Attack',potency=potencies.family.attack}},
        [0x020] = {{stat='Vs. lizards: DEF',potency=potencies.family.defense}},
        [0x021] = {{stat='Vs. lizards: Accuracy',potency=potencies.family.accuracy}},
        [0x022] = {{stat='Vs. lizards: Evasion',potency=potencies.family.evasion}},
        [0x023] = {{stat='Vs. lizards: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x024] = {{stat='Vs. lizards: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x025] = {{stat='Vs. lizards: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x026] = {{stat='Vs. lizards: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x027] = {{stat='Vs. lizards: Rng.Atk.',potency=potencies.family.attack}},
        [0x028] = {{stat='Vs. lizards: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x029] = {{stat='Vs. birds: Attack',potency=potencies.family.attack}},
        [0x02A] = {{stat='Vs. birds: DEF',potency=potencies.family.defense}},
        [0x02B] = {{stat='Vs. birds: Accuracy',potency=potencies.family.accuracy}},
        [0x02C] = {{stat='Vs. birds: Evasion',potency=potencies.family.evasion}},
        [0x02D] = {{stat='Vs. birds: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x02E] = {{stat='Vs. birds: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x02F] = {{stat='Vs. birds: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x030] = {{stat='Vs. birds: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x031] = {{stat='Vs. birds: Rng.Atk.',potency=potencies.family.attack}},
        [0x032] = {{stat='Vs. birds: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x033] = {{stat='Vs. amorphs: Attack',potency=potencies.family.attack}},
        [0x034] = {{stat='Vs. amorphs: DEF',potency=potencies.family.defense}},
        [0x035] = {{stat='Vs. amorphs: Accuracy',potency=potencies.family.accuracy}},
        [0x036] = {{stat='Vs. amorphs: Evasion',potency=potencies.family.evasion}},
        [0x037] = {{stat='Vs. amorphs: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x038] = {{stat='Vs. amorphs: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x039] = {{stat='Vs. amorphs: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x03A] = {{stat='Vs. amorphs: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x03B] = {{stat='Vs. amorphs: Rng.Atk.',potency=potencies.family.attack}},
        [0x03C] = {{stat='Vs. amorphs: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x03D] = {{stat='Vs. aquans: Attack',potency=potencies.family.attack}},
        [0x03E] = {{stat='Vs. aquans: DEF',potency=potencies.family.defense}},
        [0x03F] = {{stat='Vs. aquans: Accuracy',potency=potencies.family.accuracy}},
        [0x040] = {{stat='Vs. aquans: Evasion',potency=potencies.family.evasion}},
        [0x041] = {{stat='Vs. aquans: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x042] = {{stat='Vs. aquans: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x043] = {{stat='Vs. aquans: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x044] = {{stat='Vs. aquans: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x045] = {{stat='Vs. aquans: Rng.Atk.',potency=potencies.family.attack}},
        [0x046] = {{stat='Vs. aquans: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x047] = {{stat='Vs. undead: Attack',potency=potencies.family.attack}},
        [0x048] = {{stat='Vs. undead: DEF',potency=potencies.family.defense}},
        [0x049] = {{stat='Vs. undead: Accuracy',potency=potencies.family.accuracy}},
        [0x04A] = {{stat='Vs. undead: Evasion',potency=potencies.family.evasion}},
        [0x04B] = {{stat='Vs. undead: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x04C] = {{stat='Vs. undead: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x04D] = {{stat='Vs. undead: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x04E] = {{stat='Vs. undead: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x04F] = {{stat='Vs. undead: Rng.Atk.',potency=potencies.family.attack}},
        [0x050] = {{stat='Vs. undead: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x051] = {{stat='Vs. elementals: Attack',potency=potencies.family.attack}},
        [0x052] = {{stat='Vs. elementals: DEF',potency=potencies.family.defense}},
        [0x053] = {{stat='Vs. elementals: Accuracy',potency=potencies.family.accuracy}},
        [0x054] = {{stat='Vs. elementals: Evasion',potency=potencies.family.evasion}},
        [0x055] = {{stat='Vs. elementals: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x056] = {{stat='Vs. elementals: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x057] = {{stat='Vs. elementals: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x058] = {{stat='Vs. elementals: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x059] = {{stat='Vs. elementals: Rng.Atk.',potency=potencies.family.attack}},
        [0x05A] = {{stat='Vs. elementals: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x05B] = {{stat='Vs. arcana: Attack',potency=potencies.family.attack}},
        [0x05C] = {{stat='Vs. arcana: DEF',potency=potencies.family.defense}},
        [0x05D] = {{stat='Vs. arcana: Accuracy',potency=potencies.family.accuracy}},
        [0x05E] = {{stat='Vs. arcana: Evasion',potency=potencies.family.evasion}},
        [0x05F] = {{stat='Vs. arcana: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x060] = {{stat='Vs. arcana: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x061] = {{stat='Vs. arcana: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x062] = {{stat='Vs. arcana: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x063] = {{stat='Vs. arcana: Rng.Atk.',potency=potencies.family.attack}},
        [0x064] = {{stat='Vs. arcana: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x065] = {{stat='Vs. Demons: Attack',potency=potencies.family.attack}},
        [0x066] = {{stat='Vs. Demons: DEF',potency=potencies.family.defense}},
        [0x067] = {{stat='Vs. Demons: Accuracy',potency=potencies.family.accuracy}},
        [0x068] = {{stat='Vs. Demons: Evasion',potency=potencies.family.evasion}},
        [0x069] = {{stat='Vs. Demons: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x06A] = {{stat='Vs. Demons: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x06B] = {{stat='Vs. Demons: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x06C] = {{stat='Vs. Demons: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x06D] = {{stat='Vs. Demons: Rng.Atk.',potency=potencies.family.attack}},
        [0x06E] = {{stat='Vs. Demons: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x06F] = {{stat='Vs. dragons: Attack',potency=potencies.family.attack}},
        [0x070] = {{stat='Vs. dragons: DEF',potency=potencies.family.defense}},
        [0x071] = {{stat='Vs. dragons: Accuracy',potency=potencies.family.accuracy}},
        [0x072] = {{stat='Vs. dragons: Evasion',potency=potencies.family.evasion}},
        [0x073] = {{stat='Vs. dragons: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x074] = {{stat='Vs. dragons: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x075] = {{stat='Vs. dragons: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x076] = {{stat='Vs. dragons: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x077] = {{stat='Vs. dragons: Rng.Atk.',potency=potencies.family.attack}},
        [0x078] = {{stat='Vs. dragons: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x079] = {{stat='Vs. Empty: Attack',potency=potencies.family.attack}},
        [0x07A] = {{stat='Vs. Empty: DEF',potency=potencies.family.defense}},
        [0x07B] = {{stat='Vs. Empty: Accuracy',potency=potencies.family.accuracy}},
        [0x07C] = {{stat='Vs. Empty: Evasion',potency=potencies.family.evasion}},
        [0x07D] = {{stat='Vs. Empty: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x07E] = {{stat='Vs. Empty: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x07F] = {{stat='Vs. Empty: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x080] = {{stat='Vs. Empty: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x081] = {{stat='Vs. Empty: Rng.Atk.',potency=potencies.family.attack}},
        [0x082] = {{stat='Vs. Empty: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x083] = {{stat='Vs. Luminians: Attack',potency=potencies.family.attack}},
        [0x084] = {{stat='Vs. Luminians: DEF',potency=potencies.family.defense}},
        [0x085] = {{stat='Vs. Luminians: Accuracy',potency=potencies.family.accuracy}},
        [0x086] = {{stat='Vs. Luminians: Evasion',potency=potencies.family.evasion}},
        [0x087] = {{stat='Vs. Luminians: "Mag.Atk.Bns."',potency=potencies.family.magic_bonus}},
        [0x088] = {{stat='Vs. Luminians: "Mag.Def.Bns."',potency=potencies.family.magic_bonus}},
        [0x089] = {{stat='Vs. Luminians: Mag. Acc.',potency=potencies.family.magic_accuracy}},
        [0x08A] = {{stat='Vs. Luminians: Mag. Evasion',potency=potencies.family.accuracy}},
        [0x08B] = {{stat='Vs. Luminians: Rng.Atk.',potency=potencies.family.attack}},
        [0x08C] = {{stat='Vs. Luminians: Rng.Acc.',potency=potencies.family.accuracy}},
        [0x08D] = {{stat='Might Strikes: Ability delay ',potency=potencies.sp_recast}},
        [0x08E] = {{stat='Hundred Fists: Ability delay ',potency=potencies.sp_recast}},
        [0x08F] = {{stat='Benediction: Ability delay ',potency=potencies.sp_recast}},
        [0x090] = {{stat='Manafont: Ability delay ',potency=potencies.sp_recast}},
        [0x091] = {{stat='Chainspell: Ability delay ',potency=potencies.sp_recast}},
        [0x092] = {{stat='Perfect Dodge: Ability delay ',potency=potencies.sp_recast}},
        [0x093] = {{stat='Invincible: Ability delay ',potency=potencies.sp_recast}},
        [0x094] = {{stat='Blood Weapon: Ability delay ',potency=potencies.sp_recast}},
        [0x095] = {{stat='Familiar: Ability delay ',potency=potencies.sp_recast}},
        [0x096] = {{stat='Soul Voice: Ability delay ',potency=potencies.sp_recast}},
        [0x097] = {{stat='Eagle Eye Shot: Ability delay ',potency=potencies.sp_recast}},
        [0x098] = {{stat='Meikyo Shisui: Ability delay ',potency=potencies.sp_recast}},
        [0x099] = {{stat='Mijin Gakure: Ability delay ',potency=potencies.sp_recast}},
        [0x09A] = {{stat='Spirit Surge: Ability delay ',potency=potencies.sp_recast}},
        [0x09B] = {{stat='Astral Flow: Ability delay ',potency=potencies.sp_recast}},
        [0x09C] = {{stat='Azure Lore: Ability delay ',potency=potencies.sp_recast}},
        [0x09D] = {{stat='Wild Card: Ability delay ',potency=potencies.sp_recast}},
        [0x09E] = {{stat='Overdrive: Ability delay ',potency=potencies.sp_recast}},
        [0x09F] = {{stat='Trance: Ability delay ',potency=potencies.sp_recast}},
        [0x0A0] = {{stat='Tabula Rasa: Ability delay ',potency=potencies.sp_recast}},
        -- There are 308 augments total, and they stop being even remotely systematic after this point.
    },
}


function unpack_augment(sys,short)
    if sys == 1 then
        return short:byte(1) + short:byte(2)%8*256,  math.floor(short:byte(2)/8)
    elseif sys == 2 then
        return short:byte(1), short:byte(2)
    elseif sys == 3 then
        return short:byte(1) + short:byte(2)%8*256,  math.floor(short:byte(2)%128/8)
    end
end

function string_augment(sys,id,val)
    local augment
    local augment_table = augment_values[sys][id]
    if augment_table then
        if sys == 3 then
            augment = augment_table[1].stat
            local pot = augment_table[1].potency[val]
            if pot > 0 then
                augment = augment..'+'
            end
            augment = augment..pot
        else
            for i,v in pairs(augment_table) do
                if i > 1 then augment = augment..' ' end
                augment = (augment or '')..v.stat
                local potency = ((val+v.offset)*(v.multiplier or 1))
                if potency > 0 then augment = augment..'+'..potency
                elseif potency < 0 then  augment = augment..potency end
                if v.percent then
                    augment = augment..'%'
                end
            end
        end
    else
        augment = 'System: '..tostring(sys)..' ID: '..tostring(id)..' Val: '..tostring(val)
    end
    return augment
end

function augments_to_table(sys,str)
    local augments,ids,vals = {},{},{}
    for i=1,#str,2 do
        local id,val = unpack_augment(sys,str:sub(i,i+1))
        augments[#augments+1] = string_augment(sys,id,val)
    end
    return augments
end


local server_timestamp_offset = 1009792800

local decode = {}

function decode.Enchanted(str)
    local rettab = {type = 'Enchanted Equipment',
        charges_remaining = str:byte(2),
        usable = str:byte(4)%128/64>=1,
        next_use_time = str:unpack('I',5) + server_timestamp_offset,
        activation_time = str:unpack('I',9) + server_timestamp_offset,
        }
    return rettab
end

function decode.Augmented(str)
    local flag_2 = str:byte(2)
    local rettab = {type = 'Augmented Equipment'}
    if flag_2%128/64>= 1 then
        rettab.trial_number = (str:byte(12)%128)*256+str:byte(11)
        rettab.trial_complete = str:byte(12)/128>=1
    end
    
    if flag_2%64/32 >=1 then
        rettab.augment_system = 2
        local path_map = {[0] = 'A',[1] = 'B', [2] = 'C', [3] = 'D'}
        local points_map = {[1] = 50, [2] = 80, [3] = 120, [4] = 170, [5] = 220, [6] = 280, [7] = 340, [8] = 410, [9] = 480, [10]=560, [11]=650, [12] = 750, [13] = 960, [14] = 980}
        rettab.path = path_map[str:byte(3)%4]
        rettab.rank = math.floor(str:byte(3)%128/4)
        rettab.RP = math.max(points_map[rettab.rank] or 0 - str:byte(6)*256 - str:byte(5),0)
        rettab.augments = augments_to_table(rettab.augment_system,str:sub(7,12))
    elseif flag_2/128 >= 1 then -- Evolith
        rettab.augment_system = 3
        local slot_type_map = {[0] = 'None', [1] = 'Filled Upside-down Triangle', [2] = 'Filled Diamond', [3] = 'Filled Star', [4] = 'Empty Triangle', [5] = 'Empty Square', [6] = 'Empty Circle', [7] = 'Empty Upside-down Triangle', [8] = 'Empty Diamond', [9] = 'Empty Star', [10] = 'Filled Triangle', [11] = 'Filled Square', [12] = 'Filled Circle', [13] = 'Empty Circle', [14] = 'Fire', [15] = 'Ice'}
        rettab.slots = {[1] = {type = slot_type_map[str:byte(9)%16], size = math.floor(str:byte(10)/16)+1, element = str:byte(12)%8},
            [2] = {type = slot_type_map[math.floor(str:byte(9)/16)], size = str:byte(11)%16+1, element = math.floor(str:byte(12)/8)%8},
            [3] = {type = slot_type_map[str:byte(10)%16], size = math.floor(str:byte(11)/16)+1, element = math.floor(str:byte(12)/64) + math.floor(str:byte(8)/128)},
            }
        rettab.augments = augments_to_table(rettab.augment_system,str:sub(3,8))
    else
        rettab.augment_system = 1
        if rettab.trial_number then
            rettab.augments = augments_to_table(rettab.augment_system,str:sub(3,10))
        else
            rettab.augments = augments_to_table(rettab.augment_system,str:sub(3,12))
        end
    end
    return rettab
end


-----------------------------------------------------------------------------------
--Name: l_to_r_bit_packed(dat_string,start,stop)
--Args:
---- dat_string - string that is being bit-unpacked to a number
---- start - first bit
---- stop - last bit
-----------------------------------------------------------------------------------
--Returns:
---- number from the indicated range of bits 
-----------------------------------------------------------------------------------
function l_to_r_bit_packed(dat_string,start,stop)
    local newval = 0
    
    local c_count = math.ceil(stop/8)
    while c_count >= math.ceil((start+1)/8) do
        -- Grabs the most significant byte first and works down towards the least significant.
        local cur_val = dat_string:byte(c_count)
        local scal = 1
        
        if c_count == math.ceil(stop/8) then -- Take the least significant bits of the most significant byte
        -- Moduluses by 2^number of bits into the current byte. So 8 bits in would %256, 1 bit in would %2, etc.
        -- Cuts off the bottom.
            cur_val = math.floor(cur_val/(2^(8-((stop-1)%8+1)))) -- -1 and +1 set the modulus result range from 1 to 8 instead of 0 to 7.
        end
        
        if c_count == math.ceil((start+1)/8) then -- Take the most significant bits of the least significant byte
        -- Divides by the significance of the final bit in the current byte. So 8 bits in would /128, 1 bit in would /1, etc.
        -- Cuts off the top.
            cur_val = cur_val%(2^(8-start%8))
        end
        
        if c_count == math.ceil(stop/8)-1 then
            scal = 2^(((stop-1)%8+1))
        end
        
        newval = newval + cur_val*scal -- Need to multiply by 2^number of bits in the next byte
        c_count = c_count - 1
    end
    return newval
end


function decode.Signature(str)
    local sig_map = {[1]='0',[2]='1',[3]='2',[4]='3',[5]='4',[6]='5',[7]='6',[8]='7',[9]='8',[10]='9',
        [11]='A',[12]='B',[13]='C',[14]='D',[15]='E',[16]='F',[17]='G',[18]='H',[19]='I',[20]='J',[21]='K',[22]='L',[23]='M',
        [24]='N',[25]='O',[26]='P',[27]='Q',[28]='R',[29]='S',[30]='T',[31]='U',[32]='V',[33]='W',[34]='X',[35]='Y',[36]='Z',
        [37]='a',[38]='b',[39]='c',[40]='d',[41]='e',[42]='f',[43]='g',[44]='h',[45]='i',[46]='j',[47]='k',[48]='l',[49]='m',
        [50]='n',[51]='o',[52]='p',[53]='q',[54]='r',[55]='s',[56]='t',[57]='u',[58]='v',[59]='w',[60]='x',[61]='y',[62]='z',
        [63]='{'
        }
    return decode.bit_string(6,str,sig_map)
end

function decode.bit_string(bits,str,map)
    local i,sig = 0,''
    while map[l_to_r_bit_packed(str,i,i+bits)] do
        sig = sig..map[l_to_r_bit_packed(str,i,i+bits)]
        i = i+bits
    end
    return sig
end

local flag_1_mapping = {
    [1] = decode.Enchanted,
    [2] = decode.Augmented,
    }


function decode.General(str)
    decoded = {type = 'General'}
    if str:byte(13) ~= 0 then
        decoded.signature = decode.Signature(str:sub(13))
    end
    return decoded
end

function decode.Mannequin(str)
-- I can't test this.
    local rettab = {type = 'Mannequin',
        is_displayed = (str:byte(2)%128/64 >= 1)
    }
    if rettab.is_displayed then
        rettab.grid_x = str:byte(7)
        rettab.grid_z = str:byte(8)
        rettab.grid_y = str:byte(9)
        local storage = windower.ffxi.get_items(2)
        local empty = {}
        rettab.equipment = {main = storage[str:byte(11)] or empty, sub = storage[str:byte(12)] or empty,
            ranged = storage[str:byte(13)] or empty, head = storage[str:byte(14)] or empty, body = storage[str:byte(15)] or empty,
            hands = storage[str:byte(16)] or empty, legs = storage[str:byte(17)] or empty, feet = storage[str:byte(18)] or empty}
        rettab.race_id = str:byte(19)
        rettab.race = res.races[rettab.race_id]
        rettab.pose_id = str:byte(20)
    end
    return rettab
end

function decode.Linkshell(str)
    local status_map = {[0]='Unopened',[1]='Linkshell',[2]='Pearlsack',[3]='Linkpearl',[4]='Broken'}
    local name_end = string.find(str,string.char(0),10)
    local name_map = {[0]="'",[1]="a",[2]='b',[3]='c',[4]='d',[5]='e',[6]='f',[7]='g',[8]='h',[9]='i',[10]='j',
        [11]='k',[12]='l',[13]='m',[14]='n',[15]='o',[16]='p',[17]='q',[18]='r',[19]='s',[20]='t',[21]='u',[22]='v',[23]='w',
        [24]='x',[25]='yx',[26]='z',[27]='A',[28]='B',[29]='C',[30]='D',[31]='E',[32]='F',[33]='G',[34]='H',[35]='I',[36]='J',
        [37]='K',[38]='L',[39]='M',[40]='N',[41]='O',[42]='P',[43]='Q',[44]='R',[45]='S',[46]='T',[47]='U',[48]='V',[49]='W',
        [50]='X',[51]='Y',[52]='Z'
        }
    local rettab = {type = 'Linkshell',
        linkshell_id = str:unpack('I'),
        r  = 17*str:byte(7)%16,
        g  = 17*math.floor(str:byte(7)/16),
        b  = 17*str:byte(8)%16,
        status_id = str:byte(9),
        status = status_map[str:byte(9)],
        name = decode.bit_string(6,str:sub(10,name_end),name_map)}
    
    return rettab
end

function decode.Furniture(str)
    local rettab = {type = 'Furniture',
        is_displayed = (str:byte(2)%128/64 >= 1)}
    if rettab.is_displayed then
        rettab.grid_x = str:byte(7)
        rettab.grid_z = str:byte(8)
        rettab.grid_y = str:byte(9)
        rettab.rotation = str:byte(10)
    end
    return rettab
end

function decode.Flowerpot(str)
    --[[ 0 = Empty pot, Plant seed menu
        (1) 2-11 = Herb Seeds
        (14?)15-24 = Grain Seeds
        (27?)28-37 = Vegetable Seeds
        (40?)41-50 = Cactus Stems
        (53?)54-63 = Tree Cutting
        (65?)66-76 = Tree Sapling
        (79?)80-89 = Wildgrass Seed]]
    local rettab = {type = 'Flowerpot',
        is_displayed = (str:byte(2)%128/64 >= 1)}
    if rettab.is_displayed then
        rettab.grid_x = str:byte(7)
        rettab.grid_z = str:byte(8)
        rettab.grid_y = str:byte(9)
        rettab.rotation = str:byte(10)
        rettab.is_planted = str:byte(1)%13 > 0
    end
    if rettab.is_planted then
        local plants = {[0] = 'Herb Seeds', [1] = 'Grain Seeds',[2] = 'Vegetable Seeds', [3] = 'Cactus Stems',
            [4] = 'Tree Cuttings', [5] = 'Tree Saplings', [6] = 'Wildgrass Seeds'}
        local stages = {[1] = 'Initial', [2] = 'First Sprouts', [3] = 'First Sprouts 2', [4] = 'First Sprouts - Crystal',
            [5] = 'Second Sprouts', [6] = 'Second Sprouts 2', [7] = 'Second Sprouts - Crystal', [8] = 'Second Sprouts 3',
            [9] = 'Third Sprouts', [10] = 'Mature Plant', [11] = 'Wilted'}
        rettab.plant_id = math.floor((str:byte(1)-1)/13)
        rettab.plant = plants[plant_id]
        rettab.stage_id = str:byte(1)%13 -- Stages from 1 to 10 are valid
        rettab.ts_1 = str:unpack('I',13) + server_timestamp_offset
        rettab.ts_2 = str:unpack('I',17) + server_timestamp_offset
        rettab.unknown = str:byte(5)+str:byte(6)*256
    end
    return rettab
end

function decode.Mannequin(str)
-- I can't test this.
    local rettab = {type = 'Mannequin',
        is_displayed = (str:byte(2)%128/64 >= 1)
    }
    if rettab.is_displayed then
        rettab.grid_x = str:byte(7)
        rettab.grid_z = str:byte(8)
        rettab.grid_y = str:byte(9)
        local storage = windower.ffxi.get_items(2)
        local empty = {}
        rettab.equipment = {main = storage[str:byte(11)] or empty, sub = storage[str:byte(12)] or empty,
            ranged = storage[str:byte(13)] or empty, head = storage[str:byte(14)] or empty, body = storage[str:byte(15)] or empty,
            hands = storage[str:byte(16)] or empty, legs = storage[str:byte(17)] or empty, feet = storage[str:byte(18)] or empty}
        rettab.race_id = str:byte(19)
        rettab.race = res.races[rettab.race_id]
        rettab.pose_id = str:byte(20)
    end
    return rettab
end

function decode.Unknown(str)
    return {type = 'Unknown',
        value = str:hex()
        }
end

function decode.Lamp(str)
    local chambers = {[0x1E] = 'Rossweisse', [0x1F] = 'Grimgerde', [0x20] = 'Siegrune', [0x21] = 'Helmwige',
        [0x22] = 'Schwertleite', [0x23] = 'Waltraute', [0x24] = 'Ortlinde', [0x25] = 'Gerhilde', [0x26] = 'Brunhilde',
        [0x27] = 'Odin'}
    local statuses = {[0] = 'Uninitialized', [1] = 'Active', [2] = 'Active', [3] = 'Spent'}
    local rettab = {type='Lamp',
        chamber = chambers[str:unpack('H')] or 'unknown',
        exit_time = str:unpack('I',9),
        entry_time = str:unpack('I',13),
        zone_id = str:unpack('H',17),
        status_id = str:byte(3)%4,
        status = statuses[rettab.status_id],
        _unknown1 = str:unpack('i',5)
    }
    
    if res.zones[rettab.zone_id] then
        rettab.zone = res.zones[rettab.zone_id].english
    else
        rettab.zone = 'unknown'
    end
    
    return rettab
end

function decode.Hourglass(str)
    local statuses = {[0] = 'Uninitialized', [1] = 'Active', [2] = 'Active', [3] = 'Spent'}
    local rettab = {type='Hourglass',
        exit_time = str:unpack('I',9),
--        entry_time = str:unpack('I',13),
        zone_id = str:unpack('H',17),
        status_id = str:byte(3)%4,
        status = statuses[rettab.status_id],
        _unknown1 = str:unpack('i',5)
    }
    
    if res.zones[rettab.zone_id] then
        rettab.zone = res.zones[rettab.zone_id].english
    else
        rettab.zone = 'unknown'
    end
    
    return rettab
end

function decode.EmptySlot(str)
    local rettab = {type='Empty Slot',
        ws_points = str:unpack('I')
    }
    
    return rettab
end

function decode.Fish(str)
    local rettab = {
        size = str:unpack('H'),
        weight = str:unpack('H',3),
        is_ranked = str:byte(5)%2 == 1
    }
    return rettab
end

function decode.Equipment(str)
    local rettab
    local flag_1 = str:byte(1)
    if flag_1_mapping[flag_1] then
        rettab = flag_1_mapping[flag_1](str:sub(1,12))
    else
        rettab= decode.Unknown(str:sub(1,12))
        rettab.type = 'Equipment'
    end
    if str:byte(13) ~= 0 then
        rettab.signature = decode.Signature(str:sub(13))
    end
    return rettab
end

function decode.PvPReservation(str)
    local rettab = {type='PvP Reservation',
        time = str:unpack('I') + server_timestamp_offset,
        level = math.floor(str:byte(4)/32)*10
    }
    if rettab.level == 0 then rettab.level = 99 end
    return rettab
end

function decode.Reflector(str)
    local firstnames = {"Bloody", "Brutal", "Celestial", "Combat", "Cyclopean", "Dark", "Deadly",
            "Drachen", "Giant", "Hostile", "Howling", "Hyper", "Invincible", "Merciless", "Mighty",
            "Necro", "Nimble", "Poison", "Putrid", "Rabid", "Radiant", "Raging", "Relentless",
            "Savage", "Silent", "Tenebrous", "The", "Triple", "Undead", "Writhing", "Serpentine",
            "Aile", "Bete", "Croc", "Babine", "Carapace", "Colosse", "Corne", "Fauve",
            "Flamme", "Griffe", "Machoire", "Mandibule", "Patte", "Rapace", "Tentacule", "Voyou",
            "Zaubernder", "Brutaler", "Explosives", "Funkelnder", "Kraftvoller", "Moderndes", "Tosender", "Schwerer",
            "Sprintender", "Starker", "Stinkender", "Taumelnder", "Tolles", "Verlornes", "Wendiger", "Wuchtiger"}
        firstnames[0] = "Pit"
    local lastnames = {"Beast", "Butcher", "Carnifex", "Critter", "Cyclone", "Dancer", "Darkness",
            "Erudite", "Fang", "Fist", "Flayer", "Gladiator", "Heart", "Howl", "Hunter",
            "Jack", "Machine", "Mountain", "Nemesis", "Raven", "Reaver", "Rock", "Stalker",
            "T", "Tiger", "Tornado", "Vermin", "Vortex", "Whispers", "X", "Prime",
            "Agile", "Brave", "Coriace", "Diabolique", "Espiegle", "Feroce", "Fidele", "Fourbe",
            "Impitoyable", "Nuisible", "Robuste", "Sanguinaire", "Sauvage", "Stupide", "Tenace", "Tendre",
            "Boesewicht", "Engel", "Flitzpiepe", "Gottkaiser", "Klotz", "Muelleimer", "Pechvogel", "Postbote",
            "Prinzessin", "Raecherin", "Riesenbaby", "Hexer", "Teufel", "Vieh", "Vielfrass", "Fleischer"}
        lastnames[0] = "Monster"
    local rettab = {type='Reflector',
        first_name = firstnames[str:byte(1)%64],
        last_name = lastnames[math.floor(str:byte(1)/64) + (str:byte(2)%16)*4],
        level = (math.floor(str:byte(7)/16) + (str:byte(8)%16)*16)%128
    }
    return rettab
end

function decode.SoulPlate(str)
    local name_end = string.find(str,string.char(0),1)
    local name_map = {}
    for i = 1,127 do
        name_map[i] = string.char(i)
    end
    local rettab = {type = 'Soul Plate',
            skill_id = math.floor(str:byte(21)/128) + str:byte(22)*2 + str:byte(23)%8*(2^9), -- Index for whatever table I end up making, so table[skill_id] would be {name = "Breath Damage", multiplier = 1, percent=true}
--            skill = nil, -- "Breath damage +5%, etc."
            FP = math.floor(str:byte(23)/8) + str:byte(24)%4*16, -- Cost in FP
            name = decode.bit_string(7,str:sub(1,name_end),name_map), -- Name of the monster
--            9D 87 AE C0 = 'Naul'
        }
    return rettab
end


local typ_mapping = {
--[[Types:
    *1 = General
    *2 = Fight entry items
    *3 = Fish
    *4 = Weapon
    *5 = Armor
    *6 = Linkshells (but not broken linkshells?)
    *7 = Usable items
    *8 = Crystals
    *10 = Furniture
    *11 = Seeds
    *12 = Flowerpot
    *14 = Mannequin
    
    *15 = Ballista books
    16 = Chocobo Paraphenelia (Eggs, Cards, slips, etc.)
    17 = Chocobo Ticket and Completion Certificate
    18 = Soul Plates
    *19 = Soul Reflectors
    20 = Salvage logs
    21 = Bonanza Marble
    22 = Maze Tabula M
    23 = Maze Tabula R
    24 = Maze Voucher
    25 = Maze Rune
    26 = Evoliths
    
    27 = Storage Slip
    
    28 = Legion Pass
    29 = Meebles Burrow Grimoires
]]
    [1] = decode.General,
    [2] = decode.General, -- Unknown if used BCNM orbs contain information
    [3] = decode.Fish,
    [4] = decode.Equipment,
    [5] = decode.Equipment,
    [6] = decode.Linkshell,
    [7] = decode.General,
    [8] = decode.General,
    [10] = decode.Furniture,
    [11] = decode.General,
    [12] = decode.Flowerpot,
    [14] = decode.Mannequin,
    [15] = decode.PvPReservation,
    [18] = decode.SoulPlate,
    [19] = decode.Reflector,
    }
    
local id_mapping = {
    [0] = decode.EmptySlot,
    [4237] = decode.Hourglass,
    [5414] = decode.Lamp,
    }

function extdata.decode(tab)
    if not tab then error('extdata.decode was passed a nil value') end
    if not tab.id or not tonumber(tab.id) then
        error('extdata.decode was passed an invalid id ('..tostring(tab.id)..')',2)
    elseif tab.id ~= 0 and not res.items[tab.id] then
        error('extdata.decode was passed an id that is not yet in the resources ('..tostring(tab.id)..')',2)
    end
    if not tab.extdata or type(tab.extdata)~= 'string' or #tab.extdata ~= 24 then
        error('extdata.decode was passed an invalid extdata string ('..tostring(tab.extdata)..') ID = '..tostring(tab.id),2)
    end
    
    local typ, func
    
    if tab.id ~= 0 then
        typ = res.items[tab.id].type
    end

    local func = id_mapping[tab.id] or typ_mapping[typ] or decode.Unknown
    
    local decoded = func(tab.extdata)
    decoded.__raw = tab.extdata
    return decoded
end

-- Encode currently does nothing
--[[local encode = {}

function extdata.encode(tab)
    if tab and type(tab) == 'table' and tab.type and encode[tab.type] then
        encode[tab.type](tab)
    else
        error('extdata.encode was passed an invalid extdata table',2)
    end
end]]


return extdata