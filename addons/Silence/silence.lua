_addon.name = 'Silence'
_addon.author = 'Ihina'
_addon.version = '1.0.2.1'

config = require('config')
defaults = {}
defaults.ShowOne = false
settings = config.load(defaults)

last = {}
last['Equipment changed.'] = 0
last['You cannot use that command at this time.'] = 0
last['You cannot use that command while viewing the chat log.'] = 0
last['You must close the currently open window to use that command.'] = 0
last['Equipment removed.'] = 0
last['You were unable to change your equipped items.'] = 0
last['You cannot use that command while unconscious.'] = 0
last['You cannot use that command while charmed.'] = 0
last['You can only use that command during battle.'] = 0
last['You cannot perform that action on the selected sub-target.'] = 0
		
windower.register_event('incoming text', function(str)
	if last[str] then
		if not settings.ShowOne then
			return true
		else
			if os.clock() - last[str] < .75 then
				return true
			else
				last[str] = os.clock()
			end
		end
	end
end)

windower.register_event('unhandled command', function(...) 
	local param = L{...}
	if param[1] == 'silence' then 
		if param[2] == 'showone' then
			if param[3] == 'true' then 
				settings.ShowOne = true
				print('-showone set to true-')
			elseif param[3] == 'false' then 
				settings.ShowOne = false
				print('-showone set to false-')
			end
			settings:save()
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
--Original plugin by Taj
