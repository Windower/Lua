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


_addon.name = 'STNA'
_addon.version = '1.08'
_addon.author = 'Nitrous (Shiva)'
_addon.command = 'stna'

require('tables')
require('sets')
res = require('resources')

windower.register_event('load', function()
    statSpell = { 
        paralysis='Paralyna',
        curse='Cursna',
        doom='Cursna',
        silence='Silena',
        plague='Viruna',
        diseased='Viruna',
        petrification='Stona',
        poison='Poisona',
        blindness='Blindna'
    }
    --You may change this priority as you see fit this is my personal preference		
    priority = T{}
    priority[1] = 'doom'
    priority[2] = 'curse'
    priority[3] = 'petrification'
    priority[4] = 'paralysis'
    priority[5] = 'plague'
    priority[6] = 'silence'
    priority[7] = 'blindness'
    priority[8] = 'poison'
    priority[9] = 'diseased'
	
    statusTable = S{}
end)

windower.register_event('addon command', function(...)
    if statusTable ~= nil then
        local player = windower.ffxi.get_player()
        for i = 1, 9 do
            if statusTable:contains(priority[i]) then
                windower.send_command('send @others /ma "'..statSpell[priority[i]]..'" '..player['name'])
                if priority[i] == 'doom' then
                    windower.send_command('input /item "Holy Water" '..player['name'])  --Auto Holy water for doom
                end
                return
            end
        end
        windower.add_to_chat(55,"You are not afflicted by a status with a -na spell.")
    end
end)

windower.register_event('gain buff', function(id)
    local name = res.buffs[id].english
    if priority:contains(name) and not statusTable:contains(name) then
        statusTable:add(name)
    end
end)


windower.register_event('lose buff', function(id)
    local name = res.buffs[id].english
    if statusTable:contains(name) then
        statusTable:remove(name)
    end
end)
