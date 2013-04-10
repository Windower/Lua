-- Scoreboard addon for Windower4. See readme.md for a complete description.

_addon = _addon or {}
_addon.name = 'Scoreboard'
_addon.version = 0.5

require 'tablehelper'
require 'stringhelper'
require 'mathhelper'
require 'logger'
require 'actionhelper'
local config = require 'config'

require 'display'
require 'model'
-----------------------------

settings = nil -- holds a config instance
settings_file = 'data/settings.xml'

default_settings_file = [[
<?xml version="1.0" ?>
<settings>
	<!--
	This file controls the settings for the Scoreboard plugin.
	Settings in the <global> section apply to all characters

	The available settings are:
		posX - x coordinate for position
		posY - y coordinate for position
		numPlayers - The maximum number of players to display damage for
		bgTransparency - Transparency level for the background. 0-255 range
	-->
	<global>
		<posX>600</posX>
		<posY>100</posY>
		<bgTransparency>200</bgTransparency>
		<numPlayers>8</numPlayers>
	</global>

	<!--
	You may also override specific settings on a per-character basis here.
	-->
</settings>
]]


-- Handle addon args
function event_addon_command(...)
    local params = {...};
	
    if #params < 1 then
        return
    end

    if params[1] then
        if params[1]:lower() == "help" then
            write('sb help : Shows help message')
            write('sb pos <x> <y> : Positions the scoreboard')
            write('sb reset : Reset damage')
            write('sb report [<target>] : Reports damage. Can take standard chatmode target options.')
            write('sb filters  : Shows current filter settings')
            write('sb add <mob1> <mob2> ... : Add mob patterns to the filter (substrings ok)')
            write('sb clear : Clears mob filter')
        elseif params[1]:lower() == "pos" then
            if params[3] then
                local posx, posy = tonumber(params[2]), tonumber(params[3])
                tb_set_location('scoreboard', posx, posy)
                if posx ~= settings.posx or posy ~= settings.posy then
                    settings.posx = posx
                    settings.posy = posy
                    settings:save()
                end
            end
        elseif params[1]:lower() == "reset" then
            initialize()
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

            display_report_summary(arg, arg2)
        elseif params[1]:lower() == "filters" then
            local mob_str
            if mob_filter:isempty() then
                mob_str = "Scoreboard filters: None (Displaying damage for all mobs)"
            else
                mob_str = "Scoreboard filters: " .. mob_filter:concat(', ')
            end
                add_to_chat(55, mob_str)
        elseif params[1]:lower() == "add" then
            for i=2, #params do
                mob_filter:append(params[i])
            end
            display_update()
        elseif params[1]:lower() == "clear" then
            mob_filter = T{}
            display_update()
        end
    end
end


-- Resets application state
function initialize()
    model_init()
    display_init()
end


-- Keep updates flowing
function event_time_change(...)
    model_update()
    display_update()
end


-- Keep updates flowing
function event_status_change(...)
    model_update()
    display_update()
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

    -- Write a default settings file if it doesn't exist
    local f = io.open(lua_base_path .. settings_file, 'r')
    if not f then
        f = io.open(lua_base_path .. settings_file, 'w')
        if not f then
            error('Scoreboard: Error generating default settings file.')
        else
            f:write(default_settings_file)
            local result = f:close()
            if not result then
                error('Scoreboard: Error generating default settings file.')
            else
                add_to_chat(55, 'Scoreboard: Settings file not found; installed default.')
            end
        end
    else
        f:close()
    end
    settings = config.load()

    local player_display_count = settings['numplayers'] or player_display_count
    send_command('alias sb lua c scoreboard')

    local transparency = tonumber(settings['bgtransparency']) or 200
    local posx = tonumber(settings['posx']) or 10
    local posy = tonumber(settings['posy']) or 200

    display_create(posx, posy, transparency, player_display_count)

    initialize()
end


function event_unload()
    send_command('unalias sb')
    display_destroy()
end


-- Returns all mob IDs for anyone in your alliance, including their pets.
function get_ally_mob_ids()
    local allies = T{}
    local party = get_party()

    for _, member in pairs(party) do
        if member.mob then
            allies:append(member.mob.id)
            if member.mob.pet_target_id > 0 then
                allies:append(get_mob_by_target_id(member.mob.pet_target_id).id)
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


function event_action(raw_action)
    local action = Action(raw_action)
    local category = action:get_category_string()

    if mob_is_ally(action.raw.actor_id) then
        if category == 'melee' then
            for target in action:get_targets() do
                for subaction in target:get_actions() do
                    -- hit, crit
                    if subaction.message == 1 or subaction.message == 67 then
                        accumulate(target:get_name(), action:get_actor_name(), subaction.param)
                        if subaction.has_add_effect and T{163, 229}:contains(subaction.add_effect_message) then
                            accumulate(target:get_name(), action:get_actor_name(), subaction.add_effect_param)
                        end
                    end
                end
            end
        elseif category == 'weaponskill_finish' then
            for target in action:get_targets() do
                for subaction in target:get_actions() do
                    accumulate(target:get_name(), action:get_actor_name(), subaction.param)

                    -- skillchains
                    if subaction.has_add_effect then
                        accumulate(target:get_name(), action:get_actor_name(), subaction.add_effect_param)
                    end
                end
            end
        elseif category == 'spell_finish' then
            for target in action:get_targets() do
                for subaction in target:get_actions() do
                    if T{2, 252, 265, 650}:contains(subaction.message) then
                        accumulate(target:get_name(), action:get_actor_name(), subaction.param)
                    end
                end
            end
        elseif category == 'ranged_finish' then
            for target in action:get_targets() do
                for subaction in target:get_actions() do
                    -- ranged, crit, squarely, truestrike
                    if T{352, 353, 576, 577}:contains(subaction.message) then
                        accumulate(target:get_name(), action:get_actor_name(), subaction.param)

                        -- holy bolts etc
                        if subaction.has_add_effect and T{163, 229}:contains(subaction.add_effect_message) then
                            accumulate(target:get_name(), action:get_actor_name(), subaction.add_effect_param)
                        end
                    end
                end
            end
        elseif category == 'job_ability' or category == 'job_ability_unblinkable' then
            for target in action:get_targets() do
                for subaction in target:get_actions() do
                    -- sange(77), generic damage ja(110), barrage(157), other generic dmg ja (317), stun ja (522)
                    if T{77, 110, 157, 317, 522}:contains(subaction.message) then
                        accumulate(target:get_name(), action:get_actor_name(), subaction.param)
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
                        accumulate(action:get_actor_name(), target:get_name(), subaction.spike_effect_param)
                    end
                end
            end
        end
    end
	
    display_update()
    model_update()
end


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
