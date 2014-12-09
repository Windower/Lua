-- 
-- Obiaway v1.0.2
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
-- to day/weather/storm effect change and gets elemental obi based
-- on same conditions. Uses itemizer addon.
-- 
-- The advantage of this system compared to moving obis back during 
-- aftercast is that it avoids excessive inventory movement,
-- so malfunctions due to inventory filling up completely are
-- less likely, and timing issues with very fast spells (spell
-- fires before obi is moved) occur at worst on the first spell
-- not but subsequent ones.
--
-- Known bugs: 
--
-- 1. upon activation, it puts only the first unneeded
-- obi away. The function get_needed_obis() tries to put all
-- of them away, but the calls to itemizer are all made instantly
-- so only the first one is carried out. Usually, only one obi
-- has to be removed per call, so this is not much of a problem.
--
-- 2. when weather changes due to zoning, get_obis_in_inventory()
-- is called before inventory has loaded and returns nothing.
--
-- 3. Obi is not moved when currently equipped.
-- 
-- To Do: Use a loop to remove and retrieve obi for shorter code

_addon.name = "Obiaway"
_addon.author = "ReaperX, onetime"
_addon.version = "1.0.2"
_addon.commands = {'obi', 'obiaway'}

require('sets')
require('logger')
config = require('config')
res = require('resources')

default_settings = {}
default_settings.notify = 'on'
default_settings.location = 'sack'

settings = config.load(default_settings)

-- Accepts msg as a string or a table
function obi_output(msg)
    windower.add_to_chat(209, msg)
end

windower.register_event('addon command', function()

    return function(command, ...)
        command = command:lower() or 'help'
        local params = {...}

        if command == 'help' or command == 'h' then
            obi_output("Obiaway v".._addon.version..". Authors: ".._addon.author)
            obi_output("//(obi)away [options]")
            obi_output("   (h)elp :  Displays this help text.")
            obi_output("   (g)et :  Command for manually getting and removing obis.")
            obi_output("   (n)otify [on|off] :  Sets obiaway notifcations on or off.")
            obi_output("   (l)ocation [sack|satchel|case|wardrobe] :  Sets inventory from which to get and put obis.")
        elseif command == 'get' or command == 'g' then
            get_needed_obis()
            obi_output("Sorting obis...")
        elseif command == 'notify' or command == 'n' then
            if S{'on'}:contains(params[1]:lower()) then
                settings.notify = params[1]
                obi_output("Obiaway notifications are now on")
            elseif S{'off'}:contains(params[1]:lower()) then
                settings.notify = params[1]
                obi_output("Obiaway notifications are now off.")
            else
                error("Invalid argument. Usage: //obiaway [on|off]")
            end
        elseif command == 'location' or command == 'l' then
            if S{'sack','case','satchel','wardrobe'}:contains(params[1]:lower()) then
                settings.location = params[1]
                obi_output("Obiaway location set to: "..settings.location)
            else
                error("Invalid argument. Usage: //obiaway location [sack|satchel|case|wardrobe]")
            end
        else
            error("Unrecognized command. See //obiaway help.")
        end
    end
end())

function get_obis_in_inventory()
    obis = {}
    items = windower.ffxi.get_items()
    inv = items.inventory
    if not inv then return end
    number = items.max_inventory
    for i=1,number do
        id = inv[i].id
        if ( id>=15435 and id<=15442) then
            obis["Fire"] = obis["Fire"] or (id == 15435)
            obis["Ice"] = obis["Ice"] or (id == 15436)
            obis["Wind"] = obis["Wind"] or (id == 15437)
            obis["Earth"] = obis["Earth"] or (id == 15438)
            obis["Lightning"] = obis["Lightning"] or (id == 15439)
            obis["Water"] = obis["Water"] or (id == 15440)
            obis["Light"] = obis["Light"] or (id == 15441)
            obis["Dark"] = obis["Dark"] or (id == 15442)
        end
    end
    return obis
end

