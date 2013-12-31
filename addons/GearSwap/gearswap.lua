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
_addon.version = '0.801'
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
require 'flow'
require 'lists'
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
	if logging then
		local command = table.concat({...},' ')
		logit(logfile,'\n\n'..tostring(os.clock)..command)
	end
	local splitup = {...}
	if splitup[1]:lower() == 'c' then
		if gearswap_disabled then return end
		if splitup[2] then equip_sets('self_command',_raw.table.concat(splitup,' ',2,#splitup))
		else
			windower.add_to_chat(123,'GearSwap: No self command passed.')
		end
	elseif splitup[1]:lower() == 'equip' then
		if gearswap_disabled then return end
		local set_split = string.split(_raw.table.concat(splitup,' ',2,#splitup):gsub('%[','%.'):gsub('[%]\']',''),'.')
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
		if user_env and user_env.sets then
			table.remove(splitup,1)
			export_set(splitup)
		end
	elseif splitup[1]:lower() == 'validate' then
		if user_env and user_env.sets then
			validate()
		end
	elseif splitup[1]:lower() == 'enable' then
		disenable(splitup,enable,'enable',false)
	elseif splitup[1]:lower() == 'disable' then
		disenable(splitup,disable,'disable',true)
	elseif splitup[1]:lower() == 'reload' then
		refresh_user_env()
	elseif strip(splitup[1]) == 'debugmode' then
		_settings.debug_mode = not _settings.debug_mode
		print('GearSwap: Debug Mode set to '..tostring(_settings.debug_mode)..'.')
	elseif strip(splitup[1]) == 'showswaps' then
		_settings.show_swaps = not _settings.show_swaps
		print('GearSwap: Show Swaps set to '..tostring(_settings.show_swaps)..'.')
	elseif not ((strip(splitup[1]) == 'eval' or strip(splitup[1]) == 'visible' or strip(splitup[1]) == 'invisible') and debugging>0) then
		print('GearSwap: Command not found')
	end
end)

function disenable(tab,funct,functname,pol)
	if tab[2] and tab[2]:lower()=='all' then
		funct('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
		print('GearSwap: All slots '..functname..'d.')
	elseif tab[2]  then
		for i=2,#tab do
			if slot_map[tab[i]:gsub('[^%a]',''):lower()] then
				funct(tab[i])
				print('GearSwap: '..tab[i]..' slot '..functname..'d.')
			else
				print('GearSwap: Unable to find slot '..tostring(tab[i])..'.')
			end
		end
	elseif gearswap_disabled ~= pol and not tab[2] then
		print('GearSwap: User file '..functname..'d')
		gearswap_disabled = pol
	end
end

windower.register_event('outgoing text',function(original,modified)
	if debugging >= 1 then windower.debug('outgoing text') end
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
		
		spell = aftercast_cost(r_line)
		spell.target = temp_mob_arr
		
		storedcommand = command..' "'..spell[language]..'" '
		return equip_sets('pretarget',spell,{type=s_type})
	elseif command_list[command] == 'Ranged Attack' and temptarg then
		if logging then	logit(logfile,'\n\n'..tostring(os.clock)..'(93) temp_mod: '..temp_mod) end

		rline = r_abilities[1]
		spell = aftercast_cost(rline)
		spell.target = temp_mob_arr
		
		storedcommand = spell.prefix..' '
		return equip_sets('pretarget',spell,{type="Ranged Attack"})
	end
	return modified
end)

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
		if gearswap_disabled then return end
		data = data:sub(5)
		local arr = {}
		arr.actor_id = get_bit_packed(data,0,32)
		arr.target_id = get_bit_packed(data,32,64)
		arr.param_1 = get_bit_packed(data,64,96)
		arr.param_2 = get_bit_packed(data,96,102) -- First 6 bits
		arr.param_3 = get_bit_packed(data,102,128) -- Rest
		arr.actor_index = get_bit_packed(data,128,144)
		arr.target_index = get_bit_packed(data,144,160)
		arr.message_id = get_bit_packed(data,160,175) -- Cut off the most significant bit, hopefully
		
		inc_action_message(arr)
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
				if _settings.debug_mode then windower.add_to_chat(8,"GearSwap (Debug Mode): Your "..v..' are now unlocked.') end
			end
			encumbrance_table[i] = tf
		end
		if table.length(tab) > 0 then
			equip_sets('equip_command',tab)
		end
		if current_job_file ~= res.jobs[data:byte(9)].short then
			refresh_user_env(data:byte(9))
		end
	elseif gearswap_disabled then
		return
	elseif id == 0x050 and not injected then
--		'Equipment packet'
		if sent_out_equip[data:byte(6)] == data:byte(5) then
			sent_out_equip[data:byte(6)] = nil
			limbo_equip[data:byte(6)] = data:byte(5)
			if table.length(sent_out_equip) == 1 and sent_out_equip.ind and out_arr[sent_out_equip.ind] and out_arr[sent_out_equip.ind].verify_equip then
				local out = packet_send_check(true,sent_out_equip.ind)
				sent_out_equip.ind = nil
				if type(out) == 'string' then
					windower.packets.inject_outgoing((out:byte(2)%2)*256+out:byte(1),out)
				end
			end
		end
	elseif id == 0x01D and not injected then
		limbo_equip = {}
	end
end)

windower.register_event('outgoing chunk',function(id,original,modified,injected,blocked)
	if gearswap_disabled then return end
	if debugging >= 1 then windower.debug('outgoing chunk '..id) end
	if (id == 0x1A or id == 0x36 or id == 0x37) and not injected then
		local cur_time = os.clock()
		for i,v in pairs(outgoing_packet_table) do
			if cur_time-v > 1 then
				outgoing_packet_table[i] = nil
			elseif i:sub(1,2) == original:sub(1,2) and i:sub(5) == original:sub(5) then
				return
			end
		end
		outgoing_packet_table[original] = os.clock()
		local arr = {}
		data = original:sub(5)
		if id == 0x01A then
	--		'Action Packet'
			arr.actor_id = get_bit_packed(data,0,32)
			arr.target_index = get_bit_packed(data,32,48)
			arr.category = get_bit_packed(data,48,64)
			arr.param = get_bit_packed(data,64,80)
			arr.unknown1 = get_bit_packed(data,80,96)
			arr.target_id = windower.ffxi.get_mob_by_index(arr.target_index).id
			return out_action(arr,original)
		elseif id == 0x036 then
	--		'Menu Item Packet'
			arr.target_id = get_bit_packed(data,0,32)
			arr.inventory_index = get_bit_packed(data,352,360)
			arr.target_index = get_bit_packed(data,432,448)
			return out_item(arr,original)
		elseif id == 0x037 then
	--		'Use Item Packet'
			arr.target_id = get_bit_packed(data,0,32)
			arr.target_index = get_bit_packed(data,64,80)
			arr.inventory_index = get_bit_packed(data,80,88)
			return out_item(arr,original)
		end
	end
end)

windower.register_event('status change',function(new,old)
	if debugging >= 1 then windower.debug('status change '..new) end
	if gearswap_disabled or T{2,3,4}:contains(old) or T{2,3,4}:contains(new) then return end
	equip_sets('status_change',res.statuses[new].english,res.statuses[old].english)
end)

windower.register_event('gain buff',function(name,id)
	if debugging >= 1 then windower.debug('gain buff '..name) end
	if gearswap_disabled then return end
	if _global.midaction and T{'terror','sleep','stun','petrification','charm','weakness'}:contains(name:lower()) then _global.midaction = false end
	equip_sets('buff_change',name,true)
end)

windower.register_event('lose buff',function(name,id)
	if debugging >= 1 then windower.debug('lose buff '..name) end
	if gearswap_disabled then return end
	equip_sets('buff_change',name,false)
end)

windower.register_event('job change',function(mjob, mjob_id, mjob_lvl, sjob, sjob_id, sjob_lvl)
	if debugging >= 1 then windower.debug('job change') end
	print(mjob, mjob_id, mjob_lvl, sjob, sjob_id, sjob_lvl)
	if mjob ~= current_job_file then
		refresh_user_env(mjob_id)
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
	out_arr = {}
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
			elseif T{5,9}:contains(act.category) then
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