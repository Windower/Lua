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
--Name: check_wearable(item_id)
--Args:
---- item_id - Item ID to be examined
-----------------------------------------------------------------------------------
--Returns:
---- boolean indicating whether the given piece of gear can be worn or not
----    Checks for main job, level, superior level, and gender/race
-----------------------------------------------------------------------------------
function check_wearable(item_id)
    if not item_id or item_id == 0 then -- 0 codes for an empty slot, but Arcon will probably make it nil at some point
    elseif not res.items[item_id] then
        msg.debugging("Item "..item_id.." has not been added to resources yet.")
    elseif not res.items[item_id].jobs then -- Make sure item can be equipped by specific jobs (unlike pearlsacks).
        --msg.debugging('GearSwap (Debug Mode): Item '..(res.items[item_id][language] or item_id)..' does not have a jobs field in the resources.')
    elseif not res.items[item_id].slots then
        -- Item is not equippable
    else
        return (res.items[item_id].jobs[player.main_job_id]) and (res.items[item_id].level<=player.jobs[res.jobs[player.main_job_id].ens]) and (res.items[item_id].races[player.race_id]) and
            (player.superior_level >= (res.items[item_id].superior_level or 0))
    end
    return false
end

-----------------------------------------------------------------------------------
--Name: name_match(item_id,name)
--Args:
---- item_id - Item ID to be compared
---- name - Name to be compared
-----------------------------------------------------------------------------------
--Returns:
---- boolean indicating whether the name matches the resources entry for the itemID
-----------------------------------------------------------------------------------
function name_match(item_id,name)
    if res.items[item_id] then
        return (res.items[item_id][language..'_log']:lower() == name:lower() or res.items[item_id][language]:lower() == name:lower())
    else
        return false
    end
end

-----------------------------------------------------------------------------------
--Name: expand_entry(v)
--Args:
---- entry - Table or string ostensibly from an equipment set
-----------------------------------------------------------------------------------
--Returns:
---- name - Name of the current piece of equipment
---- priority - Priority of the current piece as defined in the advanced table
---- augments - Augments for the current piece as defined in the advanced table
---- designated_bag - Bag for the current piece as defined in the advanced table
-----------------------------------------------------------------------------------
function expand_entry(entry)
    if not entry then
        return
    end
    local augments,name,priority,designated_bag
    if type(entry) == 'table' and entry == empty then
        name = empty
    elseif type(entry) == 'table' and entry.name and type(entry.name) == 'string' then
        name = entry.name
        priority = entry.priority
        if entry.augments then
            augments = entry.augments
        elseif entry.augment then
            augments = {entry.augment}
        end
        if entry.bag and type(entry.bag) == 'string' then
            designated_bag = bag_string_lookup[to_windower_bag_api(entry.bag)]
        end
    elseif type(entry) == 'string' and entry ~= '' then
        name = entry
    end
    return name,priority,augments,designated_bag -- all nil if they don't exist
end

