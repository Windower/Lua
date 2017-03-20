include('organizer-lib')

function get_sets()
    mp_efficiency = 0
    macc_level = 0
    
    sets.TH = {
        hands={ name="Merlinic Dastanas", augments={'"Treasure Hunter"+2',},hp=9,mp=20},
        legs={ name="Merlinic Shalwar", augments={'Pet: Accuracy+16 Pet: Rng. Acc.+16','Pet: Haste+1','"Treasure Hunter"+1','Mag. Acc.+9 "Mag.Atk.Bns."+9',},hp=29,mp=44},
        waist="Chaac Belt",
    }
    
    sets.precast = {}
    
    
    sets.precast.FastCast = {}
    
    sets.precast.FastCast.Default = {
        main="Marin Staff +1",
        ammo="Impatiens",
        head={ name="Merlinic Hood", augments={'"Fast Cast"+7','MND+10','Mag. Acc.+10','"Mag.Atk.Bns."+10',},hp=22,mp=56},
        neck={name="Orunmila's Torque",mp=30},
        ear1="Enchanter Earring +1",
        ear2={name="Loquacious Earring",mp=30},
        body={ name="Zendik Robe",hp=57,mp=61},
        hands={ name="Merlinic Dastanas", augments={'Mag. Acc.+29','"Fast Cast"+7','INT+1',},hp=9,mp=20},
        lring="Kishar Ring",
        rring="Weather. Ring +1",
        back={ name="Taranus's Cape", augments={'Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',},mp=78},
        waist="Witful Belt",
        legs={name="Psycloth Lappas",hp=43,mp=109},
        feet={ name="Merlinic Crackows", augments={'"Mag.Atk.Bns."+11','"Fast Cast"+7',},hp=4,mp=20},
    }
    
    sets.precast.FastCast.Death = set_combine(sets.precast.FastCast.Default,{
        ammo={name="Ghastly Tathlum +1",mp=35},
        head={ name="Merlinic Hood", augments={'"Fast Cast"+7','MND+10','Mag. Acc.+10','"Mag.Atk.Bns."+10',},hp=22,mp=56},
        neck={name="Orunmila's Torque",mp=30},
        ear1={name="Etiolation Earring",hp=50,mp=50},
        ear2={name="Loquacious Earring",mp=30},
        body={ name="Zendik Robe",hp=57,mp=61},
        hands={ name="Merlinic Dastanas", augments={'Mag. Acc.+29','"Fast Cast"+7','INT+1',},hp=9,mp=20},
        lring="Kishar Ring",
        rring={name="Sangoma Ring",mp=70},
        back={ name="Taranus's Cape", augments={'Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',},mp=78},
        waist={name="Mujin Obi",mp=60},
        legs={name="Psycloth Lappas",hp=43,mp=109},
        feet={ name="Amalric Nails +1", hp=4,mp=106},
    })
    
    sets.precast.FastCast['Elemental Magic'] = set_combine(sets.precast.FastCast.Default,{
        ear1={name="Barkarole Earring",mp=25},
        body={ name="Dalmatica +1", augments={'Occ. quickens spellcasting +3%','"Fast Cast"+6','Pet: "Mag.Def.Bns."+6',},hp=-55,mp=55},
    })
    
    sets.precast.FastCast['Enhancing Magic'] = set_combine(sets.precast.FastCast.Default,{waist="Siegel Sash"})
    
    sets.precast.Cure = set_combine(sets.precast.FastCast.Default,{body="Heka's Kalasiris",
        back={name="Pahtli Cape",mp=50},
        legs={name="Doyen Pants",hp=43,mp=32},
        lear={name="Mendicant's Earring",mp=30},
        })
    sets.precast.Stoneskin = set_combine(sets.precast.FastCast['Enhancing Magic'],{
        legs={name="Doyen Pants",hp=43,mp=32},
        })
    
    sets.precast.Manafont = {body={name="Archmage's Coat +1",hp=54,mp=59}}
    
    sets.Impact = {head=empty,body={name="Twilight Cloak",mp=75},legs={name="Perdition Slops",hp=73,mp=59}}
    
    sets.midcast = {}
    
    sets.midcast.magic_base = {
        main="Laevateinn",
        sub="Enki Strap",
        ammo={name="Mana Ampulla",mp=20},
        head={ name="Merlinic Hood", augments={'"Mag.Atk.Bns."+28','"Fast Cast"+3','"Refresh"+1','Mag. Acc.+6 "Mag.Atk.Bns."+6',},hp=22,mp=56},
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=50,mp=117},
        hands={ name="Hagondes Cuffs +1", augments={'Phys. dmg. taken -3%','Mag. Acc.+23',},hp=30,mp=22},
        legs={ name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=43,mp=29},
        feet={name="Herald's Gaiters",mp=12},
        neck="Incanter's Torque",
        waist="Austerity Belt +1",
        lear={name="Mendicant's Earring",mp=30},
        right_ear="Dignitary's Earring",
        left_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',},hp=-20,mp=20},
        right_ring="Defending Ring",
        back="Umbra Cape",
    }
    
    sets.midcast.Stun = {main="Laevateinn",
        sub="Enki strap",
        ammo={name="Hydrocera",mp=20},
        head={ name="Merlinic Hood", augments={'"Fast Cast"+7','MND+10','Mag. Acc.+10','"Mag.Atk.Bns."+10',},hp=22,mp=56},
        neck="Erra Pendant",
        ear1="Enchanter Earring +1",
        ear2="Dignitary's Earring",
        body={name="Psycloth Vest",hp=54,mp=59},
        hands={ name="Merlinic Dastanas", augments={'Mag. Acc.+29','"Fast Cast"+7','INT+1',},hp=9,mp=20},
        lring={name="Sangoma Ring",mp=70},
        rring="Shiva Ring +1",
        back={ name="Taranus's Cape", augments={'Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',},mp=78},
        waist="Ninurta's Sash",
        legs={ name="Merlinic Shalwar", augments={'"Mag.Atk.Bns."+30','"Occult Acumen"+10','INT+9','Mag. Acc.+5',},hp=29,mp=44},
        feet={name="Artsieq Boots",hp=13,mp=44},
    }
    
    sets.midcast['Elemental Magic'] = {
        [0] = {},
        [1] = {}
        }
        
    sets.ElementalMagicMAB = {
            Earth={neck={name="Quanpur Necklace", mp=10}},
            Dark={
                head={ name="Pixie Hairpin +1", hp=-35,mp=120},
                rring="Archon Ring",
            }
        }
    
    -- MAcc level 0 (Macc and Enmity irrelevant)
    sets.midcast['Elemental Magic'][0][0] = {
        main="Laevateinn",
        sub="Enki Strap",
        ammo="Pemphredo Tathlum",
        head={ name="Merlinic Hood", augments={'VIT+8','"Mag.Atk.Bns."+27','Accuracy+5 Attack+5','Mag. Acc.+18 "Mag.Atk.Bns."+18',},hp=22,mp=56},
        neck="Baetyl Pendant",
        ear1={name="Barkarole Earring",mp=25},
        ear2="Friomisi Earring",
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=50,mp=117},
        hands={name="Amalric Gages +1",hp=13,mp=106},
        ring1="Shiva Ring +1",
        ring2="Shiva Ring +1",
        back={ name="Taranus's Cape", augments={'INT+20','System: 1 ID: 80 Val: 19','"Mag.Atk.Bns."+10',}},
        waist={name="Yamabuki-no-Obi",mp=35},
        legs={ name="Merlinic Shalwar", augments={'"Mag.Atk.Bns."+30','"Occult Acumen"+10','INT+9','Mag. Acc.+5',},hp=29,mp=44},
        feet={ name="Amalric Nails +1", hp=4,mp=106},
        }
        
    sets.midcast.MB={
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','Magic burst dmg.+11%','INT+1','Mag. Acc.+8',},hp=22,mp=56},
        body={ name="Merlinic Jubbah", augments={'"Mag.Atk.Bns."+29','Magic burst dmg.+11%','INT+10',},hp=41,mp=67},
        legs={ name="Merlinic Shalwar", augments={'"Mag.Atk.Bns."+26','Magic burst dmg.+11%','INT+10','Mag. Acc.+13',},hp=29,mp=44},
        hands={name="Amalric Gages +1",hp=13,mp=106},
        neck="Mizu. Kubikazari",
        right_ring="Mujin Band",
    }
    
    --sets.midcast['Elemental Magic'][0][0] = set_combine(sets.midcast['Elemental Magic'][0][0],sets.midcast.MB)
    
    sets.midcast['Elemental Magic'][0][1] = set_combine(sets.midcast['Elemental Magic'][0][0],{
        body={name="Spaekona's Coat +2",hp=81,mp=88}
        })
    
    -- MAcc level 1 (MAcc and Enmity relevant)
    sets.midcast['Elemental Magic'][1][0] = {main="Laevateinn",
        sub="Enki Strap",
        ammo="Pemphredo Tathlum",
        head={ name="Merlinic Hood", augments={'VIT+8','"Mag.Atk.Bns."+27','Accuracy+5 Attack+5','Mag. Acc.+18 "Mag.Atk.Bns."+18',},hp=22,mp=56},
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=50,mp=117},
        hands={name="Amalric Gages +1",hp=13,mp=106},
        legs={ name="Merlinic Shalwar", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','MND+4','Mag. Acc.+15','"Mag.Atk.Bns."+12',},hp=29,mp=44},
        feet={ name="Amalric Nails +1", hp=4,mp=106},
        neck={name="Sanctity Necklace",hp=35,mp=35},
        waist={name="Acuity Belt +1", mp=35},
        ear2="Novia Earring",
        ear1={name="Barkarole Earring",mp=25},
        ring1="Shiva Ring +1",
        ring2="Shiva Ring +1",
        back={ name="Taranus's Cape", augments={'INT+20','System: 1 ID: 80 Val: 19','"Mag.Atk.Bns."+10',}},
    }
                
    sets.midcast['Elemental Magic'][1][1] = set_combine(sets.midcast['Elemental Magic'][1][0],{
        body={name="Spaekona's Coat +2",hp=81,mp=88}
        })
    
    sets.midcast.Death = {
        main="Laevateinn",
        sub={name="Niobid Strap",mp=20},
        ammo={name="Ghastly Tathlum +1",mp=35},
        head={ name="Pixie Hairpin +1", hp=-35,mp=120},
        body={ name="Merlinic Jubbah", augments={'"Mag.Atk.Bns."+29','Magic burst dmg.+11%','INT+10',},hp=41,mp=67},
        hands={name="Amalric Gages +1",hp=13,mp=106},
        legs={ name="Merlinic Shalwar", augments={'"Mag.Atk.Bns."+26','Magic burst dmg.+11%','INT+10','Mag. Acc.+13',},hp=29,mp=44},
        feet={ name="Amalric Nails +1", hp=4,mp=106},
        neck="Mizu. Kubikazari",
        waist={name="Mujin Obi",mp=60},
        ear2={name="Etiolation Earring",hp=50,mp=50},
        ear1={name="Barkarole Earring",mp=25},
        left_ring="Archon Ring",
        right_ring="Mujin Band",
        back={ name="Taranus's Cape", augments={'Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',},mp=78},
    }
    sets.midcast['Dia II'] = sets.TH
    sets.midcast.Dia = sets.TH
    sets.midcast.Diaga = sets.TH
    sets.midcast.Burn = sets.TH
                
    
    sets.midcast['Dark Magic'] = {
        main={ name="Rubicundity", augments={'Mag. Acc.+10','"Mag.Atk.Bns."+10','Dark magic skill +10','"Conserve MP"+7',}},
        sub="Genmei Shield",
        ammo="Hasty Pinion +1",
        head={ name="Pixie Hairpin +1", hp=-35,mp=120},
        body={name="Psycloth Vest",hp=54,mp=59},
        hands={name="Amalric Gages +1",hp=13,mp=106},
        legs={ name="Merlinic Shalwar", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','MND+4','Mag. Acc.+15','"Mag.Atk.Bns."+12',},hp=29,mp=44},
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+21','"Drain" and "Aspir" potency +11','INT+1',},hp=4,mp=20},
        neck="Erra Pendant",
        waist="Ninurta's Sash",
        left_ear={name="Hirudinea Earring",hp=-5,mp=-5},
        right_ear={name="Loquac. Earring",mp=30},
        left_ring="Evanescence Ring",
        right_ring="Archon Ring",
        back={ name="Taranus's Cape", augments={'Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',},mp=78},
    }
    
    sets.midcast['Enfeebling Magic'] = {
        main="Laevateinn",
        sub="Enki Strap",
        ammo="Pemphredo Tathlum",
        head={name="Amalric Coif +1",hp=27,mp=61},
        neck="Erra Pendant",
        ear1="Enchanter Earring +1",
        ear2="Dignitary's Earring",
        body={name="Zendik Robe",hp=57,mp=61},
        hands={ name="Hagondes Cuffs +1", augments={'Phys. dmg. taken -3%','Mag. Acc.+23',},hp=30,mp=22},
        lring={name="Sangoma Ring",mp=70},
        ring2="Weather. Ring +1",
        back={ name="Taranus's Cape", augments={'INT+20','System: 1 ID: 80 Val: 19','"Mag.Atk.Bns."+10',}},
        waist={name="Luminary Sash",mp=45},
        legs={name="Psycloth Lappas",hp=43,mp=109},
        feet={name="Artsieq Boots",hp=13,mp=44},
        }
        
    sets.midcast.Vidohunir = {
        ammo="Pemphredo Tathlum",
        head={ name="Pixie Hairpin +1", hp=-35,mp=120},
        neck={name="Saevus Pendant +1",mp=20},
        ear1={name="Barkarole Earring",mp=25},
        ear2="Friomisi Earring",
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=50,mp=117},
        hands={name="Amalric Gages +1",hp=13,mp=106},
        lring="Shiva Ring +1",
        rring="Archon Ring",
        back={ name="Taranus's Cape", augments={'INT+20','System: 1 ID: 80 Val: 19','"Mag.Atk.Bns."+10',}},
        waist={name="Acuity Belt +1", mp=35},
        legs={ name="Merlinic Shalwar", augments={'"Mag.Atk.Bns."+30','"Occult Acumen"+10','INT+9','Mag. Acc.+5',},hp=29,mp=44},
        feet={ name="Amalric Nails +1", hp=4,mp=106},
        }
    
    sets.midcast.Myrkr = {
        ammo={name="Ghastly Tathlum +1",mp=35},
        head={ name="Pixie Hairpin +1", hp=-35,mp=120},
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=50,mp=117},
        hands={name="Amalric Gages +1",hp=13,mp=106},
        legs={ name="Psycloth Lappas", augments={'MP+80','Mag. Acc.+15','"Fast Cast"+7',},hp=43,mp=109},
        feet={name="Artsieq Boots",hp=13,mp=44},
        neck={name="Sanctity Necklace",hp=35,mp=35},
        waist={name="Mujin Obi",mp=60},
        ear1={name="Etiolation Earring",hp=50,mp=50},
        right_ear={name="Gifted Earring",mp=45},
        rring={name="Sangoma Ring",mp=70},
        right_ring={name="Lebeche Ring",mp=40},
        back={ name="Taranus's Cape", augments={'Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',},mp=78},
    }
    
    sets.midcast.Cure = {
        main="Vadose Rod",
        sub="Genmei Shield",
        ammo={name="Mana Ampulla",mp=20},
        head={name="Amalric Coif +1",hp=27,mp=61},
        neck="Phalaina Locket",
        lear={name="Mendicant's Earring",mp=30},
        rear="Novia Earring",
        body="Heka's Kalasiris",
        hands={name="Revealer's Mitts +1",hp=22,mp=44},
        lring={name="Sangoma Ring",mp=70},
        right_ring={name="Lebeche Ring",mp=40},
        back={name="Pahtli Cape",mp=50},
        waist={name="Luminary Sash",mp=45},
        legs={ name="Merlinic Shalwar", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','MND+4','Mag. Acc.+15','"Mag.Atk.Bns."+12',},hp=29,mp=44},
        feet={name="Wicce Sabots +1",hp=9,mp=20},
        }
        
    
    sets.midcast.EnhancingDuration = {
        main={ name="Gada", augments={'Enh. Mag. eff. dur. +6','"Mag.Atk.Bns."+9',}},
        sub={name="Ammurapi Shield",hp=22,mp=58},
        hands={ name="Telchine Gloves", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',},hp=52,mp=44},
        head={ name="Telchine Cap", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',},hp=36,mp=32,},
        body={ name="Telchine Chas.", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',},hp=54,mp=59},
        legs={ name="Telchine Braconi", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',},hp=43,mp=29},
        feet={ name="Telchine Pigaches", augments={'Song spellcasting time -7%','Enh. Mag. eff. dur. +10',},hp=13,mp=44},
    }
    
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration,{
        neck={name="Nodens Gorget",hp=25,mp=25},
        waist="Siegel Sash",
        legs="Shedir Seraweels"
        })
    
    sets.midcast.Aquaveil = set_combine(sets.midcast.EnhancingDuration,{
        main="Vadose Rod",
        head={name="Amalric Coif +1",hp=27,mp=61},
        sub="Genmei Shield",
        waist={name="Emphatikos Rope",mp=20},
        legs="Shedir Seraweels"
        })
    
    sets.midcast.Refresh = set_combine(sets.midcast.EnhancingDuration,{
        head={name="Amalric Coif +1",hp=27,mp=61},
        back="Grapevine Cape",
        feet={name="Inspirited Boots",hp=9,mp=20},
        })
    
    sets.midcast.Phalanx = set_combine(sets.midcast.EnhancingDuration,{})
    
    sets.aftercast = {}
    sets.aftercast.Idle = {}
    sets.aftercast.Idle.keys = {[0]="Refresh",[1]="PDT"}
    sets.aftercast.Idle.ind = 0
--[[    sets.aftercast.Idle[0] = {
        main="Laevateinn",
        sub={name="Niobid Strap",mp=20},
        ammo={name="Ghastly Tathlum +1",mp=35},
        head={ name="Merlinic Hood", augments={'"Mag.Atk.Bns."+28','"Fast Cast"+3','"Refresh"+1','Mag. Acc.+6 "Mag.Atk.Bns."+6',},hp=22,mp=56},
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=50,mp=117},
        hands={name="Amalric Gages +1",hp=13,mp=106},
        legs={ name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=43,mp=29},
        feet={ name="Amalric Nails +1", hp=4,mp=106},
        neck="Loricate Torque +1",
        waist={name="Mujin Obi",mp=60},
        ear1={name="Etiolation Earring",hp=50,mp=50},
        right_ear={name="Gifted Earring",mp=45},
        left_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',},hp=-20,mp=20},
        right_ring="Defending Ring",
        back={ name="Bane Cape", augments={'Elem. magic skill +3','Dark magic skill +7','"Mag.Atk.Bns."+1','"Fast Cast"+5',}},
    }]]
    sets.aftercast.Idle[0] = {
        main="Mafic Cudgel",
        sub="Genmei Shield",
        ammo={name="Mana Ampulla",mp=20},
        head={ name="Merlinic Hood", augments={'"Mag.Atk.Bns."+28','"Fast Cast"+3','"Refresh"+1','Mag. Acc.+6 "Mag.Atk.Bns."+6',},hp=22,mp=56},
        neck="Loricate Torque +1",
        ear1={name="Etiolation Earring",hp=50,mp=50},
        ear2="Sorcerer's Earring",
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=50,mp=117},
        hands={ name="Merlinic Dastanas", augments={'VIT+8','Attack+18','"Refresh"+1','Accuracy+17 Attack+17','Mag. Acc.+7 "Mag.Atk.Bns."+7',},hp=9,mp=20},
        left_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',},hp=-20,mp=20},
        ring2="Defending Ring",
        back="Umbra Cape",
        waist={name="Mujin Obi",mp=60},
        legs={ name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=43,mp=29},
        feet={name="Herald's Gaiters",mp=12},
        }
        
    sets.aftercast.Idle[1] = {
        main="Mafic Cudgel",
        sub="Genmei Shield",
        ammo={name="Mana Ampulla",mp=20},
        head={ name="Hagondes Hat +1", augments={'Phys. dmg. taken -3%','Magic dmg. taken -2%','"Mag.Atk.Bns."+26',},hp=36,mp=32},
        neck="Loricate Torque +1",
        ear1="Telos Earring",
        ear1={name="Etiolation Earring",hp=50,mp=50},
        body={name="Hagondes Coat +1",hp=54,mp=59},
        hands={ name="Hagondes Cuffs +1", augments={'Phys. dmg. taken -3%','Mag. Acc.+23',},hp=30,mp=22},
        left_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',},hp=-20,mp=20},
        ring2="Defending Ring",
        back="Umbra Cape",
        waist="Ninurta's Sash",
        legs={ name="Hagondes Pants +1", augments={'Phys. dmg. taken -4%','Magic dmg. taken -4%','Magic burst dmg.+10%',},hp=43,mp=29},
        feet={name="Battlecast Gaiters",hp=13},
        }
        
    sets.aftercast.Idle['Mana Wall'] = {
        back={ name="Taranus's Cape", augments={'Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',},mp=78},
        feet={name="Wicce Sabots +1",hp=9,mp=20},
        }
                
    sets.aftercast.Resting = {
        main={name="Numen Staff",mp=45},
        sub="Oneiros Grip",
        ammo={name="Mana Ampulla",mp=20},
        head={ name="Merlinic Hood", augments={'"Mag.Atk.Bns."+28','"Fast Cast"+3','"Refresh"+1','Mag. Acc.+6 "Mag.Atk.Bns."+6',},hp=22,mp=56},
        neck={name="Eidolon Pendant +1",mp=15},
        ear1="Relaxing Earring",
        ear2={name="Antivenom Earring",mp=15},
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=50,mp=117},
        hands={name="Nares Cuffs",mp=48}, -- MP+3%
        ring1={name="Celestial Ring",mp=20},
        ring2="Angha Ring",
        back={name="Felicitas Cape +1",mp=15},
        waist="Austerity Belt +1",
        legs={ name="Lengo Pants", augments={'INT+10','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',},hp=43,mp=29},
        feet={name="Chelona Boots +1",mp=40},
        }
                
    sets.aftercast.Engaged = {
        main="Mafic Cudgel",
        sub="Genmei Shield",
        head={ name="Hagondes Hat +1", augments={'Phys. dmg. taken -3%','Magic dmg. taken -2%','"Mag.Atk.Bns."+26',},hp=36,mp=32},
        neck="Loricate Torque +1",
        ear2="Brutal Earring",
        ear1={name="Etiolation Earring",hp=50,mp=50},
        --body="Onca Suit",hands=empty,
        left_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',},hp=-20,mp=20},
        ring2="Defending Ring",
        --back="Umbra Cape",waist="Ninurta's Sash",legs=empty,feet=empty}
        body={name="Hagondes Coat +1",hp=54,mp=59},
        hands={ name="Hagondes Cuffs +1", augments={'Phys. dmg. taken -3%','Mag. Acc.+23',},hp=30,mp=22},
        left_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',},hp=-20,mp=20},
        ring2="Defending Ring",
        back="Umbra Cape",
        waist="Ninurta's Sash",
        legs={ name="Hagondes Pants +1", augments={'Phys. dmg. taken -4%','Magic dmg. taken -4%','Magic burst dmg.+10%',},hp=43,mp=29},
        feet={name="Battlecast Gaiters",hp=13},
        }
    
    sets.Obis = {}
    sets.Obis.Fire = {waist='Hachirin-no-Obi'}
    sets.Obis.Earth = {waist='Hachirin-no-Obi'}
    sets.Obis.Water = {waist='Hachirin-no-Obi'}
    sets.Obis.Wind = {waist='Hachirin-no-Obi'}
    sets.Obis.Ice = {waist='Hachirin-no-Obi'}
    sets.Obis.Lightning = {waist='Hachirin-no-Obi'}
    sets.Obis.Light = {waist='Hachirin-no-Obi'}
    sets.Obis.Dark = {waist='Hachirin-no-Obi'}
    sets.Zodiac = {lring={name="Zodiac Ring",mp=25}}
    
    sets.aftercast.empty = {neck="Loricate Torque +1"}
    sets.aftercast.Chry = {neck={name="Chrysopoeia Torque",mp=30}}
    tp_level = 'empty'
    
    stuntarg = 'Shantotto'
    send_command('input /macro book 2;wait .1;input /macro set 1')
