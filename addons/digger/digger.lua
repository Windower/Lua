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

_addon.name = 'digger'
_addon.version = '2.2.0'
_addon.command = 'digger'
_addon.author = 'Seth VanHeulen (Acacia@Odin)'

-- modules

config = require('config')
require('pack')

-- default settings

defaults = {}
defaults.delay = {}
defaults.delay.area = 60
defaults.delay.lag = 3
defaults.delay.dig = 15
defaults.fatigue = {}
defaults.fatigue.date = os.date('!%Y-%m-%d', os.time() + 32400)
defaults.fatigue.items = 0
defaults.fatigue.diff = 0
defaults.fatigue.free = 0
defaults.accuracy = {}
defaults.accuracy.failed = 0
defaults.accuracy.total = 0

settings = config.load(defaults)

-- load message constants

require('messages')

-- buff helper function

function get_chocobo_buff()
    for _,buff_id in pairs(windower.ffxi.get_player().buffs) do
        if buff_id == 252 then
            return true
        end
    end
    return false
end

-- inventory helper function

function get_gysahl_count()
    local count = 0
    for _,item in pairs(windower.ffxi.get_items(0)) do
        if type(item) == 'table' and item.id == 4545 and item.status == 0 then
            count = count + item.count
        end
    end
    return count
end

-- stats helper functions

function update_day()
    local today = os.date('!%Y-%m-%d', os.time() + 32400)
    if settings.fatigue.date ~= today then
        settings.fatigue.date = today
        settings.fatigue.items = 0
        settings.fatigue.free = 0
        settings.fatigue.diff = settings.accuracy.failed - settings.accuracy.total
    end
end

function display_stats()
    local accuracy = 0
    local successful = settings.accuracy.total - settings.accuracy.failed
    if settings.accuracy.total > 0 then
        accuracy = (successful / settings.accuracy.total) * 100
    end
    windower.add_to_chat(207, 'dig accuracy: %d%% (%d/%d), fatigue today: %d, items today: %d gysahl greens remaining: %d':format(accuracy, successful, settings.accuracy.total, successful - settings.fatigue.free + settings.fatigue.diff, settings.fatigue.items, get_gysahl_count()))
end

function update_stats(mode)
    update_day()
    if mode == 3 then
        settings.fatigue.free = settings.fatigue.free + 1
    elseif mode == 2 then
        settings.fatigue.items = settings.fatigue.items + 1
        display_stats()
    elseif mode == 1 then
        settings.accuracy.total = settings.accuracy.total + 1
    else
        settings.accuracy.failed = settings.accuracy.failed + 1
        display_stats()
    end
    settings:save()
end

-- event callback functions

function check_zone_change(new_zone_id, old_zone_id)
    if messages[new_zone_id] then
        windower.send_command('timers c "Chocobo Area Delay" %d down':format(settings.delay.area + settings.delay.lag))
    else
        windower.send_command('timers d "Chocobo Area Delay"')
    end
    windower.send_command('timers d "Chocobo Dig Delay"')
end

function check_incoming_chunk(id, original, modified, injected, blocked)
    local zone_id = windower.ffxi.get_info().zone
    if messages[zone_id] then
        if id == 0x2A then
            local message_id = original:unpack('H', 27) % 0x8000
            if (messages[zone_id].full == message_id or messages[zone_id].success == message_id or messages[zone_id].points == message_id or messages[zone_id].standing == message_id or messages[zone_id].notes == message_id or messages[zone_id].bayld == message_id) and get_chocobo_buff() then
                update_stats(2)
            elseif messages[zone_id].ease == message_id then
                update_stats(3)
            end
        elseif id == 0x2F and windower.ffxi.get_player().id == original:unpack('I', 5) then
            if settings.delay.dig > 0 then
                windower.send_command('timers c "Chocobo Dig Delay" %d down':format(settings.delay.dig))
            end
            update_stats(1)
        elseif id == 0x36 then
            local message_id = original:unpack('H', 11) % 0x8000
            if messages[zone_id].fail == message_id then
                update_stats(0)
            end
        end
    end
end

function digger_command(...)
    local arg = {...}
    if #arg == 1 and arg[1]:lower() == 'stats' then
        update_day()
        display_stats()
    elseif #arg == 2 and arg[1]:lower() == 'stats' and arg[2]:lower() == 'clear' then
        update_day()
        settings.fatigue.diff = settings.accuracy.total - settings.accuracy.failed + settings.fatigue.diff
        settings.accuracy.failed = 0
        settings.accuracy.total = 0
        settings:save()
        windower.add_to_chat(204, 'reset dig accuracy statistics')
    elseif #arg == 2 and arg[1]:lower() == 'rank' then
        local rank = arg[2]:lower()
        if rank == 'amateur' or rank == 'a60' then
            settings.delay.area = 60
            settings.delay.dig = 15
        elseif rank == 'recruit' or rank == 'a55' then
            settings.delay.area = 55
            settings.delay.dig = 10
        elseif rank == 'initiate' or rank == 'a50' then
            settings.delay.area = 50
            settings.delay.dig = 5
        elseif rank == 'novice' or rank == 'a45' then
            settings.delay.area = 45
            settings.delay.dig = 0
        elseif rank == 'apprentice' or rank == 'a40' then
            settings.delay.area = 40
            settings.delay.dig = 0
        elseif rank == 'journeyman' or rank == 'a35' then
            settings.delay.area = 35
            settings.delay.dig = 0
        elseif rank == 'craftsman' or rank == 'a30' then
            settings.delay.area = 30
            settings.delay.dig = 0
        elseif rank == 'artisan' or rank == 'a25' then
            settings.delay.area = 25
            settings.delay.dig = 0
        elseif rank == 'adept' or rank == 'a20' then
            settings.delay.area = 20
            settings.delay.dig = 0
        elseif rank == 'veteran' or rank == 'a15' then
            settings.delay.area = 15
            settings.delay.dig = 0
        elseif rank == 'expert' or rank == 'a10' then
            settings.delay.area = 10
            settings.delay.dig = 0
        else
            windower.add_to_chat(167, 'invalid digging rank')
            return
        end
        windower.add_to_chat(204, 'digging rank: %s, area delay: %d seconds, dig delay: %d seconds':format(rank, settings.delay.area, settings.delay.dig))
        settings:save()
    else
        windower.add_to_chat(167, 'usage:')
        windower.add_to_chat(167, '  digger rank <crafting rank>')
        windower.add_to_chat(167, '  digger stats [clear]')
    end
end

-- register event callbacks

windower.register_event('zone change', check_zone_change)
windower.register_event('incoming chunk', check_incoming_chunk)
windower.register_event('addon command', digger_command)
