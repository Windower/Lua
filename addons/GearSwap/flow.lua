-----------------------------------------------------------------------------------
--Name: sender(...)
--Desc: Triggers an outgoing action packet if verify_equip()'s exit conditions are
--      still unmet after a second.
--Args:
---- {...} - space delimited key for out_arr (hopefully)
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function sender(...)
	local inde = table.concat({...},' ')
	if not action_sent then
		if debugging >= 1 or _settings.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Had to force the command to send. Exit conditions went unmet.') end
		packet_send_check(true,inde)
		sent_out_equip = {}
	end
	action_sent = false
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
		local sent = out_arr[inde].data
		windower.packets.inject_outgoing(sent:byte(2)%2*256+sent:byte(1),sent)
	elseif debugging >= 1 or _settings.debug_mode then
		windower.add_to_chat(8,'GearSwap (Debug Mode): Bad index passed to delayed_cast')
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
	_global.verify_equip = false
	_global.force_send = false
	_global.storedtarget = ''
	_global.midaction = false
	_global.cancel_spell = false
end



-----------------------------------------------------------------------------------
--Name: mk_out_arr_entry(sp,arr,original)
--Desc: Makes a new entry in out_arr or updates an old one's "data" field.
--Args:
---- sp - Resources line for the current spell
---- arr - table containing a "target_id" field that is the spell's target_id or nil
---- original - outgoing packet string (or nil in pretarget)
-----------------------------------------------------------------------------------
--Returns:
---- inde - key for out_arr
-----------------------------------------------------------------------------------
function mk_out_arr_entry(sp,arr,original)
	local inde = unify_prefix[spell.prefix]..' '..spell.english
	if out_arr[inde..' '..tostring(arr.target_id)] then
		out_arr[inde..' '..arr.target_id].data = original
		inde = inde..' '..arr.target_id
	elseif out_arr[inde..' nil'] then
		out_arr[inde..' nil'].data = original
		inde = inde..' nil'
	else
		if debugging >= 3 then windower.add_to_chat(8,'GearSwap (Debug Mode): Creating a new out_arr entry: '..tostring(inde)..' '..tostring(arr.target_id)) end
		inde = inde..' '..tostring(arr.target_id)
		out_arr[inde] = {}
		out_arr[inde].data = original
		out_arr[inde].verify_equip = false
		out_arr[inde].cast_delay = 0
		out_arr[inde].force_send = false
	end
	return inde
end



-----------------------------------------------------------------------------------
--Name: d_out_arr_entry(sp,ind)
--Desc: Deletes an entry from out_arr.
--Args:
---- sp - Resources line for the current spell (at the end of aftercast)
---- ind - Proposed index of out_arr
-----------------------------------------------------------------------------------
--Returns:
---- None
-----------------------------------------------------------------------------------
function d_out_arr_entry(sp,ind)
	if ind == true then -- ambiguous case
		local deletion_table = {}
		for i,v in pairs(out_arr) do
			if v.midaction then
				deletion_table[i] = true
			end
		end
		for i,v in pairs(deletion_table) do
			out_arr[i] = nil
		end
	elseif ind == unify_prefix[sp.prefix]..' '..sp.english then
		if out_arr[ind..' '..tostring(sp.target.id)] then
			out_arr[ind..' '..sp.target.id] = nil
		elseif out_arr[ind..' nil'] then
			out_arr[ind..' nil'] = nil
		else
			windower.add_to_chat(123,'GearSwap: Ind identified but not found.')
		end
	else
		windower.add_to_chat(123,'GearSwap: Missing ind was passed.')
	end
	return inde
end


-----------------------------------------------------------------------------------
--Name: out_action(arr,original)
--Desc: Determines the current spell from a given outgoing action packet.
--      Also infers whether or not it will be interrupted, which will be removed.
--Args:
---- arr - table containing outgoing action packet fields
---- original - outgoing packet string
-----------------------------------------------------------------------------------
--Returns:
---- true (to block) or the outgoing packet
-----------------------------------------------------------------------------------
function out_action(arr,original)
	spell = nil
	local int_flag, acttype
	if arr.category == 3 then -- 3 = Magic
		acttype = 'Magic'
		spell = r_spells[arr.param]
		if buffactive.silence or buffactive.mute then int_flag = true end
	elseif arr.category == 7 or category == 25 then -- 7 = WS, 25 = Monster skill
		acttype = "Weapon Skill"
		spell = r_abilities[arr.param+768]
		if buffactive.amnesia then int_flag = true end
	elseif arr.category == 9 then -- 9 = Ability
		acttype = "Ability"
		spell = r_abilities[arr.param]
		if buffactive.amnesia then int_flag = true end
	elseif arr.category == 16 then -- 16 = . . . ranged attack
		acttype = "Ranged Attack"
		spell = r_abilities[1]
	end
	if buffactive.terror or buffactive.sleep or buffactive.stun or buffactive.petrification or buffactive.charm then
		int_flag = true
	end
	if logging then
		local actor_name = windower.ffxi.get_mob_by_id(arr.actor_id).name
		local target_name = windower.ffxi.get_mob_by_index(arr.target_index).name
		logit(logfile,'\n\nActor: '..tostring(actor_name)..'  Target: '..tostring(target_name)..'  Category: '..tostring(arr.category)..'  param: '..tostring(spell.name or arr.param))
	end
	
	if spell then
		local inde = mk_out_arr_entry(spell,arr,original)
		spell = aftercast_cost(spell)
		if int_flag then
			spell.interrupted = true
		else
			spell.interrupted = false
		end
		spell.name = spell[language]
		if _settings.debug_mode then windower.add_to_chat(8,"GearSwap (Debug Mode): Attempting to use "..spell.name) end
		
		return equip_sets('precast',spell,{type=acttype},inde)
	end
