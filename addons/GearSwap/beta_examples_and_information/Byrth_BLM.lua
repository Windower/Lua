function get_sets()
    MP_efficiency = 0
    macc_level = 0
    
    sets.precast = {}
    
--    sets.precast.Stun[1] = {main="Laevateinn",sub="Arbuda Grip",--ranged="Aureole",
--        head="Nahtirah Hat",neck="Aesir Torque",ear1="Enchanter Earring +1",ear2="Loquacious Earring",
--        body="Hedera Cotehardie",hands={name="Archmage's Gloves +1",stats={INT=26,MAcc=19,Enmity=-5,Haste=3,MBdmg=16}},lring="Sangoma Ring",rring="Angha Ring",
--        back="Swith Cape +1",waist="Goading Belt",legs={name="Spaekona's Tonban +1",stats={INT=34,MAB=20,Haste=5,Enmity=-4}},feet="Bokwus Boots"}
    
    
    sets.precast.FastCast = {}
    
    sets.precast.FastCast.Default = {ammo="Impatiens",
        head="Nahtirah Hat",neck="Orunmila's Torque",ear1="Enchanter Earring +1",ear2="Loquacious Earring",
        body="Anhur Robe",hands={ name="Hagondes Cuffs", augments={'Phys. dmg. taken -3%','"Fast Cast"+5',}},lring="Prolix Ring",rring="Veneficium Ring",
        back="Swith Cape +1",waist="Witful Belt",legs="Artsieq Hose",feet="Chelona Boots +1"}
    
    sets.precast.FastCast['Elemental Magic'] = set_combine(sets.precast.FastCast.Default,{body="Dalmatica +1",head="Goetia Petasos +2",back="Ogapepo Cape +1"})
    
    sets.precast.FastCast['Enhancing Magic'] = set_combine(sets.precast.FastCast.Default,{waist="Siegel Sash"})
            
    sets.precast.AMII = set_combine(sets.precast.FastCast['Elemental Magic'],{hands = {name="Archmage's Gloves +1",stats={INT=36,MAcc=20,Enmity=-10,Haste=3}}})
    
    sets.precast.Manafont = {body={name="Archmage's Coat +1",stats={INT=36,MAcc=20,Enmity=-10,Haste=3}}}
    
    sets.Impact = {head=empty,body="Twilight Cloak"}
    
    sets.midcast = {}
    
    sets.midcast.Stun = {main="Apamajas II",sub="Arbuda Grip",ammo="Hasty Pinion +1",
        head="Nahtirah Hat",neck="Aesir Torque",ear1="Enchanter Earring +1",ear2="Loquacious Earring",
        body="Hedera Cotehardie",hands={name="Archmage's Gloves +1",stats={INT=26,MAcc=19,Enmity=-5,Haste=3,MBdmg=16}},lring="Sangoma Ring",rring="Angha Ring",
        back="Swith Cape +1",waist="Goading Belt",legs={name="Spaekona's Tonban +1",stats={INT=34,MAB=20,Haste=5,Enmity=-4}},feet="Chelona Boots +1"}
    
    sets.midcast['Elemental Magic'] = {
        [0] = {},
        [1] = {}
        }
    
    sets.ElementalMagicMAB = {
                Earth={neck={name="Quanpur Necklace", stats={MAB=7,EarthStaffBns=5}}},
                Dark={head={ name="Pixie Hairpin +1", stats={INT=17,DarkAffinity=28}}, rring={ name="Archon Ring", stats={DarkAffinity=5}} }
                }
    
    -- MAcc level 0 (Macc and Enmity irrelevant)
    sets.midcast['Elemental Magic'][0][0] = {main={name="Laevateinn", stats={MAB=60,MDmg=248,MAcc=220, ESDmg=10}},
                sub={name="Zuuxowu Grip", stats={MDmg=10}},
                ammo={name="Dosis Tathlum", stats={MDmg=13}},
                head={ name="Hagondes Hat +1", stats={INT=21,MAB=39,Haste=6}, augments={'Phys. dmg. taken -3%','Magic dmg. taken -2%','"Mag.Atk.Bns."+26',}},
                neck={name="Eddy Necklace", stats={MAB=11, MAcc=5}},
                ear1={name="Friomisi Earring", stats={MAB=10, Enmity=2}},
                ear2={name="Novio Earring", stats={MAB=7}},
                body={ name="Hagondes Coat +1",stats={INT=33,MAB=38,Haste=3}, augments={'Phys. dmg. taken -4%','Magic dmg. taken -2%','"Mag.Atk.Bns."+28',}},
                hands={name="Otomi Gloves", stats={INT=24,MAB=13,MAcc=13,MDmg=10,Enmity=-5,Haste=5}},
                ring1={name="Shiva Ring +1", stats={INT=9,MAB=3}},
                ring2={name="Shiva Ring +1", stats={INT=9,MAB=3}},
                back={name="Toro Cape", stats={INT=8, MAB=10}},
                --waist={name="Sekhmet Corset", stats={MDmg=15,CMP=3}},
                waist={name="Yamabuki-no-Obi", stats={INT=8}},
                legs={ name="Hagondes Pants +1", stats={INT=32,MAB=53,Haste=5,MDmg=10}, augments={'Phys. dmg. taken -3%','"Mag.Atk.Bns."+28',}},
                feet={name="Umbani Boots", stats={INT=22, MAB=20, MDmg=10, Haste=3, CMP=5}}}
    
    sets.midcast['Elemental Magic'][0][1] = set_combine(sets.midcast['Elemental Magic'][0][0],{body={name="Spaekona's Coat +1",stats={INT=29,Haste=3,Enmity=-7,MdmgToMP=2}}})
    
    -- MAcc level 1 (MAcc and Enmity relevant)
    sets.midcast['Elemental Magic'][1][0] = {main={name="Laevateinn", stats={MAB=60,MDmg=248,MAcc=220, ESDmg=10}},
                sub={name="Zuuxowu Grip", stats={MDmg=10}},
                ammo={name="Dosis Tathlum", stats={MDmg=13}},
                head={name="Hagondes Hat +1",stats={INT=21,MAB=13,MAcc=25,Haste=6}, augments={'Phys. dmg. taken -3','Mag. Acc.+25',}},
                body={ name="Hagondes Coat +1",stats={INT=33,MAB=38,Haste=3}, augments={'Phys. dmg. taken -4%','Magic dmg. taken -2%','"Mag.Atk.Bns."+28',}},
                hands={ name="Hagondes Cuffs +1", stats={INT=17,MAcc=43,Haste=3,Enmity=-8}, augments={'Phys. dmg. taken -3%','Mag. Acc.+23',}},
                legs={ name="Hagondes Pants +1", stats={INT=32,MAB=48,Haste=4,MDmg=10}, augments={'Phys. dmg. taken -3','Magic dmg. taken -3','Mag. Acc.+24',}},
                feet={ name="Arch. Sabots +1", stats={INT=20,MAcc=25, Enmity=-4}, augments={'Reduces Ancient Magic II MP cost',}},
                neck={name="Eddy Necklace", stats={MAB=11, MAcc=5}},
                waist={name="Yamabuki-no-Obi", stats={INT=8}},
                ear1={name="Novia Earring", stats={Enmity=-7}},
                ear2={name="Novio Earring", stats={MAB=7}},
                ring1={name="Shiva Ring +1", stats={INT=9,MAB=3}},
                ring2={name="Shiva Ring +1", stats={INT=9,MAB=3}},
                back={name="Toro Cape", stats={INT=8, MAB=10}}}
                
    sets.midcast['Elemental Magic'][1][1] = set_combine(sets.midcast['Elemental Magic'][1][0],{body={name="Spaekona's Coat +1",stats={INT=29,Haste=3,Enmity=-7,MdmgToMP=2}}})
    
    sets.midcast.AMII = {
                head={ name="Arch. Petasos +1", stats={INT=24, MAB=12, MAcc=29, Enmity=-5}, augments={'Increases Ancient Magic II damage',}},
                feet={ name="Arch. Sabots +1", stats={INT=20,MAcc=25, Enmity=-4}, augments={'Reduces Ancient Magic II MP cost',}},
                }
    
    
    sets.midcast['Dark Magic'] = {main={name="Laevateinn", stats={MAB=60,MDmg=248,MAcc=220, ESDmg=10}},sub="Mephitis Grip",ammo="Hasty Pinion +1",
        head={ name="Pixie Hairpin +1", stats={INT=17,DarkAffinity=28} },neck="Aesir Torque",ear1="Hirudinea Earring",ear2="Loquacious Earring",
        body={name="Spaekona's Coat +1",stats={INT=29,Haste=3,Enmity=-7,MdmgToMP=2}},hands={name="Archmage's Gloves +1",stats={INT=26,MAcc=19,Enmity=-5,Haste=3,MBdmg=16}},lring="Excelsis Ring",rring="Archon Ring",
        back="Ogapepo Cape +1",waist="Austerity Belt +1",legs={name="Spaekona's Tonban +1",stats={INT=34,MAB=20,Haste=5,Enmity=-4}},feet="Archmage's Sabots +1"}
    
    sets.midcast['Enfeebling Magic'] = {main={name="Laevateinn", stats={MAB=60,MDmg=248,MAcc=220, ESDmg=10}},sub="Mephitis Grip",--range='Aureole',
        head={name="Hagondes Hat +1",stats={INT=21,MAB=13,MAcc=25,Haste=6}, augments={'Phys. dmg. taken -3','Mag. Acc.+25',}},neck={name="Eddy Necklace", stats={MAB=11, MAcc=5}},ear1="Enchanter Earring +1",ear2="Gwati Earring",
        body="Ischemia Chasu.",hands={ name="Hagondes Cuffs +1", augments={'Phys. dmg. taken -3%','Mag. Acc.+23',}},ring1="Sangoma Ring",ring2="Angha Ring",
        back={name="Bane Cape", stats={MDmg=10, MAcc=10}},waist="Ovate Rope",legs={name="Spaekona's Tonban +1",stats={INT=34,MAB=20,Haste=5,Enmity=-4}},feet={name="Artsieq Boots", augments={'Mag. Acc.+20','MND+7','MP+30',}}}
        
    sets.midcast.Vidohunir = {ammo={name="Ombre Tathlum +1",stats={INT=6,MAcc=3}},
        head={ name="Pixie Hairpin +1", stats={INT=17,DarkAffinity=28} },neck={name="Saevus Pendant +1",stats={MAB=18,MAcc=-6}},ear1={name="Friomisi Earring", stats={MAB=10, Enmity=2}},ear2={name="Novio Earring", stats={MAB=7}},
        body={ name="Hagondes Coat +1",stats={INT=33,MAB=38,Haste=3}, augments={'Phys. dmg. taken -4%','Magic dmg. taken -2%','"Mag.Atk.Bns."+28',}},hands={name="Yaoyotl Gloves", stats={INT=19,MAB=15,MAcc=15,Enmity=-6}},lring={name="Shiva Ring +1", stats={INT=9,MAB=3}},rring={ name="Archon Ring", stats={DarkAffinity=5}},
        back={name="Toro Cape", stat={INT=8, MAB=10}},waist="Aqua Belt",legs={ name="Hagondes Pants +1", stats={INT=32,MAB=53,Haste=5,MDmg=10}, augments={'Phys. dmg. taken -3%','"Mag.Atk.Bns."+28',}},feet={name="Umbani Boots", stats={INT=22, MAB=10, MDmg=10, Haste=3, CMP=5}}}
    
    sets.midcast.Myrkr = {ammo="Mana Ampulla",
        head={ name="Pixie Hairpin +1", stats={INT=17,DarkAffinity=28} },neck="Orunmila's Torque",ear1="Gifted earring",ear2="Loquacious Earring",
        body="Archmage's Coat +1",hands="Otomi Gloves",lring="Sangoma Ring",rring="Zodiac Ring",
        back="Bane Cape",waist="Yamabuki-no-Obi",legs="Spaekona's Tonban +1",feet="Chelona Boots +1"
        }
    
    sets.midcast['Healing Magic'] = {}
    
    sets.midcast['Divine Magic'] = {}
    
    sets.midcast['Enhancing Magic'] = {}
    
    sets.midcast.Cure = {main="Chatoyant Staff",neck="Phalaina Locket",body="Heka's Kalasiris",hands={ name="Bokwus Gloves", augments={'Mag. Acc.+13','MND+10','INT+10',}},legs="Nares Trews"}
    
    sets.midcast.Stoneskin = {main="Kirin's Pole",neck="Stone Gorget",waist="Siegel Sash",legs="Shedir Seraweels"}
    
    sets.midcast.Aquaveil = {legs="Shedir Seraweels"}
    
    sets.aftercast = {}
    sets.aftercast.Idle = {}
    sets.aftercast.Idle.keys = {[0]="Refresh",[1]="PDT"}
    sets.aftercast.Idle.ind = 0
    sets.aftercast.Idle[0] = {main="Terra's Staff",sub="Arbuda Grip",ammo="Mana ampulla",
        head="Spurrina Coif",neck="Twilight Torque",ear1="Gifted earring",ear2="Sorcerer's Earring",
        body="Hagondes Coat +1",hands="Serpentes Cuffs",ring1="Dark Ring",ring2="Defending Ring",
        back="Umbra Cape",waist="Yamabuki-no-Obi",legs="Nares Trews",feet="Herald's Gaiters"}
        
    sets.aftercast.Idle[1] = {main="Terra's Staff",sub="Arbuda Grip",ammo="Mana ampulla",
        head={ name="Hagondes Hat +1", stats={INT=21,MAB=39,Haste=6}, augments={'Phys. dmg. taken -3%','Magic dmg. taken -2%','"Mag.Atk.Bns."+26',}},neck="Twilight Torque",ear1="Brutal Earring",ear2="Merman's Earring",
        body="Hagondes Coat +1",hands={ name="Hagondes Cuffs", augments={'Phys. dmg. taken -3%','"Fast Cast"+5',}},ring1="Dark Ring",ring2="Defending Ring",
        back="Umbra Cape",waist="Goading Belt",legs={ name="Hagondes Pants +1", augments={'Phys. dmg. taken -4%','Magic dmg. taken -4%','Magic burst mdg.+10%',}},feet="Battlecast Gaiters"}
        
    sets.aftercast.Idle['Mana Wall'] = {feet = "Goetia Sabots +2"}
                
    sets.aftercast.Resting = {main="Numen Staff",sub="Ariesian Grip",ammo="Mana ampulla",
        head="Spurrina Coif",neck="Eidolon Pendant",ear1="Relaxing Earring",ear2="Antivenom Earring",
        body="Hagondes Coat +1",hands="Nares Cuffs",ring1="Celestial Ring",ring2="Angha Ring",
        back="Felicitas Cape +1",waist="Austerity Belt +1",legs="Nares Trews",feet="Chelona Boots +1"}
                
    sets.aftercast.Engaged = {
        head={ name="Hagondes Hat +1", stats={INT=21,MAB=39,Haste=6}, augments={'Phys. dmg. taken -3%','Magic dmg. taken -2%','"Mag.Atk.Bns."+26',}},neck="Twilight Torque",ear1="Brutal Earring",ear2="Merman's Earring",
        body="Hagondes Coat +1",hands={ name="Hagondes Cuffs", augments={'Phys. dmg. taken -3%','"Fast Cast"+5',}},ring1="Dark Ring",ring2="Defending Ring",
        back="Umbra Cape",waist="Goading Belt",legs={ name="Hagondes Pants +1", augments={'Phys. dmg. taken -4%','Magic dmg. taken -4%','Magic burst mdg.+10%',}},feet="Battlecast Gaiters"}
    
    sets.Obis = {}
    sets.Obis.Fire = {waist='Karin Obi',back={name='Twilight Cape',stats={Day_Weather=5}},lring={name='Zodiac Ring', stats={Day_Weather=3}}}
    sets.Obis.Earth = {waist='Dorin Obi',back={name='Twilight Cape',stats={Day_Weather=5}},lring={name='Zodiac Ring', stats={Day_Weather=3}}}
    sets.Obis.Water = {waist='Suirin Obi',back={name='Twilight Cape',stats={Day_Weather=5}},lring={name='Zodiac Ring', stats={Day_Weather=3}}}
    sets.Obis.Wind = {waist='Furin Obi',back={name='Twilight Cape',stats={Day_Weather=5}},lring={name='Zodiac Ring', stats={Day_Weather=3}}}
    sets.Obis.Ice = {waist='Hyorin Obi',back={name='Twilight Cape',stats={Day_Weather=5}},lring={name='Zodiac Ring', stats={Day_Weather=3}}}
    sets.Obis.Lightning = {waist='Rairin Obi',back={name='Twilight Cape',stats={Day_Weather=5}},lring={name='Zodiac Ring', stats={Day_Weather=3}}}
    sets.Obis.Light = {waist='Korin Obi',back={name='Twilight Cape',stats={Day_Weather=5}},lring={name='Zodiac Ring', stats={Day_Weather=3}}}
    sets.Obis.Dark = {waist='Anrin Obi',back={name='Twilight Cape',stats={Day_Weather=5}},lring={name='Zodiac Ring', stats={Day_Weather=3}}}
    
    sets.FC = {staves={
        Fire = {main='Atar I'},
        Lightning = {main='Apamajas I'},
    }}
    
    sets.aftercast.empty = {}
    sets.aftercast.Chry = {neck="Chrysopoeia Torque"}
    tp_level = 'empty'
    
    stuntarg = 'Shantotto'
    send_command('input /macro book 2;wait .1;input /macro set 1')
    
    AMII = {['Freeze II']=true,['Burst II']=true,['Quake II'] = true, ['Tornado II'] = true,['Flood II']=true,['Flare II']=true}
    
