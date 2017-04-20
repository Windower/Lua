--[[
temps v1.0

Copyright © 2017, Mojo
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of temps nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

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

_addon.name = 'temps'
_addon.author = 'Mojo'
_addon.version = '1.0'
_addon.command = 'temps'

require('chat')
require('logger')
require('pack')

config = require('config')
items = require('items')
packets = require('packets')

local help_text = [[
temps - Command List:
1. help - Displays this help menu.
2. buy - Buys all temporary items in an escha zone.
* buy - Buys all temporary items.
* buy radialens - Buys all temporary items and also
  attempts to buy a radialens, even if it is on your
  blacklist or if you already have one.
3. blacklist - Add(a)/Remove(r) items from your blacklist.
* blacklist add radialens - Adds radialens to your
  blacklist.
* blacklist a radialens - Adds radialens to your blacklist.
* blacklist remove radialens - Removes radialens from 
  your blacklist.
* blacklist r radialens - Removes radialens from your
  blacklist.
4. turbo - Toggle the turbo feature.
* turbo - Enables or disables the turbo feature.

Notes:
  You must be near an escha NPC that sells temporary
  items.  A buy radialens command will refresh your
  radialens duration in the event that you already have
  one.
]]

local defaults = {
    turbo = false,
    blacklist = S{
        'mollifier',
        'primeval brew',
        'radialens',
    }
}

local settings = config.load('settings.xml', defaults)
local handlers = {}
local state = 'idle'
local zone = nil
local force = nil
local silt = 0
local key_ids = {}
local key_items = 0
local outstanding = 0
local inflight = {}

local temp_items = {
    [1] = 0,
    [2] = 0,
}

local conditions = {
    temps = false,
    busy = false,
}

local zones = {
    [288] = {npc = "Affi", menu = 9701},
    [289] = {npc = "Dremi", menu = 9701},
    [291] = {npc = "Shiftrix", menu = 9701},
}

local function busy_wait(block, timeout, message)
    local start = os.time()
    while conditions[block] and ((os.time() - start) < timeout) do
        coroutine.sleep(.1)
    end
    if os.time() - start >= timeout then
        conditions[block] = false
        return "timed out - %s":format(message)
    end
end

local function validate(constrain)
    zone = windower.ffxi.get_info()['zone']
    if zones[zone] then
        local npc = windower.ffxi.get_mob_by_name(zones[zone].npc)
        if npc and ((math.sqrt(npc.distance) < 6) or (not constrain)) then
            return npc
        else
            error("Too far from %s.":format(zones[zone].npc))
        end
    else
        error("Not in an Escha zone.")
    end
end

local function has_item(item)
    if item.key_item then
        return (math.floor(key_items/math.pow(2, item.offset)) % 2) == 1
    else
        return (math.floor(temp_items[math.floor(item.offset/32) + 1]/math.pow(2, item.offset % 32)) % 2) == 1
    end
end

local function force_purchase(item)
    return (item.name == force)
end

local function ignore_item(item)
    return settings.blacklist:contains(item.name:lower())
end

local function purchase_items()
    local npc = validate()
    local count = 0
    for item_id, item in pairs(items) do
        if force_purchase(item) or (not has_item(item)) then
            if ignore_item(item) and (not force_purchase(item)) then
                windower.add_to_chat(100, string.format("Ignoring \30\2%s\30\43.", item.name))
            else
                local p = packets.new('outgoing', 0x5b, {
                    ["Target"] = npc.id,
                    ["Option Index"] = item.option,
                    ["Target Index"] = npc.index,
                    ["Automated Message"] = true,
                    ["Zone"] = zone,
                    ["Menu ID"] = zones[zone].menu,
                })
                windower.add_to_chat(100, string.format("Purchasing \30\2%s\30\43.", item.name))
                packets.inject(p)
                state = 'purchase'
                inflight[item_id] = true
                count = count + 1
                if not settings.turbo then
                    coroutine.sleep(1)
                end
            end
        end
    end
    if count == 0 then
        windower.add_to_chat(100, "No temporary items to buy.")
    else
        outstanding = outstanding + count
        if outstanding == 0 then
            windower.add_to_chat(100, "Finished purchasing all temporary items.")
        end
    end
end

local function exit_menu(id, data, modified, injected, blocked)
    if (id == 0x5b) and ((state == 'init') or (state == 'purchase')) then
        local p = packets.parse('outgoing', data)
        local npc = validate()
        if (p['Target'] == npc.id) and not p['Automated Message'] then
            outstanding = 0
            state = 'idle'
        end
    end
end

local function observe_temps(id, data, modified, injected, blocked)
    if (id == 0x5c) and conditions['temps'] then
        local p = packets.parse('incoming', data)
        temp_items[1] = p['Menu Parameters']:unpack('I', 1)
        temp_items[2] = p['Menu Parameters']:unpack('I', 5)
        conditions['temps'] = false
    end
end

local function process_dialogue_event(id, data, modified, injected, blocked)
    if (id == 0x34) and (state == 'init') then
        local p = packets.parse('incoming', data)
        state = 'purchase'
        silt = p['Menu Parameters']:unpack('I', 5)
        key_items = p['Menu Parameters']:unpack('I', 9)
        conditions['temps'] = true
        busy_wait('temps', 10, 'observe temp items')
        purchase_items()
    end
end

local function check_inflight(iid)
    if (inflight[iid]) then
        inflight[iid] = nil
        outstanding = outstanding - 1
        if outstanding == 0 then
            windower.add_to_chat(100, "Finished purchasing all temporary items.")
        end
    end
end

local function receive_item(id, data, modified, injected, blocked)
    if (id == 0x20) and (state == 'purchase') then
        local p = packets.parse('incoming', data)
        check_inflight(p['Item'])
    end
end

local function obtained_key_item(p, item_id)
    if (math.floor(item_id/512) == p['Type']) then
        local bit = item_id % 512
        local n = bit % 8
        local character = math.floor(bit/8) + 1
        return ((math.floor(p['Key item available']:byte(character)/math.pow(2, n)) % 2) == 1)
    else
        return false
    end
end

local function receive_key_items(id, data, modified, injected, blocked)
    if (id == 0x55) and (state == 'purchase') then
        local p = packets.parse('incoming', data)
        for k, v in pairs(inflight) do
            if obtained_key_item(p, k) then
                check_inflight(k)
            end
        end
    end
end

local function validate_item(item)
    for k, v in pairs(items) do
        if item:lower() == v.name:lower() then
            return v.name
        end
    end
    error("%s not found in items list.":format(item))
end

local function start(override)
    if not (state == 'idle') then
        return error("Addon is busy.")
    elseif override then
        force = validate_item(override)
        if not force then
            return
        else
            notice("Override provided for %s.":format(force))
        end
    else
        force = nil
    end
    local npc = validate(true)
    if npc then
        local p = packets.new('outgoing', 0x01a, {
            ["Target"] = npc.id,
            ["Target Index"] = npc.index,
        })
        packets.inject(p)
        state = 'init'
    else
        state = 'idle'
    end
end

local function help()
    windower.add_to_chat(100, help_text)
end

local function blacklist(cmd, name)
    if not cmd then
        return error("No blacklist command provided.")
    elseif not S{'add', 'a', 'remove', 'r'}:contains(cmd) then
        return error("Unknown blacklist command %s.":format(cmd))
    elseif not name then
        return error("No blacklist command parameter provided.")
    end
    local item = validate_item(name)
    if not item then
        return
    elseif S{'add', 'a'}:contains(cmd) then
        notice("Adding %s to your blacklist.":format(item))
        settings.blacklist:add(item:lower())
    else
        notice("Removing %s from your blacklist.":format(item))
        settings.blacklist:remove(item:lower())
    end
    settings:save()
end

local function turbo()
    if settings.turbo then
        notice("Disabling turbo.")
        settings.turbo = false
    else
        notice("Enabling turbo.")
        settings.turbo = true
    end
    settings:save()
end
    
local function handle_command(cmd, ...)
    local cmd = cmd and cmd:lower() or 'help'
    if handlers[cmd] then
        handlers[cmd](...)
    else
        error("Unknown command %s.":format(cmd))
    end
end

handlers['buy'] = start
handlers['help'] = help
handlers['blacklist'] = blacklist
handlers['turbo'] = turbo

windower.register_event('incoming chunk', process_dialogue_event)
windower.register_event('incoming chunk', receive_item)
windower.register_event('incoming chunk', receive_key_items)
windower.register_event('incoming chunk', observe_temps)
windower.register_event('outgoing chunk', exit_menu)
windower.register_event('addon command', handle_command)
