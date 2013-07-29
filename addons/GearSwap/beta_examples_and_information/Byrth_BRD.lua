function get_sets()
	sets = {}
	
	-- Precast Sets
	sets.precast_Nightingale = {feet="Brd. Slippers +2"}
	
	sets.precast_Troubadour = {body="Bard's Justaucorps +2"}
	
	sets['precast_Soul Voice'] = {legs="Brd. Cannions +2"}
	
	sets.precast_FC_Song = {head="Aoidos' Calot +2",neck="Aoidos' Matinee",
		ear1="Loquac. Earring",ear2="Aoidos' Earring",body="Marduk's Jubbah +1",hands="Mdk. Dastanas +1",
		ring1="Minstrel's ring",ring2="Prolix Ring",back="Swith Cape",waist="Aoidos' Belt",legs="Orvail Pants",
		feet="Bokwus Boots"}
		
	sets.precast_FC = {head="Nares Cap",neck="Orunmila's Torque",ear1="Loquac. Earring",body="Marduk's Jubbah +1",
		hands="Repartie Gloves",ring2="Prolix Ring",back="Swith Cape",waist="Siegel Sash",legs="Orvail Pants",
		feet="Rostrum Pumps"}
		
	sets.precast_Cure = {body="Heka's Kalasiris",legs="Nabu's Shalwar",back="Pahtli Cape"}
	
	sets.precast_FC_Thunder = {main='Apamajas I'}
	sets.precast_FC_Fire = {main='Atar I'}
	
	-- Midcast Sets
	sets.midcast_Haste = {main="Terra's Staff",sub="Arbuda Grip",
		head="Zelus Tiara",neck="Orunmila's Torque",ear1="Loquac. Earring",
		body="Hedera's Cotehardie",hands="Repartie Gloves",ring2="Prolix Ring",
		back="Swith Cape",waist="Phasmida Belt",legs="Byakko's Haidate",feet="Rostrum Pumps"}

	sets.midcast_Debuff = {main="Chatoyant Staff",sub="Mephitis grip",
		head="Marduk's Tiara +1",neck="Aoidos' Matinee",ear1="Psystorm Earring",ear2="Lifestorm earring",
		body="Aoidos' Hngrln. +2",hands="Ad. Mnchtte. +2",ring1="Omega Ring",ring2="Veela ring",
		back="Mesmeric Cape",waist="Aristo belt",legs="Mdk. Shalwar +1",feet="Bokwus Boots"}
	
	sets.midcast_Buff = {head="Aoidos' Calot +2",neck="Aoidos' Matinee",ear2="Gifted Earring",
		body="Aoidos' Hngrln. +2",hands="Ad. Mnchtte. +2",legs="Mdk. Shalwar +1",feet="Aoidos' Cothrn. +2"}
	
	sets.midcast_DBuff = {range="Daurdabla"}
	
	sets.midcast_GBuff = {range="Gjallarhorn"}
		
	sets.midcast_Ballad = {legs="Aoidos' Rhing. +2"}
	
	sets.midcast_Base = sets.midcast_Haste
		
	sets.midcast_Cure = {main="Chatoyant Staff",head="Marduk's Tiara +1",ear2="Novia earring",
		body="Heka's Kalasiris",hands="Bokwus Gloves",legs="Brd. Cannions +2",feet="Bokwus Boots"}
		
	sets.midcast_Stoneskin = {head="Marduk's Tiara +1",body="Marduk's Jubbah +1",hands="Marduk's Dastanas +1",
		legs="Brd. Cannions +2",feet="Bokwus Boots"}
	
	
	--Aftercast Sets
	sets.aftercast_Regen = {main="Terra's Staff",
		head="Marduk's Tiara +1",neck="Twilight Torque",ear1="Loquac. Earring",ear2="Gifted Earring",
		body="Marduk's Jubbah +1",hands="Serpentes Cuffs",ring1="Dark Ring",ring2="Dark Ring",
		back="Umbra Cape",waist="Flume Belt",legs="Nares Trews",feet="Aoidos' Cothrn. +2"}
	
	sets.aftercast_PDT = {main="Terra's Staff",
		head="Marduk's Tiara +1",neck="Twilight Torque",ear1="Loquac. Earring",ear2="Gifted Earring",
		body="Marduk's Jubbah +1",hands="Serpentes Cuffs",ring1="Dark Ring",ring2="Dark Ring",
		back="Umbra Cape",waist="Flume Belt",legs="Nares Trews",feet="Aoidos' Cothrn. +2"}
		
	sets.aftercast_Idle = sets.aftercast_Regen
end

function precast(spell,action)
	if spell.type == 'BardSong' then
		verify_equip()
		if spell.target.type == 'PLAYER' and not buffactive.pianissimo then
			cast_delay(1.5)
			send_command('@input /raw /ja "Pianissimo" <me>')
		end
		if buffactive['nightingale'] then
			if spell.english == 'Water Carol' or spell.english == 'Water Carol II' or spell.english == 'Herb Pastoral' or spell.english == 'Goblin Gavotte' then
				equip(sets.midcast_Base,sets.midcast_DBuff)
			else
				equip(sets.midcast_Base,sets.midcast_Buff,sets.midcast_GBuff)
				if string.find(spell.english,'Ballad') then equip(sets.midcast_Ballad) end
			end
		else
			equip(sets.precast_FC_Song)
		end
	elseif action.type == 'Magic' then
		equip(sets.precast_FC)
		if string.find(spell.english,'Cur') then
			equip(sets.precast_Cure)
		end
	end
	
	if sets['precast_FC_'..tostring(spell.element)] then equip(sets['precast_FC_'..spell.element]) end
	if sets['precast_'..spell.english] then equip(sets['precast_'..spell.english]) end
end

function midcast(spell,action)
	if spell.type == 'BardSong' then
		if spell.english == 'Water Carol' or spell.english == 'Water Carol II' or spell.english == 'Herb Pastoral' or spell.english == 'Goblin Gavotte' then
			equip(sets.midcast_Base,sets.midcast_DBuff)
		elseif spell.target.type == 'MONSTER' then
			equip(sets.midcast_Base,sets.midcast_Debuff,sets.midcast_GBuff)
		else
			equip(sets.midcast_Base,sets.midcast_Buff,sets.midcast_GBuff)
			if string.find(spell.english,'Ballad') then equip(sets.midcast_Ballad) end
		end
	elseif string.find(spell.english,'Cur') then
		equip(sets.midcast_Base,sets.midcast_Cure)
	elseif spell.english=='Stoneskin' then
		equip(sets.midcast_Base,sets.midcast_Stoneskin)
	end
end

function aftercast(spell,action)
	equip(sets['aftercast_Idle'])
end

function status_change(new,tab)
	if T{'Idle','Resting'}:contains(new) then
		equip(sets['aftercast_Idle'])
	end
end

function buff_change(status,gain_or_loss)
end