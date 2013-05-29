--[[
timestamp v1.20130529

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

require 'colors'
require 'logger'
require 'tablehelper'

local config = require 'config'

_addon = {}
_addon.name = 'timestamp'
_addon.version = '1.20130529'

function timezone(separator)
    local now  = os.time()
    local h, m = math.modf(os.difftime(now, os.time(os.date('!*t', now))) / 3600)

    if separator == nil or separator == false then
        return string.format("%+.4d", 100 * h + 60 * m)
    else
        return string.format("%+.2d:%.2d", h, 60 * m)
    end
end

tz     = timezone()
tz_sep = timezone(true)

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

defaults = {}
defaults.color  = 508
defaults.format = '${time}'

settings = {}

function get_string(format)
    local formatted_string = format:gsub('%${([%l%d_]+)}', function(match) if constants[match] ~= nil then return os.date(constants[match]) else return match end end, 1)

    return formatted_string
end

function event_load()
    settings = config.load(defaults)

    send_command('alias timestamp lua c timestamp')
end

function event_unload()
    send_command('unalias timestamp')
end

function event_incoming_text(original, modified, mode)
    if modified ~= '' and not ((mode == 150 or mode == 151) and (modified:find('\x7f\x31$') ~= nil or modified:find('\x7f\x34$') ~= nil)) then
        local timeString = ('['..get_string(settings.format)..']'):color(settings.color)..' '

        return timeString..modified:gsub('\x07', '\x07'..timeString)
    end

    return modified, mode
end

function event_addon_command(...)
    local args = {...}
    
    if args[1] == nil then
        send_command('timestamp help')

        return
    end

    local cmd = table.remove(args, 1):lower()

    if cmd == 'help' then
        log('\x81\xa1 timestamp [<command>] help -- shows the help text.')
        log('\x81\xa1 timestamp color <color> -- sets the timestamp\'s color.')
        log('\x81\xa1 timestamp format <format> -- sets the timestamp\'s format.')

        return
    elseif cmd == 'format' then
        if args[1] == nil then
            error('Please specify the new timestamp\'s format.')
        elseif args[1] == 'help' then
            log('Sets the timestamp\'s format.')
            log('Usage: timestamp format [help|<format>]')
            log('Positional arguments:')
            log('\x81\xa1 help: shows the help text.')
            log('\x81\xa1 <format>: defines the timestamp\'s format. The available constants are:')

            for _, key in ipairs(constants:keyset():sort()) do
                log('  ${'..key..'}: '..get_string('${'..key..'}'))
            end
        else
            settings.format = args[1]

            settings:save('all')
            notice('The new timestamp\'s format has been set ('..get_string(settings.format)..').')
        end
    elseif cmd == 'color' then
        if args[1] == nil then
            error('Please specify the new color.')
        elseif args[1] == 'help' then    
            log('Sets the timestamp\'s color.')
            log('Usage: timestamp color [help|<color>]')
            log('Positional arguments:')
            log('\x81\xa1 help: shows the help text.')
            log('\x81\xa1 <color>: defines the timestamp\'s color. The value must be between 0 and 511, inclusive.')
        else
            local color = tonumber(args[1], 10)
            
            if color == nil or color < 0 or color >= 512 then
                error('Please specify a valid color.')
            else
                settings.color = color

                settings:save('all')
                notice('The new color has been set.')
            end
        end
    else
        error('"'..cmd..'" is not a valid command.')
    end
end