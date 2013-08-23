--[[
timestamp v1.20130616

Copyright (c) 2013, Giuliano Riccio
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

require 'chat'
require 'logger'
require 'tablehelper'

config = require 'config'

_addon = {}
_addon.name     = 'timestamp'
_addon.version  = '1.20130616'
_addon.commands = {'timestamp', 'ts'}

function timezone()
    local now  = os.time()
    local h, m = math.modf(os.difftime(now, os.time(os.date('!*t', now))) / 3600)

    return string.format('%+.4d', 100 * h + 60 * m), string.format('%+.2d:%.2d', h, 60 * m)
end

tz, tz_sep = timezone()

constants = T{
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
    ['iso8601']      = '%Y-%m-%dT%H:%M:%S'..tz_sep,
    ['rfc2822']      = '%a, %d %b %Y %H:%M:%S '..tz,
    ['rfc822']       = '%a, %d %b %y %H:%M:%S '..tz,
    ['rfc1036']      = '%a, %d %b %y %H:%M:%S '..tz,
    ['rfc1123']      = '%a, %d %b %Y %H:%M:%S '..tz,
    ['rfc3339']      = '%Y-%m-%dT%H:%M:%S'..tz_sep
}

lead_bytes_pattern = string.char(0x1E, 0x1F, 0xF7, 0xEF, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89)

defaults = {}
defaults.color  = 508
defaults.format = '[${time}]'

settings = {}

function get_string(format)
    local formatted_string = format:gsub('%${([%l%d_]+)}', function(match) if constants[match] ~= nil then return os.date(constants[match]) else return match end end)

    return formatted_string
end

function initialize()
    settings = config.load(defaults)
end

function event_load()
    send_command('alias timestamp lua c timestamp')
    send_command('alias ts lua c timestamp')

    if get_ffxi_info().logged_in then
        initialize()
    end
end

function event_login()
    initialize()
end

function event_unload()
    send_command('unalias timestamp')
    send_command('unalias ts')
end

function event_incoming_text(original, modified, mode)
    if modified ~= '' and not modified:find('^[%s]+$') then
        if mode == 144 then -- 144 works as 150 but the enter prompts are ignored.
            mode     = 150
            modified = modified:gsub(string.char(0x7f, 0x31)..'$', '')
        end

        if mode == 150 then -- 150 automatically indents new lines. 151 works the same way but with no indentation. redirect to 151 and manually add the ideographic space.
            mode     = 151
            modified = modified:gsub('([^'..lead_bytes_pattern..'])['..string.char(0x07)..'\n]', '%1\n'..string.char(0x81, 0x40))
        end

        if mode ~= 151 then
            local timeString = get_string(settings.format):color(settings.color)..' '

            modified = timeString..modified:gsub('^['..string.char(0x07)..'\n]+', '')
                                           :gsub('([^'..lead_bytes_pattern..'])['..string.char(0x07)..'\n]+$', '%1')
                                           :gsub('([^'..lead_bytes_pattern..'])['..string.char(0x07)..'\n]', '%1\n'..timeString)
        end
    end

    return modified, mode
end

function event_addon_command(...)
    local cmd  = (...) and (...):lower() or 'help'
    local args = {select(2, ...)}

    if cmd == 'help' then
        log(chat.chars.wsquare..' timestamp [<command>] help -- shows the help text.')
        log(chat.chars.wsquare..' timestamp color <color> -- sets the timestamp color.')
        log(chat.chars.wsquare..' timestamp format <format> -- sets the timestamp format.')
    elseif cmd == 'format' then
        if not args[1] then
            error('Please specify the new timestamp format.')
        elseif args[1] == 'help' then
            log('Sets the timestamp format.')
            log('Usage: timestamp format [help|<format>]')
            log('Positional arguments:')
            log(chat.chars.wsquare..' help: shows the help text.')
            log(chat.chars.wsquare..' <format>: defines the timestamp format. The available constants are:')

            for key in constants:keyset():sort():it() do
                log('  ${'..key..'}: '..get_string('${'..key..'}'))
            end
        else
            settings.format = args[1]

            settings:save()
            log('The new timestamp format has been saved ('..get_string(settings.format)..').')
        end
    elseif cmd == 'color' then
        if not args[1] then
            error('Please specify the new timestamp color.')
        elseif args[1] == 'help' then
            log('Sets the timestamp color.')
            log('Usage: timestamp color [help|<color>]')
            log('Positional arguments:')
            log(chat.chars.wsquare..' help: shows the help text.')
            log(chat.chars.wsquare..' <color>: defines the timestamp color. The value must be between 0 and 511, inclusive.')
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
        send_command('timestamp help')
    end
end