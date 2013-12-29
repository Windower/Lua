_addon.name = 'zonetimer'
_addon.author = 'Ihina'
_addon.version = '1.0.0.0'
_addon.command = 'zonetimer'

require 'logger'
config = require 'config'
texts = require 'texts'
 
defaults = {}
defaults.pos = {}
defaults.pos.x = 400
defaults.pos.y = 0
defaults.text = {}
defaults.text.font = 'Arial'
defaults.text.size = 12
 
settings = config.load(defaults)
times = texts.new(settings)
zone = ''

windower.register_event('prerender', function()
	current_zone = windower.ffxi.get_info().zone
	if zone == current_zone then
		seconds = os.difftime(os.time(),start_time)
		local hour = 0
		local minute = 0
		while seconds >= 3600 do
			seconds = seconds - 3600
			hour = hour + 1
		end
		while seconds >= 60 do
			seconds = seconds - 60
			minute = minute + 1
		end
		
		
		times:text(string.format("%02d", hour) .. ":" .. 
					string.format("%02d", minute) .. ":" .. 
					string.format("%02d", seconds))
		times:visible(seconds ~= nil)
	else
		zone = current_zone
		start_time = os.time()
	end
end)

windower.register_event('addon command', function(...)
	local param = L{...}
	local command = param[1]
	if command == 'help' then
		log("'zonetimer fontsize #' to change the font size" )
		log("'zonetimer posX #' to change the x position")
		log("'zonetimer posY #' to change the y position")
	
	elseif command == 'fontsize' or command == 'posX' or command == 'posY' then
		
		if command == 'fontsize' then
			settings.text.size = param[2]
		elseif command == 'posX' then
			settings.pos.x = param[2]
		elseif command == 'posY' then
			settings.pos.x = param[2]
		end

		config.save(settings, 'all')
		times:visible(false)
		times = texts.new(settings)
	end
end)

--[[
Copyright (c) 2013, Ihina
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of zonetimer nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL IHINA BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
