_addon.name = 'Update'
_addon.author = 'Arcon'
_addon.version = '1.1.0.0'
_addon.command = 'update'

require('luau')

defaults = {}
defaults.AutoUpdate = false
defaults.CheckInterval = 300

settings = config.load(defaults)

debug.setmetatable(nil, {__index = {}, __call = functions.empty})

units = {[''] = 1}
units.s = units['']

units.min = 60*units.s
units.h = 60*units.min
units.d = 24*units.h

units.ms = units.s/1000
units.us = units.ms/1000
units.ns = units.us/1000

math.randomseed(os.time() + os.clock())
handle = (0x7FFFFFFF):random():hex():zfill(8)

tick = function(msg)
    last = os.clock()
    if not msg then
        windower.send_ipc_message('update ' .. handle)
    end
end

update = tick .. windower.execute:prepare(windower.windower_path .. 'Windower.exe', {'--update'})

windower.register_event('ipc message', tick:cond(function(str)
    local args = str:split(' ')
    return args[1] == 'update' and args[2] ~= handle
end))

windower.register_event('time change', update:cond(function()
    return settings.AutoUpdate and os.clock() - last > settings.CheckInterval and not windower.ffxi.get_player().in_combat
end))

windower.register_event('addon command', function(command, param, ...)
    command = command and command:lower() or nil
    param = param and param:lower() or nil

    if not command then
        update()

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
        print(_addon.name .. ' v' .. _addon.version)
        print('    auto [on|off] - Set automatic updates to on or off or toggle.')
        print('    interval <time> - Set automatic update interval to the provided time (in seconds if no units provided).')
        print('    save - Saves the current settings for all characters.')

    end
end)

windower.register_event('load', tick)

--[[
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
