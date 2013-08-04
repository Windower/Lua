function equip_sets(swap_type,val1,val2)
	local items = get_items()
	local cur_equip = items['equipment'] -- i = 'head', 'feet', etc.; v = inventory ID (0~80)
	-- If the swap is not complete, overwrite the current equipment with the equipment that you are swapping to
	for i,v in pairs(cur_equip) do
		if sent_out_equip[slot_map[i]] then
			cur_equip[i] = sent_out_equip[slot_map[i]]
		end
	end
	
	refresh_globals()
	table.reassign(equip_list,player.equipment)
	
	if debugging >= 2 then add_to_chat(1,swap_type) end
	if logging then
		logit(logfile,'\n\n'..tostring(os.clock)..'(15) equip_sets: '..tostring(swap_type))
		if val1 then
			if val1.english then
				logit(logfile,' : '..val1.english)
			end
		else
			logit(logfile,' : nil-or-false')
		end
		if val2 then
			if val2.type then	logit(logfile,' : '..val2.type)	end
		else
			logit(logfile,' : nil-or-false')
		end
	end

	if swap_type == 'precast' then
		val1.target = spelltarget
		if type(user_env.precast) == 'function' then user_env.precast(val1,val2) -- User defined function to determine the precast set
		elseif user_env.precast then add_to_chat(123,'GearSwap: precast() exists but is not a function') end
	elseif swap_type == 'midcast' then
		val1.target = spelltarget
		if type(user_env.midcast) == 'function' then user_env.midcast(val1,val2) -- User defined function to determine the midcast set
		elseif user_env.midcast then add_to_chat(123,'GearSwap: midcast() exists but is not a function') end
	elseif swap_type == 'aftercast' then
		if not val1 then val1 = {}
			add_to_chat(8,'val1 error')
		end
		val1.target = spelltarget
		midaction = false
		spelltarget = nil
		if type(user_env.aftercast) == 'function' then user_env.aftercast(val1,val2) -- User defined function to determine the aftercast set
		elseif user_env.aftercast then add_to_chat(123,'GearSwap: aftercast() exists but is not a function') end
	elseif swap_type == 'pet_midcast' then
		val1.target = spelltarget
		if type(user_env.pet_midcast) == 'function' then user_env.pet_midcast(val1,val2) -- User defined function to determine the midcast set
		elseif user_env.pet_midcast then add_to_chat(123,'GearSwap: pet_midcast() exists but is not a function') end
	elseif swap_type == 'pet_aftercast' then
		val1.target = spelltarget
		if type(user_env.pet_aftercast) == 'function' then user_env.pet_aftercast(val1,val2) -- User defined function to determine the aftercast set
		elseif user_env.pet_aftercast then add_to_chat(123,'GearSwap: pet_aftercast() exists but is not a function') end
	elseif swap_type == 'status_change' then
		if type(user_env.status_change) == 'function' then user_env.status_change(val1,val2) -- User defined function to determine if sets should change following status change
		elseif user_env.status_change then add_to_chat(123,'GearSwap: status_change() exists but is not a function') end
	elseif swap_type == 'buff_change' then
		if type(user_env.buff_change) == 'function' then user_env.buff_change(val1,val2) -- User defined function to determine if sets should change following buff change
		elseif user_env.buff_change then add_to_chat(123,'GearSwap: buff_change() exists but is not a function') end
	elseif swap_type == 'equip_command' then
		equip(val1)
	elseif swap_type == 'self_command' then
		if type(user_env.self_command) == 'function' then user_env.self_command(val1)
		elseif user_env.self_command then add_to_chat(123,'GearSwap: self_command() exists but is not a function') end
	elseif swap_type == 'delayed' then
		equip(stored_equip_list)
	end
	
	local equip_next = {}
	-- Need to make sure the item isn't being traded or synthesized.
	equip_next = to_id_set(items['inventory'],equip_list) -- Translates the equip_list from the player (i=slot name, v=item name) into a table with i=slot id and v=inventory id.
	equip_next = eliminate_redundant(cur_equip,equip_next) -- Eliminate the equip commands for items that are already equipped
	
	if _global.show_swaps and table.length(equip_next)>0 then
		print_set(to_names_set(equip_next,items['inventory']),swap_type)
	end
	
	local failure_reason = ''
	for i,v in pairs(player.buffs) do
		if v==14 or v == 17 then
			failure_reason = 'Charmed'
		elseif v == 0 then
			failure_reason = 'KOed'
		end
		if _global.debug_mode and failure_reason ~= '' then
			add_to_chat(8,'Gearswap: Cannot change gear right now: '..failure_reason)
		end
	end
	
	
	if failure_reason == '' then
		for i,v in pairs(equip_next) do
			--if debugging >= 2 then add_to_chat(8,tostring(v)..' '..tostring(i)..' item: '..tostring(r_items[items['inventory'][v]['id']]['enl'])) else
			----inject_packet(is_outgoing, data)
			set_equip(v,i)
			sent_out_equip[i] = v -- re-make the equip_next table with the name sent_out_equip as the equipment is sent out.
			--end
		end
	elseif logging then
		logit(logfile,'\n\n'..tostring(os.clock)..'(69) failure_reason: '..tostring(failure_reason))
	end
	send_check(_global.force_send)
end

function equip(...)
	local gearsets = {...}
	for i in ipairs(gearsets) do
		local temp_set = unify_slots(gearsets[i])
		for n,m in pairs(temp_set) do
			rawset(equip_list,n,m)
		end
	end
end

function print_set(set,title)
	if title then
		add_to_chat(1,'------------------------- '..title..' -------------------------')
	else
		add_to_chat(1,'----------------------------------------------------------------')
	end
	for i,v in pairs(set) do
		add_to_chat(8,tostring(i)..' '..tostring(v))
	end
	add_to_chat(1,'----------------------------------------------------------------')
