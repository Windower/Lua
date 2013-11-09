require 'tablehelper'
require 'sets'
file = require 'filehelper'
config = require 'config'

require 'generic_helpers'
require 'parse_action_packet'
require 'statics'

_addon = {}
_addon.version = '3.04'
_addon.name = 'BattleMod'
_addon.author = 'Byrth'
_addon.commands = {'bm','battlemod'}

windower.register_event('load',function()
	options_load()
	if get_player() then
		Self = get_player()
	end
end)

windower.register_event('login',function (name)
	send_command('@wait 10;lua i battlemod options_load;')
end)

windower.register_event('addon command',function (...)
    local term = table.concat({...}, ' ')
    local splitarr = split(term,' ')
	if splitarr[1] == 'cmd' then
		if splitarr[2] ~= nil then
			if splitarr[2]:lower() == 'commamode' then
				commamode = not commamode
				add_to_chat(121,'Comma Mode flipped! - '..tostring(commamode))
			elseif splitarr[2]:lower() == 'oxford' then
				oxford = not oxford
				add_to_chat(121,'Oxford Mode flipped! - '..tostring(oxford))
			elseif splitarr[2]:lower() == 'targetnumber' then
				targetnumber = not targetnumber
				add_to_chat(121,'Target Number flipped! - '..tostring(targetnumber))
			elseif splitarr[2]:lower() == 'cancelmulti' then
				cancelmulti = not cancelmulti
				add_to_chat(121,'Multi-canceling flipped! - '..tostring(cancelmulti))
			elseif splitarr[2]:lower() == 'reload' then
				options_load()
			elseif splitarr[2]:lower() == 'unload' then
				send_command('@lua u battlemod')
			elseif splitarr[2]:lower() == 'condensebattle' then
				condensebattle = not condensebattle
				add_to_chat(121,'Condensed Battle text flipped! - '..tostring(condensebattle))
			elseif splitarr[2]:lower() == 'condensebuffs' then
				condensebuffs = not condensebuffs
				add_to_chat(121,'Condensed Buffs text flipped! - '..tostring(condensebuffs))
			elseif splitarr[2]:lower() == 'condensedamage' then
				condensedamage = not condensedamage
				add_to_chat(121,'Condensed Damage text flipped! - '..tostring(condensedamage))
			elseif splitarr[2]:lower() == 'cg' then
				collectgarbage()
			elseif splitarr[2]:lower() == 'colortest' then
				local counter = 0
				local line = ''
				for n = 1, 509 do
					if not color_redundant:contains(n) and not black_colors:contains(n) then
						if n <= 255 then
							loc_col = string.char(0x1F, n)
						else
							loc_col = string.char(0x1E, n - 254)
						end
						line = line..loc_col..string.format('%03d ', n)
						counter = counter + 1
					end
					if counter == 16 or n == 509 then
						add_to_chat(1, line)
						counter = 0
						line = ''
					end
				end
				add_to_chat(122,'Colors Tested!')
			elseif splitarr[2]:lower() == 'help' then
				write('Battlemod has 10 commands')
				write(' 1. help --- shows this menu')
				write(' 2. colortest --- Shows the 509 possible colors for use with the settings file')
				write(' 3. reload --- Reloads the settings file')
				write('Big Toggles:')
				write(' 4. condensebuffs --- Condenses Area of Effect buffs, Default = True')
				write(' 5. condensebattle --- Condenses battle logs according to your settings file, Default = True')
				write(' 6. condensedamage --- Condenses damage messages within attack rounds, Default = True')
				write(' 7. cancelmulti --- Cancles multiple consecutive identical lines, Default = True')
				write('Sub Toggles:')
				write(' 8. oxford --- Toggle use of oxford comma, Default = True')
				write(' 9. commamode --- Toggle comma-only mode, Default = False')
				write(' 10. targetnumber --- Toggle target number display, Default = True')
			end
		end
	else
		if splitarr[1] == 'wearsoff' then
			local trash = table.remove(splitarr,1)
			local stat = table.concat(splitarr,' ')
			local len = #wearing[stat]
			local targets = table.remove(wearing[stat],1)..string.char(0x1F,191)
			for i,v in pairs(wearing[stat]) do
				if i < #wearing[stat] or commamode then
					targets = targets..string.char(0x1F,191)..', '
				else
					if oxford and #wearing[stat] >2 then
						targets = targets..string.char(0x1F,191)..','
					end
					targets = targets..string.char(0x1F,191)..' and '
				end
				targets = targets..v
			end
			if targetnumber and len > 1 then
				targets = '['..len..'] '..targets
			end
			local outstr = (dialog[206]['english']
				:gsub('$\123target\125',targets..string.char(0x1F,191))
				:gsub('$\123status\125',stat..string.char(0x1F,191)) )
			add_to_chat(1,string.char(0x1F,191)..outstr..string.char(127,49))
			wearing[stat] = nil
		end
	end
end)

