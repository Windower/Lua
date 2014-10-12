_addon.name = 'TargetInfo'
_addon.author = 'Arcon'
_addon.version = '1.0.1.0'
_addon.language = 'English'

require('luau')
texts = require('texts')

-- Config

defaults = {}
defaults.showhexid = true
defaults.showfullid = true
defaults.showspeed = true
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.display.bg = {}
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.bg.alpha = 102
defaults.display.text = {}
defaults.display.text.font = 'Consolas'
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.text.size = 12

settings = config.load(defaults)
settings:save()

text_box = texts.new(settings.display, settings)

-- Constructor

initialize = function(text, settings)
    local properties = L{}
    if settings.showfullid then
        properties:append('ID:  ${full|-|%08s}')
    end
    if settings.showhexid then
        properties:append('Hex ID:   ${hex|-|%.3X}')
    end
    if settings.showspeed then
        properties:append('Speed: ${speed|-}')
    end

    text:clear()
    text:append(properties:concat('\n'))
end

text_box:register_event('reload', initialize)

initialize(text_box, settings)

-- Events

windower.register_event('prerender', function()
	local mob = windower.ffxi.get_mob_by_target('t')
	if mob and mob.id > 0 then
        local info = {}
        info.hex = mob.id % 0x1000
        info.full = mob.id
        local speed = (100 * (mob.movement_speed / 5 - 1)):round(2)
        info.speed = (
            speed > 0 and
                '\\cs(0,255,0)' .. ('+' .. speed):lpad(' ', 5)
            or speed < 0 and
                '\\cs(255,0,0)' .. speed:string():lpad(' ', 5)
            or
                '\\cs(102,102,102)' .. ('+' .. speed):lpad(' ', 5)) .. '%\\cr'
        text_box:update(info)
        text_box:show()
	else
		text_box:hide()
	end
end)

--[[
Copyright (c) 2013-2014, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
