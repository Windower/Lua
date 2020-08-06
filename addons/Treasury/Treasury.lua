_addon.name = 'Treasury'
_addon.author = 'Ihina'
_addon.version = '1.2.1.1'
_addon.commands = {'treasury', 'tr'}

res = require('resources')
config = require('config')
packets = require('packets')
require('logger')

defaults = {}
defaults.Pass = S{}
defaults.Lot = S{}
defaults.Drop = S{}
defaults.AutoDrop = false
defaults.AutoStack = true
defaults.Delay = 0
defaults.Verbose = false

settings = config.load(defaults)

all_ids = T{}
for item in res.items:it() do
    local name = item.name:lower()
    if not all_ids[name] then
        all_ids[name] = S{}
    end
    local name_log = item.name_log:lower()
    if not all_ids[name_log] then
        all_ids[name_log] = S{}
    end
    all_ids[name]:add(item.id)
    all_ids[name_log]:add(item.id)
end

code = {}
code.pass = S{}
code.lot = S{}
code.drop = S{}

local flatten = function(s)
    return s:reduce(function(s1, s2)
        return s1 + s2
    end, S{})
end

local extract_ids = function(names)
    return flatten(names:map(table.get+{all_ids} .. string.lower))
end

config.register(settings, function(settings_table)
    code.pass = extract_ids(settings_table.Pass)
    code.lot = extract_ids(settings_table.Lot)
    code.drop = extract_ids(settings_table.Drop)
end)

lotpassdrop_commands = T{
    lot = 'Lot',
    l = 'Lot',
    pass = 'Pass',
    p = 'Pass',
    drop = 'Drop',
    d = 'Drop',
}

addremove_commands = T{
    add = 'add',
    a = 'add',
    ['+'] = 'add',
    remove = 'remove',
    r = 'remove',
    ['-'] = 'remove',
}

bool_values = T{
    ['on'] = true,
    ['1'] = true,
    ['true'] = true,
    ['off'] = false,
    ['0'] = false,
    ['false'] = false,
}

inventory_id = res.bags:with('english', 'Inventory').id

function lotpassdrop(command1, command2, ids)
    local action = command1:lower()
    names = ids:map(table.get-{'name'} .. table.get+{res.items})
    if command2 == 'add' then
        log('Adding to ' .. action .. ' list:', names)
        code[action] = code[action] + ids
        settings[command1] = settings[command1] + names
    else
        log('Removing from ' .. action .. ' list:', names)
        code[action] = code[action] - ids
        settings[command1] = settings[command1] - names
    end

    settings:save()
    force_check(command1 == 'Drop')
end

function act(action, output, id, ...)
    if settings.Verbose then
        log('%s %s':format(output, res.items[id].name:color(258)))
    end
    windower.ffxi[action]:prepare(...):schedule((math.random() + 1) / 2 * settings.Delay)
end

pass = act+{'pass_item', 'Passing'}
lot = act+{'lot_item', 'Lotting'}
drop = act+{'drop_item', 'Dropping'}

function force_check()
    local items = windower.ffxi.get_items()

    -- Check treasure pool
    for index, item in pairs(items.treasure) do
        check(index, item.item_id)
    end

    -- Check inventory for unwanted items
    if settings.AutoDrop then
        for index, item in pairs(items.inventory) do
            if type(item) == 'table' and code.drop:contains(item.id) and item.status == 0 then
                drop(item.id, index, item.count)
            end
        end
    end
end

function check(slot_index, item_id)
    if (code.drop:contains(item_id) or code.pass:contains(item_id)) and not code.lot:contains(item_id) then
        pass(item_id, slot_index)
    elseif code.lot:contains(item_id) then
        local inventory = windower.ffxi.get_items(inventory_id)
        if inventory.max - inventory.count > 1 then
            lot(item_id, slot_index)
        end
    end
end

function find_id(name)
    if name == 'pool' then
        return pool_ids()
        
    elseif name == 'seals' then
        return S{1126, 1127, 2955, 2956, 2957}
        
    elseif name == 'currency' then
        return S{1449, 1450, 1451, 1452, 1453, 1454, 1455, 1456, 1457}
    
    elseif name == 'geodes' then
        return S{3297, 3298, 3299, 3300, 3301, 3302, 3303, 3304}

    elseif name == 'avatarites' then
        return S{3520, 3521, 3522, 3523, 3524, 3525, 3526, 3527}

    elseif name == 'crystals' then
        return S{4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103}

    else
        return flatten(S(all_ids:key_filter(windower.wc_match-{name})))

    end
end

function pool_ids()
    return S(T(windower.ffxi.get_items().treasure):map(table.get-{'item_id'}))
end

stack = function()
    local wait_time = 0

    return function()
        if os.clock() - last_stack_time > 2 then
            packets.inject(packets.new('outgoing', 0x03A))
            last_stack_time = os.clock()
            wait_time = 0
        elseif os.clock() - last_stack_time > wait_time then
            wait_time = wait_time + 0.45
            stack:schedule(0.5)
        end
    end:cond(function()
        return settings.AutoStack
    end)
end()

