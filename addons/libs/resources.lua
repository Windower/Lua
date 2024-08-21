--[[
    A library to handle ingame resources, as provided by ResourceExtractor. It will look for the files in Windower/res/.
]]

_libs = _libs or {}

require('functions')
require('tables')
require('sets')
require('strings')
require('bit')

local functions, table, string = _libs.functions, _libs.tables, _libs.strings

local fns = {}

local slots = setmetatable({}, {__mode = 'k'})
local bit_slots = {}

local language_string = _addon and _addon.language and _addon.language:lower() or windower.ffxi.get_info().language:lower()
local language_string_log = language_string .. '_log'
local language_string_short = language_string .. '_short'

-- The metatable for all sub tables of the root resource table
local resource_mt = {}

-- The metatable for the root resource table
local resources = setmetatable({}, {__index = function(t, k)
    if fns[k] then
        t[k] = setmetatable(fns[k](), resource_mt)
        return t[k]
    end
end})

_libs.resources = resources

local redict = {
    name = language_string,
    name_log = language_string_log,
    name_short = language_string_short,
    english = 'en',
    japanese = 'ja',
    english_log = 'enl',
    japanese_log = 'ja',
    english_short = 'ens',
    japanese_short = 'jas',
}

-- The metatable for a single resource item (an entry in a sub table of the root resource table)
local resource_entry_mt = {__index = function()
    return function(t, k)
        return redict[k] and t[redict[k]] or table[k]
    end
end()}

function resource_group(r, fn, attr)
    attr = redict[attr] or attr
    fn = type(fn) == 'function' and fn or
        bit_slots[attr] and class(fn) == 'Set' and set.subset+{fn} or
        bit_slots[attr] and set.contains-{fn} or
        functions.equals(fn)

    local res = {}
    for value, id in table.it(r) do
        if value[attr] ~= nil and fn(value[attr]) then
            res[id] = value
        end
    end

    slots[res] = slots[r]
    return setmetatable(res, resource_mt)
end

resource_mt.__class = 'Resource'

resource_mt.__index = function(t, k)
    return slots[t] and slots[t]:contains(k) and resource_group:endapply(k) or table[k]
end

resource_mt.__tostring = function(t)
    return '{' .. t:map(table.get:endapply('name')):concat(', ') .. '}'
end

local resources_path = windower.windower_path .. 'res/'

local flag_cache = {}

local check_flags = function(bits, lookup)
    if lookup.combination == 'replace' and lookup.values[bits] ~= nil then
        return S{lookup.values[bits]}
    end

    local flags = S{}

    for flag, value in pairs(lookup.values) do
        if bit.band(flag, bits) >= flag then
            flags:add(value)
        end
    end

    return flags
end

local parse_flags = function(bits)
    local flags = S{}

    local count = 0
    repeat
        local flag = 2 ^ count
        if bit.band(flag, bits) >= flag then
            flags:add(count)
        end
        count = count + 1
    until flag > bits

    return flags
end

local get_flags = function(bits, attribute, lookup)
    flag_cache[attribute] = flag_cache[attribute] or {}
    flag_cache[attribute][bits] = flag_cache[attribute][bits] or lookup and check_flags(bits, lookup) or parse_flags(bits)
    return flag_cache[attribute][bits]
end

-- Add resources from files
local post_process
local res_names = S(windower.get_dir(resources_path)):filter(string.endswith-{'.lua'}):map(string.sub-{1, -5})
for res_name in res_names:it() do
    fns[res_name] = function()
        local res, slot_table = dofile(resources_path .. res_name .. '.lua')
        res = table.map(res, (setmetatable-{resource_entry_mt}):cond(functions.equals('table') .. type))
        slots[res] = S(slot_table)
        post_process(res)
        return res
    end
end

local fn_cache = {}

post_process = function(t)
    local slot_set = slots[t]
    for key in slot_set:filter(table.get+{bit_slots}):it() do
        fn_cache[key] = get_flags-{key, bit_slots[key] ~= true and bit_slots[key] or nil}
    end

    for _, entry in pairs(t) do
        for key, fn in pairs(fn_cache) do
            if entry[key] ~= nil then
                entry[key] = fn(entry[key])
            end
        end
    end

    for key in pairs(redict) do
        slot_set:add(key)
    end
end

bit_slots = {
    jobs = true,
    slots = true,
    races = true,
    targets = {
        combination = 'replace',
        values = {
            [0x01] = 'Self',
            [0x02] = 'Player',
            [0x04] = 'Party',
            [0x08] = 'Ally',
            [0x10] = 'NPC',
            [0x20] = 'Enemy',

            [0x60] = 'Object',
            [0x9D] = 'Corpse',
        },
    },
    flags = {
        values = {
            [0x0001] = 'Wall-mounted',
            [0x0002] = 'Flag01',
            [0x0004] = 'Obtainable from Goblin Box',
            [0x0008] = 'Usable inside Mog Garden',
            [0x0010] = 'Can Send POL',
            [0x0020] = 'Inscribable',
            [0x0040] = 'No Auction',
            [0x0080] = 'Scroll',
            [0x0100] = 'Linkshell',
            [0x0200] = 'Usable',
            [0x0400] = 'NPC Tradeable',
            [0x0800] = 'Equippable',
            [0x1000] = 'No NPC Sale',
            [0x2000] = 'No Delivery',
            [0x4000] = 'No PC Trade',
            [0x8000] = 'Rare',

            [0x6040] = 'Exclusive',
        },
    },
}

return resources

--[[
Copyright © 2013-2015, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
