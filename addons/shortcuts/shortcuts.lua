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

debugging = false
if dir_exists('../addons/shortcuts/data/') then
	logging = false
	logfile = io.open('../addons/shortcuts/data/NormalLog'..tostring(os.clock())..'.log','w+')
	logfile:write('\n\n','SHORTCUTS LOGGER HEADER: ',tostring(os.clock()),'\n')
	logfile:flush()
end

file = require 'filehelper'
require 'sets'
require 'helper_functions'

require 'resources'
require 'ambiguous_names'
require 'targets'

_addon = {}
_addon.version = '0.5'
_addon.name = 'Shortcuts'
_addon.commands = {'shortcuts'}

-----------------------------------------------------------------------------------
--Name: event_load()
--Args:
---- None
-----------------------------------------------------------------------------------
--Returns:
---- None, simply a routine that runs once at the load (after the entire document
---- is loaded and treated as a script)
-----------------------------------------------------------------------------------
function event_load()
	counter = 0
	lastsent = 'MAUSMAUSMAUSMAUSMAUSMAUSMAUSMAUS'
	collectgarbage()
end

-----------------------------------------------------------------------------------
--Name: event_unload()
--Args:
---- None
-----------------------------------------------------------------------------------
--Returns:
---- None, simply a routine that runs once at unload.
-----------------------------------------------------------------------------------
function event_unload()
	if logging then	logfile:close()	end
end


-----------------------------------------------------------------------------------
--Name: event_outgoing_text()
--Args:
---- original (string): Original command entered by the player
---- modified (string): Modified command with changes upstream of the addon
-----------------------------------------------------------------------------------
--Returns:
---- string, changed command
-----------------------------------------------------------------------------------
function event_outgoing_text(original,modified)
	local temp_org = convert_auto_trans(original)
	temp_org = temp_org:gsub(' <wait %d+>','')
	if logging then
		logfile:write('\n\n',tostring(os.clock()),'temp_org: ',temp_org,'\nModified: ',modified)
		logfile:flush()
	end
	
	if counter>0 and debugging then --- Subroutine designed to detect and eliminate infinite loops.
		local dtime = os.clock() - timestamp
		if dtime > 0.2 then
			counter = 0
		else
			counter = counter +1
		end
		if counter == 36 then
			if logging then
				f = io.open('../addons/shortcuts/data/loopdetect'..tostring(os.clock())..'.log','w+')
				f:write('Probable infinite loop detected in Shortcuts: ',tostring(lastsent),'\n',tostring(os.clock()),'temp_org: ',tostring(temp_org))
				f:flush()
				f:close()
			end
			add_to_chat(8,'Probable infinite loop detected in Shortcuts: '..tostring(lastsent)..'\7Please tell Byrth what you were doing')
			timestamp = os.clock()
			counter = 0
			return modified
		end
	elseif debugging then
		counter = 1
		timestamp = os.clock()
	end
	
	-- If it's the command that was just sent, blank lastsent and pass it through with only the changes applied by other addons
	if original == lastsent then
		lastsent = ''
		return modified
	end
	
	-- Otherwise, dump the inputs into command_logic()
	return command_logic(temp_org,modified)
end

-----------------------------------------------------------------------------------
--Name: event_unhandled_command()
--Args:
---- table of strings: //entries split on ' '
-----------------------------------------------------------------------------------
--Returns:
---- None, but can generate text output through command_logic()
-----------------------------------------------------------------------------------
function event_unhandled_command(...)
	local combined = table.concat({...},' ') -- concat it back together...
	command_logic(combined,combined) -- and then dump it into command_logic()
end


