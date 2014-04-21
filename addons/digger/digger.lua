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
_addon.version = '1.3.5'
_addon.command = 'digger'
_addon.author = 'Seth VanHeulen (Acacia@Odin)'

-- modules

config = require('config')
require('pack')
require('sets')

-- default settings

defaults = {}
defaults.delay = {}
defaults.delay.area = 60
defaults.delay.lag = 3
defaults.delay.dig = 15
defaults.fatigue = {}
defaults.fatigue.date = os.date('!%Y-%m-%d', os.time() + 32400)
defaults.fatigue.remaining = 100
defaults.accuracy = {}
defaults.accuracy.successful = 0
defaults.accuracy.total = 0

settings = config.load(defaults)

-- global constants

fail_message = S{7208, 7250, 7227, 7536, 7194, 7682, 7198, 7256, 7216, 7035}
success_message = S{6379, 6393, 6406, 6552, 7377, 7692, 7717}
ease_message = S{7283, 7325, 7302, 7611, 7269, 7757, 7273, 7331, 7291, 7110}
chocobo_zone = S{2, 4, 51, 52, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 114, 115, 116, 117, 118, 119, 120, 121, 123, 124, 125}

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
    for _,item in pairs(windower.ffxi.get_items().inventory) do
        if item.id == 4545 and item.status == 0 then
            count = count + item.count
        end
    end
    return count
end

-- stats helper functions

function update_stats(count)
    local today = os.date('!%Y-%m-%d', os.time() + 32400)
    if settings.fatigue.date ~= today then
        settings.fatigue.date = today
        settings.fatigue.remaining = 100
    end
    if count < 1 then
        settings.accuracy.total = settings.accuracy.total + 1
    end
    if count < 0 then
        settings.accuracy.successful = settings.accuracy.successful + 1
    end
    settings.fatigue.remaining = settings.fatigue.remaining + count
    settings:save()
end

function display_stats()
    local accuracy = (settings.accuracy.successful / settings.accuracy.total) * 100
    windower.add_to_chat(207, 'dig accuracy: %d%% (%d/%d), items until fatigued: %d, gysahl greens remaining: %d':format(accuracy, settings.accuracy.successful, settings.accuracy.total, settings.fatigue.remaining, get_gysahl_count()))
end

-- event callback functions

function check_zone_change(new_zone_id, old_zone_id)
    if chocobo_zone:contains(new_zone_id) then
        windower.send_command('timers c "Chocobo Area Delay" %d down':format(settings.delay.area + settings.delay.lag))
    else
        windower.send_command('timers d "Chocobo Area Delay"')
    end
    windower.send_command('timers d "Chocobo Dig Delay"')
end

function check_incoming_chunk(id, original, modified, injected, blocked)
    if id == 0x2A and windower.ffxi.get_player().id == original:unpack('I', 5) then
        local message_id = original:unpack('H', 27) % 0x8000
        if success_message:contains(message_id) and get_chocobo_buff() then
            update_stats(-1)
            display_stats()
        elseif ease_message:contains(message_id) then
            update_stats(1)
        end
    elseif id == 0x2F and settings.delay.dig > 0 and windower.ffxi.get_player().id == original:unpack('I', 5) then
        windower.send_command('timers c "Chocobo Dig Delay" %d down':format(settings.delay.dig))
    elseif id == 0x36 and windower.ffxi.get_player().id == original:unpack('I', 5) then
        local message_id = original:unpack('H', 11) % 0x8000
        if fail_message:contains(message_id) then
            update_stats(0)
            display_stats()
        end
    end
end

function digger_command(...)
    local arg = {...}
    if #arg == 1 and arg[1]:lower() == 'reset' then
        windower.add_to_chat(200, 'resetting dig accuracy statistics')
        settings.accuracy.successful = 0
        settings.accuracy.total = 0
        settings:save()
    elseif #arg == 2 and arg[1]:lower() == 'rank' then
        local rank = arg[2]:lower()
        if rank == 'amateur' then
            settings.delay.area = 60
            settings.delay.dig = 15
        elseif rank == 'recruit' then
            settings.delay.area = 55
            settings.delay.dig = 10
        elseif rank == 'initiate' then
            settings.delay.area = 50
            settings.delay.dig = 5
        elseif rank == 'novice' then
            settings.delay.area = 45
            settings.delay.dig = 0
        elseif rank == 'apprentice' then
            settings.delay.area = 40
            settings.delay.dig = 0
        elseif rank == 'journeyman' then
            settings.delay.area = 35
            settings.delay.dig = 0
        elseif rank == 'craftsman' then
            settings.delay.area = 30
            settings.delay.dig = 0
        elseif rank == 'artisan' then
            settings.delay.area = 25
            settings.delay.dig = 0
        elseif rank == 'adept' then
            settings.delay.area = 20
            settings.delay.dig = 0
        elseif rank == 'veteran' then
            settings.delay.area = 15
            settings.delay.dig = 0
        elseif rank == 'expert' then
            settings.delay.area = 10
            settings.delay.dig = 0
        else
            windower.add_to_chat(167, 'invalid digging rank: %s':format(rank))
            return
        end
        windower.add_to_chat(200, 'setting digging rank to %s: area delay = %d seconds, dig delay = %d seconds':format(rank, settings.delay.area, settings.delay.dig))
        settings:save()
    else
        windower.add_to_chat(167, 'usage: digger rank <crafting rank>')
        windower.add_to_chat(167, '        digger reset')
    end
end

-- register event callbacks

windower.register_event('zone change', check_zone_change)
windower.register_event('incoming chunk', check_incoming_chunk)
windower.register_event('addon command', digger_command)
