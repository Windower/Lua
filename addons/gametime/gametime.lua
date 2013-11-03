-- Copyright (c) 2013, Omnys of Valefor
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of Gametime nor the
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
_addon.version = '0.52'
_addon.commands = {'gametime','gt'}

tb_name	= 'addon:gr:gametime'
visible = false

local gt = {}
gt.days = {}
gt.days[1] = {}
gt.days[1][1] = 'Firesday'
gt.days[1][2] = 'Fi '
gt.days[1][10] = '(255, 0, 0)'
gt.days[1][3] = 'Fire '
--Mini mode
gt.days[1][4] = '° '

gt.days[2] = {}
gt.days[2][1] = 'Earthsday'
gt.days[2][2] = 'Ea '
gt.days[2][10] = '(255, 225, 0)'
gt.days[2][3] = 'Earth '
--Mini mode
gt.days[2][4] = '° '

gt.days[3] = {}
gt.days[3][1] = 'Watersday'
gt.days[3][2] = 'Wa '
gt.days[3][10] = '(100, 100, 255)'
gt.days[3][3] = 'Water '
--Mini mode
gt.days[3][4] = '° '

gt.days[4] = {}
gt.days[4][1] = 'Windsday'
gt.days[4][2] = 'Wi '
gt.days[4][10] = '(0, 255, 0)'
gt.days[4][3] = 'Wind '
--Mini mode
gt.days[4][4] = '° '

gt.days[5] = {}
gt.days[5][1] = 'Iceday'
gt.days[5][2] = 'Ic '
gt.days[5][10] = '(150, 200, 255)'
gt.days[5][3] = 'Ice '
--Mini mode
gt.days[5][4] = '° '

gt.days[6] = {}
gt.days[6][1] = 'Lightningday'
gt.days[6][2] = 'Lg '
gt.days[6][10] = '(255, 128, 128)'
gt.days[6][3] = 'Lightning '
--Mini mode
gt.days[6][4] = '° '

gt.days[7] = {}
gt.days[7][1] = 'Lightsday'
gt.days[7][2] = 'Lt '
gt.days[7][10] = '(255, 255, 255)'
gt.days[7][3] = 'Light '
--Mini mode
gt.days[7][4] = '° '

