--[[
A library to handle ingame resources, as provided by the Radsources XMLs. It will look for the files in Windower/plugins/resources.
]]

_libs = _libs or {}
_libs.resources = true
_libs.tablehelper = _libs.tablehelper or require('tablehelper')
_libs.stringhelper = _libs.stringhelper or require('stringhelper')
_libs.filehelper = _libs.filehelper or require('filehelper')
_libs.xml = _libs.xml or require('xml')

local fns = {}

local resources = setmetatable({}, {__index = function(t, k)
    if fns[k] then
        fns[k]()
        return t[k]
    end
end})

local plugin_resources = '../../plugins/resources/'
local addon_resources = 'resources/'

local language_string = _addon and _addon.language and _addon.language:lower() or windower.get_ffxi_info().language:lower()
local language_string_full = language_string..'_full'

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

local function add_name(t)
    t.name = t[language_string]
    return t
end

-- Returns the jobs, indexed by ingame ID.
function fns.jobs()
    resources.jobs = T(require(addon_resources..'jobs')):map(add_name)
end

-- Returns the races, indexed by ingame ID.
function fns.races()
    resources.races = T(require(addon_resources..'races')):map(add_name)
end

-- Returns the weather, indexed by ingame ID.
function fns.weather()
    resources.weather = T(require(addon_resources..'weather')):map(add_name)
end

-- Returns the servers, indexed by ingame ID.
function fns.servers()
    resources.servers = T(require(addon_resources..'servers')):map(add_name)
end

-- Returns the chat, indexed by ingame ID.
function fns.chat()
    resources.chat = T(require(addon_resources..'chat')):map(add_name)
end

-- Returns the bags, indexed by ingame ID.
function fns.bags()
    resources.bags = T(require(addon_resources..'bags')):map(add_name)
end

-- Returns the emotes, indexed by ingame ID.
function fns.emotes()
    resources.emotes = T(require(addon_resources..'emotes')):map(add_name)
end

-- Returns the skills, indexed by ingame ID.
function fns.skills()
    resources.skills = T(require(addon_resources..'skills')):map(add_name)
end

-- Returns the titles, indexed by ingame ID.
function fns.titles()
    resources.titles = T(require(addon_resources..'titles')):map(add_name)
end

-- Returns the abilities, indexed by ingame ID.
function fns.abilities()
    local file = _libs.filehelper.read(plugin_resources..'abils.xml')
    local match_string = '<a id="(%d-)" index="(%d-)" prefix="([^"]-)" english="([^"]-)" german="([^"]-)" french="([^"]-)" japanese="([^"]-)" type="([^"]-)" element="([^"]-)" targets="([^"]-)" skill="([^"]-)" mpcost="(%-?%d-)" tpcost="(%d-)" casttime="(%d-)" recast="(%d-)" alias="([^"]-)" />'
    local res = T{}
    for id, index, english, german, french, japanese, type, element, targets, skill, mp_cost, tp_cost, cast_time, recast, alias in file:gmatch(match_string) do
        id = tonumber(id)
        res[id] = {
            id = id,
            index = tonumber(index),
            english = english,
            german = german,
            french = french,
            japanese = japanese,
            type = type,
            element = element,
            targets = targets:split(', '),
            skill = skill,
            mp_cost = tonumber(mp_cost),
            tp_cost = tonumber(tp_cost),
            cast_time = tonumber(cast_time),
            recast = tonumber(recast),
            alias = alias,
        }
        res[id].name = res[id][language_string]
    end

    resources.abilities = res
end

-- Returns the spells, indexed by ingame ID.
function fns.spells()
    local file = _libs.filehelper.read(plugin_resources..'spells.xml')
    local match_string = '<s id="(%d-)" index="(%d-)" prefix="([^"]-)" english="([^"]-)" german="([^"]-)" french="([^"]-)" japanese="([^"]-)" type="([^"]-)" element="([^"]-)" targets="([^"]-)" skill="([^"]-)" mpcost="(%d-)" casttime="(%d-)" recast="(%d-)" alias="([^"]-)" />'
    local res = T{}
    for id, index, english, german, french, japanese, type, element, targets, skill, mp_cost, cast_time, recast, alias in file:gmatch(match_string) do
        index = tonumber(index)
        res[index] = {
            id = tonumber(id),
            index = index,
            english = english,
            german = german,
            french = french,
            japanese = japanese,
            type = type,
            element = element,
            targets = targets:split(', '),
            skill = skill,
            mp_cost = tonumber(mp_cost),
            cast_time = tonumber(cast_time),
            recast = tonumber(recast),
            alias = alias,
        }
        res[index].name = res[index][language_string]
    end

    resources.spells = res
end

-- Returns the statuses, indexed by ingame ID.
function fns.statuses()
    local file = _libs.filehelper.read(plugin_resources..'status.xml')
    local match_string = '<b id="(%d-)" duration="(%d-)" fr="([^"]-)" de="([^"]-)" jp="([^"]-)">([^<]-)</b>'
    local res = T{}
    for id, duration, fr, de, jp, en in file:gmatch(match_string) do
        id = tonumber(id)
        res[id] = {
            id = id,
            english = en,
            duration = tonumber(duration),
            french = fr,
            german = de,
            japanese = jp,
        }
        res[id].name = res[id][language_string]
    end

    resources.statuses = res
end