-----------------------------------------------------------------------------------
--Name: unpack_equip_list(inventory,equip_list)
--Args:
---- inventory - Current inventory (potentially avoids a get_items() call)
---- equip_list - Keys are standard slot names, values are item names.
-----------------------------------------------------------------------------------
--Returns:
---- Table with keys that are slot numbers with values that are inventory slot #s.
-----------------------------------------------------------------------------------
function unpack_equip_list(equip_list,cur_equip)
    local ret_list = {} -- Gear that is designated to be equipped
    local used_list = {} -- Gear that is scheduled to be equipped but is already being worn
    local error_list = {} -- Gear that cannot be equipped for whatever reason
    local priorities = Priorities:new()
    for slot_id,slot_name in pairs(default_slot_map) do
        local name,priority,augments,designated_bag = expand_entry(equip_list[slot_name])
        priorities[slot_id] = priority
        if name == empty then
            equip_list[slot_name] = nil
            if cur_equip[slot_name].slot ~= empty then
                ret_list[slot_id] = {bag_id=0,slot=empty}
            end
        elseif name and cur_equip[slot_name].slot ~= empty then
            local item_tab = items[to_windower_bag_api(res.bags[cur_equip[slot_name].bag_id].en)][cur_equip[slot_name].slot]
            if name_match(item_tab.id,name) and
            (not augments or (#augments ~= 0 and extdata.compare_augments(augments,extdata.decode(item_tab).augments))) and
            (not designated_bag or designated_bag == cur_equip[slot_name].bag_id) then
                equip_list[slot_name] = nil
                used_list[slot_id] = {bag_id=cur_equip[slot_name].bag_id,slot=cur_equip[slot_name].slot}
            end
        end
    end
    
    for _,bag in pairs(equippable_item_bags) do
        for _,item_tab in ipairs(items[to_windower_bag_api(bag.en)]) do -- Iterate over the current bag
            if type(item_tab) == 'table' and check_wearable(item_tab.id) then
                if item_tab.status == 0 or item_tab.status == 5 then
                    for slot_id in res.items[item_tab.id].slots:it() do
                        local slot_name = default_slot_map[slot_id]
                        -- equip_list[slot_name] can also be a table (that doesn't contain a "name" property) or a number, which are both cases that should not generate any kind of equipment changing.
                        -- Hence the "and name" below.
                        if not ret_list[slot_id] and equip_list[slot_name] then -- If we haven't already found something for this slot and still want to equip something there
                            -- Make sure we're not already planning to equip this item in another slot.
                            if  (slot_id == 0  and used_list[1]  and used_list[1].bag_id  == bag.id and used_list[1].slot  == item_tab.slot) or -- main vs. sub
                                (slot_id == 1  and used_list[0]  and used_list[0].bag_id  == bag.id and used_list[0].slot  == item_tab.slot) or -- sub vs. main
                                (slot_id == 11 and used_list[12] and used_list[12].bag_id == bag.id and used_list[12].slot == item_tab.slot) or --left_earring vs. right_earring
                                (slot_id == 12 and used_list[11] and used_list[11].bag_id == bag.id and used_list[11].slot == item_tab.slot) or --right_earring vs. left_earring
                                (slot_id == 13 and used_list[14] and used_list[14].bag_id == bag.id and used_list[14].slot == item_tab.slot) or --left_ring vs. right_ring
                                (slot_id == 14 and used_list[13] and used_list[13].bag_id == bag.id and used_list[13].slot == item_tab.slot) then --right_ring vs. left_ring
                                    break
                            end
                            local name,priority,augments,designated_bag = expand_entry(equip_list[slot_name])
                            
                            if (not designated_bag or designated_bag == bag.id) and name and name_match(item_tab.id,name) then
                                if augments and #augments ~= 0 then
                                    if res.items[item_tab.id].flags.Rare or extdata.compare_augments(augments,extdata.decode(item_tab).augments) then
                                    -- Check if the augments are right
                                    -- If the item is Rare, then even if the augments are wrong try to equip it anyway because you only have one
                                        equip_list[slot_name] = nil
                                        ret_list[slot_id] = {bag_id=bag.id,slot=item_tab.slot}
                                        used_list = ret_list[slot_id]
                                        break
                                    --else the piece specifies augments that don't match the current piece, so don't break and keep trying.
                                    end
                                else
                                    equip_list[slot_name] = nil
                                    ret_list[slot_id] = {bag_id=bag.id,slot=item_tab.slot}
                                    used_list = ret_list[slot_id]
                                    break
                                end
                            end
                        end
                    end
                else -- item_tab.status > 0
                    for slot_id in res.items[item_tab.id].slots:it() do
                        local slot_name = default_slot_map[slot_id]
                        local name = expand_entry(equip_list[slot_name])
                        if name and name ~= empty then -- If "name" isn't a piece of gear, then it won't have a valid value at this point and should be ignored.
                            if name_match(item_tab.id,name) then
                                if item_tab.status == 25 then
                                    error_list[slot_name] = name..' (bazaared)'
                                else
                                    error_list[slot_name] = name..' (status unknown: '..item_tab.status..' )'
                                end
                                break
                            end
                        end
                    end
                end
            else
                for __,slot_name in pairs(default_slot_map) do
                    local name = expand_entry(equip_list[slot_name])
                    if name ~= empty and name_match(item_id,name) then
                        if not res.items[item_tab.id].jobs[player.main_job_id] then
                            equip_list[slot_name] = nil
                            error_list[slot_name] = name..' (cannot be worn by this job)'
                        elseif not (res.items[item_tab.id].level<=player.jobs[player.main_job]) then
                            equip_list[slot_name] = nil
                            error_list[slot_name] = name..' (job level is too low)'
                        elseif not res.items[item_tab.id].races[player.race_id] then
                            equip_list[slot_name] = nil
                            error_list[slot_name] = name..' (cannot be worn by your race)'
                        elseif not res.items[item_tab.id].slots then
                            equip_list[slot_name] = nil
                            error_list[slot_name] = name..' (cannot be worn)'
                        end
                        break
                    end
                end
            end
        end
    end
    
    if _settings.debug_mode and table.length(error_list) > 0 then
        print_set(error_list,'Debug Mode (error list)')
    end
    if _settings.debug_mode and table.length(equip_list) > 0 then
        print_set(equip_list,'Debug Mode (gear not equipped)')
    end
    
    return ret_list,priorities
end

-----------------------------------------------------------------------------------
--Name: to_names_set(equipment)
--Args:
---- equipment - Mapping of equipment slot ID or slot name to a table containing
----   bag_id and inventory slot ID. If already indexed to a number, treat it as a slot index.
----   Otherwise, damn the torpedoes and tostring it.
-----------------------------------------------------------------------------------
--Returns:
---- Set with a mapping of slot name to equipment name.
---- 'empty' is used as a replacement for the empty table.
-----------------------------------------------------------------------------------
function to_names_set(equipment)
    local equip_package = {}
    
    for ind,cur_item in pairs(equipment) do
        local name = 'empty'
        if type(cur_item) == 'table' and cur_item.slot ~= empty then
            if items[to_bag_api(res.bags[cur_item.bag_id].english)][cur_item.slot].id == 0 then return {} end
            -- refresh_player() can run after equip packets arrive but before the item array is fully loaded,
            -- which results in the id still being the initialization value.
            name = res.items[items[to_bag_api(res.bags[cur_item.bag_id].english)][cur_item.slot].id][language]
        end
        
        if tonumber(ind) and ind >= 0 and ind <= 15 and math.floor(ind) == ind then
            equip_package[toslotname(ind)] = name
        else
            equip_package[tostring(ind)] = name
        end
    end

    return equip_package
end


-----------------------------------------------------------------------------------
--Name: equip_piece(eq_slot_id,bag_id,inv_slot_id)
--Desc: Cleans up the global table and leaves equip_sets properly.
--Args:
---- eq_slot_id - Equipment Slot ID
---- bag_id - Bag ID of the item to be equipped
---- inv_slot_id - Inventory Slot ID of the item to be equipped
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function equip_piece(eq_slot_id,bag_id,inv_slot_id)
    -- Many complicated, wow!
    local cur_eq_tab = items.equipment[toslotname(eq_slot_id)]
    
    if cur_eq_tab.slot ~= empty then
        items[to_bag_api(res.bags[cur_eq_tab.bag_id].english)][cur_eq_tab.slot].status = 0
        -- This does not account for items like Onca Suit which take up multiple slots
    end
    
    if inv_slot_id ~= empty then
        --items.equipment[toslotname(eq_slot_id)] = {slot=inv_slot_id,bag_id=bag_id}
        items[to_bag_api(res.bags[bag_id].english)][inv_slot_id].status = 5
        local minichunk = string.char(inv_slot_id,eq_slot_id,bag_id,0)
        injected_equipment_registry[minichunk:byte(2)]:append(minichunk:sub(1,3))
        return minichunk
    else
        --items.equipment[toslotname(eq_slot_id)] = {slot=empty,bag_id=0}
        local minichunk = string.char(0,eq_slot_id,0,0)
        injected_equipment_registry[minichunk:byte(2)]:append(minichunk:sub(1,3))
        return minichunk
    end
end