--[[
porter v1.20130525.1

Copyright (c) 2013, Giuliano Riccio
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of porter nor the
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

require 'sets'
require 'stringhelper'

local slips = require 'slips'

local porter = {}
porter.items_names = L{}
porter.resources   = {
    ['armor']   = '../../plugins/resources/items_armor.xml',
    ['weapons'] = '../../plugins/resources/items_weapons.xml',
    ['general'] = '../../plugins/resources/items_general.xml'
}

function porter.load_resources()
    local slips_items_ids = T()
    for _, slip in  pairs(slips.items) do
        slips_items_ids:extend(slip)
    end

    slips_items_ids = S(slips_items_ids)

    for kind, resource_path in pairs(porter.resources) do
        resource = io.open(lua_base_path..resource_path, 'r')

        if resource ~= nil then
            while true do
                local line = resource:read()

                if line == nil then
                    break
                end

                local id, name = line:match('id="(%d+)".+>([^<]+)<')

                if id ~= nil then
                    id = tonumber(id, 10)

                    if slips_items_ids:contains(id) then
                        porter.items_names[id] = name:lower()
                    end
                end
            end
        else
            write(kind..' resource file not found')
        end

        resource:close()
    end
end

function porter.show_slip(slip_number, slip_page, owned_only)
    if porter.items_names:length() == 0 then
        porter.load_resources()
    end
    
    owned_only = owned_only or false
    
    local player_items = slips.get_player_items()
    
    if slip_number ~= nil then
        slips_storage = L{slips.get_slip_id(slip_number)}
    else
        slips_storage = slips.storages
    end

    for _, slip_id in ipairs(slips_storage) do
        local slip                  = slips.get_slip_by_id(slip_id)
        local player_slip_items     = S(player_items[slip_id])
        local printable_slip_number = tostring(slips.get_slip_number_by_id(slip_id)):lpad('0', 2)

        if slip_number ~= nil
            or slip_number == nil and player_slip_items:length() > 0
        then
            local slip_items

            if slip_number == nil or slip_page == nil then
                slip_items = slip
            else
                local offset = (slip_page - 1) * 16 + 1

                if offset < 1 or offset > slip:length() then
                    add_to_chat(55, 'lua:addon:porter >> slip '..tostring(slip_number):lpad('0', 2)..' has no page '..slip_page..', kupo.')

                    return
                end

                slip_items = slip:slice(offset, offset + 15)
            end

            for item_position, item_id in ipairs(slip_items) do
                local is_contained = player_slip_items:contains(item_id)
                
                if owned_only == false or owned_only == true and is_contained == true then
                    add_to_chat(
                        55,
                        '\30\03'..'slip '..printable_slip_number..'/page '..(slip_page and slip_page or tostring(math.ceil(item_position / 16))):lpad('0', 2)..':\30\01 '..
                        '\30'..(is_contained and '\02' or '\05')..porter.items_names[item_id]..'\30\01'
                    )
                end
            end
        end
    end
end

function event_load()
    send_command('alias porter lua c porter')
end

function event_unload()
    send_command('unalias porter')
end

function event_addon_command(slip_number, slip_page, owned_only)
    if tonumber(slip_number) == nil and slip_number == 'owned' then
        slip_number = nil
        owned_only  = true
    elseif tonumber(slip_number) ~= nil and tonumber(slip_page) == nil and slip_page == 'owned' then
        slip_page  = nil
        owned_only = true
    elseif tonumber(slip_number) ~= nil and tonumber(slip_page) ~= nil and owned_only == 'owned' then
        owned_only = true
    else
        owned_only = false
    end

    if slip_number ~= nil then
        slip_number = tonumber(slip_number, 10)

        if slip_number < 1 or slip_number > slips.storages:length() then
            add_to_chat(55, 'lua:addon:porter >> that slip doesn\'t exist, kupo!')
            
            return
        end
    else
        slip_page = nil
    end
    
    porter.show_slip(slip_number, slip_page, owned_only)
end
