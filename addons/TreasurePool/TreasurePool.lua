--[[Copyright © 2019, Kenshi
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of TreasurePool nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL KENSHI BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'TreasurePool'
_addon.author = 'Kenshi'
_addon.version = '2.0'

require('luau')
texts = require('texts')
packets = require('packets')

-- Config

defaults = {}
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.display.bg = {}
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.bg.alpha = 102
defaults.display.bg.visible = true
defaults.display.text = {}
defaults.display.text.font = 'Consolas'
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.text.size = 12

settings = config.load(defaults)
box = texts.new('${current_string}', settings)

local items = T{}

windower.register_event('load', function()
    local treasure = windower.ffxi.get_items().treasure
    for i = 0, 9 do
        if treasure[i] and treasure[i].item_id then
            local item = res.items[treasure[i].item_id] and res.items[treasure[i].item_id].en or treasure[i].item_id
            local pos = treasure[i].timestamp + i
            table.insert(items, {position = pos, index = i, name = item, timestamp = treasure[i].timestamp,
                temp = treasure[i].timestamp + 300, lotter = nil, lot = nil})
        end
    end
    table.sort(items, function(a,b) return a and b and a.position < b.position end)
end)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x0D2 then
        local packet = packets.parse('incoming', data)
        -- Ignore gil drop
        if packet.Item == 0xFFFF then
            return
        end
        -- Double packet and leaving pt fix
        for key, value in pairs(items) do
            if value and value.index == packet.Index then
                if value.timestamp == packet.Timestamp then
                    return
                else
                    table.remove(items, key)
                end
            end
        end
        -- Ignore item 0 packets
        if packet.Item == 0 then
            return
        end
        -- Create table
        local time_check = packet.Timestamp + 300
        local diff = os.difftime(time_check, os.time())
        local item = res.items[packet.Item] and res.items[packet.Item].en or packet.Item
        local pos = packet.Timestamp + packet.Index
        if diff <= 300 then
            table.insert(items, {position = pos, index = packet.Index, name = item, timestamp = packet.Timestamp,
                temp = packet.Timestamp + 300, lotter = nil, lot = nil})
        else
            table.insert(items, {position = pos, index = packet.Index, name = item, timestamp = packet.Timestamp,
                temp = os.time() + 300, lotter = nil, lot = nil})
        end
        -- Sort table
        table.sort(items, function(a,b) return a and b and a.position < b.position end)
    end
    if id == 0x0D3 then
        local packet = packets.parse('incoming', data)
        for key, value in pairs(items) do
            if value.index == packet.Index then
                if packet.Drop ~= 0 then
                    table.remove(items, key)
                    table.sort(items, function(a,b) return a and b and a.position < b.position end)
                else
                    value.lotter = packet['Highest Lotter Name']
                    value.lot = packet['Highest Lot']
                end
            end
        end
    end
    if id == 0xB then
        items = T{}
    end
end)

windower.register_event('prerender', function()
    if items:empty() then
        box:hide()
        return
    end
    local current_string = 'Treasure Pool:'
    for key, value in pairs(items) do
        if value and value.temp then
            local diff = os.difftime(value.temp, os.time())
            local timer = os.date('!%M:%S', diff)
            if diff >= 0 then
                current_string = current_string..'\n['..key..']'
                current_string = (
                    diff < 60 and
                    current_string..'\\cs(255,0,0) '..value.name..' → '..timer
                    or diff > 180 and
                    current_string..'\\cs(0,255,0) '..value.name..' → '..timer
                    or
                    current_string..'\\cs(255,128,0) '..value.name..' → '..timer)..'\\cr'
                if value.lotter and value.lot and value.lot > 0 then
                    current_string = current_string..' | '
                    current_string = (current_string..'\\cs(0,255,255)'..value.lotter..': '..value.lot)..'\\cr'
                end
            else
                table.remove(items, key)
            end
        box:show()
        end
    end
    box.current_string = current_string
end)

windower.register_event('logout', function()
    items = T{}
end)
