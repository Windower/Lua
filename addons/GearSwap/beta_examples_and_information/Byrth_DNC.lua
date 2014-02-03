function get_sets()
	-------------------  JA Sets  ----------------------
	sets.JA = {}
	sets.JA.Waltz = {head="Khepri Bonnet",neck="Dualism Collar",lear="Novia Earring",rear="Roundel Earring",
	body="Maxixi Casaque",hands="Maxixi Bangles +1",lring="Veela Ring",rring="Valseur's Ring",
	back="Toetapper Mantle",waist="Aristo Belt",legs="Desultor Tassets",feet="Maxixi Toeshoes"}
	
	sets.JA.Samba = {head="Maxixi Tiara +1"}
	
	sets.JA.Jig = {legs='Etoile Tights +2',feet="Maxixi Toeshoes"}
	
	sets.JA.Step = {ammo="Honed Tathlum",
		head="Whirlpool Mask",neck="Ziel Charm",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Manibozho Jerkin",hands="Maxixi Bangles +1",ring1="Thundersoul Ring",ring2="Beeline Ring",
		back="Toetapper Mantle",legs="Manibozho Brais",feet="Etoile Shoes +2"}
	
	sets.JA['Feather Step'] = set_combine(sets.JA.Step,{feet="Charis Shoes +2"})
	
	sets.JA['No Foot Rise'] = {body="Etoile Casaque +2"}
	
	sets.JA['Climactic Flourish'] = {head="Charis Tiara +2"}
	
	sets.JA['Striking Flourish'] = {body="Charis Casaque +2"}
	
	sets.JA['Reverse Flourish'] = {hands="Charis Bangles +2"}
	
	sets.JA['Violent Flourish'] = {ear1="Psystorm Earring",ear2="Lifestorm Earring",
		body="Etoile Casaque +2",lring="Omega Ring",rring="Sangoma Ring"}
	
	sets.JA.Trance = {head="Etoile Tiara +2"}
	
	------------------  Idle Sets  ---------------------
	sets.Idle = {}
	sets.Idle.index = {'Normal','MDT'}
	Idle_ind = 1
	sets.Idle.Normal = {main="Terpsichore",sub="Izhiikoh",ammo="Potestas Bomblet",
		head="Oce. Headpiece +1",neck="Wiglen Gorget",lear="Novia Earring",rear="Phawaylla Earring",
		body="Kheper Jacket",hands="Maxixi Bangles +1",lring="Sheltered Ring",rring="Paguroidea Ring",
		back="Boxer's Mantle",waist="Scouter's Rope",legs="Nahtirah Trousers",feet="Skadi's Jambeaux +1"}
		
	sets.Idle.MDT={head="Uk'uxkaj cap",neck="Twilight Torque",lear="Merman's Earring",
		body="Avalon Breastplate",hands="Maxixi Bangles +1",lring="Defending Ring",rring="Dark Ring",
		back="Mollusca Mantle",waist="Wanion Belt",legs="Nahtirah Trousers",feet="Manibozho Boots"}
	
	-------------------  TP Sets  ----------------------
	sets.TP={}
	sets.TP.index = {'Normal','DT'}
	TP_ind = 1
	
	sets.TP.Normal = {ammo="Charis Feather",
		head="Ejekamal Mask",neck="Charis Necklace",ear1="Brutal Earring",ear2="Suppanomimi",
		body="Charis Casaque +2",hands="Iuitl Wristbands",ring1="Epona's Ring",ring2="Rajas Ring",
		back="Rancorous Mantle",waist="Patentia Sash",legs="Quiahuiz Leggings",feet="Manibozho Boots"}
		
	sets.TP.Acc = {ammo="Honed Tathlum",
		head="Whirlpool Mask",neck="Ziel Charm",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Manibozho Jerkin",hands="Iuitl Wristbands",ring1="Epona's Ring",ring2="Rajas Ring",
		back="Atheling Mantle",waist="Windbuffet Belt",legs="Manibozho Brais",feet="Manibozho Boots"}
	
	sets.TP.DT = {ammo="Charis Feather",
		head="Iuitl headgear",neck="Twilight Torque",ear1="Brutal Earring",ear2="Suppanomimi",
		body="Charis Casaque +2",hands="Iuitl Wristbands",ring1="Dark Ring",ring2="Defending Ring",
		back="Mollusca Mantle",waist="Patentia Sash",legs="Quiahuiz Leggings",feet="Iuitl Gaiters"}
	
	sets.TP['Haste Cap'] = {ammo="Charis Feather",
		head="Iuitl Headgear",neck="Nefarious Collar",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Thaumas Coat",hands="Iuitl Wristbands",ring1="Epona's Ring",ring2="Rajas Ring",
		back="Rancorous Mantle",waist="Windbuffet Belt",legs="Quiahuiz Leggings",feet="Manibozho Boots"}
	
	-------------------  WS Sets  ----------------------
	sets.WS={}
	
	sets.WS.Exenterator = {}
		
	sets.WS.Exenterator[1] = {ammo="Potestas Bomblet",
		head="Whirlpool Mask",neck="Houyi's Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Manibozho Jerkin",hands="Iuitl Wristbands",ring1="Epona's Ring",ring2="Stormsoul Ring",
		back="Atheling Mantle",waist="Windbuffet Belt",legs="Nahtirah Trousers",feet="Iuitl Gaiters"}

	sets.WS.Exenterator[2] = {ammo="Potestas Bomblet",
		head="Uk'uxkaj cap",neck="Houyi's Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Manibozho Jerkin",hands="Iuitl Wristbands",ring1="Epona's Ring",ring2="Stormsoul Ring",
		back="Atheling Mantle",waist="Windbuffet Belt",legs="Nahtirah Trousers",feet="Iuitl Gaiters"}

	sets.WS.Evisceration = {}

	sets.WS.Evisceration[1] = {ammo="Charis Feather",
		head="Uk'uxkaj cap",neck="Love Torque",ear1="Brutal Earring",ear2="Moonshade Earring",
		body="Manibozho Jerkin",hands="Maxixi Bangles +1",ring1="Thundersoul Ring",ring2="Rajas Ring",
		back="Rancorous Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Manibozho Boots"}

	sets.WS.Evisceration[2] = {ammo="Charis Feather",
		head="Uk'uxkaj cap",neck="Love Torque",ear1="Brutal Earring",ear2="Moonshade Earring",
		body="Manibozho Jerkin",hands="Maxixi Bangles +1",ring1="Thundersoul Ring",ring2="Rajas Ring",
		back="Rancorous Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Manibozho Boots"}

	sets.WS['Pyrrhic Kleos'] = {}

	sets.WS['Pyrrhic Kleos'][1] = {ammo="Potestas Bomblet",
		head="Whirlpool Mask",neck="Justiciar's Torque",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Manibozho Jerkin",hands="Iuitl Wristbands",ring1="Epona's Ring",ring2="Rajas Ring",
		back="Atheling Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Iuitl Gaiters"}

	sets.WS['Pyrrhic Kleos'][2] = {ammo="Charis Feather",
		head="Uk'uxkaj cap",neck="Soil Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Manibozho Jerkin",hands="Maxixi Bangles +1",ring1="Epona's Ring",ring2="Rajas Ring",
		back="Atheling Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Iuitl Gaiters"}

	-------------------  MA Sets  ----------------------
	sets.MA={}

	sets.MA.Utsusemi = {head="Uk'uxkaj cap",neck="Magoraga Beads",ear1="Phawaylla Earring",ear2="Novia Earring",
		body="Manibozho Jerkin",legs="Thaumas Gloves",lring="Beeline Ring",
		back="Boxer's Mantle",waist="Scouter's Rope",legs="Manibozho Brais",feet="Manibozho Boots"}
		
	atk_lvl = 1
	send_command('input /macro book 9;wait .1;input /macro set 1')
