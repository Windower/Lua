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



-----------------------------------------------------------------------------------
--Name: equip_sets(swap_type,val1,val2,ind)
--Desc: General purpose equipment pipeline / user function caller. 
--Args:
---- swap_type - Determines equip_sets' behavior in terms of which user function it
--      attempts to call
---- val1 - First argument to be passed to the user function
---- val2 - Second argument to be passed to the user function
---- ind - nil or index of out_arr
-----------------------------------------------------------------------------------
--Return (varies by swap type):
---- pretarget : empty string to blank packet or full string
---- Everything else : nil
-----------------------------------------------------------------------------------
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
		if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Pretarget '..tostring(val1.name)) end
		if type(user_env.pretarget) == 'function' then user_env.pretarget(val1,val2) -- User defined function to determine the pretarget set
		elseif user_env.pretarget then windower.add_to_chat(123,'GearSwap: pretarget() exists but is not a function') end
		ind = mk_out_arr_entry(val1,{target_id=spell.target.id},nil)
	elseif swap_type == 'precast' then
		if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Precast '..tostring(val1.name)) end
		if type(user_env.precast) == 'function' then user_env.precast(val1,val2) -- User defined function to determine the precast set
		elseif user_env.precast then windower.add_to_chat(123,'GearSwap: precast() exists but is not a function') end
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
			return command_send_check(ind)
		elseif swap_type == 'precast' then
			packet_send_check(ind)
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
		local one_sent
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
		command_send_check(ind)
		if not out_arr[ind] then -- Cancelled spell
			return
		elseif val1.target and not st_targs:contains(val1.target.raw) then
			equip_sets('precast',val1,val2,ind)
			return ''
		elseif val1.target and st_targs:contains(val1.target.raw) then
			st_flag = true
			return
		end
	elseif swap_type == 'precast' then
		packet_send_check(ind)
	elseif swap_type == 'aftercast' then
		d_out_arr_entry(val1,ind)
	end
end


-----------------------------------------------------------------------------------
--Name: load_globals(inde)
--Desc: Takes the relevant values from out_arr for the current action and places 
--      them in the _global table, to preserve their values from pretarget to
--      precast.
--Args:
---- inde - key for out_arr
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function load_globals(inde)
	for i,v in pairs(_global) do
		if out_arr[inde] and out_arr[inde][i] then
			_global[i] = out_arr[inde][i]
		end
	end
end


-----------------------------------------------------------------------------------
--Name: cache_globals(inde)
--Desc: Takes the values from _global for the current action and places them in the
--      relevant out_arr table, to preserve their values from pretarget to precast.
--Args:
---- inde - key for out_arr
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function cache_globals(inde)
	for i,v in pairs(_global) do
		if out_arr[inde] then
			out_arr[inde][i] = v
		end
	end
	_global.cast_delay = 0
	_global.storedtarget = ''
	_global.midaction = false
	_global.cancel_spell = false
end



-----------------------------------------------------------------------------------
--Name: command_send_check(inde)
--Desc: Check at the end of pretarget to see whether or not the command should be sent.
--Args:
---- inde - out_arr index of the current spell
-----------------------------------------------------------------------------------
--Returns:
---- string - gets propagated back to the outgoing_text function
-----------------------------------------------------------------------------------
function command_send_check(inde)
	if out_arr[inde].cancel_spell then
		if debugging>=2 then windower.add_to_chat(5,'Spell canceled.') end
		storedcommand = nil
		out_arr[inde] = nil
	else
		out_arr[inde].spell = spell
		if spell.target and spell.target.id and spell.prefix and unify_prefix[spell.prefix] then
			if spell.prefix == '/item' then
				-- Item use packet handling here
				if spell.target.id == player.id then
					--0x37 packet
					out_arr[inde].proposed_packet = assemble_use_item_packet(spell.target.id,spell.target.index,spell.id)
				else
					--0x36 packet
					test_packet = assemble_menu_item_packet(spell.target.id,spell.target.index,spell.id)
					out_arr[inde].proposed_packet = test_packet
				end
				if not out_arr[inde].proposed_packet then
					out_arr[inde] = nil
				end
			elseif outgoing_action_category_table[unify_prefix[spell.prefix]] then
				if outgoing_action_category_table[unify_prefix[spell.prefix]] == 3 then
					out_arr[inde].proposed_packet = assemble_action_packet(spell.target.id,spell.target.index,outgoing_action_category_table[unify_prefix[spell.prefix]],spell.index)
				else
					out_arr[inde].proposed_packet = assemble_action_packet(spell.target.id,spell.target.index,outgoing_action_category_table[unify_prefix[spell.prefix]],spell.id)
				end
			else
				windower.add_to_chat(8,"GearSwap: Hark, what weird prefix through yonder window breaks? "..tostring(spell.prefix))
			end
		end
	end
