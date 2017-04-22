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

-------------------------------------------------------------------------------------------------------------------
-- Primary entry point.
-------------------------------------------------------------------------------------------------------------------

-- Validate either gear sets or inventory.
-- gs validate [inv|set] [filterlist]
-- Where inv == i or inv or inventory
-- Where set == s or set or sets
-- Where filterlist can use - to negate a value (eg: -charis for everything except charis, instead of only charis)
function validate(options)
    local validateType = 'sets'
    if options and #options > 0 then
        if S{'sets','set','s'}:contains(options[1]:lower()) then
            table.remove(options,1)
        elseif S{'inventory','inv','i'}:contains(options[1]:lower()) then
            validateType = 'inv'
            table.remove(options,1)
        end
    end
    
    if validateType == 'inv' then
        validate_inventory(options)
    else
        validate_sets(options)
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Functions to handle the primary logic separation.
-------------------------------------------------------------------------------------------------------------------

-- Function for determining and displaying which items from a player's inventory are not in their gear sets.
function validate_inventory(filter)
    msg.addon_msg(123,'Checking for items in inventory that are not used in your gear sets.')
    
    local extra_items = search_sets_for_items_in_bag(items.inventory, filter)
    
    local display_list = get_item_names(extra_items):sort(insensitive_sort)
    display_list:map(function(item) msg.add_to_chat(120, windower.to_shift_jis((string.gsub(item, "^%l", string.upper))) ) end)
    msg.addon_msg(123,'Final count = '..tostring(display_list:length()))
end

-- Function for determining and displaying which items of a player's gear sets are not in their inventory.
function validate_sets(filter)
    msg.addon_msg(123,'Checking for items in gear sets that are not in your inventory.')
    
    local missing_items = search_bags_for_items_in_set(sets, filter)

    local display_list = get_item_names(missing_items):sort(insensitive_sort)
    display_list:map(function(item) msg.add_to_chat(120, windower.to_shift_jis((string.gsub(item, "^%l", string.upper))) ) end)
    msg.addon_msg(123,'Final count = '..tostring(display_list:length()))
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions for output and id>name conversion.
-------------------------------------------------------------------------------------------------------------------

-- Given a set of item IDs, create a set of item names.
function get_item_names(item_set)
    return item_set:map(get_item_name)
end

-- Get the name of an item.  Handle the various types of items that can be passed to this function.
function get_item_name(item)
    local name = ''
    local aug = ''

    if type(item) == 'string' then
        name = item
    elseif type(item) == 'table' then
        if item.id then
            name = get_formal_name_by_item_id(item.id)
        elseif item.name then
            name = item.name
        end
        
        
        local aug = item.aug and table.concat(item.aug,', ') or get_augment_string(item)
        if aug then
            name = name .. ' {' .. aug .. '}'
        end
    end

    return name
end

