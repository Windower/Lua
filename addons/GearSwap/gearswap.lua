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

_addon.name = 'GearSwap'
_addon.version = '0.800'
_addon.author = 'Byrth'
_addon.commands = {'gs','gearswap'}

if windower.file_exists(windower.addon_path..'data/bootstrap.lua') then
	debugging = 1
else
	debugging = 0
end

language = 'english'
file = require 'files'
require 'strings'
require 'helper_functions'
require 'tables'

require 'statics'
require 'equip_processing'
require 'targets'
require 'user_functions'
require 'refresh'
require 'parse_augments'
require 'export'
require 'validate'
require 'sets'
res = require 'resources'

windower.register_event('load',function()
	if debugging >= 1 then windower.debug('load') end
	if windower.dir_exists('../addons/GearSwap/data/logs') then
		logging = false
		logfile = io.open('../addons/GearSwap/data/logs/NormalLog'..tostring(os.clock())..'.log','w+')
		logit(logfile,'GearSwap LOGGER HEADER\n')
	end
	
	refresh_globals()
	_global.force_send = false
	
	if world.logged_in then
		refresh_user_env()
		if debugging >= 1 then windower.send_command('@unload spellcast;') end
	end
end)

windower.register_event('unload',function ()
	if debugging >= 1 then windower.debug('unload') end
	if user_env then
		if type(user_env.file_unload)=='function' then user_env.file_unload()
		elseif user_env.file_unload then
			windower.add_to_chat(123,'GearSwap: file_unload() is not a function')
		end
	end
	if logging then	logfile:close() end
end)

