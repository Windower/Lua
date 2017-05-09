--[[
reive v1.20131021

Copyright (c) 2013, Giuliano Riccio
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of reive nor the
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

require 'chat'
require 'logger'
require 'strings'

local config = require 'config'


_addon.name    = 'reive'
_addon.author  = 'Zohno'
_addon.version = '1.20131221'
_addon.command = 'reive'

tb_name = 'addon:gr:reive'
track   = false
visible = false

stats           = T{}
stats.exp       = 0
stats.bayld     = 0
stats.tot_exp   = 0
stats.tot_bayld = 0
stats.scores    = T{}
stats.bonuses   = T{}

bonuses_map = {
    ['HP recovery']                 = 'hp_recovery',
    ['MP recovery']                 = 'mp_recovery',
    ['TP recovery']                 = 'tp_recovery',
    ['Status ailment recovery']     = 'status_recovery',
    ['Stoneskin']                   = 'stoneskin',
    ['Ability cast recovery']       = 'abilities_recovery',
    ['Increased maximum MP and HP'] = 'hp_mp_boost'
}

defaults = T{}
defaults.reset_on_start = false -- deprecated
defaults.max_scores     = 5
defaults.light          = false

defaults.track = T{}
defaults.track.hp_recovery        = true
defaults.track.mp_recovery        = true
defaults.track.tp_recovery        = true
defaults.track.status_recovery    = true
defaults.track.stoneskin          = true
defaults.track.abilities_recovery = true
defaults.track.hp_mp_boost        = true

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

defaults.colors.reive = T{}
defaults.colors.reive.title = T{}
defaults.colors.reive.title.r = 220
defaults.colors.reive.title.g = 50
defaults.colors.reive.title.b = 47

defaults.colors.reive.label = T{}
defaults.colors.reive.label.r = 38
defaults.colors.reive.label.g = 139
defaults.colors.reive.label.b = 210

defaults.colors.reive.value = T{}
defaults.colors.reive.value.r = 147
defaults.colors.reive.value.g = 161
defaults.colors.reive.value.b = 161

defaults.colors.score = T{}
defaults.colors.score.title = T{}
defaults.colors.score.title.r = 220
defaults.colors.score.title.g = 50
defaults.colors.score.title.b = 47

defaults.colors.score.label = T{}
defaults.colors.score.label.r = 42
defaults.colors.score.label.g = 161
defaults.colors.score.label.b = 152

defaults.colors.bonus = T{}
defaults.colors.bonus.title = T{}
defaults.colors.bonus.title.r = 220
defaults.colors.bonus.title.g = 50
defaults.colors.bonus.title.b = 47

defaults.colors.bonus.label = T{}
defaults.colors.bonus.label.r = 133
defaults.colors.bonus.label.g = 153
defaults.colors.bonus.label.b = 0

defaults.colors.bonus.value = T{}
defaults.colors.bonus.value.r = 147
defaults.colors.bonus.value.g = 161
defaults.colors.bonus.value.b = 161

settings = config.load(defaults)

-- plugin functions

function parse_options(args)
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

function test()
    start_tracking()
    windower.add_to_chat(121, 'Reive momentum score: HP recovery.')
    windower.add_to_chat(121, 'Momentum bonus: Ability cast recovery!')
    windower.add_to_chat(121, 'Reive momentum score: Damage taken.')
    windower.add_to_chat(121, 'Momentum bonus: Status ailment recovery!')
    windower.add_to_chat(121, 'Reive momentum score: Physical attack.')
    windower.add_to_chat(121, 'Momentum bonus: Stoneskin!')
    windower.add_to_chat(121, 'Reive momentum score: Attack success.')
    windower.add_to_chat(121, 'Momentum bonus: HP recovery!')
    windower.add_to_chat(121, 'Reive momentum score: HP recovery.')
    windower.add_to_chat(121, 'Momentum bonus: TP recovery!')
    windower.add_to_chat(121, 'Reive momentum score: Damage taken.')
    windower.add_to_chat(121, 'Momentum bonus: Increased maximum HP and MP!')
    windower.add_to_chat(121, 'Reive momentum score: Physical attack.')
    windower.add_to_chat(131, 'Player gains 408 limit points.')
    windower.add_to_chat(121, 'Player obtained 291 bayld!')
    windower.add_to_chat(121, 'Player obtained 329 bayld!')
    windower.add_to_chat(121, 'Player obtained 405 bayld!')
    windower.add_to_chat(131, 'Player gains 426 limit points.')
    stop_tracking()
    show_window()
end

function start_tracking()
    reset_stats()
    log('The Reive has begun!')

    track = true

    if settings.light == false then
        show_window()
    end
end

function stop_tracking()
    stats.scores  = T{}
    stats.bonuses = T{}
    track         = false

    log('The Reive has ended.')
    hide_window()
    show_report()
end

function refresh()
    if visible == false then
        return
    end

    local reive_colors = settings.colors.reive
    local text         =
        ' \\cs('..reive_colors.title.r..', '..reive_colors.title.g..', '..reive_colors.title.b..')--== REIVE ==--\\cr \n'..
        ' \\cs('..reive_colors.label.r..', '..reive_colors.label.g..', '..reive_colors.label.b..')Bayld:\\cr'..
        ' \\cs('..reive_colors.value.r..', '..reive_colors.value.g..', '..reive_colors.value.b..')'..stats.bayld..'/'..stats.tot_bayld..'\\cr \n'..
        ' \\cs('..reive_colors.label.r..', '..reive_colors.label.g..', '..reive_colors.label.b..')EXP:\\cr'..
        ' \\cs('..reive_colors.value.r..', '..reive_colors.value.g..', '..reive_colors.value.b..')'..stats.exp..'/'..stats.tot_exp..'\\cr '

    local scores_colors = settings.colors.score
    local scores        = '';

    if #stats.scores > 0 then
        local base = math.max(0, #stats.scores - settings.max_scores)

        for index, score in pairs(stats.scores:slice(base + 1, #stats.scores)) do
            scores = scores..
                '\n \\cs('..scores_colors.label.r..', '..scores_colors.label.g..', '..scores_colors.label.b..')'..(base + index)..'. '..score..'\\cr  '
        end

        text = text..'\n \\cs('..scores_colors.title.r..', '..scores_colors.title.g..', '..scores_colors.title.b..')--== MOMENTUM SCORES ==--\\cr '..scores
    end

    local bonuses_colors = settings.colors.bonus
    local bonuses        = '';

    for index, bonus in ipairs(stats.bonuses:keyset():sort()) do
        if type(bonuses_map[bonus]) == 'nil' or settings.track[bonuses_map[bonus]] == true then
            local amount = stats.bonuses[bonus]

            bonuses = bonuses..
                '\n \\cs('..bonuses_colors.label.r..', '..bonuses_colors.label.g..', '..bonuses_colors.label.b..')'..bonus..':\\cr'..
                ' \\cs('..bonuses_colors.value.r..', '..bonuses_colors.value.g..', '..bonuses_colors.value.b..')'..amount..'\\cr '
        end
    end

    if #bonuses > 0 then
        text = text..'\n \\cs('..bonuses_colors.title.r..', '..bonuses_colors.title.g..', '..bonuses_colors.title.b..')--== MOMENTUM BONUSES ==--\\cr '..bonuses
    end

    windower.text.set_text(tb_name, text)
end

function reset_stats()
    stats.exp   = 0
    stats.bayld = 0
    refresh()
end

function full_reset_stats()
    stats.tot_exp   = 0
    stats.tot_bayld = 0
    reset_stats()
    refresh()
end

function show_window()
    visible = true
    windower.text.set_visibility(tb_name, true)
    refresh()
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
    log('[EXP '..(stats.exp..'/'..stats.tot_exp):color(258)..'] [Bayld '..(stats.bayld..'/'..stats.tot_bayld):color(258)..']')
end

-- windower events

windower.register_event('load', function()
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

    local player = windower.ffxi.get_player()
    if player and T(player['buffs']):contains(511) then
        start_tracking()
    end
end)

windower.register_event('unload', function()
    windower.text.delete(tb_name)
end)

windower.register_event('gain buff', start_tracking:cond(function(id) return id == 511 end))
windower.register_event('lose buff', stop_tracking:cond(function(id) return id == 511 end))

windower.register_event('incoming text', function(original, modified, mode)
    local match

    if mode == 121 then
        match = original:match('Reive momentum score: ([%s%w]+)%.')

        if match then
            stats.scores:append(match)
            refresh()

            return modified, mode
        end

        match = original:match('Momentum bonus: ([%s%w]+)!')

        if match then
            if type(stats.bonuses[match]) == 'nil' then
                stats.bonuses[match] = 0
            end

            stats.bonuses[match] = stats.bonuses[match] + 1
            refresh()

            return modified, mode
        end

        match = original:match('obtained (%d+) bayld!')

        if match and track then
            stats.bayld     = stats.bayld + match
            stats.tot_bayld = stats.tot_bayld + match
            refresh()
        end
    elseif mode == 131 and track then
        match = original:match('gains (%d+) limit points%.')

        if match then
            stats.exp     = stats.exp + match
            stats.tot_exp = stats.tot_exp + match
            refresh()

            return modified, mode
        end

        match = original:match('gains (%d+) experience points%.')


        if match then
            stats.exp     = stats.exp + match
            stats.tot_exp = stats.tot_exp + match
            refresh()

            return modified, mode
        end
    end

    return modified, mode
end)

windower.register_event('addon command', function(...)
    local args = T({...})

    if args[1] == nil then
        windower.send_command('reive help')
        return
    end

    local cmd = args:remove(1):lower()

    if cmd == 'help' then
        log(chat.chars.wsquare..' reive help -- shows the help text.')
        log(chat.chars.wsquare..' reive test -- fills the chat log with some messages to show how the plugin will work.')
        log(chat.chars.wsquare..' reive reset -- sets gained exp and bayld to 0.')
        log(chat.chars.wsquare..' reive full-reset -- sets both current and total gained exp and bayld to 0.')
        log(chat.chars.wsquare..' reive show -- shows the tracking window.')
        log(chat.chars.wsquare..' reive hide -- hides the tracking window.')
        log(chat.chars.wsquare..' reive toggle -- toggles the tracking window\'s visibility.')
        log(chat.chars.wsquare..' reive light [<enabled>] -- enables or disabled light mode. When enabled, the addon will never show the window and just print a summary in the chat box at the end of the run. If the enabled parameter is not specified, the help text will be shown.')
        log(chat.chars.wsquare..' reive max-scores <amount> -- sets the max amount of scores to show in the window. if the amount parameter is not specified, the help text will be shown.')
        log(chat.chars.wsquare..' reive track <score> <visible> -- specifies the visibility of a bonus in the window.')
        log(chat.chars.wsquare..' reive position [[-h]|[-x <x>] [-y <y>]] -- sets the horizontal and vertical position of the window relative to the upper-left corner. If the no parameter is specified, the help text will be shown.')
        log(chat.chars.wsquare..' reive font [[-h]|[-f <font>] [-s <size>] [-a <alpha>] [-b [<bold>]] [-i [<italic>]]] -- sets the style of the font used in the window. if the no parameter is specified, the help text will be shown.')
        log(chat.chars.wsquare..' reive color [[-h]|[-o <objects>] [-d] [-r <red>] [-g <green>] [-b <blue>] [-a <alpha>]] -- sets the colors of the various elements present in the addon\'s window. If the no parameter is specified, the help text will be shown.')
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
            log('Enables or disabled light mode. When enabled, the addon will never show the window and just print a summary in the chat box at the end of the run. Ff the enabled parameter is not specified, the help text will be shown.')
            log('Usage: reive light <enabled>')
            log('Positional arguments:')
            log(chat.chars.wsquare..' <enabled>    specifies the status of the light mode. "default", "false" or "0" mean disabled. "true" or "1" mean enabled.')
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

            refresh()
            settings:save('all')
            log('The light mode has been set.')
        end
    elseif cmd == 'max-scores' then
        local max_scores

        if type(args[1]) == 'nil' then
            log('Sets the max amount of scores to show in the window. If the amount parameter is not specified, the help text will be shown.')
            log('Usage: reive max-scores <amount>')
            log('Positional arguments:')
            log(chat.chars.wsquare..' <amount>    specifies the max amount of status scores that will be show. By default this value is 5. Setting this value to 0 will hide the scores section.')
        elseif args[1] == 'default' then
            max_scores = defaults.max_scores
        else
            max_scores = tonumber(args[1])
        end

        if type(max_scores) ~= "number" then
            error('Please specify a valid amount of scores.')
        end

        if errors:length() == 0 then
            settings.max_scores = max_scores

            refresh()
            settings:save('all')
            notice('The max amount of scores has been set.')
        end
    elseif cmd == 'track' then
        local object
        local visible
        local validObjects = T{
            'abilities-recovery',
            'hp-mp-boost',
            'hp-recovery',
            'mp-recovery',
            'status-recovery',
            'stoneskin',
            'tp-recovery'
        }

        if type(args[1]) == 'nil' then
            log('Specifies the visibility of a bonus in the window.')
            log('Usage: reive track <bonus> <visible>')
            log('Positional arguments:')
            log(chat.chars.wsquare..' <bonus>      specifies the item which will have its visibility changed. The accepted values are : '..validObjects:concat(', '))
            log(chat.chars.wsquare..' <visible>    specifies the visibility of the bonus. "false" or "0" mean disabled. "default", "true" or "1" mean enabled.')
        elseif validObjects:contains(args[1]) then
            object = args[1]:gsub('-', '_')

            if args[2] == 'true' or args[2] == '1' or args[2] == 'default' then
                visible = true
            elseif args[2] == 'false' or args[2] == '0' then
                visible = false
            else
                error('Please specify a valid visible status.')

                return
            end

            settings.track[object] = visible

            refresh()
            settings:save('all')
            notice('The bonus\' visibility has been set.')
        else
            error('Please specify a valid bonus.')

            return
        end
    else
        local options = parse_options(args)

        if cmd == 'position' then
            if options:containskey('h') or options:length() == 0 then
                log('Sets the horizontal and vertical position of the window relative to the upper-left corner. If no parameter is specified, the help text will be shown.')
                log('Usage: reive position [[-h]|[-x <x>] [-y <y>]]')
                log('Optional arguments:')
                log(chat.chars.wsquare..' -h        shows the help text.')
                log(chat.chars.wsquare..' -x <x>    specifies the horizontal position of the window.')
                log(chat.chars.wsquare..' -y <y>    specifies the vertical position of the window.')
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
                notice('The window\'s position has been set.')
            end
        elseif cmd == 'font' then
            if options:containskey('h') or options:length() == 0 then
                log('Sets the style of the font used in the window. if the no parameter is specified, the help text will be shown.')
                log('Usage: reive font [[-h]|[-f <font>] [-s <size>] [-a <alpha>] [-b [<bold>]] [-i [<italic>]]]')
                log('Optional arguments:')
                log(chat.chars.wsquare..' -h               shows the help text.')
                log(chat.chars.wsquare..' -f <font>        specifies the text\'s font.')
                log(chat.chars.wsquare..' -s <size>        specifies the text\'s size.')
                log(chat.chars.wsquare..' -a <alpha>       specifies the text\'s transparency. the value must be set between 0 (transparent) and 255 (opaque), inclusive.')
                log(chat.chars.wsquare..' -b [<bold>]      specifies if the text should be rendered bold. "default", "false" or "0" mean disabled. "true", "1" or no value mean enabled.')
                log(chat.chars.wsquare..' -i [<italic>]    specifies if the text should be rendered italic. "default", "false" or "0" mean disabled. "true", "1" or no value mean enabled.')
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
                'reive', 'reive.title', 'reive.label', 'reive.value',
                'score', 'score.title', 'score.label',
                'bonus', 'bonus.title', 'bonus.label', 'bonus.value'
            }

            if options:containskey('h') or options:length() == 0 then
                log('Sets the colors of the various elements present in the addon\'s window. If the no parameter is specified, the help text will be shown.')
                log('Usage: reive color [[-h]|[-o <objects>] [-d] [-r <red>] [-g <green>] [-b <blue>] [-a <alpha>]]')
                log('Optional arguments:')
                log(chat.chars.wsquare..' -h             shows the help text.')
                log(chat.chars.wsquare..' -o <objects>   specifies the item/s which will have its/their color changed. If this parameter is missing all the objects will be changed. The accepted values are: "'..validObjects:concat('", "')..'"')
                log(chat.chars.wsquare..' -d             sets the red, green, blue and alpha values of the specified objects to their default values.')
                log(chat.chars.wsquare..' -r <red>       specifies the intensity of the red color. The value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.')
                log(chat.chars.wsquare..' -g <green>     specifies the intensity of the greencolor. The value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.')
                log(chat.chars.wsquare..' -b <blue>      specifies the intensity of the blue color. The value must be set between 0 and 255, inclusive, where 0 is less intense and 255 is most intense.')
                log(chat.chars.wsquare..' -a <alpha>     specifies the text\'s transparency. The value must be set between 0 (transparent) and 255 (opaque), inclusive.')
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
                                'reive.title',
                                'score.title',
                                'bonus.title'
                            }
                        elseif options['o'] == 'label' then
                            objects = T{
                                'reive.label',
                                'score.label',
                                'bonus.label'
                            }
                        elseif options['o'] == 'value' then
                            objects = T{
                                'reive.value',
                                'bonus.value'
                            }
                        elseif options['o'] == 'reive' then
                            objects = T{
                                'reive.title',
                                'reive.label',
                                'reive.value'
                            }
                        elseif options['o'] == 'score' then
                            objects = T{
                                'score.title',
                                'score.label'
                            }
                        elseif options['o'] == 'bonus'  then
                            objects = T{
                                'bonus.title',
                                'bonus.label',
                                'bonus.value'
                            }
                        elseif options['o'] == 'reive.title' then
                            objects = T{'reive.title'}
                        elseif options['o'] == 'reive.label' then
                            objects = T{'reive.label'}
                        elseif options['o'] == 'reive.value' then
                            objects = T{'reive.value'}
                        elseif options['o'] == 'score.title' then
                            objects = T{'score.title'}
                        elseif options['o'] == 'score.label' then
                            objects = T{'score.label'}
                        elseif options['o'] == 'bonus.title' then
                            objects = T{'bonus.title'}
                        elseif options['o'] == 'bonus.label' then
                            objects = T{'bonus.label'}
                        elseif options['o'] == 'bonus.value' then
                            objects = T{'bonus.value'}
                        end
                    else
                        error('Please specify a valid object or set of objects.')
                    end
                else
                    objects = T{
                        'background',
                        'reive.title', 'reive.label', 'reive.value',
                        'score.title', 'score.label',
                        'bonus.title', 'bonus.label', 'bonus.value'
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

                refresh()
                settings:save('all')
                log('The objects\' color has been set.')
            end
        else
            windower.send_command('reive help')
        end
    end
end)
