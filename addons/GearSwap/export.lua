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



function export_set(options)
    local filename_index = table.find(options, set.contains+{S{'filename', 'file', 'f'}})
    local filename = filename_index ~= nil and options[filename_index+1]
    if filename_index and not filename then
        msg.addon_msg(123, 'Cannot export to named file because a filename was not provided.')
        return
    end

    local setname_index = table.find(options, set.contains+{S{'setname', 'name', 'n'}})
    local setname = setname_index ~= nil and options[setname_index+1]
    if setname_index and not setname then
        msg.addon_msg(123, 'Cannot export to named set because a set name was not provided.')
        return
    end

    local options = S(options):map(string.lower)
    local contains_any = function(...) return not (options * S{...}):empty() end
    local check_exclusive = function(...) return #T{...}:filter(true) > 1 end

    local targinv = contains_any('inventory', 'inv', 'i')
    local all_items = contains_any('all')
    local wearable = contains_any('wearable')
    local all_sets = contains_any('sets', 'set', 's')
    if all_sets and (not user_env or not user_env.sets) then
        msg.addon_msg(123, 'Cannot export the sets table of the current file because there is no file loaded.')
        return
    end

    local noaugments = contains_any('noaugments', 'noaugs')
    local onlyaugmented = contains_any('onlyaugmented', 'onlyaugs')
    if check_exclusive(noaugments, onlyaugmented) then
        msg.addon_msg(123, 'Cannot export: "noaugments" and "onlyaugmented" are mutually exclusive.')
        return
    end

    local minify = contains_any('mini', 'minify')

    local compact = contains_any('compact')
    local bgwiki = contains_any('bgwiki')
    if check_exclusive(compact) then
        msg.addon_msg(123, 'Cannot export: "compact" and "bgwiki" are mutually exclusive.')
        return
    end

    local filename = filename
    local clipboard = contains_any('copy', 'clipboard')
    local use_job_in_filename = contains_any('mainjob')
    local use_subjob_in_filename = contains_any('mainsubjob')
    if check_exclusive(filename, clipboard, use_job_in_filename, use_subjob_in_filename) then
        msg.addon_msg(123, 'Cannot export: "filename", "clipboard", "use_job_in_filename", "use_subjob_in_filename" are mutually exclusive.')
        return
    end

    local overwrite_existing = contains_any('overwrite')

    local buildmsg = 'Exporting '
    if all_items then
        buildmsg = buildmsg .. 'all your items'
    elseif wearable then
        buildmsg = buildmsg .. 'all your items in inventory and wardrobes'
    elseif targinv then
        buildmsg = buildmsg .. 'your current inventory'
    elseif all_sets then
        buildmsg = buildmsg .. 'your current sets table'
    else
        buildmsg = buildmsg .. 'your currently equipped gear'
    end

    if noaugments then
        buildmsg = buildmsg .. ' (omitting augments)'
    elseif onlyaugmented then
        buildmsg = buildmsg .. ' (only augmented items)'
    end

    if compact then
        buildmsg = buildmsg .. ' in compact format'
    elseif bgwiki then
        buildmsg = buildmsg .. ' in BG-Wiki Template format'
    end

    if clipboard then
        buildmsg = buildmsg .. ' to clipboard.'
    elseif bgwiki then
        buildmsg = buildmsg .. ' as a text file.'
    else
        buildmsg = buildmsg .. ' as a lua file.'

        if filename then
            buildmsg = buildmsg .. ' (Named: Character_'..filename..')'
        elseif use_job_in_filename then
            buildmsg = buildmsg .. ' (Naming format: Character_JOB)'
        elseif use_subjob_in_filename then
            buildmsg = buildmsg .. ' (Naming format: Character_JOB_SUB)'
        end

        if overwrite_existing then
            buildmsg = buildmsg .. ' Will overwrite existing files with same name.'
        end
    end

    msg.addon_msg(123, buildmsg)

    local item_list = T{}
    if all_items then
        for i = 0, #res.bags do
            item_list:extend(get_item_list(items[res.bags[i].english:gsub(' ', ''):lower()]))
        end
    elseif wearable then
        for _, v in pairs(equippable_item_bags) do
            item_list:extend(get_item_list(items[v.english:gsub(' ', ''):lower()]))
        end
    elseif targinv then
        item_list:extend(get_item_list(items.inventory))
    elseif all_sets then
        -- Iterate through user_env.sets and find all the gear.
        item_list,exported = unpack_names({}, 'L1', user_env.sets,{},{empty=true})
    else
        -- Default to loading the currently worn gear.

        for i = 1,16 do -- ipairs will be used on item_list
            if not item_list[i] then
                item_list[i] = {}
                item_list[i].name = empty
                item_list[i].slot = toslotname(i-1)
            end
        end

        for slot_name,gs_item_tab in pairs(items.equipment) do
            if gs_item_tab.slot ~= empty then
                local item_tab
                local bag_name = to_windower_bag_api(res.bags[gs_item_tab.bag_id].en)
                if res.items[items[bag_name][gs_item_tab.slot].id] then
                    item_tab = items[bag_name][gs_item_tab.slot]
                    item_list[slot_map[slot_name]+1] = {
                        name = res.items[item_tab.id][language],
                        slot = slot_name
                        }
                    if not noaugments and not res.items[item_tab.id].flags:contains('Rare') then
                        local augments = extdata.decode(item_tab).augments or {}
                        local aug_str = ''
                        for aug_ind,augment in pairs(augments) do
                            if augment ~= 'none' then aug_str = aug_str .. "'"..augment:gsub("'","\\'") .. "'," end
                        end
                        if string.len(aug_str) > 0 then
                            item_list[slot_map[slot_name]+1].augments = aug_str
                        end
                    end
                else
                    msg.addon_msg(123,'You are wearing an item that is not in the resources yet.')
                end
            end
        end
    end

    if #item_list == 0 then
        msg.addon_msg(123, 'There is nothing to export.')
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
            msg.addon_msg(123, 'There is nothing to export.')
            return
        end
    end

    local newline = minify and '' or '\n'

    local output

    if setname then
        output = 'sets["' .. setname .. '"] = {' .. newline
    else
        output = 'sets.exported = {' .. newline
    end


    if compact then
        local slots_order = {
            { 'main', 'sub', 'range', 'ammo' },
            { 'head', 'neck', 'left_ear', 'right_ear' },
            { 'body', 'hands', 'left_ring', 'right_ring' },
            { 'back', 'waist', 'legs', 'feet' },
        }

        local item_list = item_list:rekey('slot')

        for _, row in ipairs(slots_order) do
            local line = {}

            for _, slot in ipairs(row) do
                local v = item_list[slot]

                if v and v.name ~= empty then
                    if v.augments then
                        --Advanced set table
                        table.insert(line, slot..'={ name="'..v.name..'", augments={'..v.augments..'}},')
                    elseif not onlyaugmented then
                        table.insert(line, slot..'="'..v.name..'",')
                    end
                end
            end

            if #line > 0 then
                output = output .. '    ' .. table.concat(line, ' ') .. newline
            end
        end

    elseif bgwiki then
        local wikiformat = {
            ['left_ear'] = 'Ear1',
            ['right_ear'] = 'Ear2',
            ['left_ring'] = 'Ring1',
            ['right_ring'] = 'Ring2',
        }

        output = '{{Guide Equipment Set\n|Set Name Background=\n|Set Name Text Color=\n|Set Name Text Shadow=\n'
        output = output .. '|Set Name=%s\n|Set Border Color=\n':format(setname or 'Exported')
        output = output .. '|Equipment Set = Exported by %s on %s\n':format(player.name, os.date(' %Y-%m-%d %H-%M-%S'))
        output = output .. '{{Equipment Set\n|CaptionTop = %s\n|CaptionBottom = Exported\n':format(setname or 'Exported')

        for i,v in ipairs(item_list) do
            if v.name ~= empty then
                local slot = v.slot:gsub('.*', wikiformat):ucfirst()

                output = output .. '| %s = %s\n':format(slot, v.name)
                if v.augments then
                    local augments = v.augments:gsub("[%'%\"]","%1")
                    output = output .. '| %sAug = %s\n':format(slot, augments)
                end
            end
        end

        output = output .. '|List = y\n|Background = \n}}\n|Equipment Set Notes =\n}'

    else
        for i,v in ipairs(item_list) do
            if v.name ~= empty then
                if v.augments then
                    --Advanced set table
                    output = output .. '    %s={ name="%s", augments={%s}},':format(v.slot, v.name, v.augments)
                elseif not onlyaugmented then
                    output = output .. '    %s="%s",':format(v.slot, v.name)
                end
                output = output .. newline
            end
        end
    end

    output = output .. '}'

    if clipboard then
        windower.copy_to_clipboard(output)
    else

        if not windower.dir_exists(windower.addon_path .. 'data/export') then
            windower.create_dir(windower.addon_path .. 'data/export')
        end

        local path = windower.addon_path .. 'data/export/' .. player.name

        if use_job_in_filename then
            path = path .. '_' .. windower.ffxi.get_player().main_job
        elseif use_subjob_in_filename then
            path = path .. '_' .. windower.ffxi.get_player().main_job .. '_' .. windower.ffxi.get_player().sub_job
        elseif filename then
            path = path .. '_' .. filename
        else
            path = path .. os.date(' %Y-%m-%d %H-%M-%S')
        end

        if (not overwrite_existing) and windower.file_exists(path .. '.lua') then
            path = path .. ' ' .. os.clock()
        end

        local file_ext = '.lua'
        if bgwiki then
            file_ext = '.txt'
        end

        local f = io.open(path .. file_ext, 'w+')
        f:write(output)
        f:close()
    end