-- Get the (preferably) capitalized version of an item's name, or the
-- log version if the short version is abbreviated.
function get_formal_name_by_item_id(id)
    local shortname = get_short_name_by_item_id(id)
    local logname = get_log_name_by_item_id(id)
    
    return (#logname > #shortname) and logname or shortname
end

-- Given an item id, get the log item name.
function get_log_name_by_item_id(id)
    return res.items[id][language..'_log']
end

-- Given an item id, get the short item name.
function get_short_name_by_item_id(id)
    return res.items[id][language]
end

-- If the provided item has augments on it, return a string containing the list of augments.
function get_augment_string(item)
    local augments
    if item.extdata then
        augments = extdata.decode(item).augments or {}
    else
        augments = item.augment or item.augments
    end

    local started = false
    if augments and #augments > 0 then
        local aug_str = ''
        for aug_ind,augment in pairs(augments) do
            if augment ~= 'none' then
                if started then
                    aug_str = aug_str .. ','
                end
                
                aug_str = aug_str.."'"..augment.."'"
                started = true
            end
        end
        
        return aug_str
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions for searching.
-------------------------------------------------------------------------------------------------------------------

-- General search to find what 'extra' items are in inventory
function search_sets_for_items_in_bag(bag, filter)
    local extra_bag_items = S{}
    for _,item in ipairs(bag) do
        if item.id ~= 0 and tryfilter(lowercase_name(get_log_name_by_item_id(item.id)), filter) then
            if not find_in_sets(item, sets) then
                extra_bag_items:add(item)
            end
        end
    end
    
    return extra_bag_items
end

-- General search to find what 'extra' items are in the job's gear sets
function search_bags_for_items_in_set(gear_table, filter, missing_items, stack)
    if stack and stack:contains(gear_table) then return end
    if type(gear_table) ~= 'table' then return end
    if missing_items == nil then missing_items = S{} end
    
    for i,v in pairs(gear_table) do
        local name = (type(v) == 'table' and v.name) or v
        local aug = (type (v) == 'table' and (v.augments or v.augment))
        
        if type(aug) == 'string' then aug = {aug} end
        if type(name) == 'string' and name ~= 'empty' and name ~= '' and type(i) == 'string' then
            if not slot_map[i] then
                msg.addon_msg(123,windower.to_shift_jis(tostring(i))..' contains a "name" element but is not a valid slot.')
            elseif tryfilter(lowercase_name(name), filter) and not find_in_equippable_inventories(name, aug) then
                -- This is one spot where inventory names will be left hardcoded until an equippable bool is added to the resources
                missing_items:add({name=lowercase_name(name),aug=aug})
            end
        elseif type(name) == 'table' and name ~= empty  then
            if not stack then stack = S{} end

            stack:add(gear_table)
            search_bags_for_items_in_set(v, filter, missing_items, stack)
            stack:remove(gear_table)
        end
    end
    
    return missing_items
end

-- Utility function to search equippable inventories
function find_in_equippable_inventories(name,aug)
    for _,bag in pairs(equippable_item_bags) do
        if find_in_inv(items[to_windower_bag_api(bag.en)], name, aug) then
            return true
        end
    end
end

-- Utility function to help search sets
function find_in_sets(item, tab, stack)
    if stack and stack:contains(tab) then
        return false
    end

    local item_short_name = lowercase_name(get_short_name_by_item_id(item.id))
    local item_log_name = lowercase_name(get_log_name_by_item_id(item.id))

    for _,v in pairs(tab) do
        local name = (type(v) == 'table' and v.name) or v
        local aug = (type(v) == 'table' and (v.augments or v.augment))
        if type(aug) == 'string' then aug = {aug} end
        if type(name) == 'string' then
            if compare_item(item, name, aug, item_short_name, item_log_name) then
                return true
            end
        elseif type(v) == 'table' then
            if not stack then stack = S{} end

            stack:add(tab)
            local try = find_in_sets(item, v, stack)
            stack:remove(tab)

            if try then
                return true
            end
        end
    end
    
    return false
end

-- Utility function to help search inventory
function find_in_inv(bag, name, aug)    
    for _,item in ipairs(bag) do
        if compare_item(item, name, aug) then
            return true
        end
    end
    return false
end

-- Utility function to compare items that may possibly be augmented.
function compare_item(item, name, aug, item_short_name, item_log_name)
    if item.id == 0 or not res.items[item.id] then
        return false
    end
    
    name = lowercase_name(name)
    item_short_name = lowercase_name(item_short_name or get_short_name_by_item_id(item.id))
    item_log_name = lowercase_name(item_log_name or get_log_name_by_item_id(item.id))

    if item_short_name == name or item_log_name == name then
        if not aug or extdata.compare_augments(aug, extdata.decode(item).augments) then
            return true
        end
    end
    
    return false
end


-------------------------------------------------------------------------------------------------------------------
-- Utility functions for filtering.
-------------------------------------------------------------------------------------------------------------------

function tryfilter(itemname, filter)
    if not filter or #filter == 0 then
        return true
    end
    
    local pass = true
    for _,v in pairs(filter) do
        if v[1] == '-' then
            pass = false
            v = v:sub(2)
        end
        if not v or type(v) ~= 'string' then
            print_set(filter,'filter with bad v')
        end
        if itemname:contains(lowercase_name(v)) then
            return pass
        end
    end
    return not pass
end


function lowercase_name(name)
    if type(name) == 'string' then
        return name:lower()
    else
        return name
    end
end

function insensitive_sort(item1, item2)
    if type(item1) == 'string' and type(item2) == 'string' then
        return item1:lower() < item2:lower()
    else
        return item1 < item2
    end
end
