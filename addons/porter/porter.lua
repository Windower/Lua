--[[
porter v1.20130529

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

require 'chat'
require 'logger'
require 'sets'
require 'strings'
res = require 'resources'
slips = require 'slips'

_addon.name = 'porter'
_addon.version = '1.20200419'
_addon.command = 'porter'
_addon.author = 'Zohno'

function show_slip(slip_number, slip_page, owned_only)

    owned_only = owned_only or false

    local player_items = slips.get_player_items()

    if slip_number ~= nil then
        if slip_number < 1 or slip_number > slips.storages:length() then
            error('That slip doesn\'t exist, kupo!')

            return
        end

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
                    error('Slip '..tostring(slip_number):lpad('0', 2)..' has no page '..slip_page..', kupo.')

                    return
                end

                slip_items = slip:slice(offset, offset + 15)
            end

            for item_position, item_id in ipairs(slip_items) do
                local is_contained = player_slip_items:contains(item_id)

                if owned_only == false or owned_only == true and is_contained == true then
                    windower.add_to_chat(
                        55,
                        ('slip '..printable_slip_number..'/page '..tostring(slip_page and slip_page or math.ceil(item_position / 16)):lpad('0', 2)..':'):color(259)..' '..
                        res.items[item_id].name:color(is_contained and 258 or 261)
                    )
                end
            end
        end
    end
end

function show_bags()

    local n = 0

    for _, bag in ipairs(slips.default_storages) do
        for _, item in ipairs(windower.ffxi.get_items(bag)) do
            local slip_id = slips.get_slip_id_by_item_id(item.id)

            if slip_id then
                n = n + 1
                windower.add_to_chat(207, 'slip %02d: %s %s':format(slips.get_slip_number_by_id(slip_id), bag, res.items[item.id].name:color(258)))
            end
        end
    end

    windower.add_to_chat(207, 'Found %s storable items in all bags':format(n))
end

windower.register_event('addon command',function (slip_number, slip_page, owned_only)
    if tonumber(slip_number) == nil then
        slip_page = nil

        if slip_number == 'owned' then
            slip_number = nil
            owned_only  = true
        elseif slip_number == 'find' then
            show_bags()
            return
        elseif slip_number ~= nil then
            error('That\'s not a valid slip number, kupo!')

            return
        end
    else
        slip_number = tonumber(slip_number, 10)

        if tonumber(slip_page) == nil then
            if slip_page == 'owned' then
                slip_page   = nil
                owned_only  = true
            elseif slip_page ~= nil then
                error('That\'s not a valid page number, kupo!')

                return
            end
        else
            slip_page = tonumber(slip_page, 10)

            if owned_only == 'owned' then
                owned_only = true
            else
                owned_only = nil
            end
        end
    end

    show_slip(slip_number, slip_page, owned_only)
end)
