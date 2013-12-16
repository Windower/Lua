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


language = 'english'
file = require 'filehelper'
require 'stringhelper'
require 'helper_functions'
require 'tablehelper'

require 'statics'
require 'equip_processing'
require 'targets'
require 'user_functions'
require 'refresh'
require 'parse_augments'
require 'export'
require 'validate'
if windower.file_exists(windower.addon_path..'resources.lua') then
    os.remove(windower.addon_path..'resources.lua',windower.addon_path..'res_bak - can delete.lua')
end
res = require 'resources'


_addon.name = 'GearSwap'
_addon.version = '0.720'
_addon.author = 'Byrth'
_addon.commands = {'gs','gearswap'}

windower.register_event('load',function()
	debugging = 0
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
	if logging then	logfile:close() end
end)

windower.register_event('addon command',function (...)
	if debugging >= 1 then windower.debug('addon command') end
	local command = table.concat({...},' ')
	if logging then	logit(logfile,'\n\n'..tostring(os.clock)..command) end
	local splitup = split(command,' ')
	if splitup[1]:lower() == 'c' then
		if gearswap_disabled then return end
		if splitup[2] then equip_sets('self_command',_raw.table.concat(splitup,' ',2,#splitup))
		else
			windower.add_to_chat(123,'GearSwap: No self command passed.')
		end
	elseif splitup[1]:lower() == 'equip' and not midaction then
		if gearswap_disabled then return end
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
			print('Gearswap: All slots enabled.')
		elseif splitup[2] and slot_map[splitup[2]:gsub('[^%a]',''):lower()] then
			enable(splitup[2])
			print('Gearswap: '..splitup[2]..' enabled.')
		elseif gearswap_disabled then
			gearswap_disabled = false
			print('GearSwap: Enabled')
		end
	elseif splitup[1]:lower() == 'disable' then
		if splitup[2] and splitup[2]:lower()=='all' then
			disable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
			print('Gearswap: All slots disabled.')
		elseif splitup[2] and slot_map[splitup[2]:gsub('[^%a]',''):lower()] then
			disable(splitup[2])
			print('Gearswap: '..splitup[2]..' disabled.')
		elseif not gearswap_disabled and not splitup[2] then
			print('GearSwap: Disabled')
			gearswap_disabled = true
		end
	elseif splitup[1]:lower() == 'reload' then
		refresh_user_env()
	elseif strip(splitup[1]) == 'debugmode' then
		_global.debug_mode = not _global.debug_mode
		print('Debug Mode set to '..tostring(_global.debug_mode)..'.')
	elseif strip(splitup[1]) == 'showswaps' then
		_global.show_swaps = not _global.show_swaps
		print('Show Swaps set to '..tostring(_global.show_swaps)..'.')
	else
		print('command not found')
	end
end)

function sender()
	if not action_sent then
		print('Forcing Send')
		if debugging >= 1 then windower.add_to_chat(123,'GearSwap: Had to force the command to send.') end
		send_check(true)
	end
	force_flag = false
	action_sent = false
end

windower.register_event('outgoing text',function(original,modified)
	if debugging >= 1 then windower.debug('outgoing text') end
	if gearswap_disabled then return modified end
	
	local temp_mod = windower.convert_auto_trans(modified)
	local splitline = split(temp_mod,' ')
	local command = splitline[1]

	local a,b,abil = string.find(temp_mod,'"(.-)"')
	if abil then
		abil = abil:lower()
	elseif #splitline == 3 then
		abil = splitline[2]:lower()
	end
	
	local temptarg = valid_target(splitline[#splitline])
	
	if command == '/raw' then
		return _raw.table.concat(splitline,' ',2,#splitline)
	elseif command_list[command] and temptarg and validabils[language][abil] and not midaction then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(93) temp_mod: '..temp_mod) end
		
		local r_line, s_type
			
		if command_list[command] == 'Magic' then
			r_line = r_spells[validabils[language][abil:lower()]['Magic']]
			r_line.name = r_line[language]
			if r_line.type == 'BardSong' and r_line.casttime == 8 then
				refresh_buff_active(windower.ffxi.get_player().buffs)
				if buffactive.pianissimo then
				-- Handling for the casting time reduction of Pianissimo.
				-- Note, does not work unless the buff list has been updated.
					r_line.casttime=4
				end
			elseif r_line.type == 'SummonerPact' and buffactive['astral conduit'] then
				r_line.recast=0
			elseif buffactive.hasso or buffactive.seigan then
				r_line.recast=r_line.recast*1.5
				r_line.casttime = r_line.casttime*1.5
			end
			s_type = 'Magic' -- command_list[r_spells[validabils[language][abil:lower()]['Magic']]['prefix']]
		elseif command_list[command] == 'Ability' then
			r_line = r_abilities[validabils[language][abil:lower()]['Ability']]
			r_line.name = r_line[language]
			s_type = 'Ability' -- command_list[r_abilities[validabils[language][abil:lower()]['Ability']]['prefix']]
		elseif command_list[command] == 'Item' then
			r_line = r_items[validabils[language][abil:lower()]['Item']]
			r_line.name = r_line[language]
			r_line.prefix = '/item'
			r_line.type = 'Item'
			s_type = 'Item'
		elseif debugging then
			print('this case should never be hit '..command)
		end
		
		_global.storedtarget = temptarg
		
		r_line = aftercast_cost(r_line)
		
		storedcommand = command..' "'..r_line[language]..'" '
		equip_sets('precast',r_line,{type=s_type})

		return ''
	elseif command_list[command] == 'Ranged Attack' and temptarg and not midaction then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(93) temp_mod: '..temp_mod) end

		rline = ranged_line
		
		_global.storedtarget = temptarg
		
		r_line = aftercast_cost(rline)
			
		storedcommand = r_line['prefix']..' '
		equip_sets('precast',r_line,{type="Ranged Attack"})

		return ''
	elseif midaction and validabils[language][tostring(abil):lower()] then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(122) Canceled: '..temp_mod) end
		return ''
	end
	return modified
end)

windower.register_event('incoming text',function(original,modified,color)
	if debugging >= 1 then windower.debug('incoming text') end
	if gearswap_disabled then return modified, color end
	if original == '...A command error occurred.' or original == 'You can only use that command during battle.' or original == 'You cannot use that command here.' then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(130) Client canceled command detected: '..color..' '..original) end
		if type(user_env.aftercast)=='function' then
			equip_sets('aftercast',{name='Invalid Spell'},{type='Recast'})
		elseif user_env.aftercast then
			windower.add_to_chat(123,'GearSwap: aftercast() exists but is not a function')
		end
	end
	return modified,color
end)

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	if debugging >= 1 then windower.debug('incoming chunk '..id) end

	if id == 0x28 then
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
		action(act)
	elseif id == 0x29 then
		if gearswap_disabled then return end
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
	elseif id == 0x01B then
--		'Job Info Packet'
		local enc = data:byte(97) + data:byte(98)*256
		for i=0,15 do
			local tf = (math.floor( (enc%(2^(i+1))) / 2^i ) == 1) -- Could include the binary library some day if necessary
			if encumbrance_table[i] ~= tf then
				if not tf and not_sent_out_equip[i] and not disable_table[i] then
					local eq = windower.ffxi.get_items().equipment
					if not_sent_out_equip[i] ~= eq[default_slot_map[i]] then
						windower.ffxi.set_equip(not_sent_out_equip[i],i)
					end
					sent_out_equip[i] = not_sent_out_equip[i]
					not_sent_out_equip[i] = nil
					if _global.debug_mode then windower.add_to_chat(8,"Gearswap (Debug Mode): Your "..default_slot_map[i]..' are now unlocked.') end
				end
				encumbrance_table[i] = tf
			end
		end
	elseif gearswap_disabled then
		return
	elseif id == 0x050 then
--		'Equipment packet'
		if sent_out_equip[data:byte(6)] == data:byte(5) then
			sent_out_equip[data:byte(6)] = nil
			send_check()
		end
	end
end)

function get_bit_packed(dat_string,start,stop)
	local newval = 0
	
	local c_count = math.ceil(stop/8)
	while c_count >= math.ceil((start+1)/8) do
		-- Grabs the most significant byte first and works down towards the least significant.
		local cur_val = dat_string:byte(c_count)
		local scal = 256
		
		if c_count == math.ceil(stop/8) then -- Take the least significant bits of the most significant byte
		-- Moduluses by 2^number of bits into the current byte. So 8 bits in would %256, 1 bit in would %2, etc.
		-- Cuts off the top.
			cur_val = cur_val%(2^((stop-1)%8+1)) -- -1 and +1 set the modulus result range from 1 to 8 instead of 0 to 7.
		end
		
		if c_count == math.ceil((start+1)/8) then -- Take the most significant bits of the least significant byte
		-- Divides by the significance of the final bit in the current byte. So 8 bits in would /128, 1 bit in would /1, etc.
		-- Cuts off the bottom.
			cur_val = math.floor(cur_val/(2^(start%8)))
			scal = 2^(8-start%8)
		end
		
		newval = newval*scal + cur_val -- Need to multiply by 2^number of bits in the next byte
		c_count = c_count - 1
	end
	return newval
end

windower.register_event('zone change',function(new_zone,new_zone_id,old_zone,old_zone_id)
	if debugging >= 1 then windower.debug('zone change') end
	midaction = false
	--sent_out_equip = {}
end)

windower.register_event('outgoing chunk',function(id,data,modified,injected,blocked)
	if debugging >= 1 then windower.debug('outgoing chunk '..id) end
	if id == 0x015 then
		lastbyte = data:byte(7,8)
	end
	if id == 0x01A then -- Action packet
		local abil_name
		actor_id = data:byte(8,8)*256^3+data:byte(7,7)*256^2+data:byte(6,6)*256+data:byte(5,5)
		index = data:byte(10,10)*256+data:byte(9,9)
		category = data:byte(12,12)*256+data:byte(11,11)
		param = data:byte(14,14)*256+data:byte(13,13)
		_unknown1 = data:byte(16,16)*256+data:byte(15,15)
		local actor_name = windower.ffxi.get_mob_by_id(actor_id)['name']
		local target_name = windower.ffxi.get_mob_by_index(index)['name']
		if category == 3 and not buffactive.silence and not buffactive.mute then -- 3 = Magic
			abil_name = r_spells[param][language]
		elseif (category == 7 or category == 25) and not buffactive.amnesia then -- 7 = WS, 25 = Monster skill
			abil_name = r_abilities[param+768][language]
		elseif category == 9 and not buffactive.amnesia then -- 9 = Ability
			abil_name = r_abilities[param][language]
		elseif category == 16 then -- 16 = . . . ranged attack
			abil_name = 'Ranged Attack'
		end
		if logging then logit(logfile,'\n\nActor: '..tostring(actor_name)..'  Target: '..tostring(target_name)..'  Category: '..tostring(category)..'  param: '..tostring(abil_name or param)) end
		if abil_name and not (buffactive.terror or buffactive.sleep or buffactive.stun or buffactive.petrification or buffactive.charm) then
			midaction = true
			windower.send_command('@wait 1;lua i gearswap midact')
		elseif user_env and not T{0,2,4,5,11,12,13,14,15,18,20}:contains(category) then -- 0 = interacting with an NPC, 2 = engaging, 4 = disengaging from menu, 5 = CFH, 11 = Homepointing, 12= assist, 13 = getting up from reraise, 14 = fishing, 15 = changing target, 18 = dismounting chocobo, 20 = zoning
			if not T{3,7,9,16,25}:contains(category) then windower.add_to_chat(8,'Tell Byrth how you triggered this and this number: '..category) end
			if type(user_env.aftercast) == 'function' then
				equip_sets('aftercast',{name='Interrupt',type='Interrupt'},{type='Recast'})
			elseif user_env.aftercast then
				midaction = false
				spelltarget = nil
				windower.add_to_chat(123,'GearSwap: aftercast() exists but is not a function')
			else
				midaction = false
				spelltarget = nil
			end
		end
	end
end)

function midact()
	midaction = false
end

function action(act)
	if debugging >= 1 then windower.debug('action') end
	if gearswap_disabled or act.category == 1 then return end
	
	local temp_player = windower.ffxi.get_player()
	local temp_player_mob_table = windower.ffxi.get_mob_by_index(temp_player.index)
	local player_id = temp_player['id']
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
	
	if act['actor_id'] == pet_id then 
		prefix = 'pet_'
	end
	
	local spell = get_spell(act)
	local category = act.category
	if logging then	
		if spell then logit(logfile,'\n\n'..tostring(os.clock)..'(178) Event Action: '..tostring(spell.english)..' '..tostring(act['category']))
		else logit(logfile,'\n\nNil spell detected') end
	end
	
	if jas[category] or uses[category] or (readies[category] and act.param == 28787 and not (category == 9)) then
		local action_type = get_action_type(category)
		if readies[category] and act.param == 28787 and not (category == 9) then
			action_type = 'Failure'
		end
		
		if type(user_env[prefix..'aftercast']) == 'function' then
			equip_sets(prefix..'aftercast',spell,{type=action_type})
		elseif user_env[prefix..'aftercast'] then
			midaction = false
			spelltarget = nil
			windower.add_to_chat(123,'GearSwap: '..prefix..'aftercast() exists but is not a function')
		else
			midaction = false
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
		midaction = false
		spelltarget = nil
	end
	
	local tempplay = windower.ffxi.get_player()
	if actor_id ~= tempplay.id then
		if tempplay.pet_index then
			if actor_id ~= windower.ffxi.get_mob_by_index(tempplay.pet_index)['id'] then
				return
			end
		else
			return
		end
	end
	
	if message_id == 62 then
		if type(user_env.aftercast) == 'function' then
			equip_sets('aftercast',r_items[param_1],{type='Failure'})
		elseif user_env.aftercast then
			midaction = false
			spelltarget = nil
			windower.add_to_chat(123,'GearSwap: aftercast() exists but is not a function')
		else
			midaction = false
			spelltarget = nil
		end
	elseif unable_to_use:contains(message_id) and midaction then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(195) Event Action Message: '..tostring(message_id)..' Interrupt') end
		if type(user_env.aftercast) == 'function' then
			equip_sets('aftercast',{name='Interrupt',type='Interrupt'},{type='Recast'})
		elseif user_env.aftercast then
			midaction = false
			spelltarget = nil
			windower.add_to_chat(123,'GearSwap: aftercast() exists but is not a function')
		else
			midaction = false
			spelltarget = nil
		end
	end
end

windower.register_event('status change',function(new,old)
	if debugging >= 1 then windower.debug('status change '..new) end
	if gearswap_disabled or T{2,3,4}:contains(old) or T{2,3,4}:contains(new) then return end
	equip_sets('status_change',res.statuses[new].english,res.statuses[old].english)
end)

windower.register_event('gain buff',function(name,id)
	if debugging >= 1 then windower.debug('gain buff '..name) end
	if gearswap_disabled then return end
	if midaction and T{'terror','sleep','stun','petrification','charm','weakness'}:contains(name:lower()) then midaction = false end
	equip_sets('buff_change',name,'gain')
end)

windower.register_event('lose buff',function(name,id)
	if debugging >= 1 then windower.debug('lose buff '..name) end
	if gearswap_disabled then return end
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
	windower.send_command('@wait 2;lua i gearswap refresh_user_env;')
end)

windower.register_event('day change',function(new,old)
	if debugging >= 1 then windower.debug('day change') end
	windower.send_command('@wait 0.5;lua invoke gearswap refresh_ffxi_info')
end)

windower.register_event('weather change',function(new_weather, new_weather_id, old_weather, old_weather_id)
	if debugging >= 1 then windower.debug('weather change') end
	refresh_ffxi_info()
end)



function get_spell(act)
	local spell, abil_ID, effect_val = {}
	local msg_ID = act['targets'][1]['actions'][1]['message']
	
	if T{7,8,9}:contains(act['category']) then
		abil_ID = act['targets'][1]['actions'][1]['param']
	elseif T{3,4,5,6,11,13,14,15}:contains(act['category']) then
		abil_ID = act['param']
		effect_val = act['targets'][1]['actions'][1]['param']
	end
	
	if act.category == 12 and act.category == 2 then
		spell.english = 'Ranged Attack'
		spell.german = 'Ranged Attack'
		spell.japanese = 'Ranged Attack'
		spell.french = 'Ranged Attack'
	else
		if not dialog[msg_ID] then
			if T{4,8}:contains(act['category']) then
				spell = r_spells[abil_ID]
				if act.category == 4 then spell.recast = act.recast end
			elseif T{3,6,7,13,14,15}:contains(act['category']) then
				spell = r_abilities[abil_ID] -- May have to correct for charmed pets some day, but I'm not sure there are any monsters with TP moves that give no message.
			elseif T{5,9}:contains(act['category']) then
				spell = r_items[abil_ID]
			else
				spell = {none=tostring(msg_ID)} -- Debugging
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
	if category == 3 and not midaction then -- Try to filter for Job Abilities that come back as WSs.
		action_type = 'Job Ability'
	else
		action_type = category_map[category]
	end
	return action_type
end
