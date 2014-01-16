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
--Name: equip_sets(swap_type,ind,val1,val2)
--Desc: General purpose equipment pipeline / user function caller. 
--Args:
---- swap_type - Determines equip_sets' behavior in terms of which user function it
--      attempts to call
---- ind - nil or index of out_arr
---- val1 - First argument to be passed to the user function
---- val2 - Second argument to be passed to the user function
-----------------------------------------------------------------------------------
--Return (varies by swap type):
---- pretarget : empty string to blank packet or full string
---- Everything else : nil
-----------------------------------------------------------------------------------
function equip_sets(swap_type,ind,...)
	local var_inps = {...}
	local val1 = var_inps[1]
	local val2 = var_inps[2]
	load_globals(ind)
	if debugging >= 1 then windower.debug(tostring(swap_type)..' enter') 
	if showphase then windower.add_to_chat(8,tostring(swap_type)..' enter') end end
	_global.current_event = tostring(swap_type)
	
	local cur_equip = get_gs_gear(items.equipment,swap_type)
	
	table.reassign(equip_order,default_equip_order)
	table.reassign(equip_list,{})
	table.reassign(player.equipment,to_names_set(cur_equip,items.inventory))
	for i,v in pairs(slot_map) do
		if not player.equipment[i] then
			player.equipment[i] = player.equipment[default_slot_map[v]]
		end
	end
	
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
	
	if _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): '..swap_type) end
	
	if not val1 then val1 = {}
		if debugging >= 2 then
			windower.add_to_chat(8,'val1 error')
		end
	end
	
	if type(swap_type) == 'string' and swap_type == 'pet_midcast' then
		_global.pet_midaction = true
	end

	
	if type(swap_type) == 'function' then
		swap_type(...)
	elseif swap_type == 'equip_command' then
		equip(val1)
	else
		user_pcall(swap_type,...)
	end
	
	
	if type(swap_type) == 'string' and swap_type == 'pretarget' then -- Target may just have been changed, so make the ind now.
		ind = mk_out_arr_entry(val1,{target_id=spell.target.id},nil)
	elseif type(swap_type) == 'string' and swap_type == 'precast' then
		_global.midaction = true
	elseif type(swap_type) == 'string' and swap_type == 'aftercast' then
		_global.midaction = false
	elseif type(swap_type) == 'string' and swap_type == 'pet_aftercast' then
		_global.pet_midaction = false
	end
	
	
	if player.race ~= 'Precomposed NPC' then
		-- Short circuits the routine and gets out  before equip processing
		-- if there's no swapping to be done because the user is a monster.
		
		for i,v in pairs(short_slot_map) do
			if equip_list[i] and (disable_table[v] or encumbrance_table[v]) then
				not_sent_out_equip[i] = equip_list[i]
			end
		end
		
		local equip_next = to_id_set(items.inventory,equip_list) -- Translates the equip_list from the player (i=slot name, v=item name) into a table with i=slot id and v=inventory id.
		equip_next = eliminate_redundant(cur_equip,equip_next) -- Eliminate the equip commands for items that are already equipped
		
		if _settings.show_swaps and table.length(equip_next)>0 then
			local tempset = to_names_set(equip_next,items.inventory)
			print_set(tempset,tostring(swap_type))
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
	end
	
	if debugging >= 1 then windower.debug(tostring(swap_type)..' exit') end
	
	return equip_sets_exit(swap_type,ind,val1,val2)
end


-----------------------------------------------------------------------------------
--Name: equip_sets_exit(swap_type,ind,val1,val2)
--Desc: Cleans up the global table and leaves equip_sets properly.
--Args:
---- swap_type - Current swap type for equip_sets
---- ind - Current index of out_arr
---- val1 - First argument of equip_sets
---- val2 - Second argument of equip_sets
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function equip_sets_exit(swap_type,ind,val1,val2)
	cache_globals(ind)
	if type(swap_type) == 'string' then
		if swap_type == 'pretarget' then
			command_send_check(ind)
			if out_arr[ind] and val1.target and st_targs[val1.target.raw] then
			-- st targets
				st_flag = true
			elseif out_arr[ind] and val1.target and not val1.target.name then
			-- Spells with invalid pass_through_targs, like using <t> without a target
				out_arr[ind] = nil
			elseif out_arr[ind] and val1.target and val1.target.name then
			-- Spells with complete target information
				equip_sets('precast',ind,val1,val2)
				return true
			end
			if storedcommand then
				local tempcmd = storedcommand..' '..spell.target.raw
				storedcommand = nil
				if debugging >= 1 or _global.debugmode then windower.add_to_chat(8,'GearSwap (Debug): Unable to create a packet for this command or action canceled ('..tempcmd..')') end
				return tempcmd
			end
		elseif swap_type == 'precast' then
			packet_send_check(ind)
		elseif swap_type == 'aftercast' then
			d_out_arr_entry(val1,ind)
		end
	end
end


-----------------------------------------------------------------------------------
--Name: user_pcall(str,val1,val2,exit_funct)
--Desc: Calls a user function, if it exists. If not, throws an error.
--Args:
---- str - Function's key in user_env.
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function user_pcall(str,...)
	if user_env then
		if type(user_env[str]) == 'function' then
			user_env[str](...)
		elseif user_env[str] then
			windower.add_to_chat(123,'GearSwap: '..str..'() exists but is not a function')
		end
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
	_global.pet_midaction = false
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
		storedcommand = nil
		out_arr[inde] = nil
	else
		out_arr[inde].spell = spell
		if spell.target and spell.target.id and spell.target.index and spell.prefix and unify_prefix[spell.prefix] then
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
				if not out_arr[inde].proposed_packet then
					out_arr[inde] = nil
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
	local temptab = {...}
	
	-- Console strips quotes, so this is necessary to add them back in
	local inde = temptab[1]..' "'..temptab[2]
	if #temptab > 3 then
		for i=3,#temptab-1 do
			inde = inde..temptab[i]
		end
	end
	inde = inde..'" '..temptab[#temptab]
	
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
		equip_sets('midcast',inde,out_arr[inde].spell)
		windower.send_command('input /assist <me>')
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