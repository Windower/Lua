--Copyright (c) 2013~2016, Byrthnoth
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
--Name: string.lower()
--Args:
---- message (string): Message to be forced to lower case
-----------------------------------------------------------------------------------
--Returns:
---- Lower case message (or not, if the language or message is invalid)
-----------------------------------------------------------------------------------
function string.lower(message)
    if message and type(message) == 'string' and language == 'english' then
        return __raw.lower(message)
    elseif message and type(message) == 'string' then
        return message:gsub('[A-Z]',function (letter) return string.char(letter:byte(1)+32) end)
    else
        return message
    end
end


-----------------------------------------------------------------------------------
--Name: string.upper()
--Args:
---- message (string): Message to be forced to upper case
-----------------------------------------------------------------------------------
--Returns:
---- Upper case message (or not, if the language or message is invalid)
-----------------------------------------------------------------------------------
function string.upper(message)
    if message and type(message) == 'string' and language == 'english' then
        return __raw.upper(message)
    elseif message and type(message) == 'string' then
        return message:gsub('[a-z]',function (letter) return string.char(letter:byte(1)-32) end)
    else
        return message
    end
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
    local fields = T{}
    string.gsub(message,"{(.-)}", function(a) if a ~= '${actor}' and a ~= '${target}' then fields:append(a) end end)
    return fields
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
--Name: user_key_filter()
--Args:
---- val (key): potential key to be modified
-----------------------------------------------------------------------------------
--Returns:
---- Filtered key
-----------------------------------------------------------------------------------
function user_key_filter(val)
    return type(val) == 'string' and string.lower(val) or val
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
-- Checks to see if key 'k' is known in the slot_map array, and that slot has not
-- been disabled.
----Args:
-- k - A key to a gear slot in a gear table.
-----------------------------------------------------------------------------------
----Returns:
-- True if the key is recognized in the slot_map table, and that slot is enabled;
-- otherwise false.
-----------------------------------------------------------------------------------
function is_slot_key(k)
    return slot_map[k]
