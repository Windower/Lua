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
_addon.version = '1.0.4'
_addon.command = 'boxdestroyer'
_addon.author = 'Seth VanHeulen (Acacia@Odin)'

-- modules

require('pack')
require('tables')

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

observed_default = {
    ['second_even_odd'] = false,
    ['first_even_odd'] = false,
    ['range'] = false,
    ['equal'] = false,
    ['second_multiple'] = false,
    ['first_multiple'] = false,
    ['thief_tools_active'] = false
}

thief_tools = {[1022] = true}

-- global variables

box = {}
observed = {}
zone_id = windower.ffxi.get_info().zone

-- filter helper functions

function greater_less(id, greater, num)
    local new = {}
    for _,v in pairs(box[id]) do
        if greater and v > num or not greater and v < num then
            table.insert(new, v)
        end
    end
    return new
end

function even_odd(id, div, rem)
    local new = {}
    for _,v in pairs(box[id]) do
        if (math.floor(v / div) % 2) == rem then
            table.insert(new, v)
        end
    end
    return new
end

function equal(id, first, num)
    local new = {}
    for _,v in pairs(box[id]) do
        if first and math.floor(v / 10) == num or not first and (v % 10) == num then
            table.insert(new, v)
        end
    end
    return new
end

function exclusive_mean(counts)
    total = 0
    for _,v in pairs(counts) do
        total = total + v
    end
    weighted_mean = 0
    for _,v in pairs(counts) do
        weighted_mean = weighted_mean + (total - v) * v / total
    end
    return weighted_mean
end

