--[[
Copyright (c) 2013, Ricky Gall
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

_addon = {}
_addon.name = 'STNA'
_addon.version = '1.07'
require 'tablehelper'
require 'sets'

function onLoad()
	windower.send_command('alias stna lua c stna')
	statSpell = { 
				Paralysis='Paralyna',
				Curse='Cursna',
				Doom='Cursna',
				Silence='Silena',
				Plague='Viruna',
				Diseased='Viruna',
				Petrification='Stona',
				Poison='Poisona',
				Blindness='Blindna'
			}
	--You may change this priority as you see fit this is my personal preference		
    priority = T{}
    priority[1] = 'Doom'
    priority[2] = 'Curse'
    priority[3] = 'Petrification'
	priority[4] = 'Paralysis'
    priority[5] = 'Plague'
    priority[6] = 'Silence'
	priority[7] = 'Blindness'
    priority[8] = 'Poison'
    priority[9] = 'Diseased'
	
	statusTable = S{}
end

function onUnload()
	windower.send_command('unalias stna')
end

function commands()
	if statusTable ~= nil then
        local player = windower.ffxi.get_player()
		for i = 1, 9 do
			if statusTable:contains(priority[i]) then
                windower.send_command('send @others /ma "'..statSpell[priority[i]]..'" '..player['name'])
                if priority[i] == 'Doom' then
                    windower.send_command('input /item "Holy Water" '..player['name'])  --Auto Holy water for doom
                end
                return
            end
		end
        windower.add_to_chat(55,"You are not afflicted by a status with a -na spell.")
	end
end

function gainStatus(id,name)
    if priority:contains(name) and not statusTable:contains(name) then
        statusTable:add(name)
    end
end


function loseStatus(id,name)
    if statusTable:contains(name) then
        statusTable:remove(name)
    end
end

windower.register_event('load', onLoad)
windower.register_event('unload', onUnload)
windower.register_event('gain status', gainStatus)
windower.register_event('lose status', loseStatus)
windower.register_event('addon command', commands)