--[[
Copyright (c) 2014, Seth VanHeulen
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

-- addon information

_addon.name = 'boxdestroyer'
_addon.version = '1.0.1'
_addon.command = 'boxdestroyer'
_addon.author = 'Seth VanHeulen (Acacia@Odin)'

-- modules

require('pack')

-- load message constants

require('messages')

-- global constants

default = {
    10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
    20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
    30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
    40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
    50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
    60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
    70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
    80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
    90, 91, 92, 93, 94, 95, 96, 97, 98, 99
}

-- global variables

box = {}

-- filter helper functions

function greater_less(id, greater, num)
    if box[id] == nil then
        box[id] = default
    end
    local new = {}
    for _,v in pairs(box[id]) do
        if greater and v > num or not greater and v < num then
            table.insert(new, v)
        end
    end
    return new
end

function even_odd(id, div, rem)
    if box[id] == nil then
        box[id] = default
    end
    local new = {}
    for _,v in pairs(box[id]) do
        if (math.floor(v / div) % 2) == rem then
            table.insert(new, v)
        end
    end
    return new
end

function equal(id, first, num)
    if box[id] == nil then
        box[id] = default
    end
    local new = {}
    for _,v in pairs(box[id]) do
        if first and math.floor(v / 10) == num or not first and (v % 10) == num then
            table.insert(new, v)
        end
    end
    return new
end

-- display helper function

function display(id, chances)
    if #box[id] == 90 then
        windower.add_to_chat(207, 'possible combinations: 10~99')
    else
        windower.add_to_chat(207, 'possible combinations: ' .. table.concat(box[id], ' '))
    end
    local remaining = math.floor(#box[id] / math.pow(2, (chances - 1)))
    if remaining == 0 then
        remaining = 1
    end
    windower.add_to_chat(207, 'best guess: %d (%d%%)':format(box[id][math.ceil(#box[id] / 2)], 1 / remaining * 100))
end

-- event callback functions

function check_incoming_chunk(id, original, modified, injected, blocked)
    local zone_id = windower.ffxi.get_info().zone
    if messages[zone_id] then
        if id == 0x0B then
            box = {}
        elseif id == 0x2A then
            local box_id = original:unpack('I', 5)
            local param0 = original:unpack('I', 9)
            local param1 = original:unpack('I', 13)
            local param2 = original:unpack('I', 17)
            local message_id = original:unpack('H', 27) % 0x8000
            if messages[zone_id].greater_less == message_id then
                box[box_id] = greater_less(box_id, param1 == 0, param0)
            elseif messages[zone_id].second_even_odd == message_id then
                box[box_id] = even_odd(box_id, 1, param0)
            elseif messages[zone_id].first_even_odd == message_id then
                box[box_id] = even_odd(box_id, 10, param0)
            elseif messages[zone_id].range == message_id then
                box[box_id] = greater_less(box_id, true, param0)
                box[box_id] = greater_less(box_id, false, param1)
            elseif messages[zone_id].less == message_id then
                box[box_id] = greater_less(box_id, false, param0)
            elseif messages[zone_id].greater == message_id then
                box[box_id] = greater_less(box_id, true, param0)
            elseif messages[zone_id].equal == message_id then
                local new = equal(box_id, true, param0)
                local duplicate = param0 * 10 + param0
                for k,v in pairs(new) do
                    if v == duplicate then
                        table.remove(new, k)
                    end
                end
                for _,v in pairs(equal(box_id, false, param0)) do table.insert(new, v) end
                table.sort(new)
                box[box_id] = new
            elseif messages[zone_id].second_multiple == message_id then
                local new = equal(box_id, false, param0)
                for _,v in pairs(equal(box_id, false, param1)) do table.insert(new, v) end
                for _,v in pairs(equal(box_id, false, param2)) do table.insert(new, v) end
                table.sort(new)
                box[box_id] = new
            elseif messages[zone_id].first_multiple == message_id then
                local new = equal(box_id, true, param0)
                for _,v in pairs(equal(box_id, true, param1)) do table.insert(new, v) end
                for _,v in pairs(equal(box_id, true, param2)) do table.insert(new, v) end
                table.sort(new)
                box[box_id] = new
            elseif messages[zone_id].success == message_id or messages[zone_id].failure == message_id then
                box[box_id] = nil
            end
        elseif id == 0x34 then
            local box_id = original:unpack('I', 5)
            if windower.ffxi.get_mob_by_id(box_id).name == 'Treasure Casket' then
                local chances = original:byte(9)
                if box[box_id] == nil then
                    box[box_id] = default
                end
                if chances > 0 and chances < 7 then
                    display(box_id, chances)
                end
            end
        elseif id == 0x5B then
            box[original:unpack('I', 17)] = nil
        end
    end
end

-- register event callbacks

windower.register_event('incoming chunk', check_incoming_chunk)
