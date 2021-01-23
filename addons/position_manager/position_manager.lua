--Copyright © 2021, Lili
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of position_manager nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL Lili BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'position_manager'
_addon.author = 'Lili'
_addon.version = '2.0.1'
_addon.command = 'pm'

if not windower.file_exists(windower.windower_path .. '\\plugins\\WinControl.dll') then
    print('position_manager: error - Please install the WinControl plugin in the launcher.')
    windower.send_command('lua u position_manager')
    return
else
    print('position_manager: loading WinControl...')
    windower.send_command('load wincontrol')
end

local config = require('config')

local default = {
    x = 0,
    y = 0,
    width = -1,
    height = -1,
    delay = 0,
}

local settings = config.load(default)

function get_name(name)
    if name ~= nil and type(name) ~= 'string' then
        err('invalid name provided')
        return false
    elseif not name then
        return windower.ffxi.get_player().name
    elseif name == ':all' then
        return 'all'
    end
    return name
end

function err(reason)
    windower.add_to_chat(207, 'position_manager: ERROR - %s.':format(err))
    show_help()
    return
end

function show_help()
    windower.add_to_chat(207, 'position_manager: Commands:')
    windower.add_to_chat(207, '  //pm set <x> <y> [name]')
    windower.add_to_chat(207, '  //pm size <width> <height> [name]')
    windower.add_to_chat(207, '  //pm delay <seconds> [name]')
    windower.add_to_chat(207, 'position_manager: See the readme for details.')
end

function move(settings)
    if settings.delay > 0 then
        coroutine.sleep(settings.delay)
    end

    windower.send_command('wincontrol move %s %s':format(settings.x, settings.y))
    --print('::wincontrol move %s %s':format(settings.x, settings.y))
end

function resize(settings)
    if settings.width == -1 and settings.height == -1 then
        windower.send_command('wincontrol resize reset')
        return
    end

    if settings.delay > 0 then
        coroutine.sleep(settings.delay)
    end

    local width = settings.width == -1 and windower.get_windower_settings().ui_x_res or settings.width
    local height = settings.height == -1 and windower.get_windower_settings().ui_y_res or settings.height

    windower.send_command('wincontrol move %s %s':format(settings.x, settings.y))
    --print('::wincontrol resize %s %s':format(width, height))
end

function handle_commands(cmd, ...)
    cmd = cmd and cmd:lower()

    if cmd == 'r' then
        windower.send_command('lua r position_manager')
        return
    elseif cmd == 'set' or cmd == 'size' then
        local arg = {...}
        local name = get_name(arg[3])

        if not name then
            return
        end

        arg[1] = arg[1] == 'default' and -1 or tonumber(arg[1])
        arg[2] = arg[2] == 'default' and -1 or tonumber(arg[2])

        if arg[1] and arg[2] then
            if cmd == 'set' then
                settings.x = arg[1]
                settings.y = arg[2]

                if settings.x and settings.y then
                    config.save(settings, name)
                    windower.add_to_chat(207, 'position_manager: Position set to %s, %s for %s.':format(settings.x, settings.y, name))
                else
                    err('invalid position provided.')
                    return false
                end
            elseif cmd == 'size' then
                settings.width = arg[1]
                settings.height = arg[2]

                if settings.width and settings.height then
                    config.save(settings, name)
                    windower.add_to_chat(207, 'position_manager: Window size set to %s, %s for %s.':format(settings.width, settings.height, name))
                else
                    err('invalid window size provided.')
                    return false
                end
            end
        else
            err('invalid arguments provided.')
            return false
        end

        if player_name and name:lower() == player_name:lower() then
            if cmd == 'set' then
                move(settings)
            elseif cmd == 'size' then
                resize(settings)
            end
        end

        windower.send_ipc_message(name)
        return true

    elseif cmd == 'delay' then
        settings.delay = tonumber(arg[2])

        if settings.delay > 0 then
            config.save(settings, name)
            windower.add_to_chat(207, 'position_manager: Delay set to %s for %s.':format(settings.delay, name))
        else
            err('invalid delay provided')
            return false
        end
        return true

    elseif cmd ~= 'help' then
        windower.add_to_chat(207, 'position_manager: %s command not found.':format(cmd))
    end
    show_help()
end

config.register(settings, move)
config.register(settings, resize)

windower.register_event('addon command', handle_commands)

windower.register_event('load','login','logout', function(name)
    local player = windower.ffxi.get_player()
    player_name = player and player.name
end)

windower.register_event('ipc message', function(msg)
    if msg == player_name or msg == 'all' then
        config.reload(settings)
    end
end)
