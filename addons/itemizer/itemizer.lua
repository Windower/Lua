_addon.name = 'Itemizer'
_addon.author = 'Ihina'
_addon.version = '3.0.1.3'
_addon.command = 'itemizer'

require('luau')

defaults = {}
defaults.AutoNinjaTools = true
defaults.AutoItems = true
defaults.Delay = 0.5
defaults.version                       = "3.0.1.1"
defaults.UseUniversalTools = {}

defaults.UseUniversalTools.Katon       = false
defaults.UseUniversalTools.Hyoton      = false
defaults.UseUniversalTools.Huton       = false
defaults.UseUniversalTools.Doton       = false
defaults.UseUniversalTools.Raiton      = false
defaults.UseUniversalTools.Suiton      = false
defaults.UseUniversalTools.Utsusemi    = false
defaults.UseUniversalTools.Jubaku      = false
defaults.UseUniversalTools.Hojo        = false
defaults.UseUniversalTools.Kurayami    = false
defaults.UseUniversalTools.Dokumori    = false
defaults.UseUniversalTools.Tonko       = false
defaults.UseUniversalTools.Monomi      = false
defaults.UseUniversalTools.Aisha       = false
defaults.UseUniversalTools.Yurin       = false
defaults.UseUniversalTools.Myoshu      = false
defaults.UseUniversalTools.Migawari    = false
defaults.UseUniversalTools.Kakka       = false
defaults.UseUniversalTools.Gekka       = false
defaults.UseUniversalTools.Yain        = false

settings = config.load(defaults)
bag_ids = res.bags:key_map(string.gsub-{' ', ''} .. string.lower .. table.get-{'english'} .. table.get+{res.bags}):map(table.get-{'id'})
-- Remove temporary bag, because items cannot be moved from/to there, as such it's irrelevant to Itemizer
bag_ids.temporary = nil

--Added this function for first load on new version. Because of the newly added features that weren't there before.
windower.register_event("load", function()
    if settings.version == "3.0.1.1" then
        windower.add_to_chat(207,"Itemizer v3.0.1.2: New features added. (use //itemizer help to find out about them)")
        settings.version = "3.0.1.2"
        settings:save() 
    end
end)

find_items = function(ids, bag, limit)
    local res = S{}
    local found = 0

    for bag_index, bag_name in bag_ids:filter(table.get-{'enabled'} .. windower.ffxi.get_bag_info):it() do
        if not bag or bag_index == bag then
            for _, item in ipairs(windower.ffxi.get_items(bag_index)) do
                if ids:contains(item.id) then
                    local count = limit and math.min(limit, item.count) or item.count
                    found = found + count

                    res:add({
                        bag = bag_index,
                        slot = item.slot,
                        count = count,
                    })

                    if limit then
                        limit = limit - count

                        if limit == 0 then
                            return res, found
                        end
                    end
                end
            end
        end
    end

    return res, found
end

windower.register_event("addon command", function(command, arg2, ...)
    if command == 'help' then
        local helptext = [[Itemizer - Command List:')
  1. Delay <delay> - Sets the time delay.
  2. Autoninjatools - toggles Automatically getting ninja tools (Shortened ant)
  3. Autoitems - Toggles automatically getting items from bags (shortened ai)
  4. Useuniversaltool <spell> - toggles using universal ninja tools for <spell> (shortened uut)
     i.e. uut katon  - will toggle katon either true or false depending on your setting
     all defaulted false.
  5. help --Shows this menu.]]
        for _, line in ipairs(helptext:split('\n')) do
            windower.add_to_chat(207, line)
        end
    elseif command:lower() == "delay" and arg2 ~= nil then
        if type(arg2) == 'number' then
            settings.delay = arg2
            settings:save()
        else
            error('The delay must be a number')
        end
    elseif T{'autoninjatools','ant'}:contains(command:lower()) then
        settings.AutoNinjaTools = not settings.AutoNinjaTools
        settings:save()
    elseif T{'autoitems','ai'}:contains(command:lower()) then
        settings.AutoItems = not settings.AutoItems
        settings:save()
    elseif T{'useuniversaltool','uut'}:contains(command:lower()) then
        if settings.UseUniversalTools[arg2:ucfirst()] ~= nil then
            settings.UseUniversalTools[arg2:ucfirst()] = not settings.UseUniversalTools[arg2:ucfirst()]
            settings:save()
        else
            error('Argument 2 must be a ninjutsu spell (sans :ichi or :ni) i.e. uut katon')
        end
    end
end)
        

