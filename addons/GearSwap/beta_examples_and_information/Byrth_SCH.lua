function get_sets()
	sets = {}
	sets.precast_Stun = {main="Apamajas II",sub="Arbuda Grip",ammo="Hasty Pinion",
		head="Zelus Tiara",neck="Aesir Torque",ear1="Belatz Pearl",ear2="Loquacious Earring",
		body="Hedera Cotehardie",hands="Repartie Gloves",lring="Balrahn's Ring",rring="Angha Ring",
		back="Swith Cape",waist="Goading Belt",legs="Rubeus Spats",feet="Scholar's Loafers"}
	
	sets.aftercast_Idle_noSub = {main="Terra's Staff",sub="Arbuda Grip",ammo="Mana ampulla",
		head="Savant's bonnet +2",neck="Twilight Torque",ear1="Gifted earring",ear2="Loquacious Earring",
		body="Heka's Kalasiris",hands="Serpentes Cuffs",ring1="Dark Ring",ring2="Dark Ring",
		back="Umbra Cape",waist="Hierarch Belt",legs="Nares Trews",feet="Herald's Gaiters"}
	
	sets.aftercast_Idle_Sub = {main="Terra's Staff",sub="Arbuda Grip",ammo="Mana ampulla",
		head="Savant's bonnet +2",neck="Twilight Torque",ear1="Savant's earring",ear2="Loquacious Earring",
		body="Heka's Kalasiris",hands="Serpentes Cuffs",ring1="Dark Ring",ring2="Dark Ring",
		back="Umbra Cape",waist="Hierarch Belt",legs="Nares Trews",feet="Herald's Gaiters"}
	
	sets.aftercast_Idle = sets.aftercast_Idle_noSub
		
	sets.precast_FastCast = {head="Nares Cap",neck="Stoicheion Medal",ear2="Loquacious Earring",
		body="Anhur Robe",back="Swith Cape",waist="Siegel Sash",feet="Argute Loafers +2"}
	
	sets.Resting = {main="Numen Staff",sub="Ariesian Grip",ammo="Mana ampulla",
		head="Hydra Beret",neck="Eidolon Pendant",ear1="Relaxing Earring",ear2="Antivenom Earring",
		body="Heka's Kalasiris",hands="Nares Cuffs",ring1="Star Ring",ring2="Angha Ring",
		back="Vita Cape",waist="Austerity Belt",legs="Nares Trews",feet="Serpentes Sabots"}
	
	sets.midcast_ElementalMagic = {main="Chatoyant Staff",sub="Wizzan Grip",ammo="Snow Sachet",
		head="Nares Cap",neck="Stoicheion Medal",ear1="Hecate's Earring",ear2="Novio Earring",
		body="Nares Saio",hands="Nares Cuffs",ring1="Icesoul Ring",ring2="Icesoul Ring",
		back="Refraction Cape",waist="Wanion Belt",legs="Akasha Chaps",feet="Nares Clogs"}
	
	sets.midcast_DarkMagic = {main="Chatoyant Staff",sub="Arbuda Grip",ammo="Hasty Pinion",
		head="Appetence Crown",neck="Aesir Torque",ear1="Hirudinea Earring",ear2="Loquacious Earring",
		body="Hedera Cotehardie",hands="Ayao's Gages",ring1="Balrahn's Ring",ring2="Excelsis Ring",
		back="Merciful Cape",waist="Goading Belt",legs="Auspex Slops",feet="Bokwus Boots"}
	
	sets.midcast_EnfeeblingMagic = {main="Chatoyant Staff",sub="Arbuda Grip",ammo="Savant's Treatise",
		head="Nares Cap",neck="Enfeebling Torque",ear1="Hirudinea Earring",ear2="Loquacious Earring",
		body="Nares Saio",hands="Ayao's Gages",ring1="Balrahn's Ring",ring2="Angha Ring",
		back="Refraction Cape",waist="Wanion Belt",legs="Rubeus Spats",feet="Bokwus Boots"}
	
	sets.midcast_HealingMagic = {}
	
	sets.midcast_DivineMagic = {}
	
	sets.midcast_EnhancingMagic = {main="Kirin's Pole",sub="Fulcio Grip",ammo="Savant's Treatise",
		head="Svnt. Bonnet +2",neck="Colossus's Torque",body="Anhur Robe",hands="Augur's Gloves",
		back="Merciful Cape",waist="Olympus Sash",legs="Shedir Seraweels",feet="Rubeus Boots"}
	
	sets.precast_Stun_MAcc = {main="Ajapamas II",sub="Wizzan Grip",ranged="Aureole",
		head="Zelus Tiara",neck="Aesir Torque",ear1="Belatz Pearl",ear2="Loquacious Earring",
		body="Hedera Cotehardie",hands="Repartie Gloves",lring="Prolix Ring",rring="Angha Ring",
		back="Merciful Cape",waist="Goading Belt",legs="Auspex Slops",feet="Scholar's Loafers"}
		
	
	sets.midcast_Cure = {main="Arka IV",body="Heka's Kalasiris",hands="Augur's Gloves",legs="Nares Trews"}
	
	sets.midcast_Helix = {main="Chatoyant Staff",sub="Wizzan Grip",ammo="Snow Sachet",
		head="Nares Cap",neck="Stoicheion Medal",ear1="Hecate's Earring",ear2="Novio Earring",
		body="Nares Saio",hands="Nares Cuffs",ring1="Icesoul Ring",ring2="Icesoul Ring",
		back="Twilight Cape",waist="Wanion Belt",legs="Akasha Chaps",feet="Nares Clogs"}
	
	sets.midcast_Stoneskin = {main="Kirin's Pole",neck="Stone Gorget",waist="Siegel Sash",legs="Shedir Seraweels"}
	
	sets.Obi_Fire = {back='Twilight Cape',lring='Zodiac Ring'}
	sets.Obi_Earth = {back='Twilight Cape',lring='Zodiac Ring'}
	sets.Obi_Water = {back='Twilight Cape',lring='Zodiac Ring'}
	sets.Obi_Wind = {waist='Furin Obi',back='Twilight Cape',lring='Zodiac Ring'}
	sets.Obi_Ice = {waist='Hyorin Obi',back='Twilight Cape',lring='Zodiac Ring'}
	sets.Obi_Thunder = {waist='Rairin Obi',back='Twilight Cape',lring='Zodiac Ring'}
	sets.Obi_Light = {waist='Korin Obi',back='Twilight Cape',lring='Zodiac Ring'}
	sets.Obi_Dark = {waist='Anrin Obi',back='Twilight Cape',lring='Zodiac Ring'}
	
	sets.staves = {}
	
	sets.staves.damage = {}
	sets.staves.damage.Thunder = {main="Apamajas I"}
	sets.staves.damage.Fire = {main="Atar I"}
	
	sets.staves.accuracy = {}
	sets.staves.damage.Thunder = {main="Apamajas II"}
	sets.staves.damage.Ice = {main="Vourukasha II"}
	
	stuntarg = 'Shantotto'
