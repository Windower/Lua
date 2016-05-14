--[[
Copyright (c) 2016, Omnys of Valefor
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


_addon.name = 'Pouches'
_addon.version = '1'
_addon.author = 'Omnys@Valefor'
_addon.command = 'pouches'

--Requiring libraries used in this addon
--These should be saved in addons/libs
require('logger')
require('tables')
require('strings')
res = require('resources')

inverted = {}
item = {}
	
windower.register_event('load', function(...)
	for k,v in pairs(res.items) do
		inverted[string.lower(v.en)] = {id = k, targets = v.targets, cast = v.cast_time}
	end
end)

function use_item()
	windower.send_command('input /item "'..item.name..'" <me>')
	item.count = item.count - 1
	if item.count > 0 and windower.ffxi.get_player().status == 0 then
		windower.send_command('wait '..item.delay..';pouches reuse')
	end
end

windower.register_event('addon command', function(...)
    local inv = windower.ffxi.get_items(0) -- get main inventory
    local args	= T{...}:map(string.lower)
	
	if args[1] == "reuse" then
		use_item()
	else
		item.name = table.concat(args," ")
		item.id = inverted[item.name].id
		item.count = 0
		for b,v in ipairs(inv) do
			if v.id == item.id and inverted[item.name].targets.Self == true then
				item.count = item.count + v.count
				item.delay = inverted[item.name].cast + 2
			end
		end
		if item.count > 0 then
			log('Found '..item.count..' '..item.name..'. Commencing Use.')
			log('You may simply type /heal to stop.')
			windower.send_command('pouches reuse')
		end
	end
end)
