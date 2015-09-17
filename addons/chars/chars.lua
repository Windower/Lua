--[[
Copyright © 2013-2014, Giuliano Riccio
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of chars nor the
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

require('lists')
require('logger')
require('strings')

_addon.name     = 'chars'
_addon.version  = '1.20141219'
_addon.command  = 'chars'

chars = require('chat.chars')

windower.register_event('addon command', function(...)
    for code, char in pairs(chars) do
        log('<%s>: %s':format(code, char))
    end

    log('Using the pattern <j:text> any alphanumeric character will be replaced with its full-width ("japanese style") version')
end)

windower.register_event('outgoing text', function(_, modified)
    return modified:psplit('<[^>]+>', nil, true):map(function(token)
        if token:match('^<.*>$') then
            if token:startswith('<j:') then
                return token:sub(4, -2):map(function(char)
                    return chars['j' .. char] or char
                end)
            else
                return chars[token:sub(2, -2)] or token
            end
        else
            return token
        end
    end):concat()
end)