end

function precast(spell,action)
	if spell.english == 'Impact' then
		cast_delay(2)
		equip(sets['precast_FastCast'],{body="Twilight Cloak"})
		if not buffactive.elementalseal then
			add_to_chat(8,'--------- Elemental Seal is down ---------')
		end
	elseif spell.english == 'Stun' then
		if spell.target.name == 'Paramount Mantis' or spell.target.name == 'Tojil' then
			equip(sets['precast_Stun_MAcc'])
		else
			equip(sets['precast_Stun'])
		end
		if not buffactive.thunderstorm then
			add_to_chat(8,'--------- Thunderstorm is down ---------')
		elseif not buffactive.klimaform then
			add_to_chat(8,'----------- Klimaform is down -----------')
		end
		if stuntarg ~= 'Shantotto' then
			send_command('@input /t '..stuntarg..' ---- Byrth Stunned!!! ---- ')
		end
		--force_send()
	elseif spell.english ~= 'Embrava' and action.type == 'Magic' then
		equip(sets['precast_FastCast'])
	end

	if spell.english == 'Reraise III' then
		verify_equip()
	end
	if (buffactive.alacrity or buffactive.celerity) and world.weather_element == spell.element then
		equip({feet='Argute Loafers +2'})
	end
end

function midcast(spell,action)
	if string.find(spell.english,'Cur') then 
		weathercheck(spell.element,sets['midcast_Cure'])
	elseif spell.skill=="ElementalMagic" then
		if string.find(spell.english,'helix') then
			equip(sets['midcast_Helix'])
		elseif spell.english == 'Impact' then
			local tempset = sets['midcast_'..spell.type]
			tempset['body'] = 'Twilight Cloak'
			tempset['head'] = 'empty'
			cast_delay(1.5)
			weathercheck(spell.element,tempset)
		else
			weathercheck(spell.element,sets['midcast_'..spell.skill])
		end
		if sets.staves.damage[spell.element] then
			equip(sets.staves.damage[spell.element])
		end
	elseif spell.english == 'Stoneskin' then
		equip(sets['midcast_Stoneskin'])
	elseif spell.type == 'EnhancingMagic' then
		if spell.english == 'Embrava' then
			if not buffactive.perpetuance then
				add_to_chat(8,'--------- Perpetuance is down ---------')
			end
			if not buffactive.accession then
				add_to_chat(8,'--------- Accession is down ---------')
			end
			if not buffactive.penury then
				add_to_chat(8,'--------- Penury is down ---------')
			end
		end
		if buffactive.perpetuance then
			equip(sets['midcast_EnhancingMagic'],{hands="Savant's Bracers +2"})
		else
			equip(sets['midcast_EnhancingMagic'])
		end
	else
		weathercheck(spell.element,sets['midcast_'..spell.skill])
	end
	
	if spell.english == 'Sneak' then
		send_command('@wait 1.8;cancel 71;')
	end
