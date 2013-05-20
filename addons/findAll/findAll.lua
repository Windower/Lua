--[[
findAll v1.20130520

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

local json = require 'json'
local file = require 'filehelper'

local findAll = {}
findAll.loadTimestamp  = os.time()
findAll.deferralTime   = 20
findAll.itemNames      = T{}
findAll.globalStorages = {}
findAll.storagesPath   = 'data/storages.json'
findAll.storagesOrder  = {'inventory', 'safe', 'storage', 'locker', 'satchel', 'sack'}
findAll.resources      = {
    ['armor']   = '../../plugins/resources/items_armor.xml',
    ['weapons'] = '../../plugins/resources/items_weapons.xml',
    ['general'] = '../../plugins/resources/items_general.xml'
}

function findAll.search(query)
    if findAll.globalStorages ~= nil then
        if not findAll.update() then
            return
        end
    end

    if query == '' then
        return
    end

    query = query:lower()

    local newItemIds = S{}

    for characterName, storages in pairs(findAll.globalStorages) do
        for storageName, storage in pairs(storages) do
            for id, quantity in pairs(storage) do
                id = tostring(id)

                if type(findAll.itemNames[id]) == 'nil'then
                    newItemIds:add(tostring(id))
                end
            end
        end
    end

    if newItemIds:length() > 0 then
        for kind, resourcePath in pairs(findAll.resources) do
            resource = io.open(lua_base_path..resourcePath, 'r')

            if resource ~= nil then
                while true do
                    local line = resource:read()

                    if line == nil then
                        break
                    end

                    local id, longName, name = line:match('id="(%d+)" enl="([^"]+)".+>([^<]+)<')

                    if id ~= nil then
                        id = tostring(id)

                        if type(findAll.itemNames[id]) == 'nil'
                            and newItemIds:contains(id)
                        then
                            findAll.itemNames[id] = {
                                ['name']     = name:lower(),
                                ['longName'] = longName:lower()
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

    local resultsItems = S{}

    for id, names in pairs(findAll.itemNames) do
        if findAll.itemNames[id].name:find(query)
            or findAll.itemNames[id].longName:find(query)
        then
            resultsItems:add(id)
        end
    end

    local noResults   = true
    local sortedNames = findAll.globalStorages:keyset():sort()
                                                       :reverse()

    sortedNames = sortedNames:append(sortedNames:remove(sortedNames:find(get_player().name)))
                             :reverse()

    for _, characterName in pairs(sortedNames) do
        local storages = findAll.globalStorages[characterName]

        for _, storageName in pairs(findAll.storagesOrder) do
            local results = L{}

            for id, quantity in pairs(storages[storageName]) do
                if resultsItems:contains(id) then
                    results:append(
                        '\30\03'..characterName..'/'..storageName..':\30\01 '..
                        findAll.itemNames[id].name:gsub(query, '\30\02'..query..'\30\01')..
                        (quantity > 1 and ' \30\03('..quantity..')\30\01' or '')
                    )

                    noResults = false
                end
            end

            results:sort()

            for _, result in ipairs(results) do
                add_to_chat(55, result)
            end
        end
    end

    if noResults then
        add_to_chat(55, 'lua:addon:findAll >> you have no items that match \''..query..'\'')
    end

    collectgarbage()
end

function findAll.getStorages()
    local items    = get_items()
    local storages = {}

    for _, storageName in pairs(findAll.storagesOrder) do
        storages[storageName] = T{}

        for _, data in pairs(items[storageName]) do
            local id = tostring(data.id)

            if id ~= "0" then
                if type(storages[storageName][id]) == 'nil' then
                    storages[storageName][id] = data.count
                else
                    storages[storageName][id] = storages[storageName][id] + data.count
                end
            end
        end
    end

    return storages
end

function findAll.update()
    local timeDifference = os.time() - findAll.loadTimestamp

    if timeDifference < findAll.deferralTime then
        add_to_chat(55, 'lua:addon:findAll >> findAll will be available in '..(findAll.deferralTime - timeDifference)..' seconds')

        return false
    end

    local playerName   = get_player().name
    local storagesFile = file.new(findAll.storagesPath)

    if not storagesFile:exists() then
        storagesFile:create()
    end

    findAll.globalStorages = json.read(storagesFile)

    if findAll.globalStorages == nil then
        findAll.globalStorages = {}
    end

    findAll.globalStorages[playerName] = findAll.getStorages()

    -- build json string
    local charactersJson = L{}

    for characterName, storages in pairs(findAll.globalStorages) do
        local storagesJson = L{}

        for storageName, storage in pairs(storages) do
            local itemsJson = L{}

            for id, quantity in pairs(storage) do
                itemsJson:append('"'..id..'":'..quantity)
            end

            storagesJson:append('"'..storageName..'":{'..itemsJson:concat(',')..'}')
        end

        charactersJson:append('"'..characterName..'":{'..storagesJson:concat(',')..'}')
    end

    storagesFile:write('{'..charactersJson:concat(',')..'}')

    collectgarbage()

    return true
end

function event_load()
    send_command('alias findall lua c findall')

    if get_ffxi_info().logged_in then
        findAll.update()
    end
end

function event_unload()
    send_command('unalias findall')

    if get_ffxi_info().logged_in then
        if not findAll.update() then
            add_to_chat(38, 'lua:addon:findAll >> findAll wasn\'t ready')
        end
    end
end

function event_login()
    findAll.loadTimestamp = os.time();
end

function event_logout()
    if not findAll.update() then
        add_to_chat(38, 'lua:addon:findAll >> findAll wasn\'t ready')
    end
end

function event_addon_command(...)
    if not get_ffxi_info().logged_in then
        write('you have to be logged in to use this addon')
    end

    findAll.search(T{...}:concat(' '))
end
