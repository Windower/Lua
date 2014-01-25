function parse_action_packet(act)
	-- Make a function that returns the action array with additional information
		-- actor : type, name, is_npc
		-- target : type, name, is_npc
	act.actor = player_info(act.actor_id)
	act.action = get_spell(act) -- Pulls the resources line for the action
	for i,v in ipairs(act.targets) do
		v.target = {}
		v.target[1] = player_info(v.id)
		if #v.actions > 1 then
			for n,m in ipairs(v.actions) do
				if dialog[m.message] then m.fields = fieldsearch(dialog[m.message][language]) end
				if dialog[m.add_effect_message] then m.add_effect_fields = fieldsearch(dialog[m.add_effect_message][language]) end
				if dialog[m.spike_effect_message] then m.spike_effect_fields = fieldsearch(dialog[m.spike_effect_message][language]) end

				if r_status[m.param] and m.param ~= 0 then
					m.status = r_status[m.param][language]
				end
				if r_status[m.add_effect_param] and m.add_effect_param ~= 0 then
					m.add_effect_status = r_status[m.add_effect_param][language]
				end
				if r_status[m.spike_effect_param] and m.spike_effect_param ~= 0 then
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
				end
				if not check_filter(v.target[1],act.actor,act.category,m.message) then
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
			end
		else
			local tempact = v.actions[1]
			if dialog[tempact.message] then tempact.fields = fieldsearch(dialog[tempact.message][language]) end
			if dialog[tempact.add_effect_message] then tempact.add_effect_fields = fieldsearch(dialog[tempact.add_effect_message][language]) end
			if dialog[tempact.spike_effect_message] then tempact.spike_effect_fields = fieldsearch(dialog[tempact.spike_effect_message][language]) end
			
				
			--if tempact.add_effect_fields and tempact.add_effect_fields.status then windower.add_to_chat(8,tostring(tempact.add_effect_fields.status)..' '..dialog[tempact.add_effect_message][language]) end
			
			if not check_filter(act.actor,v.target[1],act.category,tempact.message) then
				tempact.message = 0
				tempact.add_effect_message = 0
			end
			if not check_filter(v.target[1],act.actor,act.category,tempact.message) then
				tempact.spike_effect_message = 0
			end
			tempact.number = 1
			if tempact.has_add_effect and tempact.message ~= 674 then
				tempact.add_effect_number = 1
			end
			if tempact.has_spike_effect then
				tempact.spike_effect_number = 1
			end
			if r_status[tempact.param] and tempact.param ~= 0 then
				tempact.status = r_status[tempact.param][language]
			end
			if r_status[tempact.add_effect_param] and tempact.add_effect_param ~= 0 then
				tempact.add_effect_status = r_status[tempact.add_effect_param][language]
			end
			if r_status[tempact.spike_effect_param] and tempact.spike_effect_param ~= 0 then
				tempact.spike_effect_status = r_status[tempact.spike_effect_param][language]
			end
		end
		
		if condensetargets and i > 1 then
			for n=1,i-1 do
				local m = act.targets[n]
