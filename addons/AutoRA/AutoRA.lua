--Copyright (c) 2013, Banggugyangu
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


function event_load()

	version = '2.0.0'
	delay = 0
	RW_delay = 0
	Ammo_delay = 0
	retrn = 0
	send_command('unbind ^d')
	send_command('unbind !d')
	send_command('bind ^d ara start')
	send_command('bind !d ara stop')
	send_command('alias ara lua c autora')
	
end
	
function start()
	player = get_player()
	if (player.status:lower() == 'engaged' ) then
		auto = 1
	elseif (player.status:lower() == 'idle' ) then
		auto = 0
	end
	shoot()
end

function stop()
	auto = 0
end

function shoot()
	send_command('/shoot <t>')
end

function shootOnce()
	send_command('/shoot <t>')
end

--Function Author:  Byrth
function split(msg, match)
	local length = msg:len()
	local splitarr = {}
	local u = 1
	while u <= length do
		local nextanch = msg:find(match,u)
		if nextanch ~= nil then
			splitarr[#splitarr+1] = msg:sub(u,nextanch-match:len())
			if nextanch~=length then
				u = nextanch+match:len()
			else
				u = lengthlua 
			end
		else
			splitarr[#splitarr+1] = msg:sub(u,length)
			u = length+1
		end
	end
	return splitarr
end

function event_action(act)
	local actor = act.actor_id
	local category = act.category
	local player = get_player()
	
	if ((actor == (player.id or player.index))) then
		if category == 2 then
			if auto == 1 then
				if (player.status:lower() == 'engaged' ) then
					auto = 1
				elseif (player.status:lower() == 'idle' ) then
					auto = 0
				end
			end
			
			if auto == 1 then
				send_command('wait 2; /shoot <t>')
			elseif auto == 0 then
			end
		end
	end
end

--Function Designer:  Byrth
function event_addon_command(...)
    local term = table.concat({...}, ' ')
    local splitarr = split(term,' ')
	if splitarr[1]:lower() == 'start' then
		start()
	elseif splitarr[1]:lower() == 'stop' then
		stop()
	elseif splitarr[1]:lower() == 'shoot' then
		shoot()
	elseif splitarr[1]:lower() == 'reload' then
		setDelay()
	elseif splitarr[1]:lower() == 'help' then
		add_to_chat(17, 'AutoRA  v'..version..'commands:')
		add_to_chat(17, '//ara [options]')
		add_to_chat(17, '    start  - Starts auto attack with ranged weapon')
		add_to_chat(17, '    stop   - Stops auto attack with ranged weapon')
		add_to_chat(17, '    help   - Displays this help text')
		add_to_chat(17, ' ')
		add_to_chat(17, 'AutoRA will only automate ranged attacks if your status is "Engaged".  Otherwise it will always fire a single ranged attack.')
		add_to_chat(17, 'To start auto ranged attacks without commands use the key:  Ctrl+d')
		add_to_chat(17, 'To stop auto ranged attacks in the same manner:  Atl+d')
	end
end

