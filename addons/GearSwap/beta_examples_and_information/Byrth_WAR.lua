function get_sets()
	sets = {}
	sets.JA_Berserk = {feet="War. Calligae +2"}
	sets.JA_Aggressor = {body="War. Lorica +2"}
	sets['JA_Blood Rage'] = {body="Rvg. Lorica +2"}
	sets['JA_Mighty Strikes'] = {hands="War. Mufflers +2"}
	sets.JA_Tomahawk = {ammo="Thr. Tomahawk",feet="War. Calligae +2"}
	
	
	sets.TP_Normal = {sub="Rose Strap",ammo="Ravager's Orb",
		head="Phorcys Salade",neck="Rancor Collar",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Rvg. Lorica +2",hands="Ogier's Gauntlets",ring1="Blitz Ring",ring2="Rajas Ring",
		back="Atheling Mantle",waist="Goading Belt",legs="Rvg. Cuisses +2",feet="Rvg. Calligae +2"}
	
	sets['WS_Raging Rush'] = {ammo="Ravager's Orb",
		head="Mekira-oto +1",neck="Rancor Collar",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Phorcys Korazin",hands="Hecatomb Mittens +1",ring1="Pyrosoul Ring",ring2="Rajas Ring",
		back="Atheling Mantle",waist="Windbuffet Belt",legs="Karieyh Brayettes",feet="Rvg. Calligae +2"}
	
	sets['WS_Upheaval'] = {ammo="Iron Gobbet",
		head="Mekira-oto +1",neck="Rancor Collar",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Phorcys Korazin",hands="Hecatomb Mittens +1",ring1="Pyrosoul Ring",ring2="Rajas Ring",
		back="Atheling Mantle",waist="Windbuffet Belt",legs="Karieyh Brayettes",feet="Rvg. Calligae +2"}
	
	sets.Idle = {ammo="Iron Gobbet",
		head="Adaman Barbuta",neck="Wiglen Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
		body="Kumarbi's Akar",hands="War. Mufflers +2",ring1="Sheltered Ring",ring2="Pagodeias Ring",
		back="Atheling Mantle",waist="Flume Belt",legs="Ogier's Breeches",feet="Hermes' Sandals"}
	
	sets.DT = {ammo="Iron Gobbet",
		head="Ogier's Helm",neck="Twilight Torque",ear1="Merman's Earring",ear2="Brutal Earring",
		body="Mekira Meikogai",hands="War. Mufflers +2",ring1="Dark Ring",ring2="Dark Ring",
		back="Mollusca Mantle",waist="Flume Belt",legs="Ogier's Breeches",feet="Phorcys Schuhs"}
end

function precast(spell,action)
	if T{'Berserk','Aggressor','Blood Rage','Tomahawk','Mighty Strikes'}:contains(spell.english) then
		equip(sets['JA_'..spell.english])
	elseif T{'Raging Rush','Upheaval'}:contains(spell.english) then
		equip(sets['WS_'..spell.english])
	end
end

function midcast(spell,action)
end

function aftercast(spell,action)
	if player.in_combat then
		equip(sets.TP_Normal)
	else
		equip(sets.Idle)
	end
end

function status_change(new,old)
	if T{'Idle','Resting'}:contains(new) then
		equip(sets['Idle'])
	elseif new == 'Engaged' then
		equip(sets['TP_Normal'])
	end
end

function buff_change(status,gain_or_loss)
end

function pet_midcast(spell,action)
end

function pet_aftercast(spell,action)
end

function self_command(command)
	if command == 'DT' then
		equip(sets.DT)
	end
end