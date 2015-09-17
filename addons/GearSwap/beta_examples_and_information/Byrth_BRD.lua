function get_sets()
    sets.precast = {}
    sets.precast.JA = {}
    
    -- Precast Sets
    sets.precast.JA.Nightingale = {feet="Bihu Slippers +1"}
    
    sets.precast.JA.Troubadour = {body="Bihu Justaucorps +1"}
    
    sets.precast.JA['Soul Voice'] = {legs="Bihu Cannions +1"}
    
    sets.precast.FC = {}
    
    sets.precast.FC.Song = {main="Felibre's Dague",sub="Genbu's Shield",range="Linos",ammo=empty,
        head="Aoidos' Calot +2",neck="Orunmila's Torque",
        ear1={name="Loquac. Earring",priority=5},ear2="Enchanter Earring +1",body="Marduk's Jubbah +1",hands={name="Gendewitha Gages +1",priority=4},
        ring1="Veneficium Ring",ring2={name="Prolix Ring",priority=2},back="Swith Cape +1",waist="Witful Belt",legs={name="Gendewitha Spats +1",priority=1},
        feet={name="Bihu Slippers +1",priority=3}}
        
    sets.precast.FC.Normal = {range="Linos",ammo=empty,
        head="Nahtirah Hat",neck="Orunmila's Torque",ear1="Loquac. Earring",body="Marduk's Jubbah +1",
        hands="Gendewitha Gages +1",ring1="Veneficium Ring",ring2="Prolix Ring",back="Swith Cape +1",waist="Witful Belt",legs="Artsieq Hose",
        feet="Chelona Boots +1"}
        
    sets.precast.Cure = {body="Heka's Kalasiris",legs="Nabu's Shalwar",back="Pahtli Cape"}
    sets.precast.EnhancingMagic = {waist="Siegel Sash"}
    
    sets.precast.FC.Lightning = {main='Apamajas I',sub=empty,body="Dalmatica +1"}
    sets.precast.FC.Fire = {main='Atar I',sub=empty,body="Dalmatica +1"}
    
    sets.precast.WS = {}
    sets.precast.WS['Mordant Rime'] = {range="Gjallarhorn",ammo=empty,
        head="Brioso Roundlet +1",neck="Aqua Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Bihu Justaucorps +1",hands="Brioso Cuffs +1",ring1="Carbuncle Ring +1",ring2="Carbuncle Ring +1",
        back="Kumbira Cape",waist="Windbuffet Belt +1",legs="Bihu Cannions +1",feet="Battlecast Gaiters"}
    
    -- Midcast Sets
    sets.midcast = {}
        
    sets.midcast.Haste = {main="Terra's Staff",sub="Oneiros Grip",
        head={name="Nahtirah Hat",priority=11},neck="Orunmila's Torque",ear1="Loquac. Earring",ear2={name="Gifted Earring",priority=10},
        body={name="Hedera Cotehardie",priority=12},hands={name="Gendewitha Gages +1",priority=6},ring2={name="Prolix Ring",priority=7},
        back={name="Rhapsode's Cape",priority=9},waist="Phasmida Belt",legs="Bihu Cannions +1",feet={name="Chelona Boots +1",priority=8}}

    sets.midcast.Debuff = {main="Carnwenhan",sub="Genbu's Shield",range="Gjallarhorn",ammo=empty,
        head="Bihu Roundlet +1",neck="Wind Torque",ear1="Gwati Earring",ear2="Enchanter earring +1",
        body="Brioso Justaucorps +1",hands="Lurid Mitts",ring1="Carbuncle Ring +1",ring2="Carbuncle Ring +1",
        back="Rhapsode's Cape",waist="Ovate Rope",legs="Bihu Cannions +1",feet="Artsieq Boots"}
    
    sets.midcast.Buff = {main="Carnwenhan",sub="Genbu's Shield",head="Aoidos' Calot +2",neck="Aoidos' Matinee",
        body="Aoidos' Hngrln. +2",hands="Ad. Mnchtte. +2",legs="Mdk. Shalwar +1",feet="Brioso slippers +1"}
    
    sets.midcast.DBuff = {range="Daurdabla",ammo=empty}
    
    sets.midcast.GBuff = {range="Gjallarhorn",ammo=empty}
    
    sets.midcast.Duration = {body="Aoidos' Hngrln. +2",neck="Aoidos' Matinee",legs="Mdk. Shalwar +1",feet="Brioso slippers +1"}
        
    sets.midcast.Ballad = {legs="Aoidos' Rhing. +2"}
        
    sets.midcast.Scherzo = {feet="Aoidos' Cothrn. +2"}
        
    sets.midcast.Paeon = {head="Brioso Roundlet +1"}
    
    sets.midcast.Lullaby = {hands="Brioso Cuffs +1"}
    
    sets.midcast.Base = sets.midcast.Haste
    
    sets.midcast.Waltz = {}
        
    sets.midcast.Cure = {main="Chatoyant Staff",head="Marduk's Tiara +1",neck="Phalaina Locket",ear2="Novia earring",
        body="Heka's Kalasiris",hands="Bokwus Gloves",legs="Bihu Cannions +1",feet="Bihu Slippers +1"}
        
    sets.midcast.Stoneskin = {head="Marduk's Tiara +1",body="Marduk's Jubbah +1",hands="Marduk's Dastanas +1",
        legs="Shedir Seraweels",feet="Bihu Slippers +1"}
    
    
    --Aftercast Sets
    sets.aftercast = {}
    sets.aftercast.Regen = {main={name="Terra's Staff",order=1},sub={name="Oneiros Grip",order=2},range="Oneiros Harp",ammo=empty,
        head="Bihu Roundlet +1",neck="Twilight Torque",ear1={name="Loquac. Earring",order=7},ear2={name="Gifted Earring",order=5},
        body="Ischemia Chasu.",hands={name="Umuthi Gloves",order=9},ring1="Defending Ring",ring2={name="Dark Ring",order=8},
        back="Umbra Cape",waist="Flume Belt +1",legs={name="Nares Trews",order=6},feet="Aoidos' Cothrn. +2"}
    
    sets.aftercast.PDT = {main="Terra's Staff",sub="Oneiros Grip",range="Oneiros Harp",ammo=empty,
        head="Bihu Roundlet +1",neck="Twilight Torque",ear1="Loquac. Earring",ear2="Gifted Earring",
        body="Bihu Justaucorps +1",hands="Umuthi Gloves",ring1="Defending Ring",ring2="Dark Ring",
        back="Umbra Cape",waist="Flume Belt +1",legs="Gendewitha Spats +1",feet="Bihu Slippers +1"}
    
    sets.aftercast.Engaged = {range="Angel Lyre",ammo=empty,
        head="Lithelimb Cap",neck="Asperity Necklace",ear1="Brutal Earring",ear2="Suppanomimi",
        body="Bihu Justaucorps +1",hands="Umuthi Gloves",ring1="Ifrit Ring +1",ring2="Rajas Ring",
        back="Atheling Mantle",waist="Windbuffet Belt +1",legs="Bihu Cannions +1",feet="Battlecast Gaiters"}
        
    sets.aftercast._tab = {'Regen','PDT'}
    
    sets.aftercast._index = 1
    
    sets.aftercast.Idle = sets.aftercast[sets.aftercast._tab[sets.aftercast._index]]
    
    DaurdSongs = T{'Water Carol','Water Carol II','Ice Carol','Ice Carol II','Herb Pastoral','Goblin Gavotte'}
    
    send_command('input /macro book 3;wait .1;input /macro set 1')
    timer_reg = {}
    pianissimo_cycle = false
