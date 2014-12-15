-- 
-- Obiaway v1.0.6
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
-- 4. Notification messages are not in sync with when items are actually
-- moved.
--
-- To-do:
--   - Add support for other languages.
--   - Time obiaway get and put messages to match up with when they are moved
--   - Add location option to put all command. Ex: put all satchel
--      Command should also change settings.location accordingly.
--
--

_addon.name = "Obiaway"
_addon.author = "ReaperX, onetime"
_addon.version = "1.0.6"
_addon.commands = {'oa', 'ob', 'obi', 'obiaway'}
_addon.language = 'english'

require('sets')
require('logger')
config = require('config')
res = require('resources')

-- settings
default_settings = {}
default_settings.notify = true
default_settings.location = 'sack'
default_settings.lock = false
settings = config.load(default_settings)

-- tokens
lock_warned = false
inv_full_warned = false

-- lists
cities = S{
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
    "Tavnazian Safehold",
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
        obi_output("//obiaway [options]")
        obi_output("   help :  Displays this help text.")
        obi_output("   sort :  Automatically sorts obi.")
        obi_output("   get [ all | needed ]")
        obi_output("       Gets obi from bag.")
        obi_output("   put [ all | unneeded ]")
        obi_output("       Puts obi away into.")
        obi_output("   lock [ on | off ]    (%s)":format(booltostr(settings.lock)))
        obi_output("       Locks obi to current location.")
        obi_output("   notify [ on | off ]    (%s)":format(booltostr(settings.notify)))
        obi_output("       Sets obiaway notifcations on or off.")
        obi_output("   location [ sack | satchel | case | wardrobe ]    (%s)":format(settings.location))
        obi_output("       Sets inventory from which to get and put obi.")
    elseif command == 'sort' or command == 's' then
        if settings.lock then lock_obi(false) end
        if settings.notify then
            obi_output('Sorting obi...')
        end
        auto_sort_obi(true)
    elseif command == 'get' or command == 'g' then
        if params[1] == 'all' or params [1] == 'a' then
            obi_output('Getting all obi from %s...':format(settings.location))
            get_all_obi(true)
            lock_obi(true)
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
            lock_obi(true)
        elseif params[1] == 'unneeded' or params[1] == 'needed' or params [1] == 'n' then
            obi_output('Putting unneeded obi into %s...':format(settings.location))
            put_unneeded_obi(true)
        else
            error("Invalid argument. Usage: //obiaway put [ all | needed ]")
        end
    elseif command == 'lock' or command == 'l' then
        if params[1] == 'on' then
            lock_obi(true)
        elseif params[1] == 'off' then
            lock_obi(false)
        else
            error("Invalid argument. Usage: //obiaway lock [ on | off ]")
        end
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
    elseif command == 'location' or command == 'loc' then
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

-- converts name of a bag (str) to an id number. returns 0 (inventory) when no argument passed.
function inv_str_to_id(str)
    if not str then return 0 end
    if str == 'inventory' then
        return 0
    elseif str == 'safe' then
        return 1
    elseif str == 'storage' then
        return 2
    elseif str == 'locker' then
        return 3
    elseif str == 'satchel' then
        return 5
    elseif str == 'sack' then
        return 6
    elseif str == 'case' then
        return 7
    elseif str == 'wardrobe' then
        return 8
    end
end

-- check's if an inventory is full. returns true if full. if no location argument is passed checks main inventory.
function inventory_full(command, location)
    local id = inv_str_to_id(location)
    if id == 0 then location = 'inventory' end

    local items = windower.ffxi.get_items(id)
    if items.count == items.max then
        if command then
            obi_output('%s is full.':format(string.ucfirst(location)))
        elseif not inv_full_warned then
            inv_full_warned = true
            obi_output('%s is full.':format(string.ucfirst(location)))
        end
        return true
    elseif items.count < items.max then
        inv_full_warned = false
        return false
    end
    
    print('obiaway: inventory check unknown error.')
end

-- returns list of obi in inventory
function get_obi_in_inventory()
    local obi = {}
    local inv = windower.ffxi.get_items(0)
    if not inv then return end

    for i=1,inv.max do
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
    if inventory_full(command) then
        return
    end

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
    if inventory_full(command, settings.location) then
        return
    end

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
    if inventory_full(command) then
        return
    end

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
    else
        return str
    end
end

function put_all_obi(command)
    if inventory_full(command, settings.location) then
        return
    end

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
    else
        return str
    end
end

function lock_obi(toggle)
    if toggle then
        settings.lock = true
        lock_warned = true
        if settings.notify then
            obi_output('Obi locked.')
        end
    elseif not toggle then
        settings.lock = false
        lock_warned = false
        if settings.notify then
            obi_output('Unlocking obi...')
        end
    end
end

-- function called on events. sorts obi based on location.
function auto_sort_obi()
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
    end
end

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
