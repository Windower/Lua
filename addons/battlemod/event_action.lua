function event_action(act)
	local persistantmessage = ''
	local persistanttarget = ''
	local persistantcolor = 1
	local aggregate = false
	local eventual_send = false
	
	local msg = act['targets'][1]['actions'][1]['message']
	if agg_messages:contains(msg) and condensebuffs then
		aggregate = true -- checks if the first message is one of the multi-target indicating messages
	end
	
	local party_table = get_party()
	local actor_table = get_mob_by_id(act['actor_id'])
	local actor = actor_table['name']
	if actor == nil then return end
	actor = namecol(actor,actor_table,party_table)

	for i,v in pairs(act['targets']) do
		for n,m in pairs(act['targets'][i]['actions']) do			
			local prepstr,abil,add_eff_str,spike_str,forcemsg,wsparm,status,number,spell,ability,weapon_skill,item
			
			local flipped = false
			local target_table = get_mob_by_id(act['targets'][i]['id'])
			local target = target_table['name']
			target = namecol(target,target_table,party_table)
		
			if act['category'] == 1 then -- Melee swings
				if act['targets'][i]['actions'][n]['reaction'] == 11 then
					abil = 'Parries'
					actor,target,flipped = flip(actor,target)
				elseif  act['targets'][i]['actions'][n]['reaction'] == 12 then abil = 'Blocks'
					actor,target,flipped = flip(actor,target)
					number = act['targets'][i]['actions'][n]['param']
				elseif act['targets'][i]['actions'][n]['message'] == 1 then abil = 'Hits'
					number = act['targets'][i]['actions'][n]['param']
				elseif act['targets'][i]['actions'][n]['message'] == 15 then abil = 'Misses'
				elseif act['targets'][i]['actions'][n]['message'] == 32 then abil = 'Dodges'
					actor,target,flipped = flip(actor,target)
				elseif act['targets'][i]['actions'][n]['message'] == 106 then abil = 'Intimidates'
					actor,target,flipped = flip(actor,target)
				elseif act['targets'][i]['actions'][n]['message'] == 31 then abil = 'Disappears'
					actor,target,flipped = flip(actor,target)
					number = act['targets'][i]['actions'][n]['param']
				elseif act['targets'][i]['actions'][n]['message'] == 67 then abil = 'Crits'
					number = act['targets'][i]['actions'][n]['param']
				elseif debugging and not act['targets'][i]['actions'][n]['has_spike_effect'] then
					number = act['targets'][i]['actions'][n]['param']
					write('debug_cat1: '..act['targets'][i]['actions'][n]['param']..' '..act['targets'][i]['actions'][n]['message'])
				end
			elseif act['category'] == 2 then -- Ranged attacks
				number = act['targets'][i]['actions'][n]['param']
				if act['targets'][i]['actions'][n]['message'] == 352 then abil = 'RA Hits'
				elseif act['targets'][i]['actions'][n]['message'] == 353 then abil = 'RA Crits'
				elseif act['targets'][i]['actions'][n]['message'] == 354 then abil = 'RA Misses'
					number = nil
				elseif act['targets'][i]['actions'][n]['message'] == 576 then abil = 'RA Hits Squarely'
				elseif act['targets'][i]['actions'][n]['message'] == 577 then abil = 'RA Strikes True'
				end
			elseif act['category'] == 3 then -- Weapon Skills
				number = act['targets'][i]['actions'][n]['param']
				a,b = string.find(dialog[act['targets'][i]['actions'][n]['message']]['english'],'$\123ability\125') -- Jump registers as a weaponskill and doesn't use an offset.
				if a then
					ability = color_arr['wscol']..jobabilities[act['param']]['english']..string.char(0x1E,0x01)
					if items[act['targets'][i]['actions'][n]['param']] then
						item = color_arr['itemcol']..items[act['targets'][i]['actions'][n]['param']]['enl']..string.char(0x1E,0x01)
					end
				else
					weapon_skill = color_arr['wscol']..jobabilities[act['param']+768]['english']..string.char(0x1E,0x01)
				end
			elseif act['category'] == 4 then
				number = act['targets'][i]['actions'][n]['param']
				if nf(spells[act['param']],'english') then
					spell= color_arr['spellcol']..nf(spells[act['param']],'english')..string.char(0x1E,0x01)
				end

				if act['targets'][i]['actions'][n]['message'] == 93 or act['targets'][i]['actions'][n]['message'] == 273 then
					status=color_arr['statuscol']..'Vanish'..string.char(0x1E,0x01)
				elseif act['targets'][i]['actions'][n]['param'] == 0 or act['targets'][i]['actions'][n]['param'] == 255 then
					status = color_arr['statuscol']..'No effect'..string.char(0x1E,0x01)
				elseif statuses[act['targets'][i]['actions'][n]['param']] ~= nil then
					status = color_arr['statuscol']..statuses[act['targets'][i]['actions'][n]['param']]['english']..string.char(0x1E,0x01)
				end
			elseif act['category'] == 5 then
				item = color_arr['itemcol']..items[act['param']]['enl']..string.char(0x1E,0x01)
				number = act['targets'][i]['actions'][n]['param']
			elseif act['category'] == 6 then
				ability = color_arr['abilcol']..jobabilities[act['param']]['english']..string.char(0x1E,0x01)
				number = act['targets'][i]['actions'][n]['param']
				if act['targets'][i]['actions'][n]['param']~=0 then
					status = nf(statuses[act['targets'][i]['actions'][n]['param']],'english')
				else
					status = ability
				end
			elseif act['category'] == 7 then
				wsparm = act['targets'][i]['actions'][n]['param']
				if actor_table['is_npc'] then
					if actor_table['id']%4096 > 2048 then -- If the NPC is a pet
						ability = color_arr['abilcol']..jobabilities[wsparm]['english']..string.char(0x1E,0x01)
					else
						if wsparm > 256 then -- Accounts for TP moves that don't show up in the logs, like the Geyser eruption
							weapon_skill = color_arr['mobwscol']..mabils[wsparm-256]['english']..string.char(0x1E,0x01)
						end
					end
				else
					weapon_skill = color_arr['wscol']..jobabilities[wsparm+768]['english']..string.char(0x1E,0x01) --- Nil concat error somehow.
				end
			elseif act['category'] == 8 then
				spell = color_arr['spellcol']..spells[act['targets'][i]['actions'][n]['param']]['english']..string.char(0x1E,0x01)
			elseif act['category'] == 9 then
				if act['param'] ~= 115 then
					item = nf(items[act['targets'][i]['actions'][n]['param']],'enl')
					if item then item = color_arr['itemcol']..item..string.char(0x1E,0x01) end
				end
			elseif act['category'] == 11 then
				weapon_skill = mabils[act['param']-256]['english']
				if weapon_skill == '.' then
					weapon_skill = 'Special Attack'
				end
				weapon_skill = color_arr['mobwscol']..weapon_skill..string.char(0x1E,0x01)
				number = act['targets'][i]['actions'][n]['param']
				if nf(statuses[act['targets'][i]['actions'][n]['param']],'english') then
					status = color_arr['statuscol']..nf(statuses[act['targets'][i]['actions'][n]['param']],'english')..string.char(0x1E,0x01)
				end
			elseif act['category'] == 13 then
				ability = color_arr['abilcol']..jobabilities[act['param']]['english']..string.char(0x1E,0x01)
				number = act['targets'][i]['actions'][n]['param']
				if statuses[act['targets'][i]['actions'][n]['param']] ~= nil then
					status = color_arr['statuscol']..statuses[act['targets'][i]['actions'][n]['param']]['english']..string.char(0x1E,0x01)
				end
			elseif act['category'] == 14 then
				ability = color_arr['abilcol']..jobabilities[act['param']]['english']..string.char(0x1E,0x01)
				status = nf(statuses[act['targets'][i]['actions'][n]['param']],'english')
				if status ~= nil then
					status = color_arr['statuscol']..status..string.char(0x1E,0x01)
				end
				number = act['targets'][i]['actions'][n]['param']
				if act['targets'][1]['actions'][1]['message'] == 522 then
					target = target..' (stunned)'
				end
			end
			
			-- Sets the common field "abil" based on the applicable abilities.
			-- Only one should be valid at any given time.
			if not abil then
				abil = weapon_skill or ability or spell
			end
			
			if act['targets'][i]['actions'][n]['message'] == 158 or act['targets'][i]['actions'][n]['message'] == 188 or act['targets'][i]['actions'][n]['message'] == 245 or act['targets'][i]['actions'][n]['message'] == 324 or act['targets'][i]['actions'][n]['message'] == 592 or act['targets'][i]['actions'][n]['message'] == 658 then
			-- When you miss a WS or JA. Relevant for condensed battle.
				number = 'Miss' -- I don't know if this is doing anything.
			elseif act['targets'][i]['actions'][n]['message'] == 31 and condensebattle then
				number = number..' Shadow' -- Error here, number was nil.
			elseif act['targets'][i]['actions'][n]['message'] ~= 0 then
				if dialog[act['targets'][i]['actions'][n]['message']]['units'] ~= nil and condensebattle then
					number = number..' '..dialog[act['targets'][i]['actions'][n]['message']]['units']
				elseif dialog[act['targets'][i]['actions'][n]['message']]['color'] == 'H' and condensebattle then
					status = color_arr['statuscol']..statuses[number]['english']..string.char(0x1E,0x01)
				end
			end
			
			-- Below Here

			if act['targets'][i]['actions'][n]['message'] ~= 0 then
				if dialog[act['targets'][i]['actions'][n]['message']]['color'] == 'M' or dialog[act['targets'][i]['actions'][n]['message']]['color'] == 'D' or dialog[act['targets'][i]['actions'][n]['message']]['color'] == 'H' or act['targets'][i]['actions'][n]['reaction'] == 11 or act['targets'][i]['actions'][n]['reaction'] == 12 or act['targets'][i]['actions'][n]['message'] == 31 or act['targets'][i]['actions'][n]['message'] == 32 or act['category']==6 or act['category']==14 then
					-- Misses, Damage, Healing, Parrying, Dodge, Guard/Block, and Utsusemi
					-- Handles for Category 1,2,3,4,6, and 14
					a,b = string.find(dialog[act['targets'][i]['actions'][n]['message']]['english'],'$\123number\125')
					if a == nil then -- Distinguishes between Status effects and Damage/Healing.
						number = nil
					end
					if condensebattle then
						if abil and number and target and actor then
							prepstr = line_full
						elseif not number then
							prepstr = line_nonumber
						elseif not actor then
							prepstr = line_noactor
						elseif debugging then ---- Can remove once I don't see it anymore ----
							write(number..' '..abil..' '..target..' '..actor)
							prepstr = dialog[act['targets'][i]['actions'][n]['message']]['english']
						end
					else ---- Can remove once I don't see it anymore ----
						prepstr = dialog[act['targets'][i]['actions'][n]['message']]['english']
					end
				else
					prepstr = dialog[act['targets'][i]['actions'][n]['message']]['english']
				end
			elseif act['category'] == 12 then -- Handles category 12 cases
				if act['param']==24931 then -- Initiation of the ranged attack
					prepstr = ''
				elseif act['param'] == 28787 then -- Interruption of the ranged attack
					prepstr = dialog[218]['english'] -- 220 is the same message
					forcemsg = 218
				elseif debugging then
					write('debug12: '..act['param'])
				end
			elseif act['category'] == 8 then -- Handles category 8 cases where the message is 0 (interruption)
				prepstr = dialog[16]['english']
				forcemsg = 16
			else
				if act['targets'][i]['actions'][n]['message'] ~= 0 and debugging then
					write('debug4: '..act['category']..' '..dialog[act['targets'][i]['actions'][n]['message']]) --- Debug message. Can be removed eventually.
				elseif act['targets'][i]['actions'][n]['spike_effect_message'] == 0 and debugging then
					write('debug4: '..act['category'])
				end
				prepstr = ''
			end
			
			-- Avoid nil field errors using " or ''" with all the gsubs.
			prepstr = prepstr:gsub('$\123lb\125','\7'):gsub('$\123actor\125',actor or ''):gsub('$\123spell\125',spell or ''):gsub('$\123ability\125',ability or ''):gsub('$\123abil\125',abil or ''):gsub('$\123number\125',number or ''):gsub('$\123weapon_skill\125',weapon_skill or ''):gsub('$\123status\125',status or ''):gsub('$\123item\125',item or '')
						
			-- Construct the message to be sent out --
			if prepstr ~= '' then
				if forcemsg == nil then
					if aggregate ~= true then
						if check_filter(actor_table,party_table,target_table,act['category'],msg) then
							if dialog[act['targets'][i]['actions'][n]['message']]['color'] ~= nil then
								add_to_chat(colorfilt(dialog[act['targets'][i]['actions'][n]['message']]['color'],target_table['is_npc'],target_table['id']==party_table['p0']['mob']['id']),string.char(0x1F,0xFE,0x1E,0x01)..prepstr:gsub('$\123target\125',target or '')..string.char(127,49))
							elseif debugging then
								add_to_chat(1,string.char(0x1F,0xFE,0x1E,0x01)..prepstr:gsub('$\123target\125',target or '')..string.char(127,49))
							end
						end
					elseif i==1 then
						if condensebattle then
							eventual_send = check_filter(actor_table,party_table,target_table,act['category'],msg)
							if act['targets'][i]['actions'][n]['message']>419 and act['targets'][i]['actions'][n]['message']<430 then
								if act['targets'][i]['actions'][n]['param'] == 12 then -- Bust is always 12
									number = 'Bust!'
								end
								persistantmessage = line_roll:gsub('$\123status\125',status or ''):gsub('$\123actor\125',actor or ''):gsub('$\123number\125',number or ''):gsub('$\123abil\125',abil or '')
							else
								persistantmessage = line_aoebuff:gsub('$\123status\125',status or ''):gsub('$\123actor\125',actor or ''):gsub('$\123abil\125',abil or '')
							end
						else
							persistantmessage = prepstr
						end
						persistantcolor = dialog[act['targets'][i]['actions'][n]['message']]['color']
						persistanttarget = target
						if act['target_count'] == 1 and check_filter(actor_table,party_table,target_table,act['category'],msg) then
							add_to_chat(persistantcolor,persistantmessage)
						end
					else
						-- Applies the proper connectors to the target series
						if i < act['target_count'] then
							persistanttarget = persistanttarget..', '
						else
							if commamode then
								persistanttarget = persistanttarget..', '
							else
								if oxford and act['target_count'] >2 then
									persistanttarget = persistanttarget..','
								end
								persistanttarget = persistanttarget..' and '
							end	
						end
						persistanttarget = persistanttarget..target
					end
				elseif check_filter(actor_table,party_table,target_table,act['category'],msg) then
					add_to_chat(dialog[forcemsg]['color'],string.char(0x1F,0xFE,0x1E,0x01)..prepstr..string.char(0x1E,0x01))
				end
			end
			
			number = nil
			if flipped then actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped) end
			local addmsg = act['targets'][i]['actions'][n]['add_effect_message']
			
			if act['targets'][i]['actions'][n]['has_add_effect'] and act['targets'][i]['actions'][n]['add_effect_message'] ~= 0 then
				if act['category'] == 1 or act['category'] == 2 or act['category'] == 3 or act['category'] == 11 or debugging then
					if addmsg == 152 or addmsg == 161 or addmsg == 162 or addmsg == 163 or addmsg == 167 or addmsg == 229 or addmsg == 384 or addmsg == 603 or addmsg == 652 or addmsg > 287 and addmsg < 303 then
						number = act['targets'][i]['actions'][n]['add_effect_param']
					else
						number = nf(statuses[act['targets'][i]['actions'][n]['add_effect_param']],'english')
						status = nf(statuses[act['targets'][i]['actions'][n]['add_effect_param']],'english')
					end
					
					if addmsg > 287 and addmsg < 303 then
						abil = skillchain_arr[addmsg-287]
					elseif addmsg > 384 and addmsg < 399 then
						abil = skillchain_arr[addmsg-384]
					elseif addmsg ==603 then
						abil = 'Treasure Hunter Level'
					else
						abil = 'Add. Eff. '
					end
										
					if condensebattle then
						add_eff_str = line_noactor
					else
						add_eff_str = dialog[addmsg]['english']
					end

					add_eff_str = add_eff_str:gsub('$\123number\125',number or ''):gsub('$\123lb\125','\7'):gsub('$\123target\125',target or ''):gsub('$\123actor\125',actor or ''):gsub('$\123abil\125',abil or ''):gsub('$\123status\125',status or '')
				end
			end
			if add_eff_str ~= nil and check_filter(actor_table,party_table,target_table,act['category'],addmsg) then
				add_to_chat(colorfilt(dialog[addmsg]['color'],target_table['is_npc'],target_table['id']==party_table['p0']['id']),string.char(0x1F,0xFE,0x1E,0x01)..add_eff_str..string.char(127,49))
			end
			
			number = nil
			if flipped then actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped) end
			local spkmsg = act['targets'][i]['actions'][n]['spike_effect_message']
			
			-- Need to add battlemod battle condensation to this --
			
			if act['targets'][i]['actions'][n]['has_spike_effect'] then -- and act['category']==1 and spkmsg ~= 0 then
				number = act['targets'][i]['actions'][n]['spike_effect_param']
				if condensebattle then
					if spkmsg > 0 then
						if spkmsg == 14 then
							abil = 'Shadow from Counter'
						elseif spkmsg == 33 or spkmsg == 606 then
							abil = 'Counter'
							actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped)
						elseif spkmsg == 592 then
							abil = 'Counter Missed'
							actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped)
						elseif spkmsg == 536 then
							abil = 'Retaliates'
							actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped)
						elseif spkmsg == 535 then
							abil = 'Shadow from Retaliation'
						else
							abil = 'Spikes'
							actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped)
						end
						
						a,b = string.find(dialog[spkmsg]['english'],'$\123number\125')
						if a then
							spike_str = line_full:gsub('$\123actor\125',actor or ''):gsub('$\123target\125',target or ''):gsub('$\123lb\125','\7'):gsub('$\123abil\125',abil or ''):gsub('$\123number\125',number or '')
						else
							spike_str = line_nonumber:gsub('$\123actor\125',actor or ''):gsub('$\123target\125',target or ''):gsub('$\123lb\125','\7'):gsub('$\123abil\125',abil or '')
						end
					end
				else
					if spkmsg > 0 then
						spike_str = dialog[spkmsg]['english']:gsub('$\123actor\125',actor or ''):gsub('$\123target\125',target or ''):gsub('$\123lb\125','\7'):gsub('$\123number\125',number or '')
					end
				end
			end
			if spike_str ~= nil and check_filter(actor_table,party_table,target_table,spkmsg) then
				add_to_chat(colorfilt(dialog[spkmsg]['color'],target_table['is_npc'],target_table['id']==party_table['p0']['id']),string.char(0x1F,0xFE,0x1E,0x01)..spike_str..string.char(127,49))
			end
			
			if flipped then actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped) end
		end
	end
	
	if aggregate and eventual_send then
		persistantmessage = persistantmessage:gsub(' gains ',' gain '):gsub(' loses ',' lose '):gsub(' receives ',' receive ')
		if targetnumber and act['target_count']>1 then
			persistanttarget = '\91'..act['target_count']..'\93 '..persistanttarget
		end
		add_to_chat(persistantcolor,string.char(0x1F,0xFE,0x1E,0x01)..persistantmessage:gsub('$\123target\125',persistanttarget or '')..string.char(127,49))
	end
