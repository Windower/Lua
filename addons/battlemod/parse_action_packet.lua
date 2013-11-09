--	action_array = parse_action_packet(act)
--	if condensedamage then
--		for i,v in pairs(action_array) do
--			v = condense_actions(v)
--		end
--	end
--	if condensebuffs then
--		action_array = condense_targets(action_array)
--	end

function parse_action_packet(act)
	-- Make a function that returns the action array with additional information
		-- actor : type, name, is_npc
		-- target : type, name, is_npc
	act.actor = player_info(act.actor_id)
	act.action = get_spell(act) -- Pulls the resources line for the action
--	add_to_chat(8,tostring(act.action)..' '..tostring(#act.action))
--[[	for i,v in pairs(act.action) do
		add_to_chat(8,tostring(i)..' '..tostring(v))
	end]]
	
	for i,v in ipairs(act.targets) do
		v.target = {}
		v.target[1] = player_info(v.id)
		if #v.actions > 1 then
			for n,m in ipairs(v.actions) do
				if r_status[m.param] then
					m.status = r_status[m.param][language]
				end
				if r_status[m.add_effect_param] then
					m.add_effect_status = r_status[m.add_effect_param][language]
				end
				if r_status[m.spike_effect_param] then
					m.spike_effect_status = r_status[m.spike_effect_param][language]
				end
				m.number = 1
				if m.has_add_effect then
					m.add_effect_number = 1
				end
				if m.has_spike_effect then
					m.spike_effect_number = 1
				end
				if not check_filter(act.actor,v.target[1],act.category,m.message) then
					m.message = 0
					m.add_effect_message = 0
					m.spike_effect_message = 0
				end
				if condensedamage and n > 1 then -- Damage/Action condensation within one target
					for q=1,n-1 do
						local r = v.actions[q]
						if r.message ~= 0 and m.message == r.message and m.effect == r.effect and m.reaction == r.reaction then
							r.number = r.number + 1
							r.param = m.param + r.param
							m.message = 0
						end
						if m.has_add_effect and r.add_effect_message ~= 0 then
							if m.add_effect_effect == r.add_effect_effect and m.add_effect_message == r.add_effect_message and m.add_effect_message ~= 0 then
								r.add_effect_number = r.add_effect_number + 1
								r.add_effect_param = m.add_effect_param + r.add_effect_param
								m.add_effect_message = 0
							end
						end
						if m.has_spike_effect and r.spike_effect_message ~= 0 then
							if r.spike_effect_effect == r.spike_effect_effect and m.spike_effect_message == r.spike_effect_message and m.spike_effect_message ~= 0 then
								r.spike_effect_number = r.spike_effect_number + 1
								r.spike_effect_param = m.spike_effect_param + r.spike_effect_param
								m.spike_effect_message = 0
							end
						end
					end
				end
	--			local temp_act = assemble_action(v.target,act.category,act.param,act.targets[1]['actions'][1]['message'],m)
	--			if act_filter(temp_act) then -- act_filter needs to be made
	--				action_array[ind][#action_array[ind]+1] = temp_act
	--			end
			end
		else
			local tempact = v.actions[1]
			if not check_filter(act.actor,v.target[1],act.category,tempact.message) then
				tempact.message = 0
				tempact.add_effect_message = 0
				tempact.spike_effect_message = 0
			end
			tempact.number = 1
			if tempact.has_add_effect then
				tempact.add_effect_number = 1
			end
			if tempact.has_spike_effect then
				tempact.spike_effect_number = 1
			end
			if r_status[tempact.param] then
				tempact.status = r_status[tempact.param][language]
			end
			if r_status[tempact.add_effect_param] then
				tempact.add_effect_status = r_status[tempact.add_effect_param][language]
			end
			if r_status[tempact.spike_effect_param] then
				tempact.spike_effect_status = r_status[tempact.spike_effect_param][language]
			end
		end
		
		if condensetargets and i > 1 then
			for n=1,i-1 do
				local m = act.targets[n]
--				add_to_chat(8,m.actions[1].message..'  '..v.actions[1].message)
				if (v.actions[1].message == m.actions[1].message and v.actions[1].param == m.actions[1].param) or
					(message_map[m.actions[1].message] and message_map[m.actions[1].message]:contains(v.actions[1].message) and v.actions[1].param == m.actions[1].param) or
					(message_map[m.actions[1].message] and message_map[m.actions[1].message]:contains(v.actions[1].message) and v.actions[1].param == m.actions[1].param) then
					m.target[#m.target+1] = v.target[1]
					v.target[1] = nil
					v.actions[1].message = 0
				end
			end
		end
	end
	
	for i,v in pairs(act.targets) do
		local targ = assemble_targets(v.target)
		for n,m in pairs(v.actions) do
			if m.message ~= 0 then
				local color = color_filt(dialog[m.message].color,v.target[1].id==Self.id)
				if m.reaction == 11 and act.category == 1 then act.action.name = 'parried'
				elseif m.reaction == 12 and act.category == 1 then act.action.name = 'blocked'
				elseif m.message == 1 then act.action.name = 'hit'
				elseif m.message == 15 then act.action.name = 'missed'
				elseif m.message == 30 then act.action.name = 'anticipated by'
				elseif m.message == 31 then act.action.name = 'absorbed by shadow'
				elseif m.message == 32 then act.action.name = 'dodged by'
				elseif m.message == 67 then act.action.name = 'critical hit'
				elseif m.message == 106 then act.action.name = 'intimidated by'
				elseif m.message == 282 then act.action.name = 'evaded by'
				elseif m.message == 373 then act.action.name = 'absorbed by'
				elseif m.message == 352 then act.action.name = 'RA'
				elseif m.message == 353 then act.action.name = 'critical RA'
				elseif m.message == 354 then act.action.name = 'missed RA'
				elseif m.message == 576 then act.action.name = 'RA hit squarely'
				elseif m.message == 577 then act.action.name = 'RA struck true'
				elseif m.message > 287 and m.message < 303 then act.action.name = skillchain_arr[m.message-287]
				elseif m.message > 384 and m.message < 399 then act.action.name = skillchain_arr[m.message-384]
				elseif m.message ==603 then act.action.name = 'TH'
				elseif T{163,229}:contains(m.message) then act.action.name = 'AE'
				end
				local msg = simplify_message(m.message)
				add_to_chat(color,make_condensedamage_number(m.number)..(msg
					:gsub('${spell}',act.action.name or 'ERROR 111')
					:gsub('${ability}',act.action.name or 'ERROR 112')
					:gsub('${item}',act.action.name or 'ERROR 113')
					:gsub('${weapon_skill}',act.action.name or 'ERROR 114')
					:gsub('${abil}',act.action.name or 'ERROR 115')
					:gsub('${actor}',color_it(act.actor.name,color_arr[act.actor.owner or act.actor.type]))
					:gsub('${target}',targ)
					:gsub('${lb}','\7'):gsub('${number}',m.param)
					:gsub('${status}',m.status or '')
					:gsub('${gil}',m.param)))
				m.message = 0
			end
			if m.has_add_effect and m.add_effect_message ~= 0 then
				local color = color_filt(dialog[m.add_effect_message].color,v.target[1].id==Self.id)
				if m.add_effect_message > 287 and m.add_effect_message < 303 then act.action.name = skillchain_arr[m.add_effect_message-287]
				elseif m.add_effect_message > 384 and m.add_effect_message < 399 then act.action.name = skillchain_arr[m.add_effect_message-384]
				elseif m.add_effect_message ==603 then act.action.name = 'TH'
				elseif T{163,229}:contains(m.add_effect_message) then act.action.name = 'AE'
				end
				local msg = simplify_message(m.add_effect_message)
				add_to_chat(color,make_condensedamage_number(m.add_effect_number)..(msg
					:gsub('${spell}',act.action.name or 'ERROR 127')
					:gsub('${ability}',act.action.name or 'ERROR 128')
					:gsub('${item}',act.action.name or 'ERROR 129')
					:gsub('${weapon_skill}',act.action.name or 'ERROR 130')
					:gsub('${abil}',act.action.name or 'ERROR 131')
					:gsub('${actor}',color_it(act.actor.name,color_arr[act.actor.owner or act.actor.type]))
					:gsub('${target}',targ)
					:gsub('${lb}','\7')
					:gsub('${number}',m.add_effect_param)
					:gsub('${status}',m.add_effect_status or '')))
				m.add_effect_message = 0
			end
			if m.has_spike_effect and m.spike_effect_message ~= 0 then
				local color = color_filt(dialog[m.spike_effect_message].color,act.actor.id==Self.id)
				local msg = simplify_message(m.spike_effect_message)
				add_to_chat(color,make_condensedamage_number(m.spike_effect_number)..(msg
					:gsub('${spell}',act.action.name or 'ERROR 142')
					:gsub('${ability}',act.action.name or 'ERROR 143')
					:gsub('${item}',act.action.name or 'ERROR 144')
					:gsub('${weapon_skill}',act.action.name or 'ERROR 145')
					:gsub('${abil}',act.action.name or 'ERROR 146')
					:gsub('${actor}',color_it(act.actor.name,color_arr[act.actor.owner or act.actor.type]))
					:gsub('${target}',targ)
					:gsub('${lb}','\7')
					:gsub('${number}',m.spike_effect_param)
					:gsub('${status}',m.spike_effect_status or '')))
				m.spike_effect_message = 0
			end
		end
	end
	
	return act
end

function simplify_message(msg_ID)
	local msg = dialog[msg_ID][language]
	local fields = fieldsearch(msg)
	if line_full and (fields.actor and fields.target and (fields.spell or fields.ability or fields.item or fields.weapon_skill) and fields.number or 
		T{1,31,67,163,229,352,353,373,576,577}:contains(msg_ID)) then
		msg = line_full
	elseif line_nonumber and (fields.actor and fields.target and (fields.spell or fields.ability or fields.item or fields.weapon_skill) or
		T{15,30,32,106,282,354}) then
		msg = line_nonumber
	elseif line_noactor and fields.target and (fields.spell or fields.ability or fields.item or fields.weapon_skill) and fields.number then
		msg = line_noactor
	elseif line_noabil and fields.target and fields.number then
		msg = line_noabil
	end
	return msg
end

function assemble_targets(targs)
	local out_str = ''
	for i,v in pairs(targs) do
		if i == 1 then
			out_str = color_it(v.name,color_arr[v.owner or v.type])
		else
			out_str = conjunctions(out_str,color_it(v.name,color_arr[v.owner or v.type]),#targs,i)
		end
	end
	return out_str
end

function conjunctions(pre,post,target_count,current)
	if current < target_count or commamode then
		pre = pre..', '
	else
		if oxford and target_count >2 then
			pre = pre..','
		end
		pre = pre..' and '
	end
	return pre..post
end

function make_condensedamage_number(number)
	if condensedamage and 1 < number then
		return '['..number..'] '
	else
		return ''
	end
end

function player_info(id)
	local player_table = get_mob_by_id(id)
	local typ,owner,filter
	
	if player_table == nil then
		return {name=nil,id=nil,is_npc=nil,type=nil,owner=nil}
	end
	
	if player_table.is_npc then
		if player_table.id%4096>2047 then
			typ = 'other_pets'
			filter = 'other_pets'
			owner = 'other'
			for i,v in pairs(get_party()) do
				if nf(v.mob,'pet_index') == player_table.index then
					if i == 'p0' then
						typ = 'my_pet'
						filter = 'my_pet'
					end
					owner = i
					break
				end
			end
		else
			typ = 'mob'
			filter = 'monsters'
			for i,v in pairs(get_party()) do
				if nf(v.mob,'id') == player_table.claim_id and filter.enemies then
					filter = 'enemies'
				end
			end
		end
	else
		typ = 'other'
		filter = 'others'
		for i,v in pairs(get_party()) do
			if v.mob and v.mob.id == player_table.id then
				typ = i
				if i == 'p0' then
					filter = 'me'
				elseif i:sub(1,1) == 'p' then
					filter = 'party'
				else
					filter = 'alliance'
				end
			end
		end
	end
	if not typ then typ = 'debug' end
	if not filter then filter = 'me'
	add_to_chat(8,'DERP DERP DERP') end
	return {name=player_table.name,id=id,is_npc = player_table.is_npc,type=typ,filter=filter,owner=(owner or nil)}
end

function get_spell(act)
	local spell, abil_ID, effect_val = {}
	local msg_ID = act['targets'][1]['actions'][1]['message']
	
	if T{7,8,9}:contains(act['category']) then
		abil_ID = act['targets'][1]['actions'][1]['param']
	elseif T{3,4,5,6,11,13,14,15}:contains(act['category']) then
		abil_ID = act['param']
		effect_val = act['targets'][1]['actions'][1]['param']
	end
	
	if act.category == 1 then
		spell.english = 'hit'
		spell.german = spell.english
		spell.japanese = spell.english
		spell.french = spell.english
	elseif act.category == 2 and act.category == 12 then
		if msg_ID == 77 then
			spell = r_abilities[171] -- Sange
		elseif msg_ID == 157 then
			spell = r_abilities[60] -- Barrage
		else
			spell.english = 'Ranged Attack'
			spell.german = spell.english
			spell.japanese = spell.english
			spell.french = spell.english
		end
	else
		if not dialog[msg_ID] then
			if T{4,8}:contains(act['category']) then
				spell = r_spells[abil_ID]
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
		
		if fields.spell then
			spell = r_spells[abil_ID]
		elseif fields.ability then
			spell = r_abilities[abil_ID]
		elseif fields.weapon_skill then
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
		
		
		if fields.item then
			spell = r_items[abil_ID]
		end
	end
	
	spell.name = spell[language]
	return spell
end





function color_filt(col,is_me)
	--Used to convert situational colors from the resources into real colors
	--Depends on whether or not the target is you, the same as using in-game colors
	-- Returns a color code for add_to_chat()
	-- Does not currently support a Debuff/Buff distinction
	if col == "D" then -- Damage
		if is_me then
			return 28
		else
			return 20
		end
	elseif col == "M" then -- Misses
		if is_me then
			return 29
		else
			return 21
		end
	elseif col == "H" then -- Healing
		if is_me then
			return 30
		else
			return 22
		end
	elseif col == "B" then -- Beneficial effects
		if is_me then
			return 56
		else
			return 60
		end
	elseif col == "DB" then -- Detrimental effects (I don't know how I'd split these)
		if is_me then
			return 57
		else
			return 61
		end
	elseif col == "R" then -- Resists
		if is_me then
			return 59
		else
			return 63
		end
	else
		return col
	end
end

function condense_actions(action_array)
	for i,v in pairs(action_array) do
		local comb_table = {}
		for n,m in pairs(v) do
			if comb_table[m.primary.name] then
				if m.secondary.name == 'number' then
					comb_table[m.primary.name].secondary.name = tostring(tonumber(comb_table[m.primary.name].secondary.name)+tonumber(m.secondary.name))
				end
				comb_table[m.primary.name].count = comb_table[m.primary.name].count + 1
			else
				comb_table[m.primary.name] = m
				comb_table[m.primary.name].count = 1
			end
			m = nil -- Could cause next() error
		end
		for n,m in pairs(comb_table) do
			v[#v+1] = m
		end
	end
	return action_array
end

function condense_targets(action_array)
	local comb_table = {}
	for i,v in pairs(action_array) do
		local was_created = false
		for n,m in pairs(comb_table) do
			if table.equal(v,m,3) then -- Compares 3 levels deep
				n[#n+1] = i[1]
				was_created = true
			end
		end
		if not was_created then
			comb_table[{i[1]}] = v
		end
	end
	return comb_table
end

function fieldsearch(message)
	fieldarr = {}
	string.gsub(message,"{(.-)}", function(a) fieldarr[a] = true end)
	return fieldarr
end

function linefind(msg_ID,fields,bact)
	if dialog[msg_ID]['color'] == 'M' or dialog[msg_ID]['color'] == 'D' or dialog[msg_ID]['color'] == 'H' or sub_act['reaction'] == 11 or sub_act['reaction'] == 12 or msg_ID == 31 or msg_ID == 32 or T{6,7,8,9,14,15}:contains(category) then
		-- Misses, Damage, Healing, Parrying, Dodge, Guard/Block, and Utsusemi
		-- Handles for Category 1,2,3,4,6, and 14

		if condensebattle then
			if T{'Steal','Despoil','Scavenge','Mug'}:contains(bact.primary.name) then
				prepstr = dialog[msg_ID]['english']
			elseif msg_ID>419 and msg_ID<430 then
				prepstr = line_roll
			elseif bact.primary.name and bact.secondary.type == 'number' and fields.target and fields.actor then
				prepstr = line_full
			elseif bact.primary.name and bact.secondary.type == 'status' and fields.actor and fields.actor then
				prepstr = line_aoebuff
			elseif bact.secondary.type ~= 'number' then
				prepstr = line_nonumber
			elseif not fields.actor then
				prepstr = line_noactor
			elseif not bact.primary.name then
				prepstr = line_noabil
			end
		else -- Handles exceptions and people that don't condense battle messages
			prepstr = dialog[msg_ID]['english']
		end
	elseif dialog[msg_ID] then -- Default case
		prepstr = dialog[msg_ID]['english']
	end
	return prepstr
end


function check_filter(actor,target,category,msg)
	-- This determines whether the message should be displayed or filtered
	-- Returns true (don't filter) or false (filter), boolean
	if not actor.type or not target.type then return false end
	
	if not filter[actor.filter] then add_to_chat(8,tostring(actor.filter)) end
	
	if actor.filter ~= 'monsters' and actor.filter ~= 'enemies' then
		if filter[actor.filter]['all']
		or category == 1 and filter[actor.filter]['melee']
		or category == 2 and filter[actor.filter]['ranged']
		or category == 12 and filter[actor.filter]['ranged']
		or category == 5 and filter[actor.filter]['items']
		or category == 9 and filter[actor.filter]['uses']
		or nf(dialog[msg],'color')=='D' and filter[actor.filter]['damage']
		or nf(dialog[msg],'color')=='M' and filter[actor.filter]['misses']
		or nf(dialog[msg],'color')=='H' and filter[actor.filter]['healing']
		or msg == 43 and filter[actor.filter]['readies'] or msg == 326 and filter[actor.filter]['readies']
		or msg == 3 and filter[actor.filter]['casting'] or msg == 327 and filter[actor.filter]['casting']
		then
			return false
		end
	else
		if filter[actor.filter][target.filter]['all']
		or category == 1 and filter[actor.filter][target.filter]['melee']
		or category == 2 and filter[actor.filter][target.filter]['ranged']
		or category == 12 and filter[actor.filter]['ranged']
		or category == 5 and filter[actor.filter]['items']
		or category == 9 and filter[actor.filter]['uses']
		or nf(dialog[msg],'color')=='D' and filter[actor.filter][target.filter]['damage']
		or nf(dialog[msg],'color')=='M' and filter[actor.filter][target.filter]['misses']
		or nf(dialog[msg],'color')=='H' and filter[actor.filter][target.filter]['healing']
		or msg == 43 and filter[actor.filter][target.filter]['readies'] or msg == 326 and filter[actor.filter][target.filter]['readies']
		or msg == 3 and filter[actor.filter][target.filter]['casting'] or msg == 327 and filter[actor.filter][target.filter]['casting']
		then
			return false
		end
	end

	return true
end