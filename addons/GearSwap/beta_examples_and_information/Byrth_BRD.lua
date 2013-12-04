function get_sets()
	sets.precast = {}
	sets.precast.JA = {}
	
	-- Precast Sets
	sets.precast.Nightingale = {feet="Brd. Slippers +2"}
	
	sets.precast.Troubadour = {body="Bard's Justaucorps +2"}
	
	sets.precast['Soul Voice'] = {legs="Brd. Cannions +2"}
	
	sets.precast.FC = {}
	
	sets.precast.FC.Song = {head="Aoidos' Calot +2",neck="Aoidos' Matinee",
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
		head="Nahtirah Hat",neck="Dualism Collar",ear1="Aoidos' Earring",
		body="Brd. Justaucorps +2",hands="Buremte Gloves",ring1="Veela Ring",ring2="Thundersoul Ring",
		back="Swith Cape +1",waist="Aristo Belt",legs="Gendewitha Spats",feet="Brioso slippers"}
	
	-- Midcast Sets
	sets.midcast = {}
		
	sets.midcast.Haste = {main="Terra's Staff",sub="Oneiros Grip",
		head={name="Nahtirah Hat",order=6},neck="Orunmila's Torque",ear1="Loquac. Earring",ear2={name="Gifted Earring",order=7},
		body={name="Hedera Cotehardie",order=5},hands={name="Gendewitha Gages",order=11},ring2={name="Prolix Ring",order=10},
		back={name="Rhapsodie's Cape",order=8},waist="Phasmida Belt",legs="Byakko's Haidate",feet={name="Chelona Boots +1",order=9}}

	sets.midcast.Debuff = {main="Twashtar",sub="Genbu's Shield",range="Gjallarhorn",
		head="Kaabanax Hat",neck="Aoidos' Matinee",ear1="Psystorm Earring",ear2="Lifestorm earring",
		body="Aoidos' Hngrln. +2",hands="Ad. Mnchtte. +2",ring1="Omega Ring",ring2="Sangoma ring",
		back="Rhapsode's Cape",waist="Aristo belt",legs="Mdk. Shalwar +1",feet="Brioso slippers"}
	
	sets.midcast.Buff = {main="Legato Dagger",head="Aoidos' Calot +2",neck="Aoidos' Matinee",
		body="Aoidos' Hngrln. +2",hands="Ad. Mnchtte. +2",legs="Mdk. Shalwar +1",feet="Brioso slippers"}
	
	sets.midcast.DBuff = {range="Daurdabla"}
	
	sets.midcast.GBuff = {range="Gjallarhorn"}
		
	sets.midcast.Ballad = {legs="Aoidos' Rhing. +2"}
		
	sets.midcast.Finale = {neck="Wind Torque",feet="Bokwus Boots"}
		
	sets.midcast.Lullaby = {hands="Brioso Cuffs"}
	
	sets.midcast.Base = sets.midcast.Haste
		
	sets.midcast.Cure = {main="Chatoyant Staff",head="Marduk's Tiara +1",neck="Phalaina Locket",ear2="Novia earring",
		body="Heka's Kalasiris",hands="Bokwus Gloves",legs="Brd. Cannions +2",feet="Bokwus Boots"}
		
	sets.midcast.Stoneskin = {head="Marduk's Tiara +1",body="Marduk's Jubbah +1",hands="Marduk's Dastanas +1",
		legs="Shedir Seraweels",feet="Bokwus Boots"}
	
	
	--Aftercast Sets
	sets.aftercast = {}
	sets.aftercast.Regen = {main="Terra's Staff",sub="Oneiros Grip",range="Oneiros Harp",
		head="Marduk's Tiara +1",neck="Twilight Torque",ear1={name="Loquac. Earring",order=7},ear2={name="Gifted Earring",order=5},
		body="Marduk's Jubbah +1",hands={name="Serpentes Cuffs",order=9},ring1="Defending Ring",ring2={name="Dark Ring",order=8},
		back="Umbra Cape",waist="Flume Belt",legs={name="Nares Trews",order=6},feet="Aoidos' Cothrn. +2"}
	
	sets.aftercast.PDT = {main="Terra's Staff",sub="Oneiros Grip",range="Oneiros Harp",
		head="Marduk's Tiara +1",neck="Twilight Torque",ear1="Loquac. Earring",ear2="Gifted Earring",
		body="Marduk's Jubbah +1",hands="Serpentes Cuffs",ring1="Defending Ring",ring2="Dark Ring",
		back="Umbra Cape",waist="Flume Belt",legs="Gendewitha Spats",feet="Aoidos' Cothrn. +2"}
	
	sets.aftercast.Engaged = {range="Oneiros Harp",
		head="Zelus Tiara",neck="Asperity Necklace",ear1="Loquac. Earring",ear2="Gifted Earring",
		body="Hedera Cotehardie",hands="Buremte Gloves",ring1="Defending Ring",ring2="Dark Ring",
		back="Umbra Cape",waist="Phasmida Belt",legs="Byakko's Haidate",feet="Brioso slippers"}
		
	sets.aftercast.Idle = sets.aftercast.Regen
	
	DaurdSongs = T{'Water Carol','Water Carol II','Ice Carol','Ice Carol II','Herb Pastoral','Goblin Gavotte'}
	
	send_command('input /macro book 1;wait .1;input /macro set 1')
end

function precast(spell,action)
	if spell.type == 'BardSong' then
		if string.find(world.area:lower(),'cirdas caverns') then
			cast_delay(0.5)
		else
			verify_equip()
		end
		if spell.target.type == 'PLAYER' and not buffactive.pianissimo then
			cast_delay(1.5)
			send_command('@input /raw /ja "Pianissimo" <me>')
		end
		if buffactive['nightingale'] then
			equip_song_gear(spell)
		else
			equip_song_gear(spell)
			equip(sets.precast.FC.Song)
		end
	elseif action.type == 'Magic' then
		equip(sets.precast.FC.Normal)
		if tonumber(spell.casttime) >= 4 then verify_equip() end
		if string.find(spell.english,'Cur') then
			equip(sets.precast.Cure)
		end
	end
	
	if sets.precast.FC[tostring(spell.element)] then equip(sets.precast.FC[tostring(spell.element)]) end
	if sets.precast.JA[spell.english] then equip(sets.precast.JA[spell.english]) end
end

function midcast(spell,action)
	if spell.type == 'BardSong' then
		equip_song_gear(spell)
	elseif string.find(spell.english,'Cur') then
		equip(sets.midcast.Base,sets.midcast.Cure)
	elseif spell.english=='Stoneskin' then
		equip(sets.midcast.Base,sets.midcast.Stoneskin)
	end
end

function aftercast(spell,action)
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
		end
	end
end