--				windower.add_to_chat(8,m.actions[1].message..'  '..v.actions[1].message)
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
		for n,m in pairs(v.actions) do
			if m.message ~= 0 then
				local targ = assemble_targets(act.actor,v.target,act.category,m.message)
				local color = color_filt(dialog[m.message].color,v.target[1].id==Self.id)
				if m.reaction == 11 and act.category == 1 then m.simp_name = 'parried by'
				elseif m.reaction == 12 and act.category == 1 then m.simp_name = 'blocked by'
				elseif m.message == 1 then m.simp_name = 'hit'
				elseif m.message == 15 then m.simp_name = 'missed'
				elseif m.message == 29 or m.message == 84 then m.simp_name = 'is paralyzed'
				elseif m.message == 30 then m.simp_name = 'anticipated by'
				elseif m.message == 31 then m.simp_name = 'absorbed by'
				elseif m.message == 32 then m.simp_name = 'dodged by'
				elseif m.message == 67 then m.simp_name = 'critical hit'
				elseif m.message == 106 then m.simp_name = 'intimidated by'
				elseif m.message == 282 then m.simp_name = 'evaded by'
				elseif m.message == 373 then m.simp_name = 'absorbed by'
				elseif m.message == 352 then m.simp_name = 'RA'
				elseif m.message == 353 then m.simp_name = 'critical RA'
				elseif m.message == 354 then m.simp_name = 'missed RA'
				elseif m.message == 576 then m.simp_name = 'RA hit squarely'
				elseif m.message == 577 then m.simp_name = 'RA struck true'
				elseif m.message == 157 then m.simp_name = 'Barrage'
				elseif m.message == 77 then m.simp_name = 'Sange'
				elseif m.message == 360 then m.simp_name = act.action.name..' (JA reset)'
				elseif m.message == 426 or m.message == 427 then m.simp_name = 'Bust! '..act.action.name
				elseif m.message == 435 or m.message == 436 then m.simp_name = act.action.name..' (JAs)'
				elseif m.message == 437 or m.message == 438 then m.simp_name = act.action.name..' (JAs and TP)'
				elseif m.message == 439 or m.message == 440 then m.simp_name = act.action.name..' (SPs, JAs, TP, and MP)'
				elseif T{252,265,268,269,271,272,274,275}:contains(m.message) then m.simp_name = 'Magic Burst! '..act.action.name
				else m.simp_name = act.action.name or ''
				end

