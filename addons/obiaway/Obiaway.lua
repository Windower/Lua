-- 
-- Obiaway v0.1
-- 
-- Copyright (c) 2013, ReaperX
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
-- * Redistributions of source code must retain the above copyright
--   notice, this list of conditions and the following disclaimer.
-- * Redistributions in binary form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
-- * Neither the name of Obiaway nor the
-- names of its contributors may be used to endorse or promote products
-- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL ReaperX BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-- Puts elemental obis away when they are no longer needed due
-- to day/weather/storm effect change. Uses itemizer.
-- Intended to be used in conjunection with spellcast xml that
-- moves needed obis from sack to inventory just in time. 
-- 
-- The advantage of this system compared to moving obis back during 
-- aftercast is that it avoids excessive inventory movement,
-- so malfunctions due to inventory filling up completely are
-- less likely, and timing issues with very fast spells (spell
-- fires before obi is moved) occur at worst on the first spell
-- not but subsequent ones.
-- Known bugs: 
-- 1. upon activation, it puts only the first unneeded
-- obi away. The function remove_unneeded_obis() tries to put all
-- of them away, but the calls to itemizer are all made instantly
-- so only the first one is carried out. Usually, only one obi
-- has to be removed per call, so this is not much of a problem.
-- 2. when weather changes due to zoning, get_obis_in_inventory()
-- is called before inventory has loaded and returns nothing. 
--
-- 3. Obi is not moved when currently equipped.
-- 
-- To Do: add function to turn the console_echo's on/off. 

_addon.author = "ReaperX"
_addon.version = "1.0"
_addon.command = "obiaway"

require('sets')
config = require('config')
res = require('resources')

defaults = {}
defaults.location = 'sack'

settings = config.load(defaults)

windower.register_event('addon command',function (...)
    if args[1] == 'location' then
        if S{'sack','case','satchel'}:contains(args[2]:lower()) then
            settings.location = args[2]
        else
            print('Location can only be sack, satchel or case.')
        end
    else
        remove_unneeded_obis()
    end
end)

windower.register_event('lose buff', remove_unneeded_obis:cond(function(id) return id >= 178 and id <= 185 end))

windower.register_event('day change', 'weather change', remove_unneeded_obis)

function get_obis_in_inventory()
    obis = {}
    items = windower.ffxi.get_items()
    inv = items.inventory
    number = items.max_inventory - 1 -- items.max_inventory returns inventory size +1
    for i=1,number do 
        index = tostring(i)
        id = inv[index].id
        if ( id>=15435 and id<=15442) then
            obis["Fire"] = obis["Fire"] or (id == 15435)
            obis["Ice"] = obis["Ice"] or (id == 15436)
            obis["Wind"] = obis["Wind"] or (id == 15437)
            obis["Earth"] = obis["Earth"] or (id == 15438)
            obis["Thunder"] = obis["Thunder"] or (id == 15439)
            obis["Water"] = obis["Water"] or (id == 15440)
            obis["Light"] = obis["Light"] or (id == 15441)
            obis["Dark"] = obis["Dark"] or (id == 15442)
        end
    end
    return obis
end

function remove_unneeded_obis()
    elements = get_all_elements()
    obis = get_obis_in_inventory()
    local str = ''
    if obis["Fire"] and elements["Fire"]==0 then
        str = str.."input /put \"Karin Obi\" "..settings.location..";wait .5;"
    end
    if obis["Earth"] and elements["Earth"]==0 then
        str = str.."input /put \"Dorin Obi\" "..settings.location..";wait .5;"
    end
    if obis["Water"] and elements["Water"]==0 then
        str = str.."input /put \"Suirin Obi\" "..settings.location..";wait .5;"
    end
    if obis["Wind"] and elements["Wind"]==0 then
        str = str.."input /put \"Furin Obi\" "..settings.location..";wait .5;"
    end
    if obis["Ice"] and elements["Ice"]==0 then
        str = str.."input /put \"Hyorin Obi\" "..settings.location..";wait .5;"
    end
    if obis["Thunder"] and elements["Thunder"]==0 then
        str = str.."input /put \"Rairin Obi\" "..settings.location..";wait .5;"
    end
    if obis["Light"] and elements["Light"]==0 then    
        str = str.."input /put \"Korin Obi\" "..settings.location..";wait .5;"
    end
    if obis["Dark"] and elements["Dark"]==0 then    
        str = str.."input /put \"Anrin Obi\" "..settings.location
    end
    windower.send_command(str)
    print('Putting unneeded obis away in '..settings.location..'.')
end

function inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end

function get_all_elements()

    elements = {}           
    elements["Fire"] = 0
    elements["Earth"] = 0
    elements["Water"] = 0
    elements["Wind"] = 0
    elements["Ice"] = 0
    elements["Thunder"] = 0
    elements["Light"] = 0
    elements["Dark"] = 0
    elements["None"] = 0

    info = windower.ffxi.get_info()

    local day_element = res.elements[res.days[info.day].element].english
    elements[day_element] = elements[day_element] + 1
    local weather_element = res.elements[res.weathers[info.weather].element].english
    elements[weather_element] = elements[weather_element] + 1
    buffs = windower.ffxi.get_player().buffs

    if inTable(buffs, 178) then
      elements["Fire"] = elements["Fire"] +1
    elseif inTable(buffs, 183) then
      elements["Water"] = elements["Water"] +1
    elseif inTable(buffs, 181) then
      elements["Earth"] = elements["Earth"] +1
    elseif inTable(buffs, 180) then
      elements["Wind"] = elements["Wind"] +1
    elseif inTable(buffs, 179) then
      elements["Ice"] = elements["Ice"] +1
    elseif inTable(buffs, 182) then
      elements["Thunder"] = elements["Thunder"] +1
    elseif inTable(buffs, 184) then
      elements["Light"] = elements["Light"] +1
    elseif inTable(buffs, 185) then
      elements["Dark"] = elements["Dark"] +1
    end
    return elements
end
