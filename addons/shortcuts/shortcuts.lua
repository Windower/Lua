--Copyright (c) 2014, Byrthnoth
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

_addon.version = '2.903'
_addon.name = 'Shortcuts'
_addon.author = 'Byrth'
_addon.commands = {'shortcuts'}


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

if not windower.dir_exists(windower.addon_path..'data') then
    windower.create_dir(windower.addon_path..'data')
end

require 'sets'
require 'lists'
require 'helper_functions'
require 'tables'
require 'strings'
res = require 'resources'
config = require 'config'

default_aliases = {
    c1="Cure",
    c2="Cure II",
    c3="Cure III",
    c4="Cure IV",
    c5="Cure V",
    c6="Cure VI",
    r1="Raise",
    r2="Raise II",
    r3="Raise III",
    pro1="Protectra",
    pro2="Protectra II",
    pro3="Protectra III",
    pro4="Protectra IV",
    pro5="Protectra V",
    sh1="Shellra",
    sh2="Shellra II",
    sh3="Shellra III",
    sh4="Shellra IV",
    sh5="Shellra V",
    she1="Shellra",
    she2="Shellra II",
    she3="Shellra III",
    she4="Shellra IV",
    she5="Shellra V",
    bl="Blink",
    ss="Stoneskin",
    re1="Regen",
    re2="Regen II",
    re3="Regen III",
    re4="Regen IV",
    re5="Regen V",
    holla="Teleport-Holla",
    dem="Teleport-Dem",
    mea="Teleport-Mea",
    yhoat="Teleport-Yhoat",
    altep="Teleport-Altep",
    vahzl="Teleport-Vahzl",
    jugner="Recall-Jugner",
    pashh="Recall-Pashh",
    meri="Recall-Meriph",
    pash="Recall-Pashh",
    meriph="Recall-Meriph",
    ichi="Utsusemi: Ichi",
    ni="Utsusemi: Ni",
    utsu1="Utsusemi: Ichi",
    utsu2="Utsusemi: Ni",
    ds="Divine Seal",
    es="Elemental Seal",
    la="Light Arts",
    da="Dark Arts",
    pen="Penury",
    cel="Celerity",
    cw1="Curing Waltz",
    cw2="Curing Waltz II",
    cw3="Curing Waltz III",
    cw4="Curing Waltz IV",
    cw5="Curing Waltz V",
    hw="Healing Waltz"
}
default_settings = {
    include_items = false,
}

aliases = config.load('data/aliases.xml', default_aliases)
settings = config.load('data/settings.xml', default_settings)
config.save(aliases)
config.save(settings)
setmetatable(aliases,nil)
setmetatable(settings,nil)