windower.register_event('addon command',function (...)
	if debugging >= 1 then windower.debug('addon command') end
	local command = table.concat({...},' ')
	if logging then	logit(logfile,'\n\n'..tostring(os.clock)..command) end
	local splitup = command:split(' ')
	if splitup[1]:lower() == 'c' then
		if gearSwap_disabled then return end
		if splitup[2] then equip_sets('self_command',_raw.table.concat(splitup,' ',2,#splitup))
		else
			windower.add_to_chat(123,'GearSwap: No self command passed.')
		end
	elseif splitup[1]:lower() == 'equip' then
		if gearSwap_disabled then return end
		local set_split = split(_raw.table.concat(splitup,' ',2,#splitup):gsub('%[','%.'):gsub('[%]\']',''),'%.')
		local n = 1
		local tempset
		if set_split[1] == 'sets' then tempset = user_env
		else tempset = user_env.sets end
		while n <= #set_split do
			if tempset[set_split[n]] or tempset[tonumber(set_split[n])] then
				tempset = tempset[set_split[n]] or tempset[tonumber(set_split[n])]
				if n == #set_split then
					equip_sets('equip_command',tempset)
					break
				else
					n = n+1
				end
			else
				windower.add_to_chat(123,'GearSwap: Equip command cannot be completed. That set does not exist.')
				break
			end
		end
	elseif splitup[1]:lower() == 'export' then
		table.remove(splitup,1)
		export_set(splitup)
	elseif splitup[1]:lower() == 'validate' then
		validate()
	elseif splitup[1]:lower() == 'enable' then
		if splitup[2] and splitup[2]:lower()=='all' then
			enable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
			print('GearSwap: All slots enabled.')
		elseif splitup[2] then
			for i=2,splitup.n do
				if slot_map[splitup[i]:gsub('[^%a]',''):lower()] then
					enable(splitup[i])
					print('GearSwap: '..splitup[i]..' slot enabled.')
				else
					print('GearSwap: Unable to find slot '..tostring(splitup[i])..'.')
				end
			end
		elseif gearSwap_disabled then
			gearSwap_disabled = false
			print('GearSwap: User file enabled')
		end
	elseif splitup[1]:lower() == 'disable' then
		if splitup[2] and splitup[2]:lower()=='all' then
			disable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
			print('GearSwap: All slots disabled.')
		elseif splitup[2]  then
			for i=2,splitup.n do
				if slot_map[splitup[i]:gsub('[^%a]',''):lower()] then
					disable(splitup[i])
					print('GearSwap: '..splitup[i]..' slot disabled.')
				else
					print('GearSwap: Unable to find slot '..tostring(splitup[i])..'.')
				end
			end
		elseif not gearSwap_disabled and not splitup[2] then
			print('GearSwap: User file disabled')
			gearSwap_disabled = true
		end
	elseif splitup[1]:lower() == 'reload' then
		refresh_user_env()
	elseif strip(splitup[1]) == 'debugmode' then
		_global.debug_mode = not _global.debug_mode
		print('GearSwap: Debug Mode set to '..tostring(_global.debug_mode)..'.')
	elseif strip(splitup[1]) == 'showswaps' then
		_global.show_swaps = not _global.show_swaps
		print('GearSwap: Show Swaps set to '..tostring(_global.show_swaps)..'.')
	elseif not ((strip(splitup[1]) == 'eval' or strip(splitup[1]) == 'visible' or strip(splitup[1]) == 'invisible') and debugging>0) then
		print('GearSwap: Command not found')
	end
end)

function sender()
	if not action_sent then
		if debugging >= 1 or _global.debug_mode then windower.add_to_chat(8,'GearSwap (Debug Mode): Had to force the command to send. Exit conditions went unmet.') end
		if sent_out_equip.ind then 
			packet_send_check(true,sent_out_equip.ind)
		end
		sent_out_equip = {}
	end
	action_sent = false
end

windower.register_event('outgoing text',function(original,modified)
	if debugging >= 1 then windower.debug('outgoing text') end
	if gearSwap_disabled then return modified end
	
	local temp_mod = windower.convert_auto_trans(modified)
	local splitline = temp_mod:split(' ')
	local command = splitline[1]

	local a,b,abil = string.find(temp_mod,'"(.-)"')
	if abil then
		abil = abil:lower()
	elseif splitline.n == 3 then
		abil = splitline[2]:lower()
	end
	
	local temptarg = valid_target(splitline[splitline.n])
		
	if command_list[command] and temptarg and validabils[language][unify_prefix[command]][abil] then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(93) temp_mod: '..temp_mod) end
		
		local r_line, s_type
			
		if command_list[command] == 'Magic' then
			r_line = r_spells[validabils[language][unify_prefix[command]][abil:lower()]]
			r_line.name = r_line[language]
			if r_line.type == 'BardSong' and r_line.casttime == 8 then
				refresh_buff_active(windower.ffxi.get_player().buffs)
				if buffactive.pianissimo then
				-- Handling for the casting time reduction of Pianissimo.
				-- Note, does not work unless the buff list has been updated.
					r_line.casttime=4
				end
			elseif buffactive.hasso or buffactive.seigan then
				r_line.recast=r_line.recast*1.5
				r_line.casttime = r_line.casttime*1.5
			end
			s_type = 'Magic'
		elseif command_list[command] == 'Ability' then
			r_line = r_abilities[validabils[language][unify_prefix[command]][abil:lower()]]
			r_line.name = r_line[language]
			if r_line.type == 'SummonerPact' and buffactive['astral conduit'] then
				r_line.recast=0
			end
			s_type = 'Ability'
		elseif command_list[command] == 'Item' then
			r_line = r_items[validabils[language][unify_prefix[command]][abil:lower()]]
			r_line.name = r_line[language]
			r_line.prefix = '/item'
			r_line.type = 'Item'
			s_type = 'Item'
		elseif debugging and debugging >= 1 then
			print('this case should never be hit '..command)
		end
		
		_global.storedtarget = temptarg
		
		spell = aftercast_cost(r_line)
		
		storedcommand = command..' "'..spell[language]..'" '
		return equip_sets('pretarget',spell,{type=s_type})
	elseif command_list[command] == 'Ranged Attack' and temptarg then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(93) temp_mod: '..temp_mod) end

		rline = r_abilities[1]
		_global.storedtarget = temptarg
		spell = aftercast_cost(rline)
		
		storedcommand = spell.prefix..' '
		return equip_sets('pretarget',spell,{type="Ranged Attack"})
	end
	return modified
end)

--[[windower.register_event('incoming text',function(original,modified,color,modifiedcolor)
	if debugging >= 1 then windower.debug('incoming text') end
	if gearSwap_disabled then return modified, color end
	if string.find(original,'...A command error occurred.') or original == 'You can only use that command during battle.' or original == 'You cannot use that command here.' then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(130) Client canceled command detected: '..color..' '..original) end
		if type(user_env.aftercast)=='function' then
			if persistent_spell then persistent_spell.interrupted = true
			else persistent_spell = {name="Unknown Interrupt"} end
			equip_sets('aftercast',persistent_spell,{type='Interruption'})
		elseif user_env.aftercast then
			windower.add_to_chat(123,'GearSwap: aftercast() exists but is not a function')
		end
	end
	return modified,modifiedcolor
end)]]

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	if debugging >= 1 then windower.debug('incoming chunk '..id) end

	if id == 0x28 and not injected then
		data = data:sub(5)
		local act = {}
		act.do_not_need = get_bit_packed(data,0,8)
		act.actor_id = get_bit_packed(data,8,40)
		act.target_count = get_bit_packed(data,40,50)
		act.category = get_bit_packed(data,50,54)
		act.param = get_bit_packed(data,54,70)
		act.unknown = get_bit_packed(data,70,86)
		act.recast = get_bit_packed(data,86,118)
		act.targets = {}
		local offset = 118
		for i = 1,act.target_count do
			act.targets[i] = {}
			act.targets[i].id = get_bit_packed(data,offset,offset+32)
			act.targets[i].action_count = get_bit_packed(data,offset+32,offset+36)
			offset = offset + 36
			act.targets[i].actions = {}
			for n = 1,act.targets[i].action_count do
				act.targets[i].actions[n] = {}
				act.targets[i].actions[n].reaction = get_bit_packed(data,offset,offset+5)
				act.targets[i].actions[n].animation = get_bit_packed(data,offset+5,offset+16)
				act.targets[i].actions[n].effect = get_bit_packed(data,offset+16,offset+21)
				act.targets[i].actions[n].stagger = get_bit_packed(data,offset+21,offset+27)
				act.targets[i].actions[n].param = get_bit_packed(data,offset+27,offset+44)
				act.targets[i].actions[n].message = get_bit_packed(data,offset+44,offset+54)
				act.targets[i].actions[n].unknown = get_bit_packed(data,offset+54,offset+85)
				act.targets[i].actions[n].has_add_effect = get_bit_packed(data,offset+85,offset+86)
				offset = offset + 86
				if act.targets[i].actions[n].has_add_effect == 1 then
					act.targets[i].actions[n].has_add_effect = true
					act.targets[i].actions[n].add_effect_animation = get_bit_packed(data,offset,offset+6)
					act.targets[i].actions[n].add_effect_effect = get_bit_packed(data,offset+6,offset+10)
					act.targets[i].actions[n].add_effect_param = get_bit_packed(data,offset+10,offset+27)
					act.targets[i].actions[n].add_effect_message = get_bit_packed(data,offset+27,offset+37)
					offset = offset + 37
				else
					act.targets[i].actions[n].has_add_effect = false
					act.targets[i].actions[n].add_effect_animation = 0
					act.targets[i].actions[n].add_effect_effect = 0
					act.targets[i].actions[n].add_effect_param = 0
					act.targets[i].actions[n].add_effect_message = 0
				end
				act.targets[i].actions[n].has_spike_effect = get_bit_packed(data,offset,offset+1)
				offset = offset +1
				if act.targets[i].actions[n].has_spike_effect == 1 then
					act.targets[i].actions[n].has_spike_effect = true
					act.targets[i].actions[n].spike_effect_animation = get_bit_packed(data,offset,offset+6)
					act.targets[i].actions[n].spike_effect_effect = get_bit_packed(data,offset+6,offset+10)
					act.targets[i].actions[n].spike_effect_param = get_bit_packed(data,offset+10,offset+24)
					act.targets[i].actions[n].spike_effect_message = get_bit_packed(data,offset+24,offset+34)
					offset = offset + 34
				else
					act.targets[i].actions[n].has_spike_effect = false
					act.targets[i].actions[n].spike_effect_animation = 0
					act.targets[i].actions[n].spike_effect_effect = 0
					act.targets[i].actions[n].spike_effect_param = 0
					act.targets[i].actions[n].spike_effect_message = 0
				end
			end
		end
		inc_action(act)
	elseif id == 0x29 and not injected then
		if gearSwap_disabled then return end
		data = data:sub(5)
		local actor_id = get_bit_packed(data,0,32)
		local target_id = get_bit_packed(data,32,64)
		local param_1 = get_bit_packed(data,64,96)
		local param_2 = get_bit_packed(data,96,102) -- First 6 bits
		local param_3 = get_bit_packed(data,102,128) -- Rest
		local actor_index = get_bit_packed(data,128,144)
		local target_index = get_bit_packed(data,144,160)
		local message_id = get_bit_packed(data,160,175) -- Cut off the most significant bit, hopefully
		
		action_message(actor_id,target_id,param_1,param_2,param_3,actor_index,target_index,message_id)
	elseif id == 0x01B and not injected then
--		'Job Info Packet'
		local enc = data:byte(97) + data:byte(98)*256
		items = windower.ffxi.get_items()
		local tab = {}
		for i,v in pairs(default_slot_map) do
			local tf = (math.floor( (enc%(2^(i+1))) / 2^i ) == 1) -- Extract the single bit as a boolean
			if encumbrance_table[i] and not tf and not_sent_out_equip[v] and not disable_table[i] then
				tab[v] = not_sent_out_equip[v]
				not_sent_out_equip[v] = nil
				if _global.debug_mode then windower.add_to_chat(8,"GearSwap (Debug Mode): Your "..v..' are now unlocked.') end
			end
			encumbrance_table[i] = tf
		end
		if table.length(tab) > 0 then
			equip_sets('equip_command',tab)
		end
	elseif id == 0x29 and not injected then
		if gearSwap_disabled then return end
		data = data:sub(5)
		local actor_id = get_bit_packed(data,0,32)
		local target_id = get_bit_packed(data,32,64)
		local param_1 = get_bit_packed(data,64,96)
		local param_2 = get_bit_packed(data,96,102) -- First 6 bits
		local param_3 = get_bit_packed(data,102,128) -- Rest
		local actor_index = get_bit_packed(data,128,144)
		local target_index = get_bit_packed(data,144,160)
		local message_id = get_bit_packed(data,160,175) -- Cut off the most significant bit, hopefully
		
		action_message(actor_id,target_id,param_1,param_2,param_3,actor_index,target_index,message_id)
	elseif gearSwap_disabled then
		return
	elseif id == 0x050 and not injected then
--		'Equipment packet'
		if sent_out_equip[data:byte(6)] == data:byte(5) then
			sent_out_equip[data:byte(6)] = nil
			if table.length(sent_out_equip) == 1 and sent_out_equip.ind then
				local out = packet_send_check(true,sent_out_equip.ind)
				sent_out_equip.ind = nil
				if type(out) == 'string' then
					windower.packets.inject_outgoing((out:byte(2)%2)*256+out:byte(1),out)
				end
			end
		end
	end
end)

windower.register_event('outgoing chunk',function(id,data,modified,injected,blocked)
	if debugging >= 1 then windower.debug('outgoing chunk '..id) end
	if (id == 0x1A or id == 0x36 or id == 0x37) and not injected then
		local ind,arr = #out_arr +1,{}
		out_arr[ind] = {}
		out_arr[ind].data = data
		out_arr[ind].cast_delay = 0
		out_arr[ind].verify_equip = false
		data = data:sub(5)
		if id == 0x01A then -- Action packet
			arr.actor_id = get_bit_packed(data,0,32)
			arr.target_index = get_bit_packed(data,32,48)
			arr.category = get_bit_packed(data,48,64)
			arr.param = get_bit_packed(data,64,80)
			arr.unknown1 = get_bit_packed(data,80,96)
			return out_action(arr,ind)
		elseif id == 0x036 then
	--		'Menu Item Packet'
			arr.target_id = get_bit_packed(data,0,32)
			arr.inventory_index = get_bit_packed(data,352,360)
			arr.target_index = get_bit_packed(data,432,448)
			return out_item(arr,ind)
		elseif id == 0x037 then
	--		'Use Item Packet'
			arr.target_id = get_bit_packed(data,0,32)
			arr.target_index = get_bit_packed(data,64,80)
			arr.inventory_index = get_bit_packed(data,80,88)
			return out_item(arr,ind)
		end
	end
end)

function out_action(arr,ind)
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
		spell = aftercast_cost(spell)
		if int_flag then
			spell.interrupted = true
		else
			spell.interrupted = false
		end
		spell.name = spell[language]
		if _global.debug_mode then windower.add_to_chat(8,"GearSwap (Debug Mode): Attempting to use "..spell.name) end
		
		local temp_val = equip_sets('precast',spell,{type=acttype},ind)
		_global.midaction = true
		return temp_val
--[[	elseif abil and user_env and not T{0,2,4,5,11,12,13,14,15,18,20}:contains(arr.category) then -- 0 = interacting with an NPC, 2 = engaging, 4 = disengaging from menu, 5 = CFH, 11 = Homepointing, 12= assist, 13 = getting up from reraise, 14 = fishing, 15 = changing target, 18 = dismounting chocobo, 20 = zoning
		if not T{3,7,9,16,25}:contains(arr.category) then windower.add_to_chat(8,'Tell Byrth how you triggered this and this number: '..arr.category) end
		if type(user_env.aftercast) == 'function' and abil.name == 'Unknown Interruption' then
			windower.add_to_chat(8,'Interrupted! Category: '..arr.category)
			equip_sets('aftercast',abil,{type='Interruption'})
		elseif user_env.aftercast then
			_global.midaction = false
			spelltarget = nil
			windower.add_to_chat(123,'GearSwap: aftercast() exists but is not a function')
		else
			_global.midaction = false
			spelltarget = nil
		end]]
	end
end

function out_item(arr,ind)
	items = windower.ffxi.get_items()
	spell = aftercast_cost(r_items[items.inventory[arr.inventory_index].id])
	if spell then
		spell.name = spell[language]
		if buffactive.muddle or buffactive.medicine then -- What exactly does medicated status block?
			spell.interrupted = true
		else
			spell.interrupted = false
		end
	end
	if _global.debug_mode then windower.add_to_chat(8,"GearSwap (Debug Mode): Attempting to use "..item.name) end
--	windower.add_to_chat(8,spell.english..' '..windower.ffxi.get_mob_by_index(arr.target_index).name)
	return equip_sets('precast',spell,{type="Item"},ind)
end

function inc_action(act)
	if debugging >= 1 then windower.debug('action') end
	if gearSwap_disabled or act.category == 1 then return end
	
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
			equip_sets(prefix..'aftercast',spell,{type=action_type})
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
			equip_sets(prefix..'midcast',spell,{type=get_action_type(category)})
		elseif user_env[prefix..'midcast'] then
			windower.add_to_chat(123,'GearSwap: '..prefix..'midcast() exists but is not a function')
		end
	end
end

function action_message(actor_id,target_id,param_1,param_2,param_3,actor_index,target_index,message_id)
	if spelltarget and T{6,20,113,406,605,646}:contains(message_id) and spelltarget.id == target_id then
		-- If your current spell's target is defeated or falls to the ground
		_global.midaction = false
		spelltarget = nil
	end
	
	local tempplay = windower.ffxi.get_player()
	local prefix = ''
	if actor_id ~= tempplay.id then
		if tempplay.pet_index then
			if actor_id ~= windower.ffxi.get_mob_by_index(tempplay.pet_index).id then
				return
			else
				prefix = 'pet_'
			end
		else
			return
		end
	end
	
	if message_id == 62 then
		if type(user_env.aftercast) == 'function' then
			local tempitem = r_items[param_1]
			tempitem.interrupted = true
			equip_sets('aftercast',tempitem,{type='Interruption'})
		elseif user_env.aftercast then
			_global.midaction = false
			spelltarget = nil
			windower.add_to_chat(123,'GearSwap: aftercast() exists but is not a function')
		else
			_global.midaction = false
			spelltarget = nil
		end
	elseif unable_to_use:contains(message_id) then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(195) Event Action Message: '..tostring(message_id)..' Interrupt') end
		if type(user_env[prefix..'aftercast']) == 'function' then
			if persistent_spell then persistent_spell.interrupted = true
			else persistent_spell = {name="Unknown Interrupt"} end
			equip_sets(prefix..'aftercast',persistent_spell,{type='Interruption'})
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

windower.register_event('status change',function(new,old)
	if debugging >= 1 then windower.debug('status change '..new) end
	if gearSwap_disabled or T{2,3,4}:contains(old) or T{2,3,4}:contains(new) then return end
	equip_sets('status_change',res.statuses[new].english,res.statuses[old].english)
end)

windower.register_event('gain buff',function(name,id)
	if debugging >= 1 then windower.debug('gain buff '..name) end
	if gearSwap_disabled then return end
	if _global.midaction and T{'terror','sleep','stun','petrification','charm','weakness'}:contains(name:lower()) then _global.midaction = false end
	equip_sets('buff_change',name,'gain')
end)

windower.register_event('lose buff',function(name,id)
	if debugging >= 1 then windower.debug('lose buff '..name) end
	if gearSwap_disabled then return end
	equip_sets('buff_change',name,'loss')
end)

windower.register_event('job change',function(mjob, mjob_id, mjob_lvl, sjob, sjob_id, sjob_lvl)
	if debugging >= 1 then windower.debug('job change') end
	if mjob ~= current_job_file then
		refresh_user_env()
	end
end)

windower.register_event('login',function(name)
	if debugging >= 1 then windower.debug('login '..name) end
	windower.send_command('@wait 2;lua i gearSwap refresh_user_env;')
end)

windower.register_event('day change',function(new,old)
	if debugging >= 1 then windower.debug('day change') end
	windower.send_command('@wait 0.5;lua invoke gearSwap refresh_ffxi_info')
end)

windower.register_event('weather change',function(new_weather, new_weather_id, old_weather, old_weather_id)
	if debugging >= 1 then windower.debug('weather change') end
	refresh_ffxi_info()
end)

windower.register_event('zone change',function(new_zone,new_zone_id,old_zone,old_zone_id)
	if debugging >= 1 then windower.debug('zone change') end
	_global.midaction = false
	sent_out_equip = {}
	not_sent_out_equip = {}
end)

function get_spell(act)
	local spell, abil_ID, effect_val = {}
	local msg_ID = act.targets[1].actions[1].message
	
	if T{7,8,9}:contains(act.category) then
		abil_ID = act.targets[1].actions[1].param
	elseif T{3,4,5,6,11,13,14,15}:contains(act.category) then
		abil_ID = act.param
		effect_val = act.targets[1].actions[1].param
	end
	
	if act.category == 12 or act.category == 2 then
		spell = r_abilities[1]
	else
		if not dialog[msg_ID] then
			if T{4,8}:contains(act.category) then
				spell = r_spells[abil_ID]
				if act.category == 4 and spell then spell.recast = act.recast end
			elseif T{3,6,7,13,14,15}:contains(act.category) then
				spell = r_abilities[abil_ID] -- May have to correct for charmed pets some day, but I'm not sure there are any monsters with TP moves that give no message.
			elseif T{5,9}:contains(act['category']) then
				spell = r_items[abil_ID]
			else
				spell = {name=tostring(msg_ID)} -- Debugging
			end
			return spell
		end
		
		
		local fields = fieldsearch(dialog[msg_ID][language])

		if table.contains(fields,'spell') then
			spell = r_spells[abil_ID]
			if act.category == 4 then spell.recast = act.recast end
		elseif table.contains(fields,'ability') then
			spell = r_abilities[abil_ID]
		elseif table.contains(fields,'weapon_skill') then
--			if abil_ID > 255 then -- WZ_RECOVER_ALL is used by chests in Limbus
--				spell = r_mabils[abil_ID-256]
--				if spell.english == '.' then
--					spell.english = 'Special Attack'
--				end
--			elseif abil_ID < 256 then
				spell = r_abilities[abil_ID+768]
--			end
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
		elseif msg_ID == 328 then
			spell = r_abilities[effect_val] -- BPs that are out of range
		end
		
		
		if table.contains(fields,'item') then
			spell = r_items[abil_ID]
		else
			spell = aftercast_cost(spell)
		end
	end
	
	if spell.type == 'BardSong' and spell.casttime == 8 and buffactive.pianissimo then -- Handling for the casting time reduction of Pianissimo
		spell.casttime=4
	end
	
	spell.name = spell[language]
	spell.interrupted = false
	return spell
end

function aftercast_cost(rline)
	if rline == nil then
		return {tpaftercast = player.tp, mpaftercast = player.mp, mppaftercast = player.mpp}
	end
	if not rline.mpcost then rline.mpcost = 0 end
	if not rline.tpcost then rline.tpcost = 0 end
	
	if rline.tpcost == 0 then rline.tpaftercast = player.tp else
	rline.tpaftercast = player.tp - rline.tpcost end
	
	if rline.mpcost == 0 then
		rline.mpaftercast = player.mp
		rline.mppaftercast = player.mpp
	else
		rline.mpaftercast = player.mp - rline.mpcost
		rline.mppaftercast = (player.mp - rline.mpcost)/player.max_mp
	end
	
	return rline
end

function get_action_type(category)
	local action_type
	if category == 3 and not _global.midaction then -- Try to filter for Job Abilities that come back as WSs.
		action_type = 'Job Ability'
	else
		action_type = category_map[category]
	end
	return action_type
end

if debugging and debugging >= 1 then
	require('data/bootstrap')

	windower.register_event('addon command', function(...)
		local pantsu = {...}
		local opt = table.remove(pantsu,1)
		if opt == 'eval' then
			assert(loadstring(table.concat(pantsu,' ')))()
		elseif opt == 'visible' then
			windower.text.set_visibility('precast',true)
			windower.text.set_visibility('midcast',true)
			windower.text.set_visibility('aftercast',true)
			windower.text.set_visibility('buff_change',true)
		elseif opt == 'invisible' then
			windower.text.set_visibility('precast',false)
			windower.text.set_visibility('midcast',false)
			windower.text.set_visibility('aftercast',false)
			windower.text.set_visibility('buff_change',false)
		end
	end)
	
	windower.text.create('precast')
	windower.text.set_bg_color('precast',100,100,100,100)
	windower.text.set_bg_visibility('precast',true)
	windower.text.set_font('precast','Consolas')
	windower.text.set_font_size('precast',12)
	windower.text.set_color('precast',255,255,255,255)
	windower.text.set_location('precast',250,10)
	windower.text.set_visibility('precast',false)
	windower.text.set_text('precast','Panda')
	
	windower.text.create('midcast')
	windower.text.set_bg_color('midcast',100,100,100,100)
	windower.text.set_bg_visibility('midcast',true)
	windower.text.set_font('midcast','Consolas')
	windower.text.set_font_size('midcast',12)
	windower.text.set_color('midcast',255,255,255,255)
	windower.text.set_location('midcast',500,10)
	windower.text.set_visibility('midcast',false)
	windower.text.set_text('midcast','Panda')
	
	windower.text.create('aftercast')
	windower.text.set_bg_color('aftercast',100,100,100,100)
	windower.text.set_bg_visibility('aftercast',true)
	windower.text.set_font('aftercast','Consolas')
	windower.text.set_font_size('aftercast',12)
	windower.text.set_color('aftercast',255,255,255,255)
	windower.text.set_location('aftercast',750,10)
	windower.text.set_visibility('aftercast',false)
	windower.text.set_text('aftercast','Panda')
	
	windower.text.create('buff_change')
	windower.text.set_bg_color('buff_change',100,100,100,100)
	windower.text.set_bg_visibility('buff_change',true)
	windower.text.set_font('buff_change','Consolas')
	windower.text.set_font_size('buff_change',12)
	windower.text.set_color('buff_change',255,255,255,255)
	windower.text.set_location('buff_change',1000,10)
	windower.text.set_visibility('buff_change',false)
	windower.text.set_text('buff_change','Panda')
end