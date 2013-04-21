--[[
Copyright (c) 2013, Sebastien Gomez
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon = {}
_addon.name = 'MobCompass'
_addon.version = '1.0'

require 'tablehelper'  -- Required for various table related features. Made by Arcon
require 'logger'       -- Made by arcon. Here for debugging purposes
require 'stringhelper' -- Required to parse the other files. Probably made by Arcon
require 'mathhelper'
local config = require 'config'
file = require 'filehelper'

local settingtab = nil
local settings_file = 'data\\settings.xml'
local settingtab = config.load(settings_file)
if settingtab == nil then
	write('No settings file found. Ensure you have a file at data\\settings.xml')
end

function event_load()

	info = get_ffxi_info()
	player = get_player()

	box_name = 'direction'
	box_name2 = 'direction2'
	box_name3 = 'direction3'
	tb_create(box_name)
	tb_create(box_name2)
	tb_create(box_name3)

	a = 0
	r = settingtab['bg_red']
	g = settingtab['bg_green']
	b = settingtab['bg_blue']
	r1 = settingtab['txt_red']
	g1 = settingtab['txt_green']
	b1 = settingtab['txt_blue']
	x_pos = settingtab['x_pos']
	y_pos = settingtab['y_pos']
	bold = settingtab['txt_bold']
	mode = tostring(settingtab['defaultmode'])
	showbuff = settingtab.geomode.showbuff
	showangle = tostring(settingtab.thfmode.showangle)
	
	--geo compass
	tb_set_bg_color(box_name, a, r, g, b)
	tb_set_bg_visibility(box_name, true)
	tb_set_bold(box_name, bold)
	tb_set_location(box_name, x_pos, y_pos)
	tb_set_right_justified(box_name, false)
	tb_set_color(box_name, a, r1, g1, b1)
	--geo showbuff
	tb_set_bg_color(box_name2, a, r, g, b)
	tb_set_bg_visibility(box_name2, true)
	tb_set_bold(box_name2, bold)
	tb_set_location(box_name2, x_pos, (y_pos))
	tb_set_right_justified(box_name2, false)
	tb_set_color(box_name2, a, r1, g1, b1)
	--thf SA compass
	tb_set_bg_color(box_name3, a, r, g, b)
	tb_set_bg_visibility(box_name3, true)
	tb_set_bold(box_name3, bold)
	tb_set_location(box_name3, x_pos, (y_pos - 20))
	tb_set_right_justified(box_name3, false)
	tb_set_color(box_name3, a, r1, g1, b1)

	checktext1 = ''
	checktext2 = ''
	checktext3 = ''
	checka = 0
	loop = 1
	
	send_command('alias mobcompass lua c mobcompass')
	send_command('alias mc mobcompass')
		
	if info.logged_in == true then
		loop = 0
		write('Commands are:')
		write('To change Compass style: ')
		write('Command = " MC mode [thf | geo] "')
		write('To change Displays while in associated modes: ')
		write('Geo command : " MC mode geo showbuff "')
		write('Thf command : " MC mode thf showangle [always | behind | never] "')
		get_target()
	end

end

function event_unload()
	loop = 1
	tb_delete(box_name)
	tb_delete(box_name2)
	tb_delete(box_name3)
end

function event_login()
	loop = 0
	get_target()
end

function event_logout(name)
	loop = 1
end

function event_addon_command(...)
    local term = table.concat({...}, ' ')
	broken = term:split(' ',4)

	if broken ~= nil then
		if tostring(broken[1]):lower() == 'mode' then
			if broken[2] ~= nil then
				if broken[2] == 'thf' or broken[2] == 'geo' then
					
					mode = broken[2]
					
					if broken[3] ~= nil and broken[2] == 'geo' then
						if broken[3] == 'showbuff' then
							showbuff = not showbuff
							write('MC mode geo "showbuff" changed to "'..tostring(showbuff)..'".')
						else 
							write('Command "'..broken[3]..'" is not valid.')
							write('Use "//MC mode geo showbuff" to change display')
						end
					elseif broken[3] ~= nil and broken[2] == 'thf' then
							--print('Thf mode set. Use "//MC mode thf showangle [always | behind | never]" to change display')
						if broken[3] == 'showangle' and broken[4] ~= nil then
							if broken[4] == 'always' then
								showangle = 'always'
								write('MC mode thf "showangle" changed to "'..showangle..'".')
							elseif broken[4] == 'behind' then
								showangle = 'behind'
								write('MC mode thf "showangle" changed to "'..showangle..'".')
							elseif broken[4] == 'never' then
								showangle = 'never'
								write('MC mode thf "showangle" changed to "'..showangle..'".')
							else
								write('Command "'..broken[4]..'" is not valid.')
								write('Use "//MC mode thf showangle [always | behind | never]" to change display')
							end
						else 
							write('Command "'..broken[3]..'" is not valid.')
							write('Use "//MC mode thf showangle [always | behind | never]" to change display')
						end
					end
				else
					write('Command "'..broken[2]..'" is not valid.')
					write('Commands are:')
					write('Command 1 : //MC mode [thf|geo]')
				end
			end
		else
			write('Command "'..broken[1]..'" is not valid.')
			write('Commands are:')
			write('To change Compass style: ')
			write('Command = " MC mode [thf | geo] "')
			write('To change Displays while in associated modes: ')
			write('Geo command : " MC mode geo showbuff "')
			write('Thf command : " MC mode thf showangle [always | behind | never] "')
		end
	end
end

function get_target()
	--Player info
	player = T(get_player())
	P = T(get_mob_by_id(player.id))
	Px = P.x_pos
	Py = P.y_pos
	
	-- Target info
	target = T(get_mob_by_index(player.target_index))
	target_id = target.id
	
	if (target_id ~= 0) and (target_id ~= nil) and (target_id ~= player.id) and (target.is_npc == true) then
		a = 255
		
		Mx = target.x_pos
		My = target.y_pos
		
		angle = calc_standard_angle(Px, Py, Mx, My)
		direction = angle_to_direction(angle)
		
		target_name = target.name
		text = direction..' '..angle..' °'
		
		Mfacing = target.facing
		angle2 = calc_behind(Mfacing, Px, Py, Mx, My)
		text3 = is_sa(angle2)
		
		if mode == 'geo' then
			text2 = ''
			set_tb2(0,tostring(text2))
			
			set_tb(255,tostring(text))
			if showbuff == true then
				if direction == 'N' then
					text5 = 'buff = Recast'
				elseif direction == 'NE' then
					text5 = 'buff = Recast + Macc'
				elseif direction == 'E' then
					text5 = 'buff = Macc'
				elseif direction == 'SE' then
					text5 = 'buff = Macc + MCR'
				elseif direction == 'S' then
					text5 = 'buff = MCR'
				elseif direction == 'SW' then
					text5 = 'buff = MCR + Matt'
				elseif direction == 'W' then
					text5 = 'buff = Matt'
				elseif direction == 'NW' then
					text5 = 'buff = Matt + Recast'
				else
					text5 = 'buff = ...'
				end
				set_tb3(255,tostring(text5))
			else
				text3 = ''
				set_tb3(0,tostring(text5))
			end
		elseif mode == 'thf' then
			text = ''
			set_tb(0,tostring(text))
			text5 = ''
			set_tb3(0,tostring(text5))
			
			if showangle == 'always' then
				if text3 == 'BAD' then
					text2 = 'SA: '..text3..' | Behind: '..angle2..' °'
				elseif text3 == 'OK' then
					text2 = 'SA: '..text3.. ' | Behind: '..angle2..' °'
				end
			elseif showangle == 'behind' then
				if text3 == 'BAD' then
					text2 = 'SA: '..text3
				elseif text3 == 'OK' then
					text2 = 'SA: '..text3.. ' | Behind: '..angle2..' °'
				end
			elseif showangle == 'never' then
				text2 = 'SA: '..text3
			end
			set_tb2(255,tostring(text2))
		end
		
	elseif (target_id == 0) or (target_id == nil) or (target_id == player.id) or (target.is_npc == false) then
		a = 0
		text = ''
		text2 = ''
		text5 = ''
		set_tb(a,tostring(text))
		set_tb2(a,tostring(text2))
		set_tb3(a,tostring(text5))
	end
		
	checka = a
	checktext1 = text
	checktext2 = text2
	checktext3 = text5
	
	if loop == 0 then
		send_command('@wait 0.1;lua i MobCompass get_target')
	end
	
end

function set_tb(alpha,text)
	tb_set_bg_color(box_name, alpha, r, g, b)
	tb_set_color(box_name, alpha, r1, g1, b1)
	if checktext1 ~= text then
		tb_set_text(box_name, text)
	end
end

function set_tb2(alpha,text2)
	tb_set_bg_color(box_name2, alpha, r, g, b)
	tb_set_color(box_name2, alpha, r1, g1, b1)
	if checktext2 ~= text2 then
		tb_set_text(box_name2, text2)
	end
end

function set_tb3(alpha,text5)
	tb_set_bg_color(box_name3, alpha, r, g, b)
	tb_set_color(box_name3, alpha, r1, g1, b1)
	if checktext3 ~= text5 then
		tb_set_text(box_name3, text5)
	end
end

function calc_standard_angle(Px, Py, Mx, My)

	Px = tonumber(Px)
	Py = tonumber(Py)
	Mx = tonumber(Mx)
	My = tonumber(My)
	
	PM = (Px - Mx) / (Py - My)
	PM_angle = math.atan(PM) * 180/math.pi

	if (Px > Mx) and (Py > My) then
		
		angle = PM_angle 
	
	elseif (Px > Mx) and (Py < My) then
		
		angle = 180 + PM_angle 
	
	elseif (Px < Mx) and (Py < My) then
	
		angle = 180 + PM_angle
	
	elseif (Px < Mx) and (Py > My) then
	
		angle = 360 + PM_angle 
	
	elseif (Px == Mx) and (Py < My) then
		angle = 0
	elseif (Px > Mx) and (Py == My) then
		angle = 90
	elseif (Px == Mx) and (Py > My) then
		angle = 180
	elseif (Px < Mx) and (Py == My) then
		angle = 270
	end
	
	if angle ~= nil then 
		return angle:round(1)
	end

end

function angle_to_direction(angle)

	angle = tonumber(angle)
	direction = ''
	
	if (angle <= 11.25) and (angle >= 0) then
		direction = 'N'
	elseif angle <= 360 and angle > (11.25 * 31) then
		direction = 'N'
	elseif angle <= (11.25 * 3) and angle > 11.25 then
		direction = 'NNE'
	elseif angle <= (11.25 * 5) and angle > (11.25 * 3) then
		direction = 'NE'
	elseif angle <= (11.25 * 7) and angle > (11.25 * 5) then
		direction = 'NEE'
	elseif angle <= (11.25 * 9) and angle > (11.25 * 7) then
		direction = 'E'
	elseif angle <= (11.25 * 11) and angle > (11.25 * 9) then
		direction = 'SEE'
	elseif angle <= (11.25 * 13) and angle > (11.25 * 11) then
		direction = 'SE'
	elseif angle <= (11.25 * 15) and angle > (11.25 * 13) then
		direction = 'SSE'
	elseif angle <= (11.25 * 17) and angle > (11.25 * 15) then
		direction = 'S'
	elseif angle <= (11.25 * 19) and angle > (11.25 * 17) then
		direction = 'SSW'
	elseif angle <= (11.25 * 21) and angle > (11.25 * 19) then
		direction = 'SW'
	elseif angle <= (11.25 * 23) and angle > (11.25 * 21) then
		direction = 'SWW'
	elseif angle <= (11.25 * 25) and angle > (11.25 * 23) then
		direction = 'W'
	elseif angle <= (11.25 * 27) and angle > (11.25 * 25) then
		direction = 'NWW'
	elseif angle <= (11.25 * 29) and angle > (11.25 * 27) then
		direction = 'NW'
	elseif angle <= (11.25 * 31) and angle > (11.25 * 29) then
		direction = 'NNW'
	end
	
	return tostring(direction)	

end

function calc_behind(Mfacing, Px, Py, Mx, My)
	
	Mfacing = (Mfacing * 180/math.pi):round(2)
		
	SA_Angle = calc_standard_angle(Px, Py, Mx, My) - 90
	if SA_Angle < 0 then
		SA_Angle = 360 + SA_Angle
	end
	
	if ((Mfacing - SA_Angle) <= 180) and ((Mfacing - SA_Angle) > 0)then
		SA_Angle = 180 - (Mfacing - SA_Angle)
	elseif (Mfacing - SA_Angle) > 180 then
		SA_Angle = ((Mfacing - SA_Angle) - 180) * -1
	elseif (Mfacing - SA_Angle) <= 0  then
		SA_Angle = (180 + (Mfacing - SA_Angle)) * -1
	end
	
	return SA_Angle:round(2)
	
end

function is_sa(angle2) 
	sa = ''
	if (angle2 >= 0) and (angle2 < 45) then
		sa = 'OK'	
	elseif (angle2 < 0) and (angle2 > -45) then
		sa = 'OK'
	else
		sa = 'BAD'
	end
	
	return sa
end