require 'statics'
require 'targets'

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
    debug_chat('outgoing_text: '..modified..' '..tostring(windower.ffxi.get_mob_by_target('st')))
    temp_org = temp_org:gsub(' <wait %d+>',''):sub(2)

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
    local cmd,bool = command_logic(combined,combined) -- and then dump it into command_logic()
    if cmd and bool and cmd ~= '' then
        if cmd:sub(1,1) ~= '/' then cmd = '/'..cmd end
        windower.send_command('@input '..cmd)
    end
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
    local splitline = alias_replace(string.split(original,' '):filter(-''))
    local command = splitline[1] -- Treat the first word as a command.
    local potential_targ = '/nope//'
    if splitline.n ~= 1 then
        potential_targ = splitline[splitline.n]
    end
    local a,b,spell = string.find(original,'"(.-)"')

    if unhandled_list[command] then
        return modified,true
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
        return modified,true
    elseif command2_list[command] and not valid_target(potential_targ,true) then
        -- If the command is legitimate and requires target completion but not ability interpretation

        if not command2_list[command].args then -- If there are not any secondary commands
            local temptarg = valid_target(potential_targ) or target_make(command2_list[command]) -- Complete the target or make one.
            if temptarg ~= '<me>' then -- These commands, like emotes, check, etc., don't need to default to <me>
                lastsent = '/'..command..' '..temptarg -- Push the command and target together and send it out.
            else
                lastsent = '/'..command
            end

            debug_chat('258: input '..lastsent)
            if logging then
                logfile:write('\n\n',tostring(os.clock()),'Original: ',original,'\n(162) ',lastsent)
                logfile:flush()
            end
            windower.send_command('@input '..lastsent)
            return '',false
        else -- If there are secondary commands (like /pcmd add <name>)
            local tempcmd = command
            local passback
            local targs = command2_list[command]
            for _,v in ipairs(splitline) do -- Iterate over the potential secondary arguments.
                if command2_list[command]['args'] and command2_list[command]['args'][v] then
                    tempcmd = tempcmd..' '..v
                    passback = v
                    targs = command2_list[command]['args'][v]
                    break
                end
            end
            local temptarg = ''
            if targs ~= true then
                -- Target is required
                if command == potential_targ or passback and passback == potential_targ or potential_targ == '/nope//' then
                    -- No target is provided
                    temptarg = target_make(targs)
                else
                    -- A target is provided, which is either corrected or (if not possible) used raw
                    temptarg = valid_target(potential_targ) or potential_targ
                end
            end
            lastsent = '/'..tempcmd..' '..temptarg
            debug_chat('292: input '..lastsent)
            if logging then
                logfile:write('\n\n',tostring(os.clock()),'Original: ',original,'\n(193) ',lastsent)
                logfile:flush()
            end
            windower.send_command('@input '..lastsent)
            return '',false
        end
    elseif command2_list[command] then
        -- If the submitted command does not require ability interpretation and is fine already, send it out.
        lastsent = ''
        if logging then
            logfile:write('\n\n',tostring(os.clock()),'Original: ',original,'\n(146) Legitimate command')
            logfile:flush()
        end
        return modified,true
    elseif command_list[command] then
        -- If there is a valid command, then pass the text with an offset of 1 to the text interpretation function
        return interp_text(splitline,1,modified)
    else
        -- If there is not a valid command, then pass the text with an offset of 0 to the text interpretation function
        return interp_text(splitline,0,modified)
    end
end


