_addon.name = 'Text'
_addon.author = 'Dewin'
_addon.version = '1.0.0.0'
_addon.command = 'text'

require('lists')
require('logger')
texts = require('texts')

text_map = {}

bool_commands = S{'visible', 'right_justified', 'left_justified', 'top_justified', 'bottom_justified', 'bold', 'italic', 'bg_visible'}
string_commands = S{'font', 'append', 'appendline'}
concat_commands = S{'text'}

windower.register_event('addon command', function(name, command, ...)
    command = command and command:lower() or 'help'
    local key = name:lower()
    local args = L{...}

    if command == 'create' or command == 'c' then
        if text_map[key] then
            warning('Text "%s" already exists.':format(name))
            return
        end

        local t = texts.new(args:concat(' '))
        t:show()
        text_map[key] = t

    elseif command == 'delete' then
        local t = text_map[key]
        if not t then
            warning('Text "%s" does not exist.':format(name))
            return
        end

        t:destroy()
        text_map[key] = nil

    else
        local t = text_map[key]
        if not t then
            error('Text "%s" does not exist.':format(name))
            return
        end

        local args = L{...}
        
        if bool_commands:contains(command) then
            args = args:map(functions.equals('true'))
        elseif concat_commands:contains(command) then
            args = L{args:concat(' ')}
        elseif not string_commands:contains(command) then
            args = args:map(tonumber)
        end


        texts[command:lower()](t, args:unpack())

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
