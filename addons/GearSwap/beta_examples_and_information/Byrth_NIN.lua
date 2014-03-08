function get_sets()
    sets.precast = {}
    sets.precast.Waltz = {head="Anwig Salade",neck="Dualism Collar",ring1="Valseur's Ring",ring2="Veela Ring",
        waist="Aristo Belt",legs="Desultor Tassets",feet="Dance Shoes"}
        
    sets.precast['Blade: Hi'] = {head="Uk'uxkaj Cap",neck="Houyi's Gorget",
        ear1="Moonshade Earring",ear2="Brutal Earring",body="Manibozho Jerkin",hands="Thaumas Gloves",
        ring1="Stormsoul Ring",ring2="Epona's Ring",back="Rancorous Mantle",waist="Windbuffet Belt",legs="Nahtirah trousers",
        feet="Manibozho Boots"}
        
    sets.precast.WS = {head="Whirlpool Mask",neck="Soil Gorget",
        ear1="Steelflash Earring",ear2="Bladeborn Earring",body="Manibozho Jerkin",hands="Otronif Gloves",
        ring1="Rajas Ring",ring2="Pyrosoul Ring",back="Atheling Mantle",waist="Scouter's Rope",legs="Manibozho Brais",
        feet="Manibozho Boots"}
    
    sets.TP = {}
    sets.TP.DD = {main="Pamun",sub="Pamun",range="Aliyat Chakram",head="Iga Zukin +2",neck="Asperity Necklace",
        ear1="Suppanomimi",ear2="Brutal Earring",body="Hachiya Chainmail",hands="Otronif Gloves",
        ring1="Rajas Ring",ring2="Epona's Ring",back="Atheling Mantle",waist="Patentia Sash",legs="Quiahuiz Leggings",
        feet="Manibozho Boots"}
        
    sets.TP.Solo = {main="Pamun",sub="Pamun",range="Aliyat Chakram",head="Whirlpool Mask",neck="Twilight Torque",
        ear1="Suppanomimi",ear2="Brutal Earring",body="Thaumas Coat",hands="Otronif Gloves",
        ring1="Rajas Ring",ring2="Epona's Ring",back="Atheling Mantle",waist="Patentia Sash",legs="Quiahuiz Leggings",
        feet="Manibozho Boots"}
        
    sets.DT = {neck="Twilight Torque",ear1="Merman's Earring",body="Manibozho Jerkin",
        hands="Otronif Gloves",ring1="Defending Ring",ring2="Dark Ring",back="Mollusca Mantle",waist="Scouter's Rope"}
    
    sets.aftercast = {}
    sets.aftercast.TP = sets.TP.DD
    
    sets.aftercast.Idle = {main="Pamun",sub="Pamun",range="Aliyat Chakram",head="Oce. Headpiece +1",neck="Wiglen Gorget",
        ear1="Novia Earring",ear2="Phawaylla Earring",body="Kheper Jacket",hands="Otronif Gloves",
        ring1="Paguroidea Ring",ring2="Sheltered Ring",back="Boxer's Mantle",waist="Scouter's Rope",legs="Nahtirah trousers",
        feet="Iga Kyahan +2"}
        
    sets.precast.Ninjutsu = {neck="Magoraga Beads",ear1="Loquacious Earring",hands="Thaumas Gloves"}
        
    sets.Utsusemi = {head="Uk'uxkaj cap",neck="Magoraga Beads",ear1="Phawaylla Earring",ear2="Novia Earring",
        body="Manibozho Jerkin",legs="Thaumas Gloves",lring="Beeline Ring",
        back="Boxer's Mantle",waist="Scouter's Rope",legs="Manibozho Brais",feet="Iga Kyahan +2"}
        
    send_command('input /macro book 16;wait .1;input /macro set 1')
end

function precast(spell)
    if sets.precast[spell.english] then
        equip(sets.precast[spell.english])
    elseif spell.type=="WeaponSkill" then
        equip(sets.precast.WS)
    elseif string.find(spell.english,'Waltz') then
        equip(sets.precast.Waltz)
    elseif spell.type:lower() == 'ninjutsu' and spell.casttime > 1 then
        equip(sets.precast.Ninjutsu)
    end
end

function midcast(spell)
    if string.find(spell.english,'Utsusemi') then
        equip(sets.Utsusemi)
    end
end

function aftercast(spell)
    if player.status =='Engaged' then
        equip(sets.aftercast.TP)
    else
        equip(sets.aftercast.Idle)
    end
end

function status_change(new,old)
    if T{'Idle','Resting'}:contains(player.status) then
        equip(sets.aftercast.Idle)
    elseif player.status == 'Engaged' then
        equip(sets.aftercast.TP)
    end
end

function buff_change(status,gain_or_loss)
    if not midaction() then
        if player.status == 'Engaged' then
            equip(sets.aftercast.Engaged)
        else
            equip(sets.aftercast.Idle)
        end
    end
end

function self_command(command)
    if command == 'toggle TP set' then
        if sets.aftercast.TP == sets.TP.DD then
            sets.aftercast.TP = sets.TP.Solo
            send_command('@input /echo SOLO SET')
        elseif sets.aftercast.TP == sets.TP.Solo then
            sets.aftercast.TP = sets.TP.DD
            send_command('@input /echo DD SET')
        end
    elseif command == 'DT' then
        equip(sets.DT)
    end
end