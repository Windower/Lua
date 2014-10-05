function get_sets()
    -------------------  JA Sets  ----------------------
    sets.JA = {}
    sets.JA.Precast_Waltz = {legs="Desultor Tassets"}
    
    waltz_mode = 0
    sets.JA.Waltz = {}
    sets.JA.Waltz[0] = {head="Anwig Salade",neck="Dualism Collar +1",lear="Novia Earring",rear="Roundel Earring",
    body="Maxixi Casaque +1",hands="Slither Gloves +1",lring="Carbuncle Ring +1",rring="Valseur's Ring",
    back="Toetapper Mantle",waist="Aristo Belt",legs="Desultor Tassets",feet="Maxixi Shoes +1"}
    
    sets.JA.Waltz[1] = {head="Horos Tiara +1",neck="Dualism Collar +1",lear="Novia Earring",rear="Roundel Earring",
    body="Maxixi Casaque +1",hands="Slither Gloves +1",lring="Carbuncle Ring +1",rring="Carbuncle Ring +1",
    back="Toetapper Mantle",waist="Aristo Belt",legs="Desultor Tassets",feet="Maxixi Shoes +1"}
    
    sets.JA.Samba = {head="Maxixi Tiara +1"}
    
    sets.JA.Jig = {legs='Horos Tights +1',feet="Maxixi Shoes +1"}
    
    sets.JA.Step = {ammo="Honed Tathlum",
        head="Whirlpool Mask",neck="Ej Necklace +1",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Maxixi Casaque +1",hands="Maxixi Bangles +1",ring1="Ramuh Ring +1",ring2="Beeline Ring",
        back="Toetapper Mantle",legs="Manibozho Brais",feet="Horos Toe Shoes +1"}
    
    sets.JA['Feather Step'] = set_combine(sets.JA.Step,{feet="Charis Shoes +2"})
    
    sets.JA['No Foot Rise'] = {body="Horos Casaque +1"}
    
    sets.JA['Climactic Flourish'] = {head="Charis Tiara +2"}
    
    sets.JA['Striking Flourish'] = {body="Charis Casaque +2"}
    
    sets.JA['Reverse Flourish'] = {hands="Charis Bangles +2",back={ name="Toetapper Mantle", augments={'"Store TP"+3','"Dual Wield"+4','"Rev. Flourish"+30',}}}
    
    sets.JA['Violent Flourish'] = {ear1="Gwati Earring",ear2="Enchanter Earring +1",
        body="Horos Casaque +1",lring="Omega Ring",rring="Sangoma Ring",legs='Horos Tights +1'}
    
    sets.JA.Trance = {head="Horos Tiara +1"}
    
    ------------------  Idle Sets  ---------------------
    sets.Idle = {}
    sets.Idle.index = {'Normal','MP','MDT'}
    Idle_ind = 1
    sets.Idle.Normal = {main="Terpsichore",sub="Izhiikoh",ammo="Tengu-no-Hane",
        head="Maxixi Tiara +1",neck="Ej Necklace +1",lear="Novia Earring",rear="Phawaylla Earring",
        body="Maxixi Casaque +1",hands="Horos Bangles +1",lring="Sheltered Ring",rring="Beeline Ring",
        back="Fugacity Mantle +1",waist="Kasiri Belt",legs="Nahtirah Trousers",feet="Skadi's Jambeaux +1"}
        
    sets.Idle.MP = {main="Terpsichore",sub="Izhiikoh",ammo="Strobilus",
        head="Felistris Mask",neck="Dualism Collar +1",lear="Novia Earring",rear="Phawaylla Earring",
        body="Maxixi Casaque +1",hands="Horos Bangles +1",lring="Dark Ring",rring="Defending Ring",
        back="Fugacity Mantle +1",waist="Kasiri Belt",legs="Nahtirah Trousers",feet="Skadi's Jambeaux +1"}
        
    sets.Idle.MDT={head="Uk'uxkaj cap",neck="Twilight Torque",lear="Merman's Earring",
        body="Maxixi Casaque +1",hands="Horos Bangles +1",lring="Dark Ring",rring="Defending Ring",
        back="Mollusca Mantle",waist="Wanion Belt",legs="Nahtirah Trousers",feet="Maxixi Shoes +1"}
    
    -------------------  TP Sets  ----------------------
    sets.TP={}
    sets.TP.index = {'Normal','Acc','DT','Eva'}
    TP_ind = 1
    
    sets.TP.Normal = {ammo="Ginsen",
        head="Felistris Mask",neck="Charis Necklace",ear1="Brutal Earring",ear2="Suppanomimi",
        body="Charis Casaque +2",hands="Maxixi Bangles +1",ring1="Epona's Ring",ring2="Rajas Ring",
        back={ name="Toetapper Mantle", augments={'"Store TP"+1','"Dual Wield"+5','"Rev. Flourish"+14',}},waist="Shetal Stone",legs="Quiahuiz Trousers",feet="Horos Toe Shoes +1"}
        
    sets.TP.Acc = {ammo="Honed Tathlum",
        head="Whirlpool Mask",neck="Ej Necklace +1",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Horos Casaque +1",hands="Iuitl Wristbands +1",ring1="Epona's Ring",ring2="Rajas Ring",
        back={ name="Toetapper Mantle", augments={'"Store TP"+1','"Dual Wield"+5','"Rev. Flourish"+14',}},waist="Windbuffet Belt +1",legs="Manibozho Brais",feet="Horos Toe Shoes +1"}
    
    sets.TP.DT = {ammo="Charis Feather",
        head="Lithelimb Cap",neck="Twilight Torque",ear1="Brutal Earring",ear2="Suppanomimi",
        body="Horos Casaque +1",hands="Iuitl Wristbands +1",ring1="Dark Ring",ring2="Defending Ring",
        back="Mollusca Mantle",waist="Shetal Stone",legs="Quiahuiz Trousers",feet="Iuitl Gaiters +1"}
    
    sets.TP.Eva = {main="Terpsichore",sub="Izhiikoh",ammo="Tengu-no-Hane",
        head="Maxixi Tiara +1",neck="Ej Necklace +1",lear="Novia Earring",rear="Phawaylla Earring",
        body="Qaaxo Harness",hands="Horos Bangles +1",lring="Garuda Ring +1",rring="Beeline Ring",
        back={ name="Toetapper Mantle", augments={'"Store TP"+1','"Dual Wield"+5','"Rev. Flourish"+14',}},waist="Kasiri Belt",legs="Nahtirah Trousers",feet="Horos Toe Shoes +1"}
    
    sets.TP['Haste Cap'] = {ammo="Charis Feather",
        head="Felistris Mask",neck="Nefarious Collar +1",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body={ name="Qaaxo Harness", augments={'Attack+15','Evasion+15','"Dbl.Atk."+2',}},hands="Maxixi Bangles +1",ring1="Epona's Ring",ring2="Rajas Ring",
        back="Rancorous Mantle",waist="Windbuffet Belt +1",legs="Quiahuiz Trousers",feet="Horos Toe Shoes +1"}
    
    -------------------  WS Sets  ----------------------
    sets.WS={}
    
    sets.WS.Exenterator = {Moonshade=false}
        
    sets.WS.Exenterator[0] = {ammo="Potestas Bomblet",
        head="Lithelimb Cap",neck="Houyi's Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Maxixi Casaque +1",hands="Horos Bangles +1",ring1="Epona's Ring",ring2="Garuda Ring +1",
        back="Vespid Mantle",waist="Caudata Belt",legs="Nahtirah Trousers",feet="Maxixi Shoes +1"}
        
    sets.WS.Exenterator[1] = {ammo="Potestas Bomblet",
        head="Whirlpool Mask",neck="Houyi's Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Maxixi Casaque +1",hands="Horos Bangles +1",ring1="Epona's Ring",ring2="Garuda Ring +1",
        back="Atheling Mantle",waist="Windbuffet Belt +1",legs="Nahtirah Trousers",feet="Maxixi Shoes +1"}

    sets.WS.Exenterator[2] = {ammo="Potestas Bomblet",
        head="Whirlpool Mask",neck="Houyi's Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Maxixi Casaque +1",hands="Horos Bangles +1",ring1="Epona's Ring",ring2="Garuda Ring +1",
        back="Atheling Mantle",waist="Windbuffet Belt +1",legs="Nahtirah Trousers",feet="Maxixi Shoes +1"}

    sets.WS.Evisceration = {Moonshade=true}

    sets.WS.Evisceration[0] = {ammo="Charis Feather",
        head="Horos Tiara +1",neck="Nefarious Collar +1",ear1="Brutal Earring",ear2="Moonshade Earring",
        body="Maxixi Casaque +1",hands="Maxixi Bangles +1",ring1="Epona's Ring",ring2="Rajas Ring",
        back="Rancorous Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Qaaxo Leggings"}

    sets.WS.Evisceration[1] = {ammo="Charis Feather",
        head="Uk'uxkaj cap",neck="Nefarious Collar +1",ear1="Brutal Earring",ear2="Moonshade Earring",
        body="Maxixi Casaque +1",hands="Maxixi Bangles +1",ring1="Ramuh Ring +1",ring2="Rajas Ring",
        back="Rancorous Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Qaaxo Leggings"}

    sets.WS.Evisceration[2] = {ammo="Charis Feather",
        head="Whirlpool Mask",neck="Nefarious Collar +1",ear1="Brutal Earring",ear2="Moonshade Earring",
        body="Maxixi Casaque +1",hands="Iuitl Wristbands +1",ring1="Ramuh Ring +1",ring2="Rajas Ring",
        back="Rancorous Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Qaaxo Leggings"}

    sets.WS['Pyrrhic Kleos'] = {Moonshade=false}

    sets.WS['Pyrrhic Kleos'][0] = {ammo="Potestas Bomblet",
        head="Felistris Mask",neck="Lacono Neck. +1",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Horos Casaque +1",hands="Maxixi Bangles +1",ring1="Ifrit Ring +1",ring2="Rajas Ring",
        back="Buquwik Cape",waist="Metalsinger Belt",legs="Manibozho Brais",feet="Qaaxo Leggings"}

    sets.WS['Pyrrhic Kleos'][1] = {ammo="Potestas Bomblet",
        head="Whirlpool Mask",neck="Lacono Neck. +1",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Horos Casaque +1",hands="Maxixi Bangles +1",ring1="Ifrit Ring +1",ring2="Rajas Ring",
        back="Atheling Mantle",waist="Metalsinger Belt",legs="Manibozho Brais",feet="Qaaxo Leggings"}

    sets.WS['Pyrrhic Kleos'][2] = {ammo="Charis Feather",
        head="Whirlpool Mask",neck="Soil Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Horos Casaque +1",hands="Iuitl Wristbands +1",ring1="Ifrit Ring +1",ring2="Rajas Ring",
        back="Letalis Mantle",waist="Caudata Belt",legs="Manibozho Brais",feet="Qaaxo Leggings"}

    sets.WS['Dancing Edge'] = {Moonshade=false}

    sets.WS['Dancing Edge'][0] = {ammo="Potestas Bomblet",
        head="Whirlpool Mask",neck="Lacono Neck. +1",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Maxixi Casaque +1",hands="Maxixi Bangles +1",ring1="Epona's Ring",ring2="Airy Ring",
        back="Vespid Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Maxixi Shoes +1"}
        
    sets.WS['Aeolian Edge'] = {Moonshade=nil}
    
    sets.WS['Aeolian Edge'][0] = {ammo="Charis Feather",
        head="Uk'uxkaj cap",neck="Soil Gorget",ear1="Moonshade Earring",ear2="Friomisi Earring",
        body="Dread Jupon",hands="Umuthi Gloves",ring1="Shiva Ring +1",ring2="Shiva Ring +1",
        back="Toro Cape",waist="Wanion Belt",legs="Horos Tights +1",feet="Qaaxo Leggings"}
        
    sets.WS["Rudra's Storm"] = {Moonshade=true}
    
    sets.WS["Rudra's Storm"][0] = {
        ammo="Charis Feather",
        head={ name="Uk'uxkaj Cap", augments={'Haste+2','"Snapshot"+2','DEX+8',}},
        body={ name="Horos Casaque +1", augments={'Enhances "No Foot Rise" effect',}},
        hands={ name="Horos Bangles +1", augments={'Enhances "Fan Dance" effect',}},
        legs={ name="Manibozho Brais", augments={'Attack+15','Accuracy+10','STR+10',}},
        feet={ name="Qaaxo Leggings", augments={'Attack+15','"Mag.Atk.Bns."+15','STR+12',}},
        neck="Aqua Gorget",
        waist="Windbuffet Belt +1",
        right_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +25',}},
        left_ear="Brutal Earring",
        left_ring="Ramuh Ring +1",
        right_ring="Rajas Ring",
        back={ name="Toetapper Mantle", augments={'"Store TP"+2','"Dual Wield"+1','"Rev. Flourish"+18','Weapon skill damage +3%',}},
    }
    
    sets.WS.Mad_w_moon = {ear1="Moonshade Earring",ear2="Kuwunga Earring"}
    sets.WS.Mad_wo_moon = {ear1="Brutal Earring",ear2="Kuwunga Earring"}

    -------------------  MA Sets  ----------------------
    sets.MA={}

    sets.MA.Utsusemi = {head="Felistris Mask",neck="Ej Necklace +1",ear1="Phawaylla Earring",ear2="Novia Earring",
        body="Maxixi Casaque +1",hands="Horos Bangles +1",lring="Beeline Ring",rring="Defending Ring",
        back="Fugacity Mantle +1",waist="Kasiri Belt",legs="Manibozho Brais",feet="Maxixi Shoes +1"}
        
    sets.MA.FastCast = {ammo="Impatiens",head="Haruspex Hat +1",neck="Orunmila's Torque",ear1="Loquacious Earring",ear2="Enchanter Earring +1",
        body="Dread Jupon",hands="Thaumas Gloves",lring="Prolix Ring",rring="Veneficium Ring"}
    
    sets.tengu = {ammo="Tengu-No-Hane"}
    
    atk_lvl = 1
    send_command('input /macro book 9;wait .1;input /macro set 2')
    dur_table = {}
    AM_start = 0
