-- Scoreboard addon for Windower4. See readme.md for a complete description.

_addon = _addon or {}
_addon.name = 'Scoreboard'
_addon.author = 'Suji'
_addon.version = '1.07'
_addon.commands = {'sb', 'scoreboard'}

require('tables')
require('strings')
require('maths')
require('logger')
require('actions')
local file = require('files')
config = require('config')

local Display = require('display')
local display = nil
dps_clock = require('dpsclock'):new() -- global for now
dps_db    = require('damagedb'):new() -- global for now

-------------------------------------------------------

local settings = nil -- holds a config instance

-- Conventional settings layout
local default_settings = {}
default_settings.numplayers = 8
default_settings.sbcolor = 204
default_settings.showallidps = true
default_settings.resetfilters = true
default_settings.visible = true

default_settings.display = {}
default_settings.display.pos = {}
default_settings.display.pos.x = 500
default_settings.display.pos.y = 100

default_settings.display.bg = {}
default_settings.display.bg.alpha = 200
default_settings.display.bg.red = 0
default_settings.display.bg.green = 0
default_settings.display.bg.blue = 0

default_settings.display.text = {}
default_settings.display.text.size = 10
default_settings.display.text.font = 'Courier New'
default_settings.display.text.fonts = {}
default_settings.display.text.alpha = 255
default_settings.display.text.red = 255
default_settings.display.text.green = 255
default_settings.display.text.blue = 255

-- Accepts msg as a string or a table
function sb_output(msg)
    local prefix = 'SB: '
    local color  = settings['sbcolor']
    
    if type(msg) == 'table' then
        for _, line in ipairs(msg) do
            windower.add_to_chat(color, prefix .. line)
        end
    else
        windower.add_to_chat(color, prefix .. msg)
    end
end

