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


function equip_sets(swap_type,val1,val2)
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

	if swap_type == 'precast' then
		if _global.debug_mode then windower.add_to_chat(8,'Gearswap (Debug Mode): Precast '..tostring(val1.name)) end
		val1.target = spelltarget
		if type(user_env.precast) == 'function' then user_env.precast(val1,val2) -- User defined function to determine the precast set
		elseif user_env.precast then windower.add_to_chat(123,'GearSwap: precast() exists but is not a function') end
		if _global.verify_equip and not force_flag then
			force_flag = true
			windower.send_command('@wait 1;lua invoke gearswap sender')
		end
		persistent_spell = val1
	elseif swap_type == 'midcast' then
		if _global.debug_mode then windower.add_to_chat(8,'Gearswap (Debug Mode): Midcast '..tostring(val1.name)) end
		val1.target = spelltarget
		user_env.midcast(val1,val2) -- User defined function to determine the midcast set
		persistent_spell = val1
	elseif swap_type == 'aftercast' then
		if _global.debug_mode then windower.add_to_chat(8,'Gearswap (Debug Mode): Aftercast '..tostring(val1.name)) end
		if not val1 then val1 = {}
			if debugging >= 2 then
				windower.add_to_chat(8,'val1 error')
			end
		end
		val1.target = spelltarget
		_global.midaction = false
		spelltarget = nil
		user_env.aftercast(val1,val2) -- User defined function to determine the aftercast set
		persistent_spell = val1
	elseif swap_type == 'pet_midcast' then
		if _global.debug_mode then windower.add_to_chat(8,'Gearswap (Debug Mode): Pet Midcast '..tostring(val1.name)) end
		val1.target = spelltarget
		user_env.pet_midcast(val1,val2) -- User defined function to determine the midcast set
		persistent_spell = val1
	elseif swap_type == 'pet_aftercast' then
		if _global.debug_mode then windower.add_to_chat(8,'Gearswap (Debug Mode): Pet Aftercast '..tostring(val1.name)) end
		if val1 then
			val1.target = spelltarget
		else
			windower.add_to_chat(8,'---------------- VAL1 IS NIL ------------')
		end
		user_env.pet_aftercast(val1,val2) -- User defined function to determine the aftercast set
		persistent_spell = val1
	elseif swap_type == 'status_change' then
		if _global.debug_mode then windower.add_to_chat(8,'Gearswap (Debug Mode): Status Change '..tostring(val1)..' '..tostring(val2))
			for i=1,#val2 do
				windower.add_to_chat(8,'Gearswap (Debug Mode): '..i..' '..string.byte(val2[i]))
			end
		end
		if type(user_env.status_change) == 'function' then user_env.status_change(val1,val2) -- User defined function to determine if sets should change following status change
		elseif user_env.status_change then windower.add_to_chat(123,'GearSwap: status_change() exists but is not a function') end
	elseif swap_type == 'buff_change' then
		if _global.debug_mode then windower.add_to_chat(8,'Gearswap (Debug Mode): Buff Change '..tostring(val1)..' '..tostring(val2)) end
		if type(user_env.buff_change) == 'function' then user_env.buff_change(val1,val2) -- User defined function to determine if sets should change following buff change
		elseif user_env.buff_change then windower.add_to_chat(123,'GearSwap: buff_change() exists but is not a function') end
	elseif swap_type == 'equip_command' then
		equip(val1)
	elseif swap_type == 'self_command' then
		if _global.debug_mode then windower.add_to_chat(8,'Gearswap (Debug Mode): Self Command '..tostring(val1)) end
		if type(user_env.self_command) == 'function' then user_env.self_command(val1)
		elseif user_env.self_command then windower.add_to_chat(123,'GearSwap: self_command() exists but is not a function') end
	elseif swap_type == 'delayed' then
		equip(stored_equip_list)
	end
	
	if player.race == 'Precomposed NPC' then
		-- Short circuit the routine and get out if there's no swapping to be done because the user is a monster.
		send_check(true)
		return
	end
	
