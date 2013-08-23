--[[
A library to handle ingame resources, as provided by the Radsources XMLs. It will look for the files in Windower/plugins/resources.
]]

_libs = _libs or {}
_libs.resources = true
_libs.tablehelper = _libs.tablehelper or require('tablehelper')
_libs.stringhelper = _libs.stringhelper or require('stringhelper')
_libs.logger = _libs.logger or require('logger')
_libs.filehelper = _libs.filehelper or require('filehelper')
_libs.xml = _libs.xml or require('xml')

local resources = T{}
local abils = T{}
local spells = T{}
local items = T{}
local status = T{}
local zones = T{}
local plugin_resources = '../../plugins/resources/'
local addon_resources = '../libs/resources/'

local unquotes = {
    ['quot'] = '"',
    ['amp'] = '&',
    ['gt'] = '>',
    ['lt'] = '<',
    ['apos'] = '\'',
}

local jobs = L{
    'WAR',
    'MNK',
    'WHM',
    'BLM',
    'RDM',
    'THF',
    'PLD',
    'DRK',
    'BST',
    'BRD',
    'RNG',
    'SAM',
    'NIN',
    'DRG',
    'SMN',
    'BLU',
    'COR',
    'PUP',
    'DNC',
    'SCH',
    'GEO',
    'RUN',
}

local male = string.char(0x81, 0x89)
local female = string.char(0x81, 0x8A)
local race_table = {
    [2^1] = 'Hume '..male,
    [2^2] = 'Hume '..female,
    [2^3] = 'Elvaan '..male,
    [2^4] = 'Elvaan '..female,
    [2^5] = 'Tarutaru '..male,
    [2^6] = 'Tarutaru '..female,
    [2^7] = 'Mithra',
    [2^8] = 'Galka',

    -- Compound values
    [2^1 + 2^3 + 2^5 + 2^8] = male,
    [2^2 + 2^4 + 2^6 + 2^7] = female,
    [2^1 + 2^2] = 'Hume',
    [2^3 + 2^4] = 'Elvaan',
    [2^5 + 2^6] = 'Tarutaru',
    [2^9 - 1] = 'All races',
}

local parse_jobs = function(num)
    local res = L{}

    local count = 0
    local mod
    while num > 0 do
        count = count + 1
        num, mod = math.modf(num/2)
        if mod ~= 0 then
            res:append(jobs[count])
        end
    end

    return res
end

local unquote = function(str)
    return (str:gsub('&(.-);', unquotes))
end

--[[
    Local functions.
]]

local make_atom

-- Returns the abilities, indexed by ingame ID.
function resources.abils()
    if not abils:empty() then
        return abils
    end

    local file = _libs.filehelper.read(plugin_resources..'spells.xml')
    local match_string = '<a id="(%d-)" index="(%d-)" prefix="([^"]-)" english="([^"]-)" german="([^"]-)" french="([^"]-)" japanese="([^"]-)" type="([^"]-)" element="([^"]-)" targets="([^"]-)" skill="([^"]-)" mpcost="(%-?%d-)" tpcost="(%d-)" casttime="(%d-)" recast="(%d-)" alias="([^"]-)" />'
    for id, index, english, german, french, japanese, type, element, targets, skill, mpcost, tpcost, casttime, recast, alias in file:gmatch(match_string) do
        abils[id] = {
            id = tonumber(id),
            index = tonumber(index),
            english = english,
            german = german,
            french = french,
            japanese = japanese,
            type = type,
            element = element,
            targets = targets:split(', '),
            skill = skill,
            mpcost = tonumber(mpcost),
            tpcost = tonumber(tpcost),
            casttime = tonumber(casttime),
            recast = tonumber(recast),
            alias = alias,
        }
    end

    return abils
end

