-- Scoreboard addon for Windower4. See readme.md for a complete description.

require 'tablehelper'
require 'stringhelper'
require 'mathhelper'
require 'logger'

require 'actionhelper'

local config = require 'config'

-----------------------------

local settings = nil -- holds a config instance
local settings_file = 'data/settings.xml'

local player_display_count = 8 -- num of players to display. configured via settings file

local dps_db = T{}
local mob_filter = T{} -- subset of mobs that we're currently displaying damage for

-- DPS clock variables
local dps_active = false
local dps_clock = 1 -- avoid div/0
local dps_clock_prev_time = 0

local default_settings_file = [[
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
		<posX>10</posX>
		<posY>250</posY>
		<bgTransparency>200</bgTransparency>
		<numPlayers>8</numPlayers>
	</global>

	<!--
	You may also override specific settings on a per-character basis here.
	-->
</settings>
]]

function error(msg)
	add_to_chat(167, 'Scoreboard error: ' .. msg)
end

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
			write('sb report : Reports damage to current chatmode')
			write('sb filters  : Shows current filter settings')
			write('sb add <mob1> <mob2> ... : Add mob patterns to the filter (substrings ok)')
			write('sb clear : Clears mob filter')
		elseif params[1]:lower() == "pos" then
			if params[3] then
				tb_set_location('scoreboard', params[2], params[3])
			end
		elseif params[1]:lower() == "reset" then
			initialize()
		elseif params[1]:lower() == "report" then
			local arg = params[2]
			local arg2 = params[3]
			
			if arg then
				if T{'s', 'l', 'p', 't'}:contains(arg) then
					if arg2 and not arg2:match('^%w+$') then
						-- should be a valid player name
						error('Invalid argument for report t: ' .. arg2)
						return
					end
				else
					error('Invalid parameter passed to report: ' .. arg)
				end
			end
			
			report_summary(arg, arg2)
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
			update_scoreboard()
		elseif params[1]:lower() == "clear" then
			mob_filter = T{}
			update_scoreboard()
		end
	end
end


-- Resets all data tracking variables
function initialize()
	dps_db = T{}

	dps_active = false
	dps_clock = 1
	dps_clock_prev_timestamp = 0
	
	-- the number of spaces here was counted to keep the table width
	-- consistent even when there's no data being displayed
	tb_set_text('scoreboard',  build_scoreboard_header() ..
							   'Waiting for results...' ..
							   string.rep(' ', 17))
end


function update_dps_clock()
	if get_player()['in_combat'] then
		local now = os.time()

		if dps_clock_prev_time == 0 then
			dps_clock_prev_time = now
		end

		dps_clock = dps_clock + (now - dps_clock_prev_time)
		dps_clock_prev_time = now

		dps_active = true
	else
		dps_active = false
		dps_clock_prev_time = 0
	end
end


-- Secondary update driver to keep the DPS moving between swings and keep the clock moving.
function event_time_change(...)
	update_dps_clock()
	
	if not dps_db:isempty() then
		update_scoreboard()
	end
end


function event_status_change(old, new)
	update_dps_clock()
	
	if not dps_db:isempty() then
		update_scoreboard()
	end
end


function event_load()
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

	player_display_count = settings['numplayers'] or player_display_count
	
	send_command('alias sb lua c scoreboard')
	
	local transparency = tonumber(settings['bgtransparency']) or 200
	local posx = tonumber(settings['posx']) or 10
	local posy = tonumber(settings['posy']) or 200
	
	tb_create('scoreboard')
	tb_set_bg_color('scoreboard', transparency, 30, 30, 30)
	tb_set_font('scoreboard', 'courier', 10)
	tb_set_color('scoreboard', 255, 225, 225, 225)
	tb_set_location('scoreboard', posx, posy)
	tb_set_visibility('scoreboard', 1)
	tb_set_bg_visibility('scoreboard', 1)

	initialize()
end


function actor_is_party_member(action)
	local party = get_active_party()
	if party[action:get_actor_name()] then
		return true
	else
		return false
	end
end


function event_action(raw_action)
	local action = Action(raw_action)
	local category = action:get_category_string()
	
	if not actor_is_party_member(action) and category == 'melee' then
		for target in action:get_targets() do
			for subaction in target:get_actions() do
				if subaction.has_spike_effect then
					accumulate(action:get_actor_name(), target:get_name(), subaction.spike_effect_param)
				end
			end
		end
	elseif category == 'melee' then
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
				if subaction.message == 2 then
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
	
	update_scoreboard()
	update_dps_clock()
end


function event_unload()
	send_command('unalias sb')
	tb_delete('scoreboard')
end

-- Adds the given data to the main DPS table
function accumulate(mob, player, damage)
	local active_party = get_active_party()
	if not active_party[player] then
		return
	end

	mob = string.lower(mob:gsub('^[tT]he ', ''))
	if not dps_db[mob] then
		dps_db[mob] = T{}
	end
	
	damage = tonumber(damage)
	if not dps_db[mob][player] then
		dps_db[mob][player] = damage
	else
		dps_db[mob][player] = damage + dps_db[mob][player] 
	end
