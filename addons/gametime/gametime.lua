-- Copyright (c) 2013, Omnys of Valefor
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of <addon name> nor the
      -- names of its contributors may be used to endorse or promote products
      -- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'chat'
require 'logger'
require 'stringhelper'
require 'mathhelper'
require 'tablehelper'

local ffxi = require 'ffxi'

local config = require 'config'

_addon = {}
_addon.name = 'gametime'
_addon.version = '0.31'
_addon.command = 'gametime'

tb_name	= 'addon:gr:gametime'
visible = false

local gt = {}
gt.days = {}
gt.days[1] = {}
gt.days[1][1] = 'Firesday'
gt.days[1][2] = 'Fi '
gt.days[1][3] = '(255, 0, 0)'
gt.days[2] = {}
gt.days[2][1] = 'Earthsday'
gt.days[2][2] = 'Ea '
gt.days[2][3] = '(255, 225, 0)'
gt.days[3] = {}
gt.days[3][1] = 'Watersday'
gt.days[3][2] = 'Wa '
gt.days[3][3] = '(0, 0, 255)'
gt.days[4] = {}
gt.days[4][1] = 'Windsday'
gt.days[4][2] = 'Wi '
gt.days[4][3] = '(0, 255, 0)'
gt.days[5] = {}
gt.days[5][1] = 'Iceday'
gt.days[5][2] = 'Ic '
gt.days[5][3] = '(128, 128, 255)'
gt.days[6] = {}
gt.days[6][1] = 'Lightningday'
gt.days[6][2] = 'Lg '
gt.days[6][3] = '(255, 128, 128)'
gt.days[7] = {}
gt.days[7][1] = 'Lightsday'
gt.days[7][2] = 'Lt '
gt.days[7][3] = '(255, 255, 255)'
gt.days[8] = {}
gt.days[8][1] = 'Darksday'
gt.days[8][2] = 'Dk '
gt.days[8][3] = '(128, 128, 128)'


local defaults = T{}
	defaults.saved = 0
	defaults.mode = 1
	defaults.time = T{}
	defaults.time.visible = true
	defaults.time.x = 0 -- left
	defaults.time.y = 0 -- top
	defaults.time.alpha = 100
	defaults.time.colorr = 255
	defaults.time.colorg = 255
	defaults.time.colorb = 255
	defaults.time.bg_alpha = 25
	defaults.time.bg_colorr = 100
	defaults.time.bg_colorg = 100
	defaults.time.bg_colorb = 100
	defaults.days = T{}
	defaults.days.visible = true
	defaults.days.x = 100
	defaults.days.y = 0
	defaults.days.alpha = 75
	defaults.days.bg_alpha = 100
	defaults.days.bg_colorr = 0
	defaults.days.bg_colorg = 0
	defaults.days.bg_colorb = 0
	defaults.days.axis = 'horizontal'
	defaults.days.text_alpha = '100'
	settings = config.load(defaults)
	
function event_load()
	send_command('alias gametime lua command gametime')
	send_command('alias gt gametime')
	cb_time()
	cb_day()
	settings = config.load(defaults)

	if settings.days.axis == 'horizontal' then
		gt.delimiter = ' '
	else
		gt.delimiter = '\n'
	end
	
	gt.mode = settings.mode
end

function event_unload()
	send_command('unalias gametime')
	send_command('unalias gt')
	tb_delete('gametime_time')
	tb_delete('gametime_day')
end

function cb_time()
	gt.gtt = 'gametime_time'
	tb_create(gt.gtt)
	tb_set_bg_border_size(gt.gtt,2)
	tb_set_bg_color(gt.gtt,settings.time.bg_alpha,settings.time.bg_colorr,settings.time.bg_colorg,settings.time.bg_colorb)
	tb_set_bg_visibility(gt.gtt,settings.time.visible)
	tb_set_bold(gt.gtt,true)
	tb_set_color(gt.gtt,settings.time.alpha,settings.time.colorr,settings.time.colorg,settings.time.colorb)
	tb_set_location(gt.gtt,settings.time.x,settings.time.y)
	tb_set_text(gt.gtt,'Loading. . .')
	tb_set_visibility(gt.gtt,settings.time.visible)
end

function cb_day()
	gt.gtd = 'gametime_day'
	tb_create(gt.gtd)
	tb_set_bg_border_size(gt.gtd,2)
	tb_set_bg_color(gt.gtd,settings.days.bg_alpha,settings.days.bg_colorr,settings.days.bg_colorg,settings.days.bg_colorb)
	tb_set_bg_visibility(gt.gtd,settings.days.visible)
	tb_set_bold(gt.gtd,true)
	tb_set_color(gt.gtd,settings.days.alpha,255,255,255)
	tb_set_location(gt.gtd,settings.days.x,settings.days.y)
	tb_set_text(gt.gtd,'')
	tb_set_visibility(gt.gtd,settings.days.visible)
end

function default_settings()
	settings:save('all')
end