end

windower.register_event('tp change',function(new,old)
    if new > 2990 then
        tp_level = 'Chry'
    else
        tp_level = 'empty'
    end
    if not midaction() then
        if sets.aftercast[player.status] then
            equip(sets.aftercast[player.status],sets.aftercast[tp_level])
        else
            equip(sets.aftercast.Idle,sets.aftercast[tp_level])
        end
    end
    set_priorities('mp','hp')
end)

function precast(spell)
    if sets.precast[spell.english] then
        equip(sets.precast[spell.english][macc_level] or sets.precast[spell.english])
    elseif string.find(spell.english,'Cur') and spell.english ~='Cursna' then 
        equip(sets.precast.Cure)
    elseif spell.english == 'Impact' then
        equip(sets.precast.FastCast['Elemental Magic'],sets.Impact)
        if not buffactive['Elemental Seal'] then
            add_to_chat(8,'--------- Elemental Seal is down ---------')
        end
    elseif spell.action_type == 'Magic' then
        if spell.skill == 'Elemental Magic' then
            equip(sets.precast.FastCast['Elemental Magic'])
        elseif spell.skill == 'Enhancing Magic' then
            equip(sets.precast.FastCast['Enhancing Magic'])
        else
            equip(sets.precast.FastCast.Default)
        end
    end
    
    if spell.english == 'Stun' and stuntarg ~= 'Shantotto' then
        send_command('@input /t '..stuntarg..' ---- Byrth Stunned!!! ---- ')
    end
    set_priorities('mp','hp')
