local packets = require('packets')

_addon.name = 'SetTarget'
_addon.author = 'Arcon'
_addon.commands = {'settarget', 'st'}
_addon.version = '1.0.0.0'

windower.register_event('addon command', function(id)
    id = tonumber(id)
    if id == nil then
        return
    end

    local target = windower.ffxi.get_mob_by_id(id)
    if not target then
        return
    end

    local player = windower.ffxi.get_player()

    packets.inject(packets.new('incoming', 0x058, {
        ['Player'] = player.id,
        ['Target'] = target.id,
        ['Player Index'] = player.index,
    }))
end)