end

function precast(spell)
    if spell.action_type == 'Magic' then
        equip(sets.MA.FastCast)
        if string.find(spell.name,'Utsusemi') then
            equip({neck="Magoraga Beads"})
        end
    elseif spell.type == 'Waltz' then
        if buffactive['saber dance'] then
            windower.ffxi.cancel_buff(410)
        end
        equip(sets.JA.Precast_Waltz)
    elseif spell.type == 'Samba' and buffactive['fan dance'] then
        windower.ffxi.cancel_buff(411)
    elseif spell.name == 'Spectral Jig' and buffactive.sneak then
        windower.ffxi.cancel_buff(71)
    end
end

function filtered_action(spell)
    cancel_spell()
end

function midcast(spell)
    if sets.JA[spell.name] then
        equip(sets.JA[spell.name])
        if spell.name == "Feather Step" then
            tengu_handler()
        end
    elseif sets.WS[spell.name] then
        if sets.WS[spell.name][atk_lvl] then
            equip(sets.WS[spell.name][atk_lvl])
        elseif sets.WS[spell.name][0] then
            equip(sets.WS[spell.name][0])
        end
        if spell.name == 'Exenterator' or spell.name == "Pyrrhic Kleos" then
            tengu_handler()
        end
        if buffactive['Madrigal'] and sets.WS[spell.name].Moonshade == true then
            equip(sets.WS.Mad_w_moon)
        elseif buffactive['Madrigal'] and sets.WS[spell.name].Moonshade == false then
            equip(sets.WS.Mad_wo_moon)
        end
    elseif spell.type=='Jig' then
        equip(sets.JA.Jig)
    elseif spell.type=='Samba' then
        equip(sets.JA.Samba)
    elseif spell.type=='Waltz' then
        equip(sets.JA.Waltz[waltz_mode])
    elseif spell.type=='Step' then
        equip(sets.JA.Step)
        tengu_handler()
    elseif string.find(spell.name,'Utsusemi') then
        equip(sets.MA.Utsusemi)
    elseif string.find(spell.name,'Monomi') then
        send_command('@wait 1.7;cancel 71')
    end
    
    if spell.type == 'WeaponSkill' then
        if buffactive['climactic flourish'] then
            equip(sets.JA['Climactic Flourish'])
        elseif buffactive['striking flourish'] then
            equip(sets.JA['Striking Flourish'])
        end
    end