windower.register_event('incoming text',function (original, modified, color)
	local redcol = color%256
	
--[[	if redcol == 36 then
		a,z = string.find(original,' defeats ')
		if a then
			if original:sub(1,4) ~= string.char(0x1F,0xFE,0x1E,0x01) then
				modified = true
			end
		end
	elseif redcol == 127 then
		a,z = string.find(original,' corpuscles of ')
		b,z = string.find(original,' experience points')
		if a or b then
			if original:sub(1,4) ~= string.char(0x1F,0xFE,0x1E,0x01) then
				modified = true
			end
		end
	else]]if redcol == 121 and cancelmulti then
		a,z = string.find(original,'Equipment changed')
		
		if a and not block_equip then
			send_command('@wait 1;lua i battlemod flip_block_equip')
			block_equip = true
		elseif a and block_equip then
			modified = true
		end
	elseif redcol == 123 and cancelmulti then
		a,z = string.find(original,'You were unable to change your equipped items')
		b,z = string.find(original,'You cannot use that command while viewing the chat log')
		c,z = string.find(original,'You must close the currently open window to use that command')
		
		if (a or b or c) and not block_cannot then
			send_command('@wait 1;lua i battlemod flip_block_cannot')
			block_cannot = true
		elseif (a or b or c) and block_cannot then
			modified = true
		end
	end
	
	return modified,color
end)

function flip_block_equip()
	block_equip = not block_equip
end

function flip_block_cannot()
	block_cannot = not block_cannot
end

function options_load()
	if not dir_exists(lua_base_path..'data\\') then
		create_dir(lua_base_path..'data\\')
	end
	if not dir_exists(lua_base_path..'data\\filters\\') then
		create_dir(lua_base_path..'data\\filters\\')
	end
	 
	local settingsFile = file.new('data\\settings.xml',true)
	local filterFile=file.new('data\\filters\\filters.xml',true)
	local colorsFile=file.new('data\\colors.xml',true)
	
	if not file.exists('data\\settings.xml') then
		settingsFile:write(default_settings)
		write('Default settings xml file created')
	end
	
	local settingtab = config.load('data\\settings.xml',default_settings_table)
	config.save(settingtab)
	
	for i,v in pairs(settingtab) do
		_G[i] = v
	end
	
	if not file.exists('data\\filters\\filters.xml') then
		filterFile:write(default_filters)
		write('Default filters xml file created')
	end
	local tempplayer = get_player()
	if tempplayer then
		if tempplayer.main_job ~= 'NONE' then
			filterload(tempplayer.main_job)
		elseif get_mob_by_id(tempplayer.id)['race'] == 0 then
			filterload('MON')
		else
			filterload('DEFAULT')
		end
	else
		filterload('DEFAULT')
	end
	if not file.exists('data\\colors.xml') then
		colorsFile:write(default_colors)
		write('Default colors xml file created')
	end
	local colortab = config.load('data\\colors.xml',default_color_table)
	config.save(colortab)
	for i,v in pairs(colortab) do
		color_arr[i] = colconv(v,i)
	end
end

windower.register_event('job change',function (mjob_id,mjob,mjob_lvl,sjob_id,sjob,sjob_lvl)
	filterload(mjob)
end)

function filterload(job)
	if Current_job == job then return end
	if file.exists('data\\filters\\filters-'..job..'.xml') then
		filter = config.load('data\\filters\\filters-'..job..'.xml',default_filter_table,false)
		add_to_chat(4,'Loaded '..job..' Battlemod filters')
	else
		filter = config.load('data\\filters\\filters.xml',default_filter_table,false)
		add_to_chat(4,'Loaded default Battlemod filters')
	end
	Current_job = job
end

