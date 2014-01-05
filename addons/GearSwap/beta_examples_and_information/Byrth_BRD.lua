function get_sets()
	sets.precast = {}
	sets.precast.JA = {}
	
	-- Precast Sets
	sets.precast.JA.Nightingale = {feet="Brd. Slippers +2"}
	
	sets.precast.JA.Troubadour = {body="Bard's Justaucorps +2"}
	
	sets.precast.JA['Soul Voice'] = {legs="Brd. Cannions +2"}
	
	sets.precast.FC = {}
	
	sets.precast.FC.Song = {head="Aoidos' Calot +2",neck="Orunmila's Torque",
		ear1={name="Loquac. Earring",order=5},ear2="Aoidos' Earring",body="Marduk's Jubbah +1",hands={name="Gendewitha Gages",order=8},
		ring1="Defending ring",ring2={name="Prolix Ring",order=7},back="Swith Cape +1",waist="Aoidos' Belt",legs={name="Gendewitha Spats",order=9},
		feet={name="Bokwus Boots",order=6}}
		
	sets.precast.FC.Normal = {head="Nahtirah Hat",neck="Orunmila's Torque",ear1="Loquac. Earring",body="Marduk's Jubbah +1",
		hands="Gendewitha Gages",ring2="Prolix Ring",back="Swith Cape +1",waist="Siegel Sash",legs="Orvail Pants +1",
		feet="Chelona Boots +1"}
		
	sets.precast.Cure = {body="Heka's Kalasiris",legs="Nabu's Shalwar",back="Pahtli Cape"}
	
	sets.precast.FC.Thunder = {main='Apamajas I'}
	sets.precast.FC.Fire = {main='Atar I'}
	
	sets.precast.WS = {}
	sets.precast.WS['Mordant Rime'] = {range="Gjallarhorn",
		head="Nahtirah Hat",neck="Aqua Gorget",ear1="Aoidos' Earring",
		body="Bard's Justaucorps +2",hands="Brioso Cuffs +1",ring1="Veela Ring",ring2="Thundersoul Ring",
		back="Atheling Mantle",waist="Aqua Belt",legs="Gendewitha Spats",feet="Brioso slippers"}
	
	-- Midcast Sets
	sets.midcast = {}
		
	sets.midcast.Haste = {main="Terra's Staff",sub="Oneiros Grip",
		head={name="Nahtirah Hat",order=6},neck="Orunmila's Torque",ear1="Loquac. Earring",ear2={name="Gifted Earring",order=7},
		body={name="Hedera Cotehardie",order=5},hands={name="Gendewitha Gages",order=11},ring2={name="Prolix Ring",order=10},
		back={name="Rhapsode's Cape",order=8},waist="Phasmida Belt",legs="Byakko's Haidate",feet={name="Chelona Boots +1",order=9}}

	sets.midcast.Debuff = {main="Carnwenhan",sub="Genbu's Shield",range="Gjallarhorn",
		head="Kaabanax Hat",neck="Aoidos' Matinee",ear1="Psystorm Earring",ear2="Lifestorm earring",
		body="Aoidos' Hngrln. +2",hands="Lurid Mitts",ring1="Omega Ring",ring2="Sangoma ring",
		back="Rhapsode's Cape",waist="Aristo belt",legs="Mdk. Shalwar +1",feet="Brioso slippers"}
	
	sets.midcast.Buff = {main="Carnwenhan",sub="Genbu's Shield",head="Aoidos' Calot +2",neck="Aoidos' Matinee",
		body="Aoidos' Hngrln. +2",hands="Ad. Mnchtte. +2",legs="Mdk. Shalwar +1",feet="Brioso slippers"}
	
	sets.midcast.DBuff = {range="Daurdabla"}
	
	sets.midcast.GBuff = {range="Gjallarhorn"}
		
	sets.midcast.Ballad = {legs="Aoidos' Rhing. +2"}
		
	sets.midcast.Scherzo = {feet="Aoidos' Cothrn. +2"}
		
	sets.midcast.Finale = {neck="Wind Torque",legs="Brioso Cannions +1",feet="Bokwus Boots"}
		
	sets.midcast.Lullaby = {hands="Brioso Cuffs +1"}
	
	sets.midcast.Base = sets.midcast.Haste
		
	sets.midcast.Cure = {main="Chatoyant Staff",head="Marduk's Tiara +1",neck="Phalaina Locket",ear2="Novia earring",
		body="Heka's Kalasiris",hands="Bokwus Gloves",legs="Brd. Cannions +2",feet="Bokwus Boots"}
		
	sets.midcast.Stoneskin = {head="Marduk's Tiara +1",body="Marduk's Jubbah +1",hands="Marduk's Dastanas +1",
		legs="Shedir Seraweels",feet="Bokwus Boots"}
	
	
	--Aftercast Sets
	sets.aftercast = {}
	sets.aftercast.Regen = {main={name="Terra's Staff",order=1},sub={name="Oneiros Grip",order=2},range="Oneiros Harp",
		head="Marduk's Tiara +1",neck="Twilight Torque",ear1={name="Loquac. Earring",order=7},ear2={name="Gifted Earring",order=5},
		body="Marduk's Jubbah +1",hands={name="Serpentes Cuffs",order=9},ring1="Defending Ring",ring2={name="Dark Ring",order=8},
		back="Umbra Cape",waist="Flume Belt",legs={name="Nares Trews",order=6},feet="Aoidos' Cothrn. +2"}
	
	sets.aftercast.PDT = {main="Terra's Staff",sub="Oneiros Grip",range="Oneiros Harp",
		head="Marduk's Tiara +1",neck="Twilight Torque",ear1="Loquac. Earring",ear2="Gifted Earring",
		body="Marduk's Jubbah +1",hands="Serpentes Cuffs",ring1="Defending Ring",ring2="Dark Ring",
		back="Umbra Cape",waist="Flume Belt",legs="Gendewitha Spats",feet="Aoidos' Cothrn. +2"}
	
	sets.aftercast.Engaged = {range="Oneiros Harp",
		head="Zelus Tiara",neck="Asperity Necklace",ear1="Brutal Earring",ear2="Suppanomimi",
		body="Hedera Cotehardie",hands="Brioso Cuffs +1",ring1="Pyrosoul Ring",ring2="Rajas Ring",
		back="Atheling Mantle",waist="Phasmida Belt",legs="Byakko's Haidate",feet="Brioso slippers"}
		
	sets.aftercast.Idle = sets.aftercast.Regen
	
	DaurdSongs = T{'Water Carol','Water Carol II','Ice Carol','Ice Carol II','Herb Pastoral','Goblin Gavotte'}
	
	send_command('input /macro book 3;wait .1;input /macro set 1')
	timer_reg = {}
	pianissimo_cycle = false