end

function unpack_names(ret_tab,up,tab_level,unpacked_table,exported)
    for i,v in pairs(tab_level) do
        local flag,alt
        if type(v)=='table' and i ~= 'augments' and not ret_tab[tostring(tab_level[i])] then
            ret_tab[tostring(tab_level[i])] = true
            unpacked_table,exported = unpack_names(ret_tab,i,v,unpacked_table,exported)
        elseif i=='name' and type(v) == 'string' then
            alt = up
            flag = true
        elseif type(v) == 'string' and v~='augment' and v~= 'augments' and v~= 'priority' then
            alt = i
            flag = true
        end
        if flag then
            if not exported[v:lower()] then
                unpacked_table[#unpacked_table+1] = {}
                local tempname,tempslot = unlogify_unpacked_name(v)
                unpacked_table[#unpacked_table].name = tempname
                unpacked_table[#unpacked_table].slot = tempslot or alt
                if tab_level.augments then
                    local aug_str = ''
                    for aug_ind,augment in pairs(tab_level.augments) do
                        if augment ~= 'none' then aug_str = aug_str.."'"..augment:gsub("'","\\'").."'," end
                    end
                    if aug_str ~= '' then unpacked_table[#unpacked_table].augments = aug_str end
                end
                if tab_level.augment then
                    local aug_str = unpacked_table[#unpacked_table].augments or ''
                    if tab_level.augment ~= 'none' then aug_str = aug_str.."'"..augment:gsub("'","\\'").."'," end
                    if aug_str ~= '' then unpacked_table[#unpacked_table].augments = aug_str end
                end
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
                if potslots then potslots = to_windower_api(res.slots[potslots:it()()].english) end
                slot = potslots or 'item'
                break
            elseif v[language]:lower() == name then
                name = v[language]
                local potslots = v.slots
                if potslots then potslots = to_windower_api(res.slots[potslots:it()()].english) end
                slot = potslots or 'item'
                break
            end
        end
    end
    return name,slot
end

function get_item_list(bag)
    local items_in_bag = {}
    -- Load the entire inventory
    for _,v in pairs(bag) do
        if type(v) == 'table' and v.id ~= 0 then
            if res.items[v.id] then
                items_in_bag[#items_in_bag+1] = {}
                items_in_bag[#items_in_bag].name = res.items[v.id][language]
                local potslots,slot = copy_entry(res.items[v.id].slots)
                if potslots then
                    slot = res.slots[potslots:it()()].english:gsub(' ','_'):lower() -- Multi-lingual support requires that we add more languages to slots.lua
                end
                items_in_bag[#items_in_bag].slot = slot or 'item'
                local augments = extdata.decode(v).augments or {}
                local aug_str = ''
                for aug_ind,augment in pairs(augments) do
                    if augment ~= 'none' then aug_str = aug_str.."'"..augment:gsub("'","\\'").."'," end
                end
                if string.len(aug_str) > 0 then
                    items_in_bag[#items_in_bag].augments = aug_str
                end
            else
                msg.addon_msg(123,'You possess an item that is not in the resources yet.')
            end
        end
    end
    return items_in_bag
end
