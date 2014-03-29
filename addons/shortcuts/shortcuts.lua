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
logging = false
if windower.dir_exists('../addons/shortcuts/data/') and logging then
    logfile = io.open('../addons/shortcuts/data/NormalLog'..tostring(os.clock())..'.log','w+')
    logfile:write('\n\n','SHORTCUTS LOGGER HEADER: ',tostring(os.clock()),'\n')
    logfile:flush()
end

if windower.file_exists(windower.addon_path..'resources.lua') then
    local result = os.remove(windower.addon_path..'resources.lua')
    if not result then
        os.rename(windower.addon_path..'resources.lua',windower.addon_path..'unnecessary.lua')
    end
end

require 'sets'
require 'helper_functions'
require 'tables'
require 'strings'
res = require 'resources'

require 'statics'
require 'ambiguous_names'
require 'targets'


_addon.version = '1.9'
_addon.name = 'Shortcuts'
_addon.author = 'Byrth'
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
windower.register_event('load',function()
    counter = 0
    lastsent = ''
end)

-----------------------------------------------------------------------------------
--Name: event_unload()
--Args:
---- None
-----------------------------------------------------------------------------------
--Returns:
---- None, simply a routine that runs once at unload.
-----------------------------------------------------------------------------------
windower.register_event('unload',function()
    if logging then    logfile:close()    end
end)


-----------------------------------------------------------------------------------
--Name: event_outgoing_text()
--Args:
---- original (string): Original command entered by the player
---- modified (string): Modified command with changes upstream of the addon
-----------------------------------------------------------------------------------
--Returns:
---- string, changed command
-----------------------------------------------------------------------------------
windower.register_event('outgoing text',function(original,modified)
    local temp_org = windower.convert_auto_trans(modified)
    if modified:sub(1,1) ~= '/' then return modified end
    if debugging then 
        local tempst = windower.ffxi.get_mob_by_target('st')
        windower.add_to_chat(8,modified..' '..tostring(tempst))
    end
    temp_org = temp_org:gsub(' <wait %d+>','')
    if logging then
        logfile:write('\n\n',tostring(os.clock()),'temp_org: ',temp_org,'\nModified: ',modified)
        logfile:flush()
    end
    
    -- If it's the command that was just sent, blank lastsent and pass it through with only the changes applied by other addons
    if modified == lastsent then
        lastsent = ''
        return modified
    end
    
    -- Otherwise, dump the inputs into command_logic()
    return command_logic(temp_org,modified)
end)

