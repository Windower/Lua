_addon.name = 'stopwatch'
_addon.author = 'Patrick Finnigan (Puhfyn@Ragnarok)'
_addon.version = '1.0'
_addon.commands = {'sw', 'stopwatch'}

require('logger')
config = require('config')
texts = require('texts')
 
defaults = {}
defaults.pos = {}
defaults.pos.x = 450
defaults.pos.y = 0
defaults.text = {}
defaults.text.font = 'Arial'
defaults.text.size = 12
 
settings = config.load(defaults)
times = texts.new(settings)
startTime = os.time()
isActive = false
cumulativeSeconds = 0


windower.register_event('prerender', function()
    local info = windower.ffxi.get_info()
    if not info.logged_in then
        times:hide()
        return
    end

    seconds = cumulativeSeconds
    if isActive == true then
		seconds = seconds + os.time() - startTime
	end
	times:text(os.date('!%H:%M:%S', seconds))
	times:visible(true)
end)

windower.register_event('addon command', function(...)
	local param = L{...}
	local command = param[1]
	command = command:lower() or 'help'

	if command == 'start' then
		isActive = true
		startTime = os.time()
	elseif command == 'stop' then
		isActive = false
		cumulativeSeconds = cumulativeSeconds + os.time() - startTime
	elseif command == 'reset' then
		cumulativeSeconds = 0
		startTime = os.time()
	else
		log("'sw start' to start the stopwatch" )
		log("'sw stop' to stop the stopwatch")
		log("'sw reset' to reset the stopwatch cumulative time to 0")
	end
end)

--[[
Copyright (c) 2015, Patrick Finnigan
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
