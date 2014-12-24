_addon.name = 'Itemizer'
_addon.author = 'Ihina'
_addon.version = '2.0.1.0'
_addon.command = 'itemizer'

require('luau')

defaults = {}
defaults.AutoNinjaTools = true
defaults.AutoItems = true
defaults.Delay = 0.5

settings = config.load(defaults)

bag_ids = res.bags:key_map(string.lower .. table.get-{'english'} .. table.get+{res.bags}):map(table.get-{'id'})

windower.register_event('unhandled command', function(command, ...)
    local args = L{...}:map(string.lower)

    if command == 'get' or command == 'put' then
        local bag = args:remove(#args)
        local search = bag_ids[command == 'get' and bag or 'inventory']
        if not search then
            error('Unknown bag: %s':format(bag))
            return
        elseif not windower.ffxi.get_bag_info(search).enabled then
            error('Bag %s currently not enabled':format(bag))
            return
        end

        local item_name = args:concat(' ')
 
        local item_ids = res.items:name(windower.wc_match-{item_name})
        if item_ids:length() == 0 then
            item_ids = res.items:name_log(windower.wc_match-{item_name})
            if item_ids:length() == 0 then
                error('Unknown item: %s':format(item_name))
                return
            end
        end

        for slot, item in pairs(windower.ffxi.get_items(search)) do 
            if item_ids[item.id] then 
                windower.ffxi[command .. '_item'](bag_id, slot)
                return
            end 
        end

        log('Item "%s" not found in %s':format(item_name, command == 'get' and bag or 'inventory'))
    end	
end)

ninjutsu = res.spells:type('Ninjutsu')
patterns = L{'"(.+)"', '\'(.+)\'', '.- (.+) .-', '.- (.+)'}
spec_tools = T{
    Katon       = 1161,
    Hyoton      = 1164,
    Huton       = 1167,
    Doton       = 1170,
    Raiton      = 1173,
    Suiton      = 1176,
    Utsusemi    = 1179,
    Jubaku      = 1182,
    Hojo        = 1185,
    Kurayami    = 1188,
    Dokumori    = 1191,
    Tonko       = 1194,
    Monomi      = 2553,
    Aisha       = 2555,
    Yurin       = 2643,
    Myoshu      = 2642,
    Migawari    = 2970,
    Kakka       = 2644,
}
gen_tools = T{
    Katon       = 2971,
    Hyoton      = 2971,
    Huton       = 2971,
    Doton       = 2971,
    Raiton      = 2971,
    Suiton      = 2971,
    Utsusemi    = 2972,
    Jubaku      = 2973,
    Hojo        = 2973,
    Kurayami    = 2973,
    Dokumori    = 2973,
    Tonko       = 2972,
    Monomi      = 2972,
    Aisha       = 2973,
    Yurin       = 2973,
    Myoshu      = 2972,
    Migawari    = 2972,
    Kakka       = 2972,
}

active = S{}

-- Returning true resends the command in settings.Delay seconds
-- Returning false doesn't resend the command and executes it
use_item = function(id, count, items)
    count = count or 1
    items = items or {inventory = windower.ffxi.get_items(bag_ids.inventory)}

    local item = T(inventory):with('id', id)
    if item and item.count >= count then
        active = active:remove(id)
        return false
    end

    -- Current ID already being processed?
    if active:contains(id) then
        return true
    end

    -- Check for all items
    local remaining = count - (item and item.count or 0)
    local delay = false
    for bag_index, bag_name in bag_ids:filter(table.get-{'enabled'} .. windower.ffxi.get_bag_info):it() do
        for item in T(items[bag_name] or windower.ffxi.get_items(bag_name)):it() do
            if item.id == id and item.count >= remaining then
                -- Move it to the inventory
                windower.ffxi.get_item(bag_index, item.slot, math.min(item.count, remaining))
                remaining = remaining - item.count

                -- Add currently processing ID to set of active IDs
                active:add(id)

                if remaining <= 0 then
                    return true
                end

                delay = true
            end
        end
    end

    if not delay then
        if remaining == count - (item and item.count or 0)
            error('Item %s not found':format(res.items[id].name))
        else
            error('Not enough %s found in all accessible bags':format(res.items[id].name))
        end
    end
    return delay
end

reschedule = function(text, ids, count, items)
    items = items or {inventory = windower.ffxi.get_items(bag_ids.inventory)}

    -- Inventory full?
    if items.max_inventory - items.count_inventory == 0 then
        return false
    end

    for id in L(ids):it() do
        if use_item(id, count, items) then
            windower.send_command:prepare('input %s':format(text)):schedule(settings.Delay)
            return true
        end
    end
end

windower.register_event('outgoing text', function()
    local item_names = T{}

    return function(text)
        -- Ninjutsu
        if settings.AutoNinjaTools and (text:startswith('/ma ') or text:startswith('/nin ') or text:startswith('/magic ') or text:startswith('/ninjutsu ')) then
            local name
            for pattern in patterns:it() do
                local match = text:match(pattern)
                if match then
                    if ninjutsu:with('name', string.imatch-{match}) then
                        name = match:lower():capitalize():match('%w+')
                        break
                    end
                end
            end

            if name then
                return reschedule(text, {spec_tools[name], (windower.ffxi.get_player().main_job == 'NIN' and gen_tools[name])})
            end

        -- Item usage
        elseif settings.AutoItems and text:startswith('/item ') then
            local items = windower.ffxi.get_items()
            local inventory_items = S{}
            local wardrobe_items = S{}
            for bag in bag_ids:keyset():it() do
                for _, item in ipairs(items[bag]) do
                    if item.id > 0 and not item_names[item.id] then
                        item_names[item.id] = res.items[item.id].name
                    end

                    if bag == 'inventory' then
                        inventory_items:add(item.id)
                    elseif bag == 'wardrobe' then
                        wardrobe_items:add(item.id)
                    end
                end
            end

            local item_count = text:match('%d+$')
            local parsed_text = item_count and text:match(' (.+) (%d+)$') or text:match(' (.+)')
            local mid_name = parsed_text:match('"(.+)"') or parsed_text:match('\'(.+)\'') or parsed_text:match('(.+) ')
            local full_name = parsed_text:match('(.+)')
            local id = item_names:find(string.imatch-{mid_name}) or item_names:find(string.imatch-{full_name})
            if id then
                if not inventory_items:contains(id) and not wardrobe_items:contains(id) then
                    return reschedule(text, {id}, item_count and item_count:number() or 1, items)
                else
                    active:remove(id)
                end
            end

        end
    end
end())

--[[
Copyright © 2013-2014, Ihina
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Silence nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL IHINA BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
--Original plugin by Aureus
