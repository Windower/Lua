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


function event_action(act)
	local persistantmessage,persistanttarget = '',''
	local persistantcolor = 1
	local aggregate = false
	local eventual_send = false
	
	local party_table = get_party()
	local actor_table = get_mob_by_id(act['actor_id'])
	local actor = actor_table['name']
	if actor == nil then return end
	actor = namecol(actor,actor_table,party_table)
	
	
	if agg_messages:contains(act['targets'][1]['actions'][1]['message']) and condensebuffs then
		aggregate = true -- checks if the first message is one of the multi-target indicating messages
		local messages = {}
		for n,m in pairs(act['targets']) do
			local msg = act['targets'][n]['actions'][1]['message']
			if condensebattle then
				for i,v in pairs(message_map) do
					if table.contains(message_map[i],msg) then
						act['targets'][n]['actions'][1]['message'] = i
						msg = i
					end
				end
				if msg == 'No effect' then
					msg = no_effect_map[act['category']]
					act['targets'][n]['actions'][1]['message'] = msg
				elseif msg == 'Receives' then
					msg = receives_map[act['category']]
					act['targets'][n]['actions'][1]['message'] = msg
				end
			end
			local target_table = get_mob_by_id(act['targets'][n]['id'])
			if messages[msg] then
				if check_filter(actor_table,party_table,target_table,act['category'],msg) then
					local address = messages[msg]['address']
					act['targets'][address]['count'] = act['targets'][address]['count'] + 1
				end
			else
				messages[msg] = {}
				messages[msg]['address'] = n
				act['targets'][n]['count'] = 1
			end
		end
		
		for n,m in pairs(act['targets']) do
			local target_table = get_mob_by_id(act['targets'][n]['id'])
			local target = target_table['name']
			target = namecol(target,target_table,party_table)
			
			local msg = act['targets'][n]['actions'][1]['message']
			if messages[msg]['address'] ~= n then
				if check_filter(actor_table,party_table,target_table,act['category'],msg) then
					local address = messages[msg]['address']
					act['targets'][address]['count2'] = act['targets'][address]['count2'] + 1
					act['targets'][address]['target'] = conjunctions(act['targets'][address]['target'],target,act['targets'][address]['count'],act['targets'][address]['count2'])
					act['targets'][n]['actions'][1]['message'] = 0
				end
			else
				if act['targets'][n]['count'] > 1 then
					act['targets'][n]['target'] = '['..act['targets'][n]['count']..'] '..target
				else
					act['targets'][n]['target'] = target
				end
				act['targets'][n]['count2'] = 1
			end
		end
	end

	for i,v in pairs(act['targets']) do
	
		if condensedamage then
			local messages = {}
			local addmessages = {}
			local spikemessages = {}
			for n,m in pairs(act['targets'][i]['actions']) do
				local msg = act['targets'][i]['actions'][n]['message']
				if messages[msg] then
					local address = messages[msg]['address']
					act['targets'][i]['actions'][address]['param'] = act['targets'][i]['actions'][address]['param'] + act['targets'][i]['actions'][n]['param']
					act['targets'][i]['actions'][address]['count'] = act['targets'][i]['actions'][address]['count'] + 1
					act['targets'][i]['actions'][n]['message'] = 0
				else
					messages[msg] = {}
					messages[msg]['address'] = n
					act['targets'][i]['actions'][n]['count'] = 1
				end
				
				local addmsg = act['targets'][i]['actions'][n]['add_effect_message']
				if addmessages[addmsg] then
					local address = addmessages[addmsg]['address']
					act['targets'][i]['actions'][address]['add_effect_param'] = act['targets'][i]['actions'][address]['add_effect_param'] + act['targets'][i]['actions'][n]['add_effect_param']
					act['targets'][i]['actions'][address]['addcount'] = act['targets'][i]['actions'][address]['addcount'] + 1
					act['targets'][i]['actions'][n]['add_effect_message'] = 0
				else
					addmessages[addmsg] = {}
					addmessages[addmsg]['address'] = n
					act['targets'][i]['actions'][n]['addcount'] = 1
				end
				
				local spikemsg = act['targets'][i]['actions'][n]['spike_effect_message']
				if spikemessages[spikemsg] then
					local address = spikemessages[spikemsg]['address']
					act['targets'][i]['actions'][address]['spike_effect_param'] = act['targets'][i]['actions'][address]['spike_effect_param'] + act['targets'][i]['actions'][n]['spike_effect_param']
					act['targets'][i]['actions'][address]['spikecount'] = act['targets'][i]['actions'][address]['spikecount'] + 1
					act['targets'][i]['actions'][n]['spike_effect_message'] = 0
				else
					spikemessages[spikemsg] = {}
					spikemessages[spikemsg]['address'] = n
					act['targets'][i]['actions'][n]['spikecount'] = 1
				end
			end
		end
		
		for n,m in pairs(act['targets'][i]['actions']) do
			local prepstr,abil,add_eff_str,spike_str,wsparm,status,number,gil,abil_ID,effect_val,msg_ID
			local spell,ability,weapon_skill,item,target_table,target
			
			target_table = get_mob_by_id(act['targets'][i]['id'])

			local flipped = false
			if act['category'] == 6 and act['param'] > 140 and act['param'] < 149 then -- Force a message for maneuvers.
				msg_ID = 100
			elseif check_filter(actor_table,party_table,target_table,act['category'],act['targets'][i]['actions'][n]['message']) then
				msg_ID = act['targets'][i]['actions'][n]['message']
			else
				msg_ID = 0
			end
			
			if aggregate then
				target = act['targets'][i]['target']
			else
				target = target_table['name']
				target = namecol(target,target_table,party_table)
			end
			
			if nf(dialog[msg_ID],'english') then
				if act['category'] == 1 then -- Melee swings
					if msg_ID == 30 then abil = 'Anticipates'
						actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped)
					elseif  act['targets'][i]['actions'][n]['reaction'] == 12 then abil = 'Block'
						effect_val = act['targets'][i]['actions'][n]['param']
					elseif msg_ID == 1 then abil = 'Hit'
						effect_val = act['targets'][i]['actions'][n]['param']
					elseif msg_ID == 15 then abil = 'Miss'
					elseif msg_ID == 282 then abil = 'Evades'
						actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped)
					elseif msg_ID == 32 then abil = 'Dodges'
						actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped)
					elseif msg_ID == 106 then abil = 'Intimidates'
						actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped)
					elseif msg_ID == 31 then abil = 'Disappears'
						actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped)
						effect_val = act['targets'][i]['actions'][n]['param']
					elseif act['targets'][i]['actions'][n]['reaction'] == 11 then
						abil = 'Parries'
						actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped)
					elseif msg_ID == 67 then abil = 'Crit'
						effect_val = act['targets'][i]['actions'][n]['param']
					elseif msg_ID == 373 then abil = 'Absorbs'
						effect_val = act['targets'][i]['actions'][n]['param']
					elseif debugging and not act['targets'][i]['actions'][n]['has_spike_effect'] then
						effect_val = act['targets'][i]['actions'][n]['param']
						write('debug_cat1: '..act['targets'][i]['actions'][n]['param']..' '..msg_ID)
					end
					if abil and condensedamage and act['targets'][i]['actions'][n]['count'] ~= 1 then
						abil = abil..' ['..act['targets'][i]['actions'][n]['count']..']'
					end
				elseif act['category'] == 2 then -- Ranged attacks
					effect_val = act['targets'][i]['actions'][n]['param']
					if msg_ID == 352 then abil = 'RA'
					elseif msg_ID == 353 then abil = 'Crit RA'
					elseif msg_ID == 354 then abil = 'RA Misses'
						effect_val = nil
					elseif msg_ID == 576 then abil = 'RA Hits Squarely'
					elseif msg_ID == 577 then abil = 'RA Strikes True'
					elseif msg_ID == 157 then abil = 'Barrage'
					elseif msg_ID == 77 then abil = 'Sange'
					end
				elseif T{7,8,9}:contains(act['category']) then -- 12 and 10 don't really count because their params are meaningless. 1 and 2 need manual ability sorting
					abil_ID = act['targets'][i]['actions'][n]['param']
				elseif T{3,4,5,6,11,13,14,15}:contains(act['category']) then
					abil_ID = act['param']
					effect_val = act['targets'][i]['actions'][n]['param']
				end
				
				local fields = fieldsearch(dialog[msg_ID]['english'])
				
				if table.contains(fields,'spell') then
					spell = spells[abil_ID]['english']
					if T{252,265,268,269,271,272,274,275,650}:contains(msg_ID) then
						spell = 'Magic Burst '..spell
					end
					spell = color_it(spell,color_arr['spellcol'])
				elseif table.contains(fields,'ability') then
					ability = jobabilities[abil_ID]['english']
					if msg_ID == 379 then ability = 'Magic Burst '..ability end
					ability = color_it(ability,color_arr['abilcol'])
				elseif table.contains(fields,'item') then
					item = color_arr['itemcol']..items[abil_ID]['enl']..rcol
				elseif table.contains(fields,'weapon_skill') then
					if abil_ID > 255 and abil_ID ~= 1531 then -- WZ_RECOVER_ALL is used by chests in Limbus
						weapon_skill = mabils[abil_ID-256]['english']
						if weapon_skill == '.' then
							weapon_skill = 'Special Attack'
						end
					elseif abil_ID < 256 then
						weapon_skill = jobabilities[abil_ID+768]['english']
					end
					if msg_ID == 188 then
						weapon_skill = weapon_skill..' (Miss)'
					elseif msg_ID == 189 then
						weapon_skill = weapon_skill..' (No Effect)'
					end
					if actor_table['is_npc'] then
						weapon_skill = color_it(weapon_skill or '',color_arr['mobwscol'])
					else
						weapon_skill = color_it(weapon_skill or '',color_arr['wscol'])
					end
				elseif msg_ID == 303 then
					ability = 'Divine Seal'
				elseif msg_ID == 304 then
					ability = 'Elemental Seal'
				elseif msg_ID == 305 then
					ability = 'Trick Attack'
				elseif msg_ID == 311 then
					ability = 'Cover'
				elseif msg_ID == 312 then
					ability = 'Cover (No Effect)'
				elseif msg_ID == 241 then
					ability = 'Hide'
				elseif msg_ID == 240 then
					ability = 'Hide (Fail)'
				end
				
				if abil_ID == 53 and act['category'] == 6 then -- Gauge handling
					if msg_ID == 210 then ability = 'Gauge (Cannot charm - '
					elseif msg_ID == 211 then ability = 'Gauge (Very Difficult - '
					elseif msg_ID == 212 then ability = 'Gauge (Difficult - '
					elseif msg_ID == 213 then ability = 'Gauge (Might be able - '
					elseif msg_ID == 214 then ability = 'Gauge (Should be able - '
					end
					ability = ability..effect_val..')'
				end
				

				if table.contains(fields,'status') then
					if act['targets'][i]['actions'][n]['param'] == 0 or act['targets'][i]['actions'][n]['param'] == 255 then
						status = color_it('No effect',color_arr['statuscol'])
					elseif enfeebling:contains(act['targets'][i]['actions'][n]['param']) then
						status = color_it(statuses[effect_val]['english'],color_arr['enfeebcol'])
					else -- status = color_it((enLog[effect_val] or statuses[effect_val]['english']),color_arr['statuscol'])
						status = color_it(statuses[effect_val]['english'],color_arr['statuscol'])
					end
				elseif table.contains(fields,'number') then
					number = effect_val
					if dialog[msg_ID]['units'] and condensebattle then
						number = number..' '..dialog[msg_ID]['units']
					end
				elseif not item and table.contains(fields,'item') then
					item = color_it(items[effect_val]['enl'],color_arr['itemcol'])
				elseif table.contains(fields,'item2') then -- For when you use an item to obtain items i.e. Janus Guard
					item2 = color_it(items[effect_val]['enl'],color_arr['itemcol'])
				elseif table.contains(fields,'gil') then
					gil = effect_val..' gil'
				end
				
				-- Special Message Handling
				if msg_ID == 93 or msg_ID == 273 then
					status=color_it('Vanish',color_arr['statuscol'])
				elseif msg_ID == 522 and condensebattle then
					target = target..' (stunned)'
				elseif T{158,188,245,324,592,658}:contains(msg_ID) and condensebattle then
					-- When you miss a WS or JA. Relevant for condensed battle.
					number = 'Miss' --- This probably doesn't work due to the if a==nil statement below.
				elseif msg_ID == 653 or msg_ID == 654 then
					status = color_it('Immunobreak',color_arr['statuscol'])
				elseif msg_ID == 655 or msg_ID == 656 then
					status = color_it('Completely Resists',color_arr['statuscol'])
				elseif msg_ID == 85 or msg_ID == 284 then
					status = color_it('Resists',color_arr['statuscol'])
				elseif msg_ID == 674 then -- Scavenge
					number = act['targets'][i]['actions'][n]['add_effect_param']..' '..color_it(items[effect_val]['enl'],color_arr['itemcol'])
				elseif T{75,156,189,248,283,312,323,336,355,408,422,423,425,659}:contains(msg_ID) then
					status = color_it('No effect',color_arr['statuscol']) -- The status code for "No Effect" is 255, so it might actually work without this line
				end
			
				-- Sets the common field "abil" based on the applicable abilities.
				-- Only one should be valid at any given time.
				if not abil then
					abil = weapon_skill or ability or spell or item
				end
				
				if msg_ID ~= 0 then
					if dialog[msg_ID]['color'] == 'M' or dialog[msg_ID]['color'] == 'D' or dialog[msg_ID]['color'] == 'H' or act['targets'][i]['actions'][n]['reaction'] == 11 or act['targets'][i]['actions'][n]['reaction'] == 12 or msg_ID == 31 or msg_ID == 32 or T{6,7,8,9,14,15}:contains(act['category']) or aggregate then
						-- Misses, Damage, Healing, Parrying, Dodge, Guard/Block, and Utsusemi
						-- Handles for Category 1,2,3,4,6, and 14
						a,b = string.find(dialog[msg_ID]['english'],'$\123number\125')
						if a == nil and type(number) ~= string then -- Distinguishes between Status effects and Damage/Healing.
							number = nil
						end
						if condensebattle then
							-- TEST REMOVAL
							--if not abil then abil = 'AoE' end
							
							if T{'Steal','Despoil','Scavenge','Mug'}:contains(abil) then
								prepstr = dialog[msg_ID]['english']
							elseif msg_ID>419 and msg_ID<430 then
								if act['targets'][i]['actions'][n]['param'] == 12 then -- Bust is always 12
									number = 'Bust!'
								end
								prepstr = line_roll
							elseif abil and number and target and actor then
								prepstr = line_full
							elseif abil and status and target and actor then
								prepstr = line_aoebuff
							elseif not number then
								prepstr = line_nonumber
							elseif not actor then
								prepstr = line_noactor
							elseif not abil then
								prepstr = line_noabil -- TEST STATEMENT
							end
						else -- Handles exceptions and people that don't condense battle messages
							prepstr = dialog[msg_ID]['english']
						end
					elseif dialog[msg_ID] then -- Default case?
						prepstr = dialog[msg_ID]['english']
					end
				end
				
				-- Avoid nil field errors using " or ''" with all the gsubs.
				-- Construct the message to be sent out --
				if prepstr and check_filter(actor_table,party_table,target_table,act['category'],msg_ID) then
					prepstr = prepstr:gsub('$\123lb\125','\7'):gsub('$\123actor\125',actor or ''):gsub('$\123spell\125',spell or ''):gsub('$\123ability\125',ability or ''):gsub('$\123abil\125',abil or ''):gsub('$\123number\125',number or ''):gsub('$\123weapon_skill\125',weapon_skill or ''):gsub('$\123status\125',status or ''):gsub('$\123item\125',item or ''):gsub('$\123item2\125',item2 or ''):gsub('$\123gil\125',gil or '')
					add_to_chat(colorfilt(dialog[msg_ID]['color'],target_table['id']==party_table['p0']['mob']['id']),string.char(0x1F,0xFE,0x1E,0x01)..prepstr:gsub('$\123target\125',target or '')..string.char(127,49))
				end
			end
			
			
			number = nil
			if flipped then actor,actor_table,target,target_table,flipped = flip(actor,actor_table,target,target_table,flipped) end
			local addmsg = act['targets'][i]['actions'][n]['add_effect_message']
			
			if act['targets'][i]['actions'][n]['has_add_effect'] and act['targets'][i]['actions'][n]['add_effect_message'] ~= 0 then
				if act['category'] == 1 or act['category'] == 2 or act['category'] == 3 or act['category'] == 4 or act['category'] == 11 then
					if T{152,161,162,163,167,229,603,652}:contains(addmsg) or addmsg > 287 and addmsg < 303 or addmsg > 383 and addmsg < 399 then
						number = act['targets'][i]['actions'][n]['add_effect_param']
					else
						number = enLog[act['targets'][i]['actions'][n]['add_effect_param']] or nf(statuses[act['targets'][i]['actions'][n]['add_effect_param']],'english')
						status = enLog[act['targets'][i]['actions'][n]['add_effect_param']] or nf(statuses[act['targets'][i]['actions'][n]['add_effect_param']],'english')
					end
							
					if condensebattle then
						add_eff_str = line_noactor
						if addmsg > 287 and addmsg < 303 then
							abil = skillchain_arr[addmsg-287]
						elseif addmsg > 384 and addmsg < 399 then
							abil = skillchain_arr[addmsg-384]
						elseif addmsg ==603 then
							abil = 'TH'
						else
							abil = 'AE'
						end
						if abil and condensedamage and act['category'] == 1 and act['targets'][i]['actions'][n]['addcount'] ~= 1 then abil = abil..' ['..act['targets'][i]['actions'][n]['addcount']..']' end
					else
						add_eff_str = dialog[addmsg]['english']
					end

					add_eff_str = add_eff_str:gsub('$\123number\125',number or ''):gsub('$\123lb\125','\7'):gsub('$\123target\125',target or ''):gsub('$\123actor\125',actor or ''):gsub('$\123abil\125',abil or ''):gsub('$\123status\125',status or '')
				end
			end
			if add_eff_str ~= nil and check_filter(actor_table,party_table,target_table,act['category'],addmsg) then
				add_to_chat(colorfilt(dialog[addmsg]['color'],target_table['id']==party_table['p0']['mob']['id']),string.char(0x1F,0xFE,0x1E,0x01)..add_eff_str..string.char(127,49))
			end
			
			number = nil
			local spkmsg = act['targets'][i]['actions'][n]['spike_effect_message']
			
			if act['targets'][i]['actions'][n]['has_spike_effect'] then
				if act['category']==1 and spkmsg ~= 0 then
				number = act['targets'][i]['actions'][n]['spike_effect_param']
				if condensebattle then
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
					if abil and condensedamage and act['targets'][i]['actions'][n]['spikecount'] ~= 1 then abil = abil..' ['..act['targets'][i]['actions'][n]['spikecount']..']' end
					
					a,b = string.find(dialog[spkmsg]['english'],'$\123number\125')
					if a then
						spike_str = line_full:gsub('$\123actor\125',actor or ''):gsub('$\123target\125',target or ''):gsub('$\123lb\125','\7'):gsub('$\123abil\125',abil or ''):gsub('$\123number\125',number or '')
					else
						spike_str = line_nonumber:gsub('$\123actor\125',actor or ''):gsub('$\123target\125',target or ''):gsub('$\123lb\125','\7'):gsub('$\123abil\125',abil or '')
					end
				else
					spike_str = dialog[spkmsg]['english']:gsub('$\123actor\125',actor or ''):gsub('$\123target\125',target or ''):gsub('$\123lb\125','\7'):gsub('$\123number\125',number or '')
				end
				end
			end
			if spike_str ~= nil and check_filter(actor_table,party_table,target_table,act['category'],spkmsg) then
				add_to_chat(colorfilt(dialog[spkmsg]['color'],target_table['id']==party_table['p0']['mob']['id']),string.char(0x1F,0xFE,0x1E,0x01)..spike_str..string.char(127,49))
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
		if player_table['id']%4096>2047 then
			for i,v in pairs(party_table) do
				if nf(v['mob'],'pet_index') == player_table['index'] then
					player = color_it(player,color_arr[i])
					break
				end
			end
		else
			player = color_arr['mob']..player..rcol
		end
	else
		for i,v in pairs(party_table) do
			if nf(v['mob'],'id') == player_table['id'] then
				player = color_it(player,color_arr[i])
				break
			end
		end
	end
	if player~= nil then -- when you zone into an area, sometimes you can get no player value.
		if player:sub(-2,-1) ~= rcol then
			player = color_it(player,color_arr['other'])
		end
	end
	return player