end



-----------------------------------------------------------------------------------
--Name: packet_send_check(inde)
--Desc: Determines whether or not to send the current packet.
--      Cancels if _global.cancel_spell is true
--          If out_arr[inde].cast_delay is not 0, cues delayed_cast with the proper
--          delay instead of sending immediately.
--Args:
---- inde - key of out_arr
-----------------------------------------------------------------------------------
--Returns:
---- true (to block) or the outgoing packet
-----------------------------------------------------------------------------------
function packet_send_check(inde)
	if out_arr[inde] then
		if out_arr[inde].cancel_spell then
			out_arr[inde] = nil
		else
			if out_arr[inde].cast_delay == 0 then
				send_action(inde)
				return
			else
				windower.send_command('@wait '..out_arr[inde].cast_delay..';lua i '.._addon.name..' delayed_cast '..inde)
			end
		end
	end
	return true
end


-----------------------------------------------------------------------------------
--Name: delayed_cast(...)
--Desc: Triggers an outgoing action packet (if the passed key is valid).
--Args:
---- {...} - space delimited key for out_arr (hopefully)
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function delayed_cast(...)
	local inde = table.concat({...},' ')
	if out_arr[inde] then
		send_action(inde)
	elseif debugging >= 1 or _settings.debug_mode then
		windower.add_to_chat(8,'GearSwap (Debug Mode): Bad index passed to delayed_cast')
	end
end


-----------------------------------------------------------------------------------
--Name: send_action(inde)
--Desc: Sends the cued action packet, if it exists.
--Args:
---- inde - Key to an out_arr entry that includes an action packet (hopefully)
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function send_action(inde)
	if out_arr[inde].proposed_packet then
		cued_packet = inde
		windower.packets.inject_outgoing(out_arr[inde].proposed_packet:byte(1),out_arr[inde].proposed_packet)
		equip_sets('midcast',out_arr[inde].spell,{type=out_arr[inde].spell.type},inde)
		windower.send_command('input /echo Sending!;input /assist <me>')
	else
		windower.add_to_chat(123,'GearSwap: Cued Packet not found')
	end
end


-----------------------------------------------------------------------------------
--Name: outgoing chunk(id,original,modified,injected,blocked)
--Desc: Searches the outgoing chunks for a packet corresponding to /assist <me>.
--      If found, blocks that packet.
--Args:
---- id - ID of the current outgoing chunk
---- original - Original outgoing chunk from the buffer
---- modified - Outgoing chunk from the buffer after modification
----      by other addons/plugins
---- injected - Boolean indicating whether or not the packet was injected
---- blocked - Boolean indicating whether or not the packet is currently blocked
-----------------------------------------------------------------------------------
--Returns:
---- true if blocking the packet (/assist <me>)
-----------------------------------------------------------------------------------
windower.register_event('outgoing chunk',function(id,original,modified,injected,blocked)
	if gearswap_disabled then return end
	if debugging >= 1 then windower.debug('outgoing chunk '..id) end
	if id == 0x1A and not injected then
		local cur_time = os.clock()
		for i,v in pairs(outgoing_packet_table) do
			if cur_time-v > 1 then
				outgoing_packet_table[i] = nil
			elseif i:sub(1,2) == original:sub(1,2) and i:sub(5) == original:sub(5) then
				return
			end
		end
		outgoing_packet_table[original] = os.clock()

		local target_index = get_bit_packed(original,64,80)
		local category = get_bit_packed(original,80,96)
		local target_id = windower.ffxi.get_mob_by_index(target_index).id
		if category == 12 and cued_packet and out_arr[cued_packet] and out_arr[cued_packet].proposed_packet and target_id == player.id then
			cued_packet = nil
			return true
		end
	elseif id == 0x1A and injected and clocking then
		windower.add_to_chat(8,'Injection time: '..(os.clock()-out_time))
	end
end)