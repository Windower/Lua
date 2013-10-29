function get_sets()
	TP_Index = 1
	Idle_Index = 1
	sets = {}
	
	sets.weapons = {}
	sets.weapons[1] = {main="Izhiikoh"}
	sets.weapons[2]={main="Aphotic Kukri"}
	sets.weapons[3]={main="Thief's Knife"}
	
	sets.JA_Conspirator = {body="Raider's Vest +2"}
	sets.JA_Accomplice = {head="Raider's Bonnet +2"}
	sets.JA_Collaborator = {head="Raider's Bonnet +2"}
	sets.JA_Steal = {head="Assassin's Bonnet +2",neck="Rabbit Charm",hands="Thief's Kote",
		waist="Key Ring Belt",legs="Assassin's Culottes",feet="Rogue's Poulaines"}
	sets.JA_Flee = {feet="Rogue's Poulaines"}
	sets.JA_Despoil = {legs="Raider's Culottes +2",feet="Raider's Poulaines +2"}
	sets.JA_Mug = {head="Assassin's Bonnet +2"}
	sets['precast_Perfect Dodge'] = {hands="Assassin's Armlets +2"}
	sets.JA_Waltz = {head="Anwig Salade",neck="Dualism Collar",ring1="Valseur's Ring",ring2="Veela Ring",
		waist="Aristo Belt",legs="Desultor Tassets",feet="Dance Shoes"}

	sets.WS_Evisceration = {head="Uk'uxkaj Cap",neck="Nefarious Collar",ear1="Moonshade Earring",ear2="Brutal Earring",
		body="Manibozho Jerkin",hands="Iuitl Wristbands",ring1="Rajas Ring",ring2="Thundersoul Ring",
		back="Rancorous Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Manibozho Boots"}

	sets.WS_Exenterator = {head="Uk'uxkaj Cap",neck="Houyi's Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Manibozho Jerkin",hands="Iuitl Wristbands",ring1="Stormsoul Ring",ring2="Epona's Ring",
		back="Atheling Mantle",waist="Windbuffet Belt",legs="Nahtirah Trousers",feet="Manibozho Boots"}

	sets.WS_TA_Exenterator = {head="Uk'uxkaj Cap",neck="Houyi's Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Manibozho Jerkin",hands="Rogue's Armlets +1",ring1="Stormsoul Ring",ring2="Epona's Ring",
		back="Atheling Mantle",waist="Windbuffet Belt",legs="Nahtirah Trousers",feet="Manibozho Boots"}
		
	sets.WS_SA_TA_Exenterator = sets.WS_TA_Exenterator
	
	TP_Set_Names = {"Low Man","Delay Cap","Evasion","TH"}
	sets.TP = {}
	sets.TP['Low Man'] = {ranged="Raider's Boomerang",head="Uk'uxkaj Cap",neck="Nefarious Collar",
		ear1="Suppanomimi",ear2="Brutal Earring",body="Thaumas Coat",hands="Iuitl Wristbands",
		ring1="Rajas Ring",ring2="Epona's Ring",back="Atheling Mantle",waist="Patentia Sash",
		legs="Manibozho Brais",feet="Manibozho Boots"}
		
	sets.TP['TH'] = {ranged="Raider's Boomerang",head="Uk'uxkaj Cap",neck="Asperity Necklace",
		ear1="Suppanomimi",ear2="Brutal Earring",body="Thaumas Coat",hands="Assassin's Armlets +2",
		ring1="Rajas Ring",ring2="Epona's Ring",back="Rancorous Mantle",waist="Patentia Sash",
		legs="Manibozho Brais",feet="Raider's Poulaines +2"}
		
	sets.TP['Delay Cap'] = {ammo="Potestas Bomblet",head="Uk'uxkaj Cap",neck="Asperity Necklace",
		ear1="Steelflash Earring",ear2="Bladeborn Earring",body="Thaumas Coat",hands="Iuitl Wristbands",
		ring1="Rajas Ring",ring2="Epona's Ring",back="Rancorous Mantle",waist="Windbuffet Belt",
		legs="Manibozho Brais",feet="Manibozho Boots"}
		
	sets.TP.Evasion = {ranged="Aliyat Chakram",head="Uk'uxkaj Cap",neck="Torero Torque",
		ear1="Novia Earring",ear2="Musical Earring",body="Skadi's Cuirie +1",hands="Iuitl Wristbands",
		ring1="Beeline Ring",ring2="Epona's Ring",back="Boxer's Mantle",waist="Scouter's Rope",
		legs="Manibozho Brais",feet="Manibozho Boots"}
	
	Idle_Set_Names = {'Normal','MDT'}
	sets.Idle = {}
	sets.Idle.Normal = {head="Oce. Headpiece +1",neck="Wiglen Gorget",ear1="Merman's Earring",ear2="Bladeborn Earring",
		body="Kheper Jacket",hands="Iuitl Wristbands",ring1="Paguroidea Ring",ring2="Sheltered Ring",
		back="Atheling Mantle",waist="Scouter's Rope",legs="Iuitl Tights",feet="Skadi's Jambeaux +1"}
				
	sets.Idle.MDT = {head="Uk'uxkaj Cap",neck="Twilight Torque",ear1="Merman's Earring",ear2="Bladeborn Earring",
		body="Avalon Breastplate",hands="Iuitl Wristbands",ring1="Dark Ring",ring2="Dark Ring",
		back="Mollusca Mantle",waist="Wanion Belt",legs="Nahtirah Trousers",feet="Skadi's Jambeaux +1"}
	
end

function precast(spell,action)
	verify_equip()
	if sets['precast_'..spell.english] then
		equip(sets['JA_'..spell.english])
	elseif spell.type=="WeaponSkill" then
		local satavar = ''
		if buffactive['sneak attack'] then satavar = satavar..'SA_' end
		if buffactive['trick attack'] then satavar = satavar..'TA_' end
		if sets['WS_'..satavar..spell.english] then
			equip(sets['WS_'..satavar..spell.english])
		elseif sets['WS_'..spell.english] then
			equip(sets['WS_'..spell.english])
		end
	elseif string.find(spell.english,'Waltz') then
		equip(sets['JA_Waltz'])
	end
end

function midcast(spell,action)
end

function aftercast(spell,action)
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
		soloSA = (gain_or_loss == "gain")
	elseif buff=="Trick Attack" then
		soloTA = (gain_or_loss == "gain")
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