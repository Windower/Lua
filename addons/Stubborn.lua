_addon = {'Stubborn'}
_addon.name = 'Stubborn'
_addon.author = 'Arico'
_addon.version = '1'
_addon.command = 'stubborn'

require 'pack'
require 'strings'
require('logger')
packets = require('packets')


windower.register_event('outgoing chunk', function(id,original,modified,injected,blocked)
    if id == 0x01a then
        local p = packets.parse('outgoing',original)
        if p['Category'] == 5 and not injected then
            log('You are too stubborn to call for help! Use //stubborn to call for help.')
            return true
        end
    end
end)

windower.register_event('addon command', function(...)
    local target = windower.ffxi.get_mob_by_target("t")
    if target and target.claim_id ~= 0 then 
        local p = packets.new('outgoing', 0x1a,{
                ['Target'] = target['id'],
                ['Target Index'] = target['index'],
                ['Category'] = 5,})
        packets.inject(p)
    end
end)