end

function aftercast(spell,action)
	equip(sets['aftercast_Idle'])
	if spell.english == 'Sleep' or spell.english == 'Sleepga' then
		send_command('@wait 55;input /echo ------- '..spell.english..' is wearing off in 5 seconds -------')
	elseif spell.english == 'Sleep II' or spell.english == 'Sleepga II' then
		send_command('@wait 85;input /echo ------- '..spell.english..' is wearing off in 5 seconds -------')
	elseif spell.english == 'Break' or spell.english == 'Breakga' then
		send_command('@wait 25;input /echo ------- '..spell.english..' is wearing off in 5 seconds -------')
	end
end

function status_change(new,old)
	if new == 'Resting' then
		equip(sets['Resting'])
	else
		equip(sets['aftercast_Idle'])
	end
end

function buff_change(status,gain_or_loss)
	if status == 'Sublimation: Complete' then -- True whether gained or lost
		sets.aftercast_Idle = sets.aftercast_Idle_noSub
	elseif status == 'Sublimation: Charging' then
		sets.aftercast_Idle = sets.aftercast_Idle_Sub
	end
	equip(sets.aftercast_Idle)
end

function pet_midcast(spell,action)
end

function pet_aftercast(spell,action)
end

function self_command(command)
	if command == 'stuntarg' then
		stuntarg = target.name
	end
end

-- This function is user defined, but never called by GearSwap itself. It's just a user function that's only called from user functions. I wanted to check the weather and equip a weather-based set for some spells, so it made sense to make a function for it instead of replicating the conditional in multiple places.

function weathercheck(spell_element,set)
	if spell_element == world.weather_element or spell_element == world.day_element then
		equip(set,sets['Obi_'..spell_element])
	else
		equip(set)
	end
end