end

function pretarget(spell)
    if spell.type == 'BardSong' and spell.target.type and spell.target.type == 'PLAYER' and not buffactive.pianissimo and not spell.target.charmed and not pianissimo_cycle then
        cancel_spell()
        pianissimo_cycle = true
        send_command('input /ja "Pianissimo" <me>;wait 1.5;input /ma "'..spell.name..'" '..spell.target.name..';')
        return
    end
    if spell.name ~= 'Pianissimo' then
        pianissimo_cycle = false
    end
end

function precast(spell)
    if spell.type == 'BardSong' then
            equip_song_gear(spell)
            equip(sets.precast.FC.Song)
    elseif spell.action_type == 'Magic' then
        equip(sets.precast.FC.Normal)
        if string.find(spell.english,'Cur') and spell.name ~= 'Cursna' then
            equip(sets.precast.Cure)
        end
        if spell.skill == 'Enhancing Magic' then
            equip(sets.precast.EnhancingMagic)
        end
    elseif spell.prefix == '/weaponskill' then
        if sets.precast.WS[spell.name] then
            equip(sets.precast.WS[spell.name])
        end
    end
    
    if sets.precast.FC[tostring(spell.element)] then equip(sets.precast.FC[tostring(spell.element)]) end
    if sets.precast.JA[spell.english] then equip(sets.precast.JA[spell.english]) end
    if player.status == 'Engaged' then equip({range=nil}) end
end

function midcast(spell)
    if spell.type == 'BardSong' then
        equip_song_gear(spell)
    elseif string.find(spell.english,'Waltz') and spell.english ~= 'Healing Waltz' then
        equip(sets.midcast.Base,sets.midcast.Waltz)
    elseif string.find(spell.english,'Cur') then
        equip(sets.midcast.Base,sets.midcast.Cure)
    elseif spell.english=='Stoneskin' then
        equip(sets.midcast.Base,sets.midcast.Stoneskin)
    end
end

function aftercast(spell)
    if midaction() then return end
