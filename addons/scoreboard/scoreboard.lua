-- Scoreboard addon for Windower4. See readme.md for a complete description.

_addon = _addon or {}
_addon.name = 'Scoreboard'
_addon.version = 0.9

require 'tablehelper'
require 'stringhelper'
require 'mathhelper'
require 'logger'
require 'actionhelper'
local config = require 'config'

local Display = require 'display'
local display = nil
dps_clock = require 'dpsclock':new() -- global for now
dps_db    = require 'damagedb':new() -- global for now

-------------------------------------------------------

local settings = nil -- holds a config instance

-- Accepts msg as a string or a table
function sb_output(msg)
    local prefix = 'SB: '
    local color  = settings['sbcolor']
    
    if type(msg) == 'table' then
        for _, line in ipairs(msg) do
            add_to_chat(color, prefix .. line)
        end
    else
        add_to_chat(color, prefix .. msg)
    end
end

-- Handle addon args
function event_addon_command(...)
    local params = {...};
	
    if #params < 1 then
        return
    end

    if params[1] then
        if params[1]:lower() == "help" then
            sb_output('Scoreboard v' .. _addon.version .. '. Author: Suji')
            sb_output('sb help : Shows help message')
            sb_output('sb pos <x> <y> : Positions the scoreboard')
            sb_output('sb reset : Reset damage')
            sb_output('sb report [<target>] : Reports damage. Can take standard chatmode target options.')
            sb_output('sb filter show  : Shows current filter settings')
            sb_output('sb filter add <mob1> <mob2> ... : Add mob patterns to the filter (substrings ok)')
            sb_output('sb filter clear : Clears mob filter')
            sb_output('sb visible : Toggles scoreboard visibility')
            sb_output('sb stat <stat> [<player>]: Shows specific damage stats. Respects filters. If player isn\'t specified, ' ..
                  'stats for everyone are displayed. Valid stats are:')
            sb_output(dps_db.player_stat_fields:tostring():stripchars('{}"'))
        elseif params[1]:lower() == "pos" then
            if params[3] then
                local posx, posy = tonumber(params[2]), tonumber(params[3])
                display:set_position(posx, posy)
                
                if posx ~= settings.posx or posy ~= settings.posy then
                    settings.posx = posx
                    settings.posy = posy
                    settings:save()
                end
            end
        elseif params[1]:lower() == "reset" then
            reset()
        elseif params[1]:lower() == "report" then
            local arg = params[2]
            local arg2 = params[3]

            if arg then
                if T{'s', 'l', 'p', 't', 'say', 'linkshell', 'party', 'tell'}:contains(arg) then
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
        elseif params[1]:lower() == "filters" then
            sb_output("'//sb filters' is deprecated. Please use '//sb filter show' in the future. See //sb help")
            display:report_filters()
        elseif params[1]:lower() == "add" then
            sb_output("'//sb add ...' is deprecated. Please use '//sb filter add ...' in the future. See //sb help")
            for i=2, #params do
                dps_db:add_filter(params[i])
            end
            display:update()
        elseif params[1]:lower() == "clear" then
            sb_output("'//sb clear' is deprecated. Please use '//sb filter clear' in the future. See //sb help")
            dps_db:clear_filters()
            display:update()
        elseif params[1]:lower() == "visible" then
            display:toggle_visible()
        elseif params[1]:lower() == 'filter' then
            if params[2]:lower() == 'add' then
                for i=3, #params do
                    dps_db:add_filter(params[i])
                end
                display:update()
            elseif params[2]:lower() == 'clear' then
                dps_db:clear_filters()
                display:update()
            elseif params[2]:lower() == 'show' then
                display:report_filters()
            else
                error('Invalid argument to //sb filter')
            end
        elseif params[1]:lower() == 'stat' then
            if not params[2] then
                error('Must pass a stat specifier to //sb stat. Valid arguments: ' ..
                      dps_db.player_stat_fields:tostring():stripchars('{}"'))
            else
                local stat = params[2]:lower()
                if dps_db.player_stat_fields:contains(stat) then
                    local player = params[3]
                    if player and player:match('^[a-zA-Z]+$') then
                        player = player:lower():ucfirst()
                    end
                    display:show_stat(stat, player)
                end
            end
        end
    end
end


-- Resets application state
function reset()
    display:reset()
    dps_clock:reset()
    dps_db:reset()
end


local function update_dps_clock()
    if get_player()['in_combat'] then
        dps_clock:advance()
    else
        dps_clock:pause()
    end
end



-- Keep updates flowing
function event_time_change(...)
    update_dps_clock()
    display:update()
end


-- Keep updates flowing
function event_status_change(...)
    update_dps_clock()
    display:update()
end


function event_login(...)
    event_load()
end


function event_load(...)
    -- Bail out until player name is set. The config library depends on player name
    -- being defined to process settings properly.
    local player_name = get_player()['name']
    if player_name == '' then
        return
    end

    settings = config.load({
        posx = 10,
        posy = 200,
        bgtransparency = 200,
        numplayers = 8,
        font = 'courier',
        fontsize = 10,
        sbcolor = 204
    })

    send_command('alias sb lua c scoreboard')
    display = Display:new(settings, dps_db)
    reset()
end


function event_unload()
    send_command('unalias sb')
    display:destroy()
end


-- Returns all mob IDs for anyone in your alliance, including their pets.
function get_ally_mob_ids()
    local allies = T{}
    local party = get_party()

    for _, member in pairs(party) do
        if member.mob then
            allies:append(member.mob.id)
            if member.mob.pet_index > 0 then
                allies:append(get_mob_by_index(member.mob.pet_index).id)
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


function event_action_aux(raw_action)
    local action = Action(raw_action)
    local category = action:get_category_string()

    if not get_player()['in_combat'] then
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
end
event_action = event_action_aux


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

