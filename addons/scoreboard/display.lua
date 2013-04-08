mob_filter = T{} -- subset of mobs that we're currently displaying damage for
player_display_count = 8 -- num of players to display. configured via settings file


function display_init()
  -- the number of spaces here was counted to keep the table width
	-- consistent even when there's no data being displayed
	tb_set_text('scoreboard',  build_scoreboard_header() ..
							   'Waiting for results...' ..
							   string.rep(' ', 17))

end


function display_update()
	update_scoreboard()
end


-- Returns the string for the scoreboard header with updated info
-- about current mob filtering and whether or not time is currently
-- contributing to the DPS value.
local function build_scoreboard_header()
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
local function update_scoreboard()
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


-- Returns following two element pair:
-- 1) table of sorted 2-tuples containing {player, damage}
-- 2) integer containing the total damage done
local function get_sorted_player_damage()
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
local function seconds_to_hms(seconds)
	hours = math.floor(seconds / 3600)
	seconds = seconds - hours * 3600

	minutes = math.floor(seconds / 60)
	seconds = seconds - minutes * 60
	
	local hours_str    = hours > 0 and hours .. "h" or ""
	local minutes_str  = minutes > 0 and minutes .. "m" or ""
	local seconds_str  = seconds and seconds .. "s" or ""
	
	return hours_str .. minutes_str .. seconds_str
end


function display_report_summary (...)
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