end

function to_id_set(inventory,equip_list)
	local ret_list = {}
	
	for n,m in pairs(inventory) do
		if m['id'] ~= 0 then -- 0 codes for an empty slot
			if (m['flags'] == 0 or m['flags'] == 5) and r_items[m['id']]['jobs'] then -- Make sure the item isn't being bazaared, isn't already equipped, and can be equipped by specific jobs (unlike pearlsacks).
				if get_wearable(jobs[player.main_job],tonumber('0x'..r_items[m['id']]['jobs'])) and (tonumber(r_items[m['id']]['level'])<=player.main_job_level) and get_wearable(dat_races[player.race],tonumber('0x'..r_items[m['id']]['races'])) then
					for i,v in pairs(equip_list) do
						if not ret_list[slot_map[i]] then
							if r_items[m['id']]['enl']:lower() == v:lower() or r_items[m['id']]['english']:lower() == v:lower() then
								-- I need to add the ability to interpret extdata and specify which item based on it at some point.
								equip_list[i] = ''
								ret_list[slot_map[i]] = m['slot_id']
								break
							end
						end
					end
				else
					for i,v in pairs(equip_list) do
						if r_items[m['id']]['enl']:lower() == v:lower() or r_items[m['id']]['english']:lower() == v:lower() then
							if not get_wearable(jobs[player.main_job],tonumber('0x'..r_items[m['id']]['jobs'])) then
								equip_list[i] = v..' (cannot be worn by this job)'
							elseif not (tonumber(r_items[m['id']]['level'])<=player.main_job_level) then
								equip_list[i] = v..' (job level is too low)'
							elseif not get_wearable(dat_races[player.race],tonumber('0x'..r_items[m['id']]['races'])) then
								equip_list[i] = v..' (cannot be worn by your race)'
							end
							break
						end
					end
				end
			elseif m['flags'] > 0 then
				for i,v in pairs(equip_list) do
					if r_items[m['id']]['enl']:lower() == v:lower() or r_items[m['id']]['english']:lower() == v:lower() then
						if m['flags'] == 5 then
							equip_list[i] = ''
						elseif m['flags'] == 25 then
							equip_list[i] = v..' (bazaared)'
						end
						break
					end
				end
			end
		end
	end
	
	if _global.debug_mode then
		for i,v in pairs(equip_list) do
			if v ~= '' and v ~= 'empty' then
				add_to_chat(8,'GearSwap: '..i..' - '..v)
			end
		end
	end
	
	return ret_list
end

function eliminate_redundant(current_gear,equip_next) -- Eliminates gear you already wear from the table
	for i,v in pairs(current_gear) do
		for n,m in pairs(equip_next) do
			if v==m then
				equip_next[n] = nil
			end
		end
	end
	
	return equip_next
end

function to_names_set(id_id,inventory)
	local equip_package = {}
	for i,v in pairs(id_id) do
		if v~=0 then
			if inventory[v]['id'] == 0 then
				equip_package[i]='empty'
			elseif type(i) ~= 'string' then
				equip_package[default_slot_map[i]] = r_items[inventory[v]['id']]['english']
			else
				equip_package[i]=r_items[inventory[v]['id']]['english']
			end
		else
			equip_package[i]='empty'
		end
	end
	
	return equip_package
end

function send_check(val)
	if not _global.cancel_spell then
		if (val and storedcommand) or (storedcommand and table.length(sent_out_equip) == 0) or (storedcommand and not _global.verify_equip) then
			local assemblecommand
			if not _global.cast_delay or _global.cast_delay == 0 then
				assemblecommand = '@input /raw '..storedcommand.._global.storedtarget
				if debugging>=2 then add_to_chat(5,'Undelayed: '..assemblecommand) end
			else
				assemblecommand = '@wait '.._global.cast_delay..';input /raw '..storedcommand.._global.storedtarget
				if debugging>=2 then add_to_chat(5,'Delayed: '..assemblecommand) end
				_global.cast_delay = nil
				user_env._global.cast_delay = nil
			end
			user_env.storedcommand = nil
			user_env._global.storedtarget = nil
			user_env._global.verify_equip = false
			user_env._global.force_send = false
			storedcommand = nil
			_global.storedtarget = nil
			_global.verify_equip = false
			_global.force_send = false
			action_sent = true
			if logging then logit(logfile,'Command Sent: '..assemblecommand..'\n') end
			send_command(assemblecommand)
		end
	elseif _global.cancel_spell then
		if debugging>=2 then add_to_chat(5,'Canceled.') end
		user_env.storedcommand = nil
		user_env._global.storedtarget = nil
		user_env._global.cast_delay = nil
		user_env._global.verify_equip = false
		user_env._global.force_send = false
		user_env._global.cancel_spell = false
		_global.cancel_spell = false
		storedcommand = nil
		_global.storedtarget = nil
		_global.verify_equip = false
		_global.cast_delay = nil
		_global.force_send = false
		action_sent = true
	end
end

function unify_slots(equipment)
	local unified = {}
	for i,v in pairs(equipment) do
		if slot_map[i] == 11 then
			unified['left_ear'] = v
		elseif slot_map[i] == 12 then
			unified['right_ear'] = v
		elseif slot_map[i] == 13 then
			unified['left_ring'] = v
		elseif slot_map[i] == 14 then
			unified['right_ring'] = v
		else
			unified[i] = v
		end
	end
	return unified
end


function get_wearable(player_val,val)
	return ((val%(player_val*2))/player_val >= 1) -- Cut off the bits above it with modulus, then cut off the bits below it with division and >= 1
end