end

windower.register_event('tp change',function(new,old)
    if new > 2950 then
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
end)

function precast(spell)
    if sets.precast[spell.english] then
        equip(sets.precast[spell.english][macc_level] or sets.precast[spell.english])
    elseif spell.english == 'Impact' then
        equip(sets.precast.FastCast['Elemental Magic'],sets.Impact)
        if not buffactive['Elemental Seal'] then
            add_to_chat(8,'--------- Elemental Seal is down ---------')
        end
    elseif spell.action_type == 'Magic' then
        if spell.skill == 'Elemental Magic' then
            if AMII[spell.english] and player.merits[to_windower_api(spell.english)] > 1 then
                equip(sets.precast.AMII)
            else
                equip(sets.precast.FastCast['Elemental Magic'])
            end
        elseif spell.skill == 'Enhancing Magic' then
            equip(sets.precast.FastCast['Enhancing Magic'])
        else
            equip(sets.precast.FastCast.Default)
        end
    end
    
    if spell.english == 'Stun' and stuntarg ~= 'Shantotto' then
        send_command('@input /t '..stuntarg..' ---- Byrth Stunned!!! ---- ')
    end
    
    if sets.FC.staves[spell.element] then
        equip(sets.FC.staves[spell.element])
    end
end

function midcast(spell)
    equip_idle_set()
    if buffactive.manawell or spell.mppaftercast > 50 then mp_efficiency = 0 else
        mp_efficiency = 1
    end
    
    if string.find(spell.english,'Cur') then 
        weathercheck(spell.element,sets.midcast.Cure)
    elseif spell.english == 'Impact' then
        weathercheck(spell.element,set_combine(sets.midcast['Elemental Magic'][macc_level][mp_efficiency],sets.Impact))
    elseif sets.midcast[spell.name] then
        weathercheck(spell.element,sets.midcast[spell.name])
    elseif spell.skill == 'Elemental Magic' then
        weathercheck(spell.element,sets.midcast['Elemental Magic'][macc_level][mp_efficiency])
        if AMII[spell.english] and player.merits[to_windower_api(spell.english)] > 2 then
            equip(sets.midcast.AMII)
        end
        if sets.ElementalMagicMAB[spell.element] then
            equip(sets.ElementalMagicMAB[spell.element])
        end
    elseif spell.skill then
        equip(sets.aftercast.Idle,sets.aftercast[tp_level])
        weathercheck(spell.element,sets.midcast[spell.skill])
    end
    
    if spell.english == 'Sneak' then
        send_command('cancel 71;')
    end
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
end

function self_command(command)
    if command == 'stuntarg' then
        stuntarg = player.target.name
    elseif command:lower() == 'macc' then
        macc_level = (macc_level+1)%2
        equip(sets.midcast['Elemental Magic'][macc_level][mp_efficiency])
        if macc_level == 1 then windower.add_to_chat(8,'MMMMMMActivated!')
        else windower.add_to_chat(8,'MDamaged') end
    elseif command:lower() == 'idle' then
        sets.aftercast.Idle.ind = (sets.aftercast.Idle.ind+1)%2
        windower.add_to_chat(8,'------------------------ '..sets.aftercast.Idle.keys[sets.aftercast.Idle.ind]..' Set is now the default Idle set -----------------------')
    end
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

function equip_idle_set()
    if buffactive['Mana Wall'] then
        equip(sets.aftercast.Idle[sets.aftercast.Idle.ind],sets.aftercast.Idle['Mana Wall'])
    else
        equip(sets.aftercast.Idle[sets.aftercast.Idle.ind])
    end
    if player.tp == 3000 then equip(sets.aftercast.Chry) end
end

function to_windower_api(str)
    return str:lower():gsub(' ','_')
end