end

function precast(spell,act)
	cast_delay(0)
	if sets.JA[spell.name] then
		if spell.name == 'Trance' and buffactive['saber dance'] then
			send_command('cancel 410')
		end
		equip(sets.JA[spell.name])
	elseif sets.WS[spell.name] then
		if sets.WS[spell.name][atk_lvl] then
			equip(sets.WS[spell.name][atk_lvl])
		end
	elseif spell.type=='Jig' then
		equip(sets.JA.Jig)
		if spell.name == 'Spectral Jig' and buffactive.sneak then
			send_command('cancel 71')
		end
	elseif spell.type=='Samba' then
		if buffactive['fan dance'] then
			send_command('cancel 411')
		end
		equip(sets.JA.Samba)
	elseif spell.type=='Waltz' then
		if buffactive['saber dance'] then
			send_command('cancel 410')
		end
		equip(sets.JA.Waltz)
	elseif spell.type=='Step' then
		equip(sets.JA.Step)
	elseif string.find(spell.name,'Utsusemi') then
		equip(sets.MA.Utsusemi)
	elseif string.find(spell.name,'Monomi') then
		send_command('@wait 1.7;cancel 71')
	end
	
	if spell.type == 'WeaponSkill' then
		if buffactive['climactic flourish'] then
			equip({head='Charis Tiara +2'})
		elseif buffactive['striking flourish'] then
			equip({body='Charis Casaque +2'})
		end
	end
