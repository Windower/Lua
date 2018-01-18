include('organizer-lib')

function get_sets()
    MP_efficiency = 0
    macc_level = 0
    
    sets.TH = {
        hands={ name="Merlinic Dastanas", augments={'"Treasure Hunter"+2',},hp=9,mp=20},
        legs={ name="Merlinic Shalwar", augments={'Pet: Accuracy+16 Pet: Rng. Acc.+16','Pet: Haste+1','"Treasure Hunter"+1','Mag. Acc.+9 "Mag.Atk.Bns."+9',},hp=29,mp=44},
        waist="Chaac Belt",
    }
    
    sets.precast = {}
    sets.Idris = {main="Idris"}
    sets.Mafic = {main="Mafic Cudgel"}
    
    sets.precast.FastCast = {}
    
    sets.precast.FastCast.Default = {
        main="Marin Staff +1",
        sub="Niobid Strap",
        range=empty,
        ammo="Impatiens",
        feet={ name="Merlinic Crackows", augments={'"Mag.Atk.Bns."+11','"Fast Cast"+7',}},
        body="Zendik Robe",
        hands={ name="Merlinic Dastanas", augments={'Mag. Acc.+29','"Fast Cast"+7','INT+1',}},
        legs="Psycloth Lappas",
        head={ name="Merlinic Hood", augments={'"Fast Cast"+7','MND+10','Mag. Acc.+10','"Mag.Atk.Bns."+10',}},
        neck="Orunmila's Torque",
        waist="Witful Belt",
        left_ear="Enchntr. Earring +1",
        right_ear="Loquac. Earring",
        left_ring="Lebeche Ring",
        right_ring="Weather. Ring +1",
        back={ name="Lifestream Cape", augments={'Geomancy Skill +3','Indi. eff. dur. +20','Damage taken-3%',}},
    }
    
    sets.precast.FastCast['Elemental Magic'] = set_combine(sets.precast.FastCast.Default,{
        ear1="Barkarole Earring",
        body={ name="Dalmatica +1", augments={'Occ. quickens spellcasting +3%','"Fast Cast"+6','Pet: "Mag.Def.Bns."+6',}},
        hands="Bagua mitaines +1",
        lring="Kishar Ring",
    })
    
    sets.precast.FastCast['Healing Magic'] = set_combine(sets.precast.FastCast.Default,{main="Vadose Rod",sub="Genmei Shield",body="Heka's Kalasiris",back="Pahtli Cape"})
    
