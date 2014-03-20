--[[
A library to handle ingame resources, as provided by the Radsources XMLs. It will look for the files in Windower/plugins/resources.
]]

_libs = _libs or {}
_libs.resources = true
_libs.functions = _libs.functions or require('functions')
_libs.tables = _libs.tables or require('tables')
_libs.strings = _libs.strings or require('strings')
_libs.files = _libs.files or require('files')
_libs.xml = _libs.xml or require('xml')

local fns = {}

local slots = {}

local language_string = _addon and _addon.language and _addon.language:lower() or windower.ffxi.get_info().language:lower()
local log_language_string = 'log_' .. language_string

-- The metatable for all sub tables of the root resource table
local resource_mt = {}

-- The metatable for the root resource table
local resources = setmetatable({}, {__index = function(t, k)
    if fns[k] then
        t[k] = setmetatable(fns[k](), resource_mt)
        return t[k]
    end
end})

-- The metatable for a single resource item (an entry in a sub table of the root resource table)
local resource_entry_mt = {__index = function(t, k)
    return k == 'name'
            and t[language_string]
        or k == 'log_name'
            and t[log_language_string]
        or table[k]
end}

function resource_group(r, fn, attr)
    fn = type(fn) == 'function' and fn or functions.equals(fn)

    local res = {}
    for index, item in pairs(r) do
        if fn(item[attr]) then
            res[index] = item
        end
    end

    slots[res] = slots[r]
    return setmetatable(res, resource_mt)
end

resource_mt.__index = function(t, k)
    return (slots[t]:contains(k) or k == 'name')
            and resource_group-{k}
        or table[k]
end
resource_mt.__class = 'Resource'

local plugin_resources = '../../plugins/resources/'
local addon_resources = 'resources/'

local unquotes = {
    ['quot'] = '"',
    ['amp'] = '&',
    ['gt'] = '>',
    ['lt'] = '<',
    ['apos'] = '\'',
}

local unquote = function(str)
    return (str:gsub('&(.-);', unquotes))
end

local flag_cache = {}
resources.parse_flags = function(bits)
    if not flag_cache[bits] then
        local res = S{}

        local rem
        local count = 0
        local num = bits:number(16)
        while num > 0 do
            num, rem = (num/2):modf()
            if rem > 0 then
                res:add(count)
            end
            count = count + 1
        end

        flag_cache[bits] = res
    end

    return flag_cache[bits]
end

-- Add resources from files
local res_names = S{'jobs', 'races', 'weather', 'servers', 'chat', 'bags', 'slots', 'statuses', 'emotes', 'skills', 'titles', 'encumbrance', 'check_ratings', 'synth_ranks', 'days', 'moon_phases', 'elements', 'monster_abilities', 'action_messages', 'abilities', 'spells', 'buffs', 'zones'}
for res_name in res_names:it() do
    fns[res_name] = function()
        local res = table.map(require(addon_resources .. res_name), (setmetatable-{resource_entry_mt}):cond(function(key) return type(key) == 'table' end))
        slots[res] = table.keyset(next[2](res))
        return res
    end
end

-- Returns the items, indexed by ingame ID.
function fns.items()
    local res = table.map(require(addon_resources .. res_name), (setmetatable-{resource_entry_mt}):cond(function(key) return type(key) == 'table' end))
    slots[res] = table.keyset(next[2](res))

    for i,v in res do
        if v.races then
            res[i].races = resources.parse_flags(races)
        end
        if v.jobs then
            res[i].jobs = resources.parse_flags(jobs)
        end
        if v.slots then
            res[i].slots = resources.parse_flags(slots)
        end
    end
    return res
end

return resources

--[[
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
