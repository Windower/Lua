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
--Name: outgoing_text(original,modified)
--Desc: Searches the client's outgoing text for GearSwap handled commands and 
--      returns '' if it finds one. Otherwise returns the command unaltered.
--Args:
---- original - String entered by the user
---- modified - String after being modified by upstream addons/plugins
-----------------------------------------------------------------------------------
--Returns:
---- none or ''
-----------------------------------------------------------------------------------
windower.register_event('outgoing text',function(original,modified)
	if debugging >= 1 then windower.debug('outgoing text (debugging)') end
	if gearswap_disabled then return modified end
	
	local temp_mod = windower.convert_auto_trans(modified)
	local splitline = temp_mod:split(' ')
	local command = splitline[1]

	local a,b,abil = string.find(temp_mod,'"(.-)"')
	if abil then
		abil = abil:lower()
	elseif splitline.n == 3 then
		abil = splitline[2]:lower()
	end
	
	local temptarg,temp_mob_arr = valid_target(splitline[splitline.n])
	
	if command_list[command] and temptarg and (validabils[language][unify_prefix[command]][abil] or unify_prefix[command]=='/ra') then
		if st_flag then
			st_flag = nil
		elseif temp_mob_arr then
			if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(93) temp_mod: '..temp_mod) end
			if clocking then out_time = os.clock() end
	
			local r_line
				
			if command_list[command] == 'Magic' then
				r_line = r_spells[validabils[language][unify_prefix[command]][abil]]
				storedcommand = command..' "'..r_line[language]..'" '
			elseif command_list[command] == 'Ability' then
				r_line = r_abilities[validabils[language][unify_prefix[command]][abil]]
				storedcommand = command..' "'..r_line[language]..'" '
			elseif command_list[command] == 'Item' then
				r_line = r_items[validabils[language][unify_prefix[command]][abil]]
				r_line.prefix = '/item'
				r_line.type = 'Item'
				storedcommand = command..' "'..r_line[language]..'" '
			elseif command_list[command] == 'Ranged Attack' then
				rline = r_abilities[1]
				storedcommand = command..' '
			end
			
			r_line.name = r_line[language]
			spell = aftercast_cost(r_line)
			spell.target = temp_mob_arr
			local s_type = command_list[command]
			
			if tonumber(splitline[splitline.n]) then
				local inde,id
				if out_arr[unify_prefix[spell.prefix]..' '..spell.english..' nil'] then
					inde = unify_prefix[spell.prefix]..' '..spell.english..' nil'
				else
					inde = mk_out_arr_entry(spell,{target_id=spell.target.id},nil)
				end
				if unify_prefix[spell.prefix] == '/ma' then
					id = spell.index
				else
					id = spell.id
				end
				out_arr[inde].proposed_packet = assemble_action_packet(spell.target.id,spell.target.index,outgoing_action_category_table[unify_prefix[spell.prefix]],id)
				equip_sets('precast',spell,{type=s_type},inde)
				return ''
			else
				return equip_sets('pretarget',spell,{type=s_type})
			end
		end
	end
	return modified
end)



-----------------------------------------------------------------------------------
--Name: inc_action(act)
--Desc: Calls midcast or aftercast functions as appropriate in response to incoming
--      action packets.
--Args:
---- act - Action packet array (described on the dev wiki)
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function inc_action(act)
	if debugging >= 1 then windower.debug('action') end
	if gearswap_disabled or act.category == 1 then return end
	
	local temp_player = windower.ffxi.get_player()
	local temp_player_mob_table = windower.ffxi.get_mob_by_index(temp_player.index)
	local player_id = temp_player.id
	-- Update player info for aftercast costs.
	player.tp = temp_player.vitals.tp
	player.mp = temp_player.vitals.mp
	player.mpp = temp_player.vitals.mpp
	
	local temp_pet,pet_id
	if temp_player_mob_table.pet_index then
		temp_pet = windower.ffxi.get_mob_by_index(temp_player_mob_table.pet_index)
		if temp_pet then
			pet_id = temp_pet.id
		end
	end

	if act.actor_id ~= player_id and act.actor_id ~= pet_id then
		return -- If the action is not being used by the player, the pet, or is a melee attack then abort processing.
	end
	
	local prefix = ''
	
	if act.actor_id == pet_id then 
		prefix = 'pet_'
	end
	
	spell = get_spell(act)
	local category = act.category
	if logging then	
		if spell then logit(logfile,'\n\n'..tostring(os.clock)..'(178) Event Action: '..tostring(spell.english)..' '..tostring(act['category']))
		else logit(logfile,'\n\nNil spell detected') end
	end
	
	local inde
	if spell and spell.english then
		inde = unify_prefix[spell.prefix]..' '..spell.english
		spell.target = target_complete(windower.ffxi.get_mob_by_id(act.targets[1].id))
	elseif spell then
		unknown_out_arr_deletion(prefix,{target_id = act.targets[1].id})
		return
	end
	
	if jas[category] or uses[category] or (readies[category] and act.param == 28787 and not (category == 9 or (category == 7 and prefix == 'pet_'))) then
		-- For some reason avatar Out of Range messages send two packets (Category 4 and Category 7)
		-- Category 4 contains real information, while Category 7 does not.
		-- I do not know if this will affect automatons being interrupted.
		local action_type = get_action_type(category)
		if readies[category] and act.param == 28787 and not (category == 9) then
			act.interrupted = true
			action_type = 'Interruption'
		end
		
		if type(user_env[prefix..'aftercast']) == 'function' then
			equip_sets(prefix..'aftercast',spell,{type=action_type},inde)
		elseif user_env[prefix..'aftercast'] then
			d_out_arr_entry(spell,inde)
			windower.add_to_chat(123,'GearSwap: '..prefix..'aftercast() exists but is not a function')
		else
			d_out_arr_entry(spell,inde)
		end
	elseif readies[category] and act.param ~= 28787 and prefix == '/pet' then
		mk_out_arr_entry(spell,{target_id==spell.target.id},nil)
		if type(user_env[prefix..'midcast']) == 'function' then
			equip_sets(prefix..'midcast',spell,{type=get_action_type(category)},inde)
		elseif user_env[prefix..'midcast'] then
			windower.add_to_chat(123,'GearSwap: '..prefix..'midcast() exists but is not a function')
		end
	end
end



-----------------------------------------------------------------------------------
--Name: inc_action_message(arr)
--Desc: Calls midcast or aftercast functions as appropriate in response to incoming
--      action message packets.
--Args:
---- arr - Action message packet arguments (described on the dev wiki):
  -- actor_id,target_id,param_1,param_2,param_3,actor_index,target_index,message_id)
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function inc_action_message(arr)
	if T{6,20,113,406,605,646}:contains(arr.message_id) then
		-- If your current spell's target is defeated or falls to the ground
		delete_out_arr_by_id(arr.target_id)
	end
	
	local tempplay = windower.ffxi.get_player()
	local prefix = ''
	if arr.actor_id ~= tempplay.id then
		if tempplay.pet_index then
			if arr.actor_id ~= windower.ffxi.get_mob_by_index(tempplay.pet_index).id then
				return
			else
				prefix = 'pet_'
			end
		else
			return
		end
	end
	if unable_to_use:contains(arr.message_id) then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(195) Event Action Message: '..tostring(message_id)..' Interrupt') end
		unknown_out_arr_deletion(prefix,arr)
	end
end


