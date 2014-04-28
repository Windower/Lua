_addon.author = 'Arcon'
_addon.version = '1.0.0.1'
_addon.language = 'English'

require('luau')

defaults = {}
defaults.ResetKey = '`'
defaults.BackKey = 'backspace'

settings = config.load(defaults)

binds = {}
current = binds
stack = L{binds}

reset = function()
    current = binds
end

parse_binds = function(fbinds, top)
    top = top or binds

    for key, val in pairs(fbinds) do
        key = S(key:split('+')):map(string.lower)
        if type(val) == 'string' then
            rawset(top, key, val)
        else
            rawset(top, key, {})
            parse_binds(val, rawget(top, key))
        end
    end
end

windower.register_event('load', 'login', 'job change', 'logout', function()
    local player = windower.ffxi.get_player()
    local file
    local basepath = windower.addon_path .. 'data/'
    if player then
        for filepath in L{
            basepath .. 'name_main/sub.lua',
            basepath .. 'name_main.lua',
            basepath .. 'name.lua',
            basepath .. 'binds.lua',
        }:it() do
            file = loadfile(filepath:gsub('name', player.name):gsub('main', player.main_job):gsub('sub', player.sub_job))
            if file then
                break
            end
        end
    else
        file = loadfile(basepath .. 'binds.lua')
    end

    if file then
        parse_binds(file())
        reset()
    end
end)

keys = S{}

dikt = {    -- Har har
    [1] = 'esc',
    [2] = '1',
    [3] = '2',
    [4] = '3',
    [5] = '4',
    [6] = '5',
    [7] = '6',
    [8] = '7',
    [9] = '8',
    [10] = '9',
    [11] = '0',
    [12] = '-',
    [13] = '=',
    [14] = 'backspace',
    [15] = 'tab',
    [16] = 'q',
    [17] = 'w',
    [18] = 'e',
    [19] = 'r',
    [20] = 't',
    [21] = 'y',
    [22] = 'u',
    [23] = 'i',
    [24] = 'o',
    [25] = 'p',
    [26] = '[',
    [27] = ']',
    [28] = 'enter',
    [29] = 'ctrl',
    [30] = 'a',
    [31] = 's',
    [32] = 'd',
    [33] = 'f',
    [34] = 'g',
    [35] = 'h',
    [36] = 'j',
    [37] = 'k',
    [38] = 'l',
    [39] = ';',
    [40] = '\'',
    [41] = '`',
    [42] = 'shift',
    [43] = '\\',
    [44] = 'z',
    [45] = 'x',
    [46] = 'c',
    [47] = 'v',
    [48] = 'b',
    [49] = 'n',
    [50] = 'm',
    [51] = ',',
    [52] = '.',
    [53] = '/',
    [54] = nil,
    [55] = 'num*',
    [56] = 'alt',
    [57] = 'space',
    [58] = nil,
    [59] = 'f1',
    [60] = 'f2',
    [61] = 'f3',
    [62] = 'f4',
    [63] = 'f5',
    [64] = 'f6',
    [65] = 'f7',
    [66] = 'f8',
    [67] = 'f9',
    [68] = 'f10',
    [69] = 'num',
    [70] = 'scroll',
    [71] = 'num7',
    [72] = 'num8',
    [73] = 'num9',
    [74] = 'num-',
    [75] = 'num4',
    [76] = 'num5',
    [77] = 'num6',
    [78] = 'num+',
    [79] = 'num1',
    [80] = 'num2',
    [81] = 'num3',
    [82] = 'num0',

    [199] = 'home',
    [200] = 'up',
    [201] = 'pageup',
    [202] = nil,
    [203] = 'left',
    [204] = nil,
    [205] = 'right',
    [206] = nil,
    [207] = 'end',
    [208] = 'down',
    [209] = 'pagedown',
    [210] = 'insert',
    [211] = 'delete',
    [219] = 'win',
    [220] = 'rwin',
    [221] = 'apps',
}

windower.register_event('keyboard', function(dik, down)
    local key = dikt[dik]
    if not key then
        return
    end

    if not down then
        keys:remove(key)
        return
    end

    if not keys:contains(key) then
        keys:add(key)

        if not windower.ffxi.get_info().chat_open then
            if key == settings.ResetKey then
                reset()
                return true
            elseif key == settings.BackKey then
                if stack:length() == 1 then
                    current = binds
                else
                    current = stack[stack:length() - 1]
                    stack:remove()
                end
                return true
            end
        end

        for key, val in pairs(current) do
            if key <= keys then
                if type(val) == 'string' then
                    windower.send_command(val)
                else
                    current = val
                    stack:append(current)
                end

                return true
            end
        end
    end
end)

--[[
Copyright (c) 2014, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
