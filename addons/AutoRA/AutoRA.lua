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

require 'timer'

function event_load()

	version = '1.0.2'
	delay = 0
	RW_delay = 0
	Ammo_delay = 0
	retrn = 0
	send_command('unbind ^d')
	send_command('unbind !d')
	send_command('bind ^d ara start')
	send_command('bind !d ara stop')
	send_command('alias ara lua c autora')
	setDelay()
	
end

--Function Designer:  Byrth
function setDelay()
	local f = io.open(lua_base_path..'data/settings.txt', "r")
	if f == nil then
		local g = io.open(lua_base_path..'data/settings.txt', "w")
		g:write('Release Date: 11:50 PM, 4-06-13\46\n')
		g:write('Author Comment: This document is whitespace sensitive, which means that you need the same number of spaces between things as exist in this initial settings file\46\n')
		g:write('Author Comment: It looks at the first two words separated by spaces and then takes anything as the value in question if the first two words are relevant\46\n')
		g:write('Author Comment: If you ever mess it up so that it does not work, you can just delete it and AutoRA will regenerate it upon reload\46\n')
		g:write('Author Comment: Simply add your ranged weapon delay in the "RA Delay:" line and your ammo delay in the "Ammo Delay:" line in place of the existing numbers.\n')
		g:write('Author Comment: The design of the settings file is credited to Byrthnoth as well as the creation of the settings file.\n\n\n\n')
		g:write('Fill In Settings Below:\n')
		g:write('RA Delay: 288 \nAmmo Delay: 288\n')
		g:close()
		RW_delay = 288
		Ammo_delay = 288
		write('Default settings file created')
		add_to_chat(13,'AutoRA created a settings file and loaded!')
	else
		f:close()
		for curline in io.lines(lua_base_path..'data/settings.txt') do
			local splat = split(curline,' ')
			local cmd = ''
			if splat[2] ~=nil then
				cmd = (splat[1]..' '..splat[2]):gsub(':',''):lower()
			end
			if cmd == 'ra delay' then
				RW_delay = tonumber(splat[3])
			elseif cmd == 'ammo delay' then
				Ammo_delay = tonumber(splat[3])
			end
		end
		add_to_chat(17,'AutoRA read from a settings file and loaded!')
	end
	delay = ((RW_delay + Ammo_delay)/90)
end
	
function start()
	player = get_player()
	if (player.status:lower() == 'engaged' ) then
		auto = 1
		retrn = 1
	elseif (player.status:lower() == 'idle' ) then
		auto = 0
	end
	if (auto == 1 and retrn == 1) then
		shoot()
	elseif (auto == 0 and retrn == 0) then
		shootOnce()
	elseif (auto == 0 and retrn == 1) then
		retrn = 0
	end
end

function stop()
	timer.RemoveTimer('timerShoot')
end

function shoot()
	send_command('/shoot <t>')
	send_command('wait ' .. delay .. '; ara start')
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
