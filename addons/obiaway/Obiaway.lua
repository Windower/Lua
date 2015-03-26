-- 
-- obiaway v1.0.7
-- 
-- Copyright ©2013-2015, ReaperX, Bangerang
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
-- * Neither the name of obiaway nor the
--   names of its contributors may be used to endorse or promote products
--   derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL ReaperX or Bangerang BE LIABLE FOR ANY
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
-- undesirable effects, often not moving obi at all. This is due to 
-- limitations on how fast items can be moved from one inventory to 
-- another.
--
-- 2. When weather changes due to zoning, get_obi_in_inventory()
-- is called before inventory has loaded and returns nothing.
--
-- 3. Obi is not moved when currently equipped.
--
--
-- To-do:
--   - Add support for other languages.
--
--

-- addon info
_addon.name = "obiaway"
_addon.author = "ReaperX, Bangerang"
_addon.version = "1.0.7"
_addon.commands = {'oa', 'ob', 'obi', 'obiaway'}
_addon.language = 'english'

-- library includes
require('sets')
require('logger')
config = require('config')
res = require('resources')

-- settings
default_settings = {}
default_settings.notify = true
default_settings.location = 'sack'
default_settings.lock = false
default_settings.color = 209
default_settings.ignore_zones = S{
    "Ru'Lude Gardens", "Upper Jeuno", "Lower Jeuno", "Port Jeuno", "Port Windurst", "Windurst Waters", "Windurst Woods", "Windurst Walls",
    "Heavens Tower", "Port San d'Oria", "Northern San d'Oria", "Southern San d'Oria", "Chateau d'Oraguille", "Port Bastok", "Bastok Markets",
    "Bastok Mines", "Metalworks", "Aht Urhgan Whitegate", "Tavnazian Safehold", "Nashmau", "Selbina", "Mhaura", "Norg", "Rabao", "Kazham",
    "Eastern Adoulin", "Western Adoulin", "Leafallia", "Celennia Memorial Library", "Mog Garden"}
settings = config.load(default_settings)

-- tokens
tokens = {}
tokens.lock_warned = false
tokens.inv_full_warned = false
tokens.bag_full_warned = false

-- lists
obi_names = T{
    Light = 'Korin',
    Dark = 'Anrin',
    Fire = 'Karin',
    Earth = 'Dorin',
    Water = 'Suirin',
    Wind = 'Furin',
    Ice = 'Hyorin',
    Lightning = 'Rairin'
}


----------------------------------------
---      UTITLITY Functions  
----------------------------------------

-- Automatically formats output text for addon. Accepts msg as a string.
function obi_output(msg)
    prefix = 'Obi: '
    windower.add_to_chat(settings.color, prefix..msg)
end

-- Accepts a boolean value and returns an appropriate string value. i.e. true -> 'on'
function bool_to_str(bool)
    return bool and 'on' or 'off'
end