-- Returns the spells, indexed by ingame ID.
function resources.spells()
    if not spells:empty() then
        return spells
    end

    local file = _libs.filehelper.read(plugin_resources..'spells.xml')
    local match_string = '<s id="(%d-)" index="(%d-)" prefix="([^"]-)" english="([^"]-)" german="([^"]-)" french="([^"]-)" japanese="([^"]-)" type="([^"]-)" element="([^"]-)" targets="([^"]-)" skill="([^"]-)" mpcost="(%d-)" casttime="(%d-)" recast="(%d-)" alias="([^"]-)" />'
    for id, index, english, german, french, japanese, type, element, targets, skill, mpcost, casttime, recast, alias in file:gmatch(match_string) do
        spells[index] = {
            id = tonumber(id),
            index = tonumber(index),
            english = english,
            german = german,
            french = french,
            japanese = japanese,
            type = type,
            element = element,
            targets = targets:split(', '),
            skill = skill,
            mpcost = tonumber(mpcost),
            casttime = tonumber(casttime),
            recast = tonumber(recast),
            alias = alias,
        }
    end

    return spells
end

-- Returns the statuses, indexed by ingame ID.
function resources.status()
    if not status:empty() then
        return status
    end

    local file = _libs.filehelper.read(plugin_resources..'status.xml')
    local match_string = '<b id="(%d-)" duration="(%d-)" fr="([^"]-)" de="([^"]-)" jp="([^"]-)">([^<]-)</b>'
    for id, duration, fr, de, jp, en in file:gmatch(match_string) do
        status[id] = {
            id = tonumber(id),
            en = en,
            duration = tonumber(duration),
            fr = fr,
            de = de,
            jp = jp,
        }
    end

    return status
end

-- Returns the items, indexed by ingame ID.
function resources.items()
    if not items:empty() then
        return items
    end

    -- General items
    local file = _libs.filehelper.read(plugin_resources..'items_general.xml')
    local match_string = '<i id="(%d-)" enl="([^"]-)" fr="([^"]-)" frl="([^"]-)" de="([^"]-)" del="([^"]-)" jp="([^"]-)" jpl="([^"]-)">([^<]-)</i>'
    for id, enl, fr, frl, de, del, jp, jpl, en in file:gmatch(match_string) do
        items[id] = {
            id = tonumber(id),
            en = unquote(en),
            enl = unquote(enl),
            fr = unquote(fr),
            frl = unquote(frl),
            de = unquote(de),
            del = unquote(del),
            jp = unquote(jp),
            jpl = unquote(jpl),
        }
    end

    -- Armor and weapons
    local categories = S{'armor', 'weapons'}
    for category in categories:it() do
        local file = _libs.filehelper.read(plugin_resources..'items_'..category..'.xml')
        local match_string = '<i id="(%d-)" enl="([^"]-)" fr="([^"]-)" frl="([^"]-)" de="([^"]-)" del="([^"]-)" jp="([^"]-)" jpl="([^"]-)" jobs="([^"]-)" races="([^"]-)" level="([^"]-)">([^<]-)</i>'
        for id, enl, fr, frl, de, del, jp, jpl, en, jobs, races, level in file:gmatch(match_string) do
            items[id] = {
                id = tonumber(id),
                en = unquote(en),
                enl = unquote(enl),
                fr = unquote(fr),
                frl = unquote(frl),
                de = unquote(de),
                del = unquote(del),
                jp = unquote(jp),
                jpl = unquote(jpl),
                jobs = parse_jobs(tonumber(jobs, 16)),
                races = race_table[tonumber(races, 16)],
                level = tonumber(level),
            }
        end
    end

    return items
end

-- Returns the zones, indexed by ingame ID.
function resources.zones()
    if not zones:empty() then
        return zones
    end

    local file = _libs.filehelper.read(plugin_resources..'areas.xml')
    local match_string = '<a id="(%d-)" fr="([^"]-)" de="([^"]-)" jp="([^"]-)">([^<]-)</a>'
    for id, fr, de, jp, en in file:gmatch(match_string) do
        zones[id] = {
            id = tonumber(id),
            en = en,
            fr = fr,
            de = de,
            jp = jp,
        }
    end

    return zones
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
