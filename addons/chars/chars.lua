--[[
chars v1.20130521

Copyright (c) 2013, Giuliano Riccio
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

local chars = require('json').read('../libs/ffxidata.json').chat.chars

function event_load()
    send_command('alias chars lua c chars')
end

function event_unload()
    send_command('alias chars lua c chars')
end

function event_addon_command(...)
    for code, char in pairs(chars) do
        add_to_chat(55, '<'..code..'>: '..char)
    end

    add_to_chat(55, 'type <j:whatever you want, even punctuation> to replace each character to japanese one where available')
end

function event_outgoing_text(original, modified)
    for str in modified:gmatch('<j:([^>]+)>') do
        local jString = {}

        for char in str:gmatch('.') do
            if type(chars['j'..char]) ~= 'nil' then
                jString[#jString + 1] = chars['j'..char]
            else
                jString[#jString + 1] = char
            end
        end

        modified = modified:gsub('<j:'..str..'>', table.concat(jString), 1)
    end

    for char in modified:gmatch('<([%w]+)>') do
        if type(chars[char]) ~= 'nil' then
            modified = modified:gsub('<'..char..'>', chars[char], 1)
        end
    end

    return modified
end
