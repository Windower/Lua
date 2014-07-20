--[[
plasmon v1.20140530

Copyright (c) 2013, Giuliano Riccio
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of plasmon nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Giuliano Riccio BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

require('logger')
config = require('config')

_addon.name    = 'plasmon'
_addon.author  = 'Zohno'
_addon.version = '1.20140530'
_addon.command = 'plasmon'

tb_name       = 'addon:gr:plasmon'
track         = false
visible       = false
recovery_mode = false

stats                = T{}
stats.plasm          = 0
stats.tot_plasm      = 0
stats.mobs           = 0
stats.tot_mobs       = 0
stats.airlixirs      = 0
stats.tot_airlixirs  = 0
stats.airlixirs1     = 0
stats.tot_airlixirs1 = 0
stats.airlixirs2     = 0
stats.tot_airlixirs2 = 0

defaults = T{}
defaults.light     = false
defaults.timer     = true

defaults.position = T{}
defaults.position.x = 0
defaults.position.y = 350

defaults.font = T{}
defaults.font.family = 'Arial'
defaults.font.size   = 10
defaults.font.a      = 255
defaults.font.bold   = false
defaults.font.italic = false

defaults.colors = T{}
defaults.colors.background = T{}
defaults.colors.background.r = 0
defaults.colors.background.g = 43
defaults.colors.background.b = 54
defaults.colors.background.a = 200

defaults.colors.delve = T{}
defaults.colors.delve.title = T{}
defaults.colors.delve.title.r = 220
defaults.colors.delve.title.g = 50
defaults.colors.delve.title.b = 47

defaults.colors.delve.label = T{}
defaults.colors.delve.label.r = 38
defaults.colors.delve.label.g = 139
defaults.colors.delve.label.b = 210

defaults.colors.delve.value = T{}
defaults.colors.delve.value.r = 147
defaults.colors.delve.value.g = 161
defaults.colors.delve.value.b = 161

defaults.colors.airlixir = T{}
defaults.colors.airlixir.title = T{}
defaults.colors.airlixir.title.r = 220
defaults.colors.airlixir.title.g = 50
defaults.colors.airlixir.title.b = 47

defaults.colors.airlixir.label = T{}
defaults.colors.airlixir.label.r = 42
defaults.colors.airlixir.label.g = 161
defaults.colors.airlixir.label.b = 152

defaults.colors.airlixir.value = T{}
defaults.colors.airlixir.value.r = 147
defaults.colors.airlixir.value.g = 161
defaults.colors.airlixir.value.b = 161

settings = config.load(defaults)

-- plugin functions

function parse_options(args)
    local options = T{}

    while #args > 0 do
        if not args[1]:match('^-%a') then
            break
        end

        local option = args:remove(1):sub(2)

        if args[1] ~= nil and not args[1]:match('^-%a') then
            options[option] = args:remove(1)
        else
            options[option] = true
        end
    end

    return options
end

function test()
    windower.add_to_chat(148, 'Now permeating the mists surrounding the fracture.')
    windower.add_to_chat(148, 'You receive 50 corpuscles of mweya plasm.')
    windower.add_to_chat(121, 'You find an airlixir on the Mob')
    windower.add_to_chat(148, 'You receive 50 corpuscles of mweya plasm.')
    windower.add_to_chat(148, 'You receive 50 corpuscles of mweya plasm.')
    windower.add_to_chat(148, 'You receive 150 corpuscles of mweya plasm.')
    windower.add_to_chat(148, 'You receive 50 corpuscles of mweya plasm.')
    windower.add_to_chat(121, 'You find an airlixir on the Mob')
    windower.add_to_chat(148, 'You receive 500 corpuscles of mweya plasm.')
    windower.add_to_chat(121, 'You find an airlixir on the Mob')
    windower.add_to_chat(121, 'You find an airlixir on the Mob')
    windower.add_to_chat(121, 'You find an airlixir on the Mob')
    windower.add_to_chat(121, 'You find an airlixir on the Mob')
    windower.add_to_chat(121, 'You find an airlixir +1 on the Mob')
    windower.add_to_chat(121, 'You find an airlixir +2 on the Mob')
    windower.add_to_chat(146, 'Your time has expired for this battle. Now exiting...')
    show_window()
end

function start_tracking()
    reset_stats()
    log('The Delve has begun!')
    start_timer()

    track = true

    if recovery_mode then
        recovery_mode = false
    end

    if settings.light == false then
        show_window()
    end
end

function stop_tracking()
    stats.scores  = T{}
    stats.bonuses = T{}
    track         = false

    log('The Delve has ended.')
    stop_timer()
    hide_window()
    show_report()
end

function start_timer()
    windower.send_command('timers create Delve 2700 down ../../../addons/plasmon/icon')
end

function stop_timer()
    windower.send_command('timers delete Delve')
end

function refresh_window()
    if visible == false then
        return
    end

    local delve_colors    = settings.colors.delve
    local airlixir_colors = settings.colors.airlixir
    local text            = T{
        ' \\cs('..delve_colors.title.r..', '..delve_colors.title.g..', '..delve_colors.title.b..')--== DELVE ==--\\cr \n',
        ' \\cs('..delve_colors.label.r..', '..delve_colors.label.g..', '..delve_colors.label.b..')Plasm:\\cr',
        ' \\cs('..delve_colors.value.r..', '..delve_colors.value.g..', '..delve_colors.value.b..')'..stats.plasm..'/'..stats.tot_plasm..'\\cr \n',
        ' \\cs('..delve_colors.label.r..', '..delve_colors.label.g..', '..delve_colors.label.b..')Mobs:\\cr',
        ' \\cs('..delve_colors.value.r..', '..delve_colors.value.g..', '..delve_colors.value.b..')'..stats.mobs..'/'..stats.tot_mobs..'\\cr \n',
        ' \\cs('..airlixir_colors.title.r..', '..airlixir_colors.title.g..', '..airlixir_colors.title.b..')--== AIRLIXIRS ==--\\cr \n',
        ' \\cs('..airlixir_colors.label.r..', '..airlixir_colors.label.g..', '..airlixir_colors.label.b..')Airlixir:\\cr',
        ' \\cs('..airlixir_colors.value.r..', '..airlixir_colors.value.g..', '..airlixir_colors.value.b..')'..stats.airlixirs..'/'..stats.tot_airlixirs..'\\cr \n',
        ' \\cs('..airlixir_colors.label.r..', '..airlixir_colors.label.g..', '..airlixir_colors.label.b..')Airlixir +1:\\cr',
        ' \\cs('..airlixir_colors.value.r..', '..airlixir_colors.value.g..', '..airlixir_colors.value.b..')'..stats.airlixirs1..'/'..stats.tot_airlixirs1..'\\cr \n',
        ' \\cs('..airlixir_colors.label.r..', '..airlixir_colors.label.g..', '..airlixir_colors.label.b..')Airlixir +2:\\cr',
        ' \\cs('..airlixir_colors.value.r..', '..airlixir_colors.value.g..', '..airlixir_colors.value.b..')'..stats.airlixirs2..'/'..stats.tot_airlixirs2..'\\cr'
    }

    windower.text.set_text(tb_name, text:concat(''))
end

function reset_stats()
    stats.plasm      = 0
    stats.mobs       = 0
    stats.airlixirs  = 0
    stats.airlixirs1 = 0
    stats.airlixirs2 = 0
    refresh_window()
end

function full_reset_stats()
    stats.tot_plasm      = 0
    stats.tot_mobs       = 0
    stats.tot_airlixirs  = 0
    stats.tot_airlixirs1 = 0
    stats.tot_airlixirs2 = 0
    reset_stats()
    refresh_window()
end

function show_window()
    visible = true
    windower.text.set_visibility(tb_name, true)
    refresh_window()
end

function hide_window()
    visible = false
    windower.text.set_visibility(tb_name, false)
end

function toggle_window()
    if visible then
        hide_window()
    else
        show_window()
    end
end

function show_report()
    log('[Plasm '..(stats.plasm..'/'..stats.tot_plasm):color(258)..'] [Mobs '..(stats.mobs..'/'..stats.tot_mobs):color(258)..'] [Airlixir '..(stats.airlixirs..'/'..stats.tot_airlixirs):color(258)..' | +1 '..(stats.airlixirs1..'/'..stats.tot_airlixirs1):color(258)..' | +2 '..(stats.airlixirs2..'/'..stats.tot_airlixirs2):color(258)..']')
end

function initialize()
    local background = settings.colors.background

    windower.text.create(tb_name)
    windower.text.set_location(tb_name, settings.position.x, settings.position.y)
    windower.text.set_bg_color(tb_name, background.a, background.r, background.g, background.b)
    windower.text.set_color(tb_name, settings.font.a, 147, 161, 161)
    windower.text.set_font(tb_name, settings.font.family)
    windower.text.set_font_size(tb_name, settings.font.size)
    windower.text.set_bold(tb_name, settings.font.bold)
    windower.text.set_italic(tb_name, settings.font.italic)
    windower.text.set_text(tb_name, '')
    windower.text.set_bg_visibility(tb_name, true)

    if windower.ffxi.get_info().zone == 271 or windower.ffxi.get_info().zone == 264 then
        recovery_mode = true
    end
end

function dispose()
    windower.text.delete(tb_name)
    windower.send_command('timers delete Delve')
end

-- windower events

windower.register_event('load', initialize:cond(function() return windower.ffxi.get_info().logged_in end))

windower.register_event('login', initialize)

windower.register_event('logout', 'unload', dispose)

windower.register_event('zone change', stop_tracking:cond(function(_,id) return (id == 271 or id == 264) and track end))

windower.register_event('incoming text', function(original, modified, mode)
    local match

    original = original:strip_format()

    if track or recovery_mode then
        if mode == 148 then
            match = original:match('You receive (%d+) corpuscles of mweya plasm%.')

            if match then
                if recovery_mode then
                    start_tracking()
                end

                match           = tonumber(match)
                stats.plasm     = stats.plasm + match
                stats.tot_plasm = stats.tot_plasm + match

                if match % 50 == 0 and match % 500 ~= 0 and match % 750 ~= 0 and match % 10000 ~= 0 then
                    mobs = match / 50
                else
                    mobs = 1
                end

                stats.mobs     = stats.mobs + mobs
                stats.tot_mobs = stats.tot_mobs + mobs
                refresh_window()

                return modified, mode
            end
        elseif mode == 121 then
            match = original:match('You find an airlixir %+1')

            if match then
                if recovery_mode then
                    start_tracking()
                end

                stats.airlixirs1    = stats.airlixirs1 + 1
                stats.tot_airlixirs1 = stats.tot_airlixirs1 + 1
                refresh_window()

                return modified, mode
            end

            match = original:match('You find an airlixir %+2')

            if match then
                if recovery_mode then
                    start_tracking()
                end

                stats.airlixirs2     = stats.airlixirs2 + 1
                stats.tot_airlixirs2 = stats.tot_airlixirs2 + 1
                refresh_window()

                return modified, mode
            end

            match = original:match('You find an airlixir')

            if match then
                if recovery_mode then
                    start_tracking()
                end

                stats.airlixirs     = stats.airlixirs + 1
                stats.tot_airlixirs = stats.tot_airlixirs + 1
                refresh_window()

                return modified, mode
            end
        elseif mode == 146 then
            match = original:match('Your time has expired for this battle%. Now exiting%.%.%.')

            if match then
                stop_tracking()

                return modified, mode
            end
        end
    elseif mode > 20 then
    --mode == 148 or mode == 151 then
        --old zones
        match = original:match('Now permeating the mists surrounding the fracture%.')
        if match then
            start_tracking()

            return modified, mode
        end

        --new zones
        match = original:match('Now permeating the mists surrounding the obscured domain%.')
        if match then
            start_tracking()

            return modified, mode
        end
    end

    return modified, mode
end)

windower.register_event('addon command', function(...)
    local args = T({...})

    if args[1] == nil then
        windower.send_command('plasmon help')
        return
    end

    local cmd = args:remove(1):lower()

    if cmd == 'help' then
        log('    help -- shows the help text.')
        log('    test -- fills the chat log with some messages to show how the plugin will work.')
        log('    reset -- sets current gained plasm, monster kill count and dropped airlixirs to 0.')
        log('    full-reset --  sets both current and total gained plasm, monster kill count and dropped airlixirs to 0.')
        log('    show -- shows the tracking window.')
        log('    hide -- hides the tracking window.')
        log('    toggle -- toggles the tracking window\'s visibility.')
        log('    light [<enabled>] -- enables or disables light mode. When enabled, the addon will never show the window and just print a summary in the chat box at the end of the run. If the enabled parameter is not specified, the help text will be shown.')
        log('    timer [<enabled>] -- enables or disables the timer. When enabled, the addon will start a 45 minutes timer when entering a fracture. If the enabled parameter is not specified, the help text will be shown.')
        log('    position [[-h]|[-x <x>] [-y <y>]] -- sets the horizontal and vertical position of the window relative to the upper-left corner. If no parameter is specified, the help text will be shown.')
        log('    font [[-h]|[-f <font>] [-s <size>] [-a <alpha>] [-b [<bold>]] [-i [<italic>]]] -- sets the style of the font used in the window. If the no parameter is specified, the help text will be shown.')
        log('    color [[-h]|[-o <objects>] [-d] [-r <red>] [-g <green>] [-b <blue>] [-a <alpha>]] -- sets the colors of the various elements present in the addon\'s window. If no parameter is specified, the help text will be shown.')
    elseif cmd == 'test' then
        test()
    elseif cmd == 'reset' then
        reset_stats()
    elseif cmd == 'full-reset' then
        full_reset_stats()
    elseif cmd == 'show' then
        show_window()
    elseif cmd == 'hide' then
        hide_window()
    elseif cmd == 'toggle' then
        toggle_window()
    elseif cmd == 'light' then
        if type(args[1]) == 'nil' then
            log('Enables or disables light mode. When enabled, the addon will never show the window and just print a summary in the chat box at the end of the run. If the enabled parameter is not specified, the help text will be shown.')
            log('Usage: plasmon light <enabled>')
            log('Positional arguments:')
            log('    <enabled>    specifies the status of the light mode. "default", "false" or "0" mean disabled. "true" or "1" mean enabled.')
        else
            local light

            if args[1] == 'default' then
                light = defaults.light
            elseif args[1] == 'true' or args[1] == '1' then
                light = true
            elseif args[1] == 'false' or args[1] == '0' then
                light = false
            end

            if light == true then
                hide_window()
            elseif track == true then
                show_window()
            end

            if type(light) ~= "boolean" then
                error('Please specify a valid status')

                return
            end

            settings.light = light

            refresh_window()
            settings:save('all')
        end
    elseif cmd == 'timer' then
        if type(args[1]) == 'nil' then
            log('Enables or disables the timer. When enabled, the addon will start a 45 minutes timer when entering a fracture. If the enabled parameter is not specified, the help text will be shown.')
            log('Usage: plasmon timer <enabled>')
            log('Positional arguments:')
            log('    <enabled>    specifies the status of the timer. "false" or "0" mean disabled. "default", "true" or "1" mean enabled.')
        else
            local timer

            if args[1] == 'true' or args[1] == '1' then
                timer = true
            elseif args[1] == 'false' or args[1] == '0' then
                timer = false
            end

            if args[1] == 'default' then
                timer = defaults.timer
            elseif timer == true then
                start_timer()()
            elseif track == true then
                stop_timer()
            end

            if type(timer) ~= "boolean" then
                error('Please specify a valid status')

                return
            end

            settings.timer = timer

            refresh_window()
            settings:save('all')
        end
    else
        local options = parse_options(args)

        if cmd == 'position' then
            if options:containskey('h') or options:length() == 0 then
                log('Sets the horizontal and vertical position of the window relative to the upper-left corner. If the no parameter is specified, the help text will be shown.')
                log('Usage: plasmon position [[-h]|[-x <x>] [-y <y>]]')
                log('Optional arguments:')
                log('    -h       shows the help text.')
                log('    -x <x>   specifies the horizontal position of the window.')
                log('    -y <y>   specifies the vertical position of the window.')
            elseif options:length() > 0 then
                local x = settings.position.x
                local y = settings.position.y

                for key, value in pairs(options) do
                    if key == 'x' then
                        if options['x'] == 'default' then
                            x = defaults.position.x
                        else
                            x = tonumber(options['x'])

                            if type(x) ~= "number" then
                                error('Please specify a valid horizontal position.')

                                return
                            end
                        end
                    elseif key == 'y' then
                        if options['y'] == 'default' then
                            y = defaults.position.y
                        else
                            y = tonumber(options['y'])

                            if type(y) ~= "number" then
                                error('Please specify a valid vertical position.')

                                return
                            end
                        end

                    else
                        error('"'..key..'" is not a recognized parameter')

                        return
                    end
                end

                settings.position.x = x
                settings.position.y = y

                windower.text.set_location(tb_name, x, y)
                settings:save('all')
                log('The window\'s position has been set.')
            end
        elseif cmd == 'font' then
            if options:containskey('h') or options:length() == 0 then
                log('Sets the style of the font used in the window. If the no parameter is specified, the help text will be shown.')
                log('Usage: plasmon font [[-h]|[-f <font>] [-s <size>] [-a <alpha>] [-b [<bold>]] [-i [<italic>]]]')
                log('Optional arguments:')
                log('    -h               shows the help text.')
                log('    -f <font>        specifies the text\'s font.')
                log('    -s <size>        specifies the text\'s size.')
                log('    -a <alpha>       specifies the text\'s transparency. the value must be set between 0 (transparent) and 255 (opaque), inclusive.')
                log('    -b [<bold>]      specifies if the text should be rendered bold. "default", "false" or "0" mean disabled. "true", "1" or no value mean enabled.')
                log('    -i [<italic>]    specifies if the text should be rendered italic. "default", "false" or "0" mean disabled. "true", "1" or no value mean enabled.')
            elseif options:length() > 0 then
                local family = settings.font.family
                local size   = settings.font.size
                local bold   = settings.font.bold
                local italic = settings.font.italic
                local a      = settings.font.a

                for key, value in pairs(options) do
                    if key == 'f' then
                        if options['f'] == 'default' then
                            family = defaults.font.family
                        else
                            family = options['f']
                        end
                    elseif key == 's' then
                        if options['s'] == 'default' then
                            size = defaults.position.size
                        else
                            size = tonumber(options['s'])

                            if type(size) ~= "number" then
                                error('Please specify a valid font size.')

                                return
                            end
                        end
                    elseif key == 'b' then
                        if options['b'] == 'default' then
                            bold = defaults.position.bold
                        elseif options['b'] == true or options['b'] == '1' or options['b'] == 'true' or options['b'] == 'null' then
                            bold = true
                        elseif options['b'] == '0' or options['b'] == 'false' then
                            bold = false
                        else
                            error('Please specify a valid bold status.')

                            return
                        end
                    elseif key == 'i' then
                        if options['i'] == 'default' then
                            italic = defaults.position.italic
                        elseif options['b'] == true or options['i'] == '1' or options['i'] == 'true' or options['i'] == 'null' then
                            italic = true
                        elseif options['i'] == '0' or options['i'] == 'false' then
                            italic = false
                        else
                            error('Please specify a valid italic status.')

                            return
                        end
                    elseif key == 'a' then
                        if options['a'] == 'default' then
                            a = defaults.position.a
                        else
                            a = tonumber(options['a'])

                            if type(a) ~= "number" then
                                error('Please specify a valid alpha value.')

                                return
                            else
                                a = math.min(255, math.max(0, a))
                            end
                        end
                    else
                        error('"'..key..'" is not a recognized parameter')

                        return
                    end
                end

                settings.font.family = family
                settings.font.size   = size
                settings.font.bold   = bold
                settings.font.italic = italic
                settings.font.a      = a

                windower.text.set_color(tb_name, a, 147, 161, 161)
                windower.text.set_font(tb_name, family, size)
                windower.text.set_bold(tb_name, bold)
                windower.text.set_italic(tb_name, italic)
                settings:save('all')
                log('The font\'s style has been set.')
            end
        elseif cmd == 'color' then
            local validObjects = T{
                'all', 'background', 'bg', 'title', 'label', 'value',
                'plasmon', 'plasmon.title', 'plasmon.label', 'plasmon.value',
                'airlixir', 'airlixir.title', 'airlixir.label', 'airlixir.value'
            }

            if options:containskey('h') or options:length() == 0 then
                log('Sets the colors of the various elements present in the addon\'s window. If the no parameter is specified, the help text will be shown.')
                log('Usage: plasmon color [[-h]|[-o <objects>] [-d] [-r <red>] [-g <green>] [-b <blue>] [-a <alpha>]]')
                log('Optional arguments:')
                log('    -h             shows the help text.')
                log('    -o <objects>   specifies the item/s which will have its/their color changed. If this parameter is missing all the objects will be changed. The accepted values are: "'..validObjects:concat('", "')..'"')
                log('    -d             sets the red, green, blue and alpha values of the specified objects to their default values.')
                log('    -r <red>       specifies the intensity of the red color. The value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.')
                log('    -g <green>     specifies the intensity of the greencolor. The value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.')
                log('    -b <blue>      specifies the intensity of the blue color. The value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.')
                log('    -a <alpha>     specifies the text\'s transparency. The value must be set between 0 (transparent) and 255 (opaque), inclusive.')
            elseif options:length() > 0 then
                local r = -1
                local g = -1
                local b = -1
                local a = -1
                local objects

                if options:containskey('o') then
                    if validObjects:contains(options['o']) then
                        if options['o'] == 'background' or options['o'] == 'bg' then
                            objects = T{'background'}
                        elseif options['o'] == 'title' then
                            objects = T{
                                'plasmon.title',
                                'airlixir.title'
                            }
                        elseif options['o'] == 'label' then
                            objects = T{
                                'plasmon.label',
                                'airlixir.label'
                            }
                        elseif options['o'] == 'value' then
                            objects = T{
                                'plasmon.value',
                                'airlixir.value'
                            }
                        elseif options['o'] == 'plasmon' then
                            objects = T{
                                'plasmon.title',
                                'plasmon.label',
                                'plasmon.value'
                            }
                        elseif options['o'] == 'airlixir'  then
                            objects = T{
                                'airlixir.title',
                                'airlixir.label',
                                'airlixir.value'
                            }
                        elseif options['o'] == 'plasmon.title' then
                            objects = T{'plasmon.title'}
                        elseif options['o'] == 'plasmon.label' then
                            objects = T{'plasmon.label'}
                        elseif options['o'] == 'plasmon.value' then
                            objects = T{'plasmon.value'}
                        elseif options['o'] == 'airlixir.title' then
                            objects = T{'airlixir.title'}
                        elseif options['o'] == 'airlixir.label' then
                            objects = T{'airlixir.label'}
                        elseif options['o'] == 'airlixir.value' then
                            objects = T{'airlixir.value'}
                        end
                    else
                        error('Please specify a valid object or set of objects.')

                        return
                    end
                else
                    objects = T{
                        'background',
                        'plasmon.title', 'plasmon.label', 'plasmon.value',
                        'airlixir.title', 'airlixir.label', 'airlixir.value'
                    }
                end

                if not options:containskey('d') then
                    for key, value in pairs(options) do
                        if key == 'r' then
                            if options['r'] == 'default' then
                                r = -1
                            else
                                r = tonumber(options['r'])

                                if type(r) ~= "number" then
                                    error('Please specify a valid red value.')

                                    return
                                else
                                    r = math.min(255, math.max(0, r))
                                end
                            end
                        elseif key == 'g' then
                            if options['g'] == 'default' then
                                g = -1
                            else
                                g = tonumber(options['g'])

                                if type(g) ~= "number" then
                                    error('Please specify a valid green value.')

                                    return
                                else
                                    g = math.min(255, math.max(0, g))
                                end
                            end
                        elseif key == 'b' then
                            if options['b'] == 'default' then
                                b = -1
                            else
                                b = tonumber(options['b'])

                                if type(b) ~= "number" then
                                    error('Please specify a valid blue value.')

                                    return
                                else
                                    b = math.min(255, math.max(0, b))
                                end
                            end
                        elseif key == 'a' then
                            if options['a'] == 'default' then
                                a = -1
                            else
                                a = tonumber(options['a'])

                                if type(a) ~= "number" then
                                    error('Please specify a valid alpha value.')

                                    return
                                else
                                    a = math.min(255, math.max(0, a))
                                end
                            end
                        elseif key == 'o' then
                        else
                            error('"'..key..'" is not a recognized parameter.')

                            return
                        end
                    end
                end

                for key, object in pairs(objects) do
                    local indexes = T(object:split('.'))

                    if indexes:length() == 2 then
                        if r == -1 then
                            settings.colors[indexes[1]][indexes[2]].r = defaults.colors[indexes[1]][indexes[2]].r
                        else
                            settings.colors[indexes[1]][indexes[2]].r = r
                        end

                        if g == -1 then
                            settings.colors[indexes[1]][indexes[2]].g = defaults.colors[indexes[1]][indexes[2]].g
                        else
                            settings.colors[indexes[1]][indexes[2]].g = g
                        end

                        if b == -1 then
                            settings.colors[indexes[1]][indexes[2]].b = defaults.colors[indexes[1]][indexes[2]].b
                        else
                            settings.colors[indexes[1]][indexes[2]].b = b
                        end
                    elseif indexes:length() == 1 then
                        if r == -1 then
                            settings.colors[indexes[1]].r = defaults.colors[indexes[1]].r
                        else
                            settings.colors[indexes[1]].r = r
                        end

                        if g == -1 then
                            settings.colors[indexes[1]].g = defaults.colors[indexes[1]].g
                        else
                            settings.colors[indexes[1]].g = g
                        end

                        if b == -1 then
                            settings.colors[indexes[1]].b = defaults.colors[indexes[1]].b
                        else
                            settings.colors[indexes[1]].b = b
                        end

                        if a == -1 then
                            settings.colors[indexes[1]].a = defaults.colors[indexes[1]].a
                        else
                            settings.colors[indexes[1]].a = a
                        end

                        windower.text.set_bg_color(
                            tb_name,
                            settings.colors[indexes[1]].a,
                            settings.colors[indexes[1]].r,
                            settings.colors[indexes[1]].g,
                            settings.colors[indexes[1]].b
                        )
                    end
                end

                refresh_window()
                settings:save('all')
                log('The objects\' color has been set.')
            end
        else
            windower.send_command('plasmon help')
        end
    end
end)