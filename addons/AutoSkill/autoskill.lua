-- Setup

require('luau')
packets = require('packets')

_addon.name = 'AutoSkill'
_addon.author = 'Novasilex'
_addon.commands = {'autoskill', 'as'}
_addon.version = '1.0.0.0'

skilling = {}
skilling.active = false
skilling.repeats = 0
skilling.delay = 0
skilling.delayStep = 0

windower.register_event('addon command', function(command, ...)
	local args = {...}
	if command == 'start' then
		skilling.repeats = 0
		skilling.active = true
		log('Mode: ', skilling.active)
	elseif command == 'stop' then
		skilling.active = false
		log('Mode: ', skilling.active)
	elseif command == 'delay' then
		if (args == nill) then
			error('Missing Delay Number. E.g. autoskill delay 3')
			return
		end
		skilling.delay = args[1]
		log('Delay: ', skilling.delay)
	elseif command == 'status' then
		log('Mode: ', skilling.active)
		log('Delay: ', skilling.delay)
		log('Repeats: ', skilling.repeats)
	end
end)

windower.register_event('time change', function(new, old)
	if (skilling.active) then
		if (skilling.delayStep == 0) then
			skilling.delayStep = skilling.delay
			skilling.repeats = skilling.repeats + 1
			windower.send_command('input /ma "Indi-Poison" <me>')
		else
			skilling.delayStep = skilling.delayStep - 1
		end
	end
end)

--[[
Copyright © 2013-2023, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