stack_ids = S{0x01F, 0x020}
last_stack_time = 0
windower.register_event('incoming chunk', function(id, data)
    if id == 0x0D2 then
        local treasure = packets.parse('incoming', data)
        check(treasure.Index, treasure.Item)

    elseif stack_ids:contains(id) then
        local chunk = packets.parse('incoming', data)

        -- Ignore items in other bags
        if chunk.Bag ~= inventory_id then
            return
        end

        if id == 0x020 and settings.AutoDrop and code.drop:contains(chunk.Item) and chunk.Status == 0 then
            drop(chunk.Item, chunk.Index, chunk.Count)
        else
            -- Don't need to stack in the other case, as a new inventory packet will come in after the drop anyway
            stack()
        end
    end
end)

windower.register_event('ipc message', function(msg)
    local args = msg:split(' ')
    if args:remove(1) == 'treasury' then
        command1 = args:remove(1)
        command2 = args:remove(1)
        lotpassdrop(command1, command2, S(args):map(tonumber))
    end
end)

windower.register_event('load', force_check:cond(table.get-{'logged_in'} .. windower.ffxi.get_info))

windower.register_event('addon command', function(command1, command2, ...)
    local args = L{...}
    local global = false

    if args[1] == 'global' then
        global = true
        args:remove(1)
    end

    command1 = command1 and command1:lower() or 'help'
    command2 = command2 and command2:lower() or nil

    local name = args:concat(' ')
    if lotpassdrop_commands:containskey(command1) then
        command1 = lotpassdrop_commands[command1]

        if addremove_commands:containskey(command2) then
            command2 = addremove_commands[command2]

            local ids = find_id(name)
            if ids:empty() then
                error('No items found that match: %s':format(name))
                return
            end
            lotpassdrop(command1, command2, ids)

            if global then
                windower.send_ipc_message('treasury %s %s %s':format(command1, command2, ids:concat(' ')))
            end

        elseif command2 == 'clear' then
            code[command1:lower()]:clear()
            settings[command1]:clear()
            config.save(settings)

        elseif command2 == 'list' then
            log(command1 .. ':')
            for item in settings[command1]:it() do
                log('    ' .. item)
            end

        end

    elseif command1 == 'passall' then
        for slot_index, item_table in pairs(windower.ffxi.get_items().treasure) do 
            windower.ffxi.pass_item(slot_index)
        end
        
    elseif command1 == 'lotall' then
        for slot_index, item_table in pairs(windower.ffxi.get_items().treasure) do 
            windower.ffxi.lot_item(slot_index)
        end

    elseif command1 == 'clearall' then
        code.pass:clear()
        code.lot:clear()
        code.drop:clear()
        settings.Pass:clear()
        settings.Lot:clear()
        settings.Drop:clear()
        config.save(settings)

    elseif command1 == 'autodrop' then
        if command2 then
            settings.AutoDrop = bool_values[command2:lower()]
        else
            settings.AutoDrop = not settings.AutoDrop
        end

        config.save(settings)
        log('AutoDrop %s':format(settings.AutoDrop and 'enabled' or 'disabled'))

    elseif command1 == 'autostack' then
        if command2 then
            settings.AutoStack = bool_values[command2:lower()]
        else
            settings.AutoStack = not settings.AutoStack
        end

        config.save(settings)
        log('AutoStack %s':format(settings.AutoStack and 'enabled' or 'disabled'))

    elseif command1 == 'delay' then
        if not (command2 and tonumber(command2)) then
            error('Please specify a value in seconds for the new delay')
            return
        end

        settings.Delay = tonumber(command2)
        log('Delay set to %f seconds':format(settings.Delay))

    elseif command1 == 'verbose' then
        if command2 then
            settings.Verbose = bool_values[command2:lower()]
        else
            settings.Verbose = not settings.Verbose
        end

        config.save(settings)
        log('Verbose output %s':format(settings.Verbose and 'enabled' or 'disabled'))

    elseif command1 == 'save' then
        config.save(settings, 'all')

    elseif command1 == 'help' then
        print('%s v%s':format(_addon.name, _addon.version))
        print('    \\cs(255,255,255)lot|pass|drop add|remove <name>\\cr - Adds or removes all items matching <name> to the specified list')
        print('    \\cs(255,255,255)lot|pass|drop clear\\cr - Clears the specified list for the current character')
        print('    \\cs(255,255,255)lot|pass list\\cr - Lists all items on the specified list for the current character')
        print('    \\cs(255,255,255)lotall|passall\\cr - Lots/Passes all items currently in the pool')
        print('    \\cs(255,255,255)clearall\\cr - Removes lotting/passing/dropping settings for this character')
        print('    \\cs(255,255,255)autodrop [on|off]\\cr - Enables/disables (or toggles) the auto-drop setting')
        print('    \\cs(255,255,255)verbose [on|off]\\cr - Enables/disables (or toggles) the verbose setting')
        print('    \\cs(255,255,255)autostack [on|off]\\cr - Enables/disables (or toggles) the autostack feature')
        print('    \\cs(255,255,255)delay <value>\\cr - Allows you to change the delay of actions (default: 0)')

    end
end)

--[[
Copyright © 2014-2018, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
