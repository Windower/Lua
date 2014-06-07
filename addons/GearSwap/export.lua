function export_set(options)
    --local temp_items,item_list = windower.ffxi.get_items(),{}
    local item_list = {}
    local targinv,xml,all_sets
    if #options > 0 then
        for _,v in ipairs(options) do
            if v:lower() == 'inventory' then
                targinv = true
            elseif v:lower() == 'xml' then
                xml = true
            elseif v:lower() == 'sets' then
                all_sets = true
                if not user_env or not user_env.sets then
                    windower.add_to_chat(123,'GearSwap: Cannot export the sets table of the current file because there is no file loaded.')
                    return
                end
            end
        end
    end
    
    local buildmsg = 'GearSwap: Exporting '
    if targinv then
        buildmsg = buildmsg..'your current inventory'
    elseif all_sets then
        buildmsg = buildmsg..'your current sets table'
    else
        buildmsg = buildmsg..'your currently equipped gear'
    end
    if xml then
        buildmsg = buildmsg..' as an xml file.'
    else
        buildmsg = buildmsg..' as a lua file.'
    end
    windower.add_to_chat(123,buildmsg)
    
    if not windower.dir_exists(windower.addon_path..'data/export') then
        windower.create_dir(windower.addon_path..'data/export')
    end
    
    local inv = items.inventory
    if targinv then
        -- Load the entire inventory
        for _,v in pairs(inv) do
            if v.id ~= 0 then
                if res.items[v.id] then
                    item_list[#item_list+1] = {}
                    item_list[#item_list].name = res.items[v.id][language]
                    local potslots,slot = res.items[v.id].slots
                    if potslots then
                        slot = res.slots[potslots:it()()].english:gsub(' ','_'):lower() -- Multi-lingual support requires that we add more languages to slots.lua
                    end
                    item_list[#item_list].slot = slot or 'item'
                    if not xml then
                        local augments = extdata.decode(v).augments or {}
                        local aug_str = ''
                        for aug_ind,augment in pairs(augments) do
                            if augment ~= 'none' then aug_str = aug_str.."'"..augment.."'," end
                        end
                        if string.len(aug_str) > 0 then
                            item_list[#item_list].augments = aug_str
                        end
                    end
                else
                    windower.add_to_chat(123,'GearSwap: You possess an item that is not in the resources yet.')
                end
            end
        end
    elseif all_sets then
        -- Iterate through user_env.sets and find all the gear.
        item_list,exported = unpack_names({},'L1',user_env.sets,{},{empty=true})
    else
        -- Default to loading the currently worn gear.
        local gear = convert_equipment(items.equipment)
        local ward = items.wardrobe
        for i,v in pairs(gear) do
            if v.slot ~= 0 then
                local item_tab
                if v.inv_id == 0 and res.items[inv[v.slot].id] then
                    item_tab = inv[v.slot]
                elseif v.inv_id == 8 and res.items[ward[v.slot].id] then
                    item_tab = ward[v.slot]
                end
                if res.items[item_tab.id] then
                    item_list[slot_map[i]+1] = {
                        name = res.items[item_tab.id][language],
                        slot = i
                        }
                    if not xml then
                        local augments = extdata.decode(item_tab).augments or {}
                        local aug_str = ''
                        for aug_ind,augment in pairs(augments) do
                            if augment ~= 'none' then aug_str = aug_str.."'"..augment.."'," end
                        end
                        if string.len(aug_str) > 0 then
                            item_list[slot_map[i]+1].augments = aug_str
                        end
                    end
                else
                    windower.add_to_chat(123,'GearSwap: You are wearing an item that is not in the resources yet.')
                end
            end
        end
        for i = 1,16 do
            if not item_list[i] then
                item_list[i] = {}
                item_list[i].name = empty
                item_list[i].slot = default_slot_map[i-1]
            end
        end
    end
    
    if #item_list == 0 then
        windower.add_to_chat(123,'GearSwap: There is nothing to export.')
        return
    else
        local not_empty
        for i,v in pairs(item_list) do
            if v.name ~= empty then
                not_empty = true
                break
            end
        end
        if not not_empty then
            windower.add_to_chat(123,'GearSwap: There is nothing to export.')
            return
        end
    end
    
    
    if not windower.dir_exists(windower.addon_path..'data/export') then
        windower.create_dir(windower.addon_path..'data/export')
    end
    
    local path = windower.addon_path..'data/export/'..player.name..os.date(' %H %M %S%p  %y-%d-%m')
    if xml then
        -- Export in .xml
        if windower.file_exists(path..'.xml') then
            path = path..' '..os.clock()
        end
        local f = io.open(path..'.xml','w+')
        f:write('<spellcast>\n  <sets>\n    <group name="exported">\n      <set name="exported">\n')
        for i,v in ipairs(item_list) do
            if v.name ~= empty then
                local slot = xmlify(tostring(v.slot))
                local name = xmlify(tostring(v.name))
                f:write('        <'..slot..'>'..name..'</'..slot..'>\n')
            end
        end
        f:write('      </set>\n    </group>\n  </sets>\n</spellcast>')
        f:close()
    else
        -- Default to exporting in .lua
        if windower.file_exists(path..'.lua') then
            path = path..' '..os.clock()
        end
        local f = io.open(path..'.lua','w+')
        f:write('sets.exported={\n')
        for i,v in ipairs(item_list) do
            if v.name ~= empty then
                if v.augments then
                    --Advanced set table
                    f:write('    '..v.slot..'={ name="'..v.name..'", augments={'..v.augments..'}},\n')
                else
                    f:write('    '..v.slot..'="'..v.name..'",\n')
                end
            end
        end
        f:write('}')
        f:close()
    end
end

function unpack_names(ret_tab,up,tab_level,unpacked_table,exported)
    for i,v in pairs(tab_level) do
        local flag,alt
        if type(v)=='table' and not ret_tab[tostring(tab_level[i])] then
            ret_tab[tostring(tab_level[i])] = true
            unpacked_table,exported = unpack_names(ret_tab,i,v,unpacked_table,exported)
        elseif i=='name' then
            alt = up
            flag = true
        elseif type(v) == 'string' and v~='augment' and v~= 'augments' and v~= 'order' then
            alt = i
            flag = true
        end
        if flag then
            if not exported[v:lower()] then
                unpacked_table[#unpacked_table+1] = {}
                local tempname,tempslot = unlogify_unpacked_name(v)
                unpacked_table[#unpacked_table].name = tempname
                unpacked_table[#unpacked_table].slot = tempslot or alt
                exported[tempname:lower()] = true
                exported[v:lower()] = true
            end
        end
    end
    return unpacked_table,exported
end

function unlogify_unpacked_name(name)
    local slot
    name = name:lower()
    for i,v in pairs(res.items) do
        if type(v) == 'table' then
            if v[language..'_log']:lower() == name then
                name = v[language]
                local potslots = v.slots
                if potslots then potslots = res.slots[potslots:it()()].english:gsub(' ','_') end
                slot = potslots or 'item'
                break
            elseif v[language]:lower() == name then
                name = v[language]
                local potslots = v.slots
                if potslots then potslots = res.slots[potslots:it()()].english:gsub(' ','_') end
                slot = potslots or 'item'
                break
            end
        end
    end
    return name,slot
end

function xmlify(phrase)
    if tonumber(phrase:sub(1,1)) then phrase = 'NUM'..phrase end
    return phrase --:gsub('"','&quot;'):gsub("'","&apos;"):gsub('<','&lt;'):gsub('>','&gt;'):gsub('&&','&amp;')
end