--				if m.message == 93 or m.message == 273 then m.status=color_it('Vanish',color_arr['statuscol']) end

				-- Special Message Handling
				if m.message == 93 or m.message == 273 then
					m.status=color_it('Vanish',color_arr['statuscol'])
				elseif m.message == 522 and simplify then
					targ = targ..' (stunned)'
				elseif T{158,188,245,324,592,658}:contains(m.message) and simplify then
					-- When you miss a WS or JA. Relevant for condensed battle.
					m.status = 'Miss' --- This probably doesn't work due to the if a==nil statement below.
				elseif m.message == 653 or m.message == 654 then
					m.status = color_it('Immunobreak',color_arr['statuscol'])
				elseif m.message == 655 or m.message == 656 then
					m.status = color_it('Completely Resists',color_arr['statuscol'])
				elseif m.message == 85 or m.message == 284 then
					m.status = color_it('Resists',color_arr['statuscol'])
				elseif T{75,156,189,248,283,312,323,336,355,408,422,423,425,659}:contains(m.message) then
					m.status = color_it('No effect',color_arr['statuscol']) -- The status code for "No Effect" is 255, so it might actually work without this line
				end
				if m.message == 188 then
					m.simp_name = m.simp_name..' (Miss)'
			--	elseif m.message == 189 then
			--		m.simp_name = m.simp_name..' (No Effect)'
				elseif T{78,198,328}:contains(m.message) then
					m.simp_name = '(Too Far)'
				end
				local msg,numb = simplify_message(m.message)
				if not color_arr[act.actor.owner or act.actor.type] then windower.add_to_chat(123,'Battlemod error, missing filter:'..tostring(act.actor.owner)..' '..tostring(act.actor.type)) end
				if m.fields.status then numb = m.status else numb = pref_suf(m.param,m.message) end
	
				if msg and m.message == 70 and not simplify then -- fix pronoun on parry
					if act.actor.race == 0 then
						msg = msg:gsub(' his ',' its ')
					elseif female_races:contains(act.actor.race) then
						msg = msg:gsub(' his ',' her ')
					end
				end
			
				windower.add_to_chat(color,make_condensedamage_number(m.number)..( (msg or tostring(m.message))
					:gsub('${spell}',color_it(act.action.spell or 'ERROR 111',color_arr.spellcol))
					:gsub('${ability}',color_it(act.action.ability or 'ERROR 112',color_arr.abilcol))
					:gsub('${item}',color_it(act.action.item or 'ERROR 113',color_arr.itemcol))
					:gsub('${item2}',color_it(act.action.item2 or 'ERROR 121',color_arr.itemcol))
					:gsub('${weapon_skill}',color_it(act.action.weapon_skill or 'ERROR 114',color_arr.wscol))
					:gsub('${abil}',m.simp_name or 'ERROR 115')
					:gsub('${numb}',numb or 'ERROR 116')
					:gsub('${actor}',color_it(act.actor.name or 'ERROR 117',color_arr[act.actor.owner or act.actor.type]))
					:gsub('${target}',targ)
					:gsub('${lb}','\7')
					:gsub('${number}',act.action.number or m.param)
					:gsub('${status}',m.status or 'ERROR 120')
					:gsub('${gil}',m.param)))
				m.message = 0
			end
			if m.has_add_effect and m.add_effect_message ~= 0 and add_effect_valid[act.category] then
				local targ = assemble_targets(act.actor,v.target,act.category,m.add_effect_message)
				local color = color_filt(dialog[m.add_effect_message].color,v.target[1].id==Self.id)
				if m.add_effect_message > 287 and m.add_effect_message < 303 then m.simp_add_name = skillchain_arr[m.add_effect_message-287]
				elseif m.add_effect_message > 384 and m.add_effect_message < 399 then m.simp_add_name = skillchain_arr[m.add_effect_message-384]
				elseif m.add_effect_message ==603 then m.simp_add_name = 'TH'
				else m.simp_add_name = 'AE'
				end
				local msg,numb = simplify_message(m.add_effect_message)
				if m.add_effect_fields.status then numb = m.add_effect_status else numb = pref_suf(m.add_effect_param,m.add_effect_message) end
				if not act.action then
					windower.add_to_chat(color, 'act.action==nil : '..m.message..' - '..m.add_effect_message..' - '..msg)
				else
					windower.add_to_chat(color,make_condensedamage_number(m.add_effect_number)..(msg
						:gsub('${spell}',act.action.spell or 'ERROR 127')
						:gsub('${ability}',act.action.ability or 'ERROR 128')
						:gsub('${item}',act.action.item or 'ERROR 129')
						:gsub('${weapon_skill}',act.action.weapon_skill or 'ERROR 130')
						:gsub('${abil}',m.simp_add_name or act.action.name or 'ERROR 131')
						:gsub('${numb}',numb or 'ERROR 132')
						:gsub('${actor}',color_it(act.actor.name,color_arr[act.actor.owner or act.actor.type]))
						:gsub('${target}',targ)
						:gsub('${lb}','\7')
						:gsub('${number}',m.add_effect_param)
						:gsub('${status}',m.add_effect_status or 'ERROR 178')))
				end
				m.add_effect_message = 0
			end
			if m.has_spike_effect and m.spike_effect_message ~= 0 and spike_effect_valid[act.category] then
				local targ = assemble_targets(act.actor,v.target,act.category,m.spike_effect_message)
				local color = color_filt(dialog[m.spike_effect_message].color,act.actor.id==Self.id)
				if m.spike_effect_message == 33 then m.simp_spike_name = 'countered by' else
					m.simp_spike_name = 'spikes' end
				local msg = simplify_message(m.spike_effect_message)
				if m.spike_effect_fields.status then numb = m.spike_effect_status else numb = pref_suf(m.spike_effect_param,m.spike_effect_message) end
				windower.add_to_chat(color,make_condensedamage_number(m.spike_effect_number)..(msg
					:gsub('${spell}',act.action.spell or 'ERROR 142')
					:gsub('${ability}',act.action.ability or 'ERROR 143')
					:gsub('${item}',act.action.item or 'ERROR 144')
					:gsub('${weapon_skill}',act.action.weapon_skill or 'ERROR 145')
					:gsub('${abil}',m.simp_spike_name or act.action.name or 'ERROR 146')
					:gsub('${numb}',numb or 'ERROR 147')
					:gsub('${actor}',color_it(act.actor.name,color_arr[act.actor.owner or act.actor.type]))
					:gsub('${target}',targ)
					:gsub('${lb}','\7')
					:gsub('${number}',m.spike_effect_param)
					:gsub('${status}',m.spike_effect_status or 'ERROR 150')))
				m.spike_effect_message = 0
			end
		end
	end
	
	return act
