--[[Copyright © 2014, Kenshi
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of TargetClaim nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Kenshi BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'TargetClaim'
_addon.author = 'Kenshi'
_addon.version = '1.0'

require('luau')
texts = require('texts')

defaults = {}
defaults.showclaimname = true
defaults.showclaimid = true
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
defaults.display.text.size = 10

settings = config.load(defaults)
settings:save()

text_box = texts.new(settings.display, settings)

initialize = function(text, settings)
    local properties = L{}
	if settings.showclaimname then
        properties:append('${claim_name}')
    end
    if settings.showclaimid then
        properties:append('${claim_id}')
    end

    text:clear()
    text:append(properties:concat('\n'))
end

text_box:register_event('reload', initialize)

initialize(text_box, settings)

windower.register_event('prerender', function()
	local mob = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
	local player = windower.ffxi.get_player()
	if mob then
		if mob.claim_id > 0 then
			local mobclaim = windower.ffxi.get_mob_by_id(mob.claim_id)
			local info = {}
			info.claim_name = mobclaim.name
			info.claim_id = mob.claim_id
			text_box:update(info)
			text_box:show()
		elseif mob.target_index > 0 then
			local target = windower.ffxi.get_mob_by_index(mob.target_index)
			local info = {}
			info.claim_name = target.name
			info.claim_id = target.id
			text_box:update(info)
			text_box:show()
		elseif mob.name == player.name then
			local info = {}
			info.claim_name = player.name
			info.claim_id = player.id
			text_box:update(info)
			text_box:show()
		else
			text_box:hide()
		end
	else
		text_box:hide()
	end
end)
