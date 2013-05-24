--[[
porter v1.20130524

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

function event_load()
    send_command('alias porter lua c porter')
end

function event_unload()
    send_command('unalias porter')
end

function event_addon_command(slip_number, slip_page)
    if slip_number == nil then
        add_to_chat(55, 'lua:addon:porter >> which slip do you want to see, kupo?')
        
        return
    end
    
    slip_number = tonumber(slip_number, 10)
    
    if slip_number < 1 or slip_number > slips.storages:length() then
        add_to_chat(55, 'lua:addon:porter >> that slip doesn\'t exist, kupo!')
        
        return
    end
    
    local player_items      = slips.get_player_items()
    local slip              = slips.get_slip(slip_number)
    local slip_id           = slips.get_slip_id(slip_number)
    local player_slip_items = S(player_items[slip_id])

    if porter.items_names:length() == 0 then
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

    local slip_items

    if slip_page == nil then
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
        add_to_chat(
            55,
            '\30\03'..'slip '..tostring(slip_number):lpad('0', 2)..'/page '..(slip_page and slip_page or tostring(math.ceil(item_position / 16))):lpad('0', 2)..':\30\01 '..
            '\30'..(player_slip_items:contains(item_id) and '\02' or '\05')..porter.items_names[item_id]..'\30\01'
        )
    end
end
