--[[    BSD License Disclaimer
        Copyright © 2017, sylandro
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of giltracker nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL sylandro BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'giltracker'
_addon.author = 'sylandro'
_addon.version = '1.0.0'
_addon.language = 'English'

config = require('config')
images = require('images')
texts = require('texts')

local GIL_ITEM_ID = 0xFFFF
local CUTSCENE_STATUS_ID = 4
local SCROLL_LOCK_KEY = 70
local MAX_TIME_AFTER_STARTING = 180
local STOP_DOWNLOADING_PACKET = 0x0041

hideKey = SCROLL_LOCK_KEY
is_hidden_by_cutscene = false
is_hidden_by_key = false

defaults = {}
defaults.hideKey = SCROLL_LOCK_KEY
defaults.gilText = {}
defaults.gilText.bg = {}
defaults.gilText.bg.alpha = 100
defaults.gilText.bg.red = 0
defaults.gilText.bg.green = 0
defaults.gilText.bg.blue = 0
defaults.gilText.bg.visible = false
defaults.gilText.text = {}
defaults.gilText.text.font = 'sans-serif'
defaults.gilText.text.fonts = {'Arial','Trebuchet MS'}
defaults.gilText.text.size = 9
defaults.gilText.flags = {}
defaults.gilText.flags.italic = true
defaults.gilText.flags.bold = false
defaults.gilText.flags.right = true
defaults.gilText.flags.bottom = true
defaults.gilText.pos = {}
defaults.gilText.pos.x = -285
defaults.gilText.pos.y = -35
defaults.gilText.text.alpha = 255
defaults.gilText.text.red = 253
defaults.gilText.text.green = 252
defaults.gilText.text.blue = 250
defaults.gilText.text.stroke = {}
defaults.gilText.text.stroke.alpha = 200
defaults.gilText.text.stroke.red = 50
defaults.gilText.text.stroke.green = 50
defaults.gilText.text.stroke.blue = 50
defaults.gilText.text.stroke.width = 2
defaults.gilText.text.visible = true
defaults.gilImage = {}
defaults.gilImage.color = {}
defaults.gilImage.color.alpha = 255
defaults.gilImage.color.red = 255
defaults.gilImage.color.green = 255
defaults.gilImage.color.blue = 255
defaults.gilImage.visible = true

local settings = config.load(defaults)
config.save(settings)

settings.gilImage.texture = {}
settings.gilImage.texture.path = windower.addon_path..'gil.png'
settings.gilImage.texture.fit = true
settings.gilImage.size = {}
settings.gilImage.size.height = 23
settings.gilImage.size.width = 23
settings.gilImage.draggable = false
settings.gilImage.repeatable = {}
settings.gilImage.repeatable.x = 1
settings.gilImage.repeatable.y = 1
local start_time = 0

gil_image = images.new(settings.gilImage)
gil_text = texts.new(settings.gilText)

config.register(settings, function(settings)
    hideKey = settings.hideKey
end)

windower.register_event('load',function()
    if windower.ffxi.get_info().logged_in then
        initialize()
    end
end)

windower.register_event('login', function()
    initialize()
    start_time = os.time()
end)

windower.register_event('logout', function(...)
    hide()
end)

windower.register_event('add item', function(_bag, _slot, id, _count)
    update_gil_if_item_id_matches(id)
end)

windower.register_event('remove item', function(_bag, _slot, id, _count)
    update_gil_if_item_id_matches(id)
end)

windower.register_event('incoming chunk',function(id,_org,_modi,_is_injected,_is_blocked)
    if (is_during_login_time() and id == STOP_DOWNLOADING_PACKET) then
        update_gil()
    end
end)

windower.register_event('incoming text', function(original, ...)
    update_gil_if_string_contains_gil(original)
end)

windower.register_event('status change', function(new_status_id)
    local is_cutscene_playing = is_cutscene(new_status_id)
    toggle_display_if_cutscene(is_cutscene_playing)
end)

windower.register_event('keyboard', function(dik, down, _flags, _blocked)
    toggle_display_if_hide_key_is_pressed(dik, down)
end)

function is_during_login_time()
    return os.time() - start_time < MAX_TIME_AFTER_STARTING
end

function initialize()
    local windower_settings = windower.get_windower_settings()
    local xRes = windower_settings.ui_x_res
    local yRes = windower_settings.ui_y_res
    update_gil()
    gil_image:pos(xRes + settings.gilText.pos.x + 1,
        yRes + settings.gilText.pos.y - (settings.gilImage.size.height/6))
    show()
end

function update_gil_if_item_id_matches(id)
    if (id == GIL_ITEM_ID) then
        update_gil()
    end
end

function update_gil_if_string_contains_gil(input_string)
    if (string.match(input_string,"gil")) then
        update_gil()
    end
end

function update_gil()
    local gil = windower.ffxi.get_items('gil')
    gil_text:text(comma_value(gil))
end

function show()
    gil_text:show()
    gil_image:show()
end

function hide()
    gil_text:hide()
    gil_image:hide()
end

function comma_value(amount)
    local formatted = tostring(amount)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end

function is_cutscene(status_id)
    return status_id == CUTSCENE_STATUS_ID
end

function toggle_display_if_cutscene(is_cutscene_playing)
    if (is_cutscene_playing) and (not is_hidden_by_key) then
        is_hidden_by_cutscene = true
        hide()
    elseif (not is_cutscene_playing) and (not is_hidden_by_key) then
        is_hidden_by_cutscene = false
        show()
    end
end

function toggle_display_if_hide_key_is_pressed(key_pressed, key_down)
    if (key_pressed == hideKey) and (key_down) and (is_hidden_by_key) and (not is_hidden_by_cutscene) then
        is_hidden_by_key = false
        show()
    elseif (key_pressed == hideKey) and (key_down) and (not is_hidden_by_key) and (not is_hidden_by_cutscene) then
        is_hidden_by_key = true
        hide()
    end
end
