file = require 'filehelper'
require 'sets'
require 'stringhelper'
require 'helper_functions'

require 'resources'
require 'equip_processing'
require 'targets'
require 'refresh'

_addon = {}
_addon.name = 'GearSwap'
_addon.version = '0.5'
_addon.commands = {'gs','gearswap'}

function event_load()
	debugging = 1
	
	
	if dir_exists('../addons/GearSwap/data/logs') then
		logging = true
		logfile = io.open('../addons/GearSwap/data/logs/NormalLog'..tostring(os.clock())..'.log','w+')
		logit(logfile,'GearSwap LOGGER HEADER\n')
	end
	
	send_command('@alias gs lua c gearswap')
	refresh_globals()
	_global.force_send = false
	language = world.language:lower()
	
	if world.logged_in then
		user_env = load_user_files()
		if not user_env then
			gearswap_disabled = true
			sets = nil
		else
			gearswap_disabled = false
			sets = user_env.get_sets()
		end
		if debugging >= 1 then send_command('@unload spellcast;') end
	end
end

function event_unload()
	if logging then	logfile:close() end
	send_command('@unalias gs')
end

function event_addon_command(...)
	local command = table.concat({...},' ')
	if logging then	logit(logfile,'\n\n'..tostring(os.clock)..command) end
	local splitup = split(command,' ')
	if splitup[1]:lower() == 'c' and #splitup > 1 then
		if gearswap_disabled then return end
		equip_sets('self_command',_raw.table.concat(splitup,' ',2,#splitup))
	elseif splitup[1]:lower() == 'equip' and not midaction then
		if gearswap_disabled then return end
		equip_sets('equip_command',user_env.sets[_raw.table.concat(splitup,' ',2,#splitup)])
	elseif splitup[1]:lower() == 'reload' then
		refresh_user_env()
	elseif strip(splitup[1]) == 'debugmode' then
		_global.debug_mode = not _global.debug_mode
		write('Debug Mode set to '..tostring(_global.debug_mode)..'.')
	elseif strip(splitup[1]) == 'showswaps' then
		_global.show_swaps = not _global.show_swaps
		write('Show Swaps set to '..tostring(_global.show_swaps)..'.')
	else
		write('command not found')
	end
end

function midact()
	if not action_sent then
		if debugging >= 1 then add_to_chat(1,'Had for force the command to send.') end
		send_check(true)
	end
	action_sent = false
end

function event_outgoing_text(original,modified)
	if gearswap_disabled then return modified end
	local splitline = split(modified,' ')
	local command = splitline[1]
	
	local a,b,abil = string.find(original,'"(.-)"')
	local temptarg = valid_target(splitline[#splitline])
	
	if command == '/raw' then
		return _raw.table.concat(splitline,' ',2,#splitline)
	elseif command_list[command] and temptarg and validabils[abil:lower()] and not midaction then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(93) Original: '..original) end
		refresh_globals()
			
		midaction = true
		send_command('@wait 1;lua invoke gearswap midact')
		
		local r_line, s_type
			
		if command_list[command] == 'Magic' then
			r_line = r_spells[validabils[abil:lower()]['Magic']]
			r_line.name = r_line['english']
			s_type = command_list[r_spells[validabils[abil:lower()]['Magic']]['prefix']]
		elseif command_list[command] == 'Ability' then
			r_line = r_abilities[validabils[abil:lower()]['Ability']]
			r_line.name = r_line['english']
			s_type = command_list[r_abilities[validabils[abil:lower()]['Ability']]['prefix']]
		elseif debugging then
			write('this case should never be hit '..command)
		end
		
		_global.storedtarget = temptarg
		
		r_line = aftercast_cost(r_line)
			
		storedcommand = r_line['prefix']..' "'..r_line['english']..'" '
		equip_sets('precast',r_line,{type=s_type})

		return '' -- Makes an infinite loop with Spellcast. They fight to the death.
	elseif midaction and validabils[tostring(abil):lower()] then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(122) Canceled: '..original) end
		return ''
	end
	return modified
end

function event_incoming_text(original,modified,mode)
	if gearswap_disabled then return modified, color end
	if original == '...A command error occurred.' or original == 'You can only use that command during battle.' or original == 'You cannot use that command here.' then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(130) Client canceled command detected: '..mode..' '..original) end
		equip_sets('aftercast',{name='Invalid Spell'},{type='Recast'})
	end
	return modified,color
end

function event_incoming_chunk(id,data)
	if gearswap_disabled then return end
	cur_ID = data:byte(3,4)
	if prev_ID == nil then
		prev_ID = cur_ID
	end
	persistant_sequence[data:byte(3,4)] = true  ---------------------- TEMPORARY TO INVESTIGATE LAG ISSUES IN DELVE
	if data:byte(3,4) ~= 0x00 then
		if not persistant_sequence[data:byte(3,4)-1] then
			if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(140) Packet dropped or out of order: '..cur_ID..' '..prev_ID) end
		end
	end
	prev_ID = cur_ID
	if prev_ID == 0xFF then
		table.reassign(persistant_sequence,{})
	end

	if id == 0x050 then
		if sent_out_equip[data:byte(6)] == data:byte(5) then
			sent_out_equip[data:byte(6)] = nil
			send_check()
		end
	end
end

function event_zone_change(from_id, from, to_id, to)
	prev_ID = 0
end

function event_outgoing_chunk(id,data)
	if id == 0x015 then
		lastbyte = data:byte(7,8)
	end
end

function event_action(act)
	if gearswap_disabled then return end
	refresh_player()
	local prefix = ''
	
	if pet['id']==act['actor_id'] then 
		prefix = 'pet_'
	end
	
	if (player['id'] ~= act['actor_id'] and pet['id']~=act['actor_id']) or act['category'] == 1 then
		return -- If the action is not being used by the player, the pet, or is a melee attack then abort processing.
	end
	
	local spell = get_spell(act)
	local category = act['category']
	
	if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(178) Event Action: '..tostring(spell.english)..' '..tostring(act['category'])) end
	
	if jas[category] then
		equip_sets(prefix..'aftercast',spell,{type=get_action_type(category)})
	elseif readies[category] then
		if act['param'] == 28787 then ----------- NEED TO ADD BETTER HANDLING FOR THIS -----------------------------
			equip_sets(prefix..'aftercast',spell,{type='Failure'})
		else
			equip_sets(prefix..'midcast',spell,{type=get_action_type(category)})
		end
	elseif uses[category] then
		equip_sets(prefix..'aftercast',spell,{type=get_action_type(category)})
	end
end

function event_action_message(actor_id,target_id,actor_index,target_index,message_id,param_1,param_2,param_3)
	if gearswap_disabled then return end
	if unable_to_use:contains(message_id) then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(195) Event Action Message: '..tostring(message_id)..' Interrupt') end
		equip_sets('aftercast',{name='Interrupt'},{type='Recast'})
	end
end

function event_status_change(old,new)
	if gearswap_disabled or old == 'Event' then return end
	equip_sets('status_change',new,{type='Status Change',old=old})
end

function event_gain_status(id,name)
	if gearswap_disabled then return end
	equip_sets('buff_change',name,{type='gain'})
end

function event_lose_status(id,name)
	if gearswap_disabled then return end
	equip_sets('buff_change',name,{type='loss'})
end

function event_job_change(mjob_id, mjob, mjob_lvl, sjob_id, sjob, sjob_lvl)
	refresh_user_env()
end

function event_login(name)
	send_command('@wait 2;lua i gearswap refresh_user_env;')
end

function event_day_change(day)
	send_command('@wait 0.5;lua invoke gearswap refresh_ffxi_info')
end

function event_weather_change(weather)
	refresh_ffxi_info()
end



-- Non-events --


function debug_mode(boolean)
	if boolean then _global.debug_mode = boolean
	else
		_global.debug_mode = true
	end
end


function show_swaps(boolean)
	if boolean then _global.show_swaps = boolean
	else
		_global.show_swaps = true
	end
end


function verify_equip(boolean)
	if boolean then _global.verify_equip = boolean
	else
		_global.verify_equip = true
	end
end


function cancel_spell(boolean)
	if boolean then _global.cancel_spell = boolean
	else
		_global.cancel_spell = true
	end
end

function force_send(boolean)
	if boolean then _global.force_send = boolean
	else
		_global.force_send = true
	end
end

function change_target(name)
	if name then _global.storedtarget = name else
		add_to_chat(123,'Name is nil or false')
	end
end

function cast_delay(delay)
	if tonumber(delay) then
		_global.cast_delay = tonumber(delay)
	else
		add_to_chat(123,'Cast delay is not a number')
	end
end

function get_spell(act)
	local spell, abil_ID, effect_val
	local msg_ID = act['targets'][1]['actions'][1]['message']
	
	if T{7,8,9}:contains(act['category']) then
		abil_ID = act['targets'][1]['actions'][1]['param']
	elseif T{3,4,5,6,11,13,14,15}:contains(act['category']) then
		abil_ID = act['param']
		effect_val = act['targets'][1]['actions'][1]['param']
	end
	
	if act['category'] == 2 then
		spell.english = 'Ranged Attack'
	else
	
		if not dialog[msg_ID] then
			if T{4,8}:contains(act['category']) then
				spell = r_spells[abil_ID]
			elseif T{3,6,7,13,14,15}:contains(act['category']) then
				spell = r_abilities[abil_ID] -- May have to correct for charmed pets some day, but I'm not sure there are any monsters with TP moves that give no message.
			elseif T{}:contains(act['category']) then
				spell = r_items[abil_ID]
			else
				spell = {none=tostring(msg_ID)} -- Debugging
			end
			return spell
		end
		
		
		local fields = fieldsearch(dialog[msg_ID]['english'])
		
		if table.contains(fields,'spell') then
			spell = r_spells[abil_ID]
		elseif table.contains(fields,'ability') then
			spell = r_abilities[abil_ID]
		elseif table.contains(fields,'weapon_skill') then
			if abil_ID > 255 then -- WZ_RECOVER_ALL is used by chests in Limbus
				spell = r_mabils[abil_ID-256]
				if spell.english == '.' then
					spell.english = 'Special Attack'
				end
			elseif abil_ID < 256 then
				spell = r_abilities[abil_ID+768]
			end
		elseif msg_ID == 303 then
			spell = r_abilities[74] -- Divine Seal
		elseif msg_ID == 304 then
			spell = r_abilities[75] -- 'Elemental Seal'
		elseif msg_ID == 305 then
			spell = r_abilities[76] -- 'Trick Attack'
		elseif msg_ID == 311 or msg_ID == 311 then
			spell = r_abilities[79] -- 'Cover'
		elseif msg_ID == 240 or msg_ID == 241 then
			spell = r_abilities[43] -- 'Hide'
		end
		
		
		if table.contains(fields,'item') then
			spell = r_items[abil_ID]
		else
			spell = aftercast_cost(spell)
		end
	end
	
	spell.name = spell['english']
	return spell
end

function aftercast_cost(rline)
	if rline == nil then
		return {tpaftercast = player['tp'],mpaftercast = tonumber(player['mp']),mppaftercast = tonumber(player['mpp'])}
	end
	if tonumber(rline['tpcost']) == -1 or not rline['tpcost'] then rline['tpaftercast'] = player['tp'] else
	rline['tpaftercast'] = player['tp'] - tonumber(rline['tpcost']) end
	
	if tonumber(rline['mpcost']) == 0 then
		rline['mpaftercast'] = tonumber(player['mp'])
		rline['mppaftercast'] = tonumber(player['mpp'])
	else
		rline['mpaftercast'] = player['mp'] - tonumber(rline['mpcost'])
		rline['mppaftercast'] = (player['mp'] - tonumber(rline['mpcost']))/player['max_mp']
	end
	
	return rline
end

function get_action_type(category)
	local action_type
	if category == 3 and not midaction then -- Try to filter for Job Abilities that come back as WSs.
		action_type = 'Job Ability'
	else
		action_type = category_map[category]
	end
	return action_type
end