windower.register_event('unhandled command', function(command, ...)
    local args = L{...}:map(string.lower)

    if command == 'get' or command == 'put' or command == 'gets' or command == 'puts' then
        local count
        if command == 'gets' or command == 'puts' then
            command = command:sub(1, -2)
        else
            local last = args[#args]
            if last == 'all' then
                args:remove()
            elseif tonumber(last) then
                count = tonumber(last)
                args:remove()
            else
                count = 1
            end
        end

        local bag = args[#args]
        local specified_bag = rawget(bag_ids, bag)
        if specified_bag then
            if not windower.ffxi.get_bag_info(specified_bag).enabled then
                error('%s currently not enabled':format(res.bags[specified_bag].name))
                return
            end

            args:remove()
        elseif command == 'put' and not specified_bag then
            error('Specify a valid destination bag to put items in.')
            return
        end

        local source_bag
        local destination_bag
        if command == 'get' then
            source_bag = specified_bag
            destination_bag = bag_ids.inventory
        else
            destination_bag = specified_bag
            source_bag = bag_ids.inventory
        end
        
        local destination_bag_info = windower.ffxi.get_bag_info(destination_bag)
        if destination_bag_info.max - destination_bag_info.count == 0 then
            error('Not enough space in %s to move items.':format(res.bags[destination_bag].name))
            return
        end

        local item_name = args:concat(' ')
 
        local item_ids = (S(res.items:name(windower.wc_match-{item_name})) + S(res.items:name_log(windower.wc_match-{item_name}))):map(table.get-{'id'})
        if item_ids:length() == 0 then
            error('Unknown item: %s':format(item_name))
            return
        end

        local matches, results = find_items(item_ids, source_bag, count)
        if results == 0 then
            error('Item "%s" not found in %s.':format(item_name, source_bag and res.bags[source_bag].name or 'any accessible bags'))
            return
        end

        if count and results < count then
            warning('Only %u "%s" found in %s.':format(results, item_name, source_bag and res.bags[source_bag].name or 'all accessible bags'))
        end

        for match in matches:it() do
            windower.ffxi[command .. '_item'](command == 'get' and match.bag or destination_bag, match.slot, match.count)
        end
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
    Gekka       = 8803,
    Yain        = 8804
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
    Gekka       = 2972,
    Yain        = 2972
}

active = S{}

-- Returning true resends the command in settings.Delay seconds
-- Returning false doesn't resend the command and executes it
collect_item = function(id, items)
    items = items or {inventory = windower.ffxi.get_items(bag_ids.inventory)}

    local item = T(items.inventory):with('id', id)
    if item then
        active = active:remove(id)
        return false
    end

    -- Current ID already being processed?
    if active:contains(id) then
        return true
    end

    -- Check for all items
    local match = find_items(S{id}, nil, 1):it()()

    if match then
        windower.ffxi.get_item(match.bag, match.slot, match.count)

        -- Add currently processing ID to set of active IDs
        active:add(id)
    else
        error('Item "%s" not found in any accessible bags':format(res.items[id].name))
    end

    return match ~= nil
end

reschedule = function(text, ids, items)
    if not items then
        local info = windower.ffxi.get_bag_info(bag_ids.inventory)
        items = {inventory = windower.ffxi.get_items(bag_ids.inventory)}
        items.max_inventory = info.max
        items.count_inventory = info.count
    end

    -- Inventory full?
    if items.max_inventory - items.count_inventory == 0 then
        return false
    end

    for id in L(ids):it() do
        if collect_item(id, items) then
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
                if settings.UseUniversalTools[name] == false or windower.ffxi.get_player().main_job ~= 'NIN' then
                    return reschedule(text, {spec_tools[name], windower.ffxi.get_player().main_job == 'NIN' and gen_tools[name] or nil})
                else
                    return reschedule(text, {windower.ffxi.get_player().main_job == 'NIN' and gen_tools[name] or nil})
                end
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
                    elseif S{'wardrobe','wardrobe2','wardrobe3','wardrobe4'}:contains(bag) then
                        wardrobe_items:add(item.id)
                    end
                end
            end

            local parsed_text = item_count and text:match(' (.+) (%d+)$') or text:match(' (.+)')
            local mid_name = parsed_text:match('"(.+)"') or parsed_text:match('\'(.+)\'') or parsed_text:match('(.+) ')
            local full_name = parsed_text:match('(.+)')
            local id = item_names:find(string.imatch-{mid_name}) or item_names:find(string.imatch-{full_name})
            if id then
                if not inventory_items:contains(id) and not wardrobe_items:contains(id) then
                    return reschedule(text, {id}, items)
                else
                    active:remove(id)
                end
            end

        end
    end
end())

--[[
Copyright © 2013-2015, Ihina
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