windower.register_event('incoming chunk',function (id,original,modified,is_injected,is_blocked)
	local pref = original:sub(1,4)
	local data = original:sub(5)
	if id == 0x28 and original ~= last_28_packet then
		last_28_packet = original
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
				if debugging then --act.targets[i].actions[n].stagger > 2  then
					-- Value 8 to 63 will knockback
					act.targets[i].actions[n].stagger = act.targets[i].actions[n].stagger%8
				end
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
		act = parse_action_packet(act)

		local react = assemble_bit_packed('',act.do_not_need,0,8)
		react = assemble_bit_packed(react,act.actor_id,8,40)
		react = assemble_bit_packed(react,act.target_count,40,50)
		react = assemble_bit_packed(react,act.category,50,54)
		react = assemble_bit_packed(react,act.param,54,70)
		react = assemble_bit_packed(react,act.unknown,70,86)
		react = assemble_bit_packed(react,act.recast,86,118)
		
		local offset = 118
		for i = 1,act.target_count do
			react = assemble_bit_packed(react,act.targets[i].id,offset,offset+32)
			react = assemble_bit_packed(react,act.targets[i].action_count,offset+32,offset+36)
			offset = offset + 36
			for n = 1,act.targets[i].action_count do
				react = assemble_bit_packed(react,act.targets[i].actions[n].reaction,offset,offset+5)
				react = assemble_bit_packed(react,act.targets[i].actions[n].animation,offset+5,offset+16)
				react = assemble_bit_packed(react,act.targets[i].actions[n].effect,offset+16,offset+21)
				react = assemble_bit_packed(react,act.targets[i].actions[n].stagger,offset+21,offset+27)
				react = assemble_bit_packed(react,act.targets[i].actions[n].param,offset+27,offset+44)
				react = assemble_bit_packed(react,act.targets[i].actions[n].message,offset+44,offset+54)
				react = assemble_bit_packed(react,act.targets[i].actions[n].unknown,offset+54,offset+85)
				
				react = assemble_bit_packed(react,act.targets[i].actions[n].has_add_effect,offset+85,offset+86)
				offset = offset + 86
				if act.targets[i].actions[n].has_add_effect then
					react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_animation,offset,offset+6)
					react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_effect,offset+6,offset+10)
					react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_param,offset+10,offset+27)
					react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_message,offset+27,offset+37)
					offset = offset + 37
				end
				react = assemble_bit_packed(react,act.targets[i].actions[n].has_spike_effect,offset,offset+1)
				offset = offset + 1
				if act.targets[i].actions[n].has_spike_effect then
					react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_animation,offset,offset+6)
					react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_effect,offset+6,offset+10)
					react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_param,offset+10,offset+24)
					react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_message,offset+24,offset+34)
					offset = offset + 34
				end
			end
		end