end

function pref_suf(param,msg_ID)
	local outstr = tostring(param)
	if dialog[msg_ID] and dialog[msg_ID].prefix then
		outstr = dialog[msg_ID].prefix..' '..outstr
	end
	if dialog[msg_ID] and dialog[msg_ID].suffix then
		outstr = outstr..' '..dialog[msg_ID].suffix
	end
	return outstr
end

function simplify_message(msg_ID)
	local msg = dialog[msg_ID][language]
	local fields = fieldsearch(msg)

	if simplify and not T{23,125,129,133,139,140,153,244,453,557,593,594,595,596,597,598,599,674}:contains(msg_ID) then
		if T{93,273,522,653,654,655,656,85,284,75,156,189,248,283,312,323,336,355,408,422,423,425,659,158,245,324,592,658}:contains(msg_ID) then
			fields.status = true
		end
		if msg_ID == 31 then
			fields.actor = true
		end	
		if (msg_ID > 287 and msg_ID < 303) or (msg_ID > 384 and msg_ID < 399) or
			T{152,161,162,163,165,229,384,603,652}:contains(msg_ID) then
				fields.ability = true
		end
		
		if T{152,160,161,162,163,164,165,166,167,168,229,652}:contains(msg_ID) then
			fields.actor  = true
			fields.target = true
		end

		if line_full and fields.number and fields.target and fields.actor then
			msg = line_full
		elseif line_aoebuff and fields.status and fields.target then --and fields.actor then -- and (fields.spell or fields.ability or fields.item or fields.weapon_skill) then
			msg = line_aoebuff
		elseif line_item and fields.item2 then
			if fields.number then
				msg = line_itemnum
			else
				msg = line_item
			end
		elseif line_nonumber and not fields.number then
			msg = line_nonumber
		elseif line_aoe and T{264}:contains(msg_ID) then
			msg = line_aoe
		elseif line_noactor and not fields.actor and (fields.spell or fields.ability or fields.item or fields.weapon_skill) then
			msg = line_noactor
		elseif line_noability and not fields.actor then
			msg = line_noability
		end
	end
	return msg
end

