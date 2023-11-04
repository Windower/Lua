--[[
Copyright © 2018, Chiaia
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of Dimmer nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

--Complete addon is almost a direct copy of MyHome from "from20020516" but for warping to a different area.

_addon.name = 'Dimmer'
_addon.author = 'Chiaia'
_addon.version = '1.1.2'
_addon.commands = {'dim', 'dimmer'}

require('logger')
require('tables')
extdata = require('extdata')
res_bags = require('resources').bags

log_flag = true

lang = string.lower(windower.ffxi.get_info().language)
item_info = T{
    [26176]={id=26176, japanese='Ｄ．ホラリング', english='"Dim. Ring (Holla)"', equip_slot=13, short_name='holla'},
    [26177]={id=26177, japanese='Ｄ．デムリング', english='"Dim. Ring (Dem)"', equip_slot=13, short_name='dem'},
    [26178]={id=26178, japanese='Ｄ．メアリング', english='"Dim. Ring (Mea)"', equip_slot=13, short_name='mea'},
    [10385]={id=10385, japanese="キュムラスマスク+1", english="Cumulus Masque +1", equip_slot=4, short_name='mask'},
}

get_items = windower.ffxi.get_items
set_equip = windower.ffxi.set_equip

function search_item(name)
    if windower.ffxi.get_player().status > 1 then
        log('You cannot use items at this time.')
        return
    end

    -- Wipe any previously-saved info
    for _, stats in pairs(item_info) do
        stats.bag = nil
        stats.bag_enabled = nil
        stats.inv_index = nil
        stats.status = nil
        stats.extdata = nil
    end

    -- Get list of all equippable items player has
    for bag_id in pairs(res_bags:equippable(true)) do
        local bag = get_items(bag_id)
        for _, item in ipairs(bag) do
            if item_info[item.id] then
                item_info[item.id].bag = bag_id
                item_info[item.id].bag_enabled = bag.enabled
                item_info[item.id].inv_index = item.slot
                item_info[item.id].status = item.status
                item_info[item.id].extdata = item.extdata
            end
        end
    end

    -- If name of item is provided, process only that item
    if name then
        local _, item = item_info:find(function(i) return i.short_name == name end)
        process_item(item)
    else -- If name not provided, process all items
        for _, item in pairs(item_info) do
            if process_item(item) then
                break
            end
        end
    end
end

function process_item(item)
    if item.bag_enabled then
        local ext = extdata.decode(item)
        local enchant = ext.type == 'Enchanted Equipment'
        local recast = enchant and ext.charges_remaining > 0 and math.max(ext.next_use_time+18000-os.time(), 0)
        local usable = recast and recast == 0
        log(item[lang], usable and '' or recast and recast..' sec recast.')
        if usable or ext.type == 'General' then
            if enchant and item.status ~= 5 then --not equipped
                set_equip(item.inv_index, item.equip_slot, item.bag)
                repeat --waiting cast delay
                    coroutine.sleep(1)
                    local ext = extdata.decode(get_items(item.bag, item.inv_index))
                    local delay = ext.activation_time+18000-os.time()
                    if delay > 0 then
                        log(item[lang], delay)
                    elseif log_flag then
                        log_flag = false
                        log('Item use within 3 seconds..')
                    end
                until ext.usable or delay > 30
            end
            windower.chat.input('/item '..windower.to_shift_jis(item[lang])..' <me>')
            return true
        end
    elseif item.bag and not item.bag_enabled then
        log('You cannot access '..item[lang]..' from ' .. res_bags[item.bag].name ..' at this time.')
        return false
    else
        log('You don\'t have '..item[lang]..'.')
        return false
    end
end

windower.register_event('addon command', function(...)
    local args = T{...}
    search_item(args[1])
end)

windower.register_event('ipc message', function (...)
    local args = T{...}
    if args[1] == 'dim' or args[1] == 'dimmer' then
        search_item(args[2])
    end
end)