-----------------------------------------------------------------------------------
--Name: command_logic(original,modified)
--Args:
---- original (string): Full line entry from event unhandled command/outgoing text
---- modified (string): Modified line if from event_outgoing_text, otherwise the
---- same as original
-----------------------------------------------------------------------------------
--Returns:
---- string (sometimes '') depending what the logic says to do.
-----------------------------------------------------------------------------------
function command_logic(original,modified)
	local splitline = split(original,' ')
	local command = splitline[1] -- Treat the first word as a command.
	local potential_targ = splitline[#splitline]
	local a,b,spell = string.find(original,'"(.-)"')
	
	if targ_reps[potential_targ] then
		potential_targ = targ_reps[potential_targ]
	end
	
	if ignore_list[command] then -- If the command is legitimate and on the blacklist, return it unaltered.
		lastsent = ''
		return modified
	elseif command2_list[command] and not valid_target(potential_targ,true) then
		-- If the command is legitimate and requires target completion but not ability interpretation
		
		if command2_list[command]==true then -- If there are not any excluded secondary commands
			local temptarg = valid_target(potential_targ) or target_make({['Player']=true,['Enemy']=true,['Self']=true}) -- Complete the target or make one.
			lastsent = command..' '..temptarg -- Push the command and target together and send it out.
			if debugging then add_to_chat(8,tostring(counter)..' input '..lastsent) end
			if logging then
				logfile:write('\n\n',tostring(os.clock()),'Original: ',original,'\n(162) ',lastsent) 	
				logfile:flush()
			end
			send_command('@input '..lastsent)
			return ''
		else -- If there are excluded secondary commands (like /pcmd add <name>)
			local tempcmd = command
			local passback
			for i,v in pairs(splitline) do -- Iterate over the potential secondary arguments.
			-- I'm not sure when there could be more than one secondary argument, but it's ready if it happens.
				if command2_list[command]:contains(v) then
					tempcmd = tempcmd..' '..v
					passback = v
				end
			end
			
			local temptarg = valid_target(potential_targ)
			if passback then
				if temptarg == potential_targ or pass_through_targs:contains(temptarg) then
					-- If the final entry is a valid target, pass it through.
					temptarg = potential_targ
				elseif passback == potential_targ then
					-- If the final entry is the passed through secondary command, just send it out without a target
					temptarg = ''
				elseif not temptarg then
					-- Default to using the raw entry
					temptarg = potential_targ
				end
			elseif not temptarg then -- Make a target if the temptarget isn't valid
				temptarg = target_make({['Player']=true,['Enemy']=true,['Self']=true})
			end
			lastsent = tempcmd..' '..temptarg
			if debugging then add_to_chat(8,tostring(counter)..' input '..lastsent) end
			if logging then
				logfile:write('\n\n',tostring(os.clock()),'Original: ',original,'\n(193) ',lastsent)
				logfile:flush()
			end
			send_command('@input '..lastsent)
			return ''
		end
	elseif (command2_list[command] and valid_target(potential_targ,true)) then 
		-- If the submitted command does not require ability interpretation and is fine already, send it out.
		lastsent = ''
		if logging then
			logfile:write('\n\n',tostring(os.clock()),'Original: ',original,'\n(146) Legitimate command')
			logfile:flush()
		end
		return modified
	elseif (command_list[command] and convert_spell(spell or '') and valid_target(potential_targ)) then
		-- If the submitted ability is already properly formatted, send it out. Fixes capitalization and minor differences.
		lastsent = ''
		if logging then
			logfile:write('\n\n',tostring(os.clock()),'Original: ',original,'\n(146) Legitimate command')
			logfile:flush()
		end
		return command..' "'..convert_spell(spell)..'" '..potential_targ
	elseif command_list[command] then
		-- If there is a valid command, then pass the text with an offset of 1 to the text interpretation function
		return interp_text(splitline,1,modified)
	else
		-- If there is not a valid command, then pass the text with an offset of 0 to the text interpretation function
		return interp_text(splitline,0,modified)
	end
end


-----------------------------------------------------------------------------------
--Name: interp_text()
--Args:
---- splitline (table of strings): entire entry, split on spaces.
---- original (string): Full line entry from event unhandled command/outgoing text
---- modified (string): Modified line if from event_outgoing_text, otherwise the
---- same as original
-----------------------------------------------------------------------------------
--Returns:
---- string (sometimes '') depending what the logic says to do.
---- Sends a command if the command needs to be changed.
-----------------------------------------------------------------------------------
function interp_text(splitline,offset,modified)
	local temptarg
	if #splitline > 1 then
		local potential_targ = splitline[#splitline]
		if targ_reps[potential_targ] then
			potential_targ = targ_reps[potential_targ]
		end
		temptarg = valid_target(potential_targ)
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
		lastsent = r_line['prefix']..' "'..r_line['english']..'" '..(temptarg or target_make(r_line['validtarget']))
		if debugging then add_to_chat(8,tostring(counter)..' input '..lastsent) end
		if logging then
			logfile:write('\n\n',tostring(os.clock()),'Original: ',table.concat(splitline,' '),'\n(180) ',lastsent)
			logfile:flush()
		end
		send_command('@input '..lastsent)
		return ''
	end
	lastsent = ''
	return modified
end


-----------------------------------------------------------------------------------
--Name: convert_spell()
--Args:
---- spell (string): Proposed spell
-----------------------------------------------------------------------------------
--Returns:
---- Either false, or a corrected spell name.
-----------------------------------------------------------------------------------
function convert_spell(spell)
	local name_line = validabils[(spell or ''):lower():gsub(' ',''):gsub('[^%w]','')]
	
	if name_line then
		if name_line.typ == 'r_spells' then
			r_line = r_spells[name_line.index]
		elseif name_line.typ == 'r_abilities' then
			r_line = r_abilities[name_line.index]
		elseif name_line.typ == 'ambig_names' then
			r_line, s_type = ambig(strip(spell))
		end
		if r_line then
			return r_line[language]
		else
			return false
		end
	else
		return false
	end
end