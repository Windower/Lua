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

windower.register_event('unhandled command', function(command, ...) 
	local param = L{...}

	if command == 'get' or command == 'put' then
		local bag = param:remove(#param)
		local item_name = param:concat(' ')
		local search = command == 'get' and bag or 'inventory'

		local item_ids = res.items:name(windower.wc_match-{item_name})
		if item_ids:length() == 0 then
			item_ids = res.items:name_log(windower.wc_match-{item_name})
			if item_ids:length() == 0 then
				error('Unknown item: %s':format(item_name))
				return
			end
		end

		local bag_id = res.bags:with('english', string.imatch-{bag}).id
		if not bag_id then
			error('Unknown bag: %s':format(bag))
			return
		end

		for slot, item in pairs(windower.ffxi.get_items()[search]) do 
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

bag_names = {}
bag_names.all = T(res.bags:map(string.lower .. table.get-{'english'}))
bag_names.all.inventory = nil
bag_names.all.safe = nil
bag_names.all.storage = nil
bag_names.all.locker = nil

bag_names.nomad = T(res.bags:map(string.lower .. table.get-{'english'}))
bag_names.nomad.inventory = nil

active = S{}

-- Returning true resends the command in settings.Delay seconds
-- Returning false doesn't resend the command and executes it
function use_item(id, count, items)
    count = count or 1
    items = items or windower.ffxi.get_items()

    local item = table.with(items.inventory, 'id', id)
    if item and item.count >= count then
        active = active:remove(id)
        return false
    end

    -- Current ID already being processed?
    if active:contains(id) then
        return true
    end

    -- Check for all items
    for bag_name, bag_index in bag_names.all:it() do
        local item = table.with(items[bag_name], 'id', id)
        if item and item.count >= count then
            -- Move it to the inventory
            windower.ffxi.get_item(bag_index, item.slot, count)

            -- Add currently processing ID to set of active IDs
            active:add(id)

            -- Delay the action
            return true
        end
    end

    return false
end

function reschedule(text, ids, count, items)
    items = items or windower.ffxi.get_items()

    -- Inventory full?
    if items.max_inventory - table.count(items.inventory, function(item) return item.id > 0 end) == 0 then
        return false
    end

    for id in L(ids):it() do
        if use_item(id, count, items) then
            windower.send_command('wait %f; input %s':format(settings.Delay, text))
            return true
        end
    end
end

item_names = T{}
windower.register_event('outgoing text', function(text)
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
            return reschedule(text, {spec_tools[name], gen_tools[name]})
        end

    -- Item usage
    elseif settings.AutoItems and text:startswith('/item ') then
        local items = windower.ffxi.get_items()
        local inventory_items = S{}
        local wardrobe_items = S{}
        for bag in bag_names.all:it() do
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
end)

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
--and thank Arcon for practically writing half this code