--[[	for i,v in pairs(equip_list) do
		if not slot_map[i] then
			if debugmode then
				windower.add_to_chat(8,'GearSwap (Debug Mode): Attempting to equip an item in an unrecognized slot ('..tostring(i)..')')
			end
			equip_list[i] = nil
		end
	end]]
	
	local equip_next = {}
	-- Need to make sure the item isn't being traded or synthesized.
		
	equip_next = to_id_set(items.inventory,equip_list) -- Translates the equip_list from the player (i=slot name, v=item name) into a table with i=slot id and v=inventory id.
	
	for i,v in pairs(disable_table) do
		if v then
			not_sent_out_equip[i] = equip_next[i]
		end
	end
	for i,v in pairs(encumbrance_table) do
		if v then
			not_sent_out_equip[i] = equip_next[i]
		end
	end
	
	equip_next = eliminate_redundant(cur_equip,equip_next) -- Eliminate the equip commands for items that are already equipped
	
	if _global.show_swaps and table.length(equip_next)>0 then
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
		if _global.debug_mode and failure_reason then
			windower.add_to_chat(8,'Gearswap (Debug Mode): Cannot change gear right now: '..failure_reason)
		end
	end
	
	
	if not failure_reason then
		for _,i in ipairs(equip_order) do
			if debugging >= 3 and equip_next[i] then
				local out_str = 'Order: '..tostring(_)..'  Slot ID: '..tostring(i)
				if equip_next[i] ~= 0 then
					out_str = out_str..'  Item: '..tostring(r_items[items.inventory[equip_next[i]].id][language..'_log'])
				else
					out_str = out_str..'  Emptying slot'
				end
				windower.add_to_chat(8,'Gearswap (Debugging): '..out_str)
			elseif equip_next[i] and not disable_table[i] and not encumbrance_table[i] then
				windower.ffxi.set_equip(equip_next[i],i)
				sent_out_equip[i] = equip_next[i] -- re-make the equip_next table with the name sent_out_equip as the equipment is sent out.
			elseif equip_next[i] then
				not_sent_out_equip[i] = equip_next[i]
			end
		end
	elseif logging then
		logit(logfile,'\n\n'..tostring(os.clock)..'(69) failure_reason: '..tostring(failure_reason))
	end
	if swap_type == 'precast' then send_check(_global.force_send) end
end

