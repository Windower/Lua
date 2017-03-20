include('organizer-lib')

function get_sets()

    sets.TH = {
        hands={ name="Merlinic Dastanas", augments={'"Treasure Hunter"+2',},hp=9,mp=20},
        legs={ name="Merlinic Shalwar", augments={'Pet: Accuracy+16 Pet: Rng. Acc.+16','Pet: Haste+1','"Treasure Hunter"+1','Mag. Acc.+9 "Mag.Atk.Bns."+9',},hp=29,mp=44},
        waist="Chaac Belt",
    }
    
    -- Precast Sets
    sets.precast = {}
    
    sets.precast.FC = {
        ammo="Impatiens",
        head={ name="Merlinic Hood", augments={'"Fast Cast"+7','MND+10','Mag. Acc.+10','"Mag.Atk.Bns."+10',},mp=56,hp=22},
        body={name="Zendik Robe",hp=57,mp=61},
        hands={ name="Merlinic Dastanas", augments={'Mag. Acc.+29','"Fast Cast"+7','INT+1',},mp=20,hp=9},
        legs={ name="Psycloth Lappas", augments={'MP+80','Mag. Acc.+15','"Fast Cast"+7',},mp=109,hp=43},
        feet={ name="Merlinic Crackows", augments={'"Mag.Atk.Bns."+11','"Fast Cast"+7',},hp=4,mp=20},
        neck={ name="Orunmila's Torque",mp=30},
        waist="Witful Belt",
        left_ear={ name="Loquac. Earring",mp=30},
        left_ring="Weather. Ring +1",
        right_ear={name="Etiolation Earring",hp=50,mp=50},
        right_ring={name="Lebeche Ring",mp=40},
        back={ name="Campestres's Cape", augments={'Pet: M.Acc.+20 Pet: M.Dmg.+20','Pet: Mag. Acc.+10','"Fast Cast"+10',}},
    }
    -- 15+13+7+7+12+5+3+2+6+1+10 = 81% FC
    -- 2+3+4+2 = 11% Quickens
    sets.precast['Astral Flow'] = {
        head={ name="Glyphic Horn +1",hp=31,mp=95},
        }
    
    -- Midcast sets
    sets.midcast = {}
    
    sets.midcast.BP = { -- -10 from Gifts
        main={ name="Espiritus", augments={'Enmity-6','Pet: "Mag.Atk.Bns."+30','Pet: Damage taken -4%',}, mp=88},
        ammo="Sancus Sachet +1",
        head={name= "Beckoner's Horn +1",hp=31,mp=134},
        right_ear={name="Evans Earring",mp=50},
        hands={ name="Glyphic Bracers +1", augments={'Inc. Sp. "Blood Pact" magic burst dmg.',},hp=18,mp=41},
        legs={ name="Glyphic Spats +1", augments={'Increases Sp. "Blood Pact" accuracy',},hp=38,mp=85},
    } -- This set technically has too much BP Recast-, but it compensates for times when I lock gear.
    
    sets.midcast['Mana Cede'] = {hands="Beckoner's Bracers +1"}
    
    sets.midcast['Elemental Siphon'] = {
        main="Nirvana",
        sub="Vox Grip",
        ammo="Esper Stone +1",
        neck="Caller's Pendant",
        rear="Smn. Earring",
        lear={ name="Andoaa Earring", mp=30},
        hands={ name="Telchine Gloves", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',},hp=52,mp=44},
        head={ name="Telchine Cap", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',},hp=36,mp=32},
        body={ name="Telchine Chas.", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',},hp=54,mp=59},
        legs={ name="Telchine Braconi", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',},hp=43,mp=29},
        waist={name="Kobo Obi",mp=20},
        lring={name="Evoker's Ring",mp=25},
        rring="Globidonta Ring",
        back={ name="Conveyance Cape", augments={'Summoning magic skill +5','Pet: Enmity+15','Blood Pact Dmg.+4',},mp=100},
        feet={ name="Beckoner's Pigaches +1",hp=9,mp=97},
        day = {
            rring = "Zodiac Ring",
            }
        }
                    
    sets.midcast.Cur = {
        main="Vadose Rod",
        sub="Genbu's Shield",
        head="Marduk's Tiara +1",
        neck={name="Nodens Gorget",hp=25,mp=25},
        ear2="Novia earring",
        hands={name="Revealer's Mitts +1",hp=22,mp=44},
        }
        
    sets.midcast.Stoneskin = {
        neck={name="Nodens Gorget",hp=25,mp=25},
        waist="Siegel Sash",
        legs="Shedir Seraweels"
        }
    
    sets.midcast.Cursna = {
        head={ name="Vanya Hood", augments={'Healing magic skill +20','"Cure" spellcasting time -7%','Magic dmg. taken -3',},hp=36,mp=32},
        body={name="Vanya Robe",hp=54,mp=59},
        hands={name="Hieros Mittens",mp=30},
        legs={ name="Vanya Slops", augments={'Healing magic skill +20','"Cure" spellcasting time -7%','Magic dmg. taken -3',},hp=43,mp=29},
        left_ring="Haoma's Ring",
        right_ring="Haoma's Ring",
        back={name="Oretan. Cape +1",hp=30},
        feet={name="Vanya Clogs",hp=13,mp=14},
        neck="Debilis Medallion",
    }
    
    sets.midcast.EnhancingDuration = {
        main={ name="Gada", augments={'Enh. Mag. eff. dur. +6','"Mag.Atk.Bns."+9',}},
        sub={name="Ammurapi Shield",hp=22,mp=58},
        hands={ name="Telchine Gloves", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',},hp=52,mp=44},
        head={ name="Telchine Cap", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',},hp=36,mp=32},
        body={ name="Telchine Chas.", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',},hp=54,mp=59},
        legs={ name="Telchine Braconi", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',},hp=43,mp=29},
        feet={ name="Telchine Pigaches", augments={'Song spellcasting time -7%','Enh. Mag. eff. dur. +10',}},
    }
    
    sets.midcast.Refresh = set_combine(sets.midcast.EnhancingDuration,{
        head={name="Amalric Coif +1",hp=27,mp=61},
        feet={name="Inspirited Boots",hp=9,mp=20},
        waist="Gishdubar Sash",
        back="Grapevine Cape",
    })
    
    sets.midcast['Diaga'] = sets.TH
    sets.midcast['Dia'] = sets.TH
    sets.midcast['Dia II'] = sets.TH
    sets.midcast['Swipe'] = sets.TH
    sets.midcast['Lunge'] = sets.TH

    -- Pet Midcast Sets
    sets.pet_midcast = {}
    
    sets.BP_Base = {
        main={ name="Espiritus", augments={'Enmity-6','Pet: "Mag.Atk.Bns."+30','Pet: Damage taken -4%',}, mp=88},
        sub="Elan Strap +1",
        ammo="Sancus Sachet +1",
        head={name="Apogee Crown +1",hp=-110,mp=139},
        body={name="Convoker's Doublet +1",hp=50,mp=134},
        hands={ name="Merlinic Dastanas", augments={'Pet: Accuracy+30 Pet: Rng. Acc.+30','Blood Pact Dmg.+9','Pet: INT+9','Pet: "Mag.Atk.Bns."+14',},mp=20,hp=9},
        legs={ name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%',},hp=38,mp=106},
        feet={name="Apogee Pumps +1",hp=-90,mp=121},
        left_ear="Lugalbanda Earring",
        right_ear={name="Gelos Earring",mp=35},
        left_ring="Varar Ring +1",
        right_ring="Varar Ring +1",
    }
    
    sets.pet_midcast.Phys_BP = set_combine(sets.BP_Base,{
        main="Nirvana",
        neck="Shulmanu Collar",
        waist="Klouskap Sash",
        legs={name="Apogee Slacks +1",hp=-110,mp=56},
        back={ name="Campestres's Cape", augments={'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20','Eva.+20 /Mag. Eva.+20','Pet: Haste+10',}},
        })
        
    sets.pet_midcast.MAB_BP = set_combine(sets.BP_Base,{
        neck={name="Adad amulet",hp=25},
        --body={name="Apogee Dalmatica +1",hp=-160,mp=85},
        waist={name="Caller's sash",mp=20},
        ring2={name="Speaker's Ring",mp=40},
        back={ name="Campestres's Cape", augments={'Pet: M.Acc.+20 Pet: M.Dmg.+20','"Fast Cast"+10',}},
        })
        
    sets.pet_midcast.MAB_Spell = set_combine(sets.BP_Base,{
        neck={name="Adad amulet",hp=25},
        --body={name="Apogee Dalmatica +1",hp=-160,mp=85},
        waist={name="Caller's sash",mp=20},
        ring2={name="Speaker's Ring",mp=40},
        right_ring="Globidonta Ring",
        back={ name="Campestres's Cape", augments={'Pet: M.Acc.+20 Pet: M.Dmg.+20','"Fast Cast"+10',}},
        })
        
    sets.pet_midcast.MAcc_BP = set_combine(sets.BP_Base,{
        main="Nirvana",
        sub="Vox Grip",
        neck={name="Adad amulet",hp=25},
        right_ear="Smn. Earring",
        body={name="Beckoner's Doublet +1",hp=54,mp=151},
        hands={name="Lamassu mitts +1",hp=18,mp=44},
        feet={ name="Beckoner's Pigaches +1",hp=9,mp=97},
        lring={name="Evoker's Ring",mp=25},
        right_ring="Globidonta Ring",
        back={ name="Campestres's Cape", augments={'Pet: M.Acc.+20 Pet: M.Dmg.+20','"Fast Cast"+10',}},
        })
    
    sets.pet_midcast.Buff_BP = set_combine(sets.BP_Base,{ -- Did not check
        main="Nirvana",
        sub="Vox Grip",
        head={name= "Beckoner's Horn +1",hp=31,mp=134},
        neck="Caller's Pendant",
        lear={ name="Andoaa Earring", mp=30},
        right_ear="Smn. Earring",
        --body={name="Apogee Dalmatica +1",hp=-160,mp=85},
        hands={ name="Glyphic Bracers +1", augments={'Inc. Sp. "Blood Pact" magic burst dmg.',},hp=18,mp=41},
        legs={name="Assid. Pants +1",hp=43,mp=29},
        lring={name="Evoker's Ring",mp=25},
        right_ring="Globidonta Ring",
        back={ name="Campestres's Cape", augments={'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20','Eva.+20 /Mag. Eva.+20','Pet: Haste+10',}},
        })
    
    sets.pet_midcast['Shock Squall'] = {
        main="Nirvana",
        sub="Vox Grip",
        head={name= "Beckoner's Horn +1",hp=31,mp=134},
        neck={name="Adad amulet",hp=25},
        right_ear="Smn. Earring",
        body={name="Beckoner's Doublet +1",hp=54,mp=151},
        hands={ name="Glyphic Bracers +1", augments={'Inc. Sp. "Blood Pact" magic burst dmg.',},hp=18,mp=41},
        lring={name="Evoker's Ring",mp=25},
        rring="Globidonta Ring",
        back={ name="Campestres's Cape", augments={'Pet: M.Acc.+20 Pet: M.Dmg.+20','"Fast Cast"+10',}},
        legs={ name="Enticer's Pants", augments={'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%',},hp=38,mp=106},
        }
    
    --Aftercast Sets
    sets.aftercast = {}
    
    sets.aftercast.None = {
        main="Mafic Cudgel",
        sub="Genmei Shield",
        head={name= "Beckoner's Horn +1",hp=31,mp=134},
        neck="Loricate Torque +1",
        left_ear={ name="Loquac. Earring",mp=30},
        right_ear={name="Evans Earring",mp=50},
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=50,mp=117},
        hands={ name="Hagondes Cuffs +1", augments={'Phys. dmg. taken -3%','Mag. Acc.+23',},hp=30,mp=22},
        ring1={name="Dark Ring",hp=-20,mp=20},
        ring2="Defending Ring",
        back="Umbra Cape",
        waist="Klouskap Sash",
        legs={name="Assid. Pants +1",hp=43,mp=29},
        feet={name="Herald's Gaiters",mp=12},
        }
    
    -- Including Auto-Refresh II, unaffected by Avatar's Favor:
    -- Carbuncle: 11MP/tick : 10 Perp- + Refresh ideal (4 + Mitts + Refresh)
    -- Diabolos/Celestials: 15MP/tick : 14 Perp- + Refresh ideal
    -- Fenrir: 13MP/tick : 12 Perp- + Refresh ideal
    -- Spirit: 7MP/tick : 6 Perp- + Refresh ideal (Beckoner's Doublet +1)
    
    sets.aftercast.Avatar = {}
    sets.aftercast.Avatar.Carbuncle = {
        main="Nirvana",
        sub="Vox Grip",
        ammo="Sancus Sachet +1",
        head={name= "Beckoner's Horn +1",hp=31,mp=134},
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=50,mp=117},
        hands={name="Asteria Mitts +1",hp=18,mp=44},
        legs={name="Assid. Pants +1",hp=43,mp=29},
        feet={name="Herald's Gaiters",mp=12},
        neck="Shulmanu Collar",
        waist="Lucidity Sash",
        lear={ name="Andoaa Earring", mp=30},
        right_ear={name="Evans Earring",mp=50},
        left_ring="Varar Ring +1",
        right_ring="Defending Ring",
        back={ name="Campestres's Cape", augments={'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20','Eva.+20 /Mag. Eva.+20','Pet: Haste+10',}},
    }
    
    sets.aftercast.Avatar.Garuda = { -- 16 MP/tick, currently negated at -15 Perp with 512 skill
        main="Nirvana",
        sub="Vox Grip",
        ammo="Sancus Sachet +1",
        head={name= "Beckoner's Horn +1",hp=31,mp=134},
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=50,mp=117},
        hands={ name="Glyphic Bracers +1", augments={'Inc. Sp. "Blood Pact" magic burst dmg.',},hp=18,mp=41},
        legs={name="Assid. Pants +1",hp=43,mp=29},
        feet={name="Apogee Pumps +1",hp=-90,mp=121},
        neck="Shulmanu Collar",
        waist="Klouskap Sash",
        lear={ name="Andoaa Earring", mp=30},
        right_ear={name="Evans Earring",mp=50},
        left_ring="Varar Ring +1",
        right_ring="Defending Ring",
        back={ name="Campestres's Cape", augments={'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20','Eva.+20 /Mag. Eva.+20','Pet: Haste+10',}},
    } -- Celestials
    
    sets.aftercast.Avatar.Ifrit = sets.aftercast.Avatar.Garuda
    sets.aftercast.Avatar.Shiva = sets.aftercast.Avatar.Garuda
    sets.aftercast.Avatar.Ramuh = sets.aftercast.Avatar.Garuda
    sets.aftercast.Avatar.Leviathan = sets.aftercast.Avatar.Garuda
    sets.aftercast.Avatar.Titan = sets.aftercast.Avatar.Garuda
    sets.aftercast.Avatar.Diabolos = sets.aftercast.Avatar.Garuda
    
    sets.aftercast.Avatar.Fenrir = { -- ? MP/tick, currently negated at -15 Perp with 512 skill
        main="Nirvana",
        sub="Vox Grip",
        ammo="Sancus Sachet +1",
        head={name= "Beckoner's Horn +1",hp=31,mp=134},
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=50,mp=117},
        hands={ name="Glyphic Bracers +1", augments={'Inc. Sp. "Blood Pact" magic burst dmg.',},hp=18,mp=41},
        legs={name="Assid. Pants +1",hp=43,mp=29},
        feet={name="Apogee Pumps +1",hp=-90,mp=121},
        neck="Shulmanu Collar",
        waist="Klouskap Sash",
        lear={ name="Andoaa Earring", mp=30},
        right_ear={name="Evans Earring",mp=50},
        left_ring="Varar Ring +1",
        right_ring="Defending Ring",
        back={ name="Campestres's Cape", augments={'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20','Eva.+20 /Mag. Eva.+20','Pet: Haste+10',}},
    } -- Fenrir
    sets.aftercast.Avatar['Cait Sith'] = set_combine(sets.aftercast.Avatar.Fenrir,{
        hands={name="Lamassu mitts +1",hp=18,mp=44},
        })
    
    sets.aftercast.Avatar.Spirit = {
        main={ name="Espiritus", augments={'Enmity-6','Pet: "Mag.Atk.Bns."+30','Pet: Damage taken -4%',}, mp=88},
        sub="Vox Grip",
        ammo="Sancus Sachet +1",
        head={name= "Beckoner's Horn +1",hp=31,mp=134},
        body={name="Beckoner's Doublet +1",hp=54,mp=151},
        hands={ name="Glyphic Bracers +1", augments={'Inc. Sp. "Blood Pact" magic burst dmg.',},hp=18,mp=41},
        legs={ name="Glyphic Spats +1", augments={'Increases Sp. "Blood Pact" accuracy',}},
        feet="Marduk's Crackows +1",
        neck="Caller's Pendant",
        waist={name="Caller's sash",mp=20},
        lear={ name="Andoaa Earring", mp=30},
        right_ear="Smn. Earring",
        lring={name="Evoker's Ring",mp=25},
        left_ring="Globidonta Ring",
        back={ name="Conveyance Cape", augments={'Summoning magic skill +5','Pet: Enmity+15','Blood Pact Dmg.+4',},mp=100},
    } -- Spirits
                
    sets.aftercast.Resting = {
        main={name="Numen Staff",mp=45},
        sub="Ariesian Grip",
        ammo={name="Mana Ampulla",mp=20},
        head={name= "Beckoner's Horn +1",hp=31,mp=134},
        neck={name="Eidolon Pendant +1",mp=15},
        ear1="Relaxing Earring",
        ear2={name="Antivenom Earring",mp=15},
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=50,mp=117},
        hands={name="Nares Cuffs",mp=50},-- Not technically accurate
        ring1={name="Celestial Ring",mp=20},
        ring2="Angha Ring",
        back={name="Felicitas Cape +1",mp=15},
        waist="Austerity Belt +1",
        legs={name="Assid. Pants +1",hp=43,mp=29},
        feet={name="Chelona Boots +1",mp=40},
        }
    
    sets.aftercast.Idle = sets.aftercast.None
    
    sets.aftercast.Engaged = {
        body={ name="Hagondes Coat +1", hp=54,mp=59},
        neck="Loricate Torque +1",
        ring1={name="Dark Ring",hp=-20,mp=20},
        hands={ name="Hagondes Cuffs +1", augments={'Phys. dmg. taken -3%','Mag. Acc.+23',},hp=30,mp=22},
        lear="Genmei Earring",
        }
        --[[{
        main="Nirvana",
        sub="Bloodrain Strap",
        head={name= "Beckoner's Horn +1",hp=31,mp=134},
        body="Onca Suit",
        hands=empty,
        legs=empty,
        feet=empty,
        neck="Lissome Necklace",
        waist="Klouskap Sash",
        left_ear="Cessance Earring",
        right_ear="Telos Earring",
        left_ring="Rajas Ring",
        right_ring="Petrov Ring",
        back="Umbra Cape",
    }]]
    
    sets.midcast['Garland of Bliss'] = {
        ammo="Pemphredo Tathlum",
        head={ name="Merlinic Hood", augments={'VIT+8','"Mag.Atk.Bns."+27','Accuracy+5 Attack+5','Mag. Acc.+18 "Mag.Atk.Bns."+18',},mp=56,hp=22},
        body={ name="Merlinic Jubbah", augments={'"Mag.Atk.Bns."+29','Magic burst dmg.+11%','INT+10',},hp=49,mp=67},
        hands={ name="Amalric Gages +1", augments={'MP+80','Mag. Acc.+20','"Mag.Atk.Bns."+20',},hp=13,mp=106},
        legs={ name="Merlinic Shalwar", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','MND+4','Mag. Acc.+15','"Mag.Atk.Bns."+12',},hp=29,mp=44},
        feet={ name="Amalric Nails +1", augments={'MP+80','Mag. Acc.+20','"Mag.Atk.Bns."+20',},hp=4,mp=106},
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear="Friomisi Earring",
        right_ear="Ishvara Earring",
        left_ring="Weather. Ring +1",
        right_ring="Shiva Ring +1",
        back={name="Pahtli Cape",mp=50},
    }
    
    sets.midcast['Elemental Magic'] ={
        main="Marin Staff +1",
        sub="Enki Strap",
        ammo="Pemphredo Tathlum",
        head={ name="Merlinic Hood", augments={'VIT+8','"Mag.Atk.Bns."+27','Accuracy+5 Attack+5','Mag. Acc.+18 "Mag.Atk.Bns."+18',},mp=56,hp=22},
        body="Seidr Cotehardie",
        hands={ name="Amalric Gages +1", augments={'MP+80','Mag. Acc.+20','"Mag.Atk.Bns."+20',},hp=13,mp=106},
        legs={ name="Merlinic Shalwar", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','MND+4','Mag. Acc.+15','"Mag.Atk.Bns."+12',},hp=29,mp=44},
        feet={ name="Amalric Nails +1", augments={'MP+80','Mag. Acc.+20','"Mag.Atk.Bns."+20',},hp=4,mp=106},
        neck={name="Saevus Pendant +1",mp=20},
        waist={name="Yamabuki-no-Obi",mp=35},
        left_ear="Friomisi Earring",
        right_ear="Crematio Earring",
        left_ring="Shiva Ring +1",
        right_ring="Shiva Ring +1",
        back="Toro Cape",
        Ice={main="Ngqoqwanb"},
        Earth={neck={name="Quanpur Necklace",mp=10}}
    }
    
    sets.midcast.Myrkr={
        ammo={name="Ghastly Tathlum +1",mp=35},
        head={name= "Beckoner's Horn +1",hp=31,mp=134},
        body={name="Beckoner's Doublet +1",hp=54,mp=151},
        hands={ name="Amalric Gages +1", augments={'MP+80','Mag. Acc.+20','"Mag.Atk.Bns."+20',},hp=13,mp=106},
        legs={ name="Psycloth Lappas", augments={'MP+80','Mag. Acc.+15','"Fast Cast"+7',},mp=109,hp=43},
        feet={name="Apogee Pumps +1",hp=-90,mp=121},
        neck={name="Sanctity Necklace",hp=35,mp=35},
        waist={name="Mujin Obi",mp=60},
        left_ear={name="Etiolation Earring",hp=50,mp=50},
        right_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +25',}},
        left_ring={name="Lebeche Ring",mp=40},
        right_ring={name="Sangoma Ring",mp=70},
        back={ name="Conveyance Cape", augments={'Summoning magic skill +5','Pet: Enmity+15','Blood Pact Dmg.+4',},mp=100},
    }
    
    -- Variables and notes to myself
    Debuff_BPs = T{'Diamond Storm','Sleepga','Slowga','Tidal Roar','Shock Squall','Nightmare','Pavor Nocturnus','Ultimate Terror','Somnolence','Lunar Cry','Lunar Roar'}
    Magical_BPs = T{'Heavenly Strike','Wind Blade','Holy Mist','Night Terror','Thunderstorm','Geocrush','Meteor Strike','Grand Fall','Lunar Bay','Thunderspark','Nether Blast',
        'Aerial Blast','Searing Light','Diamond Dust','Earthen Fury','Zantetsuken','Tidal Wave','Judgment Bolt','Inferno','Howling Moon','Ruinous Omen'}
    Additional_effect_BPs = T{'Rock Throw'}    
    AvatarList = S{'Shiva','Ramuh','Garuda','Leviathan','Diabolos','Titan','Fenrir','Ifrit','Carbuncle',
        'Fire Spirit','Air Spirit','Ice Spirit','Thunder Spirit','Light Spirit','Dark Spirit','Earth Spirit','Water Spirit',
        'Cait Sith','Alexander','Odin','Atomos'}
    send_command('input /macro book 8;wait .1;input /macro set 1')
end

function pet_change(pet,gain)
    equip_aftercast(player.status,pet)
    if player.mpp > 80 then
        set_priorities('mp','hp')
    else
        set_priorities('hp','mp')
    end
end

function pet_status_change(a,b)
    windower.add_to_chat(8,'Pet status change: '..tostring(a)..' '..tostring(b)) -- Useful for knowing when you got aggroed
end

function precast(spell)
    if spell.action_type == 'Magic' then
        equip(sets.precast.FC)
    end
    
    if sets.precast.FC[spell.element] then equip(sets.precast.FC[spell.element]) end
    if player.mpp > 80 then
        set_priorities('mp','hp')
    else
        set_priorities('hp','mp')
    end
end

function midcast(spell)
    if pet_midaction() then
        return
    end
    equip_aftercast(player.status,pet) -- Put DT gear on
    if string.find(spell.type,'BloodPact') then
        if buffactive['Astral Conduit'] then
            pet_midcast(spell)
        else
            equip(sets.midcast.BP)
        end
    elseif string.find(spell.english,'Cur') then
        equip(sets.midcast.Cur)
    elseif sets.midcast[spell.english] then
        equip(sets.midcast[spell.english])
        if spell.english == 'Elemental Siphon' then
            if pet.element and pet.element == world.day_element and world.day_element ~= "Light" and world.day_element ~= 'Dark' then
                equip(sets.midcast['Elemental Siphon'].day) -- Zodiac Ring affects Siphon, but only on Fires-Lightningsday
            end
        end
    elseif spell.skill == 'Elemental Magic' then
        equip(sets.midcast['Elemental Magic'])
        if sets.midcast['Elemental Magic'][spell.element] then
            equip(sets.midcast['Elemental Magic'][spell.element])
        end
        if world.day_element == spell.element or world.weather_element == spell.element then
            equip({waist="Hachirin-no-Obi"})
        end
    elseif spell.skill == 'Enhancing Magic' then
        equip(sets.midcast.EnhancingDuration)
    end
    if player.mpp > 80 then
        set_priorities('mp','hp')
    else
        set_priorities('hp','mp')
    end
end

function aftercast(spell)
    if pet_midaction() then
        return
    elseif spell and string.find(spell.type,'BloodPact') and not spell.interrupted then
        pet_midcast(spell)
    else
        -- Don't want to swap away too quickly if I'm about to put BP damage gear on
        -- Need to wait 1 in order to allow pet information to update on Release.
        equip_aftercast(player.status,pet)
    end
    if player.mpp > 80 then
        set_priorities('mp','hp')
    else
        set_priorities('hp','mp')
    end
end

function status_change(new,old)
    equip_aftercast(new,pet)
    if player.mpp > 80 then
        set_priorities('mp','hp')
    else
        set_priorities('hp','mp')
    end
end

function pet_midcast(spell)
    if spell.name == 'Perfect Defense' then
        equip(sets.midcast['Elemental Siphon'],{feet="Marduk's Crackows +1"})
    elseif spell.type=='BloodPactWard' then
        if Debuff_BPs:contains(spell.name) then
            equip(sets.pet_midcast.MAcc_BP)
        else
            equip(sets.pet_midcast.Buff_BP)
        end
    elseif spell.type=='BloodPactRage' then
        if Magical_BPs:contains(spell.name) or string.find(spell.name,' II') or string.find(spell.name,' IV') then
            equip(sets.pet_midcast.MAB_BP)
        elseif Additional_effect_BPs:contains(spell.name) then -- for BPs where the additional effect matters more than the damage
            equip(sets.pet_midcast.MAcc_BP)
        else
            equip(sets.pet_midcast.Phys_BP)
        end
    elseif spell.type=='BlackMagic' then
        equip(sets.pet_midcast.MAB_Spell)
    end
    if player.mpp > 80 then
        set_priorities('mp','hp')
    else
        set_priorities('hp','mp')
    end
end

function pet_aftercast(spell)
    windower.add_to_chat(8,'pet_aftercast: '..tostring(spell.name))
    equip_aftercast(player.status,pet)
    if player.mpp > 80 then
        set_priorities('mp','hp')
    else
        set_priorities('hp','mp')
    end
end

function self_command(command)
    if command == 'Idle' then
        equip_aftercast('Idle',pet)
    end
    
    if player.mpp > 80 then
        set_priorities('mp','hp')
    else
        set_priorities('hp','mp')
    end
end

function equip_aftercast(status,pet)
    if sets.aftercast[status] then
        equip(sets.aftercast[status])
    end
    if pet.isvalid then
        if string.find(pet.name,'Spirit') then
            equip(sets.aftercast.Avatar.Spirit)
        elseif sets.aftercast.Avatar[pet.name] then
            equip(sets.aftercast.Avatar[pet.name])
        end
    end
    if status == "Engaged" then
        equip(sets.aftercast[status])
    end
end

function set_priorities(key1,key2)
    local future,current = gearswap.equip_list,gearswap.equip_list_history
    function get_val(piece,key)
        if piece and type(piece)=='table' and piece[key] and type(piece[key])=='number' then
            return piece[key]
        end
        return 0
    end
    local diff = {}
    for i,v in pairs(future) do
        local priority = get_val(future[i],key1) - get_val(current[i],key1) + (get_val(future[i],key2) - get_val(current[i],key2))
        if type(v) == 'table' then
            future[i].priority = priority
        else
            future[i] = {name=v,priority=priority}
        end
    end
end