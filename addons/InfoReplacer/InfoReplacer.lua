-- Copyright © 2014-2015, Cairthenn
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of InfoReplacer nor the
      -- names of its contributors may be used to endorse or promote products
      -- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL Cairthenn BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.author = 'Cairthenn'
_addon.name = 'InfoReplacer'
_addon.version = '2.0'
_addon.command = 'inforeplacer'

require('tables')
require('strings')
require('logger')

replace = require('reps')
raw = {}
custom = T{}
fns = {}

windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'help'
    local args = {...}

    if command == 'help' or command == 'h' then
        print(_addon.name .. 'v.' .. _addon.version)
        print('    \\cs(51, 153, 255)s\\cs(153, 204, 255)et <name> <value>\\cr - Defines a custom replacement')
        print('    \\cs(153, 204, 255)set\\cs(51, 153, 255)e\\cs(153, 204, 255)val <name> <code>\\cr - Defines a custom replacement as Lua code')
        print('    \\cs(51, 153, 255)u\\cs(153, 204, 255)nset <name>\\cr - Removes a previously defined custom replacement')
        print('    \\cs(51, 153, 255)l\\cs(153, 204, 255)ist\\cr - Lists all custom replacements')

    elseif command == 'list' or command == 'l' then
        if not custom:empty() then
            log('Available custom replacement variable list:')
            for key in custom:keyset():sort():it() do
                local value = raw[key]
                if fns[key] then
                    value = '%s ? %s':format(value, custom[key]())
                end
                log('    #' .. key, value)
            end
        else
            log('No custom replacements defined. For default replacements view ' .. windower.addon_path .. 'reps.lua')
        end

    elseif command == 'set' or command == 's' then
        if #args < 2 then
            error('Incorrect syntax. The "set" syntax is as follows: //inforeplacer set <name> <value>')
            return
        end

        custom[args[1]] = args[2]:fn()
        raw[args[1]] = args[2]
        fns[args[1]] = nil

    elseif command == 'unset' or command == 'u' then
        if #args < 1 then
            error('Incorrect syntax. The "unset" syntax is as follows: //inforeplacer unset <name>')
            return
        end

        custom[args[1]] = nil
        raw[args[1]] = nil
        fns[args[1]] = nil

    elseif command == 'seteval' or command == 'e' then
        if #args < 2 then
            error('Incorrect syntax. The "seteval" syntax is as follows: //inforeplacer seteval <name> <value>')
            return
        end

        custom[args[1]] = assert(loadstring('return ' .. args[2]))
        raw[args[1]] = args[2]
        fns[args[1]] = true

    end
end)

windower.register_event('outgoing text', function(original,modified,blocked)
    return modified:gsub('%%[^ ]+', function(match)
        local token = match:sub(2)
        local fn = custom[token] or replace[token]
        return fn and fn() or match
    end)
end)