end

function tengu_handler()
    if world.time >= 360 and world.time < 1080 then -- 6~18
        equip(sets.tengu)
    end
end

function aftercast(spell)
    local dur,id
    if not spell or not spell.name then windower.add_to_chat(8,'Not spell') return end
    if spell.name:sub(1,11) == 'Chocobo Jig' and (not dur_table['Chocobo Jig'] or not dur_table['Chocobo Jig'] == 190) then
        id = 176
        dur = 190
    elseif spell.name == 'Spectral Jig' and (not dur_table['Spectral Jig'] or not dur_table['Spectral Jig'] == 270) then
        id = 69
        dur = 270
        send_command('st setduration 71 269;')
    elseif spell.name:sub(7,11) == 'Samba' then
        if spell.name:sub(1,11) == 'Drain Samba' then
            id = 368
            if #spell.name == 11 and (not dur_table['Drain Samba'] or not dur_table['Drain Samba'] == 165) then
                dur = 165
                dur_table['Drain Samba'] = 165
            elseif not dur['Drain Samba'] or not dur['Drain Samba'] == 135 then
                dur = 135
                dur_table['Drain Samba'] = 135
            end
        elseif spell.name:sub(1,11) == 'Aspir Samba' then
            id = 369
            if #spell.name == 11 and (not dur_table['Aspir Samba'] or not dur_table['Aspir Samba'] == 165) then
                dur = 165
                dur_table['Aspir Samba'] = 165
            elseif not dur['Aspir Samba'] or not dur['Aspir Samba'] == 135 then
                dur = 135
                dur_table['Aspir Samba'] = 135
            end
        elseif spell.name == 'Haste Samba' and (not dur_table['Haste Samba'] or not dur_table['Haste Samba'] == 135) then
            id = 370
            dur = 135
            dur_table['Haste Samba'] = 135
        end
        
