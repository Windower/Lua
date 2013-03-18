--[[
STNA v1.07
Copyright (c) 2012, Ricky Gall All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    Neither the name of the organization nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]
require 'tablehelper'

function event_load()
	player = get_player()
	send_command('alias stna lua c stna')
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
	priority = { 
				'Doom','Curse','Petrification',
				'Paralysis','Plague','Silence',
				'Blindness','Poison','Diseased'
			}
	statusTable = T{}
end

function event_login()
	player = get_player()
end

function event_unload()
	send_command('unalias stna')
end

function event_addon_command()
	if statusTable[1] == nil then
		add_to_chat(55,"You are not afflicted by a status with a -na spell.")
	else
		for i = 1, 9 do
			for u = 1, #statusTable do
				if statusTable[u]:lower() == priority[i]:lower() then
					send_command('send @others '..statSpell[priority[i]]..' '..player['name'])
					if statusTable[u]:lower() == 'doom' then
						send_command('input /item "Holy Water" '..player['name'])  --Auto Holy water for doom
					end
					return
				end
			end
			if i == 9 then
				add_to_chat(55,"You are not afflicted by a status with a -na spell.")
			end
		end
	end
end

function event_gain_status(id,name)
	if #statusTable == 0 then
		for i = 1, #priority do
			if priority[i]:lower() == name:lower() then
				statusTable[#statusTable+1] = name
			end
		end
	else	
		for u = 1, #statusTable do
			if statusTable[u]:lower() == name:lower() then
				return
			else
				for i = 1, #priority do
					if priority[i]:lower() == name:lower() then
						statusTable[#statusTable+1] = name
					end
				end
			end
		end
	end
end


function event_lose_status(id,name)
	for u = 1, #statusTable do
		if statusTable[u]:lower() == name:lower() then
			table.remove(statusTable,u)
			return
		end
	end
end