end

function midcast(spell)
    equip_idle_set()
    if buffactive.manawell or spell.mppaftercast > 50 then
        mp_efficiency = 0
    else
        mp_efficiency = 1
    end
    
    if spell.action_type == 'Magic' then
        equip(sets.midcast.magic_base)
    end
    
    if string.find(spell.english,'Cur') and spell.english ~='Cursna' then 
        weathercheck(spell.element,sets.midcast.Cure)
    elseif spell.english == 'Impact' then
        weathercheck(spell.element,set_combine(sets.midcast['Elemental Magic'][macc_level][mp_efficiency],sets.Impact))
    elseif spell.english == 'Death' then
        equip(sets.midcast.Death)
    elseif sets.midcast[spell.name] then
        weathercheck(spell.element,sets.midcast[spell.name])
    elseif spell.skill == 'Elemental Magic' then
        weathercheck(spell.element,sets.midcast['Elemental Magic'][macc_level][mp_efficiency])
        zodiaccheck(spell.element)
        if sets.ElementalMagicMAB[spell.element] then
            equip(sets.ElementalMagicMAB[spell.element])
        end
    elseif spell.skill == "Enhancing Magic" and not S{'Warp','Warp II','Retrace','Teleport-Holla','Teleport-Mea','Teleport-Dem','Teleport-Altep','Teleport-Vahzl','Teleport-Yhoat'}:contains(spell.english) then
        equip(sets.midcast.EnhancingDuration)
    elseif spell.skill then
        equip(sets.aftercast.Idle,sets.aftercast[tp_level])
        weathercheck(spell.element,sets.midcast[spell.skill])
    end
    
    if spell.english == 'Sneak' and spell.target.name == player.name then
        send_command('cancel 71;')
    end
    set_priorities('mp','hp')