end

-- Helper Functions --
function namecol(player,player_table,party_table)
	-- Used to color names based on party position/role
	-- Returns a name colored relative to color_arr
	if not player then 	player = '' end
	if player_table['is_npc']==true then
		if player_table['id']%4096>2048 then
			for i,v in pairs(party_table) do
				if nf(v['mob'],'pet_index') == player_table['index'] then
					player = color_arr[i]..player..string.char(0x1E,0x01)
					break
				end
			end
		else
			player = color_arr['mob']..player..string.char(0x1E,0x01)
		end
	else
		for i,v in pairs(party_table) do
			if nf(v['mob'],'id') == player_table['id'] then
				player = color_arr[i]..player..string.char(0x1E,0x01)
				break
			end
		end
	end
	if player~= nil then -- when you zone into an area, sometimes you can get no player value.
		if player:sub(-2,-1) ~= string.char(0x1E,0x01) then
			player = color_arr['other']..player..string.char(0x1E,0x01)
		end
	end
	return player
end

function colorfilt(col,is_npc,is_me)
	--Used to convert situational colors from the resources into real colors
	--Depends on whether the target is an NPC or player and whether it is you
	-- Returns a color code for add_to_chat()
	if col == "D" then
		if is_npc==true then
			return 20
		else
			if is_me then
				return 28
			else
				return 32
			end
		end
	elseif col == "M" then
		if is_npc==true then
			return 21
		else
			if is_me then
				return 21
			else
				return 26
			end
		end
	elseif col == "H" then
		if is_npc==true then
			return 31
		else
			if is_me then
				return 31
			else
				return 24
			end
		end
	else
		return col
	end
