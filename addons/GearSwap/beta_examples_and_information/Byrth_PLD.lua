function get_sets()
    
    sets.items = {item="Echo Drops"}
    
    sets.Enmity = {ammo="Iron Gobbet",head="Cab. Coronet +1",body="Cab. Surcoat +1",hands="Cab. Gauntlets +1",
        ring1="Eihwaz Ring",back="Fravashi Mantle",waist="Goading Belt",legs="Cab. Breeches +1",feet="Creed Sabatons +2"}
    
    sets.precast = {}
    sets.precast.FC = {ammo="Impatiens",
        head="Cizin Helm",neck="Orunmila's Torque",lear="Loquacious Earring",
        lring="Prolix Ring",legs="Enif Cosciales"}
    
    sets.midcast = {}
    sets.midcast['Shield Bash'] = set_combine(sets.Enmity,{hands="Caballarius Gauntlets +1"})
    sets.midcast.Chivalry = {hands="Caballarius Gauntlets +1"}
    sets.midcast.Cover = {head="Reverence Coronet +1",body="Cab. Surcoat +1"}
    sets.midcast.Sentinel = {feet="Cab. Leggings +1"}
    sets.midcast.Rampart = set_combine(sets.Enmity,{head="Cab. Coronet +1"})
    sets.midcast.Invincible = set_combine(sets.Enmity,{legs="Cab. Breeches +1"})
    sets.midcast.Fealty = {body="Cab. Surcoat +1"}
    sets.midcast['Holy Circle'] = {feet="Reverence Leggings +1"}
        
    sets.midcast['Chant du Cygne'] = {
        head="Yaoyotl Helm",neck="Aqua Gorget",ear1="Moonshade Earring",ear2="Brutal Earring",
        body="Phorcys Korazin",hands="Buremte Gloves",ring1="Thundersoul Ring",ring2="Rajas Ring",
        back="Rancorous Mantle",waist="Windbuffet Belt",legs="Reverence Breeches +1",feet="Scamp's Sollerets"}
        
    sets.midcast.Atonement = set_combine(sets.Enmity,{neck="Aqua Gorget",ear1="Moonshade Earring",
        body="Phorcys Korazin",waist="Aqua Belt",legs="Ogier's Breeches"})
        
    sets.midcast['Knights of Round'] = {
        head="Yaoyotl Helm",neck="Light Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Phorcys Korazin",hands="Buremte Gloves",ring1="Pyrosoul Ring",ring2="Rajas Ring",
        back="Atheling Mantle",waist="Light Belt",legs="Reverence Breeches +1",feet="Reverence Leggings +1"}
        
    sets.midcast.Resolution = {
        head="Yaoyotl Helm",neck="Soil Gorget",ear1="Moonshade Earring",ear2="Brutal Earring",
        body="Cab. Surcoat +1",hands="Umuthi Gloves",ring1="Pyrosoul Ring",ring2="Rajas Ring",
        back="Atheling Mantle",waist="Soil Belt",legs="Cab. Breeches +1",feet="Reverence Leggings +1"}
        
    sets.midcast.Torcleaver = {
        head="Yaoyotl Helm",neck="Light Gorget",ear1="Moonshade Earring",ear2="Brutal Earring",
        body="Cab. Surcoat +1",hands="Cab. Gauntlets +1",ring1="Pyrosoul Ring",ring2="Rajas Ring",
        back="Atheling Mantle",waist="Light Belt",legs="Cab. Breeches +1",feet="Scamp's Sollerets"}
        
    sets.midcast['Ground Strike'] = {
        head="Yaoyotl Helm",neck="Soil Gorget",ear1="Moonshade Earring",ear2="Brutal Earring",
        body="Cab. Surcoat +1",hands="Umuthi Gloves",ring1="Pyrosoul Ring",ring2="Rajas Ring",
        back="Atheling Mantle",waist="Soil Belt",legs="Cab. Breeches +1",feet="Reverence Leggings +1"}
        
    sets.midcast.WS = {
        head="Yaoyotl Helm",neck="Aqua Gorget",ear1="Moonshade Earring",ear2="Brutal Earring",
        body="Phorcys Korazin",hands="Buremte Gloves",ring1="Thundersoul Ring",ring2="Rajas Ring",
        back="Rancorous Mantle",waist="Windbuffet Belt",legs="Reverence Breeches +1",feet="Ejekamal Boots"}
        
    sets.midcast.Cure = {
        neck="Phalaina Locket",body="Reverence Surcoat +1",hands="Buremte Gloves",ring2="Meridian Ring",ring1="Eihwaz Ring",legs="Rev. Breeches +1",feet="Cab. Leggings +1"}
    sets.midcast.Cure_4 = {
        neck="Phalaina Locket",body="Reverence Surcoat +1",hands="Cab. Gauntlets +1",ring2="Meridian Ring",ring1="Eihwaz Ring",legs="Rev. Breeches +1",feet="Cab. Leggings +1"}
	
	sets.midcast.Phalanx = {legs="Reverence Breeches +1"}
    -- 386 is the next tier (21 skill away)
    -- Could get there with And earring, Col. Torque, Olympus Sash, and Merciful Cape, but it seems like a waste of space and durability.
	
	sets.midcast.Enlight = {body="Rev. Surcoat +1",ear1="Divine Earring"}
    -- This set puts me exactly on the next tier. Would need another 20 points of divine skill to reach the next tier.
	
	sets.midcast.Stoneskin = {neck="Stone Gorget",hands="Stone Mufflers",waist="Siegel Sash"}
    
    sets.aftercast = {}
    
    TP_sets = {'DD','DT'}
    TP_ind = 1
	
	sets.aftercast.non_DW = {ammo="Angha Gem",
        head="Reverence Coronet +1",neck="Asperity Necklace",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Cab. Surcoat +1",hands="Rev. Gauntlets +1",ring1="Defending Ring",ring2="Rajas Ring",
        back="Atheling Mantle",waist="Windbuffet Belt",legs="Reverence Breeches +1",feet="Ejekamal Boots"}

    sets.aftercast.DW = {ammo="Angha Gem",
        head="Reverence Coronet +1",neck="Asperity Necklace",ear1="Suppanomimi",ear2="Brutal Earring",
        body="Cab. Surcoat +1",hands="Rev. Gauntlets +1",ring1="Defending Ring",ring2="Rajas Ring",
        back="Atheling Mantle",waist="Windbuffet Belt",legs="Reverence Breeches +1",feet="Ejekamal Boots"}

    sets.aftercast.Ragnarok = {ammo="Ginsen",
        head="Yaoyotl Helm",neck="Asperity Necklace",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Cab. Surcoat +1",hands="Cizin Mufflers",ring1="K'ayres Ring",ring2="Rajas Ring",
        back="Atheling Mantle",waist="Goading Belt",legs="Cab. Breeches +1",feet="Ejekamal Boots"}
	
	sets.aftercast.DD = sets.aftercast.non_DW
	
    function sets.aftercast.wield(equip_sub)
		if equip_sub == 'Aegis' or equip_sub =='Ochain' then
			sets.aftercast.DD = sets.aftercast.non_DW
		elseif equip_sub == 'Bloodrain Strap' then
            sets.aftercast.DD = sets.aftercast.Ragnarok
        else
			sets.aftercast.DD = sets.aftercast.DW
		end
	end
        
    sets.aftercast.DT = {ammo="Angha Gem",
        head="Reverence Coronet +1",neck="Twilight Torque",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Cab. Surcoat +1",hands="Reverence Gauntlets +1",ring1="Defending Ring",ring2="Dark Ring",
        back="Mollusca Mantle",waist="Flume Belt",legs="Cab. Breeches +1",feet="Reverence Leggings +1"}
    
    Idle_sets = {'Idle','Kiting','Supertanking'}
    Idle_ind = 1
    sets.aftercast.Idle = {ammo="Angha Gem",
        head="Reverence Coronet +1",neck="Twilight Torque",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Cab. Surcoat +1",hands="Umuthi Gloves",ring1="Defending Ring",ring2="Meridian Ring",
        back="Mollusca Mantle",waist="Phasmida Belt",legs="Reverence Breeches +1",feet="Ejekamal Boots"}
        
    sets.aftercast.Kiting = {ammo="Angha Gem",
        head="Reverence Coronet +1",neck="Twilight Torque",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Cab. Surcoat +1",hands="Umuthi Gloves",ring1="Defending Ring",ring2="Meridian Ring",
        back="Mollusca Mantle",waist="Phasmida Belt",legs="Crimson Cuisses",feet="Ejekamal Boots"}
        
    sets.aftercast.Supertanking = {ammo="Angha Gem",
        head="Reverence Coronet +1",neck="Twilight Torque",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Cab. Surcoat +1",hands="Umuthi Gloves",ring1="Defending Ring",ring2="Meridian Ring",
        back="Mollusca Mantle",waist="Flume Belt",legs="Caballarius Breeches +1",feet="Reverence Leggings +1"}
    
    
    sets.pretarget = {}
    sets.pretarget.HP_Down = set_combine(sets.aftercast.Idle,
        {head="Lithelimb Cap",body="Cab. Surcoat +1",hands="Umuthi Gloves",ring2="Dark Ring",waist="Flume Belt",legs="Cab. Breeches +1",feet="Phorcys Schuhs"})

	sets.manual = {main="Buramenk'ah",sub="Aegis",head="Twilight Helm"}
	
    Cure_force = false
    send_command('input /macro book 20;wait .1;input /macro set 1')