function event_time_change(old, new)
	gt.basetime = new + 1
	gt.basetime = gt.basetime - 1
	gt.time = tostring(gt.basetime):split(".")
	gt.hours = gt.time[1]
	gt.minutes = gt.time[2]
	gt.second = tostring(gt.minutes):slice(3,3)
	gt.second = gt.second:zfill(1)
	gt.minutes = tostring(gt.minutes):slice(1,2)
	if gt.seconds == nil then
		gt.minutes = '00'
	else
		if (gt.second+1 > 5) then
			gt.minutes = gt.minutes+1
		end
	end
	gt.minutes = tostring(gt.minutes):zfill(2)
	tb_set_text(gt.gtt,gt.hours..':'..gt.minutes)
	event_day_change(get_ffxi_info()["day"])
end

function event_day_change(day)
--	tb_set_text(gt.gtd,day)
	if (day == 'Firesday') then
		dlist = {'1','2','3','4','5','6','7','8'}
	elseif (day == 'Earthsday') then
		dlist = {'2','3','4','5','6','7','8','1'}
	elseif (day == 'Watersday') then
		dlist = {'3','4','5','6','7','8','1','2'}
	elseif (day == 'Windsday') then
		dlist = {'4','5','6','7','8','1','2','3'}
	elseif (day == 'Iceday') then
		dlist = {'5','6','7','8','1','2','3','4'}
	elseif (day == 'Lightningday') then
		dlist = {'6','7','8','1','2','3','4','5'}
	elseif (day == 'Lightsday') then
		dlist = {'7','8','1','2','3','4','5','6'}
	elseif (day == 'Darksday') then
		dlist = {'8','1','2','3','4','5','6','7'}
	end
	
	dpos = 0
	daystring = ''
	while dpos < 8 do
		dpos = dpos + 1
		dval = dlist[dpos]
		daystring = ''..daystring..gt.delimiter..' \\cs'..gt.days[(dval+0)][3]..gt.days[(dval+0)][settings.mode]
	end
	tb_set_text(gt.gtd,daystring)
end

function event_addon_command(...)
	local args	= T({...})
	if args[1] == nil or args[1] == "help" then
		log('Positioning:')
		log('//gametime timex <pos> //gametime timey <pos> //gametime daysx <pos> //gametime daysy <pos>')
		log('Visibility:')
		log('//gametime time show //gametime time hide')
		log('//gametime days show //gametime days hide')
		log('//gaimetime axis horizontal //gametime axis vertical')
		log('//gametime mode 1 or 2 :: Mode 1 uses full day names. Mode 2 uses 2 letter abbreviations.')
		log('//gametime save :: saves your settings')
		log('//gametime time alpha 1-255 :: sets transarency of Gametime\'s clock')
		log('//gametime days alpha 1-255 :: sets transparency of Gametime\'s day-display')
		elseif args[1] == 'timex' then
		tb_set_location(gt.gtt,args[2],settings.time.y)
		settings.time.x = args[2]
	elseif args[1] == 'timey' then
		tb_set_location(gt.gtt,settings.time.x,args[2])
		settings.time.y = args[2]
	elseif args[1] == 'daysx' then
		tb_set_location(gt.gtd,args[2],settings.days.y)
		settings.days.x = args[2]
	elseif args[1] == 'daysy' then
		tb_set_location(gt.gtd,settings.days.x,args[2])
		settings.days.y = args[2]
	elseif args[1] == 'time' then
		if args[2] == 'alpha' then
			inalpha = tostring(args[3]):zfill(3)
			inalpha = inalpha+0
			if (inalpha > 5 and inalpha < 257) then
				tb_set_bg_color(gt.gtt,inalpha,settings.time.bg_colorr,settings.time.bg_colorg,settings.time.bg_colorb)
				tb_set_color(gt.gtt,inalpha,settings.time.colorr,settings.time.colorg,settings.time.colorb)
				settings.time.bg_alpha = inalpha
				settings.time.alpha = inalpha
				log('Gametime: Time transparency set to '..math.round(100-(inalpha/2.55),0)..'%')
			end
		elseif args[2] == 'hide' then
			tb_set_visibility(gt.gtt,false)
			settings.time.visible = false
		else
			tb_set_visibility(gt.gtt,true)
			settings.time.visible = true
		end
	elseif args[1] == 'days' then
		if args[2] == 'alpha' then
			inalpha = tostring(args[3]):zfill(3)
			inalpha = inalpha+0
			if (inalpha > 5 and inalpha < 257) then
				tb_set_bg_color(gt.gtd,inalpha,settings.days.bg_colorr,settings.days.bg_colorg,settings.days.bg_colorb)
				tb_set_color(gt.gtd,inalpha,settings.days.bg_colorr,settings.days.bg_colorg,settings.days.bg_colorb)
				settings.days.bg_alpha = inalpha
				settings.days.alpha = inalpha
				log('Gametime: Days transparency set to '..math.round(100-(inalpha/2.55),0)..'%')
			end
		elseif args[2] == 'hide' then
			tb_set_visibility(gt.gtd,false)
			settings.days.visible = false
		else
			tb_set_visibility(gt.gtd,true)
			settings.days.visible = true
		end
	elseif args[1] == 'axis' then
		if args[2] == 'vertical' then
			gt.delimiter = "\n"
		else
			gt.delimiter = " "
		end
	elseif args[1] == 'mode' then
		inmode = tostring(args[2]):zfill(1)
		inmode = inmode + 1
		if inmode > 2 then
			settings.mode = 2
		else
			settings.mode = 1
		end
	elseif args[1] == 'save' then
		settings:save('all')
		log('Gametime: Settings saved.')
	end
end