-- 
-- Obiaway v1.0.3
-- 
-- Copyright ©2013-2014, ReaperX, onetime
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
-- Puts elemental obi away when they are no longer needed due
-- to day/weather/storm effect change and gets elemental obi based
-- on same conditions. Uses itemizer addon.
-- 
-- The advantage of this system compared to moving obi back during 
-- aftercast is that it avoids excessive inventory movement,
-- so malfunctions due to inventory filling up completely are
-- less likely, and timing issues with very fast spells (spell
-- fires before obi is moved) occur at worst on the first spell
-- not but subsequent ones.
--
-- Known bugs: 
--
-- 1. Using the get, put, or sort commands too quickly can have
-- undesirable effects, often leaving obi behind or failing to get
-- an obi. This is due to limitations on how fast items can be moved
-- from one inventory to another.
--
-- 2. When weather changes due to zoning, get_obi_in_inventory()
-- is called before inventory has loaded and returns nothing.
--
-- 3. Obi is not moved when currently equipped.
--
-- To-do: Rework get_obi_in_inventory() to only pull data from
-- the inventory and location specified in settings.location.
-- Add inventory count checking for settings.location.

_addon.name = "Obiaway"
_addon.author = "ReaperX, onetime"
_addon.version = "1.0.3"
_addon.commands = {'ob', 'obi', 'obiaway'}

require('sets')
require('logger')
config = require('config')
res = require('resources')

default_settings = {}
default_settings.notify = true
default_settings.location = 'sack'
default_settings.lock = false

settings = config.load(default_settings)

lockwarned = false

-- Accepts msg as a string or a table
function obi_output(msg)
    prefix = 'Obi: '
    windower.add_to_chat(209, prefix..msg)
end

-- Accepts a boolean value and returns an appropriate string value. i.e. true -> 'on'
function booltostr(bool)
    local str = ''
    if bool then
        str = 'on'
        return str
    elseif not bool then
        str = 'off'
        return str
    else
        print('Boolean to string: unknown error.')
    end
end

windower.register_event('addon command', function(command, ...)
    local command = command:lower() or 'help'
    local params = L{...}:map(string.lower)
    
    
    if command == 'help' or command == 'h' then
        obi_output("Obiaway v".._addon.version..". Authors: ".._addon.author)
        obi_output("//(ob)iaway [options]")
        obi_output("   (h)elp :  Displays this help text.")
        obi_output("   settings :  Displays current settings.")
        obi_output("   (s)ort :  Automatically sorts obi.")
        obi_output("   (g)et [ (a)ll | (n)eeded ] :  Gets obi.")
        obi_output("   (p)ut [ (a)ll | u(n)needed ] :  Puts obi.")
        obi_output("    lock:  Locks obi.")
        obi_output("    unlock:  Unocks obi.")
        obi_output("   (n)otify [ on | off ] :  Sets obiaway notifcations on or off.")
        obi_output("   (l)ocation [ sack | satchel | case | wardrobe ] :  Sets inventory from which to get and put obi.")
    elseif command == 'settings' or command == 'setting' then
        obi_output("Obiaway settings:")
        obi_output("    location:  %s":format(settings.location))
        obi_output("    notifications:  %s":format(booltostr(settings.notify)))
        obi_output("    lock:  %s":format(booltostr(settings.lock)))
    elseif command == 'sort' or command == 's' then
        if not settings.lock then
            obi_output("Sorting obi...")
        end
        auto_sort_obi()
    elseif command == 'get' or command == 'g' then
        if params[1] == 'all' or params [1] == 'a' then
            obi_output('Getting all obi from %s...':format(settings.location))
            get_all_obi(true)
        elseif params[1] == 'needed' or params [1] == 'n' then
            obi_output('Getting needed obi from %s...':format(settings.location))
            get_needed_obi(true)
        else
            error("Invalid argument. Usage: //obiaway get [ all | needed ]")
        end
    elseif command == 'put' or command == 'p' then
        if params[1] == 'all' or params [1] == 'a' then
            obi_output('Putting all obi into %s...':format(settings.location))
            put_all_obi(true)
        elseif params[1] == 'unneeded' or params[1] == 'needed' or params [1] == 'n' then
            obi_output('Putting unneeded obi into %s...':format(settings.location))
            put_unneeded_obi(true)
        else
            error("Invalid argument. Usage: //obiaway put [ all | needed ]")
        end
    elseif command == 'lock' or command == 'lo' then
        settings.lock = true
        lockwarned = true
        obi_output("Locking obi...")
    elseif command == 'unlock' or command == 'lo' then
        settings.lock = false
        lockwarned = false
        obi_output("Unlocking obi...")
    elseif command == 'notify' or command == 'n' then
        if params[1] == 'on' then
            settings.notify = true
            obi_output("Notifications are now on")
        elseif params[1] == 'off' then
            settings.notify = false
            obi_output("Notifications are now off.")
        else
            error("Invalid argument. Usage: //obiaway notify [ on | off ]")
        end
    elseif command == 'location' or command == 'l' then
        if S{'sack','case','satchel','wardrobe'}:contains(params[1]) then
            settings.location = params[1]
            obi_output("Obiaway location set to: %s":format(settings.location))
        else
            error("Invalid argument. Usage: //obiaway location [ sack | satchel | case | wardrobe ]")
        end
    else
        error("Unrecognized command. See //obiaway help.")
    end
end)

