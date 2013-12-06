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


_addon.name = 'MobCompass'
_addon.version = '1.0'
_addon.commands = {'mobcompass','mc'}

require 'tablehelper'  -- Required for various table related features. Made by Arcon
require 'logger'       -- Made by arcon. Here for debugging purposes
require 'stringhelper' -- Required to parse the other files. Probably made by Arcon
require 'mathhelper'
local config = require 'config'
file = require 'filehelper'

local settingtab = nil
local settings_file = 'data/settings.xml'

windower.register_event('load',function ()
	info = windower.ffxi.get_info()
	player = windower.ffxi.get_player()

	defaults = {}
	defaults.geomode = {}
	defaults.thfmode = {}
	defaults.bg_red = 0
	defaults.bg_blue = 0
	defaults.bg_green = 0
	defaults.txt_red = 255
	defaults.txt_blue = 0
	defaults.txt_green = 0
	defaults.txt_bold = true
	defaults.x_pos = 260
	defaults.y_pos = 550
	defaults.defaultmode = 'geo'
	defaults.geomode.showbuff = true
	defaults.thfmode.showangle = 'always'
	settingtab = config.load(defaults)
	
	if settingtab == nil then
		print('No settings file found. Ensure you have a file at data/settings.xml')
	end
	
	box_name = T()
	local i = 1
	
	for i = 1, 3 do 
		box_name[i] = 'd'..i
		windower.text.create(box_name[i])
		windower.text.set_bg_color(box_name[i], 0, settingtab['bg_red'], settingtab['bg_green'], settingtab['bg_blue'])
		windower.text.set_bg_visibility(box_name[i], true)
		windower.text.set_bold(box_name[i], settingtab['txt_bold'])
		windower.text.set_right_justified(box_name[i], false)
		windower.text.set_color(box_name[i], 0, settingtab['txt_red'], settingtab['txt_green'], settingtab['txt_blue'])
		checktext = T()
		checktext[i] = ''
		if i < 3 then
			windower.text.set_location(box_name[i], settingtab['x_pos'], settingtab['y_pos'])
		else
			windower.text.set_location(box_name[i], settingtab['x_pos'], settingtab['y_pos'] - 20)
		end
	end

	mode = tostring(settingtab['defaultmode'])
	showbuff = settingtab.geomode.showbuff
	showangle = tostring(settingtab.thfmode.showangle)
	loop = 1
		
	if info.logged_in == true then
		loop = 0
		print('Commands are:')
		print('To change Compass style: ')
		print('Command = " MC mode [thf | geo] "')
		print('To change Displays while in associated modes: ')
		print('Geo command : " MC mode geo showbuff "')
		print('Thf command : " MC mode thf showangle [always | behind | never] "')
		get_target()
	end

end)

windower.register_event('unload',function ()
	loop = 1
	local i = 1
	for i = 1,3 do
		windower.text.delete(box_name[i])
	end
end)

windower.register_event('login',function ()
	loop = 0
	get_target()
end)

windower.register_event('logout',function (name)
	loop = 1
	local i = 1
	for i = 1, 3 do
		set_tb(0,'',i)
	end
end)

windower.register_event('addon command',function (...)
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
							print('MC mode geo "showbuff" changed to "'..tostring(showbuff)..'".')
						else 
							print('Command "'..broken[3]..'" is not valid.')
							print('Use "//MC mode geo showbuff" to change display')
						end
					elseif broken[3] ~= nil and broken[2] == 'thf' then
							--print('Thf mode set. Use "//MC mode thf showangle [always | behind | never]" to change display')
						if broken[3] == 'showangle' and broken[4] ~= nil then
							if broken[4] == 'always' then
								showangle = 'always'
								print('MC mode thf "showangle" changed to "'..showangle..'".')
							elseif broken[4] == 'behind' then
								showangle = 'behind'
								print('MC mode thf "showangle" changed to "'..showangle..'".')
							elseif broken[4] == 'never' then
								showangle = 'never'
								print('MC mode thf "showangle" changed to "'..showangle..'".')
							else
								print('Command "'..broken[4]..'" is not valid.')
								print('Use "//MC mode thf showangle [always | behind | never]" to change display')
							end
						else 
							print('Command "'..broken[3]..'" is not valid.')
							print('Use "//MC mode thf showangle [always | behind | never]" to change display')
						end
					end
				else
					print('Command "'..broken[2]..'" is not valid.')
					print('Commands are:')
					print('Command 1 : //MC mode [thf|geo]')
				end
			end
		else
			print('Command "'..broken[1]..'" is not valid.')
			print('Commands are:')
			print('To change Compass style: ')
			print('Command = " MC mode [thf | geo] "')
			print('To change Displays while in associated modes: ')
			print('Geo command : " MC mode geo showbuff "')
			print('Thf command : " MC mode thf showangle [always | behind | never] "')
		end
	end
end)

