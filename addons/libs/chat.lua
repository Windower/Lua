--[[
    A collection of FFXI-specific chat/text functions and character/control database.
]]

_libs = _libs or {}

require('tables')
require('sets')
require('strings')

local table, set, string = _libs.tables, _libs.sets, _libs.strings

local chat = {}

chat.colors = require('chat/colors')
chat.controls = require('chat/controls')

_libs.chat = chat

-- Returns a color from a given input.
local function make_color(col)
    if type(col) == 'number' then
        if col <= 0x000 or col == 0x100 or col == 0x101 or col > 0x1FF then
            warning('Invalid color number '..col..'. Only numbers between 1 and 511 permitted, except 256 and 257.')
            col = ''
        elseif col <= 0xFF then
            col = chat.controls.color1..string.char(col)
        else
            col = chat.controls.color2..string.char(col - 256)
        end
    else
        if #col > 2 then
            local cl = col
            col = chat.colors[col]
            if col == nil then
                warning('Color \''..cl..'\' not found.')
                col = ''
            end
        end
    end

    return col
end

local invalids = S{0, 256, 257}

-- Returns str colored as specified by newcolor. If oldcolor is omitted, the string color will reset.
function string.color(str, new_color, reset_color)
    if new_color == nil or invalids:contains(new_color) then
        return str
    end

    reset_color = reset_color or chat.controls.reset

    new_color = make_color(new_color)
    reset_color = make_color(reset_color)

    return str:enclose(new_color, reset_color)
end

-- Strips a string of all colors.
function string.strip_colors(str)
    return (str:gsub('['..string.char(0x1E, 0x1F, 0x7F)..'].', ''))
end

-- Strips a string of auto-translate tags.
function string.strip_auto_translate(str)
    return (str:gsub(string.char(0xEF)..'['..string.char(0x27, 0x28)..']', ''))
end

-- Strips a string of all colors and auto-translate tags.
function string.strip_format(str)
    return str:strip_colors():strip_auto_translate()
end

--[[
    The following functions are for text object strings, since they behave differently than chatlog strings.
]]

-- Returns str colored as specified by (new_alpha, new_red, ...). If reset values are omitted, the string color will reset.
function string.text_color(str, new_red, new_green, new_blue, reset_red, reset_green, reset_blue)
    if str == '' then
        return str
    end

    if reset_blue then
        return chat.make_text_color(new_red, new_green, new_blue)..str..chat.make_text_color(reset_red, reset_green, reset_blue)
    end

    return chat.make_text_color(new_red, new_green, new_blue)..str..'\\cr'
end

-- Returns a color string in console format.
function chat.make_text_color(red, green, blue)
    return '\\cs('..red..', '..green..', '..blue..')'
end

-- Returns a string stripped of console formatting information.
function string.text_strip_format(str)
    return (str:gsub('\\cs%(%s*%d+,%s*%d+,%s*%d+%s*%)(.-)', ''):gsub('\\cr', ''))
end

chat.text_color_reset = '\\cr'

return chat

--[[
Copyright © 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
