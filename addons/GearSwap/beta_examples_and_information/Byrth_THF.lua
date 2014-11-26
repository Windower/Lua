function get_sets()
    TP_Index = 1
    Idle_Index = 1

    sets.weapons = {}
    sets.weapons[1] = {main="Izhiikoh"}
    sets.weapons[2]={main="Twashtar"}
    sets.weapons[3]={main="Thief's Knife"}
    sets.weapons[4]={main="Mandau"}
    sets.weapons[5]={main="Atoyac"}
    
    sets.JA = {}
--    sets.JA.Conspirator = {body="Raider's Vest +2"}
--    sets.JA.Accomplice = {head="Raider's Bonnet +2"}
--    sets.JA.Collaborator = {head="Raider's Bonnet +2"}
    sets.JA['Perfect Dodge'] = {hands="Plun. Armlets +1"}
    sets.JA.Steal = {neck="Rabbit Charm",hands="Thief's Kote",
        waist="Key Ring Belt",feet="Pillager's Poulaines +1"}
    sets.JA.Flee = {feet="Pillager's Poulaines +1"}
--    sets.JA.Despoil = {legs="Raider's Culottes +2",feet="Raider's Poulaines +2"}
--    sets.JA.Mug = {head="Assassin's Bonnet +2"}
    sets.JA.Waltz = {head="Anwig Salade",neck="Dualism Collar +1",body="Iuitl Vest",hands="Slither Gloves +1",ring1="Valseur's Ring",ring2="Carbuncle Ring +1",
        waist="Aristo Belt",legs="Desultor Tassets",feet="Dance Shoes"}
    
    sets.WS = {}
    sets.WS.SA = {}
    sets.WS.TA = {}
    sets.WS.SATA = {}
    
    sets.WS.Evisceration = {head="Uk'uxkaj Cap",neck="Nefarious Collar +1",ear1="Moonshade Earring",ear2="Brutal Earring",
        body="Pillager's vest +1",hands="Pillager's Armlets +1",ring1="Rajas Ring",ring2="Ramuh Ring +1",
        back="Rancorous Mantle",waist="Wanion Belt",legs="Pillager's culottes +1",feet="Qaaxo Leggings"}
        
    sets.WS.SA.Evisceration = set_combine(sets.WS.Evisceration,{hands="Raider's Armlets +2"})

    sets.WS["Rudra's Storm"] = {head="Uk'uxkaj Cap",neck="Aqua Gorget",ear1="Moonshade Earring",ear2="Brutal Earring",
        body="Pillager's vest +1",hands="Iuitl Wristbands +1",ring1="Rajas Ring",ring2="Ramuh Ring +1",
        back="Vespid Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Iuitl Gaiters +1"}
        
    sets.WS.SA["Rudra's Storm"] = set_combine(sets.WS["Rudra's Storm"],{hands="Raider's Armlets +2",legs="Pillager's Culottes +1", feet="Plunderer's Poulaines +1"})
        
    sets.WS.TA["Mandalic Stab"] = set_combine(sets.WS["Rudra's Storm"],{hands="Pillager's Armlets +1",legs="Pillager's Culottes +1"})
    
    sets.WS["Mandalic Stab"] = {head="Uk'uxkaj Cap",neck="Light Gorget",ear1="Moonshade Earring",ear2="Brutal Earring",
        body="Pillager's vest +1",hands="Iuitl Wristbands +1",ring1="Rajas Ring",ring2="Ramuh Ring +1",
        back="Vespid Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Plunderer's Poulaines +1"}
        
    sets.WS.SA["Mandalic Stab"] = set_combine(sets.WS["Mandalic Stab"],{hands="Raider's Armlets +2",legs="Pillager's Culottes +1", feet="Plunderer's Poulaines +1"})
        
    sets.WS.TA["Mandalic Stab"] = set_combine(sets.WS["Mandalic Stab"],{hands="Pillager's Armlets +1",legs="Pillager's Culottes +1"})

    sets.WS.Exenterator = {head="Lithelimb Cap",neck="Houyi's Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Pillager's vest +1",hands="Iuitl Wristbands +1",ring1="Garuda Ring +1",ring2="Epona's Ring",
        back="Vespid Mantle",waist="Windbuffet Belt +1",legs="Nahtirah Trousers",feet="Plunderer's Poulaines +1"}

    sets.WS.TA.Exenterator = {head="Lithelimb Cap",neck="Houyi's Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Pillager's vest +1",hands="Pillager's Armlets +1",ring1="Garuda Ring +1",ring2="Epona's Ring",
        back="Vespid Mantle",waist="Windbuffet Belt +1",legs="Pillager's Culottes +1",feet="Plunderer's Poulaines +1"}
        
    sets.WS.SATA.Exenterator = sets.WS.TA.Exenterator
    
    sets.WS['Mercy Stroke'] = {head="Whirlpool Mask",neck="Lacono Necklace +1",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Pillager's vest +1",hands="Umuthi Gloves",ring1="Rajas Ring",ring2="Ifrit Ring +1",
        back="Buquwik Cape",waist="Metalsinger Belt",legs="Quiahuiz Trousers",feet="Qaaxo Leggings"}
    
    sets.WS.SA['Mercy Stroke'] = set_combine(sets.WS["Mercy Stroke"],{hands="Raider's Armlets +2",legs="Pillager's Culottes +1"})
    
    sets.WS.TA['Mercy Stroke'] = set_combine(sets.WS["Mercy Stroke"],{hands="Pillager's Armlets +1",legs="Pillager's Culottes +1"})
    
    TP_Set_Names = {"Low Man","Delay Cap","Evasion","TH","Acc"}
    sets.TP = {}
    sets.TP['Low Man'] = {range="Raider's Bmrng.",
        head="Felistris Mask",neck="Nefarious Collar +1",ear1="Suppanomimi",ear2="Brutal Earring",
        body="Qaaxo Harness",hands="Pill. Armlets +1",ring1="Rajas Ring",ring2="Epona's Ring",
        back="Canny Cape",waist="Shetal Stone",legs="Pill. Culottes +1",feet="Plunderer's Poulaines +1"}
        
    sets.TP['TH'] = {range="Raider's Bmrng.",
        head="Uk'uxkaj Cap",neck="Asperity Necklace",ear1="Suppanomimi",ear2="Brutal Earring",
        body="Qaaxo Harness",hands="Plun. Armlets +1",ring1="Rajas Ring",ring2="Epona's Ring",
        back="Canny Cape",waist="Shetal Stone",legs="Quiahuiz Trousers",feet="Raider's Poulaines +2"}
        
    sets.TP['Acc'] = {range="Raider's Bmrng.",
        head="Whirlpool Mask",neck="Ej Necklace +1",ear1="Suppanomimi",ear2="Brutal Earring",
        body="Manibozho Jerkin",hands="Plun. Armlets +1",ring1="Rajas Ring",ring2="Epona's Ring",
        back="Canny Cape",waist="Shetal Stone",legs="Pill. Culottes +1",feet="Pill. Poulaines +1"}
        
    sets.TP['Delay Cap'] = {range="Raider's Bmrng.",
        head="Uk'uxkaj Cap",neck="Asperity Necklace",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Qaaxo Harness",hands="Pill. Armlets +1",ring1="Rajas Ring",ring2="Epona's Ring",
        back="Rancorous Mantle",waist="Windbuffet Belt +1",legs="Pill. Culottes +1",feet="Plunderer's Poulaines +1"}
        
    sets.TP.Evasion = {
        head="Uk'uxkaj Cap",neck="Ej Necklace +1",ear1="Novia Earring",ear2="Phawaylla Earring",
        body="Qaaxo Harness",hands="Pill. Armlets +1",ring1="Beeline Ring",ring2="Epona's Ring",
        back="Fugacity Mantle +1",waist="Kasiri Belt",legs="Pill. Culottes +1",feet="Plunderer's Poulaines +1"}
    
    Idle_Set_Names = {'Normal','MDT'}
    sets.Idle = {}
    sets.Idle.Normal = {head="Lithelimb Cap",neck="Wiglen Gorget",ear1="Merman's Earring",ear2="Bladeborn Earring",
        body="Khepri Jacket",hands="Iuitl Wristbands +1",ring1="Paguroidea Ring",ring2="Sheltered Ring",
        back="Canny Cape",waist="Kasiri Belt",legs="Nahtirah Trousers",feet="Skadi's Jambeaux +1"}
                
    sets.Idle.MDT = {head="Uk'uxkaj Cap",neck="Twilight Torque",ear1="Merman's Earring",ear2="Bladeborn Earring",
        body="Avalon Breastplate",hands="Iuitl Wristbands +1",ring1="Defending Ring",ring2="Dark Ring",
        back="Mollusca Mantle",waist="Wanion Belt",legs="Nahtirah Trousers",feet="Skadi's Jambeaux +1"}
    send_command('input /macro book 12;wait .1;input /macro set 2')
    
