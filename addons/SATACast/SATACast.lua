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


_addon.version = '1.1.0'
_addon.command = 'scast'
_addon.name = 'SATACast'
_addon.author = 'Banggugyangu'

res = require('resources')

windower.register_event('load',function ()
	
	version = '1.1.0'
	SA_Set = ' '
	TA_Set = ' '
	SATA_Set = ' '
	TP_Set = ' '
	TH_Set = ' '
	Idle_Set = ' '
	TH_ON = 0
	TP_ON = 0
	windower.add_to_chat(17, 'SATACast v' .. version .. ' loaded.     Author:  Banggugyangu')
	windower.add_to_chat(17, 'Attempting to load settings from file.')
	options_load()
	
end)

--Function Designer:  Byrth
function options_load()
	local f = io.open(windower.addon_path..'data/settings.txt', "r")
	if f == nil then
		local g = io.open(windower.addon_path..'data/settings.txt', "w")
		g:write('Release Date: 11:50 PM, 4-06-13\46\n')
		g:write('Author Comment: This document is whitespace sensitive, which means that you need the same number of spaces between things as exist in this initial settings file\46\n')
		g:write('Author Comment: It looks at the first two words separated by spaces and then takes anything as the value in question if the first two words are relevant\46\n')
		g:write('Author Comment: If you ever mess it up so that it does not work, you can just delete it and SATACast will regenerate it upon reload\46\n')
		g:write('Author Comment: For the output customization lines, simply place the name of the spellcast set for each setting exactly how it is spelled in spellcast.\n')
		g:write('Author Comment: The design of the settings file is credited to Byrthnoth as well as the creation of the settings file.\n\n\n\n')
		g:write('Fill In Settings Below:\n')
		g:write('SA Set: SneakAttack\nTA Set: TrickAttack\nSATA Set: SATA\nTP Set: TP\nTH Set: TreasureHunter\nIdle Set: Movement\n')
		g:close()
		
		print('Default settings file created')
		windower.add_to_chat(17,'SATACast created a settings file and loaded!')
	else
		f:close()
		for curline in io.lines(windower.addon_path..'data/settings.txt') do
			local splat = split(curline,' ')
			local cmd = ''
			if splat[2] ~=nil then
				cmd = (splat[1]..' '..splat[2]):gsub(':',''):lower()
			end
			if cmd == 'sa set' then
				SA_Set = splat[3]
			elseif cmd == 'ta set' then
				TA_Set = splat[3]
			elseif cmd == 'sata set' then
				SATA_Set = splat[3]
			elseif cmd == 'tp set' then
				TP_Set = splat[3]
			elseif cmd == 'th set' then
				TH_Set = splat[3]
			elseif cmd == 'idle set' then
				Idle_Set = splat[3]
			end
		end
		windower.add_to_chat(17,'SATACast read from a settings file and loaded!')
	end
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
	
windower.register_event('lose buff', function(id)
	local status = windower.ffxi.get_player().status
    local name = res.buffs[id].english
	if name == ('Sneak Attack' or 'Trick Attack') then
		if status == 1 then
			windower.send_command('sc set ' .. TP_Set)
		elseif status == 0 then
			windower.send_command('sc set ' .. Idle_Set)
		end
	end
end)

windower.register_event('action', function(act)
	local actor = act.actor_id
	local category = act.category
	local actor = act.actor_id
	local category = act.category
	local param = act.param
	local player = windower.ffxi.get_player()
	
	if player.status == 1 then
		if actor == (player.id or player.index) then
			if category == 1 then
				if TH_ON == 0 then
					windower.send_command('sc set ' .. TH_Set)
					TH_ON = 1
				elseif TH_ON == 1 then
					if TP_ON == 0 then
						windower.send_command('sc set ' .. TP_Set)
						TP_ON = 1
					elseif TP_ON == 1 then
					end
				end
			end
		end
	elseif player.status == 0 then
		TH_ON = 0
	end
end)

--Function Designer:  Byrth
windower.register_event('addon command',function (...)
    local term = table.concat({...}, ' ')
    local splitarr = split(term,' ')
	if splitarr[1]:lower() == 'reload' then
		options_load()
	elseif splitarr[1]:lower() == 'help' then
		windower.add_to_chat(17, 'SATACast  v'..version..'commands:')
		windower.add_to_chat(17, '//scast [options]')
		windower.add_to_chat(17, '    reload  - Reloads settings')
		windower.add_to_chat(17, '    help   - Displays this help text')
	end
end)