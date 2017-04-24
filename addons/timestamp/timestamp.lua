--[[
timestamp v1.20131102

Copyright © 2013-2014, Giuliano Riccio
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of timestamp nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Giuliano Riccio BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name     = 'timestamp'
_addon.author   = 'Zohno'
_addon.version  = '1.20131102'
_addon.commands = {'timestamp', 'ts'}

chars = require('chat.chars')
require('logger')
require('tables')
require('sets')
require('lists')

config = require('config')

do
    local now  = os.time()
    local h, m = math.modf(os.difftime(now, os.time(os.date('!*t', now))) / 3600)

    tz = '%+.4d':format(100 * h + 60 * m)
    tz_sep = '%+.2d:%.2d':format(h, 60 * m)
end

constants = {
    ['year']         = '%Y',
    ['y']            = '%Y',
    ['year_short']   = '%y',
    ['month']        = '%m',
    ['m']            = '%m',
    ['month_short']  = '%b',
    ['month_long']   = '%B',
    ['day']          = '%d',
    ['d']            = '%d',
    ['day_short']    = '%a',
    ['day_long']     = '%A',
    ['hour']         = '%H',
    ['h']            = '%H',
    ['hour24']       = '%H',
    ['hour12']       = '%I',
    ['minute']       = '%M',
    ['min']          = '%M',
    ['second']       = '%S',
    ['s']            = '%S',
    ['sec']          = '%S',
    ['ampm']         = '%p',
    ['timezone']     = tz,
    ['tz']           = tz,
    ['timezone_sep'] = tz_sep,
    ['tz_sep']       = tz_sep,
    ['time']         = '%H:%M:%S',
    ['date']         = '%Y-%m-%d',
    ['datetime']     = '%Y:%m:%d %H:%M:%S',
    ['iso8601']      = '%Y-%m-%dT%H:%M:%S' .. tz_sep,
    ['rfc2822']      = '%a, %d %b %Y %H:%M:%S ' .. tz,
    ['rfc822']       = '%a, %d %b %y %H:%M:%S ' .. tz,
    ['rfc1036']      = '%a, %d %b %y %H:%M:%S ' .. tz,
    ['rfc1123']      = '%a, %d %b %Y %H:%M:%S ' .. tz,
    ['rfc3339']      = '%Y-%m-%dT%H:%M:%S' .. tz_sep,
}

lead_bytes = S{0x1E, 0x1F, 0xF7, 0xEF, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x7F}
newline_pattern = '[' .. string.char(0x07, 0x0A) .. ']'

defaults = {}
defaults.color  = 201
defaults.format = '[${time}]'

settings = config.load(defaults)

function make_timestamp(format)
    return os.date((format:gsub('%${([%l%d_]+)}', constants)))
end

windower.register_event('incoming text', function(original, modified, mode, newmode, blocked)
    if blocked then
        return
    end

    if mode == 151 or mode == 150 then
        newmode = 151
    else
        local lines = L{}

        -- Split by newline, if applicable
        if modified:match(newline_pattern) then
            local split = modified:split(newline_pattern, 0, true, false)
            lines:append(split[1])

            for i = 2, split.n, 2 do
                local last = lines:last()[-1]
                if last and lead_bytes:contains(last:byte()) then
                    lines[-1] = '%s%s%s':format(lines[-1], split[i], split[i+1])
                else
                    lines:append(split[i + 1])
                end
            end

            if lines:last() == '' then
                lines:remove(lines.n)
            end

            -- Insert spaces in NPC text
            if mode == 190 then
                for i = 2, lines.n do
                    lines[i] = string.char(0x81, 0x40) .. lines[i]
                end
            end
        else
            lines:append(modified)
        end

        -- Append the colored timestamp before every line and concatenate them again by a newline
        modified = lines:map(function(str)
            return make_timestamp(settings.format):color(settings.color)..' '..str
        end):concat(string.char(0x0A))
    end

    return modified, newmode
end)

windower.register_event('addon command', function(cmd, ...)
    cmd = cmd and cmd:lower() or 'help'
    local args = {...}

    if cmd == 'format' then
        if not args[1] then
            error('Please specify the new timestamp format.')
        elseif args[1] == 'help' then
            log('Sets the timestamp format.')
            log('Usage: timestamp format [help|<format>]')
            log('Positional arguments:')
            log(chars.wsquare..' help: shows the help text.')
            log(chars.wsquare..' <format>: defines the timestamp format. The available constants are:')

            for key in constants:keyset():sort():it() do
                log('  ${'..key..'}: '..make_timestamp('${'..key..'}'))
            end
        else
            settings.format = args[1]

            settings:save()
            log('The new timestamp format has been saved ('..make_timestamp(settings.format)..').')
        end

    elseif cmd == 'color' then
        if not args[1] then
            error('Please specify the new timestamp color.')
        elseif args[1] == 'help' then
            log('Sets the timestamp color.')
            log('Usage: timestamp color [help|<color>]')
            log('Positional arguments:')
            log(chars.wsquare..' help: shows the help text.')
            log(windower.to_shift_jis(chars.wsquare..' <color>: defines the timestamp color. The value must be between 0 and 511, inclusive.'))
        else
            local color = tonumber(args[1])

            if not color or color < 0x00 or color > 0xFF then
                error('Please specify a valid color.')
            else
                settings.color = color

                settings:save()
                log('The new timestamp color has been saved ('..color..').')
            end
        end

    elseif cmd == 'save' then
        settings:save('all')

    else
        log(chars.wsquare..' timestamp [<command>] help -- shows the help text.')
        log(chars.wsquare..' timestamp color <color> -- sets the timestamp color.')
        log(chars.wsquare..' timestamp format <format> -- sets the timestamp format.')
    end
end)
