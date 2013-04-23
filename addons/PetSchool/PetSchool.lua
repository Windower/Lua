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
	version = '1.0.0'
	PetNuke = ' '
	PetHeal = ' '
	TP_Set = ' '
	Idle_Set = ' '
	send_command('alias ps lua c petschool')
	send_command('alias petschool lua c petschool')
	options_load()
end

--Function Designer:  Byrth
function options_load()
	local f = io.open(lua_base_path..'data/settings.txt', "r")
	if f == nil then
		local g = io.open(lua_base_path..'data/settings.txt', "w")
		g:write('Release Date: 2:16 PM, 4-22-13\46\n')
		g:write('Author Comment: This document is whitespace sensitive, which means that you need the same number of spaces between things as exist in this initial settings file\46\n')
		g:write('Author Comment: It looks at the first two words separated by spaces and then takes anything as the value in question if the first two words are relevant\46\n')
		g:write('Author Comment: If you ever mess it up so that it does not work, you can just delete it and PetSchool will regenerate it upon reload\46\n')
		g:write('Author Comment: For the Gearset, simply place the name of the spellcast set for each setting exactly how it is spelled in spellcast.\n')
		g:write('Author Comment: The design of the settings file is credited to Byrthnoth as well as the creation of the settings file.\n\n\n\n')
		g:write('Fill In Settings Below:\n')
		g:write('PetNuke Set: PetNuke\nPetHeal Set: PetHeal\nTP Set: TP\nIdle Set: Movement\n')
		g:close()
		
		write('Default settings file created')
		add_to_chat(17,'PetSchool created a settings file and loaded!')
		add_to_chat(17,'Please Modify the Settings file to fit your spellcast .XML file')
	else
		f:close()
		for curline in io.lines(lua_base_path..'data/settings.txt') do
			local splat = split(curline,' ')
			local cmd = ''
			if splat[2] ~=nil then
				cmd = (splat[1]..' '..splat[2]):gsub(':',''):lower()
			end
			if cmd == 'petnuke set' then
				PetNuke = splat[3]
			elseif cmd == 'petheal set' then
				PetHeal = splat[3]
			elseif cmd == 'tp set' then
				TP_Set = splat[3]
			elseif cmd == 'idle set' then
				Idle_Set = splat[3]
			end
		end
		add_to_chat(17,'PetSchool read from a settings file and loaded!')
	end
end

function event_action(act)
	local player = get_player()
	local pet = get_mob_by_index(get_mob_by_index(get_player()['index'])['pet_index'])['id']
	local actor = act.actor_id
	local category = act.category
	local targets = act.targets
	local actionTarget = get_mob_by_id(targets[1]['id'])
	
	if actor == pet then
		if category == 8 then
			if actionTarget.is_npc == true then
				send_command('sc set ' .. PetNuke)
				add_to_chat(17, '                       Pet Spellcast Started:  Nuking')
			elseif actionTarget.is_npc == false then
				send_command('sc set ' .. PetHeal)
				add_to_chat(17, '                       Pet Spellcast Started:  Curing/Buffing')
			end
		elseif category == 4 then
			if (player.status:lower() == 'engaged') then
				send_command('sc set ' .. TP_Set)
				add_to_chat(17, '                       Pet Spellcast Finished')
			elseif (player.status:lower() == 'idle') then
				send_command('sc set ' .. Idle_Set)
				add_to_chat(17, '                       Pet Spellcast Finished')
			end
		end
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

--Function Designer:  Byrth
function event_addon_command(...)
    local term = table.concat({...}, ' ')
    local splitarr = split(term,' ')
	if splitarr[1]:lower() == 'reload' then
		options_load()
	elseif splitarr[1]:lower() == 'help' then
		add_to_chat(17, 'PetSchool  v'..version..'commands:')
		add_to_chat(17, '//ps [options]')
		add_to_chat(17, '    reload  - Reloads settings')
		add_to_chat(17, '    help   - Displays this help text')
	end
end