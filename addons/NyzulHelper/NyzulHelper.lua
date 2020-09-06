--[[
Copyright © 2020, Glarin of Asura
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of NyzulHelper nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Glarin BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
]]

_addon.name = 'NyzulHelper'
_addon.author = 'Glarin'
_addon.version = '1.0'
_addon.commands = {'nh', 'nyzulhelper'}
_addon.language = 'english'

require('logger')
require('coroutine')

config = require('config')
packets = require('packets')
res = require('resources')
texts = require('texts')

defaults = {}
defaults.interval = .1

settings = config.load(defaults)
box = texts.new('${current_string}', settings)

pending_color = '\\cs(255,250,120)'
warning_color = '\\cs(255,165,0)'
good_color = '\\cs(0,255,0)'
bad_color = '\\cs(255,0,0)'

frame_time = 0
zone_timer = 0
end_time = nil
has_armband = false
party_size = 1
objective = ''
floor_clear = pending_color
restriction = ''
restriction_failed = warning_color
starting_floor = 0
current_floor = 0
completed = 0
floor_penalities = 0
potential_tokens = 0


-- Handle addon args
windower.register_event('addon command', function(input, ...)

    local cmd = input and input:lower() or 'help'
    local args = {...}

    if cmd == 'reset' then
        reset()
    elseif cmd == 'show' then
        box:show()
    elseif cmd == 'hide' then
        box:hide()        
    elseif cmd == 'reload' then
        windower.send_command('lua reload nyzulhelper')
    elseif cmd == 'help' then
        windower.add_to_chat(167, 'Commands:')
        windower.add_to_chat(167, '  nyzulhelper reset')
        windower.add_to_chat(167, '  nyzulhelper show')
        windower.add_to_chat(167, '  nyzulhelper hide')
        windower.add_to_chat(167, '  nyzulhelper reload')
    else
        log(cmd..' command unknown.')
    end

end)

-- Event Handlers
windower.register_event('load', function()
    
    local info = windower.ffxi.get_info()
    if info.logged_in and info.zone == 77 then 
        box:show() 
    end

end)

windower.register_event('prerender', function()

    local curr = os.clock()
    if curr > frame_time + settings.interval then
        if end_time ~= nil and zone_timer >= 1 and zone_timer ~= (end_time - os.time()) then
            zone_timer = end_time - os.time()
        end
        
        frame_time = curr
        update_box()
    end

end)

windower.register_event('zone change',function(new, old)

    box:hide()
    
    if new == 72 and old == 77 then
        zone_timer = 0
        has_armband = false
    else    
        reset()
    end
    
    if new == 77 then
        box:show()
        party_size = windower.ffxi.get_party_info().party1_count
    end
    
end)

windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)

    if id == 0x55 and windower.ffxi.get_info().zone == 72 and has_value(windower.ffxi.get_key_items(), 797) then
        has_armband = true
    end
    
end)

windower.register_event('incoming text', function(original, modified, mode, _, blocked)

    local info = windower.ffxi.get_info()
    if not info.logged_in or info.zone ~= 77 or blocked or original == '' then
        return
    end

    if mode == 123 then
    
        if string.find(original, 'Security field malfunction') then
            restriction = string.strip_format(original)
            restriction_failed = bad_color
            update_box()
        elseif string.find(original, 'Time limit has been reduced') then
            set_timer(zone_timer - tonumber(original:match('%d+')) * 60)
        elseif string.find(original, 'Potential token reward reduced') then
            floor_penalities = floor_penalities + 1
        end

    elseif (mode == 146 or mode == 148) and string.find(original, '(Earth time)') then
    
        local multiplier = 1
        if string.find(original, 'minute') then multiplier = 60 end
    
        set_timer(tonumber(original:match('%d+')) * multiplier)    
        
    elseif mode == 146 then
    
        if string.find(original,'Floor %d+ objective complete. Rune of Transfer activated.') then
            completed = completed + 1
            floor_clear = good_color
            restriction = ''
            restriction_failed = warning_color
            calculate_tokens()
            update_box()
        end
        
    elseif mode == 148 then
    
        if string.find(original,'Objective:') then
            if string.find(original,'Commencing') then
                objective = 'Complete on-site objectives'
            else
                objective = string.strip_format(original:sub(11))
            end
            floor_clear = pending_color
        elseif string.find(original, 'archaic') then
            restriction = string.strip_format(original)
        elseif string.find(original,'Transfer complete. Welcome to Floor %d+.') then
            current_floor = tonumber(original:match('%d+'))
            resync_values()
        end
        
    end
    
end)

function reset()

    zone_timer = 0
    end_time = nil
    objective = ''
    floor_clear = pending_color
    restriction = ''
    restriction_failed = warning_color
    starting_floor = 0
    current_floor = 0
    completed = 0
    floor_penalities = 0
    potential_tokens = 0

end

function has_value(list, value)

    if list ~= nil and value ~= nil then
        for _,    v in pairs(list) do
            if v == value then
                return true
            end
        end
    end

    return false

end

function set_timer(remaining)

    zone_timer = remaining
    end_time = os.time() + zone_timer
        
end

function get_relative_floor()

    if current_floor < starting_floor then 
        return current_floor + 100
    end
    
    return current_floor

end

function get_token_rate()
    
    local rate = 1
    if has_armband then 
        rate = rate + .1 
    end
    
    if party_size > 3 then 
        rate = rate - ((party_size - 3 ) * .1) 
    end
    
    return rate
    
end

function resync_values()

    if starting_floor == 0 then 
        starting_floor = current_floor
        if zone_timer == 0 then 
            set_timer(1800) 
        end
    end
    
    local relative_floor = get_relative_floor()
    if (relative_floor - starting_floor) > completed then
        completed = relative_floor - starting_floor
    end
    
    floor_penalities = 0

end

function get_token_penalty(rate)

    return math.round(117 * rate) * floor_penalities

end

function calculate_tokens()
    
    local relative_floor = get_relative_floor()
    local rate = get_token_rate()
    
    local floor_bonus = 0
    if relative_floor > 1 then 
        floor_bonus = (10 * math.floor((relative_floor - 1) / 5)) 
    end
    
    potential_tokens = potential_tokens + ((200 + floor_bonus) * rate) - get_token_penalty(rate)
    
end

function update_box()

    local timer_color = ''
    if zone_timer < 60 then 
        timer_color = bad_color 
    end
    
    local lines = L{}
    lines:append(' Current Floor:                 '..current_floor)
    lines:append('\n Time Remaining:            '..timer_color..os.date('%M:%S', zone_timer)..'\\cr ')
    lines:append('\n Objective:    '..floor_clear..objective..'\\cr ')
    if restriction ~= '' then
        lines:append(' Restriction:  '..restriction_failed..restriction..'\\cr ')
    end
    lines:append('\n Floors Completed:          '..completed)
    lines:append(' Reward Rate:                 %d%%':format(get_token_rate() * 100))
    lines:append(' Potential Tokens:            '..potential_tokens)
        
    box.current_string = lines:concat('\n')

end