end

function aftercast(spell)
    if player.status == 'Idle' then
        equip_idle_set()
    elseif sets.aftercast[player.status] then
        equip(sets.aftercast[player.status],sets.aftercast[tp_level])
    else
        equip(sets.aftercast.Idle,sets.aftercast[tp_level])
    end
    if not spell.interrupted then
        if spell.english == 'Sleep' or spell.english == 'Sleepga' then
            send_command('@wait 55;input /echo ------- '..spell.english..' is wearing off in 5 seconds -------')
        elseif spell.english == 'Sleep II' or spell.english == 'Sleepga II' then
            send_command('@wait 85;input /echo ------- '..spell.english..' is wearing off in 5 seconds -------')
        elseif spell.english == 'Break' or spell.english == 'Breakga' then
            send_command('@wait 25;input /echo ------- '..spell.english..' is wearing off in 5 seconds -------')
        end
    end
    set_priorities('mp','hp')
end

function status_change(new,old)
    if new == 'Resting' then
        equip(sets.aftercast.Resting)
    elseif new == 'Engaged' then
        if not midaction() then
            equip(sets.aftercast.Engaged,sets.aftercast[tp_level])
        end
        disable('main','sub')
    else
        equip_idle_set()
        equip(sets.aftercast[tp_level])
    end
    set_priorities('mp','hp')
