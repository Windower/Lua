-- Display object

local Display = {
    visible = true,
    settings = nil,
    filter = T{},
    tb_name = 'scoreboard'
}

local valid_fonts = T{
    'fixedsys',
    'lucida console',
    'courier',
    'courier new',
    'ms mincho',
    'consolas',
    'dejavu sans mono'
}

function Display:set_position(posx, posy)
    self.settings.posx = posx
    self.settings.posy = posy
    tb_set_location(self.tb_name, posx, posy)
end


function Display:new (settings, db)
    local repr = {db = db}
    self.settings = settings
    setmetatable(repr, self)
    self.__index = self

    tb_create(self.tb_name)
    tb_set_bg_color(self.tb_name, self.settings.bgtransparency, 30, 30, 30)
    
    if not valid_fonts:contains(self.settings.font:lower()) then
        error('Invalid font specified: ' .. self.settings.font)
        tb_set_font(self.tb_name, 'courier', self.settings.fontsize)
    else
        tb_set_font(self.tb_name, self.settings.font, self.settings.fontsize)
    end
    
    tb_set_color(self.tb_name, 255, 225, 225, 225)
    tb_set_location(self.tb_name, self.settings.posx, self.settings.posy)
    tb_set_visibility(self.tb_name, self.visible)
    tb_set_bg_visibility(self.tb_name, 1)

    return repr
end


function Display:toggle_visible()
    local old_visibility = self.visible
    self.visible = not self.visible

    if not old_visibility then
        self:update()
    end

    tb_set_visibility(self.tb_name, self.visible)
end


function Display:clear_filters()
    self.filter = T{}
    self:update()
end


function Display:add_filter(mob_pattern)
    if mob_pattern then self.filter:append(mob_pattern) end
end


function Display:report_filters()
    local mob_str
    if self.filter:isempty() then
        mob_str = "Scoreboard filters: None (Displaying damage for all mobs)"
    else
        mob_str = "Scoreboard filters: " .. self.filter:concat(', ')
    end
    add_to_chat(55, mob_str)

end


-- Returns the string for the scoreboard header with updated info
-- about current mob filtering and whether or not time is currently
-- contributing to the DPS value.
function Display:build_scoreboard_header()
    local mob_filter_str
	
    if self.filter:isempty() then
        mob_filter_str = "All"
    else
        mob_filter_str = table.concat(self.filter, ", ")
    end
	
    local labels
    if self.db:isempty() then
        labels = "\n"
    else
        labels = string.format("%23s%7s%9s\n", "Tot", "Pct", "DPS")
    end
	
    local dps_status
    if dps_clock:is_active() then
        dps_status = "Active"
    else
        dps_status = "Paused"
    end

    local dps_clock_str = ''
    if dps_clock:is_active() or dps_clock.clock > 1 then
        dps_clock_str = string.format(" (%s)", dps_clock:to_string())
    end
    local dps_chunk = string.format("DPS: %s%s", dps_status, dps_clock_str)
    return string.format("%s%s\nMobs: %-9s\n%s", dps_chunk, string.rep(" ", 29 - dps_chunk:len()) .. "//sb help", mob_filter_str, labels)
end


function Display:_filter_contains_mob(mob_name)
    if self.filter:isempty() then
        return true
    end
    
    for _, mob_pattern in ipairs(self.filter) do
        if mob_name:lower():find(mob_pattern:lower()) then
            return true
        end
    end
    return false
end

    
-- Returns following two element pair:
-- 1) table of sorted 2-tuples containing {player, damage}
-- 2) integer containing the total damage done
function Display:get_sorted_player_damage()
    -- In order to sort by damage, we have to first add it all up into a table
    -- and then build a table of sortable 2-tuples and then finally we can sort...
    local mob, players
    local player_total_dmg = T{}

    if self.db:isempty() then
        return {}, 0
    end
	
                     -- TODO: this is waiting on self.db:iter()
    for mob, players in pairs(self.db.db) do
        -- If the filter isn't active, include all mobs

        if self:_filter_contains_mob(mob) then
            for player_name, player in pairs(players) do
                if player_total_dmg[player_name] then
                    player_total_dmg[player_name] = player_total_dmg[player_name] + player.damage
                else
                    player_total_dmg[player_name] = player.damage
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


-- Updates the main display with current filter/damage/dps status
function Display:update()
    if not self.visible then
        -- no need build a display while it's hidden
        return
    end

    local damage_table, total_damage
    damage_table, total_damage = self:get_sorted_player_damage()
	
    local display_table = T{}
    local player_lines = 0
    for k, v in pairs(damage_table) do
        if player_lines < self.settings.numplayers then
            local dps
            if dps_clock.clock == 0 then
                dps = "N/A"
            else
                dps = string.format("%.2f", math.round(v[2]/dps_clock.clock, 2))
            end
            
            local percent
            if total_damage > 0 then
                percent = string.format('(%.1f%%)', 100 * v[2]/total_damage)
            else
                percent = '(0%)'
            end
            display_table:append(string.format("%-16s%7d%8s %7s", v[1], v[2], percent, dps))
        end
        player_lines = player_lines + 1
    end
	
    if self.db:isempty() then
        self:reset()
    else
        tb_set_text(self.tb_name, self:build_scoreboard_header() .. table.concat(display_table, '\n'))
    end
end


function Display:report_summary (...)
    local chatmode, tell_target = table.unpack({...})
	
    local damage_table, total_damage
    damage_table, total_damage = self:get_sorted_player_damage()
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


function Display:show_stat(stat, player_filter)
    -- this feels like it should be in the db module

    local Player = require 'player'
    local mega_players = T{}
    for mob, players in pairs(self.db.db) do
        if self:_filter_contains_mob(mob) then
            for name, player in pairs(players) do
                if (player_filter and player_filter == name) or not player_filter then
                    if not mega_players[name] then
                        mega_players[name] = Player:new{name = name}
                    end
                    mega_players[name]:merge(player)
                end
            end
        end
    end
    
    local stat_total = T{}
    mega_players:vprint()
end


function Display:reset()
    -- the number of spaces here was counted to keep the table width
    -- consistent even when there's no data being displayed
    tb_set_text(self.tb_name,  self:build_scoreboard_header() ..
                               'Waiting for results...' ..
                               string.rep(' ', 17))
end


function Display:destroy()
    tb_delete(self.tb_name)
end


return Display

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

