_addon.name = 'Silence'
_addon.author = 'Ihina'
_addon.version = '1.0.1.0'

require 'logger'
require 'tablehelper'
config = require 'config'

last = {}
t = T{'Equipment changed.', 
		'You cannot use that command at this time.', 
		'You cannot use that command while viewing the chat log.', 
		'You must close the currently open window to use that command.'}
		
defaults = {}
defaults.mode = {}
defaults.mode.value = 0
settings = config.load(defaults)

windower.register_event('load', function()
	for _, str in ipairs(t) do
		last[str] = 0
	end
end)

windower.register_event('incoming text', function(str)
	if t:contains(str) then
		if settings.mode.value == 0 then
			return ''
		else
			if os.clock() - last[str] < .75 then
				return ''
			else
				last[str] = os.clock()
			end
		end
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
    * Neither the name of Silence nor the
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
