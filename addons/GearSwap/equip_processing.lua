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
--Name: check_wearable(item_id)
--Args:
---- item_id - Item ID to be examined
-----------------------------------------------------------------------------------
--Returns:
---- boolean indicating whether the given piece of gear can be worn or not
----    Checks for main job / level and race
-----------------------------------------------------------------------------------
function check_wearable(item_id)
    if not item_id or item_id == 0 then -- 0 codes for an empty slot, but Arcon will probably make it nil at some point
    elseif not res.items[item_id] then
        msg.debugging("Item "..item_id.." has not been added to resources yet.")
    elseif not res.items[item_id].jobs then -- Make sure item can be equipped by specific jobs (unlike pearlsacks).
        --msg.debugging('GearSwap (Debug Mode): Item '..(res.items[item_id][language] or item_id)..' does not have a jobs field in the resources.')
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
-----------------------------------------------------------------------------------
function expand_entry(entry)
    if not entry then
        return
    end
    local augments,name,priority,bag
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
            local bag_list = {inventory = 0, wardrobe = 8}
            bag = bag_list[entry.bag:lower()]
        end
    elseif type(entry) == 'string' and entry ~= '' then
        name = entry
    end
    return name,priority,augments,bag -- all nil if they don't exist
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
function unpack_equip_list(equip_list)
    local ret_list = {}
    local error_list = {}
    local priorities = Priorities:new()
    for slot_id,slot_name in pairs(default_slot_map) do
        local name,priority,extgoal_1,extgoal_2 = expand_entry(equip_list[slot_name])
        priorities[slot_id] = priority
        if name == empty then
            ret_list[slot_id] = {bag_id=0,slot=empty}
            equip_list[slot_name] = nil
        end
    end
    
    local inventories = {[0]=items.inventory,[8]=items.wardrobe}
    
    for bag_id,inventory in pairs(inventories) do
        for _,item_tab in ipairs(inventory) do
            if type(item_tab) == 'table' and check_wearable(item_tab.id) then
                if item_tab.status == 0 or item_tab.status == 5 then -- Make sure the item is either equipped or not otherwise committed. eliminate_redundant will take care of the already-equipped gear.
                    for slot_id,slot_name in pairs(default_slot_map) do
                        -- equip_list[slot_name] can also be a table (that doesn't contain a "name" property) or a number, which are both cases that should not generate any kind of equipment changing.
                        -- Hence the "and name" below.
                        
                        if not ret_list[slot_id] and equip_list[slot_name] then 
                            local name,priority,augments,bag = expand_entry(equip_list[slot_name])
                            
                            if (not bag or bag == bag_id) and name and name_match(item_tab.id,name) then
                                if res.items[item_tab.id].slots[slot_id] then
                                    if augments and #augments ~=0 then
                                        if extdata.compare_augments(augments,extdata.decode(item_tab).augments) then
                                            equip_list[slot_name] = nil
                                            ret_list[slot_id] = {bag_id=bag_id,slot=item_tab.slot}
                                            break
                                        end
                                    else
                                        equip_list[slot_name] = nil
                                        ret_list[slot_id] = {bag_id=bag_id,slot=item_tab.slot}
                                        break
                                    end
                                else
                                    equip_list[slot_name] = nil
                                    error_list[slot_name] = name..' (cannot be worn in this slot)'
                                    break
                                end
                            end
                        end
                    end
                elseif item_tab.status > 0 then
                    for __,slot_name in pairs(default_slot_map) do
                        local name = expand_entry(equip_list[slot_name])
                        if name and name ~= empty then -- If "name" isn't a piece of gear, then it won't have a valid value at this point and should be ignored.
                            if name_match(item_tab.id,name) then
                                if item_tab.status == 5 then
                                    error_list[slot_name] = name..' (equipped)'
                                elseif item_tab.status == 25 then
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
                    if name == empty then
                    elseif name_match(item_id,name) then
                        if not res.items[item_tab.id].jobs[player.main_job_id] then
                            equip_list[slot_name] = nil
                            error_list[slot_name] = name..' (cannot be worn by this job)'
                        elseif not (res.items[item_tab.id].level<=player.jobs[player.main_job]) then
                            equip_list[slot_name] = nil
                            error_list[slot_name] = name..' (job level is too low)'
                        elseif not res.items[item_tab.id].races[player.race_id] then
                            equip_list[slot_name] = nil
                            error_list[slot_name] = name..' (cannot be worn by your race)'
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
--Name: eliminate_redundant(current_gear,equip_next)
--Args:
---- current_gear - Mapping of currently worn equipment
---- equip_next   - Mapping of equipment that you want to equip
-----------------------------------------------------------------------------------
--Returns:
---- Set with all duplicate entries eliminated.
---- empty tables are processed separately, because an unlimited number can be equipped.
-----------------------------------------------------------------------------------
function eliminate_redundant(current_gear,equip_next)
    for eq_slot,cur_item in pairs(current_gear) do
        if cur_item.slot == empty then
            if equip_next[slot_map[eq_slot]] and equip_next[slot_map[eq_slot]].slot == empty then
                equip_next[slot_map[eq_slot]] = nil
            end
        else
            for n,m in pairs(equip_next) do
                if m.slot ~= empty and cur_item.bag_id == m.bag_id and cur_item.slot==m.slot then
                    -- If it is already equipped somewhere else, eliminate it.
                    -- Could add more complicated handling here to control the order of equipped
                    -- gear and allow people to do things like swap fingers for rings.
                    equip_next[n] = nil
                end
            end
        end
    end
    return equip_next
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
            if items[to_windower_api(res.bags[cur_item.bag_id].english)][cur_item.slot].id == 0 then return {} end
            -- refresh_player() can run after equip packets arrive but before the item array is fully loaded,
            -- which results in the id still being the initialization value.
            name = res.items[items[to_windower_api(res.bags[cur_item.bag_id].english)][cur_item.slot].id][language]
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
        items[to_windower_api(res.bags[cur_eq_tab.bag_id].english)][cur_eq_tab.slot].status = 0
    end
    
    if inv_slot_id ~= empty then
        items.equipment[toslotname(eq_slot_id)] = {slot=inv_slot_id,bag_id=bag_id}
        items[to_windower_api(res.bags[bag_id].english)][inv_slot_id].status = 5
        return string.char(inv_slot_id,eq_slot_id,bag_id,0)
    else
        items.equipment[toslotname(eq_slot_id)] = {slot=empty,bag_id=0}
        return string.char(0,eq_slot_id,0,0)
    end
end