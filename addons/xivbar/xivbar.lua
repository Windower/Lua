--[[
        Copyright © 2017, SirEdeonX
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of xivbar nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- Addon description
_addon.name = 'XIV Bar'
_addon.author = 'Edeon'
_addon.version = '1.0'
_addon.language = 'english'

-- Libs
config = require('config')
texts  = require('texts')
images = require('images')

-- User settings
local defaults = require('defaults')
local settings = config.load(defaults)
config.save(settings)

-- Load theme options according to settings
local theme = require('theme')
local theme_options = theme.apply(settings)

-- Addon Dependencies
local ui = require('ui')
local player = require('player')
local xivbar = require('variables')

-- initialize addon
function initialize()
    ui:load(theme_options)

    local windower_player = windower.ffxi.get_player()

    if windower_player ~= nil then
        player.hpp = windower_player.vitals.hpp
        player.mpp = windower_player.vitals.mpp
        player.current_hp = windower_player.vitals.hp
        player.current_mp = windower_player.vitals.mp
        player.current_tp = windower_player.vitals.tp

        player:calculate_tpp()
    end

    xivbar.initialized = true
end

-- update a bar
function update_bar(bar, text, width, current, pp, flag)
    local old_width = width
    local new_width = math.floor((pp / 100) * theme_options.bar_width)

    if new_width ~= nil and new_width >= 0 then
        if old_width == new_width then
            if new_width == 0 then
                bar:hide()
            end

            if flag == 1 then
                xivbar.hp_update = false
            elseif flag == 2 then
                xivbar.update_mp = false
            elseif flag == 3 then
                xivbar.update_tp = false
            end
        else
            local x = old_width

            if old_width < new_width then
                x = old_width + math.ceil((new_width - old_width) * 0.1)

                x = math.min(x, theme_options.bar_width)
            elseif old_width > new_width then
                x = old_width - math.ceil((old_width - new_width) * 0.1)

                x = math.max(x, 0)
            end

            if flag == 1 then
                xivbar.hp_bar_width = x
            elseif flag == 2 then
                xivbar.mp_bar_width = x
            elseif flag == 3 then
                xivbar.tp_bar_width = x
            end

            bar:size(x, theme_options.total_height)
            bar:show()
        end
    end

    if flag == 3 and current >= 1000 then
        text:color(theme_options.full_tp_color_red, theme_options.full_tp_color_green, theme_options.full_tp_color_blue)
        if theme_options.dim_tp_bar then bar:alpha(255) end
    else
        text:color(theme_options.font_color_red, theme_options.font_color_green, theme_options.font_color_blue)
        if theme_options.dim_tp_bar then bar:alpha(180) end
    end

    text:text(tostring(current))
end

-- hide the addon
function hide()
    ui:hide()
    xivbar.ready = false
end

-- show the addon
function show()
    if xivbar.initialized == false then
        initialize()
    end

    ui:show()
    xivbar.ready = true
    xivbar.update_hp = true
    xivbar.update_mp = true
    xivbar.update_tp = true
end


-- Bind Events
-- ON LOAD
windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        initialize()
        show()
    end
end)

-- ON LOGIN
windower.register_event('login', function()
    show()
end)

-- ON LOGOUT
windower.register_event('logout', function()
    hide()
end)

-- BIND EVENTS
windower.register_event('hp change', function(new, old)
    player.current_hp = new
    xivbar.update_hp = true
end)

windower.register_event('hpp change', function(new, old)
    player.hpp = new
    xivbar.update_hp = true
end)

windower.register_event('mp change', function(new, old)
    player.current_mp = new
    xivbar.update_mp = true
end)

windower.register_event('mpp change', function(new, old)
    player.mpp = new
    xivbar.update_mp = true
end)

windower.register_event('tp change', function(new, old)
    player.current_tp = new
    player:calculate_tpp()
    xivbar.update_tp = true
end)

windower.register_event('prerender', function()
    if xivbar.ready == false then
        return
    end

    if xivbar.update_hp then
        update_bar(ui.hp_bar, ui.hp_text, xivbar.hp_bar_width, player.current_hp, player.hpp, 1)
    end

    if xivbar.update_mp then
        update_bar(ui.mp_bar, ui.mp_text, xivbar.mp_bar_width, player.current_mp, player.mpp, 2)
    end

    if xivbar.update_tp then
        update_bar(ui.tp_bar, ui.tp_text, xivbar.tp_bar_width, player.current_tp, player.tpp, 3)
    end
end)

windower.register_event('status change', function(new_status_id)
    if xivbar.hide_bars == false and (new_status_id == 4) then
        xivbar.hide_bars = true
        hide()
    elseif xivbar.hide_bars and new_status_id ~= 4 then
        xivbar.hide_bars = false
        show()
    end
end)