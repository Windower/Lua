--[[
reive v1.20130515

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

require 'tablehelper'
local config = require 'config'

local _reive = {}
_reive.tb_name        = 'addon:gr:reive'
_reive.track          = false
_reive.reset_on_start = false
_reive.visible        = false
_reive.stats          = {}
_reive.stats.exp      = 0
_reive.stats.bayld    = 0
_reive.stats.scores   = T{}
_reive.stats.bonuses  = {}

_reive.defaults = {}
_reive.defaults.reset_on_start = false
_reive.defaults.max_scores = 5
_reive.defaults.position = {}
_reive.defaults.position.x = 0
_reive.defaults.position.y = 350
_reive.defaults.font = {}
_reive.defaults.font.family = 'Arial'
_reive.defaults.font.size   = 10
_reive.defaults.font.italic = false
_reive.defaults.font.bold   = false
_reive.defaults.font.a      = 255
_reive.defaults.colors = {}
_reive.defaults.colors.background = {}
_reive.defaults.colors.background.r = 0
_reive.defaults.colors.background.g = 43
_reive.defaults.colors.background.b = 54
_reive.defaults.colors.background.a = 200
_reive.defaults.colors.reive = {}
_reive.defaults.colors.reive.title = {}
_reive.defaults.colors.reive.title.r = 220
_reive.defaults.colors.reive.title.g = 50
_reive.defaults.colors.reive.title.b = 47
_reive.defaults.colors.reive.label = {}
_reive.defaults.colors.reive.label.r = 38
_reive.defaults.colors.reive.label.g = 139
_reive.defaults.colors.reive.label.b = 210
_reive.defaults.colors.reive.value = {}
_reive.defaults.colors.reive.value.r = 147
_reive.defaults.colors.reive.value.g = 161
_reive.defaults.colors.reive.value.b = 161
_reive.defaults.colors.score = {}
_reive.defaults.colors.score.title = {}
_reive.defaults.colors.score.title.r = 220
_reive.defaults.colors.score.title.g = 50
_reive.defaults.colors.score.title.b = 47
_reive.defaults.colors.score.label = {}
_reive.defaults.colors.score.label.r = 42
_reive.defaults.colors.score.label.g = 161
_reive.defaults.colors.score.label.b = 152
_reive.defaults.colors.bonus = {}
_reive.defaults.colors.bonus.title = {}
_reive.defaults.colors.bonus.title.r = 220
_reive.defaults.colors.bonus.title.g = 50
_reive.defaults.colors.bonus.title.b = 47
_reive.defaults.colors.bonus.label = {}
_reive.defaults.colors.bonus.label.r = 133
_reive.defaults.colors.bonus.label.g = 153
_reive.defaults.colors.bonus.label.b = 0
_reive.defaults.colors.bonus.value = {}
_reive.defaults.colors.bonus.value.r = 147
_reive.defaults.colors.bonus.value.g = 161
_reive.defaults.colors.bonus.value.b = 161

_reive.settings = {}

function event_addon_command(cmd)
    if cmd == 'test' then
        _reive.test()
    elseif cmd == 'reset' then
        _reive.reset()
    elseif cmd == 'show' then
        _reive.show()
    elseif cmd == 'hide' then
        _reive.hide()
    elseif cmd == 'toggle' then
        _reive.toggle()
    end
end

function _reive:test(...)
    _reive:start()
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

function _reive:start(...)
    if _reive.reset_on_start == true then
        _reive:reset()
    end

    _reive.track = true
    add_to_chat(0, '\30\03The Reive has begun!\30\01')
    _reive:show()
end

function _reive:stop(...)
    _reive.stats.scores  = T{}
    _reive.stats.bonuses = {}

    _reive.track = false
    add_to_chat(0, '\30\03The Reive has ended\30\01')
    _reive:hide()
    _reive:status()
end

function _reive:refresh(...)
    if _reive.visible == false then
        return
    end

    local reiveColors = _reive.settings.colors.reive
    local text        =
        ' \\cs('..reiveColors.title.r..', '..reiveColors.title.g..', '..reiveColors.title.b..')--== REIVE ==--\\cr \n'..
        ' \\cs('..reiveColors.label.r..', '..reiveColors.label.g..', '..reiveColors.label.b..')Bayld:\\cr'..
        ' \\cs('..reiveColors.value.r..', '..reiveColors.value.g..', '..reiveColors.value.b..')'.._reive.stats.bayld..'\\cr \n'..
        ' \\cs('..reiveColors.label.r..', '..reiveColors.label.g..', '..reiveColors.label.b..')EXP:\\cr'..
        ' \\cs('..reiveColors.value.r..', '..reiveColors.value.g..', '..reiveColors.value.b..')'.._reive.stats.exp..'\\cr '

    local scoresColors = _reive.settings.colors.score
    local scores       = '';

    if #_reive.stats.scores > 0 then
        for index, score in pairs(_reive.stats.scores:slice(math.max(1, #_reive.stats.scores-_reive.settings.max_scores + 1), #_reive.stats.scores)) do
            scores = scores..
                '\n \\cs('..scoresColors.label.r..', '..scoresColors.label.g..', '..scoresColors.label.b..')'..score..'\\cr  '
        end

        if #scores > 0 then
            text = text..'\n \\cs('..scoresColors.title.r..', '..scoresColors.title.g..', '..scoresColors.title.b..')--== MOMENTUM SCORES ==--\\cr '..scores
        end
    end

    local bonusesColors = _reive.settings.colors.bonus
    local bonuses       = '';

    for bonus, amount in pairs(_reive.stats.bonuses) do
        bonuses = bonuses..
            '\n \\cs('..bonusesColors.label.r..', '..bonusesColors.label.g..', '..bonusesColors.label.b..')'..bonus..':\\cr'..
            ' \\cs('..bonusesColors.value.r..', '..bonusesColors.value.g..', '..bonusesColors.value.b..')'..amount..'\\cr '
    end

    if #bonuses > 0 then
        text = text..'\n \\cs('..bonusesColors.title.r..', '..bonusesColors.title.g..', '..bonusesColors.title.b..')--== MOMENTUM BONUSES ==--\\cr '..bonuses
    end

    tb_set_text(_reive.tb_name, text)
end

function _reive:reset(...)
    _reive.stats.exp   = 0
    _reive.stats.bayld = 0
    _reive:refresh()
end

function _reive:show(...)
    _reive.visible = true
    tb_set_visibility(_reive.tb_name, true)
    _reive:refresh()
end

function _reive:hide(...)
    _reive.visible = false
    tb_set_visibility(_reive.tb_name, false)
end

function _reive:toggle(...)
    if _reive.visible then
        _reive:hide()
    else 
        _reive:show()
    end
end

function _reive:status(...)
    add_to_chat(0, '\30\03[EXP\30\01 \30\02'.._reive.stats.exp..'\30\01\30\03] [Bayld\30\01 \30\02'.._reive.stats.bayld..'\30\01\30\03]\30\01')
end

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
        _reive:start()
    end
end

function event_unload()
    send_command('unalias reive')
    tb_delete(_reive.tb_name)
end

function event_gain_status(id, name)
    if id == 511 then
        _reive:start()
    end
end

function event_lose_status(id, name)
    if id == 511 then
        _reive:stop()
    end
end

function event_incoming_text(original, modified, mode)
    local match

    if mode == 121 then
        match = original:match('Reive momentum score: ([%s%w]+)%.')

        if match then
            _reive.stats.scores:append(match)
            _reive:refresh()

            return modified, mode
        end

        match = original:match('Momentum bonus: ([%s%w]+)!')

        if match then
            if type(_reive.stats.bonuses[match]) == 'nil' then
                _reive.stats.bonuses[match] = 0
            end

            _reive.stats.bonuses[match] = _reive.stats.bonuses[match] + 1
            _reive:refresh()

            return modified, mode
        end

        match = original:match('obtained (%d+) bayld!')

        if match and _reive.track then
            _reive.stats.bayld = _reive.stats.bayld + match
            _reive:refresh()
        end
    elseif mode == 131 and _reive.track then
        match = original:match('gains (%d+) limit points%.')

        if match then
            _reive.stats.exp = _reive.stats.exp + match
            _reive:refresh()

            return modified, mode
        end

        match = original:match('gains (%d+) experience points%.')

        if match then
            _reive.stats.exp = _reive.stats.exp + match
            _reive:refresh()

            return modified, mode
        end
    end

    return modified, mode
end