-- Handle addon args
windower.register_event('addon command',function(...)
    local params = {...};
	
    if #params < 1 then
        return
    end

    local chatmodes = T{'s', 'l', 'p', 't', 'say', 'linkshell', 'party', 'tell'}
    
    if params[1] then
        local param1 = params[1]:lower()
        if param1 == "help" then
            sb_output('Scoreboard v' .. _addon.version .. '. Author: Suji')
            sb_output('sb help : Shows help message')
            sb_output('sb pos <x> <y> : Positions the scoreboard')
            sb_output('sb reset : Reset damage')
            sb_output('sb report [<target>] : Reports damage. Can take standard chatmode target options.')
            sb_output('sb reportstat <stat> [<player>] [<target>] : Reports the given stat. Can take standard chatmode target options. Ex: //sb rs acc p')
            sb_output('sb filter show  : Shows current filter settings')
            sb_output('sb filter add <mob1> <mob2> ... : Add mob patterns to the filter (substrings ok)')
            sb_output('sb filter clear : Clears mob filter')
            sb_output('sb visible : Toggles scoreboard visibility')
            sb_output('sb stat <stat> [<player>]: Shows specific damage stats. Respects filters. If player isn\'t specified, ' ..
                  'stats for everyone are displayed. Valid stats are:')
            sb_output(dps_db.player_stat_fields:tostring():stripchars('{}"'))
        elseif param1 == "pos" then
            if params[3] then
                local posx, posy = tonumber(params[2]), tonumber(params[3])
                display:set_position(posx, posy)
            end
        elseif param1 == "set" then
            local setting = params[2]
            if not params[3] then
                return
            end
            
            if setting == 'numplayers' then
                settings.numplayers = tonumber(params[3])
                settings:save()
                display:update()
                sb_output("Setting 'numplayers' set to " .. settings.numplayers)
            elseif setting == 'bgtransparency' then
                settings.display.bg.alpha  = tonumber(params[3])
                settings:save()
                display:update()
                sb_output("Setting 'bgtransparency' set to " .. settings.display.bg.alpha)
            elseif setting == 'font' then
                settings.display.text.font = params[3]
                settings:save()
                display:update()
                sb_output("Setting 'font' set to " .. settings.display.text.font)
            elseif setting == 'sbcolor' then
                settings.sbcolor = tonumber(params[3])
                settings:save()
                sb_output("Setting 'sbcolor' set to " .. settings.sbcolor)
            elseif setting == 'showallidps' then
                if params[3] == 'true' then
                    settings.showallidps = true
                elseif params[3] == 'false' then
                    settings.showallidps = false
                else
                    error("Invalid value for 'showallidps'. Must be true or false.")
                    return
                end
                
                settings:save()
                sb_output("Setting 'showalldps' set to " .. tostring(settings.showallidps))
            elseif setting == 'resetfilters' then
                if params[3] == 'true' then
                    settings.resetfilters = true
                elseif params[3] == 'false' then
                    settings.resetfilters = false
                else
                    error("Invalid value for 'resetfilters'. Must be true or false.")
                    return
                end
                
                settings:save()
                sb_output("Setting 'resetfilters' set to " .. tostring(settings.resetfilters))
            end
        elseif param1 == "reset" then
            reset()
        elseif param1 == "report" then
            local arg = params[2]
            local arg2 = params[3]

            if arg then
                if chatmodes:contains(arg) then
                    if arg2 and not arg2:match('^[a-zA-Z]+$') then
                        -- should be a valid player name
                        error('Invalid argument for report t: ' .. arg2)
                        return
                    end
                else
                    error('Invalid parameter passed to report: ' .. arg)
                    return
                end
            end

            display:report_summary(arg, arg2)

        elseif param1 == "visible" then
            display:toggle_visible()
            settings.visible = not settings.visible
            settings:save()
        elseif param1 == 'filter' then
            local subcmd
            if params[2] then
                subcmd = params[2]:lower()
            else
                error('Invalid option to //sb filter. See //sb help')
                return
            end
            
            if subcmd == 'add' then
                for i=3, #params do
                    dps_db:add_filter(params[i])
                end
                display:update()
            elseif subcmd == 'clear' then
                dps_db:clear_filters()
                display:update()
            elseif subcmd == 'show' then
                display:report_filters()
            else
                error('Invalid argument to //sb filter')
            end
        elseif param1 == 'stat' then
            if not params[2] or not dps_db.player_stat_fields:contains(params[2]:lower()) then
                error('Must pass a stat specifier to //sb stat. Valid arguments: ' ..
                      dps_db.player_stat_fields:tostring():stripchars('{}"'))
            else
                local stat = params[2]:lower()
                local player = params[3]
                display:show_stat(stat, player)
            end
        elseif param1 == 'reportstat' or param1 == 'rs' then
            if not params[2] or not dps_db.player_stat_fields:contains(params[2]:lower()) then
                error('Must pass a stat specifier to //sb reportstat. Valid arguments: ' ..
                      dps_db.player_stat_fields:tostring():stripchars('{}"'))
                return
            end
            
            local stat = params[2]:lower()
            local arg2 = params[3] -- either a player name or a chatmode
            local arg3 = params[4] -- can only be a chatmode

            -- The below logic is obviously bugged if there happens to be a player named "say",
            -- "party", "linkshell" etc but I don't care enough to account for those people!
            
            if chatmodes:contains(arg2) then
                -- Arg2 is a chatmode so we assume this is a 3-arg version (no player specified)
                display:report_stat(stat, {chatmode = arg2, telltarget = arg3})
            else
                -- Arg2 is not a chatmode, so we assume it's a player name and then see
                -- if arg3 looks like an optional chatmode.
                if arg2 and not arg2:match('^[a-zA-Z]+$') then
                    -- should be a valid player name
                    error('Invalid argument for reportstat t ' .. arg2)
                    return
                end
                
                if arg3 and not chatmodes:contains(arg3) then
                    error('Invalid argument for reportstat t ' .. arg2 .. ', must be a valid chatmode.')
                    return
                end
                
                display:report_stat(stat, {player = arg2, chatmode = arg3, telltarget = params[5]})
            end
        elseif param1 == 'fields' then
            do  error("Not implemented yet.") return end
        elseif param1 == 'save' then
            if false then -- dps_db:empty() then
                error('Nothing to save.')
                return
            else
                if params[2] then
                    if not params2:match('^[a-ZA-Z0-9_-,.:]+$') then
                        error("Invalid filename: " .. params[2])
                        return
                    end
                    save(params[2])
                else
                    save()
                end
            end
        else
            error('Unrecognized command. See //sb help')
        end
    end
end)