function get_needed_obis()
    elements = get_all_elements()
    obis = get_obis_in_inventory()
    
    areas = {}
    areas.Cities = S{
        "Ru'Lude Gardens",
        "Upper Jeuno",
        "Lower Jeuno",
        "Port Jeuno",
        "Port Windurst",
        "Windurst Waters",
        "Windurst Woods",
        "Windurst Walls",
        "Heavens Tower",
        "Port San d'Oria",
        "Northern San d'Oria",
        "Southern San d'Oria",
        "Port Bastok",
        "Bastok Markets",
        "Bastok Mines",
        "Metalworks",
        "Aht Urhgan Whitegate",
        "Tavanazian Safehold",
        "Nashmau",
        "Selbina",
        "Mhaura",
        "Norg",
        "Kazham",
        "Eastern Adoulin",
        "Western Adoulin",
        "Leafallia",
        "Celennia Memorial Library",
        "Mog Garden"
    }
    
    local str = ''
    if not areas.Cities:contains(res.zones[windower.ffxi.get_info().zone].english) then
        if obis["Fire"] and elements["Fire"] == 0 then
            str = str.."put \"Karin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Karin Obi away in "..settings.location..".")
            end
        end
        if obis["Earth"] and elements["Earth"] == 0 then
            str = str.."put \"Dorin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Dorin Obi away in "..settings.location..".")
            end
        end
        if obis["Water"] and elements["Water"] == 0 then
            str = str.."put \"Suirin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Suirin Obi away in "..settings.location..".")
            end
        end
        if obis["Wind"] and elements["Wind"] == 0 then
            str = str.."put \"Furin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Furin Obi away in "..settings.location..".")
            end
        end
        if obis["Ice"] and elements["Ice"] == 0 then
            str = str.."put \"Hyorin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Hyorin Obi away in "..settings.location..".")
            end
        end
        if obis["Lightning"] and elements["Lightning"] == 0 then
            str = str.."put \"Rairin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Rairin Obi away in "..settings.location..".")
            end
        end
        if obis["Light"] and elements["Light"] == 0 then    
            str = str.."put \"Korin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Korin Obi away in "..settings.location..".")
            end
        end
        if obis["Dark"] and elements["Dark"] == 0 then    
            str = str.."put \"Anrin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Anrin Obi away in "..settings.location..".")
            end
        end
        if not obis["Fire"] and elements["Fire"] > 0 then
            str = str.."get \"Karin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Getting Karin Obi from "..settings.location..".")
            end
        end
        if not obis["Earth"] and elements["Earth"] > 0 then
            str = str.."get \"Dorin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Getting Dorin Obi from "..settings.location..".")
            end
        end
        if not obis["Water"] and elements["Water"] > 0 then
            str = str.."get \"Suirin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Getting Suirin Obi from "..settings.location..".")
            end
        end
        if not obis["Wind"] and elements["Wind"] > 0 then
            str = str.."get \"Furin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Getting Furin Obi from "..settings.location..".")
            end
        end
        if not obis["Ice"] and elements["Ice"] > 0 then
            str = str.."get \"Hyorin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Getting Hyorin Obi from "..settings.location..".")
            end
        end
        if not obis["Lightning"] and elements["Lightning"] > 0 then
            str = str.."get \"Rairin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Getting Rairin Obi from "..settings.location..".")
            end
        end
        if not obis["Light"] and elements["Light"] > 0 then    
            str = str.."get \"Korin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Getting Korin Obi from "..settings.location..".")
            end
        end
        if not obis["Dark"] and elements["Dark"] > 0 then    
            str = str.."get \"Anrin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Getting Anrin Obi from "..settings.location..".")
            end
        end
        windower.send_command(str)
    else --in town: put away all obis.
        if obis["Fire"] then
            str = str.."put \"Karin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Karin Obi away in "..settings.location..".")
            end
        end
        if obis["Earth"] then
            str = str.."put \"Dorin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Dorin Obi away in "..settings.location..".")
            end
        end
        if obis["Water"] then
            str = str.."put \"Suirin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Suirin Obi away in "..settings.location..".")
            end
        end
        if obis["Wind"] then
            str = str.."put \"Furin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Furin Obi away in "..settings.location..".")
            end
        end
        if obis["Ice"] then
            str = str.."put \"Hyorin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Hyorin Obi away in "..settings.location..".")
            end
        end
        if obis["Lightning"] then
            str = str.."put \"Rairin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Rairin Obi away in "..settings.location..".")
            end
        end
        if obis["Light"] then    
            str = str.."put \"Korin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Korin Obi away in "..settings.location..".")
            end
        end
        if obis["Dark"] then    
            str = str.."put \"Anrin Obi\" "..settings.location..";wait .5;"
            if settings.notify == 'on' then
                obi_output("Putting Anrin Obi away in "..settings.location..".")
            end
        end
        windower.send_command(str)
    end
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
    elements["Lightning"] = 0
    elements["Light"] = 0
    elements["Dark"] = 0
    elements["None"] = 0

    info = windower.ffxi.get_info()

    local day_element = res.elements[res.days[info.day].element].english
    elements[day_element] = elements[day_element] + 1
    local weather_element = res.elements[res.weather[info.weather].element].english
    elements[weather_element] = elements[weather_element] + 1
    buffs = windower.ffxi.get_player().buffs

    if inTable(buffs, 178) then
      elements["Fire"] = elements["Fire"] + 1
    elseif inTable(buffs, 183) then
      elements["Water"] = elements["Water"] + 1
    elseif inTable(buffs, 181) then
      elements["Earth"] = elements["Earth"] + 1
    elseif inTable(buffs, 180) then
      elements["Wind"] = elements["Wind"] + 1
    elseif inTable(buffs, 179) then
      elements["Ice"] = elements["Ice"] + 1
    elseif inTable(buffs, 182) then
      elements["Lightning"] = elements["Lightning"] + 1
    elseif inTable(buffs, 184) then
      elements["Light"] = elements["Light"] + 1
    elseif inTable(buffs, 185) then
      elements["Dark"] = elements["Dark"] + 1
    end
    return elements
end

windower.register_event('gain buff', get_needed_obis:cond(function(id) return id >= 178 and id <= 185 end))
windower.register_event('lose buff', get_needed_obis:cond(function(id) return id >= 178 and id <= 185 end))
windower.register_event('day change', 'weather change', get_needed_obis)
