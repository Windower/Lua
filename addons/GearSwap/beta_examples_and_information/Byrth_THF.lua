function get_sets()
	TP_Index = 1
	Idle_Index = 1

	sets.weapons = {}
	sets.weapons[1] = {main="Izhiikoh"}
	sets.weapons[2]={main="Twashtar"}
	sets.weapons[3]={main="Thief's Knife"}
	
	sets.JA = {}
	sets.JA.Conspirator = {body="Raider's Vest +2"}
	sets.JA.Accomplice = {head="Raider's Bonnet +2"}
	sets.JA.Collaborator = {head="Raider's Bonnet +2"}
	sets.JA['Perfect Dodge'] = {hands="Assassin's Armlets +2"}
	sets.JA.Steal = {head="Assassin's Bonnet +2",neck="Rabbit Charm",hands="Thief's Kote",
		waist="Key Ring Belt",legs="Assassin's Culottes",feet="Pillager's Poulaines"}
	sets.JA.Flee = {feet="Pillager's Poulaines"}
	sets.JA.Despoil = {legs="Raider's Culottes +2",feet="Raider's Poulaines +2"}
	sets.JA.Mug = {head="Assassin's Bonnet +2"}
	sets.JA.Waltz = {head="Anwig Salade",neck="Dualism Collar",body="Iuitl Vest",hands="Buremte Gloves",ring1="Valseur's Ring",ring2="Veela Ring",
		waist="Aristo Belt",legs="Desultor Tassets",feet="Dance Shoes"}
	
	sets.WS = {}
	sets.WS.SA = {}
	sets.WS.TA = {}
	sets.WS.SATA = {}
	
	sets.WS.Evisceration = {head="Uk'uxkaj Cap",neck="Nefarious Collar",ear1="Moonshade Earring",ear2="Brutal Earring",
		body="Manibozho Jerkin",hands="Pillager's Armlets",ring1="Rajas Ring",ring2="Thundersoul Ring",
		back="Rancorous Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Manibozho Boots"}
		
	sets.WS.SA.Evisceration = set_combine(sets.WS.Evisceration,{hands="Raider's Armlets +2"})

	sets.WS["Rudra's Storm"] = {head="Whirlpool Mask",neck="Love Torque",ear1="Moonshade Earring",ear2="Brutal Earring",
		body="Manibozho Jerkin",hands="Iuitl Wristbands",ring1="Rajas Ring",ring2="Thundersoul Ring",
		back="Atheling Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Iuitl Gaiters"}
		
	sets.WS.SA["Rudra's Storm"] = set_combine(sets.WS["Rudra's Storm"],{hands="Raider's Armlets +2"})

	sets.WS.Exenterator = {head="Uk'uxkaj Cap",neck="Houyi's Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Manibozho Jerkin",hands="Iuitl Wristbands",ring1="Stormsoul Ring",ring2="Epona's Ring",
		back="Atheling Mantle",waist="Windbuffet Belt",legs="Nahtirah Trousers",feet="Iuitl Gaiters"}

	sets.WS.TA.Exenterator = {head="Uk'uxkaj Cap",neck="Houyi's Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Manibozho Jerkin",hands="Pillager's Armlets",ring1="Stormsoul Ring",ring2="Epona's Ring",
		back="Atheling Mantle",waist="Windbuffet Belt",legs="Nahtirah Trousers",feet="Iuitl Gaiters"}
		
	sets.WS.SATA.Exenterator = sets.WS.TA.Exenterator
	
	TP_Set_Names = {"Low Man","Delay Cap","Evasion","TH"}
	sets.TP = {}
	sets.TP['Low Man'] = {range="Raider's Bmrng.",head="Uk'uxkaj Cap",neck="Nefarious Collar",
		ear1="Suppanomimi",ear2="Brutal Earring",body="Thaumas Coat",hands="Iuitl Wristbands",
		ring1="Rajas Ring",ring2="Epona's Ring",back="Atheling Mantle",waist="Patentia Sash",
		legs="Manibozho Brais",feet="Manibozho Boots"}
		
	sets.TP['TH'] = {range="Raider's Bmrng.",head="Ejekamal Mask",neck="Asperity Necklace",
		ear1="Suppanomimi",ear2="Brutal Earring",body="Thaumas Coat",hands="Assassin's Armlets +2",
		ring1="Rajas Ring",ring2="Epona's Ring",back="Atheling Mantle",waist="Patentia Sash",
		legs="Manibozho Brais",feet="Raider's Poulaines +2"}
		
	sets.TP['Delay Cap'] = {ammo="Potestas Bomblet",head="Iuitl Headgear",neck="Asperity Necklace",
		ear1="Steelflash Earring",ear2="Bladeborn Earring",body="Thaumas Coat",hands="Iuitl Wristbands",
		ring1="Rajas Ring",ring2="Epona's Ring",back="Rancorous Mantle",waist="Windbuffet Belt",
		legs="Manibozho Brais",feet="Manibozho Boots"}
		
	sets.TP.Evasion = {ranged="Aliyat Chakram",head="Uk'uxkaj Cap",neck="Torero Torque",
		ear1="Novia Earring",ear2="Phawaylla Earring",body="Manibozho Jerkin",hands="Iuitl Wristbands",
		ring1="Beeline Ring",ring2="Epona's Ring",back="Boxer's Mantle",waist="Scouter's Rope",
		legs="Manibozho Brais",feet="Manibozho Boots"}
	
	Idle_Set_Names = {'Normal','MDT'}
	sets.Idle = {}
	sets.Idle.Normal = {head="Oce. Headpiece +1",neck="Wiglen Gorget",ear1="Merman's Earring",ear2="Bladeborn Earring",
		body="Kheper Jacket",hands="Iuitl Wristbands",ring1="Paguroidea Ring",ring2="Sheltered Ring",
		back="Atheling Mantle",waist="Scouter's Rope",legs="Iuitl Tights",feet="Skadi's Jambeaux +1"}
				
	sets.Idle.MDT = {head="Uk'uxkaj Cap",neck="Twilight Torque",ear1="Merman's Earring",ear2="Bladeborn Earring",
		body="Avalon Breastplate",hands="Iuitl Wristbands",ring1="Defending Ring",ring2="Dark Ring",
		back="Mollusca Mantle",waist="Wanion Belt",legs="Nahtirah Trousers",feet="Skadi's Jambeaux +1"}
	send_command('input /macro book 12;wait .1;input /macro set 1')
	
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