end
 
 
-----------------------------------------------------------------------------------
----Name: make_empty_item_table(slot)
-- Make an empty item table with slot = slot
----Args:
-- slot - The index of the item table
-----------------------------------------------------------------------------------
----Returns:
-- A zero'd table with slot = slot
-----------------------------------------------------------------------------------
function make_empty_item_table(slot)
    return {id=0,
    count = 0,
    bazaar = 0,
    extdata = string.char(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    status = 0,
    slot = slot}
end


-----------------------------------------------------------------------------------
----Name: make_inventory_table()
-- Make a table of empty item tables
----Args:
-- none
-----------------------------------------------------------------------------------
----Returns:
-- A table of 80 empty item tables indexed 1-80
-----------------------------------------------------------------------------------
function make_inventory_table()
    local tab = {}
    for i = 0,80 do
        tab[i] = make_empty_item_table(i)
    end
    return tab
end


-----------------------------------------------------------------------------------
----Name: to_windower_api(str)
-- Takes strings and converts them to resources table key format
----Args:
-- str - String to be converted to the windower API version
-----------------------------------------------------------------------------------
----Returns:
-- a lower case string with ' ' replaced with '_'
-----------------------------------------------------------------------------------
function to_windower_api(str)
    return __raw.lower(str:gsub(' ','_'))
end


-----------------------------------------------------------------------------------
----Name: to_windower_bag_api(str)
-- Takes strings and converts them to resources table key format
----Args:
-- str - String to be converted to the windower bag API version
-----------------------------------------------------------------------------------
----Returns:
-- a lower case string with ' ' replaced with ''
-----------------------------------------------------------------------------------
function to_windower_bag_api(str)
    return __raw.lower(str:gsub(' ',''))
end

-----------------------------------------------------------------------------------
----Name: to_bag_api(str)
-- Takes strings and converts them to resources table key format
----Args:
-- str - String to be converted to the windower bag API version
-----------------------------------------------------------------------------------
----Returns:
-- a lower case string with ' ' eliminated
-----------------------------------------------------------------------------------
function to_bag_api(str)
    return __raw.lower(str:gsub(' ',''))
end

-----------------------------------------------------------------------------------
----Name: to_windower_compact(str)
-- Takes strings and converts them to a compact version of the resource table key
----Args:
-- str - String to be converted to the windower API version
-----------------------------------------------------------------------------------
----Returns:
-- a lower case string with ' ' replaced with ''
-----------------------------------------------------------------------------------
function to_windower_compact(str)
    return __raw.lower(str:gsub(' ',''))
end

-----------------------------------------------------------------------------------
----Name: get_job_names()
-- Returns the short and long form of the job name
----Args:
-- id - Job ID
-----------------------------------------------------------------------------------
----Returns:
-- short and long form of the job name
-----------------------------------------------------------------------------------
function get_job_names(id)
    if res.jobs[id] then
        return res.jobs[id][language..'_short'], res.jobs[id][language]
    else
        return 'NONE', 'None'
    end
end


-----------------------------------------------------------------------------------
----Name: update_job_names()
-- Updates job names in the global player array
----Args:
-- none
-----------------------------------------------------------------------------------
----Returns:
-- none
-----------------------------------------------------------------------------------
function update_job_names()
    player.main_job,player.main_job_full = get_job_names(player.main_job_id)
    player.sub_job, player.sub_job_full = get_job_names(player.sub_job_id)
    player.job = player.main_job..'/'..player.sub_job
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
        return toslotname(slot_map[k])
    end
end


-----------------------------------------------------------------------------------
----Name: set_merge(baseSet, ...)
-- Merges any additional gear sets (...) into the provided base set.
-- Ensures that only valid slot keys/elements are used in the combined set.
----Args:
-- respect_disable - boolean indicating whether the disable_table should be respected.
-- baseSet - The set that all the other sets are combined into.  May be an empty set.
-----------------------------------------------------------------------------------
----Returns:
-- Returns the modified base set, after all other sets have been merged into it.
-----------------------------------------------------------------------------------
function set_merge(respect_disable, baseSet, ...)
    local combineSets = {...}

    local canCombine = table.all(combineSets, function(t) return type(t) == 'table' end)
    if not canCombine then
        -- the code that called equip() or set_combine() is #3 on the stack from here
        error("Trying to combine non-gear sets.", 3)
    end

    -- Take the list of tables we're given and cleans them up, so that they
    -- only contain acceptable slot key entries.
    local cleanSetsList = table.map(combineSets, unify_slots)

    -- Combine the provided sets into combinedSet.  If anything is blocked by having
    -- the slot disabled, assign the item to the not_sent_out_equip table.
    for _,set in pairs(cleanSetsList) do
        for slot,item in pairs(set) do
            if respect_disable and disable_table[slot_map[slot]] then
                not_sent_out_equip[slot] = item
            else
                baseSet[slot] = item
            end
        end
    end
    
    return baseSet
end


-----------------------------------------------------------------------------------
----Name: parse_set_to_keys(str)
-- Function to parse a string representation of a table into a list of keys that
-- that can be used to select that table.
----Args:
-- str - Input can be a string, or a table of strings (which will be concatenated
-- into a single string with spaces as intervals).
--
-- Example:
-- Input: sets.precast.WS["Rudra's Storm"]['Ltng. Threnody'].Acc
-- Output: [sets, precast, WS, Rudra's Storm, Ltng. Threnody, Acc]
-----------------------------------------------------------------------------------
----Returns:
-- Returns a list of keys parsed from the provided input.
-----------------------------------------------------------------------------------
function parse_set_to_keys(str)
    if type(str) == 'table' then
        str = table.concat(str, ' ')
    end
    
    -- Parsing results get pushed into the result list.
    local result = L{}

    local remainder = str
    local key
    local stop
    local sep = '.'
    local count = 0
    
    -- Loop as long as remainder hasn't been nil'd or reduced to 0 characters, but only to a maximum of 30 tries.
    while remainder ~= "" and count < 30 do
        -- Try aaa.bbb set names first
        while sep == '.' do
            _,_,key,sep,remainder = remainder:find("^([^%.%[]*)(%.?%[?)(.*)")
            -- "key" is everything that is not . or [ 0 or more times.
            -- "sep" is the next divider, which is necessarily . or [
            -- "remainder" is everything after that
            result:append(key)
        end
        
        -- Then try aaa['bbb'] set names.
        -- Be sure to account for both single and double quote enclosures.
        -- Ignore periods contained within quote strings.
        while sep == '[' do 
            _,_,sep,remainder = remainder:find([=[^(%'?%"?)(.*)]=]) --' --block bad text highlighting
            -- "sep" is the first ' or " found (or nil)
            -- remainder is everything after that (or nil)
            if sep == "'" then
                _,_,key,stop,sep,remainder = remainder:find("^([^']+)('])(%.?%[?)(.*)")
            elseif sep == '"' then
                _,_,key,stop,sep,remainder = remainder:find('^([^"]+)("])(%.?%[?)(.*)')
            end
            if not sep or #sep == 0 then
                -- If there is no single or double quote detected, attempt to treat the index as a number or boolean
                local _,_,pot_key,pot_stop,pot_sep,pot_remainder = remainder:find('^([^%]]+)(])(%.?%[?)(.*)')
                if tonumber(pot_key) then
                    key,stop,sep,remainder = tonumber(pot_key),pot_stop,pot_sep,pot_remainder
                elseif pot_key == 'true' then
                    key,stop,sep,remainder = true,pot_stop,pot_sep,pot_remainder
                elseif pot_key == 'false' then
                    key,stop,sep,remainder = false,pot_stop,pot_sep,pot_remainder
                elseif pot_key and pot_key ~= "" then
                    key,stop,sep,remainder = pot_key,pot_stop,pot_sep,pot_remainder
                end
            end
            result:append(key)
        end
        
        count = count +1
    end

    return result
end


-----------------------------------------------------------------------------------
----Name: get_set_from_keys(keys)
-- Function to take a list of keys select the set they point to, if possible.
----Args:
-- keys - A List of strings intended to be keys in progressively nested tables.
-- The list is presumed to be based on the 'sets' table, and will start from that
-- point if it is not explicitly provided in the key list.
-----------------------------------------------------------------------------------
----Returns:
-- Returns the set if found, or nil if not.
-----------------------------------------------------------------------------------
function get_set_from_keys(keys)
    local set = keys[1] == 'sets' and _G or sets
    for key in (keys.it or it)(keys) do
        if key == nil then
            return nil
        end
        set = set[key]
        if not set then
            return nil
        end
    end

    return set
end


-----------------------------------------------------------------------------------
--Name: initialize_arrow_offset(mob_table)
--Desc: Returns the current target arrow offset.
--Args:
---- mob_table - Monster table of the target monster
-----------------------------------------------------------------------------------
--Returns:
---- table - Keys x, y, and z with the respective current offsets from the target.
-----------------------------------------------------------------------------------
function initialize_arrow_offset(mob_table)
    local backtab = {}
    local arrow = windower.ffxi.get_info().target_arrow
    
    if arrow.x == 0 and arrow.y == 0 and arrow.z == 0 then
        return arrow
    end
    
    backtab.x = arrow.x-mob_table.x
    backtab.y = arrow.y-mob_table.y
    backtab.z = arrow.z-mob_table.z
    return backtab
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
function assemble_action_packet(target_id,target_index,category,spell_id,arrow_offset)
    local outstr = string.char(0x1A,0x08,0,0)
    outstr = outstr..string.char( (target_id%256), math.floor(target_id/256)%256, math.floor( (target_id/65536)%256) , math.floor( (target_id/16777216)%256) )
    outstr = outstr..string.char( (target_index%256), math.floor(target_index/256)%256)
    outstr = outstr..string.char( (category%256), math.floor(category/256)%256)
    
    if category == 16 then
        spell_id = 0
    end
        
    outstr = outstr..string.char( (spell_id%256), math.floor(spell_id/256)%256)..string.char(0,0) .. 'fff':pack(arrow_offset.x,arrow_offset.z,arrow_offset.y)
    return outstr
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
        msg.debugging('Proposed item: '..(res.items[item_id][language] or item_id)..' not found in inventory.')
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
function assemble_menu_item_packet(target_id,target_index,...)
    local outstr = string.char(0x36,0x20,0,0)
    -- Message is coming out too short by 12 characters
    
    -- Target ID
    outstr = outstr.."I":pack(target_id)
    local item_ids,counts,count = {...},{},0
    for i,v in pairs(item_ids) do
        if res.items[v] then
            counts[v] = (counts[v] or 0) + 1
            count = count + 1
        end
    end
    
    local unique_items = 0
    for i,v in pairs(counts) do
        outstr = outstr.."I":pack(v)
        unique_items = unique_items + 1
    end
    if unique_items > 9 then
        msg.debugging('Too many items ('..unique_items..') passed to the assemble_menu_item_packet function')
        return
    end
    while #outstr < 0x30 do
        outstr = outstr..string.char(0)
    end
    
    -- Inventory Index for the one unit
    
    for i,v in pairs(counts) do
        inventory_index = find_inventory_item(i)
        if inventory_index then
            outstr = outstr..string.char(inventory_index%256)
        else
            msg.debugging('Proposed item: '..(res.items[i][language] or i)..' not found in inventory.')
            return
        end
    end
    while #outstr < 0x3A do
        outstr = outstr..string.char(0)
    end
    -- Target Index
    outstr = outstr.."H":pack(target_index)
    -- Only one item being traded
    outstr = outstr..string.char(unique_items,0,0,0)
    return outstr
end


-----------------------------------------------------------------------------------
--Name: find_inventory_item(item_id)
--Desc: Finds a npc trade item in normal inventory. Assumes items array
--      is accurate already.
--Args:
---- item_id - The resource line for the current item
-----------------------------------------------------------------------------------
--Returns:
---- inventory_index - The item's use inventory index (if it exists)
---- bag_id - The item's bag ID (if it exists)
-----------------------------------------------------------------------------------
function find_inventory_item(item_id)
    for i,v in pairs(items.inventory) do
        if type(v) == 'table' and v.id == item_id and v.status == 0 then
            return i
        end
    end
end


-----------------------------------------------------------------------------------
--Name: find_usable_item(item_id,bool)
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
    for _,bag in ipairs(usable_item_bags) do
        for i,v in pairs(items[to_windower_bag_api(bag.en)]) do
            if type(v) == 'table' and v.id == item_id and is_usable_item(v,bag.id) then
                return i, bag.id
            end
        end
    end
end

-----------------------------------------------------------------------------------
--Name: is_usable_item(i_tab)
--Desc: Determines whether the item table belongs to a usable item.
--Args:
---- i_tab - current item table
---- bag_id - The item's bag ID
-----------------------------------------------------------------------------------
--Returns:
---- true or false to indicate whether the item is usable
-----------------------------------------------------------------------------------
function is_usable_item(i_tab,bag_id)
    local ext = extdata.decode(i_tab)
    if ext.type == 'Enchanted Equipment' and ext.usable then
        return i_tab.status == 5
    elseif i_tab.status == 0 and bag_id < 4 then
        return true
    end
    return false
end

-----------------------------------------------------------------------------------
--Name: number_of_jps(jp_tab)
--Desc: Gives the total number of job points spent on that job
--Args:
---- jp_tab - One table from windower.ffxi.get_player().job_points[job]
-----------------------------------------------------------------------------------
--Returns:
---- The total number of job points spent on that job.
-----------------------------------------------------------------------------------
function number_of_jps(jp_tab)
    local count = 0
    for _,v in pairs(jp_tab) do
        count = count + v*(v+1)
    end
    return count/2
end

-----------------------------------------------------------------------------------
--Name: filter_pretarget(spell)
--Desc: Determines whether the current player is capable of using the proposed action
----    at pretarget.
--Args:
---- action - current action
-----------------------------------------------------------------------------------
--Returns:
---- false to cancel further command processing and just return the command.
-----------------------------------------------------------------------------------
function filter_pretarget(action)
    local category = outgoing_action_category_table[unify_prefix[action.prefix]]
    local bool = true
    local err
    if world.in_mog_house then
        msg.debugging("Unable to execute commands. Currently in a Mog House zone.")
        return false
    elseif category == 3 then
        local available_spells = windower.ffxi.get_spells()
        bool,err = check_spell(available_spells,action)
    elseif category == 7 then
        local available = windower.ffxi.get_abilities().weapon_skills
        if not table.contains(available,action.id) then
            bool,err = false,"Unable to execute command. You do not have access to that weapon skill."
        end
    elseif category == 9 then
        local available = windower.ffxi.get_abilities().job_abilities
        if not table.contains(available,action.id) then
            bool,err = false,"Unable to execute command. You do not have access to that job ability."
        end
    elseif category == 25 and (not player.main_job_id == 23 or not windower.ffxi.get_mjob_data().species or
        not res.monstrosity[windower.ffxi.get_mjob_data().species] or not res.monstrosity[windower.ffxi.get_mjob_data().species].tp_moves[action.id] or
        not (res.monstrosity[windower.ffxi.get_mjob_data().species].tp_moves[action.id] <= player.main_job_level)) then
        -- Monstrosity filtering
        msg.debugging("Unable to execute command. You do not have access to that monsterskill ("..(res.monster_abilities[action.id][language] or action.id)..")")
        return false
    end
    
    if err then
        msg.debugging(err)
    end
    return bool
end


-----------------------------------------------------------------------------------
--Name: check_spell(available_spells,spell)
--Desc: Determines whether the current player is capable of using the proposed spell
----    at precast.
--Args:
---- available_spells - current set of available spells
---- spell - current spell table
-----------------------------------------------------------------------------------
--Returns:
---- false if the spell is not currently accessible
-----------------------------------------------------------------------------------
function check_spell(available_spells,spell)
    -- Filter for spells that you do not know. Exclude Impact / Dispelga.
    local spell_jobs = copy_entry(res.spells[spell.id].levels)
    if not available_spells[spell.id] and not (spell.id == 503 or spell.id == 417 or spell.id == 360) then
        return false,"Unable to execute command. You do not know that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    -- Filter for spells that you know, but do not currently have access to
    elseif (not spell_jobs[player.main_job_id] or not (spell_jobs[player.main_job_id] <= player.main_job_level or
        (spell_jobs[player.main_job_id] >= 100 and number_of_jps(player.job_points[__raw.lower(res.jobs[player.main_job_id].ens)]) >= spell_jobs[player.main_job_id]) ) ) and
        (not spell_jobs[player.sub_job_id] or not (spell_jobs[player.sub_job_id] <= player.sub_job_level)) and not (player.main_job_id == 23) then
        return false,"Unable to execute command. You do not have access to that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    -- At this point, we know that it is technically castable by this job combination if the right conditions are met.
    elseif player.main_job_id == 20 and ((addendum_white[spell.id] and not buffactive[401] and not buffactive[416]) or
        (addendum_black[spell.id] and not buffactive[402] and not buffactive[416])) and
        not (spell_jobs[player.sub_job_id] and spell_jobs[player.sub_job_id] <= player.sub_job_level) then
        return false,"Unable to execute command. Addendum required for that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    elseif player.sub_job_id == 20 and ((addendum_white[spell.id] and not buffactive[401] and not buffactive[416]) or
        (addendum_black[spell.id] and not buffactive[402] and not buffactive[416])) and
        not (spell_jobs[player.main_job_id] and (spell_jobs[player.main_job_id] <= player.main_job_level or
        (spell_jobs[player.main_job_id] >= 100 and number_of_jps(player.job_points[__raw.lower(res.jobs[player.main_job_id].ens)]) >= spell_jobs[player.main_job_id]) ) ) then
        return false,"Unable to execute command. Addendum required for that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    elseif spell.type == 'BlueMagic' and not ((player.main_job_id == 16 and table.contains(windower.ffxi.get_mjob_data().spells,spell.id)) 
        or unbridled_learning_set[spell.english]) and
        not (player.sub_job_id == 16 and table.contains(windower.ffxi.get_sjob_data().spells,spell.id)) then
        -- This code isn't hurting anything, but it doesn't need to be here either.
        return false,"Unable to execute command. Blue magic must be set to cast that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    elseif spell.type == 'Ninjutsu'  then
        if player.main_job_id ~= 13 and player.sub_job_id ~= 13 then
            return false,"Unable to make action packet. You do not have access to that spell ("..(spell[language] or spell.id)..")"
        elseif not player.inventory[tool_map[spell.english][language]] and not (player.main_job_id == 13 and player.inventory[universal_tool_map[spell.english][language]]) then
            return false,"Unable to make action packet. You do not have the proper tools."
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
        if debugging.general then msg.debugging('No target id or index') end
        return false
    end
    return true
end


local cmd_reg = {}
Command_Registry = {}

function Command_Registry.new()
    local new_instance = {_self={last_removed=os.clock()}}
    local function remove_old_entries (t)
        -- Removes old command registry entries.
        for i,v in pairs(t) do
            local lim = (type(v) == 'table' and (v.spell and v.spell.cast_time and v.spell.cast_time*1.1+2 or
                v.spell and v.spell.prefix=='/pet' and 5 or
                v.spell and v.spell.action_type and delay_map_to_action_type[v.spell.action_type] or
                3) + (v.pretarget_cast_delay or 0) + (v.precast_cast_delay or 0))
                -- Sets it to normal casting time + 10% +1 for anything with a defined cast_time, or 1 if there is no defined cast time.
            if tonumber(i) and os.time()-i >= lim then
                cmd_reg.delete_entry(t,i)
            end
        end
        return os.clock()
    end

    return setmetatable(new_instance, {__index = function(t, k)
            if os.clock() - rawget(rawget(t,'_self'),'last_removed') > 0.04 then
                rawset(rawget(t,'_self'),'last_removed', remove_old_entries(t))
            end
            if rawget(cmd_reg, k) ~= nil then
                return rawget(cmd_reg,k)
            else
                return rawget(t,k)
            end
        end})
end


-----------------------------------------------------------------------------------
--Name: cmd_reg:new_entry(sp)
--Desc: Makes a new entry in command_registry.
--Args:
---- sp - Resources line for the current spell
-----------------------------------------------------------------------------------
--Returns:
---- ts - index for command_registry
-----------------------------------------------------------------------------------
function cmd_reg:new_entry(sp)
    local ts = os.time()
    while rawget(self,ts) do
        ts = ts+0.001
    end
    rawset(self,ts,{pretarget_cast_delay=0, precast_cast_delay=0, cancel_spell=false, new_target=false, current_event='nascent', spell=sp, timestamp=ts,target_arrow={x=0,y=0,z=0}})
    if debugging.command_registry then
        msg.addon_msg('Creating a new command_registry entry: '..windower.to_shift_jis(tostring(ts)..' '..tostring(self[ts])))
    end
    return ts
end


-----------------------------------------------------------------------------------
--Name: cmd_reg:delete_entry(ts)
--Desc: Makes a new entry in command_registry.
--Args:
---- ts - timestamp of the command registry entry to be deleted
-----------------------------------------------------------------------------------
--Returns:
---- bool - true indicates a successful deletion
-----------------------------------------------------------------------------------
function cmd_reg:delete_entry(ts)
    if rawget(self,ts) then
        if debugging.command_registry then
            msg.debugging('Deleting a command_registry entry: '..windower.to_shift_jis(tostring(ts)..' '..tostring(rawget(self,ts))))
        end
        rawset(self,ts,nil)
        return true
    elseif debugging.command_registry then
        msg.debugging('Attempted to delete a command_registry entry that did not exist: '..windower.to_shift_jis(tostring(ts) ))
    end
    return false
end


-----------------------------------------------------------------------------------
--Name: cmd_reg:find_by_spell(value)
--Desc: Returns the proper unified prefix, or "Monster" in the case of a monster action
--Args:
---- typ - 'spell', 'timestamp', or 'id'
---- value - The spell, timestamp, or id
---- Currently the ID and Timestamp options are unused.
-----------------------------------------------------------------------------------
--Returns:
---- timestamp index of command_registry
-----------------------------------------------------------------------------------
function cmd_reg:find_by_spell(value)
    -- Finds all entries of a given spell in the table.
    -- Returns the one with the most recent timestamp.
    -- Actions that do not have timestamps yet (have not hit midcast) are given lowest priority.
    local potential_entries,current_time,winner,ts = {},os.time()
    for i,v in pairs(self) do
        if type(v) == 'table' and v.spell and v.spell.prefix == value.prefix and v.spell.name == value.name then
            potential_entries[i] = v.timestamp or 0
        elseif type(v) == 'table' and v.spell and v.spell.english == 'Double-Up' and value.type == 'CorsairRoll' then
            -- Double Up ability uses will return action packets that match Corsair Rolls rather than Double Up
            potential_entries[i] = v.timestamp or 0
        end
    end
    for i,v in pairs(potential_entries) do
        if not winner or (current_time - v < current_time - winner) then
            winner = v
            ts = i
        end
    end
    return ts
end


-----------------------------------------------------------------------------------
--Name: cmd_reg:find_by_time()
--Desc: Finds the most recent command_registry entry
--Args:
---- none
-----------------------------------------------------------------------------------
--Returns:
---- ts,discovered entry
-----------------------------------------------------------------------------------
function cmd_reg:find_by_time(target_time)
    local time_stamp,ts
    target_time = target_time or os.time()
    
    -- Iterate over command_registry looking for the spell with the closest timestamp.
    -- Call aftercast with this spell's information (interrupted) if one is found.
    for i,v in pairs(self) do
        if not time_stamp or (type(v) == 'table' and v.timestamp and ((target_time - v.timestamp) < (target_time - time_stamp))) then
            time_stamp = v.timestamp
            ts = i
        end
    end
    if time_stamp then
        return ts,table.reassign({},self[ts])
    end
end


-----------------------------------------------------------------------------------
--Name: cmd_reg:delete_by_id(id)
--Desc: Deletes all command_registry entry based that match a given target ID.
--Args:
---- id - ID of the target
-----------------------------------------------------------------------------------
--Returns:
---- ts,last_entry for the deleted entry
-----------------------------------------------------------------------------------
function cmd_reg:delete_by_id(id)
    local ts,last_entry
    for i,v in pairs(self) do
        if v.spell and v.spell.target then
            if v.spell.target.id == id then
                last_entry = table.reassign({},self[i])
                ts = i
                self[i] = nil
            end
        end
    end
    return ts,last_entry
end


-----------------------------------------------------------------------------------
--Name: copy_entry(tab)
--Desc: Copies a table into a new table while preserving its metatable.
--      Designed for copying resources entries.
--Args:
---- tab - Resources table.
-----------------------------------------------------------------------------------
--Returns:
---- ret - New table that has the same metatable and content as the original table.
-----------------------------------------------------------------------------------
function copy_entry(tab)
    if not tab then return nil end
    local ret = setmetatable(table.reassign({},tab),getmetatable(tab))
    return ret
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
    local spell, abil_ID, effect_val
    local msg_ID = act.targets[1].actions[1].message
    
    if T{7,8,9}:contains(act.category) then
        abil_ID = act.targets[1].actions[1].param
    elseif T{3,4,5,6,11,13,14,15}:contains(act.category) then
        abil_ID = act.param
        effect_val = act.targets[1].actions[1].param
    end
    
    if act.category == 12 or act.category == 2 then
        spell = copy_entry(resources_ranged_attack)
    else
        if not res.action_messages[msg_ID] or msg_ID == 31 then
            if act.category == 4 or act.category == 8 then
                spell = spell_complete(copy_entry(res.spells[abil_ID]))
                if act.category == 4 and spell then spell.recast = act.recast end
            elseif T{6,13,14,15}:contains(act.category) then
                spell = spell_complete(copy_entry(res.job_abilities[abil_ID])) -- May have to correct for charmed pets some day, but I'm not sure there are any monsters with TP moves that give no message.
            elseif T{3,7}:contains(act.category) then
                spell = spell_complete(copy_entry(res.weapon_skills[abil_ID]))
            elseif T{5,9}:contains(act.category) then
                spell = copy_entry(res.items[abil_ID])
            else
                spell = {name=tostring(msg_ID)}
            end
            
            return spell
        end
        
        
        local fields = fieldsearch(res.action_messages[msg_ID].english) -- ENGLISH
        
        if table.contains(fields,'spell') then
            spell = copy_entry(res.spells[abil_ID])
            if act.category == 4 then spell.recast = act.recast end
        elseif table.contains(fields,'ability') then
            spell = copy_entry(res.job_abilities[abil_ID])
        elseif table.contains(fields,'weapon_skill') then
            if abil_ID > 255 then -- WZ_RECOVER_ALL is used by chests in Limbus
                spell = copy_entry(res.monster_abilities[abil_ID])
                if not spell then
                    spell = {id=abil_ID,english='Special Attack'}
                end
            elseif abil_ID < 256 then
                spell = copy_entry(res.weapon_skills[abil_ID])
            end
        elseif msg_ID == 303 then
            spell = copy_entry(res.job_abilities[74]) -- Divine Seal
        elseif msg_ID == 304 then
            spell = copy_entry(res.job_abilities[75]) -- 'Elemental Seal'
        elseif msg_ID == 305 then
            spell = copy_entry(res.job_abilities[76]) -- 'Trick Attack'
        elseif msg_ID == 311 or msg_ID == 311 then
            spell = copy_entry(res.job_abilities[79]) -- 'Cover'
        elseif msg_ID == 240 or msg_ID == 241 then
            spell = copy_entry(res.job_abilities[43]) -- 'Hide'
        elseif msg_ID == 244 then
            spell = copy_entry(res.job_abilities[act.param]) -- Mug failures
        elseif msg_ID == 328 then
            spell = copy_entry(res.job_abilities[effect_val]) -- BPs that are out of range
        end
        
        
        if table.contains(fields,'item') then
            if spell then
                spell.item = copy_entry(res.items[effect_val])
            else
                spell = copy_entry(res.items[abil_ID])
            end
        else
            spell = spell_complete(spell)
        end
    end
    
    if spell then
        spell.name = spell[language]
        spell.interrupted = false
    end
    
    return spell
end


-----------------------------------------------------------------------------------
--Name: spell_complete(rline)
--Desc: Takes a resource line and modifies it so it includes aftercast cost and
--      a few other values
--Args:
---- rline - resource line
-----------------------------------------------------------------------------------
--Returns:
---- rline - modified resource line
-----------------------------------------------------------------------------------
function spell_complete(rline)
    -- Hardcoded adjustments
    if rline and rline.skill == 40 and buffactive.Pianissimo and rline.cast_time == 8 then
        -- Pianissimo halves song casting time for buffs
        rline.cast_time = 4
        rline.targets.Party = true
    end
    if rline and rline.skill == 44 and buffactive.Entrust and string.find(rline.en,"Indi") then
        -- Entrust allows Indi- spells to be cast on party members
        rline.targets.Party = true
    end
    
    if rline == nil then
        return {tpaftercast = player.tp, mpaftercast = player.mp, mppaftercast = player.mpp}
    end
    if not rline.mp_cost or rline.mp_cost == -1 then rline.mp_cost = 0 end
    if not rline.tp_cost and rline.type == 'WeaponSkill' then
        rline.tp_cost = player.tp
    elseif not rline.tp_cost or rline.tp_cost == -1 then
        rline.tp_cost = 0
    end
    
    if rline.skill and tonumber(rline.skill) then
        rline.skill = res.skills[rline.skill][language]
    end
    
    if rline.element and tonumber(rline.element) then
        rline.element = res.elements[rline.element][language]
    end
    
    if rline.tp_cost == 0 then rline.tpaftercast = player.tp else
    rline.tpaftercast = player.tp - rline.tp_cost end
    
    if rline.mp_cost == 0 then
        rline.mpaftercast = player.mp
        rline.mppaftercast = player.mpp
    else
        rline.mpaftercast = player.mp - rline.mp_cost
        rline.mppaftercast = (player.mp - rline.mp_cost)/player.max_mp
    end
    
    return rline
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
function logit(str)
    if debugging.logging then
        if not logfile and windower.dir_exists('../addons/GearSwap/data/logs') then
            logfile = io.open('../addons/GearSwap/data/logs/NormalLog'..tostring(os.clock())..'.log','w+')
            logfile:write('GearSwap LOGGER HEADER\n')
        end
        logfile:write(str)
        logfile:flush()
    end
end

msg = {}

-----------------------------------------------------------------------------------
--Name: msg.add_to_chat(col,str)
--Args:
---- col (num): Color to print out in (0x1F,col)
---- str (string): String to be printed.
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function msg.add_to_chat(col,str)
    if str == '' then return end
    if col == 1 then
        windower.add_to_chat(1,str)
    else
        windower.add_to_chat(1,string.char(0x1F,col%256)..str..string.char(0x1E,0x01))
    end
end

-----------------------------------------------------------------------------------
--Name: msg.debugging(message)
--Desc: Checks _settings.debug_mode and outputs the message if necessary
--Args:
---- message - The debug message
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function msg.debugging(message)
    if _settings.debug_mode or debugging.general or debugging.command_registry then
        msg.add_to_chat(8,"GearSwap (Debug Mode): "..windower.to_shift_jis(tostring(message)))
    end
end

-----------------------------------------------------------------------------------
--Name: msg.addon_msg(col,str)
--Args:
---- col (num): Color to print out in (0x1F,col)
---- str (string): String to be printed.
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function msg.addon_msg(col,str)
    msg.add_to_chat(col,'GearSwap: '..str)
end

-- Set up the priority list structure

-----------------------------------------------------------------------------------
--Name: prioritize()
--Args:
---- priority_list (table): Current list of slot priorities
---- slot_id (number): Desired order of the piece of equipment
---- priority (number): Name for the slot
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function prioritize(self,slot_id,priority)
    if priority and tonumber(priority) then -- Check that priority is number
        rawset(self,slot_id,priority)
        return
    elseif priority then
        msg.addon_msg(123,'Invalid priority ('..tostring(priority)..') given')
    end
    rawset(self,slot_id,0)
end


local priority_list = {}

Priorities = {}
function Priorities.new()
    local new_instance = {}
    return setmetatable(new_instance, { __index = function(t, k) if rawget(t, k) ~= nil then return rawget(t,k) else return rawget(priority_list,k) end end,
        __newindex=prioritize})
end

-----------------------------------------------------------------------------------
--Name: priority_list:it()
--Args:
---- self (table): Current list of slot priorities
-----------------------------------------------------------------------------------
--Returns:
---- slot_id : Number from 0~15
-----------------------------------------------------------------------------------
function priority_list:it()
    return function ()
        local maximum,slot_id = -math.huge
        for i=0,15 do
            if self[i] and (self[i] > maximum or (self[i] == maximum and self[i] == -math.huge)) then
                maximum = self[i]
                slot_id = i
            end
        end
        if not slot_id then return end
        self[slot_id] = nil
        return slot_id,maximum
    end
end



-----------------------------------------------------------------------------------
--Name: toslotname(slot_id)
--Args:
---- slot_id: Number from 0-15 representing the slot
-----------------------------------------------------------------------------------
--Returns:
---- slot name (string)
-----------------------------------------------------------------------------------
function toslotname(slot_id)
    return rawget(default_slot_map,slot_id)
end



-----------------------------------------------------------------------------------
--Name: toslotid(slot_name)
--Args:
---- slot_name: proposed slot name
-----------------------------------------------------------------------------------
--Returns:
---- slot id (whole number from 0-15)
-----------------------------------------------------------------------------------
function toslotid(slot_name)
    return slot_map[slot_name]
end



-----------------------------------------------------------------------------------
--Name: windower.debug(...)
--Args:
---- ...: Anything, to be passed to the real windower.debug if the windower_debugging
---- flag is set.
-----------------------------------------------------------------------------------
--Returns:
---- Nothing
-----------------------------------------------------------------------------------
windower.__raw = {debug = windower.debug}
windower.debug = function(...)
    if debugging.windower_debug then __raw.debug(...) end
end