local months = {
    'jan', 'feb', 'mar', 'apr',
    'may', 'jun', 'jul', 'aug',
    'sep', 'oct', 'nov', 'dec'
}

local function fexists(fname)

end


function save(filename)
    if not filename then
        local date = os.date("*t", os.time())
        filename = string.format("sb_%s-%d-%d-%d-%d.txt",
                                  months[date.month],
                                  date.day,
                                  date.year,
                                  date.hour,
                                  date.min)
    end
    local parse = file.new('data/parses/' .. filename)

    if parse:exists() then
        local dup_path = file.new(parse.path)
        local dup = 0

        while dup_path:exists() do
            dup_path = file.new(parse.path .. '.' .. dup)
            dup = dup + 1
        end
        parse = dup_path
    end
    parse:create()
end

-- Resets application state
function reset()
    display:reset()
    dps_clock:reset()
    dps_db:reset()
end


local function update_dps_clock()
    local player = windower.ffxi.get_player()
    if player and player.in_combat then
        dps_clock:advance()
    else
        dps_clock:pause()
    end
end


-- Keep updates flowing
windower.register_event('time change', 'status change', function()
    update_dps_clock()
    display:update()
end)


windower.register_event('login', 'load', function()
    -- Bail out until we are logged in properly.
    local player = windower.ffxi.get_player()
    if not player then
        return
    end

    settings = config.load(default_settings)
    windower.send_command('alias sb lua c scoreboard')
    
    if not display then
        display = Display:new(settings, dps_db)
        reset()
    end
end)


windower.register_event('unload', function()
    settings:save()
    windower.send_command('unalias sb')
    display:destroy()
end)


-- Returns all mob IDs for anyone in your alliance, including their pets.
function get_ally_mob_ids()
    local allies = T{}
    local party = windower.ffxi.get_party()

    for _, member in pairs(party) do
        if member.mob then
            allies:append(member.mob.id)
            if member.mob.pet_index and member.mob.pet_index> 0 then
                allies:append(windower.ffxi.get_mob_by_index(member.mob.pet_index).id)
            end
        end
    end
	
    return allies
end


-- Returns true iff is someone (or a pet of someone) in your alliance.
function mob_is_ally(mob_id)
    -- get zone-local ids of all allies and their pets
    return get_ally_mob_ids():contains(mob_id)
end


