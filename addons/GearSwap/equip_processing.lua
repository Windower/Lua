--Copyright (c) 2013, Byrthnoth
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


function equip_sets(swap_type,val1,val2,ind)
	load_globals(ind)
	if debugging >= 1 then windower.debug(swap_type..' enter') end
	_global.current_event = swap_type
	refresh_globals()
	local cur_equip = get_gs_gear(items.equipment,swap_type)
	
	table.reassign(equip_order,default_equip_order)
	table.reassign(equip_list,to_names_set(cur_equip,items.inventory))
	
	if debugging >= 2 then windower.add_to_chat(8,swap_type) end
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

	if swap_type == 'pretarget' then
		_global.cast_delay = 0
		_global.verify_equip = false
		_global.force_send = false
		if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Pretarget '..tostring(val1.name)) end
		if type(user_env.pretarget) == 'function' then user_env.pretarget(val1,val2) -- User defined function to determine the pretarget set
		elseif user_env.pretarget then windower.add_to_chat(123,'GearSwap: pretarget() exists but is not a function') end
		ind = mk_out_arr_entry(val1,{target_id=spell.target.id},nil)
	elseif swap_type == 'precast' then
		if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Precast '..tostring(val1.name)) end
		if type(user_env.precast) == 'function' then user_env.precast(val1,val2) -- User defined function to determine the precast set
		elseif user_env.precast then windower.add_to_chat(123,'GearSwap: precast() exists but is not a function') end
		if _global.verify_equip then
			windower.send_command('@wait 1;lua i '.._addon.name..' sender '..ind)
		end
		_global.midaction = true
	elseif swap_type == 'midcast' then
		if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Midcast '..tostring(val1.name)) end
		user_env.midcast(val1,val2) -- User defined function to determine the midcast set
	elseif swap_type == 'aftercast' then
		if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Aftercast '..tostring(val1.name)) end
		if not val1 then val1 = {}
			if debugging >= 2 then
				windower.add_to_chat(8,'val1 error')
			end
		end
		_global.midaction = false
		user_env.aftercast(val1,val2) -- User defined function to determine the aftercast set
	elseif swap_type == 'pet_midcast' then
		if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Pet Midcast '..tostring(val1.name)) end
		user_env.pet_midcast(val1,val2) -- User defined function to determine the midcast set
	elseif swap_type == 'pet_aftercast' then
		if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Pet Aftercast '..tostring(val1.name)) end
		if val1 then
		else
			windower.add_to_chat(8,'---------------- VAL1 IS NIL ------------')
		end
		user_env.pet_aftercast(val1,val2) -- User defined function to determine the aftercast set
	elseif swap_type == 'status_change' then
		if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Status Change '..tostring(val1)..' '..tostring(val2))
			for i=1,#val2 do
				windower.add_to_chat(8,'GearSwap (Debug Mode): '..i..' '..string.byte(val2[i]))
			end
		end
		if type(user_env.status_change) == 'function' then user_env.status_change(val1,val2) -- User defined function to determine if sets should change following status change
		elseif user_env.status_change then windower.add_to_chat(123,'GearSwap: status_change() exists but is not a function') end
	elseif swap_type == 'buff_change' then
		if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Buff Change '..tostring(val1)..' '..tostring(val2)) end
		if type(user_env.buff_change) == 'function' then user_env.buff_change(val1,val2) -- User defined function to determine if sets should change following buff change
		elseif user_env.buff_change then windower.add_to_chat(123,'GearSwap: buff_change() exists but is not a function') end
	elseif swap_type == 'equip_command' then
		equip(val1)
	elseif swap_type == 'self_command' then
		if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Self Command '..tostring(val1)) end
		if type(user_env.self_command) == 'function' then user_env.self_command(val1)
		elseif user_env.self_command then windower.add_to_chat(123,'GearSwap: self_command() exists but is not a function') end
	elseif swap_type == 'delayed' then
		equip(stored_equip_list)
	end
	
	if player.race == 'Precomposed NPC' then
		-- Short circuit the routine and get out if there's no swapping to be done because the user is a monster.
		if swap_type == 'pretarget' then
			command_send_check(out_arr[ind].storedtarget)
		elseif swap_type == 'precast' then
			packet_send_check(true,ind)
		elseif swap_type == 'aftercast' then
			d_out_arr_entry(val1,ind)
		end
		return
	end
	
	
	for i,v in pairs(short_slot_map) do
		if equip_list[i] and (disable_table[v] or encumbrance_table[v]) then
			not_sent_out_equip[i] = equip_list[i]
		end
	end
	
	local equip_next = to_id_set(items.inventory,equip_list) -- Translates the equip_list from the player (i=slot name, v=item name) into a table with i=slot id and v=inventory id.
	equip_next = eliminate_redundant(cur_equip,equip_next) -- Eliminate the equip commands for items that are already equipped
	
	if _settings.show_swaps and table.length(equip_next)>0 then
		local tempset = to_names_set(equip_next,items.inventory)
		print_set(tempset,swap_type)
	end
	
	local failure_reason
	for i,v in pairs(player.buffs) do
		if v==14 or v == 17 then
			failure_reason = 'Charmed'
		elseif v == 0 then
			failure_reason = 'KOed'
		end
		if _settings.debug_mode and failure_reason then
			windower.add_to_chat(8,'GearSwap (Debug Mode): Cannot change gear right now: '..failure_reason)
		end
	end
	
	
	if not failure_reason then
		if ind and _global.verify_equip then sent_out_equip.ind = ind end
		
		for _,i in ipairs(equip_order) do
			if debugging >= 3 and equip_next[i] then
				local out_str = 'Order: '..tostring(_)..'  Slot ID: '..tostring(i)..'  Inv. ID: '..tostring(equip_next[i])
				if equip_next[i] ~= 0 then
					out_str = out_str..'  Item: '..tostring(r_items[items.inventory[equip_next[i]].id][language..'_log'])
				else
					out_str = out_str..'  Emptying slot'
				end
				windower.add_to_chat(8,'GearSwap (Debugging): '..out_str)
			elseif equip_next[i] and not disable_table[i] and not encumbrance_table[i] then
				windower.debug('attempting to set gear. Order: '..tostring(_)..'  Slot ID: '..tostring(i)..'  Inv. ID: '..tostring(equip_next[i]))
				windower.ffxi.set_equip(equip_next[i],i)
				sent_out_equip[i] = equip_next[i] -- re-make the equip_next table with the name sent_out_equip as the equipment is sent out.
			end
		end
	elseif logging then
		logit(logfile,'\n\n'..tostring(os.clock)..'(69) failure_reason: '..tostring(failure_reason))
	end
	if debugging >= 1 then windower.debug(swap_type..' exit') end
	
	cache_globals(ind)
	if swap_type == 'pretarget' then
		return command_send_check(ind)
	elseif swap_type == 'precast' then
		return packet_send_check(_global.force_send,ind)
	elseif swap_type == 'aftercast' then
		d_out_arr_entry(val1,ind)
	end