--        if buffactive['saber dance'] then
--            dur = math.floor(dur*1.2)
--        end
    elseif spell.name == 'Trance' and (not dur_table['Trance'] or not dur_table['Trance'] == 80) then
        id = 376
        dur = 80
        dur_table['Trance'] = 165
--    elseif spell.name == 'Grand Pas' then
--        id = 507
--        dur = 60
--    elseif spell.name == 'Presto' then
--        id = 442
--        dur = 30
    end
    if id then
        send_command('st setduration '..id..' '..(dur-1)..';')
    end

    if player.status=='Engaged' then
        equip_TP_set()
    else
        equip(sets.Idle[sets.Idle.index[Idle_ind]])
    end
end

function status_change(new,old)
    if new == 'Engaged' then
        equip_TP_set()
    else
        equip(sets.Idle[sets.Idle.index[Idle_ind]])
    end
end

function equip_TP_set()
    if TP_ind == 1 and ( (buffactive['march'] == 2 and buffactive['haste']) or (buffactive['march'] and buffactive['embrava'] and buffactive['haste']) ) then
        sets.TP.index = {'Normal','Acc','DT','Eva','Haste Cap'}
        TP_ind = 5
    else
        sets.TP.index = {'Normal','Acc','DT','Eva'}
        if TP_ind == 5 then TP_ind = 1 end
    end
    equip(sets.TP[sets.TP.index[TP_ind]])
    tengu_handler()
