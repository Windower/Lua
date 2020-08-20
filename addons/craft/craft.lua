--[[
Craft v1.1.0

Copyright © 2017 Mojo
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of craft nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mojo BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name     = 'craft'
_addon.author   = 'Mojo'
_addon.version  = '1.1.1'
_addon.commands = {'craft'}

require('chat')
require('lists')
require('coroutine')
require('queues')
require('logger')
require('tables')
require('sets')
require('strings')

local packets = require('packets')
local res = require('resources')
local recipes = require('recipes')
local queue = Q{}
local handlers = {}
local delay = 24
local synth = 0
local skip_delay = false
local busy = false
local paused = false
local display = false
local jiggle = false
local support = false
local zone = nil
local hqsynth = false

local conditions = {
    move = false,
    sort = false,
    crystal = false,
    support = false,
}

local food = false
local supported = false
local appropriated = {}
local inventory = {}

local function filter_bag(v)
    return not (v.name:match("Inventory") or
        v.name:match("Temporary") or
        v.name:match("Wardrobe"))
end

local function get_bag_command(k)
    return res.bags[k].command
end

local function get_bag_id(bag)
    return bag.id
end

local bags = res.bags:filter(filter_bag):key_map(get_bag_command):map(get_bag_id)

local support_npcs = {
    {name = "Orechiniel", zone = 230, menu = 650, buff = 240},
    {name = "Greubaque", zone = 231, menu = 628, buff = 237},
    {name = "Ulycille", zone = 231, menu = 623, buff = 236},
    {name = "Azima", zone = 234, menu = 122, buff = 242},
    {name = "Fatimah", zone = 235, menu = 302, buff = 238},
    {name = "Wise Owl", zone = 237, menu = 103, buff = 237},
    {name = "Kipo-Opo", zone = 238, menu = 10015, buff = 243},
    {name = "Lih Pituu", zone = 241, menu = 10018, buff = 241},
    {name = "Terude-Harude", zone = 241, menu = 10013, buff = 239},
    {name = "Fleuricette", zone = 256, menu = 1201, buff = 512},
    {name = "Quiri-Aliri", zone = 257, menu = 1201, buff = 512},
}

local exceptions = {
    ['Geo Crystal'] = 6509,
    ['Fire Card'] = 9764,
    ['Ice Card'] = 9765,
    ['Wind Card'] = 9766,
    ['Earth Card'] = 9767,
    ['Water Card'] = 9769,
    ['Light Card'] = 9770,
    ['Dark Card'] = 9771,
}

local clusters = {
    ['Fire Crystal'] = 'Fire Cluster',
    ['Ice Crystal'] = 'Ice Cluster',
    ['Wind Crystal'] = 'Wind Cluster',
    ['Earth Crystal'] = 'Earth Cluster',
    ['Lightng. Crystal'] = 'Lightning Cluster',
    ['Water Crystal'] = 'Water Cluster',
    ['Light Crystal'] = 'Light Cluster',
    ['Dark Crystal'] = 'Dark Cluster',
}

local hqcrystal = {
    ['Fire Crystal'] = 'Inferno Crystal',
    ['Ice Crystal'] = 'Glacier Crystal',
    ['Wind Crystal'] = 'Cyclone Crystal',
    ['Earth Crystal'] = 'Terra Crystal',
    ['Lightng. Crystal'] = 'Plasma Crystal',
    ['Water Crystal'] = 'Torrent Crystal',
    ['Light Crystal'] = 'Aurora Crystal',
    ['Dark Crystal'] = 'Twilight Crystal',
}

local help_commands = [[
craft - Command List:
1.  help - Displays this message.
2.  repeat - Repeats synthesis (default 1) using the
    lastsynth command.
* repeat - Repeats 1 synthesis
* repeat 13 - Repeats 13 synthesis
3.  make - Issue a synthesis command using a recipe name
* make "Sheep Leather" - Makes 1 Sheep Leather
* make "Sheep Leather" 5 - Makes 5 Sheep Leather
4.  put - Moves all copies of an item into available bags.
* put "Dragon Mask" - Moves all Dragon Masks in inventory
  to any available bags.
* put "Dragon Mask" satchel - Moves all Dragon Masks in
  inventory to Mog Satchel.
* put "Dragon Mask" safe2 - Moves all Dragon Masks to Mog
  Safe 2 (if available).
5.  delay - Sets the delay between crafting attempts
    (default 24, minimum 17)
* delay 30 - Sets the delay between crafting to 30
  seconds.]]

local help_commands_2 = [[
6.  food - Sets a food item that will automatically
    be consumed while crafting.
* food - Sets the auto food to None.
* food "Kitron Macaron" - Sets the auto food
  to Kitron Macaron.
7.  pause - Pauses the addon.
8.  resume - Resumes the addon.
9. clear - Clears all items in the queue.
10. jiggle - Set a key that will be pressed between every
    queue item (default disabled.)
* jiggle - Disables the jiggle feature.
* jiggle escape - Sets the jiggle key to escape.
11. support - Toggles auto support/ionis (default off)
* Must be near an NPC that offers Ionis or advanced
  imagery support to work.
* Determines whether items will be sold instantly or slowly.
12. status - Display some information about the
    addon's current state.
13. find - Search for a recipe fromt the recipes list using
    a string.
* find "Pizza" - Finds and displays all recipes containing
  the string "Pizza".
* find "Pizza" details - Finds and displays all recipes
  containing the string "Pizza" (ingredients/crystal are
  also displayed.)
14. display - Toggles whether outgoing crafting
    packets are displayed in the chat log.
15. hqcrystal - Toggle whether to use HQ Crystal
]]

local help_notes = [[
Notes:
  Make commands will automatically pull items from
  any available bags if they are not present in your
  inventory.  This includes all recipe ingredients
  and the crystal.  If a crystal cannot be found,
  it will search for a cluster from your inventory
  and available bags and use the cluster.  These
  features are not supported with the repeat command.

  The available recipes are stored in recipes.lua.
  The order in which ingredients are entered matter.
  To add new recipes, enable the display (//craft
  display) and manually synthesis an item.  The
  packet will be printed to your chat log.  Create
  an entry similar to the recipes that are already
  provided.  Only add the actual ingredients and
  crystal.  Then save recipes.lua and reload the addon.

  Ingredients and food are case sensitive and use
  the short english name.  These are the ones
  displayed on FFXIAH.
]]

local function validate(npcs)
    zone = windower.ffxi.get_info()['zone']
    local valid = false
    for _, npc in pairs(npcs) do
        if zone == npc.zone then
            valid = true
            local mob = windower.ffxi.get_mob_by_name(npc.name)
            if mob then
                if (math.sqrt(mob.distance) < 6) then
                    return mob, npc
                end
            end
        end
    end
    if valid then
        warning("Too far from away from NPC")
    end
end

local function get_support(id, data)
    if (id == 0x34) and conditions['support'] then
        local mob, npc = validate(support_npcs)
        local p = packets.new('outgoing', 0x5b, {
            ["Target"] = mob.id,
            ["Option Index"] = 1,
            ["Target Index"] = mob.index,
            ["Automated Message"] = false,
            ["Zone"] = zone,
            ["Menu ID"] = npc.menu,
        })
        packets.inject(p)
        conditions['support'] = false
        return true
    end
end

local function check_bag(bag, id)
    if not inventory['enabled_%s':format(bag)] then
        return false
    end
    local contents = inventory[bag]
    for index = 1, inventory['max_%s':format(bag)] do
        if contents[index].id == id then
            conditions['sort'] = true
            conditions['move'] = true
            windower.ffxi.get_item(bags[bag], index, contents[index].count)
            return true
        end
    end
    return false
end

local function check_bags(id)
    if inventory['count_inventory'] == inventory['max_inventory'] then
        return false
    end
    for bag, bag_id in pairs(bags) do
        if check_bag(bag, id) then
            return true
        end
    end
    return false
end

local function block_sort(id, data)
    if (id == 0x3a) and conditions['sort'] then
        return true
    end
end

local function busy_wait(block, timeout, message)
    local start = os.time()
    while conditions[block] and ((os.time() - start) < timeout) do
        coroutine.sleep(.1)
    end
    if os.time() - start >= timeout then
        conditions[block] = false
        return "Timed out - %s":format(message)
    else
        inventory = windower.ffxi.get_items()
    end
end

local function poke_npc()
    local mob, npc = validate(support_npcs)
    if npc then
        local player = windower.ffxi.get_player()
        if S(player.buffs):contains(npc.buff) then
            return
        end
        conditions['support'] = true
        local p = packets.new('outgoing', 0x01a, {
            ["Target"] = mob.id,
            ["Target Index"] = mob.index,
            ["Category"] = 0,
            ["Param"] = 0,
            ["_unknown1"] = 0,
        })
        packets.inject(p)
        return busy_wait('support', 10, "getting crafting buff")
    end
end

local function unblock_sort(id, data)
    if id == 0x1d then
        conditions['move'] = false
    end
end

local function unblock_item(id, data)
    if (id == 0x20) then
        p = packets.parse('incoming', data)
        if p['Item'] == conditions['item'] then
            conditions['item'] = false
        end
    end
end

local function commence_jigglin()
    windower.send_command('setkey %s down':format(jiggle))
    coroutine.sleep(.25)
    windower.send_command('setkey %s up':format(jiggle))
end

local function consume_item(item)
    windower.chat.input('/item \"%s\" <me>':format(item))
    coroutine.sleep(3.5)
    inventory = windower.ffxi.get_items()
end

local function fetch_ingredient(ingredient)

    local id, name
    if exceptions[ingredient] then
        id = exceptions[ingredient]
    else
        item = res.items:name(ingredient)
        id, name = next(item, nil)
    end
    if id then
        local contents = inventory['inventory']
        for index = 1, inventory['max_inventory'] do
            if appropriated[index] == nil then
                appropriated[index] = 0
            end
            if (contents[index].id == id) and
               (contents[index].count > appropriated[index]) then
                appropriated[index] = appropriated[index] + 1
                return id, index
            end
        end
        if check_bags(id) then
            local status = busy_wait('move', 10, 'moving %s':format(ingredient))
            if status then
                return status
            else
                return fetch_ingredient(ingredient)
            end
        end
        if clusters[ingredient] then
            local cluster = clusters[ingredient]
            local cluster_id, cluster_index = fetch_ingredient(cluster)
            if cluster_index then
                conditions['sort'] = true
                conditions['item'] = id
                local start = os.time()
                windower.chat.input('/item \"%s\" <me>':format(cluster))
                local status = busy_wait('item', 10, 'using %s':format(cluster))
                if status then
                    error(status)
                end
                coroutine.sleep(4 - (os.time() - start))
                inventory = windower.ffxi.get_items()
                return fetch_ingredient(ingredient)
            end
        end
        return "Unable to locate %s":format(ingredient)
    else
        return "Unknown item %s":format(ingredient)
    end
end

local function consume_food()
    local player = windower.ffxi.get_player()
    if S(player.buffs):contains(251) then
        return
    end
    inventory = windower.ffxi.get_items()
    local id, index = fetch_ingredient(food)
    if index then
        windower.chat.input('/item \"%s\" <me>':format(food))
        coroutine.sleep(3.5)
    else
        warning("Unable to consume %s":format(food))
    end
end

local function fetch_recipe(item)
    local item = item:lower()
    for name, recipe in pairs(recipes) do
        if item == name:lower() then
            return recipe
        end
    end
end

local function hash(crystal, item, count)
    local c = ((crystal % 6506) % 4238) % 4096
    local m = (c + 1) * 6 + 77
    local b = (c + 1) * 42 + 31
    local m2 = (8 * c + 26) + (item - 1) * (c + 35)
    return (m * item + b + m2 * (count - 1)) % 127
end

local function build_recipe(item)
    if windower.ffxi.get_player().status ~= 0 then
        return "You can't craft at the moment"
    end

    local recipe = fetch_recipe(item)
    
    if recipe then
        inventory = windower.ffxi.get_items()
        appropriated = {}
        local p = packets.new('outgoing', 0x096)
        local crystal = recipe['crystal']
        if hqsynth then
            crystal = hqcrystal[crystal]
        end
        local id, index = fetch_ingredient(crystal)
        if not index then return id end
        p['Crystal'] = id
        p['Crystal Index'] = index
        p['Ingredient count'] = #recipe['ingredients']
        for i, ingredient in pairs(recipe['ingredients']) do
            id, index = fetch_ingredient(ingredient)
            if not index then return id end
            p["Ingredient %i":format(i)] = id
            p["Ingredient Index %i":format(i)] = index
        end
        p['_unknown1'] = hash(p['Crystal'], p['Ingredient 1'], p['Ingredient count'])
        return p
    else
        return "No recipe for %s":format(item)
    end
end

local function issue_synthesis(item)
    local p = build_recipe(item)
    if type(p) == 'string' then
        skip_delay = true
        conditions['sort'] = false
        return "%s - %s":format(item, p)
    else
        packets.inject(p)
        conditions['sort'] = false
    end
end

local function repeat_synthesis()
    windower.chat.input('/lastsynth')
end

local function put_items(bag, id)
    local src = inventory['inventory']
    local dst = inventory[bag]
    local empty = {}
    for index = 1, inventory['max_%s':format(bag)] do
        if dst[index].count == 0 then
            empty[index] = true
        end
    end
    local idx, status = next(empty, nil)
    for index = 1, inventory['max_inventory'] do
        if (src[index].id == id) and idx then
            windower.ffxi.put_item(bags[bag], index, src[index].count)
            dst[idx].id = id
            dst[idx].count = src[index].count
            src[index].id = 0
            src[index].count = 0
            idx, status = next(empty, idx)
            delta = true
        end
    end
end

local function put(args)
    conditions['sort'] = true
    delta = false
    inventory = windower.ffxi.get_items()
    if args['bag'] then
        local bag = args['bag']
        if not inventory['enabled_%s':format(bag)] then
            block = false
            return "bag %s disabled":format(bag)
        end
        put_items(bag, args['id'])
    else
        for bag, bag_id in pairs(bags) do
            if inventory['enabled_%s':format(bag)] then
                put_items(bag, args['id'])
            end
        end
    end
    if delta then
        delta = false
        busy_wait('move', 10, 'moving %s':format(args['name']))
    end
    conditions['sort'] = false
    coroutine.sleep(3.5)
    skip_delay = true
end

local function check_queue()
    if not queue:empty() then
        if not paused then
            if jiggle then
                commence_jigglin()
            end
            if support then
                poke_npc()
            end
            if food then
                consume_food()
            end
            local fn, arg = unpack(queue:pop())
            local msg = fn(arg)
            if msg then
                error(msg)
            end
            if skip_delay then
                coroutine.schedule(check_queue, 0)
                skip_delay = false
            else
                coroutine.schedule(check_queue, delay)
            end
        end
    else
        busy = false
    end
end

local function process_queue()
    if not busy then
        busy = true
        coroutine.schedule(check_queue, 0)
    end
end

local function handle_help()
    windower.add_to_chat(100, help_commands)
    windower.add_to_chat(100, help_commands_2)
    windower.add_to_chat(100, help_notes)
end

local function handle_status()
    notice("delay", delay)
    notice("paused", paused)
    notice("display", display)
    notice("auto food", food)
    notice("auto support", support)
    notice("jiggle", jiggle)
    notice("queue size", queue:length())
    notice("hq crystal", hqsynth)
end

local function handle_delay(seconds)
    local n = tonumber(seconds)
    if n == nil then
        return "Invalid delay %s":format(seconds)
    else
        n = math.max(17, n)
        notice("Setting delay to %d":format(n))
        delay = n
    end
end

local function handle_clear()
    notice("Clearing queue")
    queue = Q{}
end

local function handle_pause()
    notice("Pausing")
    paused = true
end

local function handle_resume()
    notice("Resuming")
    if paused then
        paused = false
        busy = false
        process_queue()
    end
end

local function handle_jiggle(key)
    if key then
        notice("Setting jiggle to %s key":format(key))
        jiggle = key
    else
        notice("Removing jiggle")
        jiggle = false
    end
end

local function handle_repeat(count)
    local count = count or 1
    local n = tonumber(count)
    if n == nil then
        return "Invalid count %s":format(count)
    end
    notice("Adding %d repeat commands to the queue":format(count))
    for i = 1, count do
        local item = {repeat_synthesis, nil}
        queue:push(item)
    end
    process_queue()
end

local function handle_make(item, count)
    local count = count or 1
    local n = tonumber(count)
    if n == nil then
        return "Invalid count %s":format(count)
    end
    local recipe = fetch_recipe(item)
    if not recipe then
        return "No recipe for %s":format(item)
    end
    notice("Adding %d make %s commands to the queue":format(count, item))
    for i = 1, count do
        local item = {issue_synthesis, item}
        queue:push(item)
    end
    process_queue()
end

local function handle_food(item)
    if not item then
        notice("Setting auto food to None")
        food = false
    else
        local search = res.items:name(item)
        local id, name = next(search, nil)
        if id then
            notice("Setting auto food to %s":format(name.en))
            food = name.en
        else
            return "Invalid food %s":format(item)
        end
    end
end

local function handle_put(ingredient, bag)
    if bag then
        bag = bag:lower()
        if not bags[bag] then
            return "Unknown bag %s":format(bag)
        end
    end
    local search = res.items:name(ingredient)
    local id, name = next(search, nil)
    if id then
        local msg = nil
        local args = {
            ['id'] = id,
            ['bag'] = bag,
            ['name'] = name.english,
        }
        local item = {put, args}
        if bag then
            msg = "%s %s":format(ingredient, bag)
        else
            msg = ingredient
        end
        notice("Adding a put %s command to the queue":format(msg))
        queue:push(item)
        process_queue()
    else
        return "Unknown item %s":format(ingredient)
    end
end

local function display_crafting_packet(id, data)
    if id == 0x096 and display then
        local p = packets.parse('outgoing', data)
        log(p)
    end
end

local function handle_display()
    if display then
        notice("Disabling display")
        display = false
    else
        notice("Enabling display")
        display = true
    end
end

local function handle_support()
    if support then
        notice("Disabling support")
        support = false
    else
        notice("Enabling support")
        support = true
    end
end

local function handle_find(query, details)
    local query = query:lower()
    notice("Searching for recipes containing %s":format(query))
    for name, recipe in pairs(recipes) do
        if string.find(name:lower(), query) then
            notice("Found recipe - \"%s\"":format(name))
            if details then
                notice(" %s":format(recipe['crystal']))
                for _, ingredient in pairs(recipe['ingredients']) do
                    notice("  %s":format(ingredient))
                end
            end
        end
    end
end

local function handle_hqsynth()
    if hqsynth then
        notice("Disabling HQ Crystal")
        hqsynth = false
    else
        notice("Enabling HQ Crystal")
        hqsynth = true
    end
end


handlers['clear'] = handle_clear
handlers['repeat'] = handle_repeat
handlers['r'] = handle_repeat
handlers['delay'] = handle_delay
handlers['pause'] = handle_pause
handlers['resume'] = handle_resume
handlers['make'] = handle_make
handlers['m'] = handle_make
handlers['display'] = handle_display
handlers['put'] = handle_put
handlers['food'] = handle_food
handlers['status'] = handle_status
handlers['help'] = handle_help
handlers['jiggle'] = handle_jiggle
handlers['support'] = handle_support
handlers['find'] = handle_find
handlers['hqcrystal'] = handle_hqsynth

local function handle_command(cmd, ...)
    local cmd = cmd or 'help'
    if handlers[cmd] then
        local msg = handlers[cmd](unpack({...}))
        if msg then
            error(msg)
        end
    else
        error("Unknown command %s":format(cmd))
    end
end

windower.register_event('addon command', handle_command)
windower.register_event('outgoing chunk', display_crafting_packet)
windower.register_event('outgoing chunk', block_sort)
windower.register_event('incoming chunk', unblock_sort)
windower.register_event('incoming chunk', unblock_item)
windower.register_event('incoming chunk', get_support)
