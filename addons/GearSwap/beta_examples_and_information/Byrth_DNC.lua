function get_sets()
	sets = {}
	-------------------  JA Sets  ----------------------
	sets.JA = {}
	sets.JA.Waltz = {head="Khepri Bonnet",neck="Dualism Collar",lear="Novia Earring",
	body="Dnc. Casaque +1",hands="Buremte Gloves",lring="Veela Ring",rring="Valseur's Ring",
	back="Etoile Cape",waist="Aristo Belt",legs="Desultor Tassets",feet="Dance Shoes"}
	
	sets.JA.Samba = {head="Dancer's Tiara +1"}
	
	sets.JA.Jig = {legs='Etoile Tights +2',feet="Dancer's Toe Shoes +1"}
	
	sets.JA.Step = {ammo="Honed Tathlum",
		head="Whirlpool Mask",neck="Ziel Charm",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Manibozho Jerkin",hands="Buremte Gloves",ring1="Thundersoul Ring",ring2="Beeline Ring",
		back="Letalis Mantle",legs="Manibozho Brais",feet="Etoile Shoes +2"}
	
	sets.JA['Feather Step'] = set_combine(sets.JA.Step,{feet="Charis Shoes +2"})
	
	sets.JA['No Foot Rise'] = {body="Etoile Casaque +2"}
	
	sets.JA['Climactic Flourish'] = {head="Charis Tiara +2"}
	
	sets.JA['Striking Flourish'] = {body="Charis Casaque +2"}
	
	sets.JA['Reverse Flourish'] = {hands="Charis Bangles +2"}
	
	sets.JA['Violent Flourish'] = {ear1="Psystorm Earring",ear2="Lifestorm Earring",
		body="Etoile Casaque +2",lring="Omega Ring"}
	
	------------------  Idle Sets  ---------------------
	sets.Idle = {}
	sets.Idle.Normal = {head="Ocelomeh Headpiece +1",neck="Wiglen Gorget",lear="Novia Earring",rear="Musical Earring",
		body="Kheper Jacket",hands="Buremte Gloves",lring="Sheltered Ring",rring="Paguroidea Ring",
		back="Boxer's Mantle",waist="Scouter's Rope",legs="Nahtirah Trousers",feet="Skadi's Jambeaux +1"}
	
	-------------------  TP Sets  ----------------------
	sets.TP={}
	sets.TP.Normal = {ammo="Charis Feather",
		head="Uk'uxkaj cap",neck="Charis Necklace",ear1="Brutal Earring",ear2="Suppanomimi",
		body="Charis Casaque +2",hands="Skadi's bazubands +1",ring1="Epona's Ring",ring2="Rajas Ring",
		back="Rancorous Mantle",waist="Patentia Sash",legs="Manibozho Brais",feet="Manibozho Boots"}
	
	sets.TP['Haste Cap'] = {ammo="Charis Feather",
		head="Uk'uxkaj cap",neck="Nefarious Collar",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Thaumas Coat",hands="Skadi's bazubands +1",ring1="Epona's Ring",ring2="Rajas Ring",
		back="Rancorous Mantle",waist="Windbuffet Belt",legs="Manibozho Brais",feet="Manibozho Boots"}
	
	-------------------  WS Sets  ----------------------
	sets.WS={}
	
	sets.WS.Exenterator = {ammo="Potestas Bomblet",
		head="Uk'uxkaj cap",neck="Houyi's Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Manibozho Jerkin",hands="Skadi's bazubands +1",ring1="Epona's Ring",ring2="Stormsoul Ring",
		back="Atheling Mantle",waist="Windbuffet Belt",legs="Nahtirah Trousers",feet="Manibozho Boots"}
	
	sets.WS.Evisceration = {ammo="Charis Feather",
		head="Uk'uxkaj cap",neck="Love Torque",ear1="Brutal Earring",ear2="Moonshade Earring",
		body="Manibozho Jerkin",hands="Buremte Gloves",ring1="Thundersoul Ring",ring2="Rajas Ring",
		back="Rancorous Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Manibozho Boots"}
	
	sets.WS['Pyrrhic Kleos'] = {ammo="Charis Feather",
		head="Uk'uxkaj cap",neck="Soil Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Manibozho Jerkin",hands="Buremte Gloves",ring1="Epona's Ring",ring2="Rajas Ring",
		back="Atheling Mantle",waist="Wanion Belt",legs="Manibozho Brais",feet="Manibozho Boots"}
	
	-------------------  MA Sets  ----------------------
	sets.MA={}
	
	sets.MA.Utsusemi = {head="Uk'uxkaj cap",neck="Magoraga Beads",ear1="Musical Earring",ear2="Novia Earring",
		body="Manibozho Jerkin",legs="Thaumas Gloves",lring="Beeline Ring",
		back="Boxer Mantle",waist="Scouter's Rope",legs="Manibozho Legs",feet="Manibozho Boots"}
end

function precast(spell,act)
	--cast_delay(0.2)
	if sets.JA[spell.name] then
		equip(sets.JA[spell.name])
	elseif sets.WS[spell.name] then
		equip(sets.WS[spell.name])
	elseif string.find(spell.name,'Jig') then
		equip(sets.JA.Jig)
		if spell.name == 'Spectral Jig' then
			send_command('cancel 71')
		end
	elseif string.find(spell.name,'Samba') then
		equip(sets.JA.Samba)
	elseif string.find(spell.name,'Waltz') then
		equip(sets.JA.Waltz)
	elseif string.find(spell.name,'Step') then
		equip(sets.JA.Step)
	elseif string.find(spell.name,'Utsusemi') then
		equip(sets.MA.Utsusemi)
	elseif string.find(spell.name,'Monomi') then
		send_command('@wait 1.7;cancel 71')
	end
end

function aftercast(spell,act)
	if player.in_combat then
		if (buffactive['march'] == 2 and buffactive['haste']) or (buffactive['march'] and buffactive['embrava'] and buffactive['haste']) then
			equip(sets.TP['Haste Cap'])
		else
			equip(sets.TP.Normal)
		end
	else
		equip(sets.Idle.Normal)
	end
end