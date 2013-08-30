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

local valid_fields = T{
    'name',
    'dps',
    'percent',
    'total',
    'acc',
    'racc',
    'crit',
    'rcrit',
    'wsavg'
}

-- Margin of error for a sample size N at 95% confidence
local function moe95(n)
    return 0.98 / math.sqrt(n)
end


function Display:set_position(posx, posy)
    tb_set_location(self.tb_name, posx, posy)
end


function Display:new (settings, db)
    local repr = {db = db}
    self.settings = settings
    setmetatable(repr, self)
    self.__index = self
    self.visible = settings.visible

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

    if self.db:isempty() then
        self:reset()
        return
    end
    
    local damage_table, total_damage
    damage_table, total_damage = self:get_sorted_player_damage()
	
    local display_table = T{}
    local player_lines = 0
    local alli_damage = 0
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
        
        alli_damage = alli_damage + v[2] -- gather this even for players not displayed
        player_lines = player_lines + 1
    end                  
    
    if self.settings.showallidps and dps_clock.clock > 0 then
        display_table:append("-----------------")
        display_table:append("Alli DPS: " .. string.format("%7.1f", alli_damage / dps_clock.clock))
    end
    
    tb_set_text(self.tb_name, self:build_scoreboard_header() .. table.concat(display_table, '\n'))
end


local function build_input_command(chatmode, tell_target)
    local input_cmd = 'input '
    if chatmode then
        input_cmd = input_cmd .. '/' .. chatmode .. ' '
        if tell_target then
            input_cmd = input_cmd .. tell_target .. ' '
        end
    end
    
    return input_cmd
end

-- Takes a table of elements to be wrapped across multiple lines and returns
-- a table of strings, each of which fits within one FFXI line.
local function wrap_elements(elements, header, sep)
    local max_line_length = 120 -- game constant
    if not sep then
        sep = ', '
    end
    
    local lines = T{}
    local current_line = nil
    local line_length
    
    local i = 1
    while i <= #elements do
        if not current_line then
            current_line = T{}
            line_length = header:len()
            lines:append(current_line)
        end
 
        local new_line_length = line_length + elements[i]:len() + sep:len()
        if new_line_length > max_line_length then
            current_line = T{}
            lines:append(current_line)
            new_line_length = elements[i]:len() + sep:len()
        end
        
        current_line:append(elements[i])
        line_length = new_line_length
        i = i + 1
    end
    
    local baked_lines = lines:map(function (ls) return ls:concat(sep) end)
    if header:len() > 0 and #baked_lines > 0 then
        baked_lines[1] = header .. baked_lines[1]
    end
    
    return baked_lines
end


local function slow_output(chatprefix, lines, limit)
    -- this is funky but if we don't wait like this, the lines will spew too fast and error
    send_command(lines:map(function (l) return chatprefix .. l end):concat('; wait 1.2 ; '))
end

  
function Display:report_summary (...)
    local chatmode, tell_target = table.unpack({...})
	
    local damage_table, total_damage
    damage_table, total_damage = self:get_sorted_player_damage()

    local elements = T{}
    for k, v in pairs(damage_table) do
        elements:append(string.format("%s %d(%.1f%%)", v[1], v[2], 100 * v[2]/total_damage))
    end

    -- Send the report to the specified chatmode
    slow_output(build_input_command(chatmode, tell_target),
                wrap_elements(elements:slice(1, self.settings.numplayers), 'Dmg: '), self.settings.numplayers)
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


local function insert_stat_header(header, elements)
    
end

-- TODO: This needs to be factored somehow to take better advantage of similar
--       code already written for reporting and stat queries.
function Display:report_stat(stat, args)
    local stats = self.db:query_stat(stat, args.player)
    
    if T{'acc', 'racc', 'crit', 'rcrit'}:contains(stat) then
        local elements = T{}
        local header   = stat:ucfirst() .. ': '
        for name, stat_pair in pairs(stats) do
            if stat_pair[2] > 0 then
                elements:append({stat_pair[1], string.format("%s %.2f%% (%ds)", name, 100 * stat_pair[1], stat_pair[2])})
            end
        end
        local function cmp(a, b) 
            return a[1] > b[1]
        end
        table.sort(elements, cmp)
        
        -- Send the report to the specified chatmode
        local wrapped = wrap_elements(elements:slice(1, self.settings.numplayers):map(function (p) return p[2] end), header)
        slow_output(build_input_command(args.chatmode, args.telltarget), wrapped, self.settings.numplayers)
    elseif stat == 'wsavg' then
        local elements = T{}
        local header   = stat:ucfirst() .. ': '
        for name, stat_pair in pairs(stats) do
            if stat_pair[2] > 0 then
                elements:append({stat_pair[1], string.format("%s %d (%ds)", name, stat_pair[1], stat_pair[2])})
            end
        end
        local function cmp(a, b) 
            return a[1] > b[1]
        end
        table.sort(elements, cmp)
        
        -- Send the report to the specified chatmode
        local wrapped = wrap_elements(elements:slice(1, self.settings.numplayers):map(function (p) return p[2] end), header)
        slow_output(build_input_command(args.chatmode, args.telltarget), wrapped, self.settings.numplayers)
    end
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


