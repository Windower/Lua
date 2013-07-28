function get_sets()
	sets = {}
	
	-- Precast Sets
	sets['precast_Elemental Siphon'] = {main="Soulscourge",sub="Vox Grip",
		head="Marduk's Tiara +1",neck="Caller's Pendant",rear="Smn. Earring",
		body="Call. Doublet +2",hands="Smn. Bracers +2",lring="Evoker's Ring",rring="Fervor Ring",
		back="Astute Cape",legs="Mdk. Shalwar +1",feet="Caller's Pgch. +2"}
	
	sets['precast_Shock Squall'] = {main="Soulscourge",sub="Vox Grip",
		head="Marduk's Tiara +1",neck="Caller's Pendant",rear="Smn. Earring",
		body="Call. Doublet +2",hands="Smn. Bracers +2",lring="Evoker's Ring",rring="Fervor Ring",
		back="Tiresias' cape",legs="Smn. Spats +2",feet="Smn. Pigaches +2"}
	
	sets.precast_BP = {hands="Smn. Bracers +2",back="Tiresias' cape",legs="Smn. Spats +2",feet="Smn. Pigaches +2"}
	
	sets['precast_Mana Cede'] = {hands="Call. Bracers +2"}
				
	sets.precast_FC = {head="Nares Cap",neck="Orunmila's Torque",ear1="Loquac. Earring",body="Marduk's Jubbah +1",
		hands="Repartie Gloves",ring2="Prolix Ring",back="Swith Cape",waist="Siegel Sash",legs="Orvail Pants",
		feet="Rostrum Pumps"}
		
	sets.precast_Cur = {body="Heka's Kalasiris",legs="Nabu's Shalwar",back="Pahtli Cape"}
	
	sets.precast_FC_Thunder = {main='Apamajas I'}
	sets.precast_FC_Fire = {main='Atar I'}
	
	-- Midcast Sets
	sets.midcast_Phys_BP = {main="Soulscourge",sub="Vox grip",ammo="Dashavatara Sash",
		head="Caller's horn +2",neck="Sacrifice torque",ear1="Gifted Earring",ear2="Smn. Earring",
		body="Call. Doublet +2",hands="Auspex Gages",ring1="Evoker's Ring",ring2="Fervor Ring",
		back="Astute Cape",waist="Mujin Obi",legs="Ngen Seraweels",feet="Shedir Crackows"}
		
	sets.midcast_MAB_BP = {main="Yaskomo's Pole",sub="Vox grip",ammo="Dashavatara Sash",
		head="Hokwus Circlet",neck="Eidolon Pendant",ear1="Gifted Earring",ear2="Smn. Earring",
		body="Call. Doublet +2",hands="Nares Cuffs",ring1="Evoker's Ring",ring2="Fervor Ring",
		back="Tiresias' Cape",waist="Caller's sash",legs="Caller's spats +2",feet="Shedir Crackows"}
		
	sets.midcast_MAcc_BP = {main="Yaskomo's Pole",sub="Vox grip",ammo="Dashavatara Sash",
		head="Hokwus Circlet",neck="Caller's Pendant",ear1="Gifted Earring",ear2="Smn. Earring",
		body="Anhur Robe",hands="Smn. Bracers +2",ring1="Evoker's Ring",ring2="Fervor Ring",
		back="Astute Cape",legs="Smn. spats +2",feet="Caller's Pgch. +2"}
		
	sets.midcast_Buff_BP = {sub="Vox grip",
		head="Caller's Horn +2",neck="Caller's Pendant",ear1="Gifted Earring",ear2="Smn. Earring",
		body="Caller's Doublet +2",hands="Smn. Bracers +2",ring1="Evoker's Ring",ring2="Fervor Ring",
		back="Astute Cape",legs="Nares Trews"}
					
	sets.midcast_Cur = {main="Arka IV",head="Marduk's Tiara +1",ear2="Novia earring",
		body="Heka's Kalasiris"}
		
	sets.midcast_Stoneskin = {head="Marduk's Tiara +1",neck="Stone Gorget",body="Marduk's Jubbah +1",
		hands="Marduk's Dastanas +1",waist="Seigel Sash",legs="Shedir Seraweels"}
	
	
	--Aftercast Sets
	sets.aftercast_None = {main="Terra's Staff",
		head="Caller's Horn +2",neck="Twilight Torque",ear1="Loquac. Earring",ear2="Antivenom Earring",
		body="Marduk's Jubbah +1",hands="Marduk's Dastanas +1",ring1="Dark Ring",ring2="Dark Ring",
		back="Umbra Cape",waist="Hierarch belt",legs="Nares Trews",feet="Herald's Gaiters"}
	
	sets.aftercast_Favor = {main="Chatoyant Staff",sub="Vox grip",ammo="Dashavatara Sash",
		head="Caller's Horn +2",neck="Caller's Pendant",ear1="Loquac. Earring",ear2="Antivenom Earring",
		body="Caller's Doublet +2",hands="Smn. Bracers +2",ring1="Evoker's Ring",ring2="Fervor Ring",
		back="Astute Cape",waist="Hierarch belt",legs="Ngen Seraweels",feet="Rubeus Boots"}
	
	sets.aftercast_Perp_Base = {main="Chatoyant Staff",ammo="Dashavatara Sash",
		head="Caller's Horn +2",neck="Caller's Pendant",
		body="Caller's Doublet +2",hands="Adhara Gages",ring1="Evoker's Ring",
		waist="Hierarch belt",legs="Nares Trews",feet="Caller's Pgch. +2"}
	
	sets.aftercast_Avatar_Carbuncle = {hands="Carbuncle Mitts"}
	
	sets.aftercast_Avatar_Diabolos = {waist="Diabolos's Rope"}
	
	sets.aftercast_Avatar_Spirit = {main="Soulscourge",sub="Vox grip",ammo="Dashavatara Sash",
		head="Caller's Horn +2",neck="Caller's Pendant",ear2="Smn. Earring",
		body="Anhur Robe",hands="Smn. Bracers +2",ring1="Evoker's Ring",ring2="Fervor Ring",
		back="Astute Cape",legs="Smn. spats +2",feet="Caller's Pgch. +2"}
				
	sets.aftercast_Resting = {main="Numen Staff",sub="Ariesian Grip",ammo="Mana Ampulla",
		head="Caller's Horn +2",neck="Eidolon Pendant",ear1="Relaxing Earring",ear2="Antivenom Earring",
		body="Marduk's Jubbah +1",hands="Nares Cuffs",ring1="Star Ring",ring2="Angha Ring",
		back="Vita cape",waist="Austerity belt",legs="Nares Trews",feet="Oracle's Pigaches"}
	
	sets.aftercast_Idle = sets.aftercast_None