end

function pretarget(spell)
	if spell.type == 'BardSong' and spell.target.type and spell.target.type == 'PLAYER' and not buffactive.pianissimo and not spell.target.charmed and not pianissimo_cycle then
		cancel_spell()
		pianissimo_cycle = true
		send_command('input /ja "Pianissimo" <me>;wait 1.5;input /ma "'..spell.name..'" '..spell.target.name..';')
		return
	end
	if spell.name ~= 'Pianissimo' then
		pianissimo_cycle = false
	end
end

function precast(spell)
	if spell.type == 'BardSong' then
		if buffactive.nightingale then
			equip_song_gear(spell)
			return
		else
			equip_song_gear(spell)
			equip(sets.precast.FC.Song)
		end
	elseif spell.action_type == 'Magic' then
		equip(sets.precast.FC.Normal)
		if string.find(spell.english,'Cur') and spell.name ~= 'Cursna' then
			equip(sets.precast.Cure)
		end
	elseif spell.type == 'WeaponSkill' then
		if sets.precast.WS[spell.name] then
			equip(sets.precast.WS[spell.name])
		end
	end
	
	if sets.precast.FC[tostring(spell.element)] then equip(sets.precast.FC[tostring(spell.element)]) end
	if sets.precast.JA[spell.english] then equip(sets.precast.JA[spell.english]) end
end

function midcast(spell)
	if spell.type == 'BardSong' then
		equip_song_gear(spell)
	elseif string.find(spell.english,'Cur') then
		equip(sets.midcast.Base,sets.midcast.Cure)
	elseif spell.english=='Stoneskin' then
		equip(sets.midcast.Base,sets.midcast.Stoneskin)
	end
end

