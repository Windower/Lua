_addon.name = 'Update'
_addon.author = 'Arcon'
_addon.version = '1.0.0.0'
_addon.command = 'update'

require('functions')
require('strings')
require('maths')
require('logger')
config = require('config')

defaults = {}
defaults.AutoUpdate = true
defaults.CheckInterval = 300

settings = config.load(defaults)

units = {[''] = 1}
units.s = units['']

units.min = 60*units.s
units.h = 60*units.min
units.d = 24*units.h

units.ms = units.s/1000
units.us = units.ms/1000
units.ns = units.us/1000

math.randomseed(os.time() + os.clock())
handle = math.random(0x7FFFFFFF):hex():zfill(8)

tick = function(msg)
    last = os.clock()
    if not msg then
        windower.send_ipc_message('update ' .. handle)
    end
end

update = tick..windower.execute:prepare(windower.addon_path .. '../../Windower.exe', {'--update'})

windower.register_event('ipc message', tick:cond(function(str)
    local args = str:split(' ')
    return args[1] == 'update' and args[2] ~= handle
end))
windower.register_event('time change', update:cond(function()
    if not settings.AutoUpdate then
        return false
    end

    local player = windower.ffxi.get_player()
    return os.clock() - last > settings.CheckInterval and (not player or not player.in_combat)
end))

windower.register_event('addon command', function(command, param, ...)
    command = command and command:lower() or nil
    param = param and param:lower() or nil

    if command == 'help' then
        print('Update v' .. _addon.version)
        print('    auto [on|off] - Set automatic updates to on or off or toggle.')
        print('    interval <time> - Set automatic update interval to the provided time (in seconds if no units provided).')

    elseif command == 'auto' then
        if not param then
            settings.AutoUpdate = not settings.AutoUpdate
        elseif param == 'on' then
            settings.AutoUpdate = true
        elseif param == 'off' then
            settings.AutoUpdate = false
        else
            error('Invalid syntax: //update auto [on|off]')
            return
        end

        config.save(settings)
        log('Automatic updates turned ' .. (settings.AutoUpdate and 'on' or 'off') .. '.')

    elseif command == 'interval' then
        if not param then
            error('Invalid syntax: //update interval <time>')
            return
        end

        param = param .. L{...}:concat(' ')
        local number = param:gsub('[^%d]', ''):number()
        local unit = param:gsub('[%d]', '')
        if not number or unit ~= '' and not units[unit] then
            error('Invalid syntax: //update interval <time>')
            return
        end

        settings.CheckInterval = number * units[unit]
        config.save(settings)
        log('Interval set to ' .. settings.CheckInterval:string() .. ' seconds.')

    elseif command == 'save' then
        config.save(settings, 'all')

    else
        update()

    end
end)

windower.register_event('load', tick)
