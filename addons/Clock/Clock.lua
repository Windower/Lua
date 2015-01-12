_addon.name = 'Clock'
_addon.author = 'StarHawk'
_addon.version = '0.0.0.0'
_addon.command = 'clock'

require('tables')
require('logger')
config = require('config')
texts = require('texts')

time_zones = T(require('time_zones'))

for key, val in pairs(time_zones) do
    time_zones[key] = val * 3600
end

local tz_format = {}
for tz in time_zones:keyset():it() do
    tz_format[tz:lower()] = tz:gsub('%d', '')
end

defaults = {}
defaults.Format = '%H:%M:%S'
defaults.TimeZones = L{'UTC', 'jst'}
defaults.Separator = '\\n'
defaults.Sort = ''
defaults.Clock = {}

settings = config.load(defaults)

clock = texts.new('', settings.Clock, settings)

sort = {
    time = function(t1, t2)
        return time_zones[t1] < time_zones[t2]
    end,
    alphabetical = function(t1, t2)
        return t1 < t2
    end,
}

redraw = function()
    local sorted = settings.Sort ~= '' and settings.TimeZones:sort(sort[settings.Sort:lower()]) or settings.TimeZones
    local width = settings.TimeZones:reduce(function(acc, tz)
        return math.max(acc, #tz)
    end, 0)
    local strings = sorted:map(function(tz)
        return '%s%s: ${%s}':format(' ':rep(width - #tz), tz_format[tz:lower()], tz:lower())
    end)

    -- Use loadstring to let Lua interpret things like \n for us
    clock:text(strings:concat(loadstring('return \'%s\'':format(settings.Separator))()))
end

config.register(settings, redraw)

clock:show()

utc_diff = os.difftime(os.time(), os.time(os.date('!*t', os.time())))

windower.register_event('prerender', function()
    local utc_now = os.time() - utc_diff
    for var in clock:it() do
        if tz_format[var] then
            clock[var] = os.date(settings.Format, utc_now + time_zones[tz_format[var]])
        end
    end
end)

windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'help'
    local args = {...}

    if command == 'help' or command == 'h' then
        print(_addon.name .. ' v.' .. _addon.version)
        print('    \\cs(51, 153, 255)f\\cs(153, 204, 255)ormat\\cr - Displays the current or sets a new format to use')
        print('    \\cs(51, 153, 255)a\\cs(153, 204, 255)dd\\cr - Adds a new time zone to the list')
        print('    \\cs(51, 153, 255)r\\cs(153, 204, 255)emove\\cr - Removes a time zone to the current list')

    elseif command == 'format' or command == 'f' then
        if args[1] then
            settings.Format = args[1]
            config.save(settings)
        end

        log('Format: %s':format(settings.Format))

    elseif command == 'add' or command == 'a' then
        if not args[1] then
            error('Invalid syntax: //clock add <timezone>')
            return
        end

        local tz = tz_format[args[1]]
        if not tz then
            error('Unknown time zone identifier: %s':format(args[1]))
            return
        end

        if settings.TimeZones:contains(tz) then
            notice('Time zone "%s" is already being displayed.':format(tz))
            return
        end

        settings.TimeZones:append(tz)
        config.save(settings)
        redraw()

    elseif command == 'remove' or command == 'r' then
        if not args[1] then
            error('Invalid syntax: //clock add <timezone>')
            return
        end

        local tz = tz_format[args[1]]
        if not tz then
            error('Unknown time zone identifier: %s':format(args[1]))
            return
        end

        if not settings.TimeZones:contains(tz) then
            notice('Time zone "%s" is not being displayed.':format(tz))
            return
        end

        settings.TimeZones:remove(settings.TimeZones:find(tz))
        config.save(settings)
        redraw()

    end
end)

--[[
Copyright © 2015, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
