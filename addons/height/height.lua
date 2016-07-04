_addon.name = 'Height'
_addon.author = 'Sammeh'
_addon.version = '1.0'
_addon.command = 'height'

config = require('config')
texts = require('texts')

defaults = {}
defaults.pos = {}
defaults.pos.x = -218
defaults.pos.y = 21
defaults.text = {}
defaults.text.font = 'Arial'
defaults.text.size = 14
defaults.flags = {}
defaults.flags.right = true

settings = config.load(defaults)
height = texts.new('${value||%.2f}', settings)

debug.setmetatable(nil, {__index = {}, __call = functions.empty})

windower.register_event('prerender', function()
    local t = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
	local s = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
	upperthreshold = 8.5
	lowerthreshold = -7.5
    if t then 
	  height.value = t.z - s.z
	  if (t.z - s.z) >= upperthreshold or (t.z - s.z) <= lowerthreshold then
	    height:color(0,255,0) -- green
	  else
	    height:color(255,0,0) -- red
	  end
	end
    height:visible(t ~= nil)
	
end)



windower.register_event('addon command', function(command)
    if command == 'save' then
        config.save(settings, 'all')
    end
end)

--[[
Copyright © 2016, Sammeh
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
