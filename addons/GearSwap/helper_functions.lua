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
		if key~=nil then
			completed_table[tonumber(key)]={}
			local q = 1
			while q <= str:len() do
				local a,b,ind,val = find(str,'(%w+)="([^"]+)"',q)
				if ind~=nil then
					if not ignore_fields[ind] then
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
--Desc: Puts together an action packet using one weird old trick!
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
	if not target_id then
		windower.add_to_chat(8,'No target id?')
		return
	end
	if not target_index then
		windower.add_to_chat(8,'No target index?')
		return
	end
	local outstr = string.char(0x1A,0x08,0,0)
	outstr = outstr..string.char( (target_id%256), math.floor(target_id/256)%256, math.floor( (target_id/65536)%256) , math.floor( (target_id/16777216)%256) )
	outstr = outstr..string.char( (target_index%256), math.floor(target_index/256)%256)
	outstr = outstr..string.char( (category%256), math.floor(category/256)%256)

	if (category == 7 or category == 9) and not windower.ffxi.get_abilities()[spell_id] then
		--windower.add_to_chat(123,"GearSwap: Unable to make action packet. You do not have access to that ability ("..spell_id..")")
		return
	end
	
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
--Desc: Puts together an action packet using one weird old trick!
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
		return
	end
	return outstr
end



-----------------------------------------------------------------------------------
--Name: assemble_use_item_packet(target_id,target_index,item)
--Desc: Puts together an action packet using one weird old trick!
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
			bag_id = 4
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
--Name: mk_out_arr_entry(sp,arr,original)
--Desc: Makes a new entry in out_arr or updates an old one's "data" field.
--Args:
---- sp - Resources line for the current spell
---- arr - table containing a "target_id" field that is the spell's target_id or nil
---- original - outgoing packet string (or nil in pretarget)
-----------------------------------------------------------------------------------
--Returns:
---- inde - key for out_arr
-----------------------------------------------------------------------------------
function mk_out_arr_entry(sp,arr,original)
	local inde = get_prefix(spell.prefix)..' "'..spell.english..'"'
	if out_arr[inde..' '..tostring(arr.target_id)] then
		inde = inde..' '..tostring(arr.target_id)
		out_arr[inde].data = original
		out_arr[inde].spell.target = sp.target
	elseif out_arr[inde..' nil'] then
		inde = inde..' nil'
		out_arr[inde].data = original
		out_arr[inde].spell.target = sp.target
	elseif out_arr[inde..' '..player.id] then
		inde = inde..' '..player.id
		out_arr[inde].data = original
		out_arr[inde].spell.target = sp.target
	else
		if debugging >= 2 then windower.add_to_chat(8,'GearSwap (Debug Mode): Creating a new out_arr entry: '..tostring(inde)..' '..tostring(arr.target_id)) end
		inde = inde..' '..tostring(arr.target_id)
		out_arr[inde] = {}
		out_arr[inde].data = original
		out_arr[inde].cast_delay = 0
		out_arr[inde].spell = sp
	end
	return inde
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
--Name: d_out_arr_entry(sp,ind)
--Desc: Deletes an entry from out_arr.
--Args:
---- sp - Resources line for the current spell (at the end of aftercast)
---- ind - Proposed index of out_arr
-----------------------------------------------------------------------------------
--Returns:
---- None
-----------------------------------------------------------------------------------
function d_out_arr_entry(sp,ind)
	if ind == true then -- ambiguous case
		local deletion_table = {}
		for i,v in pairs(out_arr) do
			if v.midaction then
				deletion_table[i] = true
			end
		end
		for i,v in pairs(deletion_table) do
			out_arr[i] = nil
		end
	elseif not sp.english then
		windower.add_to_chat(123,'Spell.english is nil in helper_functions at line 548! Tell Byrth what you were doing!')
	elseif ind == get_prefix(sp.prefix)..' "'..sp.english..'"' then
		if out_arr[ind..' '..tostring(sp.target.id)] then
			out_arr[ind..' '..sp.target.id] = nil
		elseif out_arr[ind..' nil'] then
			out_arr[ind..' nil'] = nil
		elseif out_arr[ind..' '..player.id] then
			out_arr[ind..' '..player.id] = nil
		elseif debugging >= 1 then
			windower.add_to_chat(123,'GearSwap: Ind matches the predicted Ind, but does not exist in out_arr.')
		end
	else
		windower.add_to_chat(123,'GearSwap: Missing ind was passed.')
	end
	return inde
end



-----------------------------------------------------------------------------------
--Name: unknown_out_arr_deletion(prefix,arr)
--Desc: Deletes an unknown out_arr entry based on target ID
--Args:
---- prefix - Current spell's prefix
---- target_id - target_ID 
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function unknown_out_arr_deletion(prefix,target_id)
	local loop_check
	
	-- Iterate over out_arr looking for a spell targeting the current target
	-- Call aftercast with this spell's information (interrupted) if one is found.
	for i,v in pairs(out_arr) do
		if v.spell and v.spell.target and v.spell.target.id == target_id then
			v.spell.interrupted = true
			v.spell.action_type = 'Interruption'
			refresh_globals()
			equip_sets(prefix..'aftercast',true,v.spell)
			loop_check = true
			break
		elseif target_id == player.id and v.midaction then
			-- Instead of passing the spell target of the offending spell, some
			-- action messages simply return your information as the target.
			-- In this case, assume the first action found in out_arr that is between
			-- precast and aftercast is the action to be canceled.
			v.spell.interrupted = true
			v.spell.action_type = 'Interruption'
			refresh_globals()
			equip_sets(prefix..'aftercast',true,v.spell)
			loop_check = true
			break
		end
	end
	if not loop_check  then
	-- If the above loop fails to produce a result, just go through and
	-- delete everything associated with that target_id
		delete_out_arr_by_id(target_id)
	end
end



-----------------------------------------------------------------------------------
--Name: delete_out_arr_by_id(id)
--Desc: Deletes an unknown out_arr entry based on target ID
--Args:
---- id - ID of the target
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function delete_out_arr_by_id(id)
	local deleted_table = {}
	for i,v in pairs(out_arr) do
		if v.spell and v.spell.target then
			if v.spell.target.id == id then
				out_arr[i] = nil
			end
		end
	end
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