end

function check_filter(actor_table,party_table,target_table,category,msg)
	-- This determines whether the message should be displayed or filtered
	-- Returns true (don't filter) or false (filter), boolean
	actor_type = party_id(actor_table,party_table)
	target_type = party_id(target_table,party_table)
	
	if actor_type ~= 'monsters' then
		if filter[actor_type]['all']
		or category == 1 and filter[actor_type]['melee']
		or category == 2 and filter[actor_type]['ranged']
		or category == 12 and filter[actor_type]['ranged']
		or nf(dialog[msg],'color')=='D' and filter[actor_type]['damage']
		or nf(dialog[msg],'color')=='M' and filter[actor_type]['misses']
		or nf(dialog[msg],'color')=='H' and filter[actor_type]['healing']
		or msg == 43 and filter[actor_type]['readies'] or msg == 326 and filter[actor_type]['readies']
		or msg == 3 and filter[actor_type]['casting'] or msg == 327 and filter[actor_type]['casting']
		then
			return false
		end
	else
		if filter[actor_type][target_type]['all']
		or category == 1 and filter[actor_type][target_type]['melee']
		or category == 2 and filter[actor_type][target_type]['ranged']
		or nf(dialog[msg],'color')=='D' and filter[actor_type][target_type]['damage']
		or nf(dialog[msg],'color')=='M' and filter[actor_type][target_type]['misses']
		or nf(dialog[msg],'color')=='H' and filter[actor_type][target_type]['healing']
		or msg == 43 and filter[actor_type][target_type]['readies'] or msg == 326 and filter[actor_type][target_type]['readies']
		or msg == 3 and filter[actor_type][target_type]['casting'] or msg == 327 and filter[actor_type][target_type]['casting']
		then
			return false
		end
	end

	return true
end

function party_id(actor_table,party_table)
	-- For use in the check_filter function
	-- Returns "me", "party", "alliance", "others", "monsters", "my_pet", or "other_pets"
	local partypos, filtertype
	if actor_table['is_npc']==true then
		if actor_table['id']%4096 > 2048 then -- Pet check
			if party_table['p0']['mob']['pet_index'] == actor_table['index'] then
				filtertype = 'my_pet'
			elseif party_table['p0']['pet_index'] ~= actor_table['index'] then
				filtertype = 'other_pets'
			end
		elseif filter['monsters'] then
			filtertype = 'monsters'
		end
	else
		for i,v in pairs(party_table) do
			if nf(v['mob'],'id') == actor_table['id'] then
				partypos = i
			end
		end
		
		if not partypos then
			filtertype='others'
		elseif partypos == 'p0' then
			filtertype='me'
		elseif partypos:sub(1,1) == 'p' then
			filtertype='party'
		else
			filtertype='alliance'
		end
	end
	
	return filtertype
end

function flip(p1,p1t,p2,p2t,cond)
	return p2,p2t,p1,p1t,not cond
end