--[[
plasmon v1.20130516

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

require 'stringhelper'
local config = require 'config'

local _plasmon = T{}
_plasmon.v                   = '1.20130516'
_plasmon.tb_name             = 'addon:gr:plasmon'
_plasmon.track               = false
_plasmon.visible             = false
_plasmon.stats               = T{}
_plasmon.stats.plasm         = 0
_plasmon.stats.totPlasm      = 0
_plasmon.stats.mobs          = 0
_plasmon.stats.totMobs       = 0
_plasmon.stats.airlixirs     = 0
_plasmon.stats.totAirlixirs  = 0
_plasmon.stats.airlixirs1    = 0
_plasmon.stats.totAirlixirs1 = 0
_plasmon.stats.airlixirs2    = 0
_plasmon.stats.totAirlixirs2 = 0

_plasmon.defaults = T{}
_plasmon.defaults.v         = 0
_plasmon.defaults.first_run = true
_plasmon.defaults.light     = false

_plasmon.defaults.position = T{}
_plasmon.defaults.position.x = 0
_plasmon.defaults.position.y = 350

_plasmon.defaults.font = T{}
_plasmon.defaults.font.family = 'Arial'
_plasmon.defaults.font.size   = 10
_plasmon.defaults.font.a      = 255
_plasmon.defaults.font.bold   = false
_plasmon.defaults.font.italic = false

_plasmon.defaults.colors = T{}
_plasmon.defaults.colors.background = T{}
_plasmon.defaults.colors.background.r = 0
_plasmon.defaults.colors.background.g = 43
_plasmon.defaults.colors.background.b = 54
_plasmon.defaults.colors.background.a = 200

_plasmon.defaults.colors.delve = T{}
_plasmon.defaults.colors.delve.title = T{}
_plasmon.defaults.colors.delve.title.r = 220
_plasmon.defaults.colors.delve.title.g = 50
_plasmon.defaults.colors.delve.title.b = 47

_plasmon.defaults.colors.delve.label = T{}
_plasmon.defaults.colors.delve.label.r = 38
_plasmon.defaults.colors.delve.label.g = 139
_plasmon.defaults.colors.delve.label.b = 210

_plasmon.defaults.colors.delve.value = T{}
_plasmon.defaults.colors.delve.value.r = 147
_plasmon.defaults.colors.delve.value.g = 161
_plasmon.defaults.colors.delve.value.b = 161

_plasmon.defaults.colors.airlixir = T{}
_plasmon.defaults.colors.airlixir.title = T{}
_plasmon.defaults.colors.airlixir.title.r = 220
_plasmon.defaults.colors.airlixir.title.g = 50
_plasmon.defaults.colors.airlixir.title.b = 47

_plasmon.defaults.colors.airlixir.label = T{}
_plasmon.defaults.colors.airlixir.label.r = 42
_plasmon.defaults.colors.airlixir.label.g = 161
_plasmon.defaults.colors.airlixir.label.b = 152

_plasmon.defaults.colors.airlixir.value = T{}
_plasmon.defaults.colors.airlixir.value.r = 147
_plasmon.defaults.colors.airlixir.value.g = 161
_plasmon.defaults.colors.airlixir.value.b = 161

_plasmon.settings = T{}

-- plugin functions

function _plasmon.parseOptions(args)
    local options = T{}

    while #args > 0 do
        if not args[1]:match('^-%a') then
            break
        end

        local option = args:remove(1):sub(2)

        if type(args[1]) ~= 'nil' and not args[1]:match('^-%a') then
            options[option] = args:remove(1)
        else
            options[option] = true
        end
    end

    return options
end

function _plasmon.test()
    add_to_chat(121, 'Now permeating the mists surrounding the fracture.')
    add_to_chat(121, 'You receive 50 corpuscles of mweya plasm.')
    add_to_chat(121, 'You find an airlixir on the Mob')
    add_to_chat(121, 'You receive 50 corpuscles of mweya plasm.')
    add_to_chat(121, 'You receive 50 corpuscles of mweya plasm.')
    add_to_chat(121, 'You receive 150 corpuscles of mweya plasm.')
    add_to_chat(121, 'You receive 50 corpuscles of mweya plasm.')
    add_to_chat(121, 'You find an airlixir on the Mob')
    add_to_chat(121, 'You receive 500 corpuscles of mweya plasm.')
    add_to_chat(121, 'You find an airlixir on the Mob')
    add_to_chat(121, 'You find an airlixir on the Mob')
    add_to_chat(121, 'You find an airlixir on the Mob')
    add_to_chat(121, 'You find an airlixir on the Mob')
    add_to_chat(121, 'You find an airlixir +1 on the Mob')
    add_to_chat(121, 'You find an airlixir +2 on the Mob')
    add_to_chat(121, 'Your time has expired for this battle. Now exiting...')
    _plasmon.show()
end

function _plasmon.start()
    _plasmon.reset()
    _plasmon.track = true
    add_to_chat(0, '\30\03The Delve has begun!\30\01')

    if _plasmon.settings.light == false then
        _plasmon.show()
    end
end

function _plasmon.stop()
    _plasmon.stats.scores  = T{}
    _plasmon.stats.bonuses = T{}

    _plasmon.track = false
    add_to_chat(0, '\30\03The Delve has ended\30\01')
    _plasmon.hide()
    _plasmon.status()
end

function _plasmon.refresh()
    if _plasmon.visible == false then
        return
    end

    local delveColors    = _plasmon.settings.colors.delve
    local airlixirColors = _plasmon.settings.colors.airlixir
    local text           = T{
        ' \\cs('..delveColors.title.r..', '..delveColors.title.g..', '..delveColors.title.b..')--== DELVE ==--\\cr \n',
        ' \\cs('..delveColors.label.r..', '..delveColors.label.g..', '..delveColors.label.b..')Plasm:\\cr',
        ' \\cs('..delveColors.value.r..', '..delveColors.value.g..', '..delveColors.value.b..')'.._plasmon.stats.plasm..'/'.._plasmon.stats.totPlasm..'\\cr \n',
        ' \\cs('..delveColors.label.r..', '..delveColors.label.g..', '..delveColors.label.b..')Mobs:\\cr',
        ' \\cs('..delveColors.value.r..', '..delveColors.value.g..', '..delveColors.value.b..')'.._plasmon.stats.mobs..'/'.._plasmon.stats.totMobs..'\\cr \n',
        ' \\cs('..airlixirColors.title.r..', '..airlixirColors.title.g..', '..airlixirColors.title.b..')--== AIRLIXIRS ==--\\cr \n',
        ' \\cs('..airlixirColors.label.r..', '..airlixirColors.label.g..', '..airlixirColors.label.b..')Airlixir:\\cr',
        ' \\cs('..airlixirColors.value.r..', '..airlixirColors.value.g..', '..airlixirColors.value.b..')'.._plasmon.stats.airlixirs..'/'.._plasmon.stats.totAirlixirs..'\\cr \n',
        ' \\cs('..airlixirColors.label.r..', '..airlixirColors.label.g..', '..airlixirColors.label.b..')Airlixir +1:\\cr',
        ' \\cs('..airlixirColors.value.r..', '..airlixirColors.value.g..', '..airlixirColors.value.b..')'.._plasmon.stats.airlixirs1..'/'.._plasmon.stats.totAirlixirs1..'\\cr \n',
        ' \\cs('..airlixirColors.label.r..', '..airlixirColors.label.g..', '..airlixirColors.label.b..')Airlixir +2:\\cr',
        ' \\cs('..airlixirColors.value.r..', '..airlixirColors.value.g..', '..airlixirColors.value.b..')'.._plasmon.stats.airlixirs2..'/'.._plasmon.stats.totAirlixirs2..'\\cr'
    }

    tb_set_text(_plasmon.tb_name, text:concat(''))
end

function _plasmon.reset()
    _plasmon.stats.plasm      = 0
    _plasmon.stats.mobs       = 0
    _plasmon.stats.airlixirs  = 0
    _plasmon.stats.airlixirs1 = 0
    _plasmon.stats.airlixirs2 = 0
    _plasmon.refresh()
end

function _plasmon.fullReset()
    _plasmon.stats.totPlasm      = 0
    _plasmon.stats.totMobs       = 0
    _plasmon.stats.totAirlixirs  = 0
    _plasmon.stats.totAirlixirs1 = 0
    _plasmon.stats.totAirlixirs2 = 0
    _plasmon.reset()
    _plasmon.refresh()
end

function _plasmon.show()
    _plasmon.visible = true
    tb_set_visibility(_plasmon.tb_name, true)
    _plasmon.refresh()
end

function _plasmon.hide()
    _plasmon.visible = false
    tb_set_visibility(_plasmon.tb_name, false)
end

function _plasmon.toggle()
    if _plasmon.visible then
        _plasmon.hide()
    else
        _plasmon.show()
    end
end

function _plasmon.status()
    add_to_chat(0, '\30\03[Plasm\30\01 \30\02'.._plasmon.stats.plasm..'/'.._plasmon.stats.totPlasm..'\30\01\30\03] [Mobs\30\01 \30\02'.._plasmon.stats.mobs..'/'.._plasmon.stats.totMobs..'\30\01\30\03] [Airlixir\30\01 \30\02'.._plasmon.stats.airlixirs..'/'.._plasmon.stats.totAirlixirs..'\30\01\30\03 | +1\30\01 \30\02'.._plasmon.stats.airlixirs1..'/'.._plasmon.stats.totAirlixirs1..'\30\01\30\03 | +2\30\01 \30\02'.._plasmon.stats.airlixirs2..'/'.._plasmon.stats.totAirlixirs2..'\30\01\30\03]\30\01')
end

function _plasmon.first_run()
    if ( type(_plasmon.settings.v) ~= 'nil' and _plasmon.settings.v >= tonumber(_plasmon.v) and _plasmon.settings.first_run == false ) then
        return
    end

    add_to_chat(55, 'hi '..get_player()['name']:lower()..',')
    add_to_chat(55, 'thank you for using plasmon v'.._plasmon.v)
    add_to_chat(55, 'in this update i\'ve added a light mode. when enabled the window will be kept hidden and only the summary will be shown at the end of the run.')
    add_to_chat(55, 'use "plasmon light true/false" to enable or disable it.')
    add_to_chat(55, '- zohno@phoenix')

    _plasmon.settings.v = _plasmon.v
    _plasmon.settings.first_run = false
    _plasmon.settings:save('all')
end

-- windower events

function event_load()
    _plasmon.settings = config.load(_plasmon.defaults)

    local background = _plasmon.settings.colors.background

    send_command('alias plasmon lua c plasmon')
    tb_create(_plasmon.tb_name)
    tb_set_location(_plasmon.tb_name, _plasmon.settings.position.x, _plasmon.settings.position.y)
    tb_set_bg_color(_plasmon.tb_name, background.a, background.r, background.g, background.b)
    tb_set_color(_plasmon.tb_name, _plasmon.settings.font.a, 147, 161, 161)
    tb_set_font(_plasmon.tb_name, _plasmon.settings.font.family, _plasmon.settings.font.size)
    tb_set_bold(_plasmon.tb_name, _plasmon.settings.font.bold)
    tb_set_italic(_plasmon.tb_name, _plasmon.settings.font.italic)
    tb_set_text(_plasmon.tb_name, '')
    tb_set_bg_visibility(_plasmon.tb_name, true)
end

function event_unload()
    send_command('unalias plasmon')
    tb_delete(_plasmon.tb_name)
end

function event_login()
    _plasmon.first_run()
end

function event_incoming_text(original, modified, mode)
    local match

    match = original:match('Now permeating the mists surrounding the fracture%.')

    if match then
        _plasmon.start()

        return modified, mode
    end

    match = original:match('Your time has expired for this battle%. Now exiting%.%.%.')

    if match and _plasmon.track then
        _plasmon.stop()

        return modified, mode
    end

    match = original:match('You receive (%d+) corpuscles of mweya plasm%.')

    if match and _plasmon.track then
        _plasmon.stats.plasm    = _plasmon.stats.plasm + match
        _plasmon.stats.totPlasm = _plasmon.stats.totPlasm + match

        if match ~= 50 or match ~= 500 or match ~= 750 then
            mobs = match / 50
        else
            mobs = 1
        end

        _plasmon.stats.mobs     = _plasmon.stats.mobs + mobs
        _plasmon.stats.totMobs  = _plasmon.stats.totMobs + mobs
        _plasmon.refresh()

        return modified, mode
    end

    match = original:match('You find an airlixir %+1')

    if match and _plasmon.track then
        _plasmon.stats.airlixirs1    = _plasmon.stats.airlixirs1 + 1
        _plasmon.stats.totAirlixirs1 = _plasmon.stats.totAirlixirs1 + 1
        _plasmon.refresh()

        return modified, mode
    end

    match = original:match('You find an airlixir %+2')

    if match and _plasmon.track then
        _plasmon.stats.airlixirs2    = _plasmon.stats.airlixirs2 + 1
        _plasmon.stats.totAirlixirs2 = _plasmon.stats.totAirlixirs2 + 1
        _plasmon.refresh()

        return modified, mode
    end

    match = original:match('You find an airlixir')

    if match and _plasmon.track then
        _plasmon.stats.airlixirs    = _plasmon.stats.airlixirs + 1
        _plasmon.stats.totAirlixirs = _plasmon.stats.totAirlixirs + 1
        _plasmon.refresh()

        return modified, mode
    end

    return modified, mode
end

function event_addon_command(...)
    local args     = T({...})
    local messages = T{}
    local errors   = T{}

    if args[1] == nil then
        send_command('plasmon help')
        return
    end

    local cmd = args:remove(1):lower()

    if cmd == 'help' then
        messages:append('help >> plasmon test -- fills the chat log to show how the plugin will work. reload the plugin after the test (lua r plasmon)')
        messages:append('help >> plasmon reset -- sets gained exp and bayld to 0')
        messages:append('help >> plasmon full-reset -- sets gained exp/total exp and bayld/total bayld to 0')
        messages:append('help >> plasmon show -- shows the tracking window')
        messages:append('help >> plasmon hide -- hides the tracking window')
        messages:append('help >> plasmon toggle -- toggles the tracking window')
        messages:append('help >> plasmon light [\30\02enabled\30\01] -- defines the light mode status')
        messages:append('help >> plasmon position [[-h]|[-x \30\02x\30\01] [-y \30\02y\30\01]] -- sets the horizontal and vertical position of the window relative to the upper-left corner')
        messages:append('help >> plasmon font [[-h]|[-f \30\02font\30\01] [-s \30\02size\30\01] [-a \30\02alpha\30\01] [-b[ \30\02bold\30\01]] [-i[ \30\02italic\30\01]]] -- sets the style of the font used in the window')
        messages:append('help >> plasmon color [[-h]|[-o \30\02objects\30\01] [-d] [-r \30\02red\30\01] [-g \30\02green\30\01] [-b \30\02blue\30\01] [-a \30\02alpha\30\01]] -- sets the colors used by the plugin')
    elseif cmd == 'test' then
        _plasmon.test()
    elseif cmd == 'reset' then
        _plasmon.reset()
    elseif cmd == 'full-reset' then
        _plasmon.fullReset()
    elseif cmd == 'show' then
        _plasmon.show()
    elseif cmd == 'hide' then
        _plasmon.hide()
    elseif cmd == 'toggle' then
        _plasmon.toggle()
    elseif cmd == 'light' then
        if type(args[1]) == 'nil' then
            messages:append('light >> defines the light mode status. when enabled, the window will be kept hidden and only the summary will be show after the run')
            messages:append('light >> usage: plasmon light \30\02enabled\30\01')
            messages:append('light >> positional arguments:')
            messages:append('light >>   enabled    define light mode status')
        else
            local light

            if args[1] == 'default' then
                light = _plasmon.defaults.light
            elseif args[1] == 'true' or args[1] == '1' then
                light = true
            elseif args[1] == 'false' or args[1] == '0' then
                light = false
            end

            if light == true then
                _plasmon.hide()
            elseif _plasmon.track == true then
                _plasmon.show()
            end

            if type(light) ~= "boolean" then
                errors:append('light >> light expects \'enabled\' to be a boolean (\'true\' or \'false\'), a number (\'1\' or \'0\') or \'default\' (without quotes)')
            end

            if errors:length() == 0 then
                _plasmon.settings.light = light

                _plasmon.refresh()
                _plasmon.settings:save('all')
            end
        end
    else
        local options = _plasmon.parseOptions(args)

        if cmd == 'position' then
            if options:containskey('h') or options:length() == 0 then
                messages:append('position >> sets the horizontal and vertical position of the window relative to the upper-left corner')
                messages:append('position >> usage: plasmon position [[-h]|[-x \30\02x\30\01] [-y \30\02y\30\01]]')
                messages:append('position >> optional arguments:')
                messages:append('position >>   -h    show this message and exit')
                messages:append('position >>   -x    the horizontal position of the window relative to the upper-left corner')
                messages:append('position >>   -y    the vertical position of the window relative to the upper-left corner')
            elseif options:length() > 0 then
                local x = _plasmon.settings.position.x
                local y = _plasmon.settings.position.y

                for key, value in pairs(options) do
                    if key == 'x' then
                        if options['x'] == 'default' then
                            x = _plasmon.defaults.position.x
                        else
                            x = tonumber(options['x'])

                            if type(x) ~= "number" then
                                errors:append('position >> position expects \'x\' to be a number or \'default\' (without quotes)')
                            end
                        end
                    elseif key == 'y' then
                        if options['y'] == 'default' then
                            y = _plasmon.defaults.position.y
                        else
                            y = tonumber(options['y'])

                            if type(y) ~= "number" then
                                errors:append('position >> position expects \'y\' to be a number or \'default\' (without quotes)')
                            end
                        end

                    else
                        errors:append('position >> '..key..' is not a recognized parameter')
                    end
                end

                if errors:length() == 0 then
                    _plasmon.settings.position.x = x
                    _plasmon.settings.position.y = y

                    tb_set_location(_plasmon.tb_name, x, y)
                    _plasmon.settings:save('all')
                end
            end
        elseif cmd == 'font' then
            if options:containskey('h') or options:length() == 0 then
                messages:append('font >> sets the style of the font used in the window')
                messages:append('font >> usage: plasmon font [[-h]|[-f \30\02font\30\01] [-s \30\02size\30\01] [-a \30\02alpha\30\01] [-b[ \30\02bold\30\01]] [-i[ \30\02italic\30\01]]]')
                messages:append('font >> optional arguments:')
                messages:append('font >>   -h    show this message and exit')
                messages:append('font >>   -f    the name of the font to use')
                messages:append('font >>   -s    the size of the text')
                messages:append('font >>   -a    the text transparency between 0 (transparent) and 255 (opaque)')
                messages:append('font >>   -b    makes the text bold (null/true/false/1/0/default)')
                messages:append('font >>   -i    makes the text italic (null/true/false/1/0/default)')
            elseif options:length() > 0 then
                local family = _plasmon.settings.font.family
                local size   = _plasmon.settings.font.size
                local bold   = _plasmon.settings.font.bold
                local italic = _plasmon.settings.font.italic
                local a      = _plasmon.settings.font.a

                for key, value in pairs(options) do
                    if key == 'f' then
                        if options['f'] == 'default' then
                            family = _plasmon.defaults.font.family
                        else
                            family = options['f']
                        end
                    elseif key == 's' then
                        if options['s'] == 'default' then
                            size = _plasmon.defaults.position.size
                        else
                            size = tonumber(options['s'])

                            if type(size) ~= "number" then
                                errors:append('font >> font expects \'size\' to be a number or \'default\' (without quotes)')
                            end
                        end
                    elseif key == 'b' then
                        if options['b'] == 'default' then
                            bold = _plasmon.defaults.position.bold
                        elseif options['b'] == true or options['b'] == '1' or options['b'] == 'true' or options['b'] == 'null' then
                            bold = true
                        elseif options['b'] == '0' or options['b'] == 'false' then
                            bold = false
                        else
                            errors:append('font >> font expects \'bold\' to be null (\'true\'), a boolean (\'true\' or \'false\'), a number (\'1\' or \'0\') or \'default\' (without quotes)')
                        end
                    elseif key == 'i' then
                        if options['i'] == 'default' then
                            italic = _plasmon.defaults.position.italic
                        elseif options['b'] == true or options['i'] == '1' or options['i'] == 'true' or options['i'] == 'null' then
                            italic = true
                        elseif options['i'] == '0' or options['i'] == 'false' then
                            italic = false
                        else
                            errors:append('font >> font expects \'italic\' to be a number (\'0\' or \'1\'), a boolean (\'false\' or \'true\') or \'default\' (without quotes)')
                        end
                    elseif key == 'a' then
                        if options['a'] == 'default' then
                            a = _plasmon.defaults.position.a
                        else
                            a = tonumber(options['a'])

                            if type(a) ~= "number" then
                                errors:append('font >> font expects \'a\' to be a number or \'default\' (without quotes)')
                            else
                                a = math.min(255, math.max(0, a))
                            end
                        end
                    else
                        errors:append('font >> '..key..' is not a recognized parameter')
                    end
                end

                if errors:length() == 0 then
                    _plasmon.settings.font.family = family
                    _plasmon.settings.font.size   = size
                    _plasmon.settings.font.bold   = bold
                    _plasmon.settings.font.italic = italic
                    _plasmon.settings.font.a      = a

                    tb_set_color(_plasmon.tb_name, a, 147, 161, 161)
                    tb_set_font(_plasmon.tb_name, family, size)
                    tb_set_bold(_plasmon.tb_name, bold)
                    tb_set_italic(_plasmon.tb_name, italic)
                    _plasmon.settings:save('all')
                end
            end
        elseif cmd == 'color' then
            local validObjects = T{
                'all', 'background', 'bg', 'title', 'label', 'value',
                'plasmon', 'plasmon.title', 'plasmon.label', 'plasmon.value',
                'airlixir', 'airlixir.title', 'airlixir.label', 'airlixir.value'
            }

            if options:containskey('h') or options:length() == 0 then
                messages:append('color >> sets the colors used by the plugin')
                messages:append('color >> usage: plasmon color [[-h]|[-o \30\02objects\30\01] [-d] [-r \30\02red\30\01] [-g \30\02green\30\01] [-b \30\02blue\30\01] [-a \30\02alpha\30\01]]')
                messages:append('color >> optional arguments:')
                messages:append('color >>   -h    show this message and exit')
                messages:append('color >>   -o    the objects that will have their color changed. accepted values are: '..validObjects:concat(', '))
                messages:append('color >>   -d    sets the default r, g, b, a values for the specified objects')
                messages:append('color >>   -r    the amount of red between 0 and 255')
                messages:append('color >>   -g    the amount of green between 0 and 255')
                messages:append('color >>   -b    the amount of blue between 0 and 255')
                messages:append('color >>   -a    the transparency between 0 (transparent) and 255 (opaque). applies only to background')
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
                        errors:append('color >> color expects \'o\' to be one of the following values: '..validObjects:concat(', '))
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
                                    errors:append('color >> color expects \'r\' to be a number or \'default\' (without quotes)')
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
                                    errors:append('color >> color expects \'g\' to be a number or \'default\' (without quotes)')
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
                                    errors:append('color >> color expects \'b\' to be a number or \'default\' (without quotes)')
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
                                    errors:append('color >> color expects \'a\' to be a number or \'default\' (without quotes)')
                                else
                                    a = math.min(255, math.max(0, a))
                                end
                            end
                        elseif key == 'o' then
                        else
                            errors:append('color >> '..key..' is not a recognized parameter')
                        end
                    end
                end

                if errors:length() == 0 then
                    for key, object in pairs(objects) do
                        local indexes = T(object:split('.'))

                        if indexes:length() == 2 then
                            if r == -1 then
                                _plasmon.settings.colors[indexes[1]][indexes[2]].r = _plasmon.defaults.colors[indexes[1]][indexes[2]].r
                            else
                                _plasmon.settings.colors[indexes[1]][indexes[2]].r = r
                            end

                            if g == -1 then
                                _plasmon.settings.colors[indexes[1]][indexes[2]].g = _plasmon.defaults.colors[indexes[1]][indexes[2]].g
                            else
                                _plasmon.settings.colors[indexes[1]][indexes[2]].g = g
                            end

                            if b == -1 then
                                _plasmon.settings.colors[indexes[1]][indexes[2]].b = _plasmon.defaults.colors[indexes[1]][indexes[2]].b
                            else
                                _plasmon.settings.colors[indexes[1]][indexes[2]].b = b
                            end
                        elseif indexes:length() == 1 then
                            if r == -1 then
                                _plasmon.settings.colors[indexes[1]].r = _plasmon.defaults.colors[indexes[1]].r
                            else
                                _plasmon.settings.colors[indexes[1]].r = r
                            end

                            if g == -1 then
                                _plasmon.settings.colors[indexes[1]].g = _plasmon.defaults.colors[indexes[1]].g
                            else
                                _plasmon.settings.colors[indexes[1]].g = g
                            end

                            if b == -1 then
                                _plasmon.settings.colors[indexes[1]].b = _plasmon.defaults.colors[indexes[1]].b
                            else
                                _plasmon.settings.colors[indexes[1]].b = b
                            end

                            if a == -1 then
                                _plasmon.settings.colors[indexes[1]].a = _plasmon.defaults.colors[indexes[1]].a
                            else
                                _plasmon.settings.colors[indexes[1]].a = a
                            end

                            tb_set_bg_color(
                                _plasmon.tb_name,
                                _plasmon.settings.colors[indexes[1]].a,
                                _plasmon.settings.colors[indexes[1]].r,
                                _plasmon.settings.colors[indexes[1]].g,
                                _plasmon.settings.colors[indexes[1]].b
                            )
                        end
                    end

                    _plasmon.refresh()
                    _plasmon.settings:save('all')
                end
            end
        else
            send_command('plasmon help')
        end
    end

    for key, message in pairs(errors) do
        add_to_chat(38, 'lua:addon:plasmon:'..message)
    end

    for key, message in pairs(messages) do
        add_to_chat(55,'lua:addon:plasmon:'..message)
    end
end