end

function pretarget(spell)
    if spell.name == 'Cure IV' or spell.name == 'Cure III' and player.max_hp - player.hp < 328 and spell.target and spell.target.name == player.name then
        equip(sets.pretarget.HP_Down)
    end
end

function precast(spell)
	sets.aftercast.wield(player.equipment.sub)
    if player.equipment.head == 'Twilight Helm' and player.equipment.body == 'Twilight Mail' then disable('head','body') end
    if spell.action_type == 'Magic' then
        equip(sets.precast.FC)
    end
end

function midcast(spell)
    if player.status =='Engaged' then
        equip(sets.aftercast[TP_sets[TP_ind]])
    else
        equip(sets.aftercast[Idle_sets[Idle_ind]])
    end
    
	if spell.type == 'JobAbility' then
		equip(sets.Enmity)
	end
    if sets.midcast[spell.name] then
        equip(sets.midcast[spell.name])
    elseif spell.type == 'WeaponSkill' then
        equip(sets.precast.WS)
    elseif string.find(spell.name,'Cure') then
        if spell.name == 'Cure 4' and spell.target.name == player.name then
            equip(sets.Enmity,sets.midcast.Cure_4)
        else
            equip(sets.Enmity,sets.midcast.Cure)
        end
    end
end

function aftercast(spell)
    if player.status =='Engaged' then
        equip(sets.aftercast[TP_sets[TP_ind]])
    else
        equip(sets.aftercast[Idle_sets[Idle_ind]])
    end
end

function status_change(new,old)
    if T{'Idle','Resting'}:contains(new) then
        equip(sets.aftercast[Idle_sets[Idle_ind]])
    elseif new == 'Engaged' then
        equip(sets.aftercast[TP_sets[TP_ind]])
    end
end

function self_command(command)
    if command == 'toggle TP set' then
        if TP_ind == 1 then
            TP_ind = 2
            send_command('@input /echo SOLO SET')
        elseif TP_ind == 2 then
            TP_ind = 1
            send_command('@input /echo DD SET')
        end
    elseif command == 'toggle Idle set' then
        if Idle_ind == 1 then
            Idle_ind = 2
            send_command('@input /echo KITING SET')
        elseif Idle_ind == 2 then
            Idle_ind = 3
            send_command('@input /echo SUPERTANKING SET')
        elseif Idle_ind == 3 then
            Idle_ind = 1
            send_command('@input /echo NORMAL SET')
        end
    elseif command == 'DT' then
        equip(sets.DT)
    end
end