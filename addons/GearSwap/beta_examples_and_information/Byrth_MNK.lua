function get_sets()
	sets = {}
	sets.precast_Chakra = {ammo="Iron Gobbet",body="Omodaka Haramaki",hands="Mel. Gloves +2",ring1="Dark Ring",ring2="Dark Ring"}
	sets.precast_Counterstance = {feet="Mel. Gaiters +2"}
	sets.precast_Mantra = {feet="Mel. Gaiters +2"}
	sets.precast_Waltz = {head="Anwig Salade",neck="Dualism Collar",ring1="Valseur's Ring",ring2="Veela Ring",
		waist="Aristo Belt",legs="Desultor Tassets",feet="Dance Shoes"}
		
	sets.precast_midcast_WS = {ammo="Potestas Bomblet",head="Whirlpool Mask",neck="Justiciar's Torque",
		ear1="Steelflash Earring",ear2="Bladeborn Earring",body="Omodaka Haramaki",hands="Mel. Gloves +2",
		ring1="Rajas Ring",ring2="Pyrosoul Ring",back="Atheling Mantle",waist="Black Belt",legs="Manibozho Brais",
		feet="Usk. Sune-Ate +1"}
	
	sets.TP_DD = {ammo="Potestas Bomblet",head="Usk. Somen +1",neck="Asperity Necklace",
		ear1="Steelflash Earring",ear2="Bladeborn Earring",body="Thaumas Coat",hands="Miodio Gloves",
		ring1="Rajas Ring",ring2="Epona's Ring",back="Atheling Mantle",waist="Windbuffet Belt",legs="Manibozho Brais",
		feet="Usukane Sune-Ate +1"}
		
	sets.TP_Solo = {ammo="Potestas Bomblet",head="Whirlpool Mask",neck="Twilight Torque",
		ear1="Steelflash Earring",ear2="Bladeborn Earring",body="Thaumas Coat",hands="Mel. Gloves +2",
		ring1="Rajas Ring",ring2="Epona's Ring",back="Atheling Mantle",waist="Black Belt",legs="Manibozho Brais",
		feet="Usk. Sune-Ate +1"}
		
	sets.TP_Accuracy = {ammo="Honed Tathlum",head="Whirlpool Mask",neck="Ziel Charm",
		ear1="Steelflash Earring",ear2="Bladeborn Earring",body="Thaumas Coat",hands="Mel. Gloves +2",
		ring1="Rajas Ring",ring2="Epona's Ring",back="Letalis Mantle",waist="Black Belt",legs="Manibozho Brais",
		feet="Usk. Sune-Ate +1"}
		
	sets.PDT = {ammo="Iron Gobbet",neck="Twilight Torque",ear1="Merman's Earring",body="Omodaka Haramaki",
		hands="Melaco Mittens",ring1="Dark Ring",ring2="Dark Ring",back="Mollusca Mantle",waist="Black Belt"}
	
	sets.aftercast_TP = sets.TP_DD
	
	sets.aftercast_Idle = {ammo="Potestas Bomblet",head="Oce. Headpiece +1",neck="Wiglen Gorget",
		ear1="Merman's Earring",ear2="Bladeborn Earring",body="Kheper Jacket",hands="Melaco Mittens",
		ring1="Paguroidea Ring",ring2="Sheltered Ring",back="Boxer's Mantle",waist="Black Belt",legs="Manibozho Brais",
		feet="Hermes' Sandals"}
end

function precast(spell,action)
	if sets['precast_'..spell.english] then
		equip(sets['precast_'..spell.english])
	elseif spell.type=="WeaponSkill" then
		equip(sets['precast_midcast_WS'])
	elseif string.find(spell.english,'Waltz') then
		equip(sets['precast_Waltz'])
	end
end

function midcast(spell,action)
end

function aftercast(spell,action)
	if player.in_combat then
		equip(sets.aftercast_TP)
	else
		equip(sets.aftercast_Idle)
	end
end

function status_change(new,old)
	if T{'Idle','Resting'}:contains(new) then
		equip(sets['aftercast_Idle'])
	elseif new == 'Engaged' then
		equip(sets['aftercast_TP'])
	end
end

function buff_change(status,gain_or_loss)
end

function self_command(command)
	if command == 'toggle TP set' then
		if sets.aftercast_TP == sets.TP_DD then
			sets.aftercast_TP = sets.TP_Solo
			send_command('@input /echo SOLO SET')
		elseif sets.aftercast_TP == sets.TP_Solo then
			sets.aftercast_TP = sets.TP_Accuracy
			send_command('@input /echo ACC SET')
		else
			sets.aftercast_TP = sets.TP_DD
			send_command('@input /echo DD SET')
		end
	elseif command == 'PDT' then
		equip(sets.PDT)
	end
end