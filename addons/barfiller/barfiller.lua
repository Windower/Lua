--[[    BSD License Disclaimer
        Copyright © 2015, Morath86
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of BarFiller nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL Morath86 BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'BarFiller'
_addon.author = 'Morath'
_addon.version = '0.2.4'
_addon.commands = {'bf','barfiller'}
_addon.language = 'english'

-- Windower Libs
config = require('config')
file = require('files')
packets = require('packets')
texts = require('texts')
images = require('images')

-- BarFiller Libs
require('statics')

-- Generate Settings Fi]les
-- Thanks to Byrth & SnickySnacks' BattleMod addon
settings = config.load(default_settings)
config.save(settings)

background_bar = images.new(settings.Images.Background)
foreground_bar = images.new(settings.Images.Foreground)
rested_bonus   = images.new(settings.Images.RestedBonus)

box = texts.new(settings.ExpText)

debug = false
ready = false
chunk_update = false

-- Make sure character is logged in, and loaded before initializing
windower.register_event('load',function()
    if windower.ffxi.get_info().logged_in then
        initialize() -- Populate character details
    end
end)

windower.register_event('login',function()
    initialize()
end)

-- If you're switching characters this will clear the previous characters stats
windower.register_event('logout',function()
    hide()
end)

-- Addon commands
-- Thanks to Byrth & SnickySnacks' BattleMod addon
windower.register_event('addon command',function(command, ...)
    local commands = {...}
    local first_cmd = (command or 'help'):lower()
    if approved_commands[first_cmd] and #commands >= approved_commands[first_cmd].n then
        if first_cmd == 'clear' or first_cmd == 'c' then        -- Reset EXP bar to 0
            initialize()
        elseif first_cmd == 'reload' or first_cmd == 'r' then   -- Reloads BarFiller
            windower.add_to_chat(8,'BarFiller successfully reloaded.')
            windower.send_command('lua r barfiller;')
        elseif first_cmd == 'unload' or first_cmd == 'u' then   -- Unloads BarFiller
            windower.send_command('lua u barfiller;')
            windower.add_to_chat(8,'BarFiller successfully unloaded.')
        elseif first_cmd == 'help' or first_cmd == 'h' then     -- Display helpful information
            help()
        end
    else
        help()
    end
end)

-- Capture XP Values
-- Thanks to smd111 for Packet parsing
windower.register_event('incoming chunk',function(id,org,modi,is_injected,is_blocked)
    if is_injected then return end
    if ready then
        local packet_table = packets.parse('incoming', org)
        if id == 0x2D then
            exp_msg(packet_table['Param 1'],packet_table['Message'])
        elseif id == 0x61 then
            xp.current = packet_table['Current EXP']
            xp.total = packet_table['Required EXP']
            xp.tnl = xp.total - xp.current
            chunk_update = true
        end
    end
end)

-- Update the XP bar size
-- Thanks to Iryoku for the logic on smooth animations
windower.register_event('prerender',function()
    if ready then
        if chunk_update then
            local old_width = foreground_bar:width()
            local new_width = calc_new_width()

            if new_width ~= nil and new_width > 0 then
                if old_width < new_width then
                    local last_update = 0
                    local x = old_width + math.ceil(((new_width - old_width) * 0.1))
                    if debug then print(old_width, x, new_width) end -- Debug statement
                    foreground_bar:size(x, fg_height)

                    local now = os.clock()
                    if now - last_update > 0.5 then
                        update_strings()
                        last_update = now
                    end
                elseif old_width >= new_width then
                    foreground_bar:size(new_width, fg_height)
                    chunk_update = false
                    if debug then print(chunk_update) end -- Debug statement
                end
            end
        end
    end
end)

windower.register_event('level up', function(level)
    update_strings()
end)

windower.register_event('level down', function(level)
    update_strings()
end)

windower.register_event('zone change', function(new_id,old_id)
    mog_house()
end)