function to_id_set(inventory,equip_list)
	local ret_list = {}
	for n,m in pairs(inventory) do
		if m.id and m.id ~= 0 then -- 0 codes for an empty slot, but Arcon will probably make it nil at some point
			if (m.flags == 0 or m.flags == 5) and r_items[m.id].jobs then -- Make sure the item isn't being bazaared, isn't already equipped, and can be equipped by specific jobs (unlike pearlsacks).
				if get_wearable(jobs[player.main_job],r_items[m.id].jobs) and (r_items[m.id].level<=player.main_job_level) and get_wearable(dat_races[player.race],r_items[m.id].races) then
					for i,v in pairs(equip_list) do
						local name,order
						local extgoal = {}
						if type(v) == 'table' and v == empty then
							name = empty
						elseif type(v) == 'table' and v.name then
							name = v.name
							if v.augments then
								for n,m in pairs(v.augments) do
									extgoal[n] = augment_to_extdata(m)
								end
							elseif v.augment then
								extgoal[1] = augment_to_extdata(v.augment)
							end
							order = v.order
						elseif type(v) == 'string' then
							name = v
						end
						-- v can also be a table (that doesn't contain a "name" property) or a number, which are both cases that should not generate any kind of equipment changing.
						-- Hence the "and name" below.
						if not ret_list[slot_map[i]] and name then
							if type(name) == 'table' and name == empty then
								ret_list[slot_map[i]] = 0
								reorder(order,i)
							elseif (r_items[m['id']][language..'_log']:lower() == name:lower() or r_items[m['id']][language]:lower() == name:lower()) and get_wearable(dat_slots[slot_map[i]],r_items[m.id].slots) then
								if extgoal[1] then
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
									windower.add_to_chat(8,tostring(count))
									if count == #extgoal then
										equip_list[i] = ''
										ret_list[slot_map[i]] = m.slot_id
										reorder(order,i)
										break
									end
								else
									equip_list[i] = ''
									ret_list[slot_map[i]] = m.slot_id
										reorder(order,i)
									break
								end
							elseif (r_items[m.id][language..'_log']:lower() == name:lower() or r_items[m.id][language]:lower() == name:lower()) and not get_wearable(dat_slots[slot_map[i]],r_items[m.id].slots) then
								equip_list[i] = name..' (cannot be worn in this slot)'
							end
						end
					end
				else
					for i,v in pairs(equip_list) do
						local name
						if type(v) == 'table' and v~=empty then
							name = v.name
						elseif type(v) == 'string' then
							name = v
						end
						if v == empty then
						elseif not name then
							windower.add_to_chat(123,'Gearswap: Invalid name found. ('..tostring(v)..')')
						elseif r_items[m['id']][language..'_log']:lower() == name:lower() or r_items[m['id']][language]:lower() == name:lower() then
							if not get_wearable(jobs[player.main_job],r_items[m.id].jobs) then
								equip_list[i] = name..' (cannot be worn by this job)'
							elseif not (tonumber(r_items[m.id].level)<=player.main_job_level) then
								equip_list[i] = name..' (job level is too low)'
							elseif not get_wearable(dat_races[player.race],r_items[m.id].races) then
								equip_list[i] = name..' (cannot be worn by your race)'
							elseif not get_wearable(slot_map[i],r_items[m.id].slots) then
								equip_list[i] = name..' (cannot be worn in this slot)'
							end
							break
						end
					end
				end
			elseif m.flags > 0 then
				for i,v in pairs(equip_list) do
					local name
					if type(v) == 'table' then
						name = v.name
					elseif type(v) == 'string' then
						name = v
					end
					if name then -- If "name" isn't a piece of gear, then it won't have a valid value at this point and should be ignored.
						if r_items[m.id][language..'_log']:lower() == name:lower() or r_items[m.id][language]:lower() == name:lower() then
							if m.flags == 5 then
								equip_list[i] = ''
							elseif m.flags == 25 then
								equip_list[i] = name..' (bazaared)'
							end
							break
						end
					end
				end
			end
		end
	end
	
	if _global.debug_mode then
		for i,v in pairs(equip_list) do
			if type(v) == 'string' and v ~= 'empty' and v~='' then
				windower.add_to_chat(8,'GearSwap (Debug Mode): Unhandled slot '..i..' - '..v)
			end
		end
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
		windower.add_to_chat(123,'Gearswap: Invalid order given')
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

function send_check(val)
	if not _global.cancel_spell then
--		print('arg1: '..tostring(val and storedcommand)..'  arg2: '..tostring(storedcommand)..' '..tostring(table.length(sent_out_equip))..'  arg3: '..tostring(storedcommand and not _global.verify_equip))
		if (val and storedcommand) or (storedcommand and table.length(sent_out_equip) == 0) or (storedcommand and not _global.verify_equip) then
			local assemblecommand
			if not _global.cast_delay or _global.cast_delay == 0 then
				assemblecommand = '@input /raw '..storedcommand.._global.storedtarget
				if debugging>=2 then windower.add_to_chat(5,'Undelayed: '..assemblecommand) end
			else
				assemblecommand = '@wait '.._global.cast_delay..';input /raw '..storedcommand.._global.storedtarget
				if debugging>=2 then windower.add_to_chat(5,'Delayed: '..assemblecommand) end
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
			windower.send_command(assemblecommand)
		end
	elseif _global.cancel_spell then
		if debugging>=2 then windower.add_to_chat(5,'Canceled.') end
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
		if not slot_map[i] then
		elseif slot_map[i] == 11 then
			unified.left_ear = v
		elseif slot_map[i] == 12 then
			unified.right_ear = v
		elseif slot_map[i] == 13 then
			unified.left_ring = v
		elseif slot_map[i] == 14 then
			unified.right_ring = v
		else
			unified[i] = v
		end
	end
	return unified
end

function get_wearable(player_val,val)
	if player_val then
		return ((val%(player_val*2))/player_val >= 1) -- Cut off the bits above it with modulus, then cut off the bits below it with division and >= 1
	else
		return false -- In cases where the provided playervalue is nil, just return false.
	end
end

function get_gs_gear(cur_equip,swap_type)
	local sent_out_box = 'Going into '..swap_type..':\n' -- i = 'head', 'feet', etc.; v = inventory ID (0~80)
	-- If the swap is not complete, overwrite the current equipment with the equipment that you are swapping to
	for i,v in pairs(cur_equip) do
		if sent_out_equip[slot_map[i]] then
			cur_equip[i] = sent_out_equip[slot_map[i]]
		elseif not_sent_out_equip[slot_map[i]] then
			cur_equip[i] = not_sent_out_equip[slot_map[i]]
		end
		if v == 0 then
			cur_equip[i] = empty
		end
		if v and v ~= 0 and debugging > 0 and items.inventory[v] and r_items[items.inventory[v].id] then
			sent_out_box = sent_out_box..tostring(i)..' '..tostring(r_items[items.inventory[v].id].english)..'\n'
		end
	end
	if debugging > 0 then windower.text.set_text(swap_type,sent_out_box) end
	return cur_equip
end