gt.days[8] = {}
gt.days[8][1] = 'Darksday'
gt.days[8][2] = 'Dk '
gt.days[8][10] = '(128, 128, 128)'
gt.days[8][3] = 'Dark '
--Mini mode
gt.days[8][4] = '° '

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
	defaults.time.font_size = 12
	defaults.time.font = 'tahoma'
	defaults.time.bg_alpha = 25
	defaults.time.bg_colorr = 100
	defaults.time.bg_colorg = 100
	defaults.time.bg_colorb = 100
	
	defaults.days = T{}
	defaults.days.visible = true
	defaults.days.x = 100
	defaults.days.y = 0
	defaults.days.alpha = 75
	defaults.days.font_size = 12
	defaults.days.font = 'tahoma'
	
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

	

	Cycles = T{}
	Cycles.selbina = T{}
	Cycles.selbina.rname = "Ships between Mhaura and Selbina"
	Cycles.selbina.route = T{}
	Cycles.selbina.route[1] = "Arrives in Mhaura and Selbina|22:40"
	Cycles.selbina.route[2] = "Arrives in Mhaura and Selbina|6:40"
	Cycles.selbina.route[3] = "Arrives in Mhaura and Selbina|14:40"

	Cycles.bibiki = T{}
	Cycles.bibiki.rname = "Ship departing Bibiki Bay for Purgonorgo Isle"
	Cycles.bibiki.route = T{}
	Cycles.bibiki.route[1] = "Arrives in Bibiki|4:50"
	Cycles.bibiki.route[2] = "Arrives in Bibiki|16:50"

	Cycles.nashmau = T{}
	Cycles.nashmau.rname = "Aht Urhgan / Nashmau Ship"
	Cycles.nashmau.route = T{}
	Cycles.nashmau.route[1] = "Arrives in Whitegate and Nashmau|05:00"
	Cycles.nashmau.route[2] = "Arrives in Whitegate and Nashmau|13:00"
	Cycles.nashmau.route[3] = "Arrives in Whitegate and Nashmau|21:00"
	
	Cycles.whitegate = T{}
	Cycles.whitegate.rname = "Aht Urhgan / whitegate Ship"
	Cycles.whitegate.route = T{}
	Cycles.whitegate.route[1] = "Arrives in Whitegate and Mhaura|10:40"
	Cycles.whitegate.route[2] = "Arrives in Whitegate and Mhaura|18:40"
	Cycles.whitegate.route[3] = "Arrives in Whitegate and Mhaura|2:40"

	Cycles.windurst = T{}
	Cycles.windurst.rname = "Ship between Windurst and Jeuno"
	Cycles.windurst.route = {T}
	Cycles.windurst.route[1] = "Arrives in Windurst|4:47"
	Cycles.windurst.route[2] = "Arrives in Jeuno|7:41"
	Cycles.windurst.route[3] = "Arrives in Windurst|10:47"
	Cycles.windurst.route[4] = "Arrives in Jeuno|13:41"
	Cycles.windurst.route[5] = "Arrives in Windurst|16:47"
	Cycles.windurst.route[6] = "Arrives in Jeuno|19:41"
	Cycles.windurst.route[7] = "Arrives in Windurst|22:47"
	Cycles.windurst.route[8] = "Arrives in Jeuno|1:41"

	Cycles.bastok = T{}
	Cycles.bastok.rname = "Ship between Bastok and Jeuno"
	Cycles.bastok.route = {T}
	Cycles.bastok.route[1] = "Arrives in Bastok|0:13"
	Cycles.bastok.route[2] = "Arrives in Jeuno|3:11"
	Cycles.bastok.route[3] = "Arrives in Bastok|6:13"
	Cycles.bastok.route[4] = "Arrives in Jeuno|9:11"
	Cycles.bastok.route[5] = "Arrives in Bastok|12:13"
	Cycles.bastok.route[6] = "Arrives in Jeuno|15:11"
	Cycles.bastok.route[7] = "Arrives in Bastok|18:13"
	Cycles.bastok.route[8] = "Arrives in Jeuno|21:41"

	Cycles.sandy = T{}
	Cycles.sandy.rname = "Ship between San d'Oria and Jeuno"
	Cycles.sandy.route = {T}
	Cycles.sandy.route[1] = "Arrives in San d'Oria|7:10"
	Cycles.sandy.route[2] = "Arrives in Jeuno|6:11"
	Cycles.sandy.route[3] = "Arrives in San d'Oria|9:10"
	Cycles.sandy.route[4] = "Arrives in Jeuno|12:11"
	Cycles.sandy.route[5] = "Arrives in San d'Oria|15:10"
	Cycles.sandy.route[6] = "Arrives in Jeuno|18:11"
	Cycles.sandy.route[7] = "Arrives in San d'Oria|21:10"
	Cycles.sandy.route[8] = "Arrives in Jeuno|00:41"
	
	Cycles.kazham = T{}
	Cycles.kazham.rname = "Ship between Kazham and Jeuno"
	Cycles.kazham.route = {T}
	Cycles.kazham.route[1] = "Arrives in Kazham|1:48"
	Cycles.kazham.route[2] = "Arrives in Jeuno|4:49"
	Cycles.kazham.route[3] = "Arrives in Kazham|7:48"
	Cycles.kazham.route[4] = "Arrives in Jeuno|10:49"
	Cycles.kazham.route[5] = "Arrives in Kazham|13:48"
	Cycles.kazham.route[6] = "Arrives in Jeuno|14:49"
	Cycles.kazham.route[7] = "Arrives in Kazham|19:48"
	Cycles.kazham.route[8] = "Arrives in Jeuno|20:49"
	
windower.register_event('load',function ()
	cb_time()
	cb_day()
	settings = config.load(defaults)

	if settings.days.axis == 'horizontal' then
		gt.delimiter = ' '
	else
		gt.delimiter = '\n'
	end
	
	gt.mode = settings.mode
	event_time_change(get_ffxi_info()["time"])
	event_day_change(get_ffxi_info()["day"])
	event_moon_pct_change(get_ffxi_info()["moon_pct"])
end)