windower.register_event('action', function(raw_action)
    local action = Action(raw_action)
    local category = action:get_category_string()

    local player = windower.ffxi.get_player()
    if not player or not windower.ffxi.get_player()['in_combat'] then
        -- nothing to do
        return
    end
    
    if mob_is_ally(action.raw.actor_id) then
        if category == 'melee' then
            for target in action:get_targets() do
                for subaction in target:get_actions() do
                    -- hit, crit
                    if subaction.message == 1 or subaction.message == 67 then
                        if subaction.message == 67 then
                            dps_db:add_m_crit(target:get_name(), action:get_actor_name(), subaction.param)
                        else
                            dps_db:add_m_hit(target:get_name(), action:get_actor_name(), subaction.param)
                        end
                        
                        -- enspells etc
                        if subaction.has_add_effect and T{163, 229}:contains(subaction.add_effect_message) then
                            dps_db:add_damage(target:get_name(), action:get_actor_name(), subaction.add_effect_param)
                        end
                    elseif subaction.message == 15 or subaction.message == 63 then
                        dps_db:incr_misses(target:get_name(), action:get_actor_name())
                    end
                end
            end
        elseif category == 'weaponskill_finish' then
            -- TODO: need to map whatever id into the actual ws name
        
            for target in action:get_targets() do
                for subaction in target:get_actions() do
                    dps_db:add_ws_damage(target:get_name(), action:get_actor_name(), subaction.param, action.raw.param)

                    -- skillchains
                    if subaction.has_add_effect then
                        local actor_name = action:get_actor_name()
                        local sc_name = string.format("Skillchain(%s%s)", actor_name:sub(1, 3),
                                                      actor_name:len() > 3 and '.' or '')
                        dps_db:add_damage(target:get_name(), sc_name, subaction.add_effect_param)
                    end
                end
            end
        elseif category == 'spell_finish' then
            for target in action:get_targets() do
                for subaction in target:get_actions() do
                    if T{2, 252, 265, 650}:contains(subaction.message) then
                        dps_db:add_damage(target:get_name(), action:get_actor_name(), subaction.param)
                    end
                end
            end
        elseif category == 'ranged_finish' then
            for target in action:get_targets() do
                for subaction in target:get_actions() do
                    -- barrage(157), ranged, crit, squarely, truestrike
                    if T{157, 352, 353, 576, 577}:contains(subaction.message) then
                        if subaction.message == 353 then
                            dps_db:add_r_crit(target:get_name(), action:get_actor_name(), subaction.param)
                        else
                            dps_db:add_r_hit(target:get_name(), action:get_actor_name(), subaction.param)
                        end                    
                        
                        -- holy bolts etc
                        if subaction.has_add_effect and T{163, 229}:contains(subaction.add_effect_message) then
                            dps_db:add_damage(target:get_name(), action:get_actor_name(), subaction.add_effect_param)
                        end
                    elseif subaction.message == 354 then
                        dps_db:incr_r_misses(target:get_name(), action:get_actor_name())
                    end
                end
            end
        elseif category == 'job_ability' or category == 'job_ability_unblinkable' then
            for target in action:get_targets() do
                for subaction in target:get_actions() do
                    -- sange(77), generic damage ja(110), other generic dmg ja (317), stun ja (522)
                    if T{77, 110, 317, 522}:contains(subaction.message) then
                        dps_db:add_damage(target:get_name(), action:get_actor_name(), subaction.param)
                    end
                end
            end
        elseif category == 'avatar_tp_finish' then
            for target in action:get_targets() do
                for subaction in target:get_actions() do
                    if subaction.message == 317 then
                        dps_db:add_damage(target:get_name(), action:get_actor_name(), subaction.param)
                    end
                end
            end
        elseif category == 'mob_tp_finish' then
            for target in action:get_targets() do
                for subaction in target:get_actions() do
                    if subaction.message == 185 or subaction.message == 264 then
                        dps_db:add_damage(target:get_name(), action:get_actor_name(), subaction.param)
                    end
                end
            end        
        end
    elseif category == 'melee' then
        -- This is some non-ally action packet. We need to see if they are hitting someone
        -- in this alliance, and if so, accumulate any damage from spikes/counters/etc.
        for target in action:get_targets() do
            if mob_is_ally(target.id) then
                for subaction in target:get_actions() do
                    if subaction.has_spike_effect then
                        dps_db:add_damage(action:get_actor_name(), target:get_name(), subaction.spike_effect_param)
                    end
                end
            end
        end
    end
	
    display:update()
    update_dps_clock()
end)
--event_action = event_action_aux


--[[
Copyright (c) 2013, Jerry Hebert
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Scoreboard nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL JERRY HEBERT BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