end

function buff_change(buff,gain)
    if gain and not midaction() and TP_ind == 1 and ( (buffactive['march'] == 2 and buffactive['haste']) or (buffactive['march'] and buffactive['embrava'] and buffactive['haste']) ) then
        equip_TP_set()
    end
end

function self_command(command)
    if command == 'toggle TP set' then
        TP_ind = TP_ind +1
        if TP_ind > #sets.TP.index then TP_ind = 1 end
        windower.add_to_chat(8,'----- TP Set changed to '..sets.TP.index[TP_ind]..' -----')
        equip(sets.TP[sets.TP.index[TP_ind]])
    elseif command == 'toggle TP set back' then
        TP_ind = TP_ind -1
        if TP_ind < 1 then TP_ind = #sets.TP.index end
        windower.add_to_chat(8,'----- TP Set changed to '..sets.TP.index[TP_ind]..' -----')
        equip(sets.TP[sets.TP.index[TP_ind]])
    elseif command == 'toggle Idle set' then
        Idle_ind = Idle_ind +1
        if Idle_ind > #sets.Idle.index then Idle_ind = 1 end
        windower.add_to_chat(8,'----- Idle Set changed to '..sets.Idle.index[Idle_ind]..' -----')
        equip(sets.Idle[sets.Idle.index[Idle_ind]])
    elseif command == 'equip TP set' then
        equip_TP_set()
    elseif command == 'waltz_mode' then
        waltz_mode = (waltz_mode + 1)%2
        if waltz_mode == 1 then
            windower.add_to_chat(8,'----- Waltz Efficiency Setting -----')
        else
            windower.add_to_chat(8,'----- Waltz Recast Setting (Default) -----')
        end
    end
end