end

function precast(spell,action)
	verify_equip()
	if action.type == 'Magic' then
		equip(sets.precast_FC)
		if string.find(spell.english,'Cur') then
			equip(sets.precast_Cur)
		end
	elseif string.find(spell.type,'BloodPact') then
		equip(sets.precast_BP)
	end
	
	if sets['precast_FC_'..tostring(spell.element)] then equip(sets['precast_FC_'..spell.element]) end
	if sets['precast_'..spell.english] then equip(sets['precast_'..spell.english]) end
end

function midcast(spell,action)
	if string.find(spell.english,'Cur') then
		equip(sets.midcast_Cur)
	elseif spell.english=='Stoneskin' then
		equip(sets.midcast_Stoneskin)
	end
end

function aftercast(spell,action)
	if spell.type then
		if not string.find(spell.type,'BloodPact') then
			send_command('@wait 1;gs c Idle')
		end
	end
end

function status_change(old,new)
	if new=='Idle' then
		send_command('@gs c Idle')
	elseif new=='Resting' then
		equip(sets['aftercast_Resting'])
	end
end

function buff_change(status,gain_or_loss)
end

function pet_midcast(spell,action)
	if spell.type=='BloodPactWard' then
		if T{'Diamond Storm','Sleepga','Slowga','Tidal Roar','Shock Squall'}:contains(spell.name) then
			equip(sets.midcast_MAcc_BP)
		else
			equip(sets.midcast_Buff_BP)
		end
	elseif spell.type=='BloodPactRage' then
		if T{'Heavenly Strike','Wind Blade','Holy Mist','Night Terror','Nether Blast','Thunderstorm'}:contains(spell.name) then
			equip(sets.midcast_MAB_BP)
		elseif T{'Predator Claws','Rush','Eclipse Bite','Meteor','Spinning Dive','Flaming Crush','Mountain Buster','Chaotic Strike'}:contains(spell.name) then
			equip(sets.midcast_Phys_BP)
		else
			equip(sets.midcast_Phys_BP)
		end
	end
end


function pet_aftercast(spell,action)
	
	send_command('@gs c Idle')
end


function self_command(command)
	if command == 'Idle' then
		equip(sets.aftercast_None)
		if pet.isvalid then
			if string.find(pet.name,'Spirit') then
				equip(sets.aftercast_Avatar_Spirit)
			elseif buffactive["Avatar's Favor"] then
				equip(sets.aftercast_Favor)
			else
				equip(sets.aftercast_Perp_Base)
				if sets['aftercast_Avatar_'..pet.name] then
					equip(sets['aftercast_Avatar_'..pet.name])
				end
			end
		end
	end
end