-- Returns the items, indexed by ingame ID.
function fns.items()
    local function parse_jobs(num)
        local res = S{}

        local count = 0
        local mod
        while num > 0 do
            count = count + 1
            num, mod = math.modf(num/2)
            if mod ~= 0 then
                res:add(resources.jobs[count])
            end
        end

        return res
    end

    local match_string
    local file
    local res = T{}

    -- General items
    file = _libs.filehelper.read(plugin_resources..'items_general.xml')
    match_string = '<i id="(%d-)" enl="([^"]-)" fr="([^"]-)" frl="([^"]-)" de="([^"]-)" del="([^"]-)" jp="([^"]-)" jpl="([^"]-)">([^<]-)</i>'
    for id, enl, fr, frl, de, del, jp, jpl, en in file:gmatch(match_string) do
        id = tonumber(id)
        res[id] = {
            id = id,
            english = unquote(en),
            english_full = unquote(enl),
            french = unquote(fr),
            french_full = unquote(frl),
            german = unquote(de),
            german_full = unquote(del),
            japanese = unquote(jp),
            japanese_full = unquote(jpl),
            targets = 'None',
            cast_time = 0,
            category = 'General',
        }
        res[id].name = res[id][language_string]
        res[id].name_full = res[id][language_string_full]
    end

    match_string = '<i id="(%d-)" enl="([^"]-)" fr="([^"]-)" frl="([^"]-)" de="([^"]-)" del="([^"]-)" jp="([^"]-)" jpl="([^"]-)" targets="([^"]-)" casttime="(%d-)">([^<]-)</i>'
    for id, enl, fr, frl, de, del, jp, jpl, targets, cast_time, en in file:gmatch(match_string) do
        id = tonumber(id)
        res[id] = {
            id = id,
            english = unquote(en),
            english_full = unquote(enl),
            french = unquote(fr),
            french_full = unquote(frl),
            german = unquote(de),
            german_full = unquote(del),
            japanese = unquote(jp),
            japanese_full = unquote(jpl),
            targets = unquote(targets),
            cast_time = tonumber(cast_time),
            category = 'General',
        }
        res[id].name = res[id][language_string]
        res[id].name_full = res[id][language_string_full]
    end

    -- Armor and weapons
    local categories = S{'armor', 'weapons'}
    for category in categories:it() do
        file = _libs.filehelper.read(plugin_resources..'items_'..category..'.xml')
        match_string = '<i id="(%d-)" enl="([^"]-)" fr="([^"]-)" frl="([^"]-)" de="([^"]-)" del="([^"]-)" jp="([^"]-)" jpl="([^"]-)" jobs="([^"]-)" races="([^"]-)" level="(%d-)" targets="([^"]-)" casttime="(%d-)" recast="(%d-)">([^<]-)</i>'
        for id, enl, fr, frl, de, del, jp, jpl, jobs, races, level, targets, cast_time, recast, en in file:gmatch(match_string) do
            id = tonumber(id)
            res[id] = {
                id = id,
                english = unquote(en),
                english_full = unquote(enl),
                french = unquote(fr),
                french_full = unquote(frl),
                german = unquote(de),
                german_full = unquote(del),
                japanese = unquote(jp),
                japanese_full = unquote(jpl),
                jobs = parse_jobs(tonumber(jobs, 16)),
                races = race_table[tonumber(races, 16)],
                level = tonumber(level),
                targets = unquote(targets),
                cast_time = tonumber(cast_time),
                recast = tonumber(recast),
                category = category,
            }
            res[id].name = res[id][language_string]
            res[id].name_full = res[id][language_string_full]
        end
    end

    resources.items = res
end

-- Returns the zones, indexed by ingame ID.
function fns.zones()
    local file = _libs.filehelper.read(plugin_resources..'areas.xml')
    local match_string = '<a id="(%d-)" fr="([^"]-)" de="([^"]-)" jp="([^"]-)">([^<]-)</a>'
    local res = {}
    for id, fr, de, jp, en in file:gmatch(match_string) do
        id = tonumber(id)
        res[id] = {
            id = id,
            english = en,
            french = fr,
            german = de,
            japanese = jp,
        }
        res[id].name = res[id][language_string]
    end

    resources.zones = res
end

-- Returns monster abilities, indexed by ingame ID.
function fns.monster_abils()
    local file = _libs.filehelper.read(addon_resources..'mabils.xml')
    local match_string
    local res = T{}

    match_string = '<m id="(%d-)" english="([^"]-)" actor_status="([^"]-)" target_status="([^"]-)" />'
    for id, english, actor_status, target_status in file:gmatch(match_string) do
        id = tonumber(id)
        res[id] = {
            id = id,
            english = unquote(english),
            actor_status = S(actor_status:split(','):map(tonumber)),
            target_status = S(target_status:split(','):map(tonumber)),
        }
        res[id].name = res[id][language_string]
    end

    match_string = '<m id="(%d-)" english="([^"]-)" actor_status="([^"]-)" />'
    for id, english, actor_status in file:gmatch(match_string) do
        id = tonumber(id)
        res[id] = {
            id = id,
            english = unquote(english),
            actor_status = S(actor_status:split(','):map(tonumber)),
            target_status = S{},
        }
        res[id].name = res[id][language_string]
    end

    match_string = '<m id="(%d-)" english="([^"]-)" target_status="([^"]-)" />'
    for id, english, target_status in file:gmatch(match_string) do
        id = tonumber(id)
        res[id] = {
            id = id,
            english = unquote(english),
            actor_status = S{},
            target_status = S(target_status:split(','):map(tonumber)),
        }
        res[id].name = res[id][language_string]
    end

    match_string = '<m id="(%d-)" english="([^"]-)" />'
    for id, english in file:gmatch(match_string) do
        id = tonumber(id)
        res[id] = {
            id = id,
            english = unquote(english),
            actor_status = S{},
            target_status = S{},
        }
        res[id].name = res[id][language_string]
    end

    resources.monster_abils = res
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
