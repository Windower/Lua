--[[
findAll v1.20130524

Copyright (c) 2013, Giuliano Riccio
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of findAll nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Giuliano Riccio BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

require 'lists'
require 'sets'

local json  = require 'json'
local file  = require 'filehelper'
local slips = require 'slips'

local findall = {}
findall.load_timestamp         = os.time()
findall.deferral_time          = 20
findall.item_names             = T{}
findall.global_storages        = {}
findall.storages_path          = 'data/storages.json'
findall.storages_order         = L{'inventory', 'safe', 'storage', 'locker', 'satchel', 'sack'}
findall.storage_slips_order    = L{'slip 01', 'slip 02', 'slip 03', 'slip 04', 'slip 05', 'slip 06', 'slip 07', 'slip 08', 'slip 09', 'slip 10', 'slip 11', 'slip 12', 'slip 13', 'slip 14'}
findall.merged_storages_orders = L{}:extend(findall.storages_order):extend(findall.storage_slips_order)
findall.resources              = {
    ['armor']   = '../../plugins/resources/items_armor.xml',
    ['weapons'] = '../../plugins/resources/items_weapons.xml',
    ['general'] = '../../plugins/resources/items_general.xml'
}

function findall.search(query)
    if findall.global_storages ~= nil then
        if not findall.update() then
            return
        end
    end

    if query:length() == 0 then
        return
    end

    local character_filters = S{}
    local terms            = ''

    for _, query_element in ipairs(query) do
        if query_element:find('^:%a+$') then
            character_filters:add(query_element:match('^:(%a+)$'):lower():gsub("^%l", string.upper))
        else
            terms = query_element
        end
    end

    if character_filters:length() == 0 and terms == '' then
        return
    end

    local new_item_ids = S{}

    for character_name, storages in pairs(findall.global_storages) do
        for storage_name, storage in pairs(storages) do
            for id, quantity in pairs(storage) do
                id = tostring(id)

                if findall.item_names[id] == nil then
                    new_item_ids:add(tostring(id))
                end
            end
        end
    end

    if new_item_ids:length() > 0 then
        for kind, resource_path in pairs(findall.resources) do
            resource = io.open(lua_base_path..resource_path, 'r')

            if resource ~= nil then
                while true do
                    local line = resource:read()

                    if line == nil then
                        break
                    end

                    local id, long_name, name = line:match('id="(%d+)" enl="([^"]+)".+>([^<]+)<')

                    if id ~= nil then
                        id = tostring(id)

                        if findall.item_names[id] == nil
                            and new_item_ids:contains(id)
                        then
                            findall.item_names[id] = {
                                ['name']      = name:lower(),
                                ['long_name'] = long_name:lower()
                            }
                        end
                    end
                end
            else
                write(kind..' resource file not found')
            end

            resource:close()
        end
    end

    local results_items = S{}

    for id, names in pairs(findall.item_names) do
        if findall.item_names[id].name:find(terms)
            or findall.item_names[id].long_name:find(terms)
        then
            results_items:add(id)
        end
    end

    add_to_chat(55, 'lua:addon:findAll >> searching: '..query:concat(' '))

    local no_results   = true
    local sorted_names = findall.global_storages:keyset():sort()
                                                       :reverse()

    sorted_names = sorted_names:append(sorted_names:remove(sorted_names:find(get_player().name)))
                               :reverse()

    for _, character_name in ipairs(sorted_names) do
        if character_filters:length() == 0 or character_filters:length() > 0 and character_filters:contains(character_name) then
            local storages = findall.global_storages[character_name]

            for _, storage_name in ipairs(findall.merged_storages_orders) do
                local results = L{}

                if storages[storage_name] ~= nil then
                    for id, quantity in pairs(storages[storage_name]) do
                        if results_items:contains(id) then
                            results:append(
                                '\30\03'..character_name..'/'..storage_name..':\30\01 '..
                                findall.item_names[id].name:gsub(terms, '\30\02'..terms..'\30\01')..
                                (quantity > 1 and ' \30\03('..quantity..')\30\01' or '')
                            )

                            no_results = false
                        end
                    end

                    results:sort()

                    for _, result in ipairs(results) do
                        add_to_chat(55, result)
                    end
                end
            end
        end
    end

    if no_results then
        if terms ~= '' then
            if character_filters:length() == 0 then
                add_to_chat(55, 'lua:addon:findAll >> you have no items that match \''..terms..'\'')
            else
                add_to_chat(55, 'lua:addon:findAll >> you have no items that match \''..terms..'\' on the specified characters')
            end
        else
            add_to_chat(55, 'lua:addon:findAll >> you have no items on the specified characters')
        end
    end

    collectgarbage()
end

function findall.get_storages()
    local items    = get_items()
    local storages = {}

    for _, storage_name in ipairs(findall.storages_order) do
        storages[storage_name] = T{}

        for _, data in ipairs(items[storage_name]) do
            local id = tostring(data.id)

            if id ~= "0" then
                if storages[storage_name][id] == nil then
                    storages[storage_name][id] = data.count
                else
                    storages[storage_name][id] = storages[storage_name][id] + data.count
                end
            end
        end
    end

    local slip_storages = slips.get_player_items()

    for _, slip_id in ipairs(slips.storages) do
        local slip_name     = 'slip '..tostring(slips.get_slip_number_by_id(slip_id)):lpad('0', 2)
        storages[slip_name] = T{}

        for _, id in ipairs(slip_storages[slip_id]) do
            storages[slip_name][tostring(id)] = 1
        end
    end

    return storages
end

function findall.update()
    local time_difference = os.time() - findall.load_timestamp

    if time_difference < findall.deferral_time then
        add_to_chat(55, 'lua:addon:findAll >> findAll will be available in '..(findall.deferral_time - time_difference)..' seconds')

        return false
    end

    local player_name   = get_player().name
    local storages_file = file.new(findall.storages_path)

    if not storages_file:exists() then
        storages_file:create()
    end

    findall.global_storages = json.read(storages_file)

    if findall.global_storages == nil then
        findall.global_storages = {}
    end

    findall.global_storages[player_name] = findall.get_storages()

    -- build json string
    local characters_json = L{}

    for character_name, storages in pairs(findall.global_storages) do
        local storages_json = L{}

        for storage_name, storage in pairs(storages) do
            local items_json = L{}

            for id, quantity in pairs(storage) do
                items_json:append('"'..id..'":'..quantity)
            end

            storages_json:append('"'..storage_name..'":{'..items_json:concat(',')..'}')
        end

        characters_json:append('"'..character_name..'":{'..storages_json:concat(',')..'}')
    end

    storages_file:write('{'..characters_json:concat(',')..'}')

    collectgarbage()

    return true
end

function event_load()
    send_command('alias findall lua c findall')

    if get_ffxi_info().logged_in then
        findall.update()
    end
end

function event_unload()
    send_command('unalias findall')

    if get_ffxi_info().logged_in then
        if not findall.update() then
            add_to_chat(38, 'lua:addon:findAll >> findAll wasn\'t ready')
        end
    end
end

function event_login()
    findall.load_timestamp = os.time();
end

function event_zone_change()
    findall.load_timestamp = os.time();
end

function event_logout()
    if not findall.update() then
        add_to_chat(38, 'lua:addon:findAll >> findAll wasn\'t ready')
    end
end

function event_addon_command(...)
    if not get_ffxi_info().logged_in then
        write('you have to be logged in to use this addon')
    end

    local params = L{...}
    local query  = L{}

    while params:length() > 0 and params[1]:match('^:%a+$') do
        query:append(params:remove(1))
    end

    if params:length() > 0 then
        query:append(params:concat(' '))
    end

    findall.search(query)
end