end


function get_active_party()
	local party_data = get_party()
	local new_party = {}
	
	for _, member in pairs(party_data) do
		new_party[member["name"]] = 1
	end
	
	return new_party
end


-- Returns following two element pair:
-- 1) table of sorted 2-tuples containing {player, damage}
-- 2) integer containing the total damage done
function get_sorted_player_damage()
	-- In order to sort by damage, we have to first add it all up into a table
	-- and then build a table of sortable 2-tuples and then finally we can sort...
	local mob, players
	local player_total_dmg = T{}

	if not dps_db then
		return
	end
	
	local function filter_contains_mob(mob_name)
		for _, mob_pattern in ipairs(mob_filter) do
			if mob_name:lower():find(mob_pattern:lower()) then
				return true
			end
		end
		return false
	end
	
	for mob, players in pairs(dps_db) do
		-- If the filter isn't active, include all mobs

		if mob_filter:isempty() or filter_contains_mob(mob) then
			for player, damage in pairs(players) do
				if player_total_dmg[player] then
					player_total_dmg[player] = player_total_dmg[player] + damage
				else
					player_total_dmg[player] = damage
				end
			end
		end
	end
	
	local sortable = T{}
	local total_damage = 0
	for player, damage in pairs(player_total_dmg) do
		total_damage = total_damage + damage
		sortable:append({player, damage})
	end

	local function cmp(a, b) 
		return a[2] > b[2]
	end
	table.sort(sortable, cmp)
	
	return sortable, total_damage
end

-- Convert integer seconds into a "HhMmSs" string
function seconds_to_hms(seconds)
	hours = math.floor(seconds / 3600)
	seconds = seconds - hours * 3600

	minutes = math.floor(seconds / 60)
	seconds = seconds - minutes * 60
	
	local hours_str    = hours > 0 and hours .. "h" or ""
	local minutes_str  = minutes > 0 and minutes .. "m" or ""
	local seconds_str  = seconds and seconds .. "s" or ""
	
	return hours_str .. minutes_str .. seconds_str
end


-- Returns the string for the scoreboard header with updated info
-- about current mob filtering and whether or not time is currently
-- contributing to the DPS value.
function build_scoreboard_header()
	local mob_filter_str
	
	if mob_filter:isempty() then
		mob_filter_str = "All"
	else
		mob_filter_str = table.concat(mob_filter, ", ")
	end
	
	local labels
	if dps_db:isempty() then
		labels = "\n"
	else
		labels = string.format("%23s%7s%8s\n", "Tot", "Pct", "DPS")
	end
	
	local dps_status
	if dps_active then
		dps_status = "Active"
	else
		dps_status = "Paused"
	end

	local dps_clock_str = ''
	if dps_active or dps_clock > 1 then
		dps_clock_str = string.format(" (%s)", seconds_to_hms(dps_clock))
	end
	return string.format("DPS: %s%s\nMobs: %-9s\n%s",  dps_status, dps_clock_str, mob_filter_str, labels)
end


-- Updates the main display with current filter/damage/dps status
function update_scoreboard()
	local damage_table, total_damage
	damage_table, total_damage = get_sorted_player_damage()
	
	local display_table = T{}
	local player_lines = 0
	for k, v in pairs(damage_table) do
		if player_lines < player_display_count then
			local dps = math.round(v[2]/dps_clock, 2)
			local percent = string.format('(%.1f%%)', 100 * v[2]/total_damage)
			display_table:append(string.format("%-16s%7d%8s %7.2f", v[1], v[2], percent, dps))
		end
		player_lines = player_lines + 1
	end
	
	if not dps_db:isempty() then
		tb_set_text('scoreboard', build_scoreboard_header() .. table.concat(display_table, '\n'))
	end
end


function report_summary (...)
	local chatmode, tell_target = table.unpack({...})
	
	local damage_table, total_damage
	damage_table, total_damage = get_sorted_player_damage()
	local max_line_length = 127 -- game constant

	-- We have to make sure not to exceed max line or it can cause a crash
	local display_table = T{}
	local line_length = 0
	for k, v in pairs(damage_table) do
		-- TODO: this algorithm doesn't quite work right but it's close
		formatted_entry = string.format("%s %d(%.1f%%)", v[1], v[2], 100 * v[2]/total_damage)
		local new_line_length = line_length + formatted_entry:len() + 2 -- 2 is for the sep
		
		if new_line_length < max_line_length then
			display_table:append(formatted_entry)
			line_length = new_line_length
		else
			-- If we don't break here, a subsequent player could fit but that would result
			-- in out-of-order damage reporting
			break
		end
	end

	-- Send the report to the current chatmode
	local input_cmd = 'input '
	if chatmode then
		input_cmd = input_cmd .. '/' .. chatmode .. ' '
		if tell_target then
			input_cmd = input_cmd .. tell_target .. ' '
		end
	end
	send_command(input_cmd .. table.concat(display_table, ', '))
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
