--Copyright (c) 2013, Byrthnoth
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



file = require 'filehelper'
require 'sets'
require 'helper_functions'

require 'resources'
require 'ambiguous_names'
require 'targets'

_addon = {}
_addon.version = '0.3'
_addon.name = 'Shortcuts'
_addon.commands = {'shortcuts'}

function event_load()
	counter = 0
	debugging = false
	lastsent = 'MAUSMAUSMAUSMAUSMAUSMAUSMAUSMAUS'
	collectgarbage()
end

function event_outgoing_text(original,modified)
	if counter>0 then
		local dtime = os.clock() - timestamp
		if dtime > 0.2 then
			counter = 0
		else
			counter = counter +1
		end
		if counter == 36 then
			if dir_exists('../addons/shortcuts/data/') then
				f = io.open('../addons/shortcuts/data/'..tostring(os.clock())..'.log','w+')
				f:write('Probable infinite loop detected in Shortcuts: '..tostring(lastsent)..'\n')
				f:close()
			end
			add_to_chat(8,'Probable infinite loop detected in Shortcuts: '..tostring(lastsent)..'\7Please tell Byrth what you were doing')
			timestamp = os.clock()
			counter = 0
			return modified
		end
	else
		counter = 1
		timestamp = os.clock()
	end
	
	if original == lastsent then
		lastsent = ''
		return modified
	end

	return command_logic(original,modified)
end

function event_unhandled_command(...)
	local combined = table.concat({...},' ')
	command_logic(combined,combined)
end

function command_logic(original,modified)
	local splitline = split(original,' ')
	local command = splitline[1]
	
	local a,b,spell = string.find(original,'"(.-)"')

	if ignore_list[command] then
		lastsent = ''
		return modified
	elseif command2_list[command] and not valid_target(splitline[#splitline],true) then
		
		if command2_list[command]==true then -- no excluded second commands
			local temptarg = valid_target(splitline[#splitline]) or target_make({validtarget={['Player']=true,['Enemy']=true,['Self']=true}})
			lastsent = command..' '..temptarg
			if debugging then add_to_chat(8,tostring(counter)..' input '..lastsent) end
			send_command('input '..lastsent)
			return ''
		else
			local tempcmd = command
			local passback
			for i,v in pairs(splitline) do
				if command2_list[command]:contains(v) then
					tempcmd = tempcmd..' '..v
					passback = v
				end
			end

			local temptarg = valid_target(splitline[#splitline])
			if passback then
				if temptarg == splitline[#splitline] or pass_through_targs:contains(temptarg) then
					temptarg = splitline[#splitline]
				elseif passback == splitline[#splitline] then
					temptarg = ''
				elseif not temptarg then
					temptarg = splitline[#splitline]
				end
			elseif not temptarg then
				temptarg = target_make({validtarget={['Player']=true,['Enemy']=true,['Self']=true}})
			end
			lastsent = tempcmd..' '..temptarg
			if debugging then add_to_chat(8,tostring(counter)..' input '..lastsent) end
			send_command('input '..lastsent)
			return ''
		end
	elseif (command2_list[command] and valid_target(splitline[#splitline],true)) or (command == '/hide') or (command_list[command] and validabils[(spell or ''):lower():gsub(' ',''):gsub('[^%w]','')] and valid_target(splitline[#splitline])) then
		lastsent = ''
		return modified
	elseif command_list[command] then
		return interp_text(splitline,1,modified)
	else
		return interp_text(splitline,0,modified)
	end
end

function interp_text(splitline,offset,modified)
	player = get_player()
	local temptarg
	if #splitline > 1 then
		temptarg = valid_target(splitline[#splitline])
	end
	local abil
	
	if temptarg then abil = _raw.table.concat(splitline,' ',1+offset,#splitline-1)
	else abil = _raw.table.concat(splitline,' ',1+offset,#splitline) end

	local strippedabil = strip(abil) -- Slug the ability

	if validabils[strippedabil] then -- If the ability exists, do this.
		local r_line, s_type
			
		if validabils[strippedabil].typ == 'r_spells' then
			r_line = r_spells[validabils[strippedabil].index]
		elseif validabils[strippedabil].typ == 'r_abilities' then
			r_line = r_abilities[validabils[strippedabil].index]
		elseif validabils[strippedabil].typ == 'ambig_names' then
			r_line, s_type = ambig(strippedabil)
		end
		lastsent = r_line['prefix']..' "'..r_line['english']..'" '..(temptarg or target_make(r_line))
		if debugging then add_to_chat(8,tostring(counter)..' input '..lastsent) end
		send_command('input '..lastsent)
		return ''
	end
	lastsent = ''
	return modified
end