end

function aftercast(spell,act)
	local dur,id
	if spell.name:sub(1,11) == 'Chocobo Jig' then
		id = 176
		dur = 190
	elseif spell.name:sub(7,11) == 'Samba' then
		if spell.name:sub(1,11) == 'Drain Samba' then
			id = 368
			if #spell.name == 11 then
				dur = 165
			else
				dur = 135
			end
		elseif spell.name:sub(1,11) == 'Aspir Samba' then
			id = 369
			if #spell.name == 11 then
				dur = 165
			else
				dur = 135
			end
		elseif spell.name == 'Haste Samba' then
			id = 370
			dur = 135
		end
		
		if buffactive['saber dance'] then
			dur = math.floor(dur*1.2)
		end
	elseif spell.name == 'Trance' then
		id = 376
		dur = 60
	elseif spell.name == 'Grand Pas' then
		id = 507
		dur = 60
	elseif spell.name == 'Presto' then
		id = 442
		dur = 30
	end
	if id then
		send_command('st setduration '..id..' '..(dur-1)..';')
	end

	if player.status=='Engaged' then
		equip_TP_set()
	else
		equip(sets.Idle.Normal)
	end
end

function status_change(new,old)
	if new == 'Engaged' then
		equip_TP_set()
	else
		equip(sets.Idle.Normal)
	end
end

function equip_TP_set()
	if TP_ind == 1 and ( (buffactive['march'] == 2 and buffactive['haste']) or (buffactive['march'] and buffactive['embrava'] and buffactive['haste']) ) then
		equip(sets.TP['Haste Cap'])
	else
		equip(sets.TP[sets.TP.index[TP_ind]])
	end
end

function self_command(command)
	if command == 'toggle TP set' then
		TP_ind = TP_ind +1
		if TP_ind > #sets.TP.index then TP_ind = 1 end
		send_command('@input /echo ----- TP Set changed to '..sets.TP.index[TP_ind]..' -----')
		equip(sets.TP[sets.TP.index[TP_ind]])
	elseif command == 'toggle Idle set' then
		Idle_ind = Idle_ind +1
		if Idle_ind > #sets.Idle.index then Idle_ind = 1 end
		send_command('@input /echo ----- Idle Set changed to '..sets.Idle.index[Idle_ind]..' -----')
		equip(sets.Idle[sets.Idle.index[Idle_ind]])
	elseif command == 'equip TP set' then
		equip_TP_set()
	end
end