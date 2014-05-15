_addon.name = 'Treasury'
_addon.author = 'Ihina'
_addon.version = '1.0.0.0'
_addon.commands = {'treasury', 'tr'}
_addon.language = 'English'

res = require('resources')
config = require('config')
packets = require('packets')
require('logger')

defaults = {}
defaults.Pass = S{}
defaults.Lot = S{}
defaults.AutoDrop = false

settings = config.load(defaults)

ids = T{}
res.items:map(function(item) 
    ids[item.name:lower()] = item.id 
    ids[item.log_name:lower()] = item.id 
end)

s = S{'pass', 'lot'}
code = {}
code.pass = S{}
code.lot = S{}

config.register(settings, function(settings_table)
    code.pass = settings_table.Pass:map(table.get+{ids} .. string.lower)
    code.lot = settings_table.Lot:map(table.get+{ids} .. string.lower)
end)

lotpass_commands = T{
    lot = 'Lot',
    pass = 'Pass',
    l = 'Lot',
    p = 'Pass',
}

addremove_commands = T{
    add = 'add',
    remove = 'remove',
    a = 'add',
    r = 'remove',
    ['+'] = 'add',
    ['-'] = 'remove',
}

bool_values = T{
    on = true,
    ['1'] = true,
    ['true'] = true,
    off = false,
    ['0'] = false,
    ['false'] = false,
}

function passlot(command1, command2, ids)
    local action = command1:lower()
    names = ids:map(table.get-{'name'} .. table.get+{res.items})
    if command2 == 'add' then
        log('Adding to "' .. command1 .. '":', names)
        code[action] = code[action] + ids
        settings[command1] = settings[command1] + names
    else
        log('Removing to "' .. command1 .. '":', names)
        code[action] = code[action] - ids
        settings[command1] = settings[command1] - names
    end

    settings:save()
    force_check()
end

function force_check()
    local items = windower.ffxi.get_items()

    -- Check treasure pool
    for index, item in pairs(items.treasure) do
        check(index, item.item_id)
    end

    -- Check inventory for unwanted items
    if settings.AutoDrop then
        for index, item in pairs(items.inventory) do
            if code.pass:contains(item.id) then
                windower.ffxi.drop_item(index, item.count)
            end
        end
    end
end

function check(slot_index, item_id)
    local items = windower.ffxi.get_items()
    if code.pass:contains(item_id) then
        windower.ffxi.pass_item(slot_index)
    elseif items.max_inventory - items.count_inventory > 1 and code.lot:contains(item_id) then
        windower.ffxi.lot_item(slot_index)
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
        return S(ids:key_filter(windower.wc_match-{name}))

    end
end

function pool_ids()
    local ids = S{}
    for slot_index,item_table in pairs(windower.ffxi.get_items().treasure) do 
        ids:add(item_table.item_id)
    end
    return ids
end

stack_ids = S{0x01E, 0x01F, 0x020}
last_stack_time = 0
inventory = res.bags:with('english', 'Inventory').id
windower.register_event('incoming chunk', function(id, original)
    if id == 0x0D2 then
        local treasure = packets.incoming(id, original)
        check(treasure.Index, treasure.Item)
    elseif stack_ids:contains(id) then
        if id == 0x020 and settings.AutoDrop then
            local item = packets.incoming(id, original)
            if item.Bag == inventory and code.pass:contains(item.ID) then
                windower.ffxi.drop_item(item.Index, item.Count)
            end
        end

        if os.clock() - last_stack_time > 2000 then
            packets.inject(packets.outgoing(0x03A))
            last_stack_time = os.clock()
        end
    end
end)

windower.register_event('ipc message', function(msg)
    local args = msg:split(' ')
    if args:remove(1) == 'treasury' then
        command1 = args:remove(1)
        command2 = args:remove(1)
        passlot(command1, command2, S(args):map(tonumber))
    end
end)

windower.register_event('load', force_check)

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
    if lotpass_commands:containskey(command1) then
        command1 = lotpass_commands[command1]

        if addremove_commands:containskey(command2) then
            command2 = addremove_commands[command2]

            local ids = find_id(name)
            if ids:empty() then
                error('Item does not exist.')
                return
            end
            passlot(command1, command2, ids)            

            if global then
                str = ''
                for item in ids:it() do
                    str = str .. ' '  .. item
                end
                send = 'treasury ' .. command1 .. ' ' .. command2 .. str
                windower.send_ipc_message(send)
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
        settings.Pass:clear()
        settings.Lot:clear()

        config.save(settings)

    elseif command1 == 'autodrop' then
        if command2 then
            settings.AutoDrop = bool_values[command2:lower()]
        else
            settings.AutoDrop = not settings.AutoDrop
        end

        config.save(settings)
        log('AutoDrop ' .. (settings.AutoDrop and 'enabled' or 'disabled'))

    elseif command1 == 'help' then
        print(_addon.name .. ' v' .. _addon.version)
        print('    \\cs(255,255,255)lot|pass add|remove <name>\\cr - Adds are removes all items matching <name> to the specified list')
        print('    \\cs(255,255,255)lot|pass clear\\cr - Clears the specified list for the current character')
        print('    \\cs(255,255,255)lot|pass list\\cr - Lists all items on the specified list for the current character')
        print('    \\cs(255,255,255)lotall|passall\\cr - Lots/Passes all items currently in the pool')
        print('    \\cs(255,255,255)clearall\\cr - Removes lotting/passing settings for this character')
        print('    \\cs(255,255,255)autodrop [on|off]\\cr - Enables/disables (or toggles) the auto-drop setting')

    end
end)