end

function precast(spell)
    if sets.JA[spell.english] then
        equip(sets.JA[spell.english])
    elseif spell.type=="WeaponSkill" then
        if sets.WS[spell.english] then equip(sets.WS[spell.english]) end
        if buffactive['sneak attack'] and buffactive['trick attack'] and sets.WS.SATA[spell.english] then equip(sets.WS.SATA[spell.english])
        elseif buffactive['sneak attack'] and sets.WS.SA[spell.english] then equip(sets.WS.SA[spell.english])
        elseif buffactive['trick attack'] and sets.WS.TA[spell.english] then equip(sets.WS.TA[spell.english]) end
    elseif string.find(spell.english,'Waltz') then
        equip(sets.JA.Waltz)
    end
end

function aftercast(spell)
    if player.status=='Engaged' then
        equip(sets.TP[TP_Set_Names[TP_Index]])
    else
        equip(sets.Idle[Idle_Set_Names[Idle_Index]])
    end
end

function status_change(new,old)
    if T{'Idle','Resting'}:contains(new) then
        equip(sets.Idle[Idle_Set_Names[Idle_Index]])
    elseif new == 'Engaged' then
        equip(sets.TP[TP_Set_Names[TP_Index]])
    end
end

function buff_change(buff,gain_or_loss)
    if buff=="Sneak Attack" then
        soloSA = gain_or_loss
    elseif buff=="Trick Attack" then
        soloTA = gain_or_loss
    end
end

function self_command(command)
    if command == 'toggle TP set' then
        TP_Index = TP_Index +1
        if TP_Index > #TP_Set_Names then TP_Index = 1 end
        send_command('@input /echo ----- TP Set changed to '..TP_Set_Names[TP_Index]..' -----')
        equip(sets.TP[TP_Set_Names[TP_Index]])
    elseif command == 'toggle Idle set' then
        Idle_Index = Idle_Index +1
        if Idle_Index > #Idle_Set_Names then Idle_Index = 1 end
        send_command('@input /echo ----- Idle Set changed to '..Idle_Set_Names[Idle_Index]..' -----')
        equip(sets.Idle[Idle_Set_Names[Idle_Index]])
    end
end