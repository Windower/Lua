-- Display object

local Display = {
    visible = true,
    settings = nil,
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
    windower.text.set_location(self.tb_name, posx, posy)
end


function Display:new (settings, db)
    local repr = {db = db}
    self.settings = settings
    setmetatable(repr, self)
    self.__index = self

    windower.text.create(self.tb_name)
    windower.text.set_bg_color(self.tb_name, self.settings.bgtransparency, 30, 30, 30)
    
    if not valid_fonts:contains(self.settings.font:lower()) then
        error('Invalid font specified: ' .. self.settings.font)
        windower.text.set_font(self.tb_name, self.settings.font) 
        windower.text.set_font_size(self.tb_name, self.settings.fontsize)
    else
        windower.text.set_font(self.tb_name, self.settings.font,'courier mew','monospace') 
        windower.text.set_font_size(self.tb_name, self.settings.fontsize)
    end
    
    windower.text.set_color(self.tb_name, 255, 225, 225, 225)
    windower.text.set_location(self.tb_name, self.settings.posx, self.settings.posy)
    windower.text.set_visibility(self.tb_name, self.visible)
    windower.text.set_bg_visibility(self.tb_name, 1)

    return repr
end


function Display:toggle_visible()
    local old_visibility = self.visible
    self.visible = not self.visible

    if not old_visibility then
        self:update()
    end

    windower.text.set_visibility(self.tb_name, self.visible)
end


function Display:report_filters()
    local mob_str
    local filters = self.db:get_filters()
    
    if filters:isempty() then
        mob_str = "Scoreboard filters: None (Displaying damage for all mobs)"
    else
        mob_str = "Scoreboard filters: " .. filters:concat(', ')
    end
    add_to_chat(55, mob_str)

end


-- Returns the string for the scoreboard header with updated info
-- about current mob filtering and whether or not time is currently
-- contributing to the DPS value.
function Display:build_scoreboard_header()
    local mob_filter_str
    local filters = self.db:get_filters()

    if filters:isempty() then
        mob_filter_str = "All"
    else
        mob_filter_str = table.concat(filters, ", ")
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
	
    for mob, players in self.db:iter() do
        -- If the filter isn't active, include all mobs
        for player_name, player in pairs(players) do
            if player_total_dmg[player_name] then
                player_total_dmg[player_name] = player_total_dmg[player_name] + player.damage
            else
                player_total_dmg[player_name] = player.damage
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
        windower.text.set_text(self.tb_name, self:build_scoreboard_header() .. table.concat(display_table, '\n'))
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


-- This is a closure around a hash-based dispatcher. Some conveniences are
-- defined for the actual stat display functions.
Display.show_stat = (function()
    local stat_display = {}
    
    local function format_title(msg)
        local line_length = 40
        local msg_length  = msg:len()
        local border_len = math.floor(line_length / 2 - msg_length / 2)
        
        return string.rep(' ', border_len) .. msg .. string.rep(' ', border_len)
    end
    
    stat_display['acc'] = function (stats, filters)
        local lines = T{}
        for name, acc_pair in pairs(stats) do
            lines:append(string.format("%-20s %.2f%% (%d sample%s)", name, 100 * acc_pair[1], acc_pair[2],
                                                                  acc_pair[2] == 1 and "" or "s"))
        end
        
        if #lines > 0 then
            sb_output(format_title('-= Accuracy (' .. filters .. ') =-'))
            sb_output(lines)
        end
    end

    stat_display['racc'] = function (stats, filters)
        local lines = T{}
        for name, racc_pair in pairs(stats) do
            lines:append(string.format("%-20s %.2f%% (%d sample%s)", name, 100 * racc_pair[1], racc_pair[2],
                                                                     racc_pair[2] == 1 and "" or "s"))
        end
        
        if #lines > 0 then
            sb_output(format_title('-= Ranged Accuracy (' .. filters .. ') =-'))
            sb_output(lines)
        end
    end

    stat_display['crit'] = function (stats, filters)
        local lines = T{}
        for name, crit_pair in pairs(stats) do
            lines:append(string.format("%-20s %.2f%% (%d sample%s)", name, 100 * crit_pair[1], crit_pair[2],
                                                                     crit_pair[2] == 1 and "" or "s"))
        end
        
        if #lines > 0 then
            sb_output(format_title('Melee Crit. Rate (' .. filters .. ')'))
            sb_output(lines)
        end
    end
 
    stat_display['rcrit'] = function (stats, filters)
        local lines = T{}
        for name, crit_pair in pairs(stats) do
            lines:append(string.format("%-20s %.2f%% (%d sample%s)", name, 100 * crit_pair[1], crit_pair[2],
                                                                     crit_pair[2] == 1 and "" or "s"))
        end
        
        if #lines > 0 then
            sb_output(format_title('Ranged Crit. Rate (' .. filters .. ')'))
            sb_output(lines)
        end
    end
    
    return function (self, stat, player_filter)
        local stats = self.db:query_stat(stat, player_filter)
        local filters = self.db:get_filters()
        local filter_str
        
        if filters:isempty() then
            filter_str = 'All mobs'
        else
            filter_str = filters:concat(', ')
        end
        
        stat_display[stat](stats, filter_str)
    end
end)()


function Display:reset()
    -- the number of spaces here was counted to keep the table width
    -- consistent even when there's no data being displayed
    windower.text.set_text(self.tb_name,  self:build_scoreboard_header() ..
                               'Waiting for results...' ..
                               string.rep(' ', 17))
end


function Display:destroy()
    windower.text.delete(self.tb_name)
end

windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked then
        return
    end

    if type == 0 then
        if dragged_text then
            local t = dragged_text[1]
            Display:set_position(x - dragged_text[2], y - dragged_text[3])
            return true
        end

    elseif type == 1 then
            local x_pos, y_pos = windower.text.get_location('scoreboard')
            local x_off, y_off = windower.text.get_extents('scoreboard')

            if (x_pos <= x and x <= x_pos + x_off
                or x_pos >= x and x >= x_pos + x_off)
            and (y_pos <= y and y <= y_pos + y_off
                or y_pos >= y and y >= y_pos + y_off) then
                dragged_text = {'scoreboard', x - x_pos, y - y_pos}
                return true
            end

    elseif type == 2 then
        if dragged_text then
            if settings then
                settings:save()
            end
            dragged_text = nil
            return true
        end
    end

    return false
end)

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