-----------------------------------------------------------------------------------
--Name: alias_replace(tab)
--Args:
---- tab (table of strings): splitline
-----------------------------------------------------------------------------------
--Returns:
---- tab (table of strings): with all the aliased values replaced
-----------------------------------------------------------------------------------
function alias_replace(tab)
    for ind,key in ipairs(tab) do
        if aliases[key:lower()] then
            tab[ind] = aliases[key:lower()]
        end
    end
    return tab
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
    -- Assume there was not a target suffix on the command.
    local preliminary_action_name = table.concat(splitline,' ',1+offset,splitline.n)
    local preliminary_action_name_normalized_as_item = strip_non_alphanumeric_keep_plus_fix_hq(preliminary_action_name)
    local preliminary_action_name_normalized_as_nonitem = strip_non_alphanumeric_convert_digits_to_roman(preliminary_action_name)

    -- Note: The normalized 'item' name is almost strictly more specific than
    -- the normalized 'nonitem' name, and thus the former must be searched
    -- before the latter to avoid falsely matching the wrong entry.
    local temporary_target_name, normalized_preliminary_action_name
    if validabils[preliminary_action_name_normalized_as_item] then
        normalized_preliminary_action_name = preliminary_action_name_normalized_as_item
    elseif validabils[preliminary_action_name_normalized_as_nonitem] then
        normalized_preliminary_action_name = preliminary_action_name_normalized_as_nonitem
    elseif splitline.n > 1 then
        temporary_target_name = valid_target(targ_reps[splitline[splitline.n]] or splitline[splitline.n])
    end

    -- Compute a better name to look up based on the result of the above.
    local finalized_action_name = normalized_preliminary_action_name
    if temporary_target_name then
        finalized_action_name = _raw.table.concat(splitline,' ',1+offset,splitline.n-1)
    elseif not normalized_preliminary_action_name then
        finalized_action_name = _raw.table.concat(splitline,' ',1+offset,splitline.n)
    end

    -- Re-normalize the action name, but using the finalized name
    local finalized_action_name_normalized_as_item = strip_non_alphanumeric_keep_plus_fix_hq(finalized_action_name)
    local finalized_action_name_normalized_as_nonitem = strip_non_alphanumeric_convert_digits_to_roman(finalized_action_name)

    
    log(preliminary_action_name)
    log(preliminary_action_name_normalized_as_item)
    log(preliminary_action_name_normalized_as_nonitem)
    log('normalized: ', normalized_preliminary_action_name)
    log('finalized')
    log(finalized_action_name_normalized_as_item)
    log(finalized_action_name_normalized_as_nonitem)
    
    -- Note: The normalized 'item' name is almost strictly more specific than
    -- the normalized 'nonitem' name, and thus the former must be searched
    -- before the latter to avoid falsely matching the wrong entry.
    local actions_by_normalized_name
    if validabils[finalized_action_name_normalized_as_item] then
        actions_by_normalized_name = validabils[finalized_action_name_normalized_as_item]
    else
        actions_by_normalized_name = validabils[finalized_action_name_normalized_as_nonitem]
    end

    if actions_by_normalized_name then
        local options,nonoptions,num_opts = {},{},0
        local player = windower.ffxi.get_player()
        for v in actions_by_normalized_name:it() do
            if check_usability(player,v.res,v.id) then
                options[v.res] = v.id
                num_opts = num_opts + 1
            elseif v.res ~= nil then
                nonoptions[v.res] = v.id
            end
        end

        -- If there are usable options then prioritize:
        -- Prefix, if given -> Spells -> Job Abilities -> Weapon Skills -> Monster Skills
        local r_type,r_idx,r_line
        local opts_to_use = num_opts > 0 and options or nonoptions
        if offset == 1 and opts_to_use[command_list[splitline[1]]] then
            r_type = command_list[splitline[1]]
        else
            r_type = (opts_to_use.spells       and 'spells')
                or (opts_to_use.job_abilities  and 'job_abilities')
                or (opts_to_use.weapon_skills  and 'weapon_skills')
                or (opts_to_use.monster_skills and 'monster_skills')
                or (opts_to_use.mounts         and 'mounts')
                or (opts_to_use.items          and 'items')
        end
        if opts_to_use[command_list[splitline[1]]] then
            r_idx = opts_to_use[command_list[splitline[1]]]
        else
            r_idx = opts_to_use.spells
                or opts_to_use.job_abilities
                or opts_to_use.weapon_skills
                or opts_to_use.monster_skills
                or opts_to_use.mounts
                or opts_to_use.items
        end
        r_line = res[r_type][r_idx]

        -- Modify r_line to contain 'prefix' for items.
        if r_line and not r_line.prefix and r_type == 'items' then
            r_line = r_line:copy()
            r_line.prefix = '/item'
        end

        local targets = table.reassign({},r_line.targets)

        -- Handling for abilities that change potential targets.
        if r_line.skill == 40 and r_line.cast_time == 8 and L(player.buffs):contains(409) then
            targets.Party = true -- Pianissimo changes the target list of
        elseif r_line.skill == 44 and r_line.en:find('Indi-') and L(player.buffs):contains(584) then
            targets.Party = true -- Indi- spells can be cast on others when Entrust is up
        end

        local abil_name = r_line.english -- Remove spaces at the end of the ability name.
        while abil_name:sub(-1) == ' ' do
            abil_name = abil_name:sub(1,-2)
        end

        local out_tab = {prefix = in_game_res_commands[r_line.prefix:gsub("/","")], name = abil_name, target = temporary_target_name or target_make(targets)}
        if not out_tab.prefix then print('Could not find prefix',r_line.prefix) end
        lastsent = out_tab.prefix..' "'..out_tab.name..'" '..out_tab.target
        if logging then
            logfile:write('\n\n',tostring(os.clock()),'Original: ',table.concat(splitline,' '),'\n(180) ',lastsent)
            logfile:flush()
        end
        debug_chat('390 comp '..lastsent:sub(2):gsub('"([^ ]+)"', '%1'):lower()..'   ||    '..table.concat(splitline,' ',1,splitline.n):gsub('"([^ ]+)"', '%1'):lower())
        if offset == 1 and in_game_res_commands[splitline[1]] and in_game_res_commands[splitline[1]] == out_tab.prefix and
            ('"'..out_tab.name..'" '..out_tab.target):gsub('"([^ ]+)"', '%1'):lower() == table.concat(splitline,' ',2,splitline.n):gsub('"([^ ]+)"', '%1'):lower() then
            debug_chat('400 return '..lastsent)
            return lastsent,true
        else
            debug_chat('403 input '..lastsent)
            windower.send_command('@input '..lastsent)
            return '',false
        end
    end
    lastsent = ''
    return modified,false
end