function get_target()
	--Player info
	player = T(windower.ffxi.get_player())
	P = T(windower.ffxi.get_mob_by_id(player.id))
	local Px = P.x_pos
	local Py = P.y_pos
	local tb_text = T()
	
	-- Target info
	target = T(windower.ffxi.get_mob_by_index(player.target_index))
	target_id = target.id
	local i = 1
	for i = 1,3 do
		tb_text[i] = ''
	end
	
	if (target_id ~= 0) and (target_id ~= nil) and (target_id ~= player.id) and (target.is_npc == true) then
		
		local Mx = target.x_pos
		local My = target.y_pos
						
		if mode == 'geo' then
			local angle = calc_standard_angle(Px, Py, Mx, My)
			local direction = angle_to_direction(angle)
			tb_text[1] = direction..' '..angle..' °'
			
			tb_text[2] = ''
			
			set_tb(0,tostring(tb_text[2]),2)
			set_tb(255,tostring(tb_text[1]),1)
			
			if showbuff and direction == 'N' then
				tb_text[3] = 'buff = Recast'
			elseif showbuff and direction == 'NE' then
				tb_text[3] = 'buff = Recast + Macc'
			elseif showbuff and direction == 'E' then
				tb_text[3] = 'buff = Macc'
			elseif showbuff and direction == 'SE' then
				tb_text[3] = 'buff = Macc + MCR'
			elseif showbuff and direction == 'S' then
				tb_text[3] = 'buff = MCR'
			elseif showbuff and direction == 'SW' then
				tb_text[3] = 'buff = MCR + Matt'
			elseif showbuff and direction == 'W' then
				tb_text[3] = 'buff = Matt'
			elseif showbuff and direction == 'NW' then
				tb_text[3] = 'buff = Matt + Recast'
			else
				tb_text[3] = 'buff = ...'
			end
			set_tb(255,tostring(tb_text[3]),3)
			
			if showbuff == false then 
				tb_text[3] = ''
				set_tb(0,tostring(tb_text[3]),3)
			end
			
		elseif mode == 'thf' then
			local Mfacing = target.facing
			local angle2 = calc_behind(Mfacing, Px, Py, Mx, My)
			tb_text[2] = is_sa(angle2)
			
			tb_text[1] = ''
			set_tb(0,tostring(tb_text[1]),1)
			tb_text[3] = ''
			set_tb(0,tostring(tb_text[3]),3)
			
			if showangle == 'always' and tb_text[2] == 'BAD' then
				tb_text[2] = 'SA: '..tb_text[2]..' | Behind: '..angle2..' °'
			elseif showangle == 'always' and tb_text[2] == 'OK' then
				tb_text[2] = 'SA: '..tb_text[2].. ' | Behind: '..angle2..' °'
			elseif showangle == 'behind' and tb_text[2] == 'BAD' then
				tb_text[2] = 'SA: '..tb_text[2]
			elseif tb_text[2] == 'OK' and tb_text[2] == 'BAD' then
				tb_text[2] = 'SA: '..tb_text[2].. ' | Behind: '..angle2..' °'
			elseif showangle == 'never' then
				tb_text[2] = 'SA: '..tb_text[2]
			end
			set_tb(255,tostring(tb_text[2]),2)
		end
		
	elseif (target_id == 0) or (target_id == nil) or (target_id == player.id) or (target.is_npc == false) then
		for i = 1,3 do
			tb_text[i] = ''
			set_tb(0,tostring(tb_text[i]),i)
		end
	end
	
	for i = 1,3 do
		checktext[i] = tb_text[i]
	end
	
	if loop == 0 then
		windower.send_command('@wait 0.1;lua i MobCompass get_target')
	end
	
end

function set_tb(alpha,text,tb_number)	
	tb_number = tonumber(tb_number)
	windower.text.set_bg_color(box_name[tb_number], alpha,settingtab['bg_red'], settingtab['bg_green'], settingtab['bg_blue'])
	windower.text.set_color(box_name[tb_number], alpha,settingtab['txt_red'], settingtab['txt_green'], settingtab['txt_blue'])
	if checktext[tb_number] ~= text then
		windower.text.set_text(box_name[tb_number], text)
	end
end

function calc_standard_angle(Px, Py, Mx, My)

	local angle = 0
	local Px = tonumber(Px)
	local Py = tonumber(Py)
	local Mx = tonumber(Mx)
	local My = tonumber(My)
	
	local PM = (Px - Mx) / (Py - My)
	local PM_angle = math.atan(PM) * 180/math.pi

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

	local angle = tonumber(angle)
	local direction = ''
	
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
	
	local Px = tonumber(Px)
	local Py = tonumber(Py)
	local Mx = tonumber(Mx)
	local My = tonumber(My)
	
	local Mfacing = (Mfacing * 180/math.pi):round(2)
		
	local SA_Angle = calc_standard_angle(Px, Py, Mx, My) - 90
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
	local sa = ''
	if (angle2 >= 0) and (angle2 < 45) then
		sa = 'OK'	
	elseif (angle2 < 0) and (angle2 > -45) then
		sa = 'OK'
	else
		sa = 'BAD'
	end
	
	return sa
end