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

function check_wearable(item_id)
    if not item_id or item_id == 0 then -- 0 codes for an empty slot, but Arcon will probably make it nil at some point
    elseif not res.items[item_id] then
        debug_mode_chat("Item '..item_id..' has not been added to resources yet.")
    elseif not res.items[item_id].jobs then -- Make sure item can be equipped by specific jobs (unlike pearlsacks).
        --debug_mode_chat('GearSwap (Debug Mode): Item '..(res.items[item_id][language] or item_id)..' does not have a jobs field in the resources.')
    else
        return (res.items[item_id].jobs[player.main_job_id]) and (res.items[item_id].level<=player.main_job_level) and (res.items[item_id].races[player.race_id])
    end
    return false
end

function expand_entry(v)
    if not v then
        return
    end
    local extgoal_1,extgoal_2,name,order = {},{}
    if type(v) == 'table' and v == empty then
        name = empty
    elseif type(v) == 'table' and v.name then
        name = v.name
        order = v.order
        if v.augments then
            for n,m in pairs(v.augments) do
                extgoal_1[n],extgoal_2[n] = augment_to_extdata(m)
            end
        elseif v.augment then
            extgoal_1[1],extgoal_2[1] = augment_to_extdata(v.augment)
        end
    elseif type(v) == 'string' and v ~= '' then
        name = v
    end
    return name,order,extgoal_1,extgoal_2 -- nil, nil, {}, {} if they don't exist
end

function name_match(item_id,name)
    if res.items[item_id] then
        return (res.items[item_id][language..'_log']:lower() == name:lower() or res.items[item_id][language]:lower() == name:lower())
    else
        return false
    end
end