-- checks if a value is in a table and then returns its key. Ex: a table contains Key = Value. returns Key. returns false if no match.
function in_table(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end

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
    else
        print('Obiaway: Function inv_str_to_id invalid argument')
        return
    end
end

-- Function which counts how many slots remain in a bag. if no location is passed, checks inventory.
function free_space(location)
    local id = inv_str_to_id(location)

    local inv = windower.ffxi.get_bag_info(id)
    n = inv.max - inv.count
    return n
end

-- check's if an inventory is full. returns true if full. if no location argument is passed checks main inventory.
-- also handle's an inventory full warning. requires two tokens which keep track of whether or not an inventory
-- full warning was already given. one for the main inventory and a separate for a bag. this is to prevent
-- "Inventory full." spam in the chat log.
function inventory_full(command, location)
    local id = inv_str_to_id(location)
    if id == 0 then location = 'inventory' end
    
    if free_space(location) == 0 then
        if command then
            obi_output('%s is full.':format(string.ucfirst(location)))
        elseif not tokens.inv_full_warned and id == 0 then
            tokens.inv_full_warned = true
            obi_output('%s is full.':format(string.ucfirst(location)))
        elseif not tokens.bag_full_warned then
            tokens.bag_full_warned = true
            obi_output('%s is full.':format(string.ucfirst(location)))
        end
        return true
    elseif free_space(location) > 0 then -- resets the tokens when space is free
        if id == 0 then tokens.inv_full_warned = false else tokens.bag_full_warned = false end
        return false
    end
    
    print('Obiaway: Function inventory_full unknown error.')
end


----------------------------------------
---         ADDON functions
----------------------------------------

-- locks obi sorting. accepts true or false.
function lock_obi(toggle)
    if toggle then
        settings.lock = true
        tokens.lock_warned = true
        if settings.notify then
            obi_output('Obi locked.')
        end
    elseif not toggle then
        settings.lock = false
        tokens.lock_warned = false
        if settings.notify then
            obi_output('Unlocking obi...')
        end
    end
end

-- Builds a table of boolean values that indicate which obi are in inventory and how many.
-- Ex:
--          obi = {
--              "Fire" = false
--              "Ice" = false
--              "Wind" = true
--              "Earth" = false
--              "Lightning" = true
--              "Water" = false
--              "Light" = false
--              "Dark" = true
--              n = 3
--          }
--
-- function designer: ReaperX
function get_obi_in_inventory(location)
    local id = inv_str_to_id(location)
    local obi = {}
    local inv = windower.ffxi.get_items(id)
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
    
    -- count obi in inventory
    obi["n"] = table.count(obi, true)
    
    return obi
end

-- Builds a table (elements) which contains storm buffs, weather effects, and day of the week is active.
-- Adds +1 to corresponding element variable for each effect active.
-- Ex: If fire weather and earthsday are active will return:
--          elements = {
--              "Fire" = true
--              "Earth" = true
--              "Water" = false
--              "Wind" = false
--              "Ice" = false
--              "Lightning" = false
--              "Light" = false
--              "Dark" = false
--              "None" = false
--          }
--
-- function designer: ReaperX
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

    -- check for active Day and Weather
    local info = windower.ffxi.get_info()
    local day_element = res.elements[res.days[info.day].element].english
    elements[day_element] = elements[day_element] + 1
    local weather_element = res.elements[res.weather[info.weather].element].english
    elements[weather_element] = elements[weather_element] + 1
    
    -- check for active SCH buffs
    local buffs = windower.ffxi.get_player().buffs
    if in_table(buffs, 178) then
      elements["Fire"] =  elements["Fire"] + 1
    elseif in_table(buffs, 183) then
      elements["Water"] = elements["Water"] + 1
    elseif in_table(buffs, 181) then
      elements["Earth"] = elements["Earth"] + 1
    elseif in_table(buffs, 180) then
      elements["Wind"] = elements["Wind"] + 1
    elseif in_table(buffs, 179) then
      elements["Ice"] = elements["Ice"] + 1
    elseif in_table(buffs, 182) then
      elements["Lightning"] = elements["Lightning"] + 1
    elseif in_table(buffs, 184) then
      elements["Light"] = elements["Light"] + 1
    elseif in_table(buffs, 185) then
      elements["Dark"] = elements["Dark"] + 1
    end
    
    return elements
end

----------------------------------------
---      SORTING functions
----------------------------------------

function get_needed_obi(command)
    if inventory_full(command) then return false end
    local obi = get_obi_in_inventory()
    local elements = get_all_elements()

    for name, element in obi_names:it() do
        if not obi[element] and elements[element] > 0 then
            windower.send_command('get "%s Obi" %s;':format(name, settings.location))
            if settings.notify then
                obi_output('Getting %s Obi from %s.':format(name, settings.location))
            end
            coroutine.sleep(.5)
        end
    end

    return true
end

function put_unneeded_obi(command)
    if inventory_full(command, settings.location) then return false end
    local obi = get_obi_in_inventory()
    local elements = get_all_elements()

    for name, element in obi_names:it() do
        if obi[element] and elements[element] == 0 then    
            windower.send_command('put "%s Obi" %s;':format(name, settings.location))
            if settings.notify then
                obi_output('Putting %s Obi away into %s.':format(name, settings.location))
            end
            coroutine.sleep(.5)
        end
    end

    return true
end

function get_all_obi(command)
    if inventory_full(command) then return false end
    local obi = get_obi_in_inventory()
    local obi_bag = get_obi_in_inventory(settings.location)
    if free_space() < obi_bag["n"] then
        obi_output('Not enough space in inventory...')
        return false
    end

    local elements = get_all_elements()
    local obi = get_obi_in_inventory()

    for name, element in obi_names:it() do
        if not obi[element] then
            windower.send_command('get "%s Obi" %s;':format(name, settings.location))
            if settings.notify then
                obi_output('Getting %s Obi from %s.':format(name, settings.location))
            end
            coroutine.sleep(.5)
        end
    end
    
    return true
end

function put_all_obi(command)
    if inventory_full(command, settings.location) then return false end
    local obi = get_obi_in_inventory()
    if free_space(settings.location) < obi["n"] then
        obi_output('Not enough space in %s...':format(settings.location))
        return false
    end

    local elements = get_all_elements()

    for name, element in obi_names:it() do
        if obi[element] then
            windower.send_command('put "%s Obi" %s;':format(name, settings.location))
            if settings.notify then
                obi_output('Putting %s Obi away into %s.':format(name, settings.location))
            end
            coroutine.sleep(.5)
        end
    end

    return true
end

-- function called on automatic events. sorts obi based on location.
function auto_sort_obi()
    -- if inventory and obi bag are full at the same time, do nothing. 'cause we can't.
    if inventory_full(false) and inventory_full(false, settings.location) then return false end

    if not settings.lock then -- if sorting lock is not on, then do this stuff:
        if not settings.ignore_zones:contains(res.zones[windower.ffxi.get_info().zone].english) then -- Not in a city:
            put_unneeded_obi(false)
            get_needed_obi(false)
        else -- In a city:
            put_all_obi(false)
        end
    end
    
    return true
end

----------------------------------------
---            EVENTS
----------------------------------------

windower.register_event('gain buff', auto_sort_obi:cond(function(id) return id >= 178 and id <= 185 end))
windower.register_event('lose buff', auto_sort_obi:cond(function(id) return id >= 178 and id <= 185 end))
windower.register_event('day change', 'weather change', auto_sort_obi)
windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'help'
    params = L{...}:map(string.lower)


    if command == 'help' or command == 'h' then
        obi_output("obiaway v".._addon.version..". Authors: ".._addon.author)
        obi_output("//obiaway [options]")
        obi_output("   help :  Displays this help text.")
        obi_output("   sort :  Automatically sorts obi.")
        obi_output("   get [ all | needed ]")
        obi_output("       Gets obi from bag.")
        obi_output("   put [ all | unneeded ] [ sack | satchel | case | wardrobe ]")
        obi_output("       Puts obi away. Can optionally specify a location.")
        obi_output("   lock [ on | off ]    (%s)":format(bool_to_str(settings.lock)))
        obi_output("       Locks obi to current location.")
        obi_output("   notify [ on | off ]    (%s)":format(bool_to_str(settings.notify)))
        obi_output("       Sets obiaway notifcations on or off.")
        obi_output("   location [ sack | satchel | case | wardrobe ]    (%s)":format(settings.location))
        obi_output("       Sets inventory from which to get and put obi.")
    elseif command == 'sort' or command == 's' then
        if settings.lock then lock_obi(false) end
        if settings.notify then
            obi_output('Sorting obi...')
            coroutine.sleep(0.5)
        end
        auto_sort_obi(true)
    elseif command == 'get' or command == 'g' then
        if params[1] == 'all' or params [1] == 'a' then
            obi_output('Getting all obi from %s...':format(settings.location))
            get_all_obi(true)
            coroutine.sleep(1)
        elseif params[1] == 'needed' or params [1] == 'n' then
            obi_output('Getting needed obi from %s...':format(settings.location))
            get_needed_obi(true)
        else
            error("Invalid argument. Usage: //obiaway get [ all | needed ]")
        end
    elseif command == 'put' or command == 'p' then
        if params[1] == 'all' or params [1] == 'a' then
            if S{'sack','case','satchel','wardrobe'}:contains(params[2]) then
                settings.location = params[2]
                obi_output("Obiaway location set to: %s":format(settings.location))
            end
            obi_output('Putting all obi into %s...':format(settings.location))
            put_all_obi(true)
            coroutine.sleep(1)
        elseif params[1] == 'unneeded' or params[1] == 'needed' or params [1] == 'n' then
            if S{'sack','case','satchel','wardrobe'}:contains(params[2]) then
                settings.location = params[2]
                obi_output("Obiaway location set to: %s":format(settings.location))
            else
                obi_output('Putting unneeded obi into %s...':format(settings.location))
                put_unneeded_obi(true)
            end
        else
            error("Invalid argument. Usage: //obiaway put [ all | needed ] [ sack | satchel | case | wardrobe ]")
        end
    elseif command == 'lock' or command == 'l' then
        if params[1] == 'on' then
            lock_obi(true)
        elseif params[1] == 'off' then
            lock_obi(false)
        else
            error("Invalid argument. Usage: //obiaway lock [ on | off ]")
        end
    elseif command == 'unlock' then
        lock_obi(false)
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