end

function check_wearable(item_id)
	if not item_id or item_id == 0 then -- 0 codes for an empty slot, but Arcon will probably make it nil at some point
	elseif not r_items[item_id] then
		if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Item '..item_id..' has not been added to resources yet.') end
	elseif not r_items[item_id].jobs then -- Make sure item can be equipped by specific jobs (unlike pearlsacks).
		if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Item '..item_id..' does not have a jobs field in the resources.') end
	else
		return (get_wearable(jobs[player.main_job],r_items[item_id].jobs) and (r_items[item_id].level<=player.main_job_level) and get_wearable(dat_races[player.race],r_items[item_id].races))
	end
	return false
end

function expand_entry(v)
	if not v then
		return
	end
	local extgoal,name,order
	if type(v) == 'table' and v == empty then
		name = empty
	elseif type(v) == 'table' and v.name then
		name = v.name
		if v.augments then
			extgoal = {}
			for n,m in pairs(v.augments) do
				extgoal[n] = augment_to_extdata(m)
			end
		elseif v.augment then
			extgoal = {}
			extgoal[1] = augment_to_extdata(v.augment)
		end
		order = v.order
	elseif type(v) == 'string' and v ~= '' then
		name = v
	end
	return name,order,extgoal -- These values are nil if they don't exist.
