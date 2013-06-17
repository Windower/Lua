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
_addon.version = '0.5'
_addon.command = 'gametime'

tb_name	= 'addon:gr:gametime'
visible = false

local gt = {}
gt.days = {}
gt.days[1] = {}
gt.days[1][1] = 'Firesday'
gt.days[1][2] = 'Fi '
gt.days[1][10] = '(255, 0, 0)'
gt.days[1][3] = 'Fire '
gt.days[2] = {}
gt.days[2][1] = 'Earthsday'
gt.days[2][2] = 'Ea '
gt.days[2][10] = '(255, 225, 0)'
gt.days[2][3] = 'Earth '
gt.days[3] = {}
gt.days[3][1] = 'Watersday'
gt.days[3][2] = 'Wa '
gt.days[3][10] = '(0, 0, 255)'
gt.days[3][3] = 'Water '
gt.days[4] = {}
gt.days[4][1] = 'Windsday'
gt.days[4][2] = 'Wi '
gt.days[4][10] = '(0, 255, 0)'
gt.days[4][3] = 'Wind '
gt.days[5] = {}
gt.days[5][1] = 'Iceday'
gt.days[5][2] = 'Ic '
gt.days[5][10] = '(128, 128, 255)'
gt.days[5][3] = 'Ice '
gt.days[6] = {}
gt.days[6][1] = 'Lightningday'
gt.days[6][2] = 'Lg '
gt.days[6][10] = '(255, 128, 128)'
gt.days[6][3] = 'Lightning '
gt.days[7] = {}
gt.days[7][1] = 'Lightsday'
gt.days[7][2] = 'Lt '
gt.days[7][10] = '(255, 255, 255)'
gt.days[7][3] = 'Light '
gt.days[8] = {}
gt.days[8][1] = 'Darksday'
gt.days[8][2] = 'Dk '
gt.days[8][10] = '(128, 128, 128)'
gt.days[8][3] = 'Dark '

gt.WeekReport = ''
gt.MoonPct = ''
gt.MoonPhase = ''


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
	defaults.days.text_alpha = 100
	defaults.days.change = true
	defaults.moon = T{}
	defaults.moon.change = true
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
	event_day_change(get_ffxi_info()["day"])
	event_moon_pct_change(get_ffxi_info()["moon_pct"])
end

function event_unload()
	send_command('unalias gametime')
	send_command('unalias gt')
	tb_delete('gametime_time')
	tb_delete('gametime_day')
end

function event_login()
	event_load()
end