--		if react:sub(1) ~= data:sub(1,#react) then
--			write('REACT does not match up')
--		end
		while #react < #data do
			react = react..data:sub(#react+1,#react+1)
		end
--		local first_error = true
--		for i=1,#data do
--			if data:byte(i) ~= react:byte(i) then
--				if first_error then
--					first_error = nil
--				end
--				add_to_chat(8,'Mismatch at byte '..i..'.')
--			end
--		end

		return pref..react
	end
	
	if id == 0x29 then
		local am = {}
		am.actor_id = get_bit_packed(data,0,32)
		am.target_id = get_bit_packed(data,32,64)
		am.param_1 = get_bit_packed(data,64,96)
		am.param_2 = get_bit_packed(data,96,102) -- First 6 bits
		am.param_3 = get_bit_packed(data,102,128) -- Rest
		am.actor_index = get_bit_packed(data,128,144)
		am.target_index = get_bit_packed(data,144,160)
		am.message_id = get_bit_packed(data,160,175) -- Cut off the most significant bit, hopefully
		
		if am.message_id == 206 then -- Wears off messages
			local status
			local targ = player_info(am.target_id)
			
			if enfeebling:contains(am.param_1) and r_status[param_1] then
				status = color_it(r_status[param_1]['english'],color_arr.enfeebcol)
			elseif color_arr.statuscol == rcol then
				status = color_it(r_status[am.param_1]['english'],string.char(0x1F,191))
			else
				status = color_it(r_status[am.param_1]['english'],color_arr.statuscol)
			end
			
			if not wearing[status] and not (stat_ignore:contains(am.param_1)) then
				wearing[status] = {}
				wearing[status][1] = color_it(targ.name,color_arr[targ.owner or targ.type])
				send_command('@wait 0.5;lua c battlemod wearsoff '..status)
			elseif not (stat_ignore:contains(am.param_1)) then
				wearing[status][#wearing[status]+1] = color_it(targ.name,color_arr[targ.owner or targ.type])
			else
			-- This handles the stat_ignore values, which are things like Utsusemi,
			-- Sneak, Invis, etc. that you don't want to see on a delay
				wearing[status] = {}
				wearing[status][1] = color_it(targ.name,color_arr[targ.owner or targ.type])
				send_command('@lua c battlemod wearsoff '..status)
			end
			am.message_id = false
		elseif passed_messages:contains(am.message_id) then
			local status,spell,skill,number,number2
			local actor = player_info(am.actor_id)
			local target = player_info(am.target_id)
			
			if actor.name == nil or actor.is_npc == nil then
				return
			end
			
			if am.message_id > 169 and am.message_id <179 then
				if am.param_1 == 4294967296 then
					skill = 'like level -1'..' ('..ratings_arr[am.param_2+1]..')'
				else
					skill = 'like level '..am.param_1..' ('..ratings_arr[am.param_2+1]..')'
				end
				--if debugging then write(am.param_1..'   '..am.param_2..'   '..am.param_3) end
			end
			
			if am.message_id == 558  then
				number2 = am.param_2
			end
			number = am.param_1
			
			if am.param_1 ~= 0 then
				status = (enLog[am.param_1] or nf(r_status[am.param_1],'english'))
				spell = nf(r_spells[am.param_1],'english')
			end
			
			if status then
				if enfeebling:contains(am.param_1) then
					status = color_it(status,color_arr.enfeebcol)
				else
					status = color_it(status,color_arr.statuscol)
				end
			end

			if spell then spell = color_it(spell,color_arr.spellcol) end
			if target then target = color_it(target.name,color_arr[target.owner or target.type]) end
			if actor then actor = color_it(actor.name,color_arr[actor.owner or actor.type]) end
			if skill then skill = color_it(skill,color_arr.abilcol) end
			
			local outstr = (dialog[am.message_id]['english']
				:gsub('$\123actor\125',actor or '')
				:gsub('$\123status\125',status or '')
				:gsub('$\123target\125',target or '')
				:gsub('$\123spell\125',spell or '')
				:gsub('$\123skill\125',skill or '')
				:gsub('$\123number\125',number or '')
				:gsub('$\123number2\125',number2 or '')
				:gsub('$\123lb\125','\7'))
			add_to_chat(dialog[am.message_id]['color'],string.char(0x1F,0xFE,0x1E,0x01)..outstr..string.char(127,49))
			am.message_id = false
		elseif T{62,94,251,308,313}:contains(am.message_id) then
		-- 62 is "fails to activate" but it is color 121 so I cannot block it because I
			-- would also accidentally block a lot of system messages. Thus I have to ignore it.
		-- Message 251 is "about to wear off" but it is color 123 so I cannot block it
			-- because I would also block "you failed to swap that gear, idiot!" messages. Thus I have to ignore it.
		-- Message 308 is "your inventory is full" but it is color 123.
		-- Message 313 is the red "target is out of range" message but it is color 123 so I
			-- cannot block it because I would also block "you failed to swap that gear, idiot!" messages. Thus I have to ignore it.
		elseif T{38,202}:contains(am.message_id) then
		-- 38 is the Skill Up message, which (interestingly) uses all the number params.
		-- 202 is the Time Remaining message, which (interestingly) uses all the number params.
			if debugging then
				write('debug_EAM#'..am.message_id..': '..dialog[am.message_id]['english']..' '..am.param_1..'   '..am.param_2..'   '..am.param_3)
			end
		elseif debugging then 
			write('debug_EAM#'..am.message_id..': '..dialog[am.message_id]['english'])
		end
		if not am.message_id then
			return true
		end
--[[		local ream = assemble_bit_packed('',am.actor_id,0,32)
		ream = assemble_bit_packed(ream,am.target_id,32,64)
		ream = assemble_bit_packed(ream,am.param_1,64,96)
		ream = assemble_bit_packed(ream,am.param_2,96,102) -- First 6 bits
		ream = assemble_bit_packed(ream,am.param_3,102,128) -- Rest
		ream = assemble_bit_packed(ream,am.actor_index,128,144)
		ream = assemble_bit_packed(ream,am.target_index,144,160)
		ream = assemble_bit_packed(ream,am.message_id,160,175) -- Cut off the most significant bit, hopefully]]
	end

	if id == 0x030 then
		if get_player().id == (data:byte(3,3)*256*256 + data:byte(2,2)*256 + data:byte(1,1)) then
			result = data:byte(9,9)
			if result == 0 then
				add_to_chat(8,' ------------- NQ Synthesis -------------')
			elseif result == 1 then
				add_to_chat(8,' ---------------- Break -----------------')
			elseif result == 2 then
				add_to_chat(8,' ------------- HQ Synthesis -------------')
			else
				add_to_chat(8,'Craftmod: Unhandled result '..tostring(result))
			end
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

function assemble_bit_packed(init,val,initial_length,final_length,debug_val)
	if type(val) == 'boolean' then
		if val then val = 1 else val = 0 end
	end
	local bits = initial_length%8
	local byte_length = math.ceil(final_length/8)
	
	local out_val = 0
	if bits > 0 then
		out_val = init:byte(#init) -- Initialize out_val to the remainder in the active byte.
		init = init:sub(1,#init-1) -- Take off the active byte
	end
	out_val = out_val + val*2^bits -- left-shift val by the appropriate amount and add it to the remainder (now the lsb-s in val)
	if debug_val then write(out_val..' '..#init) end
	
	while out_val > 0 do
		init = init..string.char(out_val%256)
		out_val = math.floor(out_val/256)
	end
	while #init < byte_length do
		init = init..string.char(0)
	end
	return init
end