end


-----------------------------------------------------------------------------------
--Name: out_item(arr,original)
--Desc: Determines the current spell from a given outgoing item use packet.
--Args:
---- arr - table containing outgoing action packet fields
---- original - outgoing packet string
-----------------------------------------------------------------------------------
--Returns:
---- true (to block) or the outgoing packet
-----------------------------------------------------------------------------------
function out_item(arr,original)
	items = windower.ffxi.get_items()
	spell = aftercast_cost(r_items[items.inventory[arr.inventory_index].id])
	if spell then
		local inde = mk_out_arr_entry(spell,arr,original)
		spell.name = spell[language]
		if buffactive.muddle or buffactive.medicine then -- What exactly does medicated status block?
			spell.interrupted = true
		else
			spell.interrupted = false
		end
		if _settings.debug_mode then windower.add_to_chat(8,"GearSwap (Debug Mode): Attempting to use "..item.name) end
		return equip_sets('precast',spell,{type="Item"},inde)
	end
end


-----------------------------------------------------------------------------------
--Name: packet_send_check(val,inde)
--Desc: Determines whether or not to send the current packet.
--      Cancels if _global.cancel_spell is true
--      Sends if val is true (_global.force_send or another)
--      Sends if verify_equip is false
--      Sends if verify_equip is true and sent_out_equip's length is 1
--          If out_arr[inde].cast_delay is not 0, cues delayed_cast with the proper
--          delay instead of sending immediately.
--Args:
---- inde - key of out_arr
-----------------------------------------------------------------------------------
--Returns:
---- true (to block) or the outgoing packet
-----------------------------------------------------------------------------------
function packet_send_check(val,inde)
	if out_arr[inde] then
		if out_arr[inde].cancel_spell then
			action_sent = true
			out_arr[inde] = nil
			sent_out_equip.ind = nil
		elseif val or not out_arr[inde].verify_equip or ((table.length(sent_out_equip) == 1) and ( tostring(sent_out_equip.ind) ~= 'nil' ) ) then
			action_sent = true
			if out_arr[inde].cast_delay == 0 then
				return out_arr[inde].data
			else
				windower.send_command('@wait '..out_arr[inde].cast_delay..';lua i '.._addon.name..' delayed_cast '..inde)
			end
		end
	end
	return true
end

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
	if spell then
		inde = unify_prefix[spell.prefix]..' '..spell.english
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
			_global.midaction = false
			spelltarget = nil
			windower.add_to_chat(123,'GearSwap: '..prefix..'aftercast() exists but is not a function')
		else
			_global.midaction = false
			spelltarget = nil
		end
	elseif readies[category] and act.param ~= 28787 then
		if type(user_env[prefix..'midcast']) == 'function' then
			equip_sets(prefix..'midcast',spell,{type=get_action_type(category)},inde)
		elseif user_env[prefix..'midcast'] then
			windower.add_to_chat(123,'GearSwap: '..prefix..'midcast() exists but is not a function')
		end
	end
end

function inc_action_message(arr)
	if spelltarget and T{6,20,113,406,605,646}:contains(arr.message_id) and spelltarget.id == arr.target_id then
		-- If your current spell's target is defeated or falls to the ground
		_global.midaction = false
		spelltarget = nil
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
	
	if arr.message_id == 62 then
		if type(user_env.aftercast) == 'function' then
			local tempitem = r_items[param_1]
			tempitem.interrupted = true
			equip_sets('aftercast',tempitem,{type='Interruption'},true)
		elseif user_env.aftercast then
			_global.midaction = false
			spelltarget = nil
			windower.add_to_chat(123,'GearSwap: aftercast() exists but is not a function')
		else
			_global.midaction = false
			spelltarget = nil
		end
	elseif unable_to_use:contains(arr.message_id) then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(195) Event Action Message: '..tostring(message_id)..' Interrupt') end
		if type(user_env[prefix..'aftercast']) == 'function' then
			if persistent_spell then persistent_spell.interrupted = true
			else persistent_spell = {name="Unknown Interrupt"} end
			equip_sets(prefix..'aftercast',persistent_spell,{type='Interruption'},true)
		elseif user_env[prefix..'aftercast'] then
			_global.midaction = false
			spelltarget = nil
			windower.add_to_chat(123,'GearSwap: '..prefix..'aftercast() exists but is not a function')
		else
			_global.midaction = false
			spelltarget = nil
		end
	end
end

function command_send_check(targ,inde)
	if out_arr[inde] then
		if out_arr[inde].cancel_spell then
			if debugging>=2 then windower.add_to_chat(5,'Spell canceled.') end
			storedcommand = nil
			return ''
		else
	--		print('arg1: '..tostring(val and storedcommand)..'  arg2: '..tostring(storedcommand)..' '..tostring(table.length(sent_out_equip))..'  arg3: '..tostring(storedcommand and not _global.verify_equip))
			if targ and storedcommand then
				local assemblecommand = storedcommand..targ
				storedcommand = nil
				out_arr[inde].spell = spell
				if logging then logit(logfile,'Command Sent: '..assemblecommand..'\n') end
				return assemblecommand
			elseif _settings.debug_mode then
				windower.add_to_chat(8,'GearSwap (Debug Mode): Spell was not sent because there was no stored command ('..tostring(stored_command)') or target ('..tostring(targ)..')')
				return ''
			end
		end
	elseif debugging>=1 then
		windower.add_to_chat(8,'GearSwap: Command send check error - inde is invalid: '..tostring(inde))
	end
end