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

hideKey = 70
is_hidden_by_cutscene = false
is_hidden_by_key = false

defaults = {}
defaults.HideKey = 70
defaults.GilText = {}
defaults.GilText.bg = {}
defaults.GilText.bg.alpha = 100
defaults.GilText.bg.red = 0
defaults.GilText.bg.green = 0
defaults.GilText.bg.blue = 0
defaults.GilText.bg.visible = false
defaults.GilText.text = {}
defaults.GilText.text.font = 'sans-serif'
defaults.GilText.text.fonts = {'Arial','Trebuchet MS'}
defaults.GilText.text.size = 9
defaults.GilText.flags = {}
defaults.GilText.flags.italic = true
defaults.GilText.flags.bold = false
defaults.GilText.flags.right = true
defaults.GilText.flags.bottom = true
defaults.GilText.pos = {}
defaults.GilText.pos.x = -285
defaults.GilText.pos.y = -35
defaults.GilText.text.alpha = 255
defaults.GilText.text.red = 253
defaults.GilText.text.green = 252
defaults.GilText.text.blue = 250
defaults.GilText.text.stroke = {}
defaults.GilText.text.stroke.alpha = 200
defaults.GilText.text.stroke.red = 50
defaults.GilText.text.stroke.green = 50
defaults.GilText.text.stroke.blue = 50
defaults.GilText.text.stroke.width = 2
defaults.GilText.text.visible = true
defaults.GilImage = {}
defaults.GilImage.color = {}
defaults.GilImage.color.alpha = 255
defaults.GilImage.color.red = 255
defaults.GilImage.color.green = 255
defaults.GilImage.color.blue = 255
defaults.GilImage.visible = true

local settings = config.load(defaults)
config.save(settings)

settings.GilImage.texture = {}
settings.GilImage.texture.path = windower.addon_path..'gil.png'
settings.GilImage.texture.fit = true
settings.GilImage.size = {}
settings.GilImage.size.height = 23
settings.GilImage.size.width = 23
settings.GilImage.draggable = false
settings.GilImage.repeatable = {}
settings.GilImage.repeatable.x = 1
settings.GilImage.repeatable.y = 1

gil_image = images.new(settings.GilImage)
gil_text = texts.new(settings.GilText)

windower.register_event('load',function()
    if windower.ffxi.get_info().logged_in then
        initialize()
    end
end)

windower.register_event('login', function()
    initialize()
end)

windower.register_event('logout', function(...)
    hide()
end)

windower.register_event('add item', function(...)
    update_gil()
end)

windower.register_event('remove item', function(original, modified, original_mode, modified_mode, blocked)
    if (string.match(original,"gil")) then
        update_gil()
    end
end)


windower.register_event('incoming text', function(...)
    update_gil()
end)

function initialize()
    hideKey = settings.HideKey
    local xRes = windower.get_windower_settings().ui_x_res
    local yRes = windower.get_windower_settings().ui_y_res
    update_gil()
    gil_image:pos(xRes + settings.GilText.pos.x + 1 ,
      yRes + settings.GilText.pos.y - (settings.GilImage.size.height/6))
    show()
end

function update_gil()
  local gil = windower.ffxi.get_items().gil
  gil_text:text(''..comma_value(gil))
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
  local formatted = amount
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

windower.register_event('status change', function(new_status_id)
    if (new_status_id == 4) and (is_hidden_by_key == false) then
        is_hidden_by_cutscene = true
        hide()
    elseif (new_status_id ~= 4) and (is_hidden_by_key == false) then
        is_hidden_by_cutscene = false
        show()
    end
end)

windower.register_event('keyboard', function(dik, flags, blocked)
  if (dik == hideKey) and (flags == true) and (is_hidden_by_key == true) and (is_hidden_by_cutscene == false) then
    is_hidden_by_key = false
    show()
  elseif (dik == hideKey) and (flags == true) and (is_hidden_by_key == false) and (is_hidden_by_cutscene == false) then
    is_hidden_by_key = true
    hide()
  end
end)