end

function buff_change(name,gol,tab)
    if name == 'Mana Wall' and gol and not midaction() then
        equip(sets.aftercast.Idle[sets.aftercast.Idle.ind],sets.aftercast.Idle['Mana Wall'])
    end
    set_priorities('mp','hp')
end

function self_command(command)
    if command:lower() == 'stuntarg' then
        stuntarg = player.target.name
    elseif command:lower() == 'macc' then
        macc_level = (macc_level+1)%2
        equip(sets.midcast['Elemental Magic'][macc_level][mp_efficiency])
        if macc_level == 1 then windower.add_to_chat(8,'MMMMMMAcctivated!')
        else windower.add_to_chat(8,'MDamaged') end
    elseif command:lower() == 'idle' then
        sets.aftercast.Idle.ind = (sets.aftercast.Idle.ind+1)%2
        windower.add_to_chat(8,'------------------------ '..sets.aftercast.Idle.keys[sets.aftercast.Idle.ind]..' Set is now the default Idle set -----------------------')
    end
    set_priorities('mp','hp')
end

-- This function is user defined, but never called by GearSwap itself. It's just a user function that's only called from user functions. I wanted to check the weather and equip a weather-based set for some spells, so it made sense to make a function for it instead of replicating the conditional in multiple places.

function weathercheck(spell_element,set)
    if not set then return end
    if spell_element == world.weather_element or spell_element == world.day_element then
        equip(set,sets.Obis[spell_element])
    else
        equip(set)
    end
    if set[spell_element] then equip(set[spell_element]) end
end

function zodiaccheck(spell_element)
    if spell_element == world.day_element and spell_element ~= 'Dark' and spell_element ~= 'Light' then
        equip(sets.Zodiac)
    end
end

function equip_idle_set()
    if buffactive['Mana Wall'] then
        equip(sets.aftercast.Idle[sets.aftercast.Idle.ind],sets.aftercast.Idle['Mana Wall'])
    else
        equip(sets.aftercast.Idle[sets.aftercast.Idle.ind])
    end
    if player.tp == 3000 then equip(sets.aftercast.Chry) end
    set_priorities('mp','hp')
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