function event_logout()
	event_unload()
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
	-- gt.basetime = new + 1
	-- gt.basetime = gt.basetime - 1
	-- gt.time = tostring(gt.basetime):split(".")
	-- gt.hours = gt.time[1]
	-- gt.minutes = gt.time[2]
	-- gt.second = tostring(gt.minutes):slice(3,3)
	-- gt.second = gt.second:zfill(1)
	-- gt.minutes = tostring(gt.minutes):slice(1,2)
	-- if gt.seconds == nil then
		-- gt.minutes = '00'
	-- else
		-- if (gt.second+1 > 5) then
			-- gt.minutes = gt.minutes+1
		-- end
	-- end
	--log(gt.time[1]..':'..gt.time[2])
	--gt.minutes = tostring(gt.minutes):zfill(2)
	--^old method, will remove next update.
	gt.basetime = get_ffxi_info()["time"]
	gt.basetime = gt.basetime * 100
	gt.basetime = math.round(gt.basetime)
	gt.basetime = tostring(gt.basetime):zfill(4)
	gt.time = T{gt.basetime:slice(1,(#gt.basetime-2)),gt.basetime:slice((#gt.basetime-1),#gt.basetime)}
	tb_set_text(gt.gtt,gt.time[1]..':'..gt.time[2])
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
		daystring = ''..daystring..gt.delimiter..' \\cs'..gt.days[(dval+0)][10]..gt.days[(dval+0)][settings.mode]
	end
	gt.WeekReport = daystring
	tb_set_text(gt.gtd,gt.MoonPhase..' ('..gt.MoonPct..'%);'..gt.WeekReport)
	event_moon_change(get_ffxi_info()["moon"])
end

function event_moon_change(moon)
	gt.MoonPhase = moon
	tb_set_text(gt.gtd,gt.MoonPhase..' ('..gt.MoonPct..'%);'..gt.WeekReport)
	if settings.moon.change == true then
		log('Gametime: Day: '..get_ffxi_info()["day"]..'; Moon: '..gt.MoonPhase..' ('..gt.MoonPct..'%);')
	end
end

function event_moon_pct_change(pct)
	gt.MoonPct = pct
	tb_set_text(gt.gtd,gt.MoonPhase..' ('..gt.MoonPct..'%);'..gt.WeekReport)
end

function event_addon_command(...)
	local args	= T({...})
	if args[1] == nil or args[1] == "help" then
		log('Use //gametime or //gt as follows:')
		log('Positioning:')
		log('//gt [timex/timey/daysx/daysy] <pos> :: example: //gt timex 125')
		log('//gt [time/days] reset :: example: //gt days reset')
		log('Visibility:')
		log('//gt [time/days] [show/hide] :: example //gt time hide')
		log('//gt axis [horizontal/vertical] :: week display axis')
		log('//gt [time/days] alpha 1-255. :: Sets the transparency. Lowest numbers = more transparent.')
		log('//gt mode 1-3 :: Fullday; Abbreviated; Element names')
		-- log('Log Reporting -- Day and Moon Phase (Not Moon %) change') not implemented yet
		-- log('//gt [days/moon] change [true/false]')
		-- log('Positioning:')
		-- log('//gt timex <pos> //gt timey <pos> //gt daysx <pos> //gt daysy <pos>')
		-- log('//gt time reset //gt days reset :: resets reset both coordinates.')
		-- log('Visibility:')
		-- log('//gt time show //gt time hide')
		-- log('//gt days show //gt days hide')
		-- log('//gt axis horizontal //gt axis vertical :: changes the display axis of gamedays.')
		-- log('//gt mode 1-3 :: 1: Fullday names; 2: Short names; 3: Element names.')
		-- log('//gt time alpha 1-255 :: sets transarency of Gametime\'s clock')
		-- log('//gt days alpha 1-255 :: sets transparency of Gametime\'s day-display')
		log('Remember to //gt save when you\'re happy with your settings.')
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
			if (inalpha > 0 and inalpha < 256) then
				tb_set_bg_color(gt.gtt,inalpha,settings.time.bg_colorr,settings.time.bg_colorg,settings.time.bg_colorb)
				tb_set_color(gt.gtt,inalpha,settings.time.colorr,settings.time.colorg,settings.time.colorb)
				settings.time.bg_alpha = inalpha
				settings.time.alpha = inalpha
				log('Gametime: Time transparency set to '..inalpha..' ('..math.round(100-(inalpha/2.55),0)..'%).')
			end
		elseif args[2] == 'hide' then
			tb_set_visibility(gt.gtt,false)
			settings.time.visible = false
			log('Gametime: Time display hidden.')
		elseif args[2] == 'reset' then
			tb_set_location(gt.gtt,0,0)
		else
			tb_set_visibility(gt.gtt,true)
			settings.time.visible = true
			log('Gametime: Showing time display.')
		end
	elseif args[1] == 'days' then
		if args[2] == 'alpha' then
			inalpha = tostring(args[3]):zfill(3)
			inalpha = inalpha+0
			if (inalpha > 0 and inalpha < 256) then
				tb_set_bg_color(gt.gtd,inalpha,settings.days.bg_colorr,settings.days.bg_colorg,settings.days.bg_colorb)
				tb_set_color(gt.gtd,inalpha,settings.days.bg_colorr,settings.days.bg_colorg,settings.days.bg_colorb)
				settings.days.bg_alpha = inalpha
				settings.days.alpha = inalpha
				log('Gametime: Days transparency set to '..inalpha..' ('..math.round(100-(inalpha/2.55),0)..'%).')
			end
		elseif args[2] == 'hide' then
			tb_set_visibility(gt.gtd,false)
			settings.days.visible = false
			log('Gametime: Days display hidden.')
		elseif args[2] == 'reset' then
			tb_set_location(gt.gtd,100,0)
		else
			tb_set_visibility(gt.gtd,true)
			settings.days.visible = true
			log('Gametime: Showing days display.')
		end
	elseif args[1] == 'axis' then
		if args[2] == 'vertical' then
			gt.delimiter = "\n"
		else
			gt.delimiter = " "
		end
		log('Gametime: Week display axis set.')
	elseif args[1] == 'mode' then
		inmode = tostring(args[2]):zfill(1)
		inmode = inmode+0
		if inmode > 3 then
			return
		else
			settings.mode = inmode
			log('Gametime: mode updated')
		end
	elseif args[1] == 'save' then
		settings:save('all')
		log('Gametime: Settings saved.')
	end
end