function calculate_odds(id,chances)
    local reductions = {}
    if not observed[id].first_even_odd then
        local counter = {0}
        counter[0] = 0
        for _,v in pairs(box[id]) do
            counter[math.floor(v / 10) % 2] = counter[math.floor(v / 10) % 2] + 1
        end
        reductions[#reductions+1] = exclusive_mean(counter)
    end
    if not observed[id].second_even_odd then
        local counter = {0}
        counter[0] = 0
        for _,v in pairs(box[id]) do
            counter[v % 2] = counter[v % 2] + 1
        end
        reductions[#reductions+1] = exclusive_mean(counter)
    end
    if not observed[id].range then
        local new = {}
        local reduction = 0
        for i,v in pairs(box[id]) do
            new[i] = 0
            for _,m in pairs(box[id]) do
                if m-v > 16 then break end
                new[i] = new[i] + math.max(16-math.abs(m - v),0)^2/256
            end
            reduction = reduction + (#box[id] - new[i])/#box[id]
        end
        
        reductions[#reductions+1] = reduction
    end
    if not observed[id].equal then
        local counter = {0,0,0,0,0,0,0,0,0}
        counter[0] = 0
        local eliminated = {0,0,0,0,0,0,0,0,0}
        eliminated[0] = 0
        for _,v in pairs(box[id]) do
            counter[math.floor(v / 10)] = counter[math.floor(v / 10)] + 1/2
            counter[v % 10] = counter[v % 10] + 1/2
            for i = 0,9 do
                if i ~= v % 10 and i ~= math.floor(v / 10) then
                    eliminated[i] = eliminated[i] + 1
                end
            end
        end
        
        reduction = 0
        for i,v in pairs(counter) do
            reduction = reduction + eliminated[i] * v / #box[id]
        end
        
        reductions[#reductions+1] = reduction
    end
    if not observed[id].second_multiple then
        local counter = {0,0,0,0,0,0,0,0,0}
        counter[0] = 0
        for _,v in pairs(box[id]) do
            counter[v % 10] = counter[v % 10] + 1
        end
        
        local weights = {
            counter[0]   + counter[1]/2 + counter[2]/3,
            counter[1]/2 + counter[2]/3 + counter[3]/3,
            counter[2]/3 + counter[3]/3 + counter[4]/3,
            counter[3]/3 + counter[4]/3 + counter[5]/3,
            counter[4]/3 + counter[5]/3 + counter[6]/3,
            counter[5]/3 + counter[6]/3 + counter[7]/3,
            counter[6]/3 + counter[7]/3 + counter[8]/2,
            counter[7]/3 + counter[8]/2 + counter[9]
        }
        
        local eliminated = {
            counter[3] + counter[4] + counter[5] + counter[6] + counter[7] + counter[8] + counter[9],
            counter[0] + counter[4] + counter[5] + counter[6] + counter[7] + counter[8] + counter[9],
            counter[0] + counter[1] + counter[5] + counter[6] + counter[7] + counter[8] + counter[9],
            counter[0] + counter[1] + counter[2] + counter[6] + counter[7] + counter[8] + counter[9],
            counter[0] + counter[1] + counter[2] + counter[3] + counter[7] + counter[8] + counter[9],
            counter[0] + counter[1] + counter[2] + counter[3] + counter[4] + counter[8] + counter[9],
            counter[0] + counter[1] + counter[2] + counter[3] + counter[4] + counter[5] + counter[9],
            counter[0] + counter[1] + counter[2] + counter[3] + counter[4] + counter[5] + counter[6]
        }
        
        local reduction = 0
        for i,v in pairs(weights) do
            reduction = reduction + eliminated[i] * v / #box[id]
        end
        
        reductions[#reductions + 1] = reduction
    end
    if not observed[id].first_multiple then
        local counter = {0,0,0,0,0,0,0,0,0}
        for _,v in pairs(box[id]) do
            counter[math.floor(v / 10)] = counter[math.floor(v / 10)] + 1
        end
        
        local weights = {
            counter[1]   + counter[2]/2 + counter[3]/3,
            counter[2]/2 + counter[3]/3 + counter[4]/3,
            counter[3]/3 + counter[4]/3 + counter[5]/3,
            counter[4]/3 + counter[5]/3 + counter[6]/3,
            counter[5]/3 + counter[6]/3 + counter[7]/3,
            counter[6]/3 + counter[7]/3 + counter[8]/2,
            counter[7]/3 + counter[8]/2 + counter[9]
        }
        
        local eliminated = {
            counter[4] + counter[5] + counter[6] + counter[7] + counter[8] + counter[9],
            counter[1] + counter[5] + counter[6] + counter[7] + counter[8] + counter[9],
            counter[1] + counter[2] + counter[6] + counter[7] + counter[8] + counter[9],
            counter[1] + counter[2] + counter[3] + counter[7] + counter[8] + counter[9],
            counter[1] + counter[2] + counter[3] + counter[4] + counter[8] + counter[9],
            counter[1] + counter[2] + counter[3] + counter[4] + counter[5] + counter[9],
            counter[1] + counter[2] + counter[3] + counter[4] + counter[5] + counter[6]
        }
                
        local reduction = 0
        for i,v in pairs(weights) do
            reduction = reduction + eliminated[i] * v / #box[id]
        end
        
        reductions[#reductions + 1] = reduction
    end
    
    local expected_examine_value = 0
    for _,v in pairs(reductions) do
        expected_examine_value = expected_examine_value + v/#reductions
    end
        
    local optimal_guess = math.ceil(#box[id] / 2)
    
    local expected_guess_value = 2*optimal_guess - 2*optimal_guess^2 / #box[id] + 2*optimal_guess/#box[id] - 1 / #box[id]
        
    return expected_examine_value, expected_guess_value
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
    
    if chances == 1 and observed[id].equal then
        -- The "equal" message (== "X") for X in 1..9 gives an unequal probability to the remaining options 
        -- because "XX" is twice as likely to be indicated by the "equal" message.
        -- This is too annoying to propagate to the rest of the addon, although it should be some day.
        local printed = false
        for _,v in pairs(box[id]) do
            if math.floor(v/10) == v%10 then
                windower.add_to_chat(207, 'best guess: %d (%d%%)':format(v, 1 / remaining * 100))
                printed = true
                break
            end
        end
        if not printed then
            windower.add_to_chat(207, 'best guess: %d (%d%%)':format(box[id][math.ceil(#box[id] / 2)], 1 / remaining * 100))
        end
    else
        windower.add_to_chat(207, 'best guess: %d (%d%%)':format(box[id][math.ceil(#box[id] / 2)], 1 / remaining * 100))
        local clue_value,guess_value = calculate_odds(id,chances)
        if clue_value > guess_value and remaining ~= 1 then
            windower.add_to_chat(207, 'boxdestroyer recommends examining the chest')
        else
            windower.add_to_chat(207, 'boxdestroyer recommends guessing %d':format(box[id][math.ceil(#box[id] / 2)]))
        end
    end
    
end

-- ID obtaining helper function
function get_id(zone_id,str)
    return messages[zone_id] + offsets[str]
end

-- event callback functions

function check_incoming_chunk(id, original, modified, injected, blocked)
    if id == 0x0A then
        zone_id = original:unpack('H', 49)
    elseif messages[zone_id] then
        if id == 0x0B then
            box = {}
            observed = {}
        elseif id == 0x2A then
            local box_id = original:unpack('I', 5)
            local param0 = original:unpack('I', 9)
            local param1 = original:unpack('I', 13)
            local param2 = original:unpack('I', 17)
            local message_id = original:unpack('H', 27) % 0x8000
            
            if box[box_id] == nil then
                box[box_id] = table.copy(default)
            end
            if observed[box_id] == nil then
                observed[box_id] = table.copy(observed_default)
            end
            
            if get_id(zone_id,'greater_less') == message_id then
                box[box_id] = greater_less(box_id, param1 == 0, param0)
            elseif get_id(zone_id,'second_even_odd') == message_id then
                -- tells whether the second digit is even or odd
                box[box_id] = even_odd(box_id, 1, param0)
                observed[box_id].second_even_odd = true
            elseif get_id(zone_id,'first_even_odd') == message_id then
                -- tells whether the first digit is even or odd
                box[box_id] = even_odd(box_id, 10, param0)
                observed[box_id].first_even_odd = true
            elseif get_id(zone_id,'range') == message_id then
                if observed[box_id].thief_tools_active then
                    -- Thief tools are the same as normal ranges but with larger bounds.
                    -- lower bound (param0) = solution - RANDINT(8,32)
                    -- upper bound (param1) = solution + RANDINT(8,32)
                    -- param0 + 33 > solution > param0 + 7
                    -- param1 - 7  > solution > param1 - 33
                    -- if the bound is less than 11 or greater than 98, the message changes to "greater" or "less" respectively
                    box[box_id] = greater_less(box_id, true, math.max(param1-33,param0+7) )
                    box[box_id] = greater_less(box_id, false, math.min(param0+33,param1-7) )
                    observed[box_id].thief_tools_active = false
                else
                    -- lower bound (param0) = solution - RANDINT(5,20)
                    -- upper bound (param1) = solution + RANDINT(5,20)
                    -- param0 + 21 > solution > param0 + 4
                    -- param1 - 4  > solution > param1 - 21
                    -- if the bound is less than 11 or greater than 98, the message changes to "greater" or "less" respectively
                    box[box_id] = greater_less(box_id, true, math.max(param1-21,param0+4) )
                    box[box_id] = greater_less(box_id, false, math.min(param0+21,param1-4) )
                    observed[box_id].range = true
                end
            elseif get_id(zone_id,'less') == message_id then
                -- Less is a range with 9 as the lower bound
                if observed[box_id].thief_tools_active then
                    box[box_id] = greater_less(box_id, true, math.max(9, param0-33) )
                    box[box_id] = greater_less(box_id, false, math.min(10+33,param0-7) )
                    observed[box_id].thief_tools_active = false
                else
                    box[box_id] = greater_less(box_id, true, math.max(9, param0-21) )
                    box[box_id] = greater_less(box_id, false, math.min(10+21,param0-4) )
                    observed[box_id].range = true
                end
            elseif get_id(zone_id,'greater') == message_id then
                -- Greater is a range with 100 as the upper bound
                if observed[box_id].thief_tools_active then
                    box[box_id] = greater_less(box_id, true, math.max(99-33,param0+7) )
                    box[box_id] = greater_less(box_id, false, math.min(100,param0+33) )
                    observed[box_id].thief_tools_active = false
                else
                    box[box_id] = greater_less(box_id, true, math.max(99-21,param0+4) )
                    box[box_id] = greater_less(box_id, false, math.min(100,param0+21) )
                    observed[box_id].range = true
                end
            elseif get_id(zone_id,'equal') == message_id then
                -- single number that is either the first or second digit of the solution
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
                observed[box_id].equal = true
            elseif get_id(zone_id,'second_multiple') == message_id then
                -- three digit range including the second digit of the solution
                local new = equal(box_id, false, param0)
                for _,v in pairs(equal(box_id, false, param1)) do table.insert(new, v) end
                for _,v in pairs(equal(box_id, false, param2)) do table.insert(new, v) end
                table.sort(new)
                box[box_id] = new
                observed[box_id].second_multiple = true
            elseif get_id(zone_id,'first_multiple') == message_id then
                -- three digit range including the first digit of the solution
                local new = equal(box_id, true, param0)
                for _,v in pairs(equal(box_id, true, param1)) do table.insert(new, v) end
                for _,v in pairs(equal(box_id, true, param2)) do table.insert(new, v) end
                table.sort(new)
                box[box_id] = new
                observed[box_id].first_multiple = true
            elseif get_id(zone_id,'success') == message_id or get_id(zone_id,'failure') == message_id then
                box[box_id] = nil
            elseif get_id(zone_id,'tool_failure') == message_id then
                observed[box_id].thief_tools_active = false
            end
        elseif id == 0x34 then
            local box_id = original:unpack('I', 5)
            if windower.ffxi.get_mob_by_id(box_id).name == 'Treasure Casket' then
                local chances = original:byte(9)
                if box[box_id] == nil then
                    box[box_id] = table.copy(default)
                    observed[box_id] = table.copy(observed_default)
                end
                if chances > 0 and chances < 7 then
                    display(box_id, chances)
                end
            end
        elseif id == 0x5B then
            box[original:unpack('I', 17)] = nil
            observed[original:unpack('I', 17)] = nil
        end
    end
end

function watch_for_keys(id, original, modified, injected, blocked)
    if blocked then
    elseif (id == 0x036 or id == 0x037) and
        windower.ffxi.get_mob_by_id(modified:unpack('I',0x05)).name == 'Treasure Casket' and
        (windower.ffxi.get_player().main_job == 'THF' or windower.ffxi.get_player().sub_job == 'THF') then
        
        local box_id = modified:unpack('I',0x05)
        if not box[box_id] then
            box[box_id] = table.copy(default)
            observed[box_id] = table.copy(observed_default)
        end
        
        if id == 0x037 and thief_tools[windower.ffxi.get_items(modified:byte(0x11))[modified:byte(0xF)].id] then
            observed[box_id].thief_tools_active = true
        elseif id == 0x036 then
            for i = 1,9 do
                if thief_tools[windower.ffxi.get_items(0)[modified:byte(0x30+i)].id] then
                    observed[box_id].thief_tools_active = true
                    break
                end
            end
        end
    end
end

-- register event callbacks

windower.register_event('incoming chunk', check_incoming_chunk)

windower.register_event('outgoing chunk', watch_for_keys)
