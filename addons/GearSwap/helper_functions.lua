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


-----------------------------------------------------------------------------------
--Name: parse_resources()
--Args:
---- lines_file (table of strings) - Table loaded with readlines() from an opened file
-----------------------------------------------------------------------------------
--Returns:
---- Table of subtables indexed by their id (or index).
---- Subtables contain the child text nodes/attributes of each resources line.
----
---- Child text nodes are given the key "english".
---- Attributes keyed by the attribute name, for example:
---- <a id="1500" a="1" b="5" c="10">15</a>
---- turns into:
---- completed_table[1500]['a']==1
---- completed_table[1500]['b']==5
---- completed_table[1500]['c']==10
---- completed_table[1500]['english']==15
----
---- There is also currently a field blacklist (ignore_fields) for the sake of memory bloat.
-----------------------------------------------------------------------------------
function parse_resources(lines_file)
	local find = string.find
	local ignore_fields = {}
	local convert_fields = {enl='english_log',fr='french',frl='french_log',de='german',del='german_log',jp='japanese',jpl='japanese_log'}
	local hex_fields = {jobs=true,races=true,slots=true}
	
	local completed_table = {}
	for i in ipairs(lines_file) do
		local str = tostring(lines_file[i])
		local g,h,typ,key = find(str,'<(%w+) id="(%d+)" ')
		if typ == 's' then -- Packets and .dats refer to the spell index instead of ID
			g,h,key = find(str,'index="(%d+)" ')
		end
		if key~=nil and not (typ == 's' and (tonumber(key) == 363 or tonumber(key) == 364)) then
			completed_table[tonumber(key)]={}
			local q = 1
			while q <= str:len() do
				local a,b,ind,val = find(str,'(%w+)="([^"]+)"',q)
				if ind~=nil then
					if not ignore_fields[ind]  then
						if convert_fields[ind] then
							ind = convert_fields[ind]
						end
						if val == "true" or val == "false" then
							completed_table[tonumber(key)][ind] = str2bool(val)
						elseif hex_fields[ind] then
							completed_table[tonumber(key)][ind] = tonumber('0x'..val)
						elseif tonumber(val) then
							completed_table[tonumber(key)][ind] = tonumber(val)
						else
							completed_table[tonumber(key)][ind] = val:gsub('&quot;','\42'):gsub('&apos;','\39')
						end
					end
					q = b+1
				else
					q = str:len()+1
				end
			end
			local k,v,english = find(str,'>([^<]+)</') -- Look for a Child Text Node
			if english~=nil then -- key it to 'english' if it exists
				completed_table[tonumber(key)]['english']=english
			end
		end
	end

	return completed_table
end

-----------------------------------------------------------------------------------
--Name: str2bool()
--Args:
---- input (string) - Value that might be true or false
-----------------------------------------------------------------------------------
--Returns:
---- boolean or nil. Defaults to nil if input is not true or false.
-----------------------------------------------------------------------------------
function str2bool(input)
	-- Used in the options_load() function
	if input:lower() == 'true' then
		return true
	elseif input:lower() == 'false' then
		return false
	else
		return nil
	end
end

-----------------------------------------------------------------------------------
--Name: Dec2Hex()  -- From Nitrous
--Args:
---- nValue (string or number): Value to be converted to hex
-----------------------------------------------------------------------------------
--Returns:
---- String version of the hex value.
-----------------------------------------------------------------------------------
function Dec2Hex(nValue)
	if type(nValue) == "string" then
		nValue = tonumber(nValue);
	end
	nHexVal = string.format("%X", nValue);  -- %X returns uppercase hex, %x gives lowercase letters
	sHexVal = nHexVal.."";
	return sHexVal;
end