end

function name_match(item_id,name)
	if r_items[item_id] then
		return (r_items[item_id][language..'_log']:lower() == name:lower() or r_items[item_id][language]:lower() == name:lower())
	else
		return false
	end
end

-----------------------------------------------------------------------------------
--Name: to_id_set(inventory,equip_list)
--Args:
---- inventory - Current inventory (potentially avoids a get_items() call)
---- equip_list - Keys are standard slot names, values are item names.
-----------------------------------------------------------------------------------
--Returns:
---- Table with keys that are slot numbers with values that are inventory slot #s.
-----------------------------------------------------------------------------------
function to_id_set(inventory,equip_list)
	local ret_list = {}
	local error_list = {}
	for i,v in pairs(short_slot_map) do -- Should go sanitize equip() so that it changes everything to default_slot_map
		local name,order,extgoal = expand_entry(equip_list[i])
		if name == empty or name =='empty' then
			ret_list[v] = 0
			reorder(order,i)
			equip_list[i] = nil
		end
	end
	for n,m in pairs(inventory) do
		if check_wearable(m.id) then
			if m.flags == 0 or m.flags == 5 then -- Make sure the item is either equipped or not otherwise committed. eliminate_redundant will take care of the already-equipped gear.
				for i,v in pairs(short_slot_map) do
					local name,order,extgoal = expand_entry(equip_list[i])
					-- equip_list[i] can also be a table (that doesn't contain a "name" property) or a number, which are both cases that should not generate any kind of equipment changing.
					-- Hence the "and name" below.
					if not ret_list[v] and name then
						if name_match(m.id,name) and get_wearable(dat_slots[v],r_items[m.id].slots) then
							if extgoal then
								local count = 0
								for o,q in pairs(extgoal) do
									-- It appears only the first five bits are used for augment value.
								--	local first,second,third = string.char(m.extdata:byte(4)%32), string.char(m.extdata:byte(6)%32), string.char(m.extdata:byte(8)%32)
								--	local exttemp = m.extdata:sub(1,3)..first..m.extdata:sub(5,5)..second..m.extdata:sub(7,7)..third..m.extdata:sub(9)
									local exttemp = m.extdata
									if exttemp:sub(3,4) == q or exttemp:sub(5,6) == q or exttemp:sub(7,8) == q then
										count = count +1
									end
								end
								if count == #extgoal then
									equip_list[i] = nil
									ret_list[v] = m.slot_id
									reorder(order,i)
									break
								end
							else
								equip_list[i] = nil
								ret_list[v] = m.slot_id
								reorder(order,i)
								break
							end
						elseif name_match(m.id,name) and not get_wearable(dat_slots[v],r_items[m.id].slots) then
							equip_list[i] = nil
							error_list[i] = name..' (cannot be worn in this slot)'
							break
						end
					end
				end
			elseif m.flags > 0 then
				for i,v in pairs(short_slot_map) do
					local name = expand_entry(equip_list[i])
					if name and name ~= empty then -- If "name" isn't a piece of gear, then it won't have a valid value at this point and should be ignored.
						if name_match(m.id,name) then
							if m.flags == 5 then
								error_list[i] = name..' (equipped)'
							elseif m.flags == 25 then
								error_list[i] = name..' (bazaared)'
							else
								error_list[i] = name..' (flags unknown: '..m.flags..' )'
							end
							break
						end
					end
				end
			end
		else
			for i,v in pairs(short_slot_map) do
				local name = expand_entry(equip_list[i])
				if name == empty then
				elseif name_match(item_id,name) then
					if not get_wearable(jobs[player.main_job],r_items[m.id].jobs) then
						equip_list[i] = nil
						error_list[i] = name..' (cannot be worn by this job)'
					elseif not (tonumber(r_items[m.id].level)<=player.main_job_level) then
						equip_list[i] = nil
						error_list[i] = name..' (job level is too low)'
					elseif not get_wearable(dat_races[player.race],r_items[m.id].races) then
						equip_list[i] = nil
						error_list[i] = name..' (cannot be worn by your race)'
					end
					break
				end
			end
		end
	end
	
	if _settings.debug_mode and table.length(error_list) > 0 then
		print_set(error_list,'Debug Mode (error list)')
	end
	if _settings.debug_mode and table.length(equip_list) > 0 then
		print_set(equip_list,'Debug Mode (gear not equipped)')
	end
	
	return ret_list
end

function reorder(order,i)
	if order and order < 17 and order > 0 then
		local temp_order
		for o,q in pairs(equip_order) do
			if q == slot_map[i] then
				temp_order = o -- o is the current slot of the item being redefined.
				break
			end
		end
		equip_order[temp_order] = equip_order[order]
		equip_order[order] = slot_map[i]
	elseif order then
		windower.add_to_chat(123,'GearSwap: Invalid order given')
	end
end

function eliminate_redundant(current_gear,equip_next) -- Eliminates gear you already wear from the table
	for i,v in pairs(current_gear) do
		if v == empty and (equip_next[slot_map[i]] == 0 or equip_next[slot_map[i]] == empty) then
			equip_next[slot_map[i]] = nil
		else
			for n,m in pairs(equip_next) do
				if v==m and v ~= 0 then
					equip_next[n] = nil
				end
			end
		end
	end
	return equip_next
end

function to_names_set(id_id,inventory)
	local equip_package = {}
	for i,v in pairs(id_id) do
		if v~=0 and v~=empty then
			if inventory[v].id == 0 then
				equip_package[i]=''
			elseif type(i) ~= 'string' then
				equip_package[default_slot_map[i]] = r_items[inventory[v].id][language]
			else
				equip_package[i]=r_items[inventory[v].id][language]
			end
		else
			if type(i)~= 'string' then
				equip_package[default_slot_map[i]] = 'empty'
			else
				equip_package[i]='empty'
			end
		end
	end
	
	return equip_package
end

function unify_slots(equipment)
	local unified = {}
	for i,v in pairs(equipment) do
		if default_slot_map[slot_map[i]] then
			unified[default_slot_map[slot_map[i]]] = v
		end
	end
	return unified
end

function get_gs_gear(cur_equip,swap_type)
	local temp_set = table.reassign({},cur_equip)
	local sent_out_box = 'Going into '..swap_type..':\n' -- i = 'head', 'feet', etc.; v = inventory ID (0~80)
	-- If the swap is not complete, overwrite the current equipment with the equipment that you are swapping to
	local not_sent_ids = to_id_set(items.inventory,not_sent_out_equip)

	for i,v in pairs(cur_equip) do
		if sent_out_equip[short_slot_map[i]] then
			cur_equip[i] = sent_out_equip[short_slot_map[i]]
		elseif not_sent_ids[short_slot_map[i]] then
			cur_equip[i] = not_sent_ids[short_slot_map[i]]
		end
		if v == 0 or v == 'empty' then
			cur_equip[i] = empty
		end
		if v and v ~= 0 and debugging > 0 and items.inventory[v] and r_items[items.inventory[v].id] then
			sent_out_box = sent_out_box..tostring(i)..' '..tostring(r_items[items.inventory[v].id].english)..'\n'
		end
	end
	if debugging > 0 then windower.text.set_text(swap_type,sent_out_box) end
	return cur_equip
end