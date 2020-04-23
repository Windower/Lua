_addon.author = 'Banggugyangu'
_addon.version = '3.0.0'
_addon.commands = {'autora', 'ara'}

require('functions')
local config = require('config')

local defaults = {
    HaltOnTp = true,
    Delay = 1.5
}

local settings = config.load(defaults)

local auto = false
local player_id

windower.send_command('bind ^d ara start')
windower.send_command('bind !d ara stop')

local shoot = function()
    windower.send_command('input /shoot <t>')
end

local start = function()
    auto = true
    windower.add_to_chat(17, 'AutoRA  STARTING~~~~~~~~~~~~~~')

    shoot()
end

local stop = function()
    auto = false
    windower.add_to_chat(17, 'AutoRA  STOPPING ~~~~~~~~~~~~~~')
end

local haltontp = function()
    settings.HaltOnTp = not settings.HaltOnTp

    if settings.HaltOnTp then
        windower.add_to_chat(17, 'AutoRA will halt upon reaching 1000 TP')
    else
        windower.add_to_chat(17, 'AutoRA will no longer halt upon reaching 1000 TP')
    end
end

local check = function()
    if not auto then
        return
    end

    local player = windower.ffxi.get_player()
    if not player or not player.target_index then
        return
    end

    if player.vitals.tp >= 1000 and settings.HaltOnTp then
        auto = false
        windower.add_to_chat(17, 'AutoRA  HALTING AT 1000 TP ~~~~~~~~~~~~~~')
    elseif player.status == 1 then
        shoot()
    end
end

windower.register_event('action', function(action)
    if auto and action.actor_id == player_id and action.category == 2 then
        check:schedule(settings.Delay)
    end
end)

windower.register_event('addon command', function(command)
    command = command and command:lower() or 'help'

    if command == 'start' then
        start()
    elseif command == 'stop' then
        stop()
    elseif command == 'shoot' then
        shoot()
    elseif command == 'reload' then
        setDelay()
    elseif command == 'haltontp' then
        haltontp()
    elseif command == 'help' then
        windower.add_to_chat(17, 'AutoRA  v' .. _addon.version .. 'commands:')
        windower.add_to_chat(17, '//ara [options]')
        windower.add_to_chat(17, '    start      - Starts auto attack with ranged weapon')
        windower.add_to_chat(17, '    stop       - Stops auto attack with ranged weapon')
        windower.add_to_chat(17, '    haltontp    - Toggles automatic halt upon reaching 1000 TP')
        windower.add_to_chat(17, '    help       - Displays this help text')
        windower.add_to_chat(17, ' ')
        windower.add_to_chat(17, 'AutoRA will only automate ranged attacks if your status is "Engaged".  Otherwise it will always fire a single ranged attack.')
        windower.add_to_chat(17, 'To start auto ranged attacks without commands use the key:  Ctrl+D')
        windower.add_to_chat(17, 'To stop auto ranged attacks in the same manner:  Atl+D')
    end
end)

windower.register_event('load', 'login', 'logout', function()
    local player = windower.ffxi.get_player()
    player_id = player and player.id
end)

--Copyright © 2013, Banggugyangu
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