-----------------------------------------------------------------------------------
--Name: event_unhandled_command()
--Args:
---- table of strings: //entries split on ' '
-----------------------------------------------------------------------------------
--Returns:
---- None, but can generate text output through command_logic()
-----------------------------------------------------------------------------------
windower.register_event('unhandled command',function(...)
    local combined = windower.convert_auto_trans(table.concat({...},' ')) -- concat it back together...
    command_logic(combined,combined) -- and then dump it into command_logic()
end)


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
    local splitline = string.split(original,' ')
    local command = splitline[1] -- Treat the first word as a command.
    local potential_targ = splitline[splitline.n]
    local a,b,spell = string.find(original,'"(.-)"')
    
    if unhandled_list[command] then
        return modified
    end
    
    if spell then
        spell = spell:lower()
    elseif splitline.n == 3 then
		if valid_target(potential_targ) then
			spell = splitline[2]
		else
			spell = splitline[2]..' '..splitline[3]
		end
    end
    
    if targ_reps[potential_targ] then
        potential_targ = targ_reps[potential_targ]
    end
    
    if ignore_list[command] then -- If the command is legitimate and on the blacklist, return it unaltered.
        lastsent = ''
        return modified
    elseif command2_list[command] and not valid_target(potential_targ,true) then
        -- If the command is legitimate and requires target completion but not ability interpretation
        
        if command2_list[command]==true then -- If there are not any excluded secondary commands
            local temptarg = valid_target(potential_targ) or target_make({['Player']=true,['Enemy']=true,['Party']=true,['Ally']=true,['NPC']=true,['Self']=true,['Corpse']=true}) -- Complete the target or make one.
            if temptarg ~= '<me>' then -- These commands, like emotes, check, etc., don't need to default to <me>
                lastsent = command..' '..temptarg -- Push the command and target together and send it out.
            else
                lastsent = command
            end
            if debugging then windower.add_to_chat(8,tostring(counter)..' input '..lastsent) end
            if logging then
                logfile:write('\n\n',tostring(os.clock()),'Original: ',original,'\n(162) ',lastsent)     
                logfile:flush()
            end
            windower.send_command('@input '..lastsent)
            return ''
        else -- If there are excluded secondary commands (like /pcmd add <name>)
            local tempcmd = command
            local passback
            for _,v in ipairs(splitline) do -- Iterate over the potential secondary arguments.
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
                temptarg = target_make({['Player']=true,['Enemy']=true,['Party']=true,['Ally']=true,['NPC']=true,['Self']=true,['Corpse']=true})
            end
            lastsent = tempcmd..' '..temptarg
            if debugging then windower.add_to_chat(8,tostring(counter)..' input '..lastsent) end
            if logging then
                logfile:write('\n\n',tostring(os.clock()),'Original: ',original,'\n(193) ',lastsent)
                logfile:flush()
            end
            windower.send_command('@input '..lastsent)
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
    elseif command_list[command] and convert_spell(spell or '') and valid_target(potential_targ,true) then
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
    local temptarg,abil
    local no_targ_abil = strip(_raw.table.concat(splitline,' ',1+offset,splitline.n))
    
    if validabils[no_targ_abil] then
        abil = no_targ_abil
    elseif splitline.n > 1 then
        local potential_targ = splitline[splitline.n]
        if targ_reps[potential_targ] then
            potential_targ = targ_reps[potential_targ]
        end
        temptarg = valid_target(potential_targ)
    end

    if temptarg then abil = _raw.table.concat(splitline,' ',1+offset,splitline.n-1)
    elseif not abil then abil = _raw.table.concat(splitline,' ',1+offset,splitline.n) end

    local strippedabil = strip(abil) -- Slug the ability

    if validabils[strippedabil] then -- If the ability exists, do this.
        local r_line, s_type
        
        if validabils[strippedabil].typ == 'spells' then
            if debugging then windower.add_to_chat(8,strippedabil..' is considered a spell.') end
            r_line = res.spells[validabils[strippedabil].index]
        elseif validabils[strippedabil].typ == 'abilities' then
            if debugging then windower.add_to_chat(8,strippedabil..' is considered an ability.') end
            r_line = res.abilities[validabils[strippedabil].index]
        elseif validabils[strippedabil].typ == 'ambig_names' then
            if debugging then windower.add_to_chat(8,strippedabil..' is considered ambiguous.') end
            r_line, s_type = ambig(strippedabil)
        end
        
        local targets = r_line.targets
        
        -- Handling for abilities that change potential targets.
        if r_line.prefix == '/song' or r_line.prefix == '/so' and r_line.casttime == 8 then
            local buffs = windower.ffxi.get_player().buffs
            for i,v in pairs(buffs) do
                if v == 409 then targets.Party = true end -- Pianissimo
            end
        end
        
        lastsent = r_line.prefix..' "'..r_line.english..'" '..(temptarg or target_make(targets))
        if debugging then windower.add_to_chat(8,tostring(counter)..' input '..lastsent) end
        if logging then
            logfile:write('\n\n',tostring(os.clock()),'Original: ',table.concat(splitline,' '),'\n(180) ',lastsent)
            logfile:flush()
        end
        windower.send_command('@input '..lastsent)
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
        if name_line.typ == 'spells' then
            r_line = res.spells[name_line.index]
        elseif name_line.typ == 'abilities' then
            r_line = res.abilities[name_line.index]
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