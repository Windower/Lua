--[[Copyright © 2014-2017, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Nostrum nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL trv BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER I N CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

overlay.name = 'MsJans'
overlay.author = 'trv'
overlay.version = '1.0.0'

require 'display_settings'
require 'helper_functions'
require 'macro_builder'

settings = config.load('data/display_settings.xml', settings)

bg = {}
macro = {{}, {}, {}}
palette = {{}, {}, {}, buffs = {}, statuses = {}}
macro_grid = {}
palette_grid = {}
-- buff_grid
-- specials_grid : This exists if the specials settings aren't empty
widget_lookup = {{}, {}, {}}
misc_bin = {}
display = require 'display'

register_event('load', function()
	get_palette_settings()
	palette_settings_parser()
	load_text_dimensions()
	measure_text_labels(settings.text.macro_buttons, macro_order.macro_labels)
	measure_text_labels(settings.text.name, L{'menu'}
		:extend(macro_order.status_labels) 
		:extend(macro_order.buff_labels) 
		:extend(macro_order.status) 
		:extend(macro_order.buff) 
	)
	
	for i = 1, 3 do
		local count = get_party(i).count
		
		if count > 0 then
			macro_builder.new_party(i)
			
			for j = 1, count do
				macro_builder.new_player(i, j)
			end
		end
	end
	
	macro_builder.header()
	macro_builder.specials()
	macro_builder.highlight()
	macro_builder.target()
end)

register_event('new party', function(position)
	if check_display_state(position) then return end
	
	macro_builder.new_party(position)
end)

register_event('member join', function(party, position, player)
	local bin = widget_lookup[party][position]
	
	if bin then
		bin:link(player)
		bin:show()
		bin:refresh()
	else
		macro_builder.new_player(party, position)	
	end
end)

register_event('member leave', function(party_number, position)
	local party = get_party(party_number)
	local count = party.count
	local party_widget_bin = widget_lookup[party_number]

	for i = position, count do
		local bin = party_widget_bin[i]
		
		bin:link(party[i])
		bin:refresh()
	end

	local last_line = party_widget_bin[count + 1]
	
	last_line:hide()
	last_line:unlink()
	
	if party_number == 1 and buff_grid then
		local empty_position = (count + 1) * 2
		
		for i = empty_position - 1, empty_position do
			local r = buff_grid[i]
			
			for j = 16, 1, -1 do
				local image = r[j]
				
				if not image then break end
				
				image:hide()
				buff_grid:ignore_visibility(image, true)
			end
		end
		
		if position ~= count + 1 then
			local buffs = get_buff_array(position)
			local new_count = buffs.n
			local old_count = 0
			
			for j = position * 2, position * 2 - 1, -1 do -- not ideal
				local row = buff_grid[j]
				
				for k = 16, 1, -1 do
					if row[k] then
						old_count = old_count + 1
					else
						break
					end
				end
			end
			
			local t = {}
			
			for j = 1, new_count do
				t[j] = buffs[j]
			end
			
			draw_buff_display(position, t, old_count, new_count)

			for i = position + 1, count do
				local buffs = get_buff_array(i)
				local new_count = buffs.n
				local old_count = get_buff_array(i - 1).n
				local t = {}
				
				for j = 1, new_count do
					t[j] = buffs[j]
				end
				
				draw_buff_display(i, t, old_count, new_count)
			end
		end
	end
end)

register_event('hp change', function(party, position, new, old)
	widget_lookup[party][position]:draw_hp(new)
end)

register_event('mp change', function(party, position, new, old)
	widget_lookup[party][position]:draw_mp(new)
end)

register_event('tp change', function(party, position, new, old)
	widget_lookup[party][position]:draw_tp(new)
end)

register_event('mpp change', function(party, position, new, old)
	widget_lookup[party][position]:draw_mpp(new)
end)

register_event('hpp change', function(party, position, new, old)
	widget_lookup[party][position]:draw_hpp(new, old)
end)

register_event('member zone', function(party, spot, new, old)
	local widget_bin = widget_lookup[party][spot]

	if new == 0 then
		widget_bin:in_zone()
	elseif old == 0 then
		widget_bin:out_of_zone()
	end
end)

if settings.prim.target.create_target_display then
	register_event('target change', function(target)
		if nostrum_available() then
			target_display:visible(true)
		end
		
		if target.valid_target then
			update_all_target()
		else
			target_display:visible(false)
		end
	end)

	register_event('target hpp change', function(new, old)
		target_display.hpp:text(tostring(target.hpp))
		target_display.phpp:width(settings.prim.target.width * target.hpp / 100)		
	end)
end

register_event('addon command', function(command, ...)
	local command = command and command:lower() or 'help'
	
	if command == 'help' then
		print(
			[[\cs(200, 155, 20)MsJans overlay commands:\cr
				profile(p) <name>: Reconstructs the palette 
				 - using the specified profile from settings.
				cut(c): Removes blank lines from the display.]]
		)
	elseif command == 'profile' or command == 'p' then
		load_new_profile(select(1, ...))
	elseif command == 'cut' or command == 'c' then
		cut()
	end
end)

if settings.prim.buffs.display_party_buffs then
	register_event('buff change', function(party_spot, old_count, new_count, changes)
		draw_buff_display(party_spot, changes, old_count, new_count)
	end)
end

register_event('distance change', function(party, spot, distance_squared)
	local out_of_range = distance_squared >= 441
	local player = get_player(party, spot)
	
	if out_of_range ~= player.out_of_range then
		player.out_of_range = out_of_range
		
		local widget_bin = widget_lookup[party][spot]
		
		if out_of_range then
			widget_bin:out_of_range()
		else
			widget_bin:in_range()
		end
	end
end)

register_event('member appear', function(party, spot)
	local widget_bin = widget_lookup[party][spot]
	
	widget_bin:in_sight()
end)

register_event('member disappear', function(party, spot)
	local widget_bin = widget_lookup[party][spot]
	
	widget_bin:out_of_sight()
end)