function get_obi_in_inventory()
    local obi = {}
    local items = windower.ffxi.get_items()
    if items.count_inventory == items.max_inventory then
        if not lockwarned then
            obi_output("Inventory is full..")
            lockwarned = true
        end
        return
    else
        lockwarned = false
    end
    local inv = items.inventory
    if not inv then return end
    local number = items.max_inventory

    for i=1,number do
        id = inv[i].id
        if ( id>=15435 and id<=15442) then
            obi["Fire"] = obi["Fire"] or (id == 15435)
            obi["Ice"] = obi["Ice"] or (id == 15436)
            obi["Wind"] = obi["Wind"] or (id == 15437)
            obi["Earth"] = obi["Earth"] or (id == 15438)
            obi["Lightning"] = obi["Lightning"] or (id == 15439)
            obi["Water"] = obi["Water"] or (id == 15440)
            obi["Light"] = obi["Light"] or (id == 15441)
            obi["Dark"] = obi["Dark"] or (id == 15442)
        end
    end

    return obi
end

function get_needed_obi(command)
    local elements = get_all_elements()
    local obi = get_obi_in_inventory()
    local str = ''
    local obi_names = T{
        Light = 'Korin',
        Dark = 'Anrin',
        Fire = 'Karin',
        Earth = 'Dorin',
        Water = 'Suirin',
        Wind = 'Furin',
        Ice = 'Hyorin',
        Lightning = 'Rairin'
    }
    for name, element in obi_names:it() do
        if not obi[element] and elements[element] > 0 then
            str = str..'get "%s Obi" %s;wait .5;':format(name, settings.location)
            if settings.notify then
                obi_output('Getting %s Obi from %s.':format(name, settings.location))
            end
        end
    end
    if command then
        windower.send_command(str)
    else
        return str
    end
end

function put_unneeded_obi(command)
    local elements = get_all_elements()
    local obi = get_obi_in_inventory()
    local str = ''
    local obi_names = T{
        Light = 'Korin',
        Dark = 'Anrin',
        Fire = 'Karin',
        Earth = 'Dorin',
        Water = 'Suirin',
        Wind = 'Furin',
        Ice = 'Hyorin',
        Lightning = 'Rairin'
    }

    for name, element in obi_names:it() do
        if obi[element] and elements[element] == 0 then    
            str = str..'put "%s Obi" %s;wait .5;':format(name, settings.location)
            if settings.notify then
                obi_output('Putting %s Obi away into %s.':format(name, settings.location))
            end
        end
    end
    if command then
        windower.send_command(str)
    else
        return str
    end
end

function get_all_obi(command)
    local elements = get_all_elements()
    local obi = get_obi_in_inventory()
    local str = ''
    local obi_names = T{
        Light = 'Korin',
        Dark = 'Anrin',
        Fire = 'Karin',
        Earth = 'Dorin',
        Water = 'Suirin',
        Wind = 'Furin',
        Ice = 'Hyorin',
        Lightning = 'Rairin'
    }
    for name, element in obi_names:it() do
        if not obi[element] then
            str = str..'get "%s Obi" %s;wait .5;':format(name, settings.location)
            if settings.notify then
                obi_output('Getting %s Obi from %s.':format(name, settings.location))
            end
        end
    end
    if command then
        windower.send_command(str)
        settings.lock = true
        lockwarned = true
        if settings.notify then
            obi_output('Locking obi...')
        end
    else
        return str
    end
end

function put_all_obi(command)
    local elements = get_all_elements()
    local obi = get_obi_in_inventory()
    local str = ''
    local obi_names = T{
        Light = 'Korin',
        Dark = 'Anrin',
        Fire = 'Karin',
        Earth = 'Dorin',
        Water = 'Suirin',
        Wind = 'Furin',
        Ice = 'Hyorin',
        Lightning = 'Rairin'
    }
    for name, element in obi_names:it() do
        if obi[element] then
            str = str..'put "%s Obi" %s;wait .5;':format(name, settings.location)
            if settings.notify then
                obi_output('Putting %s Obi away into %s.':format(name, settings.location))
            end
        end
    end
    if command then
        windower.send_command(str)
        settings.lock = true
        lockwarned = true
        if settings.notify then
            obi_output('Locking obi...')
        end
    else
        return str
    end
end

auto_sort_obi = function()
    local cities = S{
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
    return function()
        local str = ''
        if not settings.lock then
            if not cities:contains(res.zones[windower.ffxi.get_info().zone].english) then
                str = str..put_unneeded_obi(false)
                str = str..get_needed_obi(false)
                windower.send_command(str)
            else  -- in town. put away all obi.
                str = str..put_all_obi(false)
                windower.send_command(str)
            end
        elseif not lockwarned then
            obi_output("Locked.")
            lockwarned = true
        end
    end
end()

function inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end

function get_all_elements()
    local elements = {}           
    elements["Fire"] = 0
    elements["Earth"] = 0
    elements["Water"] = 0
    elements["Wind"] = 0
    elements["Ice"] = 0
    elements["Lightning"] = 0
    elements["Light"] = 0
    elements["Dark"] = 0
    elements["None"] = 0

    local info = windower.ffxi.get_info()

    local day_element = res.elements[res.days[info.day].element].english
    elements[day_element] = elements[day_element] + 1
    local weather_element = res.elements[res.weather[info.weather].element].english
    elements[weather_element] = elements[weather_element] + 1
    local buffs = windower.ffxi.get_player().buffs

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

windower.register_event('gain buff', auto_sort_obi:cond(function(id) return id >= 178 and id <= 185 end))
windower.register_event('lose buff', auto_sort_obi:cond(function(id) return id >= 178 and id <= 185 end))
windower.register_event('day change', 'weather change', auto_sort_obi)
