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

-- Add resources from files
local res_names = S{'jobs', 'races', 'weather', 'servers', 'chat', 'bags', 'slots', 'statuses', 'emotes', 'skills', 'titles', 'encumbrance', 'check_ratings', 'synth_ranks', 'days', 'moon_phases', 'elements', 'monster_abilities', 'action_messages'}
for res_name in res_names:it() do
    fns[res_name] = function()
        local res = table.map(require(addon_resources .. res_name), (setmetatable-{resource_entry_mt}):cond(function(key) return type(key) == 'table' end))
        slots[res] = table.keyset(next[2](res))
        return res
    end
end

resources.convert = function(bits)
    local res = S{}

    local rem
    local count = 0
    while bits > 0 do
        bits, rem = (bits/2):modf()
        if rem > 0 then
            res:add(count)
        end
        count = count + 1
    end

    return res
end

-- Returns the abilities, indexed by ingame ID.
function fns.abilities()
    local file = _libs.files.read(plugin_resources..'abils.xml')
    local match_string
    local last = {}

    local res = {}
    slots[res] = S{}

    match_string = '<a id="(%-?%d-)" index="(%d-)" prefix="(/%a-)" english="([^"]-)" german="([^"]-)" french="([^"]-)" japanese="([^"]-)" type="(%w-)" element="([%a,%s]-)" targets="([%a,%s]-)" skill="(%a-)" mpcost="(%d-)" tpcost="(%-?%d-)" casttime="(%d-)" recast="(%d-)" alias="([%w|]-)" />'
    for id, index, prefix, english, german, french, japanese, type, elements, targets, skill, mp_cost, tp_cost, cast_time, recast, alias in file:gmatch(match_string) do
        id = id:number()
        res[id] = setmetatable({
            id = id,
            index = index:number(),
            prefix = prefix,
            english = unquote(english),
            german = unquote(german),
            french = unquote(french),
            japanese = unquote(japanese),
            type = type,
            elements = S(elements:split(', ')):remove('None'),
            targets = S(targets:split(', ')),
            skill = skill,
            mp_cost = mp_cost:number(),
            tp_cost = tp_cost:number(),
            cast_time = cast_time:number(),
            recast = recast:number(),
            alias = S(alias:split('|')),
        }, resource_entry_mt)
        last = res[id]
    end
    slots[res] = slots[res] + table.keyset(last)

    match_string = '<a id="(%-?%d-)" index="(%d-)" prefix="(/%a-)" english="([^"]-)" german="([^"]-)" french="([^"]-)" japanese="([^"]-)" type="(%w-)" element="([%a,%s]-)" targets="([%a,%s]-)" skill="(%a-)" mpcost="(%d-)" tpcost="(%-?%d-)" casttime="(%d-)" recast="(%d-)" alias="([%w|]-)" wsA="(%a-)" wsB="(%a-)" wsC="(%a-)" />'
    for id, index, prefix, english, german, french, japanese, type, elements, targets, skill, mp_cost, tp_cost, cast_time, recast, alias, wsA, wsB, wsC in file:gmatch(match_string) do
        id = id:number()
        res[id] = setmetatable({
            id = id,
            index = index:number(),
            prefix = prefix,
            english = unquote(english),
            german = unquote(german),
            french = unquote(french),
            japanese = unquote(japanese),
            type = type,
            elements = S(elements:split(', ')):remove('None'),
            targets = S(targets:split(', ')),
            skill = skill,
            mp_cost = mp_cost:number(),
            tp_cost = tp_cost:number(),
            cast_time = cast_time:number(),
            recast = recast:number(),
            alias = S(alias:split('|')),
            wsA = wsA,
            wsB = wsB,
            wsC = wsC,
        }, resource_entry_mt)
        last = res[id]
    end
    slots[res] = slots[res] + table.keyset(last)

    return res
end

-- Returns the spells, indexed by ingame ID.
function fns.spells()
    local file = _libs.files.read(plugin_resources..'spells.xml')
    local match_string = '<s id="(%d-)" index="(%d-)" prefix="([^"]-)" english="([^"]-)" german="([^"]-)" french="([^"]-)" japanese="([^"]-)" type="([^"]-)" element="([^"]-)" targets="([^"]-)" skill="([^"]-)" mpcost="(%d-)" casttime="([%d%.]-)" recast="([%d%.]-)" alias="([^"]-)" />'
    local last = {}

    local res = {}

    for id, index, prefix, english, german, french, japanese, type, element, targets, skill, mp_cost, cast_time, recast, alias in file:gmatch(match_string) do
        index = index:number()
        if prefix ~= '/trigger' then
            res[index] = setmetatable({
                id = id:number(),
                index = index,
                prefix = prefix,
                english = unquote(english),
                german = unquote(german),
                french = unquote(french),
                japanese = unquote(japanese),
                type = type,
                element = element,
                targets = S(targets:split(', ')),
                skill = skill,
                mp_cost = mp_cost:number(),
                cast_time = cast_time:number(),
                recast = recast:number(),
                alias = S(alias:split('|')),
            }, resource_entry_mt)
            last = res[index]
        end
    end
    slots[res] = table.keyset(last)

    return res
end

