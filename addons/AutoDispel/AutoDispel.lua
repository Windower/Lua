_addon.name = 'AutoDispel'
_addon.author = 'Jay Simons'
_addon.version = '1.0.1'
_addon.commands = { 'adisp' }

require('luau')
require('functions')
require('config')

defaults = T {}
defaults.WatchFor = T {}
defaults.DoCommand = '/ma "Dispel"'
defaults.ExecDelay = 2

settings = config.load(defaults)

local do_command = string.format('input %s <t>', settings.DoCommand)

local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

local execute_command = function()
    windower.send_command(do_command)
end

local run = false

local start = function()
    run = true
    windower.add_to_chat(2, 'Starting AutoDispel')
    windower.add_to_chat(7, '------------------------------------')
    windower.add_to_chat(7, 'Exec Delay: ' .. settings.ExecDelay)
    windower.add_to_chat(7, 'Do Command: ' .. do_command)
    if type(settings.WatchFor) == 'table' then
        windower.add_to_chat(4, 'WatchFor items:')
        for i, item in ipairs(settings.WatchFor) do
            windower.add_to_chat(4, string.format('  %d: %s', i, item))
        end
    end
    windower.add_to_chat(7, '------------------------------------')
end

local stop = function()
    run = false
    windower.add_to_chat(2, 'AutoDispel stopped')
end

-- Convert settings.WatchFor to a table if it's a string
local watch_conditions = type(settings.WatchFor) == 'string' and T { settings.WatchFor } or settings.WatchFor

windower.register_event('incoming text', function(original, modified)
    -- return if not running
    if not run then
        return modified
    end

    -- return if trimmed line starts with a number
    if trim(original):match('^%d+') then
        return modified
    end

    -- return if no original or length is 0
    if not original or #original == 0 then
        return modified
    end

    local trimmed_message = trim(original)
    if not trimmed_message or #trimmed_message == 0 then
        return modified
    end

    -- Ignore our own debug messages
    if trimmed_message:lower():match('autodispel') then
        return modified
    end

    -- Check if any of the watch conditions match
    for _, condition in ipairs(watch_conditions) do
        -- Match the exact phrase
        local pattern = condition:lower()
        if trimmed_message:lower():match(pattern) then
            windower.add_to_chat(3, 'AutoDispel executing...')
            execute_command:schedule(settings.ExecDelay)
            break -- Exit the loop once we find a match
        end
    end
end)

windower.register_event('addon command', function(command)
    command = command and command:lower() or 'help'

    if command == 'start' then
        start()
    elseif command == 'stop' then
        stop()
    elseif command == 'help' then
        windower.add_to_chat(17, 'AutoDispel  v' .. _addon.version .. ' commands:')
        windower.add_to_chat(17, '//adisp [options]')
        windower.add_to_chat(17, '    start      - Starts auto dispel')
        windower.add_to_chat(17, '    stop       - Stops auto dispel')
        windower.add_to_chat(17, '    help       - Displays this help text')
    end
end)

--[[
 	Copyright (c) 2025, Jay Simons
 	All rights reserved.

 	Redistribution and use in source and binary forms, with or without
 	modification, are permitted provided that the following conditions are met :

 	* Redistributions of source code must retain the above copyright
 	  notice, this list of conditions and the following disclaimer.
 	* Redistributions in binary form must reproduce the above copyright
 	  notice, this list of conditions and the following disclaimer in the
 	  documentation and/or other materials provided with the distribution.
 	* Neither the name of XIPivot nor the
 	  names of its contributors may be used to endorse or promote products
 	  derived from this software without specific prior written permission.

 	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 	DISCLAIMED.IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
