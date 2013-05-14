--[[
reive v1.20130520

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

require 'stringhelper'
local config = require 'config'

local _reive = T{}
_reive.v              = '1.20130520'
_reive.tb_name        = 'addon:gr:reive'
_reive.track          = false
_reive.visible        = false
_reive.stats          = T{}
_reive.stats.exp      = 0
_reive.stats.bayld    = 0
_reive.stats.totExp   = 0
_reive.stats.totBayld = 0
_reive.stats.scores   = T{}
_reive.stats.bonuses  = T{}

_reive.bonuses_map = {
    ['HP recovery']                 = 'hp_recovery',
    ['MP recovery']                 = 'mp_recovery',
    ['TP recovery']                 = 'tp_recovery',
    ['Status ailment recovery']     = 'status_recovery',
    ['Stoneskin']                   = 'stoneskin',
    ['Ability cast recovery']       = 'abilities_recovery',
    ['Increased maximum MP and HP'] = 'hp_mp_boost'
}

_reive.defaults = T{}
_reive.defaults.v              = 0
_reive.defaults.first_run      = true
_reive.defaults.reset_on_start = false -- deprecated
_reive.defaults.max_scores     = 5

_reive.defaults.track = T{}
_reive.defaults.track.hp_recovery        = true
_reive.defaults.track.mp_recovery        = true
_reive.defaults.track.tp_recovery        = true
_reive.defaults.track.status_recovery    = true
_reive.defaults.track.stoneskin          = true
_reive.defaults.track.abilities_recovery = true
_reive.defaults.track.hp_mp_boost        = true

_reive.defaults.position = T{}
_reive.defaults.position.x = 0
_reive.defaults.position.y = 350

_reive.defaults.font = T{}
_reive.defaults.font.family = 'Arial'
_reive.defaults.font.size   = 10
_reive.defaults.font.a      = 255
_reive.defaults.font.bold   = false
_reive.defaults.font.italic = false

_reive.defaults.colors = T{}
_reive.defaults.colors.background = T{}
_reive.defaults.colors.background.r = 0
_reive.defaults.colors.background.g = 43
_reive.defaults.colors.background.b = 54
_reive.defaults.colors.background.a = 200

_reive.defaults.colors.reive = T{}
_reive.defaults.colors.reive.title = T{}
_reive.defaults.colors.reive.title.r = 220
_reive.defaults.colors.reive.title.g = 50
_reive.defaults.colors.reive.title.b = 47

_reive.defaults.colors.reive.label = T{}
_reive.defaults.colors.reive.label.r = 38
_reive.defaults.colors.reive.label.g = 139
_reive.defaults.colors.reive.label.b = 210

_reive.defaults.colors.reive.value = T{}
_reive.defaults.colors.reive.value.r = 147
_reive.defaults.colors.reive.value.g = 161
_reive.defaults.colors.reive.value.b = 161

_reive.defaults.colors.score = T{}
_reive.defaults.colors.score.title = T{}
_reive.defaults.colors.score.title.r = 220
_reive.defaults.colors.score.title.g = 50
_reive.defaults.colors.score.title.b = 47

_reive.defaults.colors.score.label = T{}
_reive.defaults.colors.score.label.r = 42
_reive.defaults.colors.score.label.g = 161
_reive.defaults.colors.score.label.b = 152

_reive.defaults.colors.bonus = T{}
_reive.defaults.colors.bonus.title = T{}
_reive.defaults.colors.bonus.title.r = 220
_reive.defaults.colors.bonus.title.g = 50
_reive.defaults.colors.bonus.title.b = 47

_reive.defaults.colors.bonus.label = T{}
_reive.defaults.colors.bonus.label.r = 133
_reive.defaults.colors.bonus.label.g = 153
_reive.defaults.colors.bonus.label.b = 0

_reive.defaults.colors.bonus.value = T{}
_reive.defaults.colors.bonus.value.r = 147
_reive.defaults.colors.bonus.value.g = 161
_reive.defaults.colors.bonus.value.b = 161

_reive.settings = T{}

-- plugin functions

function _reive.parseOptions(args)
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

function _reive.test()
    _reive.start()
    add_to_chat(121, 'Reive momentum score: HP recovery.')
    add_to_chat(121, 'Momentum bonus: Ability cast recovery!')
    add_to_chat(121, 'Reive momentum score: Damage taken.')
    add_to_chat(121, 'Momentum bonus: Status ailment recovery!')
    add_to_chat(121, 'Reive momentum score: Physical attack.')
    add_to_chat(121, 'Momentum bonus: Stoneskin!')
    add_to_chat(121, 'Reive momentum score: Attack success.')
    add_to_chat(121, 'Momentum bonus: HP recovery!')
    add_to_chat(121, 'Reive momentum score: HP recovery.')
    add_to_chat(121, 'Momentum bonus: TP recovery!')
    add_to_chat(121, 'Reive momentum score: Damage taken.')
    add_to_chat(121, 'Momentum bonus: Increased maximum HP and MP!')
    add_to_chat(121, 'Reive momentum score: Physical attack.')
    add_to_chat(131, 'Player gains 408 limit points.')
    add_to_chat(121, 'Player obtained 291 bayld!')
    add_to_chat(121, 'Player obtained 329 bayld!')
    add_to_chat(121, 'Player obtained 405 bayld!')
    add_to_chat(131, 'Player gains 426 limit points.')
end

function _reive.start()
	_reive.reset()
    _reive.track = true
    add_to_chat(0, '\30\03The Reive has begun!\30\01')
    _reive.show()
end

function _reive.stop()
    _reive.stats.scores  = T{}
    _reive.stats.bonuses = T{}

    _reive.track = false
    add_to_chat(0, '\30\03The Reive has ended\30\01')
    _reive.hide()
    _reive.status()
end

function _reive.refresh()
    if _reive.visible == false then
        return
    end

    local reiveColors = _reive.settings.colors.reive
    local text        =
        ' \\cs('..reiveColors.title.r..', '..reiveColors.title.g..', '..reiveColors.title.b..')--== REIVE ==--\\cr \n'..
        ' \\cs('..reiveColors.label.r..', '..reiveColors.label.g..', '..reiveColors.label.b..')Bayld:\\cr'..
        ' \\cs('..reiveColors.value.r..', '..reiveColors.value.g..', '..reiveColors.value.b..')'.._reive.stats.bayld..'/'.._reive.stats.totBayld..'\\cr \n'..
        ' \\cs('..reiveColors.label.r..', '..reiveColors.label.g..', '..reiveColors.label.b..')EXP:\\cr'..
        ' \\cs('..reiveColors.value.r..', '..reiveColors.value.g..', '..reiveColors.value.b..')'.._reive.stats.exp..'/'.._reive.stats.totExp..'\\cr '

    local scoresColors = _reive.settings.colors.score
    local scores       = '';

    if #_reive.stats.scores > 0 then
        local base = math.max(0, #_reive.stats.scores - _reive.settings.max_scores)

        for index, score in pairs(_reive.stats.scores:slice(base + 1, #_reive.stats.scores)) do
            scores = scores..
                '\n \\cs('..scoresColors.label.r..', '..scoresColors.label.g..', '..scoresColors.label.b..')'..(base + index)..'. '..score..'\\cr  '
        end

        text = text..'\n \\cs('..scoresColors.title.r..', '..scoresColors.title.g..', '..scoresColors.title.b..')--== MOMENTUM SCORES ==--\\cr '..scores
    end

    local bonusesColors = _reive.settings.colors.bonus
    local bonuses       = '';

    for index, bonus in pairs(_reive.stats.bonuses:keyset():sort()) do
        if type(_reive.bonuses_map[bonus]) == 'nil' or _reive.settings.track[_reive.bonuses_map[bonus]] == true then
            local amount = _reive.stats.bonuses[bonus]

            bonuses = bonuses..
                '\n \\cs('..bonusesColors.label.r..', '..bonusesColors.label.g..', '..bonusesColors.label.b..')'..bonus..':\\cr'..
                ' \\cs('..bonusesColors.value.r..', '..bonusesColors.value.g..', '..bonusesColors.value.b..')'..amount..'\\cr '
        end
    end

    if #bonuses > 0 then
        text = text..'\n \\cs('..bonusesColors.title.r..', '..bonusesColors.title.g..', '..bonusesColors.title.b..')--== MOMENTUM BONUSES ==--\\cr '..bonuses
    end

    tb_set_text(_reive.tb_name, text)
end

function _reive.reset()
    _reive.stats.exp   = 0
    _reive.stats.bayld = 0
    _reive.refresh()
end

function _reive.fullReset()
    _reive.stats.totExp   = 0
    _reive.stats.totBayld = 0
	_reive.reset()
    _reive.refresh()
end

function _reive.show()
    _reive.visible = true
    tb_set_visibility(_reive.tb_name, true)
    _reive.refresh()
end

function _reive.hide()
    _reive.visible = false
    tb_set_visibility(_reive.tb_name, false)
end

function _reive.toggle()
    if _reive.visible then
        _reive.hide()
    else
        _reive.show()
    end
end

function _reive.status()
    add_to_chat(0, '\30\03[EXP\30\01 \30\02'.._reive.stats.exp..'/'.._reive.stats.totExp..'\30\01\30\03] [Bayld\30\01 \30\02'.._reive.stats.bayld..'/'.._reive.stats.totBayld..'\30\01\30\03]\30\01')
end

function _reive.first_run()
    if ( type(_reive.settings.v) ~= 'nil' and _reive.settings.v >= tonumber(_reive.v) and _reive.settings.first_run == false ) then
        return
    end

    add_to_chat(55, 'hi '..get_player()['name']:lower()..',')
    add_to_chat(55, 'thank you for using reive v'.._reive.v)
    add_to_chat(55, 'in this new version the addon will show both current and total gained bayld and exp in the "current/total" format.')
    add_to_chat(55, 'as of this now the "reset_on_start" parameter has no use anymore and has been removed.')
    add_to_chat(55, '- zohno@phoenix')

    _reive.settings.v = _reive.v
    _reive.settings.first_run = false
    _reive.settings:save('all')
end

-- windower events

function event_load()
    _reive.settings = config.load(_reive.defaults)

    local background = _reive.settings.colors.background

    send_command('alias reive lua c reive')
    tb_create(_reive.tb_name)
    tb_set_location(_reive.tb_name, _reive.settings.position.x, _reive.settings.position.y)
    tb_set_bg_color(_reive.tb_name, background.a, background.r, background.g, background.b)
    tb_set_color(_reive.tb_name, _reive.settings.font.a, 147, 161, 161)
    tb_set_font(_reive.tb_name, _reive.settings.font.family, _reive.settings.font.size)
    tb_set_bold(_reive.tb_name, _reive.settings.font.bold)
    tb_set_italic(_reive.tb_name, _reive.settings.font.italic)
    tb_set_text(_reive.tb_name, '')
    tb_set_bg_visibility(_reive.tb_name, true)

    if T(get_player()['buffs']):contains(511) then
        _reive.start()
    end
end

function event_unload()
    send_command('unalias reive')
    tb_delete(_reive.tb_name)
end

function event_login()
    _reive.first_run()
end

function event_gain_status(id, name)
    if id == 511 then
        _reive.start()
    end
end

function event_lose_status(id, name)
    if id == 511 then
        _reive.stop()
    end
end

function event_incoming_text(original, modified, mode)
    local match

    if mode == 121 then
        match = original:match('Reive momentum score: ([%s%w]+)%.')

        if match then
            _reive.stats.scores:append(match)
            _reive.refresh()

            return modified, mode
        end

        match = original:match('Momentum bonus: ([%s%w]+)!')

        if match then
            if type(_reive.stats.bonuses[match]) == 'nil' then
                _reive.stats.bonuses[match] = 0
            end

            _reive.stats.bonuses[match] = _reive.stats.bonuses[match] + 1
            _reive.refresh()

            return modified, mode
        end

        match = original:match('obtained (%d+) bayld!')

        if match and _reive.track then
            _reive.stats.bayld    = _reive.stats.bayld + match
            _reive.stats.totBayld = _reive.stats.totBayld + match
            _reive.refresh()
        end
    elseif mode == 131 and _reive.track then
        match = original:match('gains (%d+) limit points%.')

        if match then
            _reive.stats.exp    = _reive.stats.exp + match
            _reive.stats.totExp = _reive.stats.totExp + match
            _reive.refresh()

            return modified, mode
        end

        match = original:match('gains (%d+) experience points%.')

        if match then
            _reive.stats.exp = _reive.stats.exp + match
            _reive.refresh()

            return modified, mode
        end
    end

    return modified, mode
end

function event_addon_command(...)
    local args     = T({...})
    local messages = T{}
    local errors   = T{}

	if args[1] == nil then
        send_command('reive help')
        return
    end

    local cmd = args:remove(1):lower()

    if cmd == 'help' then
        messages:append('help >> reive test -- fills the chat log to show how the plugin will work. reload the plugin after the test (lua r reive)')
        messages:append('help >> reive reset -- sets gained exp and bayld to 0')
        messages:append('help >> reive full-reset -- sets gained exp/total exp and bayld/total bayld to 0')
        messages:append('help >> reive show -- shows the tracking window')
        messages:append('help >> reive hide -- hides the tracking window')
        messages:append('help >> reive toggle -- toggles the tracking window')
        messages:append('help >> reive max-scores \30\02amount\30\01 -- sets the max amount of scores to show in the window')
        messages:append('help >> reive track \30\02score\30\01 \30\02visible\30\01 -- specifies the visibility of a score in the window')
        messages:append('help >> reive position [[-h]|[-x \30\02x\30\01] [-y \30\02y\30\01]] -- sets the horizontal and vertical position of the window relative to the upper-left corner')
        messages:append('help >> reive font [[-h]|[-f \30\02font\30\01] [-s \30\02size\30\01] [-a \30\02alpha\30\01] [-b[ \30\02bold\30\01]] [-i[ \30\02italic\30\01]]] -- sets the style of the font used in the window')
        messages:append('help >> reive color [[-h]|[-o \30\02objects\30\01] [-d] [-r \30\02red\30\01] [-g \30\02green\30\01] [-b \30\02blue\30\01] [-a \30\02alpha\30\01]] -- sets the colors used by the plugin')
    elseif cmd == 'test' then
        _reive.test()
    elseif cmd == 'reset' then
        _reive.reset()
    elseif cmd == 'full-reset' then
        _reive.fullReset()
    elseif cmd == 'show' then
        _reive.show()
    elseif cmd == 'hide' then
        _reive.hide()
    elseif cmd == 'toggle' then
        _reive.toggle()
    elseif cmd == 'max-scores' then
        local max_scores

        if type(args[1]) == 'nil' then
            messages:append('max-scores >> sets the max amount of scores to show in the window')
            messages:append('max-scores >> usage: reive max-scores \30\02amount\30\01')
            messages:append('max-scores >> positional arguments:')
            messages:append('max-scores >>   amount    the max amount of scores to show')
        elseif args[1] == 'default' then
            max_scores = _reive.defaults.max_scores
        else
            max_scores = tonumber(args[1])
        end

        if type(max_scores) ~= "number" then
            errors:append('max-scores >> max-scores expects \'amount\' to be a number or \'default\' (without quotes)')
        end

        if errors:length() == 0 then
            _reive.settings.max_scores = max_scores

            _reive.refresh()
            _reive.settings:save('all')
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
            messages:append('track >> specifies the visibility of a score in the window')
            messages:append('track >> usage: reive track \30\02score\30\01 \30\02visible\30\01')
            messages:append('track >> positional arguments:')
            messages:append('track >>   score    the name of the score. accepted values are: '..validObjects:concat(', '))
            messages:append('track >>   visible  the visibility of the score (true/false/1/0/default)')
        elseif validObjects:contains(args[1]) then
            object = args[1]:gsub('-', '_')

            if args[2] == 'true' or args[2] == '1' or args[2] == 'default' then
                visible = true
            elseif args[2] == 'false' or args[2] == '0' then
                visible = false
            else
                errors:append('track >> track expects \'visible\' to be a boolean (\'true\' or \'false\'), a number (\'1\' or \'0\') or \'default\' (without quotes)')
            end

            if errors:length() == 0 then
                _reive.settings.track[object] = visible

                _reive.refresh()
                _reive.settings:save('all')
            end
        else
            errors:append('track >> track expects \'score\' to be one of the following values: '..validObjects:concat(', '))
        end
    else
        local options = _reive.parseOptions(args)

        if cmd == 'position' then
            if options:containskey('h') or options:length() == 0 then
                messages:append('position >> sets the horizontal and vertical position of the window relative to the upper-left corner')
                messages:append('position >> usage: reive position [[-h]|[-x \30\02x\30\01] [-y \30\02y\30\01]]')
                messages:append('position >> optional arguments:')
                messages:append('position >>   -h    show this message and exit')
                messages:append('position >>   -x    the horizontal position of the window relative to the upper-left corner')
                messages:append('position >>   -y    the vertical position of the window relative to the upper-left corner')
            elseif options:length() > 0 then
                local x = _reive.settings.position.x
                local y = _reive.settings.position.y

                for key, value in pairs(options) do
                    if key == 'x' then
                        if options['x'] == 'default' then
                            x = _reive.defaults.position.x
                        else
                            x = tonumber(options['x'])

                            if type(x) ~= "number" then
                                errors:append('position >> position expects \'x\' to be a number or \'default\' (without quotes)')
                            end
                        end
                    elseif key == 'y' then
                        if options['y'] == 'default' then
                            y = _reive.defaults.position.y
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
                    _reive.settings.position.x = x
                    _reive.settings.position.y = y

                    tb_set_location(_reive.tb_name, x, y)
                    _reive.settings:save('all')
                end
            end
        elseif cmd == 'font' then
            if options:containskey('h') or options:length() == 0 then
                messages:append('font >> sets the style of the font used in the window')
                messages:append('font >> usage: reive font [[-h]|[-f \30\02font\30\01] [-s \30\02size\30\01] [-a \30\02alpha\30\01] [-b[ \30\02bold\30\01]] [-i[ \30\02italic\30\01]]]')
                messages:append('font >> optional arguments:')
                messages:append('font >>   -h    show this message and exit')
                messages:append('font >>   -f    the name of the font to use')
                messages:append('font >>   -s    the size of the text')
                messages:append('font >>   -a    the text transparency between 0 (transparent) and 255 (opaque)')
                messages:append('font >>   -b    makes the text bold (null/true/false/1/0/default)')
                messages:append('font >>   -i    makes the text italic (null/true/false/1/0/default)')
            elseif options:length() > 0 then
                local family = _reive.settings.font.family
                local size   = _reive.settings.font.size
                local bold   = _reive.settings.font.bold
                local italic = _reive.settings.font.italic
                local a      = _reive.settings.font.a

                for key, value in pairs(options) do
                    if key == 'f' then
                        if options['f'] == 'default' then
                            family = _reive.defaults.font.family
                        else
                            family = options['f']
                        end
                    elseif key == 's' then
                        if options['s'] == 'default' then
                            size = _reive.defaults.position.size
                        else
                            size = tonumber(options['s'])

                            if type(size) ~= "number" then
                                errors:append('font >> font expects \'size\' to be a number or \'default\' (without quotes)')
                            end
                        end
                    elseif key == 'b' then
                        if options['b'] == 'default' then
                            bold = _reive.defaults.position.bold
                        elseif options['b'] == true or options['b'] == '1' or options['b'] == 'true' or options['b'] == 'null' then
                            bold = true
                        elseif options['b'] == '0' or options['b'] == 'false' then
                            bold = false
                        else
                            errors:append('font >> font expects \'bold\' to be null (\'true\'), a boolean (\'true\' or \'false\'), a number (\'1\' or \'0\') or \'default\' (without quotes)')
                        end
                    elseif key == 'i' then
                        if options['i'] == 'default' then
                            italic = _reive.defaults.position.italic
                        elseif options['b'] == true or options['i'] == '1' or options['i'] == 'true' or options['i'] == 'null' then
                            italic = true
                        elseif options['i'] == '0' or options['i'] == 'false' then
                            italic = false
                        else
                            errors:append('font >> font expects \'italic\' to be a number (\'0\' or \'1\'), a boolean (\'false\' or \'true\') or \'default\' (without quotes)')
                        end
                    elseif key == 'a' then
                        if options['a'] == 'default' then
                            a = _reive.defaults.position.a
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
                    _reive.settings.font.family = family
                    _reive.settings.font.size   = size
                    _reive.settings.font.bold   = bold
                    _reive.settings.font.italic = italic
                    _reive.settings.font.a      = a

                    tb_set_color(_reive.tb_name, a, 147, 161, 161)
                    tb_set_font(_reive.tb_name, family, size)
                    tb_set_bold(_reive.tb_name, bold)
                    tb_set_italic(_reive.tb_name, italic)
                    _reive.settings:save('all')
                end
            end
        elseif cmd == 'color' then
            local validObjects = T{
                'all', 'background', 'bg', 'title', 'label', 'value',
                'reive', 'reive.title', 'reive.label', 'reive.value',
                'score', 'score.title', 'score.label',
                'bonus', 'bonus.title', 'bonus.label', 'bonus.value'
            }

            if options:containskey('h') or options:length() == 0 then
                messages:append('color >> sets the colors used by the plugin')
                messages:append('color >> usage: reive color [[-h]|[-o \30\02objects\30\01] [-d] [-r \30\02red\30\01] [-g \30\02green\30\01] [-b \30\02blue\30\01] [-a \30\02alpha\30\01]]')
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
                        errors:append('color >> color expects \'o\' to be one of the following values: '..validObjects:concat(', '))
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
                                _reive.settings.colors[indexes[1]][indexes[2]].r = _reive.defaults.colors[indexes[1]][indexes[2]].r
                            else
                                _reive.settings.colors[indexes[1]][indexes[2]].r = r
                            end

                            if g == -1 then
                                _reive.settings.colors[indexes[1]][indexes[2]].g = _reive.defaults.colors[indexes[1]][indexes[2]].g
                            else
                                _reive.settings.colors[indexes[1]][indexes[2]].g = g
                            end

                            if b == -1 then
                                _reive.settings.colors[indexes[1]][indexes[2]].b = _reive.defaults.colors[indexes[1]][indexes[2]].b
                            else
                                _reive.settings.colors[indexes[1]][indexes[2]].b = b
                            end
                        elseif indexes:length() == 1 then
                            if r == -1 then
                                _reive.settings.colors[indexes[1]].r = _reive.defaults.colors[indexes[1]].r
                            else
                                _reive.settings.colors[indexes[1]].r = r
                            end

                            if g == -1 then
                                _reive.settings.colors[indexes[1]].g = _reive.defaults.colors[indexes[1]].g
                            else
                                _reive.settings.colors[indexes[1]].g = g
                            end

                            if b == -1 then
                                _reive.settings.colors[indexes[1]].b = _reive.defaults.colors[indexes[1]].b
                            else
                                _reive.settings.colors[indexes[1]].b = b
                            end

                            if a == -1 then
                                _reive.settings.colors[indexes[1]].a = _reive.defaults.colors[indexes[1]].a
                            else
                                _reive.settings.colors[indexes[1]].a = a
                            end

                            tb_set_bg_color(
                                _reive.tb_name,
                                _reive.settings.colors[indexes[1]].a,
                                _reive.settings.colors[indexes[1]].r,
                                _reive.settings.colors[indexes[1]].g,
                                _reive.settings.colors[indexes[1]].b
                            )
                        end
                    end

                    _reive.refresh()
                    _reive.settings:save('all')
                end
            end
        else
            send_command('reive help')
        end
    end

    for key, message in pairs(errors) do
        add_to_chat(38, 'lua:addon:reive:'..message)
    end

    for key, message in pairs(messages) do
        add_to_chat(55,'lua:addon:reive:'..message)
    end
end