function aftercast(spell)
	if spell.type and spell.type == 'BardSong' and spell.target and spell.target.type:upper() == 'SELF' then
		local t = os.time()
		
		-- Eliminate songs that have already expired
		local tempreg = {}
		for i,v in pairs(timer_reg) do
			if v < t then tempreg[i] = true end
		end
		for i,v in pairs(tempreg) do
			timer_reg[i] = nil
		end
		
		local dur = calculate_duration(spell.name)
		if timer_reg[spell.name] then
			if (timer_reg[spell.name] - t) <= 120 then
				send_command('timers delete "'..spell.name..'"')
				timer_reg[spell.name] = t + dur
				send_command('timers create "'..spell.name..'" '..dur..' down')
			end
		else
			local maxsongs = 2
			if player.equipment.range == 'Daurdabla' then
				maxsongs = maxsongs+2
			end
			if buffactive['Clarion Call'] then
				maxsongs = maxsongs+1
			end
			if maxsongs < table.length(timer_reg) then
				maxsongs = table.length(timer_reg)
			end
			
			if table.length(timer_reg) < maxsongs then
				timer_reg[spell.name] = t+dur
				send_command('timers create "'..spell.name..'" '..dur..' down')
			else
				local rep,repsong
				for i,v in pairs(timer_reg) do
					if t+dur > v then
						if not rep or rep > v then
							rep = v
							repsong = i
						end
					end
				end
				if repsong then
					timer_reg[repsong] = nil
					send_command('timers delete "'..repsong..'"')
					timer_reg[spell.name] = t+dur
					send_command('timers create "'..spell.name..'" '..dur..' down')
				end
			end
		end
	end
	if player.status == 'Engaged' then
		equip(sets.aftercast.Engaged)
	else
		equip(sets.aftercast.Idle)
	end
end

function status_change(new,old)
	if new == 'Engaged' then
		equip(sets.aftercast.Engaged)
		disable('main','sub')
	elseif T{'Idle','Resting'}:contains(new) then
		equip(sets.aftercast.Idle)
	end
end

function self_command(cmd)
	if cmd == 'unlock' then
		enable('main','sub')
	elseif cmd == 'midact' then
		midaction(false)
	end
end

function equip_song_gear(spell)
	if DaurdSongs:contains(spell.english) then
		equip(sets.midcast.Base,sets.midcast.DBuff)
	else
		if spell.target.type == 'MONSTER' then
			equip(sets.midcast.Base,sets.midcast.Debuff,sets.midcast.GBuff)
			if string.find(spell.english,'Finale') then equip(sets.midcast.Finale) end
			if string.find(spell.english,'Lullaby') then equip(sets.midcast.Lullaby) end
		else
			equip(sets.midcast.Base,sets.midcast.Buff,sets.midcast.GBuff)
			if string.find(spell.english,'Ballad') then equip(sets.midcast.Ballad) end
			if string.find(spell.english,'Scherzo') then equip(sets.midcast.Scherzo) end
		end
	end
end

function calculate_duration(name)
	local mult = 1
	if player.equipment.range == 'Daurdabla' then mult = mult + 0.3 end
	if player.equipment.range == "Gjallarhorn" then mult = mult + 0.4 end
	
	if player.equipment.neck == "Aoidos' Matinee" then mult = mult + 0.1 end
	if player.equipment.feet == "Brioso Slippers" then mult = mult + 0.1 end
	if player.equipment.body == "Aoidos' Hngrln. +2" then mult = mult + 0.1 end
	if player.equipment.legs == "Mdk. Shalwar +1" then mult = mult + 0.1 end
	if player.equipment.main == "Carnwenhan" then mult = mult + 0.5 end
	
	if string.find(name,'March') and player.equipment.hands == 'Ad. Mnchtte. +2' then mult = mult + 0.1 end
	if string.find(name,'Minuet') and player.equipment.body == "Aoidos' Hngrln. +2" then mult = mult + 0.1 end
	if string.find(name,'Madrigal') and player.equipment.head == "Aoidos' Calot +2" then mult = mult + 0.1 end
	if string.find(name,'Ballad') and player.equipment.legs == "Aoidos' Rhing. +2" then mult = mult + 0.1 end
	if string.find(name,'Scherzo') and player.equipment.feet == "Aoidos' Cothrn. +2" then mult = mult + 0.1 end
	
	if buffactive.Troubadour then
		mult = mult*2
	end
	if string.find(name,'Scherzo') and buffactive['Soul Voice'] then
		mult = mult*2
	elseif string.find(name,'Scherzo') and buffactive.marcato then
		mult = mult*1.5
	end
	
	return mult*120
end

--[[windower.register_event('zone change',function (...)
	for i,v in pairs(timer_reg) do
		send_command('timers delete "'..i..'"')
	end
	timer_reg = {}
end)]]