_addon.author = 'Arcon'
_addon.version = '2.1.2.0'
_addon.language = 'English'
_addon.command = 'yush'

require('luau')
require('logger')
texts = require('texts')

_innerG = {}
for k, v in pairs(_G) do
    rawset(_innerG, k, v)
end
_innerG._innerG = nil
_innerG._G = _innerG
_innerG._binds = {}
_innerG._names = {}

_innerG.include = function(path)
    local full_path = '%sdata/%s':format(windower.addon_path, path)

    local file = loadfile(full_path)
    if not file then
        warning('Include file %s not found.':format(path))
        return
    end

    setfenv(file, _innerG)
    file()
end

setmetatable(_innerG, {
    __index = function(g, k)
        local t = rawget(rawget(g, '_binds'), k)
        if not t then
            t = {}
            rawset(rawget(g, '_binds'), k, t)
            rawset(rawget(g, '_names'), t, k)
        end
        return t
    end,
    __newindex = function(g, k, v)
        local t = rawget(rawget(g, '_binds'), k)
        if t and type(v) == 'table' then
            for k, v in pairs(v) do
                t[k] = v
            end
        else
            rawset(rawget(g, '_binds'), k, v)
            if type(v) == 'table' then
                rawset(rawget(g, '_names'), v, k)
            end
        end
    end
})

defaults = {}
defaults.ResetKey = '`'
defaults.BackKey = 'backspace'
defaults.Verbose = false
defaults.VerboseOutput = 'Text'
defaults.Label = {}

settings = config.load(defaults)

label = texts.new(settings.Label, settings)

binds = {}
names = {}
current = binds
stack = L{binds}
keys = S{}

output = function()
    if settings.Verbose then
        names[current] = names[current] or 'Unnamed ' .. tostring(current):sub(8)

        if settings.VerboseOutput == 'Text' then
            label:text(names[current])
        elseif settings.VerboseOutput == 'Chat' then
            log('Changing into macro set %s.':format(names[current]))
        elseif settings.VerboseOutput == 'Console' then
            print('Changing into macro set %s.':format(names[current]))
        end
    end
end

reset = function()
    current = binds
    stack = L{binds}
    output()
end

back = function()
    if stack:length() == 1 then
        current = binds
    else
        current = stack[stack:length() - 1]
        stack:remove()
    end
    output()
end

check = function(keyset)
    keyset = keyset or keys
    for key, val in pairs(current) do
        if key <= keyset then
            if type(val) == 'string' then
                windower.send_command(val)
            else
                current = val
                stack:append(current)
                output()
            end

            return true
        end
    end

    return false
end

parse_binds = function(fbinds, top)
    top = top or binds

    rawset(names, top, rawget(_innerG._names, fbinds))
    for key, val in pairs(fbinds) do
        key = S(key:split('+')):map(string.lower)
        if type(val) == 'string' then
            rawset(top, key, val)
        else
            local sub = {}
            rawset(top, key, sub)
            parse_binds(val, sub)
        end
    end
end

windower.register_event('load', 'login', 'job change', 'logout', function()
    local player = windower.ffxi.get_player()
    local file, path, filename, filepath, err
    local basepath = windower.addon_path .. 'data/'
    if player then
        for filepath_template in L{
            {path = 'name_main_sub.lua',    format = '%s\'s %s/%s'},
            {path = 'name_main.lua',        format = '%s\'s %s'},
            {path = 'name.lua',             format = '%s\'s'},
            {path = 'binds.lua',            format = '"binds"'},
        }:it() do
            path = filepath_template.format:format(player.name, player.main_job, player.sub_job or '')
            filename = filepath_template.path:gsub('name', player.name):gsub('main', player.main_job):gsub('sub', player.sub_job or '')
            filepath = basepath .. filename
            if windower.file_exists(filepath) then
                file, err = loadfile(filepath)
                break
            end
        end
    end

    if file and not err then
        _innerG._names = {}
        _innerG._binds = {}
        binds = {}
        names = {}
        keys = S{}

        setfenv(file, _innerG)
        local root = file()
        if not root then
            _innerG._names = {}
            _innerG._binds = {}
            error('Malformatted %s Lua file: no return value.':format(path))
            return
        end

        _innerG._names[root] = _innerG._names[root] or 'Root'
        parse_binds(root)
        reset()

        print('Yush: Loaded %s Lua file':format(path))
    elseif err then
        print('\nYush: Error loading file: '..err:gsub('\\','/'))
    elseif player then
        print('Yush: No matching file found for %s (%s%s)':format(player.name, player.main_job, player.sub_job and '/' .. player.sub_job or ''))

    end
end)

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
                back()
                return true
            end
        end

        return check()
    end
end)

windower.register_event('prerender', function()
    if settings.Verbose and settings.VerboseOutput == 'Text' then
        label:show()
    else
        label:hide()
    end
end)

windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'help'
    local args = {...}

    if command == 'reset' then
        reset()

    elseif command == 'back' then
        back()

    elseif command == 'press' then
        check(S(args):map(string.lower))

    elseif command == 'set' then
        if not args[1] then
            error('Specify a settings category.')
            return
        end

        local category = args[1]:lower()
        local param = args[2] and args[2]:lower() or nil

        if category == 'verbose' then
            if param == 'true' then
                settings.Verbose = true
            elseif param == 'false' then
                settings.Verbose = false
            elseif param == 'toggle' then
                settings.Verbose = not settings.Verbose
            else
                log('Verbose settings are %s.':format(settings.Verbose and 'on' or 'off'))
                return
            end

        elseif category == 'backkey' then
            if not param then
                log('Current "Back" key: %s':format(settings.BackKey))
                return
            elseif not table.find(param) then
                error('Key %s unknown.':format(param))
                return
            else
                settings.BackKey = param
            end

        elseif category == 'resetkey' then
            if not param then
                log('Current "Reset" key: %s':format(settings.ResetKey))
                return
            elseif not table.find(param) then
                error('Key %s unknown.':format(param))
                return
            else
                settings.ResetKey = param
            end

        elseif category == 'verboseoutput' then
            if not param then
                log('Currently verbose mode outputs to %s.':format(
                    settings.VerboseOutput == 'Text' and 'a text object'
                    or settings.VerboseOutput == 'Chat' and 'the chat log'
                    or settings.VerboseOutput == 'Console' and 'the console'
                ))
                return
            elseif param == 'text' then
                settings.VerboseOutput = 'Text'
            elseif param == 'chat' then
                settings.VerboseOutput = 'Chat'
            elseif param == 'console' then
                settings.VerboseOutput = 'Console'
            end

        end

        config.save(settings)

    elseif command == 'save' then
        config.save(settings, 'all')

    end
end)

--[[
Copyright © 2014, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