--    sets.precast.FastCast['Enhancing Magic'] = set_combine(sets.precast.FastCast.Default,{waist="Siegel Sash"})
            
    sets.Impact = {head=empty,body="Twilight Cloak"}
    
    sets.midcast = {}
    
    sets.midcast.Stun = {main="Marin Staff +1",sub="Enki Strap",range=empty,ammo="Hasty Pinion +1",
        head={ name="Merlinic Hood", augments={'"Fast Cast"+7','MND+10','Mag. Acc.+10','"Mag.Atk.Bns."+10',}}, neck="Erra Pendant", ear1="Enchanter Earring +1",ear2="Loquacious Earring",
        body="Geomancy Tunic +1",hands={ name="Hagondes Cuffs +1", augments={'Phys. dmg. taken -3%','Mag. Acc.+23',}},lring="Sangoma Ring",rring="Angha Ring",
        back={ name="Lifestream Cape", augments={'Geomancy Skill +3','Indi. eff. dur. +20','Damage taken-3%',}},waist="Ninurta's Sash",legs="Psycloth Lappas",feet="Amalric Nails +1"}
    
    
    
    sets.midcast['Elemental Magic'] = {
        [0] = {},
        [1] = {}
        }
    
    sets.ElementalMagicMAB = {
        Ice={main="Ngqoqwanb",sub="Enki Strap"},
        Wind={main="Marin Staff +1",sub="Enki Strap"},
        Earth={neck="Quanpur Necklace"},
        Dark={head="Pixie Hairpin +1", rring="Archon Ring"}
        }
    
    -- MAcc level 0 (Macc and Enmity irrelevant)
    sets.midcast['Elemental Magic'][0][0] = {
        main="Idris",
        sub="Ammurapi Shield",
        range=empty,
        ammo="Pemphredo Tathlum",
        head={ name="Merlinic Hood", augments={'VIT+8','"Mag.Atk.Bns."+27','Accuracy+5 Attack+5','Mag. Acc.+18 "Mag.Atk.Bns."+18',}},
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',}},
        hands="Amalric Gages +1",
        legs={ name="Merlinic Shalwar", augments={'"Mag.Atk.Bns."+30','"Occult Acumen"+10','INT+9','Mag. Acc.+5',}},
        feet="Amalric Nails +1",
        neck="Baetyl Pendant",
        waist="Yamabuki-no-Obi",
        left_ear="Barkaro. Earring",
        right_ear="Crematio Earring",
        left_ring="Shiva Ring +1",
        right_ring="Shiva Ring +1",
        back={ name="Nantosuelta's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10',}},
    }
    
    sets.midcast['Elemental Magic'][0][1] = set_combine(sets.midcast['Elemental Magic'][0][0],{body="Seidr Cotehardie"})
    
    -- MAcc level 1 (MAcc and Enmity relevant)
    sets.midcast['Elemental Magic'][1][0] = {
        main="Idris",
        sub="Ammurapi Shield",
        range=empty,
        ammo="Pemphredo Tathlum",
        head={ name="Merlinic Hood", augments={'VIT+8','"Mag.Atk.Bns."+27','Accuracy+5 Attack+5','Mag. Acc.+18 "Mag.Atk.Bns."+18',}},
        body={ name="Witching Robe", augments={'MP+50','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Refresh"+1',}},
        hands={ name="Hagondes Cuffs +1", augments={'Phys. dmg. taken -3%','Mag. Acc.+23',}},
        legs={ name="Merlinic Shalwar", augments={'"Mag.Atk.Bns."+30','"Occult Acumen"+10','INT+9','Mag. Acc.+5',}},
        feet="Amalric Nails +1",
        neck="Sanctity Necklace",
        waist={name="Yamabuki-no-Obi", stats={INT=8}},
        ear2={name="Novia Earring", stats={Enmity=-7}},
        ear1="Barkarole Earring",
        ring1={name="Shiva Ring +1", stats={INT=9,MAB=3}},
        ring2={name="Shiva Ring +1", stats={INT=9,MAB=3}},
        back={ name="Nantosuelta's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10',}},
        }
                
    sets.midcast['Elemental Magic'][1][1] = set_combine(sets.midcast['Elemental Magic'][1][0],{body="Seidr Cotehardie"})
    
    
    
    sets.midcast['Dark Magic'] = {
        main={ name="Rubicundity", augments={'Mag. Acc.+10','"Mag.Atk.Bns."+10','Dark magic skill +10','"Conserve MP"+7',}},
        sub="Ammurapi Shield",
        range=empty,
        ammo="Hasty Pinion +1",
        head="Pixie Hairpin +1",
        body="Psycloth Vest",
        hands={ name="Hagondes Cuffs +1", augments={'Phys. dmg. taken -3%','Mag. Acc.+23',}},
        legs="Psycloth Lappas",
        feet={ name="Merlinic Crackows", augments={'Mag. Acc.+21','"Drain" and "Aspir" potency +11','INT+1',}},
        neck="Erra Pendant",
        waist="Austerity Belt +1",
        left_ear="Hirudinea Earring",
        right_ear="Loquac. Earring",
        left_ring="Evanescence Ring",
        right_ring="Archon Ring",
        back={ name="Nantosuelta's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10',}},
    }
    
    sets.midcast['Enfeebling Magic'] = {
        main="Idris",
        sub="Ammurapi Shield",
        range=empty,
        ammo="Pemphredo Tathlum",
        head="Amalric Coif +1",
        neck="Erra Pendant",
        ear1="Barkarole Earring",
        ear2="Dignitary's Earring",
        body="Zendik Robe",
        hands={ name="Hagondes Cuffs +1", augments={'Phys. dmg. taken -3%','Mag. Acc.+23',}},
        ring1="Kishar Ring",
        ring2="Weather. Ring +1",
        back={ name="Nantosuelta's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10',}},
        waist="Luminary Sash",
        legs="Psycloth Lappas",
        feet="Amalric Nails +1",
    }
        
    sets.midcast.EnhancingDuration = {
        main={ name="Gada", augments={'Enh. Mag. eff. dur. +6','"Mag.Atk.Bns."+9',}},
        sub="Ammurapi Shield",
        hands={ name="Telchine Gloves", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',}},
        head={ name="Telchine Cap", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',}},
        body={ name="Telchine Chas.", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',}},
        legs={ name="Telchine Braconi", augments={'"Elemental Siphon"+35','Enh. Mag. eff. dur. +10',}},
        feet={ name="Telchine Pigaches", augments={'Song spellcasting time -7%','Enh. Mag. eff. dur. +10',}},
    }
        
    sets.midcast['Flash Nova'] = {
        range=empty,
        ammo="Mana Ampulla",
        head={ name="Merlinic Hood", augments={'VIT+8','"Mag.Atk.Bns."+27','Accuracy+5 Attack+5','Mag. Acc.+18 "Mag.Atk.Bns."+18',}},
        body={ name="Merlinic Jubbah", augments={'"Mag.Atk.Bns."+29','Magic burst dmg.+11%','INT+10',}},
        hands="Amalric Gages +1",
        legs={ name="Merlinic Shalwar", augments={'"Mag.Atk.Bns."+30','"Occult Acumen"+10','INT+9','Mag. Acc.+5',}},
        feet="Amalric Nails +1",
        neck="Baetyl Pendant",
        waist="Fotia Belt",
        left_ear="Friomisi Earring",
        right_ear="Crematio Earring",
        left_ring="Shiva Ring +1",
        right_ring="Weather. Ring +1",
        back={ name="Nantosuelta's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10',}},
    }
    
    sets.midcast.Exudation = {range=empty,ammo="Mana Ampulla",
        head="Geomancy Galero +1",neck="Phalaina Locket",
        body="Onca Suit",hands=empty,lring="Rajas Ring",rring="Ifrit Ring +1",
        back="Pahtli Cape",waist="Luminary Sash",legs=empty,feet=empty,
        }
        
    sets.midcast['Spirit Taker'] = sets.midcast.Exudation
    
    sets.midcast['Healing Magic'] = {neck="Incanter's Torque"}
    
    sets.midcast['Divine Magic'] = {neck="Incanter's Torque"}
    
    sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.EnhancingDuration,{neck="Incanter's Torque"})
    
    sets.midcast.Dia = sets.TH
    sets.midcast['Dia II'] = sets.TH
    sets.midcast.Diaga = sets.TH
    
    sets.midcast.Cure = {
        main="Vadose Rod",
        sub="Genmei Shield",
        range=empty,
        ammo="Mana Ampulla",
        head="Amalric Coif +1",
        neck="Phalaina Locket",
        lear="Novia Earring",
        rear="Mendicant's Earring",
        body="Heka's Kalasiris",
        hands="Revealer's Mitts +1",
        lring="Celestial Ring",
        rring="Sangoma Ring",
        back="Pahtli Cape",
        waist="Luminary Sash",
        legs="Vanya Slops",
        feet="Amalric Nails +1"
    }
    
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration,{neck="Nodens Gorget",waist="Siegel Sash",legs="Shedir Seraweels"})
    
    sets.midcast.Aquaveil = set_combine(sets.midcast.EnhancingDuration,{main="Vadose Rod",head="Amalric Coif +1",sub="Genmei Shield",waist="Emphatikos Rope",legs="Shedir Seraweels"})
    
    sets.midcast.Refresh = set_combine(sets.midcast.EnhancingDuration,{head="Amalric Coif +1",back="Grapevine Cape",feet="Inspirited Boots"})
    
    sets.midcast.Cursna = {
        main={ name="Divinity", augments={'Attack+10','Accuracy+10','Phys. dmg. taken -3%','DMG:+15',}},
        sub="Genmei Shield",
        head={ name="Vanya Hood", augments={'Healing magic skill +20','"Cure" spellcasting time -7%','Magic dmg. taken -3',}},
        body="Vanya Robe",
        hands="Hieros Mittens",
        legs={ name="Vanya Slops", augments={'Healing magic skill +20','"Cure" spellcasting time -7%','Magic dmg. taken -3',}},
        left_ring="Haoma's Ring",
        right_ring="Haoma's Ring",
        back="Oretan. Cape +1",
        feet="Vanya Clogs",
        neck="Debilis Medallion",
    }
    
    sets.midcast.Bolster = {body="Bagua Tunic +1"}
    
    sets.midcast['Full Circle'] = {head="Azimuth Hood +1",hands="Bagua Mitaines +1"}
    
    sets.midcast['Life Cycle'] = {body="Geomancy Tunic +1",
        back={ name="Nantosuelta's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Pet: "Regen"+10',}},}
    
    sets.midcast['Radial Arcana'] = {hands="Bagua Sandals +1"}
    
    sets.midcast['Mending Halation'] = {Legs="Bagua Pants +1"}
    
    sets.midcast.Indi = {
        main="Idris",
        sub="Genmei Shield",
        range="Dunna",
        ammo=empty,
        head="Azimuth Hood +1",
        body={ name="Bagua Tunic +1", augments={'Enhances "Bolster" effect',}},
        legs={ name="Bagua Pants +1", augments={'Enhances "Mending Halation" effect',}},
        feet="Azimuth Gaiters +1",
        neck="Incanter's Torque",
        back={ name="Lifestream Cape", augments={'Geomancy Skill +3','Indi. eff. dur. +20','Damage taken-3%',}},
    }
    
    sets.midcast.Geo = {
        main="Idris",
        sub="Genmei Shield",
        range="Dunna",
        ammo=empty,
        head="Azimuth Hood +1",
        body={ name="Bagua Tunic +1", augments={'Enhances "Bolster" effect',}},
        legs={ name="Bagua Pants +1", augments={'Enhances "Mending Halation" effect',}},
        feet="Azimuth Gaiters +1",
        neck="Incanter's Torque",
        back={ name="Lifestream Cape", augments={'Geomancy Skill +3','Indi. eff. dur. +20','Damage taken-3%',}},
    }
    sets.midcast.Geo = set_combine(sets.midcast.Geo,sets.TH)
    
    sets.midcast['Entrusted Indi'] = set_combine(sets.midcast.Indi,{main="Solstice"})
    
    
    
    sets.aftercast = {}
    sets.aftercast.Idle = {}
    sets.aftercast.Idle[false] = {
        main="Mafic Cudgel",
        sub="Genmei Shield",
        range="Dunna",
        ammo=empty,
        head={ name="Merlinic Hood", augments={'"Mag.Atk.Bns."+28','"Fast Cast"+3','"Refresh"+1','Mag. Acc.+6 "Mag.Atk.Bns."+6',}},
        neck="Loricate Torque +1",
        ear1="Gifted earring",
        ear2="Etiolation Earring",
        body="Witching Robe",
        hands="Bagua Mitaines +1",
        ring1="Dark Ring",
        ring2="Defending Ring",
        back="Umbra Cape",
        waist="Yamabuki-no-Obi",
        legs="Assid. Pants +1",
        feet="Geomancy Sandals +2"}
        
    sets.aftercast.Idle[true] = {
        main="Idris",
        sub="Genmei Shield",
        range={ name="Dunna", augments={'MP+20','Mag. Acc.+10','"Fast Cast"+3',}},
        head="Azimuth Hood +1",
        body={ name="Telchine Chas.", augments={'Mag. Evasion+21','Pet: "Regen"+3','Pet: Damage taken -3%',}},
        hands={ name="Telchine Gloves", augments={'Mag. Evasion+25','Pet: "Regen"+3','Pet: Damage taken -3%',}},
        legs={ name="Telchine Braconi", augments={'Mag. Evasion+25','Pet: "Regen"+3','Pet: Damage taken -3%',}},
        feet={ name="Bagua Sandals +1", augments={'Enhances "Radial Arcana" effect',}},
        neck="Loricate Torque +1",
        waist="Isa belt",
        left_ear="Genmei Earring",
        right_ear="Etiolation Earring",
        left_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}},
        right_ring="Defending Ring",
        back={ name="Nantosuelta's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Pet: "Regen"+10',}},
    }
                        
    sets.aftercast.Resting = {main="Numen Staff",sub="Ariesian Grip",range="Dunna",ammo=empty,
        head={ name="Merlinic Hood", augments={'"Mag.Atk.Bns."+28','"Fast Cast"+3','"Refresh"+1','Mag. Acc.+6 "Mag.Atk.Bns."+6',}},neck="Eidolon Pendant +1",ear1="Relaxing Earring",ear2="Antivenom Earring",
        body="Witching Robe",hands="Nares Cuffs",ring1="Celestial Ring",ring2="Angha Ring",
        back="Felicitas Cape +1",waist="Austerity Belt +1",legs="Assid. Pants +1",feet="Chelona Boots +1"}
                
    sets.aftercast.Engaged = {main="Mafic Cudgel",sub="Genmei Shield",
        head={name="Hagondes Hat +1", augments={'Phys. dmg. taken -3%','Magic dmg. taken -2%','"Mag.Atk.Bns."+26',}},neck="Loricate Torque +1",ear1="Brutal Earring",ear2="Genmei Earring",
        body="Onca Suit",hands=empty,ring1="Dark Ring",ring2="Defending Ring",
        back="Umbra Cape",waist="Ninurta's Sash",legs=empty,feet=empty}
        --body="Hagondes Coat +1",hands={ name="Hagondes Cuffs +1", augments={'Phys. dmg. taken -3%','Mag. Acc.+23',}},ring1="Dark Ring",ring2="Defending Ring",
        --back="Umbra Cape",waist="Ninurta's Sash",legs={ name="Hagondes Pants +1", augments={'Phys. dmg. taken -4%','Magic dmg. taken -4%','Magic burst dmg.+10%',}},feet="Battlecast Gaiters"}
    
    sets.Obis = {}
    sets.Obis.Fire = {waist='Hachirin-no-Obi'}
    sets.Obis.Earth = {waist='Hachirin-no-Obi'}
    sets.Obis.Water = {waist='Hachirin-no-Obi'}
    sets.Obis.Wind = {waist='Hachirin-no-Obi'}
    sets.Obis.Ice = {waist='Hachirin-no-Obi'}
    sets.Obis.Lightning = {waist='Hachirin-no-Obi'}
    sets.Obis.Light = {waist='Hachirin-no-Obi'}
    sets.Obis.Dark = {waist='Hachirin-no-Obi'}
    sets.Zodiac = {lring="Zodiac Ring"}
    
    sets.midcast.MB={
        head={ name="Merlinic Hood", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','Magic burst dmg.+11%','INT+1','Mag. Acc.+8',}},
        body={ name="Merlinic Jubbah", augments={'"Mag.Atk.Bns."+29','Magic burst dmg.+11%','INT+10',}},
        legs={ name="Merlinic Shalwar", augments={'"Mag.Atk.Bns."+26','Magic burst dmg.+11%','INT+10','Mag. Acc.+13',}},
        neck="Mizu. Kubikazari",
        right_ring="Mujin Band",
    }
        
    stuntarg = 'Shantotto'
    send_command('input /macro book 2;wait .1;input /macro set 1')
    
    AMII = {['Freeze II']=true,['Burst II']=true,['Quake II'] = true, ['Tornado II'] = true,['Flood II']=true,['Flare II']=true}
end

function precast(spell)
    if sets.precast[spell.english] then
        equip(sets.precast[spell.english][macc_level] or sets.precast[spell.english])
    elseif spell.english == 'Impact' then
        equip(sets.precast.FastCast.Default,sets.Impact)
        if not buffactive['Elemental Seal'] then
            add_to_chat(8,'--------- Elemental Seal is down ---------')
        end
    elseif spell.action_type == 'Magic' then
        equip(sets.precast.FastCast.Default)
    end
    
    if spell.english == 'Stun' and stuntarg ~= 'Shantotto' then
        send_command('@input /t '..stuntarg..' ---- Byrth Stunned!!! ---- ')
    end
end

function midcast(spell)
    equip_idle_set()
    if buffactive.manawell or spell.mppaftercast > 50 then mp_efficiency = 0
    else mp_efficiency = 1 end
    
    if spell and spell.english and string.find(spell.english,'Cur') then 
        weathercheck(spell.element,sets.midcast.Cure)
    elseif spell.english == 'Impact' then
        weathercheck(spell.element,set_combine(sets.midcast['Elemental Magic'][macc_level][mp_efficiency],sets.Impact))
    elseif spell.english:sub(1,4) == 'Geo-' then
        equip(sets.midcast.Geo)
    elseif spell.english:sub(1,5) == 'Indi-' then
        if buffactive.Entrust then
            equip(sets.midcast["Entrusted Indi"])
        else
            equip(sets.midcast.Indi)
        end
    elseif sets.midcast[spell.name] then
        weathercheck(spell.element,sets.midcast[spell.name])
    elseif spell.skill == 'Elemental Magic' then
        weathercheck(spell.element,sets.midcast['Elemental Magic'][macc_level][mp_efficiency])
        if sets.ElementalMagicMAB[spell.element] then
            equip(sets.ElementalMagicMAB[spell.element])
        end
    elseif spell.skill then
        equip(sets.aftercast.Idle)
        weathercheck(spell.element,sets.midcast[spell.skill])
    end
    
    if spell.english == 'Sneak' then
        send_command('cancel 71;')
    end
end

function aftercast(spell)
    if midaction() or (spell and (spell.name == 'Mending Halation' or spell.name == 'Radial Arcana')) then
    elseif player.status == 'Idle' then
    
        if not spell.english then print('NO SPELL IN AFTERCAST') return end
        if spell and spell.english and player.status == 'Idle' and string.find(spell.english,'Geo') then
            equip(sets.aftercast.Idle[true])
        else
            equip_idle_set()
        end
    elseif sets.aftercast[player.status] then
        equip(sets.aftercast[player.status])
    else
        equip_idle_set()
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
end

function pet_aftercast(spell)
    if (spell and (spell.name == 'Mending Halation' or spell.name == 'Radial Arcana')) then
        equip_idle_set()
    end
end

function status_change(new,old)
    if new == 'Resting' then
        equip(sets.aftercast.Resting)
    elseif new == 'Engaged' then
        if not midaction() then
            equip(sets.aftercast.Engaged)
        end
 --       disable('main','sub')
    else
        equip_idle_set()
    end
end

function equip_idle_set(bool)
    if bool == nil then
        bool = pet.isvalid
    end
    equip(sets.aftercast.Idle[bool])
end

function weathercheck(spell_element,set)
    if not set then return end
    if spell_element == world.weather_element or spell_element == world.day_element then
        equip(set,sets.Obis[spell_element])
    else
        equip(set)
    end
    if set[spell_element] then equip(set[spell_element]) end
end

function indi_change(spell,bool)
    if not bool then windower.add_to_chat(8,"------------------- Indi effect wears off! -------------------------") end
end

function buff_change(name,gain,tab)
    if gain then
        print('gain',name,buffactive[name],math.floor(tab.duration/60),math.floor(tab.duration%60))
    else
        print('loss',name,buffactive[name],math.floor(tab.duration/60),math.floor(tab.duration%60))
    end
end

function self_command(command)
    if command:lower() == 'stuntarg' then
        stuntarg = player.target.name
        print('StunTarg: ',stuntarg)
    elseif command:lower() == 'macc' then
        macc_level = (macc_level+1)%2
        print('Magic Accuracy level ',macc_level)
    end
end

function pet_change(pet,gain)
    if not midaction() then
        equip_idle_set(gain)
    end
end