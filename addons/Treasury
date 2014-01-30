_addon.name = 'treasury'
_addon.author = 'Ihina'
_addon.version = '1.0.0.0'
_addon.command = 'treasury'

res = require('resources')
config = require('config')
packets = require('packets')
require('logger')

s = S{'pass', 'lot'}
code = {}
code.pass = S{}
code.lot = S{}
items = {}
items.pass = S{}
items.lot = S{}
settings = config.load(items)

ids = T{}
res.items:map(function(item) 
    ids[item.name:lower()] = item.id 
    ids[item.log_name:lower()] = item.id 
end)

windower.register_event('ipc message',function (msg)
    local param = msg:split(" ")
    if param:remove(1) == 'treasury' then
        command1 = param:remove(1)
        command2 = param:remove(1)
        passlot(command1, command2, S(param):map(tonumber))
    end
end)

windower.register_event('load', function(...)
    code.pass = settings.pass:map(table.get+{ids}..string.lower)
    code.lot = settings.lot:map(table.get+{ids}..string.lower)
    forceCheck()
end)

windower.register_event('addon command', function(...)
    local param = L{...}
    if tostring(param) == '[clearall]' then
        log('Clear all')
        for func in s:it() do
            code[func]:clear()
            settings[func]:clear()
        end
        settings:save()
    end
end)

windower.register_event('unhandled command', function(command1, command2, ...)
    local param = L{...}
    local isGlobal = false
    if param[1] == 'global' then
        isGlobal = true
        param:remove(1)
    end
    local name = param:concat(' ')
    if command1 == 'lot' or command1 == 'pass' then
        if command2 == 'add' or command2 == 'remove' then
            local ids = findID(name)
            if ids:empty() then
                error('Item does not exist.')
                return
            end
            passlot(command1, command2, ids)            
            if isGlobal then
                str = ''
                for item in ids:it() do
                    str = str .. ' '  .. item
                end
                send = 'treasury ' .. command1 .. ' ' .. command2 .. str
                windower.send_ipc_message(send)
            end
        elseif command2 == 'clear' then
            log(command1, command2)
            code[command1]:clear()
            settings[command1]:clear()
            settings:save()
        
        elseif command2 == 'list' then
            log(command1, ':')
            for item in settings[command1]:it() do
                log(item)
            end
        end

    elseif command1 == 'passall' then
        log('Pass all')
        for slot_index,item_table in pairs(windower.ffxi.get_items().treasure) do 
            windower.ffxi.pass_item(slot_index)
        end
        
    elseif command1 == 'lotall' then
        log('Lot all')
        for slot_index,item_table in pairs(windower.ffxi.get_items().treasure) do 
            windower.ffxi.lot_item(slot_index)
        end

    elseif command1 == 'qq' then
        -- for debugging purposes
        log('Super secret debug command')
        log(code.lot)
        log(code.pass)
    end
end)

function passlot(command1, command2, ids)
    names = ids:map(table.get-{'name'}..table.get+{res.items})
        if command2 == 'add' then
            log('Adding to', command1, ':', names)
            code[command1] = code[command1] + ids
            settings[command1] = settings[command1] + names
        else
            log('Removing to', command1, ':', names)
            code[command1] = code[command1] - ids
            settings[command1] = settings[command1] - names
        end
        settings:save()
        forceCheck()
end

function forceCheck()
    for slot_index,item_table in pairs(windower.ffxi.get_items().treasure) do 
        check(slot_index, item_table.item_id)
    end
end

function fromPacket(...)
    local packet = packets.incoming(...)
    check(packet['Pool Index'], packet['Item ID'])
end

function check(slot_index, item_id)
    for func in s:it() do
        if code[func]:contains(item_id) then
            windower.ffxi[func .. '_item'](slot_index)
            return
        end
    end
end

function findID(name)
    if name == 'pool' then
        return getPoolIDs()
        
    elseif name == 'seals' then
        return S{2955, 2956, 1127, 2957, 1126}
        
    elseif name == 'currency' then
        return S{1450, 1455, 1452, 1449, 1453, 1456}
    
    elseif name == 'junk' then
        return S{3297, 3299, 3301, 3303, 3522, 3524, 4103, 4096, 4100, 3298, 3300, 3302, 
                    3521, 4097, 3525, 3527, 3520, 3304, 3523, 3526, 4098, 4102, 4099, 4101}
    else
        return S(ids:filter(windower.wc_match-{name}))
    end
end

function getPoolIDs()
    local ids = S{}
    for slot_index,item_table in pairs(windower.ffxi.get_items().treasure) do 
        ids:add(item_table.item_id)
    end
    return ids
end

windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
    if id == 0x0D2 then
        fromPacket(id, original, modified, injected, blocked)
    elseif id == 0x020 then
        packets.inject(packets.outgoing(0x03A))
    end
end)