--[[    if spell.type and spell.type == 'BardSong' and spell.target and spell.target.type:upper() == 'SELF' then
        local t = os.time()
        
        -- Eliminate songs that have already expired
        local tempreg = {}
        for i,v in pairs(timer_reg) do
            if v < t then tempreg[i] = true end
        end
        for i,v in pairs(tempreg) do
            timer_reg[i] = nil
        end
        
        local dur = calculate_duration(spell.name)
        if timer_reg[spell.name] then
            if (timer_reg[spell.name] - t) <= 120 then
                send_command('timers delete "'..spell.name..'"')
                timer_reg[spell.name] = t + dur
                send_command('timers create "'..spell.name..'" '..dur..' down')
            end
        else
            local maxsongs = 2
            if player.equipment.range == 'Daurdabla' then
                maxsongs = maxsongs+2
            end
            if buffactive['Clarion Call'] then
                maxsongs = maxsongs+1
            end
            if maxsongs < table.length(timer_reg) then
                maxsongs = table.length(timer_reg)
            end
            
            if table.length(timer_reg) < maxsongs then
                timer_reg[spell.name] = t+dur
                send_command('timers create "'..spell.name..'" '..dur..' down')
            else
                local rep,repsong
                for i,v in pairs(timer_reg) do
                    if t+dur > v then
                        if not rep or rep > v then
                            rep = v
                            repsong = i
                        end
                    end
                end
                if repsong then
                    timer_reg[repsong] = nil
                    send_command('timers delete "'..repsong..'"')
                    timer_reg[spell.name] = t+dur
                    send_command('timers create "'..spell.name..'" '..dur..' down')
                end
            end
        end
    end]]
    if player.status == 'Engaged' then
        equip(sets.aftercast.Engaged)
    else
        equip(sets.aftercast.Idle)
    end
end

function status_change(new,old)
    if new == 'Engaged' then
        equip(sets.aftercast.Engaged)
        disable('main','sub','ammo')
    elseif T{'Idle','Resting'}:contains(new) then
        equip(sets.aftercast.Idle)
    end
end

function self_command(cmd)
    if cmd == 'unlock' then
        enable('main','sub','ammo')
    elseif cmd == 'midact' then
        midaction(false)
    elseif cmd == 'idle' then
        sets.aftercast._index = sets.aftercast._index%(#sets.aftercast._tab) + 1
        windower.add_to_chat(8,'Aftercast Set: '..sets.aftercast._tab[sets.aftercast._index])
        sets.aftercast.Idle = sets.aftercast[sets.aftercast._tab[sets.aftercast._index]]
        equip(sets.aftercast.Idle)
    end
end

function equip_song_gear(spell)
    if DaurdSongs:contains(spell.english) then
        equip(sets.midcast.Base,sets.midcast.DBuff)
    else
        if spell.target.type == 'MONSTER' then
            equip(sets.midcast.Base,sets.midcast.Debuff,sets.midcast.GBuff)
            if buffactive.troubadour or buffactive['elemental seal'] then
                equip(sets.midcast.Duration)
            end
            if string.find(spell.english,'Lullaby') then equip(sets.midcast.Duration,sets.midcast.Lullaby) end
        else
            equip(sets.midcast.Base,sets.midcast.Buff,sets.midcast.GBuff)
            if string.find(spell.english,'Ballad') then equip(sets.midcast.Ballad) end
            if string.find(spell.english,'Scherzo') then equip(sets.midcast.Scherzo) end
            if string.find(spell.english,'Paeon') then equip(sets.midcast.Paeon) end
        end
    end
end

function calculate_duration(name)
    local mult,ext = 1,0
    if player.equipment.range == 'Daurdabla' then mult = mult + 0.3 end
    if player.equipment.range == "Gjallarhorn" then mult = mult + 0.4 end
    
    if player.equipment.neck == "Aoidos' Matinee" then mult = mult + 0.1 end
    if player.equipment.feet == "Brioso Slippers" then mult = mult + 0.1 end
    if player.equipment.body == "Aoidos' Hngrln. +2" then mult = mult + 0.1 end
    if player.equipment.legs == "Mdk. Shalwar +1" then mult = mult + 0.1 end
    if player.equipment.main == "Carnwenhan" then mult = mult + 0.5 end
    
    if string.find(name,'March') and player.equipment.hands == 'Ad. Mnchtte. +2' then mult = mult + 0.1 end
    if string.find(name,'Minuet') and player.equipment.body == "Aoidos' Hngrln. +2" then mult = mult + 0.1 end
    if string.find(name,'Madrigal') and player.equipment.head == "Aoidos' Calot +2" then mult = mult + 0.1 end
    if string.find(name,'Ballad') and player.equipment.legs == "Aoidos' Rhing. +2" then mult = mult + 0.1 end
    if string.find(name,'Scherzo') and player.equipment.feet == "Aoidos' Cothrn. +2" then mult = mult + 0.1 end
    if string.find(name,'Paeon') and player.equipment.head == "Brioso Roundlet +1" then mult = mult + 0.1 end
    
    if buffactive.Troubadour then
        mult = mult*2
    end
    if string.find(name,'Scherzo') and buffactive['Soul Voice'] then
        mult = mult*2
    elseif string.find(name,'Scherzo') and buffactive.marcato then
        mult = mult*1.5
    end
    
    if buffactive['Clarion Call'] then
        ext = 20
    end
    
    return mult*120 + ext
end

function reset_timers()
    for i,v in pairs(timer_reg) do
        send_command('timers delete "'..i..'"')
    end
    timer_reg = {}
end

windower.register_event('zone change',reset_timers)
windower.register_event('logout',reset_timers)