function assemble_targets(actor,targs,category,msg)
	local targets = {}
	for i,v in pairs(targs) do
	-- Done in two loops so that the ands and commas don't get out of place.
	-- This loop filters out unwanted targets.
		if check_filter(actor,v,category,msg) then
			targets[#targets+1] = v
		end
	end
	
	local out_str
	if targetnumber and #targets > 1 then
		out_str = '{'..#targets..'} '
	else
		out_str = ''
	end
	
	for i,v in pairs(targets) do
		if i == 1 then
			out_str = color_it(v.name,color_arr[v.owner or v.type])
		else
			out_str = conjunctions(out_str,color_it(v.name,color_arr[v.owner or v.type]),#targets,i)
		end
	end
	return out_str
end

function make_condensedamage_number(number)
	if swingnumber and condensedamage and 1 < number then
		return '['..number..'] '
	else
		return ''
	end
end

function player_info(id)
	local player_table = windower.ffxi.get_mob_by_id(id)
	local typ,owner,filter
	
	if player_table == nil then
		return {name=nil,id=nil,is_npc=nil,type='debug',owner=nil,race=nil}
	end
	
	for i,v in pairs(windower.ffxi.get_party()) do
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
	
	if not filter then
		if player_table.is_npc then
			if player_table.id%4096>2047 then
				typ = 'other_pets'
				filter = 'other_pets'
				owner = 'other'
				for i,v in pairs(windower.ffxi.get_party()) do
					if v.mob and v.mob.pet_index and v.mob.pet_index == player_table.index then
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
				for i,v in pairs(windower.ffxi.get_party()) do
					if nf(v.mob,'id') == player_table.claim_id and filter.enemies then
						filter = 'enemies'
					end
				end
			end
		else
			typ = 'other'
			filter = 'others'
		end
	end
	if not typ then typ = 'debug' end
	return {name=player_table.name,id=id,is_npc = player_table.is_npc,type=typ,filter=filter,owner=(owner or nil),race = player_table.race}
end

function get_spell(act)
	local spell, abil_ID, effect_val = {}
	local msg_ID = act.targets[1].actions[1].message
	
	if T{7,8,9}:contains(act['category']) then
		abil_ID = act.targets[1].actions[1].param
	elseif T{3,4,5,6,11,13,14,15}:contains(act.category) then
		abil_ID = act.param
		effect_val = act.targets[1].actions[1].param
	end
	
	if act.category == 1 then
		spell.english = 'hit'
		spell.german = spell.english
		spell.japanese = spell.english
		spell.french = spell.english
	elseif act.category == 2 and act.category == 12 then
		if msg_ID == 77 then
			spell = r_abilities[171] -- Sange
			spell.name = color_it(spell[language],color_arr.abilcol)
		elseif msg_ID == 157 then
			spell = r_abilities[60] -- Barrage
			spell.name = color_it(spell[language],color_arr.abilcol)
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
			spell.name = color_it(spell[language],color_arr.spellcol)
			spell.spell = color_it(spell[language],color_arr.spellcol)
		elseif fields.ability then
			spell = r_abilities[abil_ID]
			spell.name = color_it(spell[language],color_arr.abilcol)
			spell.ability = color_it(spell[language],color_arr.abilcol)
		elseif fields.weapon_skill then
			if abil_ID > 255 then -- WZ_RECOVER_ALL is used by chests in Limbus
				spell = r_mabils[abil_ID-256]
				if spell.english == '.' then
					spell.english = 'Special Attack'
				end
			elseif abil_ID < 256 then
				spell = r_abilities[abil_ID+768]
			end
			spell.name = color_it(spell[language],color_arr.wscol)
			spell.weapon_skill = color_it(spell[language],color_arr.wscol)
		elseif msg_ID == 303 then
			spell = r_abilities[74] -- Divine Seal
			spell.name = color_it(spell[language],color_arr.abilcol)
			spell.ability = color_it(spell[language],color_arr.abilcol)
		elseif msg_ID == 304 then
			spell = r_abilities[75] -- 'Elemental Seal'
			spell.name = color_it(spell[language],color_arr.abilcol)
			spell.ability = color_it(spell[language],color_arr.abilcol)
		elseif msg_ID == 305 then
			spell = r_abilities[76] -- 'Trick Attack'
			spell.name = color_it(spell[language],color_arr.abilcol)
			spell.ability = color_it(spell[language],color_arr.abilcol)
		elseif msg_ID == 311 or msg_ID == 311 then
			spell = r_abilities[79] -- 'Cover'
			spell.name = color_it(spell[language],color_arr.abilcol)
			spell.ability = color_it(spell[language],color_arr.abilcol)
		elseif msg_ID == 240 or msg_ID == 241 then
			spell = r_abilities[43] -- 'Hide'
			spell.name = color_it(spell[language],color_arr.abilcol)
			spell.ability = color_it(spell[language],color_arr.abilcol)
		end
		
		if fields.item then
			if T{125,593,594,595,596,597,598,599}:contains(msg_ID) then
				spell.item = color_it(r_items[effect_val]['enl'], color_arr.itemcol)
			else
				spell = r_items[abil_ID]
				spell.name = color_it(spell['enl'],color_arr.itemcol)
				spell.item = color_it(spell['enl'],color_arr.itemcol)
			end
		end
		
		if fields.item2 then
			local tempspell = r_items[effect_val]
			spell.item2 = color_it(tempspell.enl,color_arr.itemcol)
			if fields.number then
				spell.number = act.targets[1].actions[1].add_effect_param
			end
		end
	end
	
	if not spell.name then spell.name = spell[language] end
	return spell
end


function color_filt(col,is_me)
	--Used to convert situational colors from the resources into real colors
	--Depends on whether or not the target is you, the same as using in-game colors
	-- Returns a color code for windower.add_to_chat()
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
