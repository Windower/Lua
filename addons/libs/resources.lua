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
local language_string = language_string .. '_log'

-- The metatable for all sub tables of the root resource table
local resource_mt = {}

-- The metatable for the root resource table
local resources = setmetatable({}, {__index = function(t, k)
    if fns[k] then
        t[k] = setmetatable(fns[k](), resource_mt)
        return t[k]
    end
end})

local redict = {
    name = language_string,
    name = language_string_log,
    english = 'en',
    japanese = 'ja',
    german = 'de',
    french = 'fr',
    english_log = 'enl',
    japanese_log = 'ja',
    german_log = 'del',
    french_log = 'frl',
    english_short = 'ens',
    japanese_short = 'jas',
    german_short = 'des',
    french_short = 'frs',
}

-- The metatable for a single resource item (an entry in a sub table of the root resource table)
local resource_entry_mt = {__index = function()
    return function(t, k)
        return redict[k]
                and t[redict[k]]
            or table[k]
    end
end()}

function resource_group(r, fn, attr)
    fn = type(fn) == 'function' and fn or functions.equals(fn)
    attr = redict[attr] or attr

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
    return (slots[t]:contains(k) or slots[t]:contains(redict[k]))
            and resource_group-{k}
        or table[k]
end
resource_mt.__class = 'Resource'

local resources_path = windower.windower_path .. 'res/'

local flag_cache = {}
local parse_flags = function(bits, lookup, values)
    if not rawget(flag_cache, lookup) then
        rawset(flag_cache, lookup, {})
    end

    if values and not rawget(rawget(flag_cache, lookup), bits) and rawget(lookup, bits) then
        rawset(rawget(flag_cache, lookup), bits, S{rawget(lookup, bits)})
    elseif not rawget(rawget(flag_cache, lookup), bits) then
        local res = S{}

        local rem
        local num = bits
        local count = 0
        while num > 0 do
            num, rem = (num/2):modf()
            if rem > 0 then
                -- Commented out due to current API returning numbers instead of objects
                -- res:add(rawget(lookup, values and 2^count or count))
                res:add(values and rawget(lookup, 2^count) or count)
            end
            count = count + 1
        end

        rawset(rawget(flag_cache, lookup), bits, res)
    end

    return rawget(rawget(flag_cache, lookup), bits)
end

local language_strings = S{'english', 'japanese', 'german', 'french'}

-- Add resources from files
local post_process
local res_names = S(windower.get_dir(resources_path)):filter(string.endswith-{'.lua'}):map(string.sub-{1, -5})
for res_name in res_names:it() do
    fns[res_name] = function()
        local res, slot_table = dofile(resources_path .. res_name .. '.lua')
        res = table.map(res, (setmetatable-{resource_entry_mt}):cond(function(key) return type(key) == 'table' end))
        slots[res] = S(slot_table) or language_strings + table.keyset(next[2](res))
        post_process(res)
        return res
    end
end

local lookup = {}
local flag_keys = S{
    'flags',
    'targets',
}
local fn_cache = {}

post_process = function(t)
    for key in slots[t]:it() do
        if rawget(lookup, key) then
            if flag_keys:contains(key) then
                rawset(fn_cache, key, function(flags)
                    return parse_flags(flags, rawget(lookup, key), true)
                end)
            else
                rawset(fn_cache, key, function(flags)
                    return parse_flags(flags, rawget(lookup, key), false)
                end)
            end

        elseif rawget(lookup, key .. 's') then
            rawset(fn_cache, key, function(value)
--                return rawget(rawget(lookup, key .. 's'), value)
                return value
            end)

        end
    end

    for _, entry in pairs(t) do
        for key, fn in pairs(fn_cache) do
            if rawget(entry, key) ~= nil then
                rawset(entry, key, fn(rawget(entry, key)))
            end
        end
    end
end

lookup = {
    elements = resources.elements,
    jobs = resources.jobs,
    slots = resources.slots,
    races = resources.races,
    skills = resources.skills,
    targets = {
        [0x01] = 'Self',
        [0x02] = 'Player',
        [0x04] = 'Party',
        [0x08] = 'Ally',
        [0x10] = 'NPC',
        [0x20] = 'Enemy',

        [0x60] = 'Object',
        [0x9D] = 'Corpse',
    },
    flags = {
        [0x0001] = 'Flag00',
        [0x0002] = 'Flag01',
        [0x0004] = 'Flag02',
        [0x0008] = 'Flag03',
        [0x0010] = 'Flag04',
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
}

return resources

--[[
Copyright (c) 2013-2014, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