windower.register_event('unload',function ()
	tb_delete('gametime_time')
	tb_delete('gametime_day')
end)

function getroutes(route)
	for ckey, cval in pairs(Cycles) do
		if route == nil or ckey == route then
			log('\30\02'..Cycles[ckey].rname..' (shortcode: //gt route '..ckey..')')
			for ri = 1, #Cycles[ckey].route do
				ro = Cycles[ckey].route[ri]:split('|')
				rtime = timeconvert(ro[2])
				rdelay = math.round(rtime-gt.dectime,2)
				if rdelay < 0 then rdelay = rdelay + 24 end
				rdelay = 2.4 * rdelay
				log(ro[1]..' @ '..ro[2]..'  \30\02Arrival in '..(timeconvert2(rdelay))..'')
			end
		end
	end
end

windower.register_event('login',function ()
	event_load()
end)

windower.register_event('logout',function ()
	event_unload()
end)

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
	--Set font type and size for time
	tb_set_font(gt.gtt,settings.time.font,settings.time.font_size)
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
	--Set font type and size for days 
	tb_set_font(gt.gtd,settings.days.font,settings.days.font_size)
	
	
	
end

function default_settings()
	settings:save('all')
end

windower.register_event('time change',function (old, new)
	gt.basetime = get_ffxi_info()["time"]
	gt.basetime = gt.basetime * 100
	gt.basetime = math.round(gt.basetime)
	gt.basetime = tostring(gt.basetime):zfill(4)
	gt.hour = gt.basetime:slice(1,(#gt.basetime-2))
	gt.minute = gt.basetime:slice((#gt.basetime-1),#gt.basetime)
	-- gt.time = T{gt.basetime:slice(1,(#gt.basetime-2)),gt.basetime:slice((#gt.basetime-1),#gt.basetime)}
	gt.time = T{gt.hour,gt.minute}
	gt.dectime = timeconvert(gt.time[1]..':'..gt.time[2])
	tb_set_text(gt.gtt,gt.time[1]..':'..gt.time[2])
end)

function timeconvert(basetime)
	basetable = basetime:split(':')
	return basetable[1]..'.'..math.round(basetable[2] * (100/60))
end

function timeconvert2(basetime)
	basetable = tostring(basetime):split('.')
	return basetable[1]..':'..tostring(math.round(tostring(basetable[2]):slice(1,2) / (100/60))):zfill(2)
end

windower.register_event('day change',function (day)
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
	
	gt.day = day
	
	gt.WeekReport = daystring
	tb_set_color(gt.gtd,settings.days.alpha,255,255,255)
	tb_set_text(gt.gtd,' \\cs'..gt.days[1][10]..gt.MoonPhase..' ('..gt.MoonPct..'%);'..gt.WeekReport)
	event_moon_change(get_ffxi_info()["moon"])
end)

windower.register_event('moon change',function (moon)
	gt.MoonPhase = moon
	tb_set_text(gt.gtd,gt.MoonPhase..' ('..gt.MoonPct..'%);'..gt.WeekReport)
	if settings.moon.change == true then
		log('Day: '..gt.day..'; Moon: '..gt.MoonPhase..' ('..gt.MoonPct..'%);')
	end
end)

windower.register_event('moon pct change',function (pct)
	gt.MoonPct = pct
	tb_set_text(gt.gtd,gt.MoonPhase..' ('..gt.MoonPct..'%);'..gt.WeekReport)
end)

windower.register_event('addon command',function (...)
	local args	= T({...})
	if args[1] == nil or args[1] == "help" then
		log('Use //gametime or //gt as follows:')
		log('Positioning:')
		log('//gt [timex/timey/daysx/daysy] <pos> :: example: //gt timex 125')
		log('//gt [time/days] reset :: example: //gt days reset')
		
		log('Text features:')
		log('//gt timeSize <size> :: example: //gt timeSize 10')
		log('//gt timeFont <fontName> :: example: //gt timeFont Verdana')
		log('//gt daySize <size> :: example: //gt daySize 10')
		log('//gt dayFont <fontName> :: example: //gt dayFont Verdana')
		
		log('Visibility:')
		log('//gt [time/days] [show/hide] :: example //gt time hide')
		log('//gt axis [horizontal/vertical] :: week display axis')
		log('//gt [time/days] alpha 1-255. :: Sets the transparency. Lowest numbers = more transparent.')
		log('//gt mode 1-4 :: Fullday; Abbreviated; Element names; Compact')
		log('//gt route :: Displays route names.')
		log('//gt route [route name] :: Displays arrival time for route.')
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
	elseif args[1] == 'routes' or args[1] == 'route' then
		if args[2] == nil then
			local ckeys = ''
			for ckey, cval in pairs(Cycles) do
				ckeys = ckeys..', '..ckey
			end
			ckeys = ckeys:slice(3,#ckeys)
			log('Use //gt route [shortcode] ('..ckeys..')')
		else
			getroutes(args[2])
		end
	
	
	
	---CLI Arguments for Time font Size
	elseif args[1] == 'timeSize' then
			tb_set_font(gt.gtt,settings.time.font,args[2])
			settings.time.font_size = args[2]
			
			
			
	---CLI Arguments for Time font type
	elseif args[1] == 'timeFont' then
			tb_set_font(gt.gtt,args[2],settings.time.font_size)
			settings.time.font = args[2]

			
			
	---CLI Arguments for Day font Size
	elseif args[1] == 'daySize' then
			tb_set_font(gt.gtd,settings.time.font,args[2])
			settings.days.font_size = args[2]
			
			
			
	---CLI Arguments for Day font type
	elseif args[1] == 'dayFont' then
			tb_set_font(gt.gtd,args[2],settings.time.font_size)
			settings.days.font = args[2]				
	
	
	
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
				log('Time transparency set to '..inalpha..' ('..math.round(100-(inalpha/2.55),0)..'%).')
			end
		elseif args[2] == 'x' or args[2] == 'posx' then
			send_command('gt timex '..args[3])
		elseif args[2] == 'y' or args[2] == 'posy' then
			send_command('gt timey '..args[3])
		elseif args[2] == 'hide' then
			tb_set_visibility(gt.gtt,false)
			settings.time.visible = false
			log('Time display hidden.')
		elseif args[2] == 'reset' then
			tb_set_location(gt.gtt,0,0)
		else
			tb_set_visibility(gt.gtt,true)
			settings.time.visible = true
			log('Showing time display.')
		end
	elseif args[1] == 'days' then
		if args[2] == 'alpha' then
			inalpha = tostring(args[3]):zfill(3)
			inalpha = inalpha+0
			if (inalpha > 0 and inalpha < 256) then
				tb_set_bg_color(gt.gtd,inalpha,settings.days.bg_colorr,settings.days.bg_colorg,settings.days.bg_colorb)
				tb_set_color(gt.gtd,inalpha,255,255,255)
				settings.days.bg_alpha = inalpha
				settings.days.alpha = inalpha
				log('Days transparency set to '..inalpha..' ('..math.round(100-(inalpha/2.55),0)..'%).')
			end
		elseif args[2] == 'x' or args[2] == 'posx' then
			send_command('gt daysx '..args[3])
		elseif args[2] == 'y' or args[2] == 'posy' then
			send_command('gt timey '..args[3])
		elseif args[2] == 'hide' then
			tb_set_visibility(gt.gtd,false)
			settings.days.visible = false
			log('Days display hidden.')
		elseif args[2] == 'reset' then
			tb_set_location(gt.gtd,100,0)
		else
			tb_set_visibility(gt.gtd,true)
			settings.days.visible = true
			log('Showing days display.')
		end
	elseif args[1] == 'axis' then
		if args[2] == 'vertical' then
			gt.delimiter = "\n"
		log('Week display axis set to vertical.')
		else
			gt.delimiter = " "
		log('Week display axis set to horizontal.')
		end
		event_day_change(get_ffxi_info()["day"])
	elseif args[1] == 'mode' then
		inmode = tostring(args[2]):zfill(1)
		inmode = inmode+0
		if inmode > 4 then
			return
		else
			settings.mode = inmode
			log('mode updated')
		end
		event_day_change(get_ffxi_info()["day"])
	elseif args[1] == 'save' then
		settings:save('all')
		log('Settings saved.')
	end
end)