end

function colorfilt(col,is_me)
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

function check_filter(actor_table,party_table,target_table,category,msg)
	-- This determines whether the message should be displayed or filtered
	-- Returns true (don't filter) or false (filter), boolean
	actor_type = party_id(actor_table,party_table)
	target_type = party_id(target_table,party_table)
	
	if filter[target_type]['target'] then return true end
	
	if actor_type ~= 'monsters' and actor_type ~= 'enemies' then
		if filter[actor_type]['all']
		or category == 1 and filter[actor_type]['melee']
		or category == 2 and filter[actor_type]['ranged']
		or category == 12 and filter[actor_type]['ranged']
		or category == 5 and filter[actor_type]['items']
		or category == 9 and filter[actor_type]['uses']
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
		or category == 12 and filter[actor_type]['ranged']
		or category == 5 and filter[actor_type]['items']
		or category == 9 and filter[actor_type]['uses']
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
		if actor_table['id']%4096 > 2047 then -- Pet check
			if party_table['p0']['mob']['pet_index'] == actor_table['index'] then
				filtertype = 'my_pet'
			elseif party_table['p0']['mob']['pet_index'] ~= actor_table['index'] then
				filtertype = 'other_pets'
			end
		elseif filter['enemies'] ~= nil then -- For people without xmls that include enemies
			filtertype = 'monsters'
			for i,v in pairs(party_table) do
				if actor_table['claim_id'] == v['id'] then
					filtertype = 'enemies'
				end
			end
		else
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

function fieldsearch(message)
	fieldarr = {}
	string.gsub(message,"{(.-)}", function(a) if a ~= '${actor}' and a ~= '${target}' then fieldarr[#fieldarr+1] = a end end)
	return fieldarr
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