-- Returns the buffs, indexed by ingame ID.
function fns.buffs()
    local file = _libs.files.read(plugin_resources..'status.xml')
    local match_string = '<b id="(%d-)" duration="(%d-)" fr="([^"]-)" de="([^"]-)" jp="([^"]-)" enLog="([^"]-)">([^<]-)</b>'
    local last = {}

    local res = {}

    for id, duration, fr, de, jp, en_log, en in file:gmatch(match_string) do
        id = id:number()
        res[id] = setmetatable({
            id = id,
            english = unquote(en),
            french = unquote(fr),
            german = unquote(de),
            japanese = unquote(jp),
            english_log = english_log,
            duration = duration:number(),
        }, resource_entry_mt)
        last = res[id]
    end
    slots[res] = table.keyset(last)

    return res
end

-- Returns the items, indexed by ingame ID.
function fns.items()
    local file
    local last = {}
    local match_string

    local res = {}
    slots[res] = S{'log_name'}

    -- General items
    file = _libs.files.read(plugin_resources..'items_general.xml')
    match_string = '<i id="(%d-)" enl="([^"]-)" fr="([^"]-)" frl="([^"]-)" de="([^"]-)" del="([^"]-)" jp="([^"]-)" jpl="([^"]-)" targets="([%a,%s]-)">([^<]-)</i>'
    for id, enl, fr, frl, de, del, jp, jpl, targets, en in file:gmatch(match_string) do
        id = id:number()
        res[id] = setmetatable({
            id = id,
            english = unquote(en),
            log_english = unquote(enl),
            french = unquote(fr),
            log_french = unquote(frl),
            german = unquote(de),
            log_german = unquote(del),
            japanese = unquote(jp),
            log_japanese = unquote(jpl),
            targets = S(targets:split()):remove('None'),
            cast_time = 0,
            category = 'General',
        }, resource_entry_mt)
        last = res[id]
    end
    slots[res] = slots[res] + table.keyset(last)

    match_string = '<i id="(%d-)" enl="([^"]-)" fr="([^"]-)" frl="([^"]-)" de="([^"]-)" del="([^"]-)" jp="([^"]-)" jpl="([^"]-)" targets="([%a,%s]-)" casttime="([%d%.]-)">([^<]-)</i>'
    for id, enl, fr, frl, de, del, jp, jpl, targets, cast_time, en in file:gmatch(match_string) do
        id = id:number()
        res[id] = setmetatable({
            id = id,
            english = unquote(en),
            log_english = unquote(enl),
            french = unquote(fr),
            log_french = unquote(frl),
            german = unquote(de),
            log_german = unquote(del),
            japanese = unquote(jp),
            log_japanese = unquote(jpl),
            targets = S(targets:split()):remove('None'),
            cast_time = cast_time:number(),
            category = 'General',
        }, resource_entry_mt)
        last = res[id]
    end
    slots[res] = slots[res] + table.keyset(last)
    
    match_string = '<i id="(%d-)" enl="([^"]-)" fr="([^"]-)" frl="([^"]-)" de="([^"]-)" del="([^"]-)" jp="([^"]-)" jpl="([^"]-)">([^<]-)</i>'
    for id, enl, fr, frl, de, del, jp, jpl, en in file:gmatch(match_string) do
        id = id:number()
        res[id] = setmetatable({
            id = id,
            english = unquote(en),
            log_english = unquote(enl),
            french = unquote(fr),
            log_french = unquote(frl),
            german = unquote(de),
            log_german = unquote(del),
            japanese = unquote(jp),
            log_japanese = unquote(jpl),
            category = 'General',
        }, resource_entry_mt)
        last = res[id]
    end
    slots[res] = slots[res] + table.keyset(last)

    -- Armor and weapons
    local categories = S{'armor', 'weapons'}
    for category in categories:it() do
        file = _libs.files.read(plugin_resources..'items_'..category..'.xml')
        match_string = '<i id="(%d-)" enl="([^"]-)" fr="([^"]-)" frl="([^"]-)" de="([^"]-)" del="([^"]-)" jp="([^"]-)" jpl="([^"]-)" slots="([^"]-)" jobs="([^"]-)" races="([^"]-)" level="(%d-)" targets="([%a,%s]-)" casttime="([%d%.]-)" recast="(%d-)">([^<]-)</i>'
        category = category:capitalize()
        for id, enl, fr, frl, de, del, jp, jpl, slots, jobs, races, level, targets, cast_time, recast, en in file:gmatch(match_string) do
            id = id:number()
            res[id] = setmetatable({
                id = id,
                english = unquote(en),
                log_english = unquote(enl),
                french = unquote(fr),
                log_french = unquote(frl),
                german = unquote(de),
                log_german = unquote(del),
                japanese = unquote(jp),
                log_japanese = unquote(jpl),
                slots = resources.convert(slots:number(16)),
                jobs = resources.convert(jobs:number(16)),
                races = resources.convert(races:number(16)),
                level = level:number(),
                targets = S(targets:split()):remove('None'),
                cast_time = cast_time:number(),
                recast = recast:number(),
                category = category,
            }, resource_entry_mt)
            last = res[id]
        end
    end
    slots[res] = slots[res] + table.keyset(last)

    return res
end

-- Returns the zones, indexed by ingame ID.
function fns.zones()
    local file = _libs.files.read(plugin_resources..'areas.xml')
    local match_string = '<a id="(%d-)" fr="([^"]-)" de="([^"]-)" jp="([^"]-)">([^<]-)</a>'
    local last = {}

    local res = {}

    for id, fr, de, jp, en in file:gmatch(match_string) do
        id = id:number()
        res[id] = setmetatable({
            id = id,
            english = en,
            french = fr,
            german = de,
            japanese = jp,
        }, resource_entry_mt)
        last = res[id]
    end
    slots[res] = table.keyset(last)

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
