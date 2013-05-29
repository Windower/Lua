--[[
timestamp v1.20130528

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

local config    = require 'config'
local timestamp = {}

timestamp.defaults = T{}
timestamp.defaults.ampm = false

timestamp.settings = T{}

function event_load()
    timestamp.settings = config.load(timestamp.defaults)

    send_command('alias timestamp lua c timestamp')
end

function event_unload()
    send_command('unalias timestamp')
end

function event_incoming_text(original, modified, mode)
    if modified ~= '' and not ((mode == 150 or mode == 151) and (modified:find('\x7f\x31$') ~= nil or modified:find('\x7f\x34$') ~= nil)) then
        local timeString
        
        if timestamp.settings.ampm == false then
            timeString = os.date('%H:%M:%S')
        else
            timeString = os.date('%I:%M:%S '..os.date('%p'):upper())
        end
            
        return '\x1E\xFC['..timeString..']\x1E\x01 '..modified:gsub('\x07', '\x07\x1E\xFC['..timeString..']\x1E\x01 ')
    end

    return modified, mode
end

function event_addon_command(...)
    local args = {...}

    if #args == 0 then
        add_to_chat(55,'lua:addon:timestamp >> switches between military and ampm modes.')
        add_to_chat(55,'lua:addon:timestamp >> usage: timestamp ampm [\30\02enabled\30\01]')
        add_to_chat(55,'lua:addon:timestamp >> positional arguments:')
        add_to_chat(55,'lua:addon:timestamp >>   enabled    defines the status of ampm mode. "0", "false" or "default" to disable it. "1" or "true" to enable it. if not specified, "true" will be assumed.')

        return
    end

    if args[1] == 'ampm' then
        if args[2] == '0' or args[2] == 'false' or args[2] == 'default' then
            timestamp.settings.ampm = false

            timestamp.settings:save('all')
            add_to_chat(55,'lua:addon:timestamp >> ampm mode has been disabled.')
        elseif args[2] == '1' or args[2] == 'true' or args[2] == nil then
            timestamp.settings.ampm = true

            timestamp.settings:save('all')
            add_to_chat(55,'lua:addon:timestamp >> ampm mode has been enabled.')
        else
            add_to_chat(38, 'lua:addon:timestamp >> "'..args[2]..'" is not a valid value for \30\02enabled\30\01.')
        end
    else
        add_to_chat(38, 'lua:addon:timestamp >> "'..args[1]..'" is not a valid command.')
    end
end