-----------------------------------------------------------------------------------
--Name: to_id_set(inventory,equip_list)
--Args:
---- inventory - Current inventory (potentially avoids a get_items() call)
---- equip_list - Keys are standard slot names, values are item names.
-----------------------------------------------------------------------------------
--Returns:
---- Table with keys that are slot numbers with values that are inventory slot #s.
-----------------------------------------------------------------------------------
function to_id_set(inventory,equip_list)
    local ret_list = {}
    local error_list = {}
    for i,v in pairs(short_slot_map) do
        local name,order,extgoal_1,extgoal_2 = expand_entry(equip_list[i])
        if name == empty or name =='empty' then
            ret_list[v] = 0
            reorder(order,i)
            equip_list[i] = nil
        end
    end
    for n,m in pairs(inventory) do
        if check_wearable(m.id) then
            if m.status == 0 or m.status == 5 then -- Make sure the item is either equipped or not otherwise committed. eliminate_redundant will take care of the already-equipped gear.
                for i,v in pairs(short_slot_map) do
                    -- equip_list[i] can also be a table (that doesn't contain a "name" property) or a number, which are both cases that should not generate any kind of equipment changing.
                    -- Hence the "and name" below.
                    
                    if not ret_list[v] and equip_list[i] then 
                        local name,order,extgoal_1,extgoal_2 = expand_entry(equip_list[i])
                        
                        if name and name_match(m.id,name) then
                            if res.items[m.id].slots[v] then
                                if #extgoal_1 ~= 0 or #extgoal_2 ~=0 then
                                    local exttemp = m.extdata
                                    local count = 0

                                    for o,q in pairs(extgoal_1) do
                                    --  It appears only the first five bits are used for augment value.
                                    --    local first,second,third = string.char(m.extdata:byte(4)%32), string.char(m.extdata:byte(6)%32), string.char(m.extdata:byte(8)%32)
                                    --    local exttemp = m.extdata:sub(1,3)..first..m.extdata:sub(5,5)..second..m.extdata:sub(7,7)..third..m.extdata:sub(9)
                                        if exttemp:sub(3,4) == q or exttemp:sub(5,6) == q or exttemp:sub(7,8) == q then
                                            count = count +1
                                        end
                                    end
                                    if count == #extgoal_1 then
                                        equip_list[i] = nil
                                        ret_list[v] = m.slot
                                        reorder(order,i)
                                        break
                                    elseif #extgoal_2 ~= 0 then
                                        count = 0
                                        for o,q in pairs(extgoal_2) do
                                        --  It appears only the first five bits are used for augment value.
                                        --    local first,second,third = string.char(m.extdata:byte(4)%32), string.char(m.extdata:byte(6)%32), string.char(m.extdata:byte(8)%32)
                                        --    local exttemp = m.extdata:sub(1,3)..first..m.extdata:sub(5,5)..second..m.extdata:sub(7,7)..third..m.extdata:sub(9)
                                            if exttemp:sub(7,8) == q or exttemp:sub(9,10) == q or exttemp:sub(11,12) == q then
                                                count = count +1
                                            end
                                        end
                                        if count == #extgoal_2 then
                                            equip_list[i] = nil
                                            ret_list[v] = m.slot
                                            reorder(order,i)
                                            break
                                        end
                                    end
                                else
                                    equip_list[i] = nil
                                    ret_list[v] = m.slot
                                    reorder(order,i)
                                    break
                                end
                            elseif not res.items[m.id].slots[v] then
                                equip_list[i] = nil
                                error_list[i] = name..' (cannot be worn in this slot)'
                                break
                            end
                        end
                    end
                end
            elseif m.status > 0 then
                for i,v in pairs(short_slot_map) do
                    local name = expand_entry(equip_list[i])
                    if name and name ~= empty then -- If "name" isn't a piece of gear, then it won't have a valid value at this point and should be ignored.
                        if name_match(m.id,name) then
                            if m.status == 5 then
                                error_list[i] = name..' (equipped)'
                            elseif m.status == 25 then
                                error_list[i] = name..' (bazaared)'
                            else
                                error_list[i] = name..' (status unknown: '..m.status..' )'
                            end
                            break
                        end
                    end
                end
            end
        else
            for i,v in pairs(short_slot_map) do
                local name = expand_entry(equip_list[i])
                if name == empty then
                elseif name_match(item_id,name) then
                    if not res.items[m.id].jobs[player.main_job_id] then
                        equip_list[i] = nil
                        error_list[i] = name..' (cannot be worn by this job)'
                    elseif not (res.items[m.id].level<=player.main_job_level) then
                        equip_list[i] = nil
                        error_list[i] = name..' (job level is too low)'
                    elseif not res.items[m.id].races[player.race_id] then
                        equip_list[i] = nil
                        error_list[i] = name..' (cannot be worn by your race)'
                    end
                    break
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
    
    return ret_list
end

function reorder(order,i)
    if order and order < 17 and order > 0 then
        local temp_order
        for o,q in pairs(equip_order) do
            if q == slot_map[i] then
                temp_order = o -- o is the current slot of the item being redefined.
                break
            end
        end
        equip_order[temp_order] = equip_order[order]
        equip_order[order] = slot_map[i]
    elseif order then
        windower.add_to_chat(123,'GearSwap: Invalid order given')
    end
end

function eliminate_redundant(current_gear,equip_next) -- Eliminates gear you already wear from the table
    for i,v in pairs(current_gear) do
        if v == empty and (equip_next[slot_map[i]] == 0 or equip_next[slot_map[i]] == empty) then
            equip_next[slot_map[i]] = nil
        else
            for n,m in pairs(equip_next) do
                if v==m and v ~= 0 then
                    equip_next[n] = nil
                end
            end
        end
    end
    return equip_next
end

function to_names_set(id_id,inventory)
    local equip_package = {}
    for i,v in pairs(id_id) do
        if v~=0 and v~=empty then
            if inventory[v].id == 0 then
                equip_package[i]=''
            elseif type(i) ~= 'string' then
                equip_package[default_slot_map[i]] = res.items[inventory[v].id][language]
            else
                equip_package[i]=res.items[inventory[v].id][language]
            end
        else
            if type(i)~= 'string' then
                equip_package[default_slot_map[i]] = 'empty'
            else
                equip_package[i]='empty'
            end
        end
    end
    
    return equip_package
end

function get_gs_gear(cur_equip,swap_type)
    local temp_set = table.reassign({},cur_equip)
    local sent_out_box = 'Going into '..swap_type..':\n' -- i = 'head', 'feet', etc.; v = inventory ID (0~80)
    -- If the swap is not complete, overwrite the current equipment with the equipment that you are swapping to
--    local not_sent_ids = to_id_set(items.inventory,not_sent_out_equip)

    for i,v in pairs(cur_equip) do
        if limbo_equip[short_slot_map[i]] then
            cur_equip[i] = limbo_equip[short_slot_map[i]]
        elseif sent_out_equip[short_slot_map[i]] then
            cur_equip[i] = sent_out_equip[short_slot_map[i]]
--        elseif not_sent_ids[short_slot_map[i]] then
--            cur_equip[i] = not_sent_ids[short_slot_map[i]]
        end
        if v == 0 or v == 'empty' then
            cur_equip[i] = empty
        end
        if v and v ~= 0 and debugging > 0 and items.inventory[v] and res.items[items.inventory[v].id] then
            sent_out_box = sent_out_box..tostring(i)..' '..tostring(res.items[items.inventory[v].id].english)..'\n'
        end
    end
    if debugging > 0 and type(swap_type) == 'string' then windower.text.set_text(swap_type,sent_out_box) end
    return cur_equip
end