-----------------------------------------------------------------------------------
--Name: fieldsearch()
--Args:
---- message (string): Message to be searched
-----------------------------------------------------------------------------------
--Returns:
---- Table of strings that contained {something}.
---- Seems to be trying to exclude ${actor} and ${target}, but not.
-----------------------------------------------------------------------------------
function fieldsearch(message)
	fieldarr = {}
	string.gsub(message,"{(.-)}", function(a) if a ~= '${actor}' and a ~= '${target}' then fieldarr[#fieldarr+1] = a end end)
	return fieldarr
end



-----------------------------------------------------------------------------------
--Name: strip()
--Args:
---- name (string): Name to be slugged
-----------------------------------------------------------------------------------
--Returns:
---- string with a gsubbed version of name that converts numbers to Roman numerals
-------- removes non-letter/numbers, and forces it to lower case.
-----------------------------------------------------------------------------------
function strip(name)
	return name:gsub('4','iv'):gsub('9','ix'):gsub('0','p'):gsub('3','iii'):gsub('2','ii'):gsub('1','i'):gsub('8','viii'):gsub('7','vii'):gsub('6','vi'):gsub('5','v'):gsub('[^%a]',''):lower()
end



-----------------------------------------------------------------------------------
--Name: table.reassign()
--Args:
---- targ (table): Table to be replaced
---- new (table): Table with values to transfer to the targ table
-----------------------------------------------------------------------------------
--Returns:
---- targ (table)
---- The "targ" table is blanked, and then the values from "new" are assigned to it
---- In the event that new is not passed, targ is not filled with anything.
-----------------------------------------------------------------------------------
function table.reassign(targ,new,strength)
	if new == nil then new = {} end
	if strength == true then
		for i,v in pairs(new) do
			if targ[i] == nil then targ[i] = v end
		end
	else
		for i,v in pairs(targ) do
			if not new[i] then targ[i] = nil end
		end
		for i,v in pairs(new) do
			targ[i] = v
		end
	end
	return targ
end



-----------------------------------------------------------------------------------
--Name: logit()
--Args:
---- logfile (file): File to be logged to
---- str (string): String to be logged.
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function logit(file,str)
	file:write(str)
	file:flush()
end


-----------------------------------------------------------------------------------
--Name: user_key_filter()
--Args:
---- val (key): potential key to be modified
-----------------------------------------------------------------------------------
--Returns:
---- Filtered key
-----------------------------------------------------------------------------------
function user_key_filter(val)
	if type(val) == 'string' then
		val = string.lower(val)
	end
	return val
end


-----------------------------------------------------------------------------------
--Name: make_user_table()
--Args:
---- None
-----------------------------------------------------------------------------------
--Returns:
---- Table with case-insensitive keys
-----------------------------------------------------------------------------------
function make_user_table()
	return setmetatable({}, user_data_table)
end


-----------------------------------------------------------------------------------
--Name: get_bit_packed(dat_string,start,stop)
--Args:
---- dat_string - string that is being bit-unpacked to a number
---- start - first bit
---- stop - last bit
-----------------------------------------------------------------------------------
--Returns:
---- number from the indicated range of bits 
-----------------------------------------------------------------------------------
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


-----------------------------------------------------------------------------------
--Name: get_wearable(player_val,val)
--Args:
---- player_val - Number representing the player's characteristic
---- val - Number representing the item's affinities
-----------------------------------------------------------------------------------
--Returns:
---- True (player_val exists in val) or false (anything else)
-----------------------------------------------------------------------------------
function get_wearable(player_val,val)
	if player_val then
		return ((val%(player_val*2))/player_val >= 1) -- Cut off the bits above it with modulus, then cut off the bits below it with division and >= 1
	else
		return false -- In cases where the provided playervalue is nil, just return false.
	end
end


-----------------------------------------------------------------------------------
----Name: unify_slots(g)
-- Filters the provided gear table to only known slots, and then runs a map
-- on the table to make sure all keys are the accepted versions for each.
----Args:
-- g - A dictionary table containing a gear set.
-----------------------------------------------------------------------------------
----Returns:
-- A table simplified to only acceptable slots.
-----------------------------------------------------------------------------------
function unify_slots(g)
	local g1 = table.key_filter(g, is_slot_key)
	return table.key_map(g1, get_default_slot)
end
 
-----------------------------------------------------------------------------------
----Name: is_slot_key(k)
-- Checks to see if key 'k' is known in the slot_map array.
----Args:
-- k - A key to a gear slot in a gear table.
-----------------------------------------------------------------------------------
----Returns:
-- True if the key is recognized in the slot_map table; otherwise false.
-----------------------------------------------------------------------------------
function is_slot_key(k)
	return slot_map[k]
end
 
-----------------------------------------------------------------------------------
----Name: get_default_slot(k)
-- Given a generally known slot key, return the default version of that key.
----Args:
-- k - A gear slot key.
-----------------------------------------------------------------------------------
----Returns:
-- Returns the default slot key that matches the provided key.
-----------------------------------------------------------------------------------
function get_default_slot(k)
	if slot_map[k] then
		return default_slot_map[slot_map[k]]
	end
end

-----------------------------------------------------------------------------------
----Name: set_merge(baseSet, ...)
-- Merges any additional gear sets (...) into the provided base set.
-- Ensures that only valid slot keys/elements are used in the combined set.
----Args:
-- baseSet - The set that all the other sets are combined into.  May be an empty set.
-----------------------------------------------------------------------------------
----Returns:
-- Returns the modified base set, after all other sets have been merged into it.
-----------------------------------------------------------------------------------
function set_merge(baseSet, ...)
	local combineSets = {...}

	local canCombine = table.all(combineSets, function(t) return type(t) == 'table' end)
	if not canCombine then
		-- the code that called equip() or set_combine() is #3 on the stack from here
		error("Trying to combine non-gear sets.", 3)
	end

	-- Take the list of tables we're given and cleans them up, so that they
	-- only contain acceptable slot key entries.
	local cleanSetsList = table.map(combineSets, unify_slots)

	-- Then reduce using a simple table.update function to generate a single set result.
	local combinedSet = table.reduce(cleanSetsList, table.update, baseSet)

	return combinedSet
end



-----------------------------------------------------------------------------------
--Name: assemble_action_packet(target_id,target_index,category,spell_id)
--Desc: Puts together an "action" packet (0x1A)
--Args:
---- target_id - The target's ID
---- target_index - The target's index
---- category - The action's category. (3 = MA, 7 = WS, 9 = JA, 16 = RA, 25 = MS)
---- spell_ID - The current spell's ID
-----------------------------------------------------------------------------------
--Returns:
---- string - An action packet. First four bytes are dummy bytes.
-----------------------------------------------------------------------------------
function assemble_action_packet(target_id,target_index,category,spell_id)	
	local outstr = string.char(0x1A,0x08,0,0)
	outstr = outstr..string.char( (target_id%256), math.floor(target_id/256)%256, math.floor( (target_id/65536)%256) , math.floor( (target_id/16777216)%256) )
	outstr = outstr..string.char( (target_index%256), math.floor(target_index/256)%256)
	outstr = outstr..string.char( (category%256), math.floor(category/256)%256)
	
	if category == 7 or category == 25 then
		spell_id = spell_id - 768
	end
	
	if category == 16 then
		spell_id = 0
	end
	
	outstr = outstr..string.char( (spell_id%256), math.floor(spell_id/256)%256)
	return outstr..string.char(0,0)
end



-----------------------------------------------------------------------------------
--Name: assemble_use_item_packet(target_id,target_index,item)
--Desc: Puts together a "use item" packet (0x37)
--Args:
---- target_id - The target's ID
---- target_index - The target's index
---- item_id - The id for the current item
-----------------------------------------------------------------------------------
--Returns:
---- string - A use item packet. First four bytes are dummy bytes.
-----------------------------------------------------------------------------------
function assemble_use_item_packet(target_id,target_index,item_id)
	local outstr = string.char(0x37,0x0A,0,0)
	outstr = outstr..string.char( (target_id%256), math.floor(target_id/256)%256, math.floor( (target_id/65536)%256) , math.floor( (target_id/16777216)%256) )
	outstr = outstr..string.char(0,0,0,0)
	outstr = outstr..string.char( (target_index%256), math.floor(target_index/256)%256)
	inventory_index,bag_id = find_usable_item(item_id)
	if inventory_index then
		outstr = outstr..string.char(inventory_index%256)..string.char(0,bag_id,0,0,0)
	else
		debug_mode_chat('Proposed item: '..(r_items[item_id][language] or item_id)..' not found in inventory.')
		return
	end
	return outstr
end



-----------------------------------------------------------------------------------
--Name: assemble_menu_item_packet(target_id,target_index,item)
--Desc: Puts together a "menu item" packet (0x36)
--Args:
---- target_id - The target's ID
---- target_index - The target's index
---- item_id - The id for the current item
-----------------------------------------------------------------------------------
--Returns:
---- string - A use item packet. First four bytes are dummy bytes.
-----------------------------------------------------------------------------------
function assemble_menu_item_packet(target_id,target_index,item_id)
	local outstr = string.char(0x36,0x20,0,0)
	-- Target ID
	outstr = outstr..string.char( (target_id%256), math.floor(target_id/256)%256, math.floor( (target_id/65536)%256) , math.floor( (target_id/16777216)%256) )
	-- One unit traded
	outstr = outstr..string.char(1,0,0,0,0,0,0,0)..string.char(0,0,0,0,0,0,0,0)..string.char(0,0,0,0,0,0,0,0)..
		string.char(0,0,0,0,0,0,0,0)..string.char(0,0,0,0,0,0,0,0)
	-- Inventory Index for the one unit
	inventory_index,bag_id = find_usable_item(item_id)
	if inventory_index then
		outstr = outstr..string.char(inventory_index%256)
	else
		debug_mode_chat('Proposed item: '..(r_items[item_id][language] or item_id)..' not found in inventory.')
		return
	end
	-- Nothing else being traded
	outstr = outstr..string.char(0,0,0,0,0,0,0,0,0)
	-- Target Index
	outstr = outstr..string.char( (target_index%256), math.floor(target_index/256)%256)
	-- Only one item being traded
	outstr = outstr..string.char(1,0,0,0)
	return outstr
end



-----------------------------------------------------------------------------------
--Name: find_usable_item(item_id)
--Desc: Finds a usable item in temporary or normal inventory. Assumes items array
--      is accurate already.
--Args:
---- item_id - The resource line for the current item
-----------------------------------------------------------------------------------
--Returns:
---- inventory_index - The item's use inventory index (if it exists)
---- bag_id - The item's bag ID (if it exists)
-----------------------------------------------------------------------------------
function find_usable_item(item_id)
	local inventory_index,bag_id
	for i,v in pairs(items.temporary) do
		if v and v.id == item_id then
			inventory_index = i
			bag_id = 3
			break
		end
	end
	if not inventory_index then
		for i,v in pairs(items.inventory) do
			if v and v.id == item_id then
				inventory_index = i
				bag_id = 0
				break
			end
		end
	end
	return inventory_index,bag_id
end



-----------------------------------------------------------------------------------
--Name: filter_pretarget(spell)
--Desc: Determines whether the current player is capable of using the proposed spell
----    at pretarget.
--Args:
---- spell - current spell table
-----------------------------------------------------------------------------------
--Returns:
---- false to cancel further command processing and just return the command.
-----------------------------------------------------------------------------------
function filter_pretarget(spell)
	local category,spell_id = outgoing_action_category_table[unify_prefix[spell.prefix]]
	if category == 3 then
		spell_id = spell.index
		local available_spells = windower.ffxi.get_spells()
		-- filter for spells that you do not know
		if not available_spells[spell_id] and not (spell_id == 503 and player.equipment.body:lower() == 'twilight cloak') then
			debug_mode_chat("Unable to execute command. You do not know that spell ("..(r_spells[spell_id][language] or spell.id)..")")
			return false
		end
	else
		spell_id = spell.id
		if (category == 7 or category == 9) and not windower.ffxi.get_abilities()[spell_id] then
			debug_mode_chat("Unable to execute command. You do not have access to that ability ("..(r_abilities[spell_id][language] or spell_id)..")")
			return false
		end
	end
	
	
	if spell.type == 'BlueMagic' and player.main_job ~= 'BLU' and player.sub_job ~= 'BLU' then
		return false
	elseif spell.type == 'Ninjutsu'  then
		if player.main_job ~= 'NIN' and player.sub_job ~= 'NIN' then
			debug_mode_chat("Unable to make action packet. You do not have access to that spell ("..(spell[language] or spell_id)..")")
			return false
		elseif not player.inventory[tool_map[spell.english]] and not (player.main_job == 'NIN' and player.inventory[universal_tool_map[spell.english]]) then
			debug_mode_chat("Unable to make action packet. You do not have the proper tools.")
			return false
		end
	end
	
	return true
end


-----------------------------------------------------------------------------------
--Name: filter_precast(spell)
--Desc: Determines whether the current player is capable of using the proposed spell
----    at precast.
--Args:
---- spell - current spell table
-----------------------------------------------------------------------------------
--Returns:
---- false to block the outgoing packet
-----------------------------------------------------------------------------------
function filter_precast(spell)
	if not spell.target.id or not spell.target.index then
		if debugging >= 1 then windower.add_to_chat(8,'No target id or index') end
		return false
	end
	return true
end



-----------------------------------------------------------------------------------
--Name: mk_command_registry_entry(sp)
--Desc: Makes a new entry in command_registry.
--Args:
---- sp - Resources line for the current spell
-----------------------------------------------------------------------------------
--Returns:
---- ts - index for command_registry
-----------------------------------------------------------------------------------
function mk_command_registry_entry(sp)
	local ts = os.time()
	remove_old_command_registry_entries(ts)
	while command_registry[ts] do
		ts = ts+0.001
	end
	command_registry[ts] = {}
	command_registry[ts].cast_delay = 0
	command_registry[ts].spell = sp
	if debugging >= 2 then
		windower.add_to_chat(8,'GearSwap (Debug Mode): Creating a new command_registry entry: '..tostring(ts)..' '..tostring(command_registry[ts]))
	end
	return ts
end



-----------------------------------------------------------------------------------
--Name: remove_old_command_registry_entries(ts)
--Desc: Removes all command_registry entries more than 20 seconds old.
--Args:
---- ts - The current time, as obtained from os.time()
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function remove_old_command_registry_entries(ts)
	for i,v in pairs(command_registry) do
		if ts-i >= 20 then
			command_registry[i] = nil
		end
	end
end



-----------------------------------------------------------------------------------
--Name: find_command_registry_key(typ,value)
--Desc: Returns the proper unified prefix, or "Mosnter " in the case of a monster action
--Args:
---- typ - 'spell', 'timestamp', or 'id'
---- value - The spell, timestamp, or id
---- Currently the ID and Timestamp options are unused.
-----------------------------------------------------------------------------------
--Returns:
---- timestamp index of command_registry
-----------------------------------------------------------------------------------
function find_command_registry_key(typ,value)
	if typ == 'spell' then
		-- Finds all entries of a given spell in the table.
		-- Returns the one with the most recent timestamp.
		-- Actions that do not have timestamps yet (have not hit midcast) are given lowest priority.
		local potential_entries,current_time,winner,winning_ind = {},os.time()
		for i,v in pairs(command_registry) do
			if v.spell and v.spell.prefix == value.prefix and v.spell.name == value.name then
				potential_entries[i] = v.timestamp or 0
			end
		end
		for i,v in pairs(potential_entries) do
			if not winner or (current_time - v < current_time - winner) then
				winner = v
				winning_ind = i
			end
		end
		return winning_ind
	elseif typ == 'timestamp' then
		for i,v in pairs(command_registry) do
			if v.index_timestamp == value then
				return i
			end
		end
	elseif typ == 'id' then
		for i,v in pairs(command_registry) do
			if v.spell and v.spell.target and value == v.spell.target.id then
				return i
			end
		end
	end
end



-----------------------------------------------------------------------------------
--Name: get_prefix(pref)
--Desc: Returns the proper unified prefix, or "Mosnter " in the case of a monster action
--Args:
---- pref - Prefix to match (or nil, for monster TP moves)
-----------------------------------------------------------------------------------
--Returns:
---- unified prefix (or Monster)
-----------------------------------------------------------------------------------
function get_prefix(pref)
	if not pref then
		return 'Monster '
	else
		return unify_prefix[pref]
	end
end


-----------------------------------------------------------------------------------
--Name: find_command_registry_by_time()
--Desc: Finds the most recent command_registry entry
--Args:
---- target - 'player' or 'pet'
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function find_command_registry_by_time(target)
	local time_stamp,ts
	local time_now = os.time()
	
	-- Iterate over command_registry looking for the spell with the closest timestamp
	-- possible that matches the target type.
	-- Call aftercast with this spell's information (interrupted) if one is found.
	for i,v in pairs(command_registry) do
		if not time_stamp or (v.timestamp and ((time_now - v.timestamp) < (time_now - time_stamp))) then -- (target == 'player' and v.midaction or target=='pet' and v.pet_midaction) and v.timestamp and 
			time_stamp = v.timestamp
			ts = i
		end
	end
	if time_stamp then
		return ts,table.reassign({},command_registry[ts])
	end
end



-----------------------------------------------------------------------------------
--Name: delete_command_registry_by_id(id)
--Desc: Deletes all command_registry entry based that match a given target ID.
--Args:
---- id - ID of the target
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function delete_command_registry_by_id(id)
	local ts,last_tab
	for i,v in pairs(command_registry) do
		if v.spell and v.spell.target then
			if v.spell.target.id == id then
				last_tab = table.reassign({},command_registry[i])
				ts = i
				command_registry[i] = nil
			end
		end
	end
	return ts,last_tab
end



-----------------------------------------------------------------------------------
--Name: get_spell(act)
--Desc: Takes an action table and returns a modified resource line
--Args:
---- act - action table in the same format as event_action
-----------------------------------------------------------------------------------
--Returns:
---- spell - Resource line of the current spell
-----------------------------------------------------------------------------------
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
		elseif msg_ID == 328 then
			spell = r_abilities[effect_val] -- BPs that are out of range
		end
		
		
		if table.contains(fields,'item') then
			spell = r_items[abil_ID]
		else
			spell = aftercast_cost(spell)
		end
	end
		
	spell.name = spell[language]
	spell.interrupted = false
	
	return spell
end



-----------------------------------------------------------------------------------
--Name: aftercast_cost(rline)
--Desc: Takes a resource line and modifies it so it includes aftercast cost and
--      a few other values
--Args:
---- rline - resource line
-----------------------------------------------------------------------------------
--Returns:
---- rline - modified resource line
-----------------------------------------------------------------------------------
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



-----------------------------------------------------------------------------------
--Name: debug_mode_chat(message)
--Desc: Checks _settings.debug_mode and outputs the message if necessary
--Args:
---- message - The debug message
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function debug_mode_chat(message)
	if _settings.debug_mode then
		windower.add_to_chat(8,"GearSwap (Debug Mode): "..message)
	end
end