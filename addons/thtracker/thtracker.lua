--Copyright (c) 2013, Krizz
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of thtracker nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL KRIZZ BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon = _addon or {}
_addon.name = 'th tracker'
_addon.version = 1.0


local config = require 'config'

thoutput = ''
posx = 1000
posy = 200
see = true

local settingtab = nil
local settings_file = 'data\\settings.xml'
local settingtab = config.load(settings_file)
if settingtab == nil then
	write('No settings file found. Ensure you have a file at data\\settings.xml')
end

	if settingtab['posx'] ~= nil then
		posx = settingtab['posx']
		posy = settingtab['posy']
	end	

function event_load()
	send_command('alias th lua c thtracker')
	thbox()
	tb_set_visibility('th_box',false)
end

function event_addon_command(...)
	local params = {...};
	if #params < 1 then
		return
	end
	if params[1] then
		if params[1]:lower() == "help" then
			write('th help : Shows help message')
			write('th pos <x> <y> : Positions the list')
			write('th hide : Hides the box')
			write('th show : Shows the box')
		elseif params[1]:lower() == "pos" then
			if params[3] then
				local posx, posy = tonumber(params[2]), tonumber(params[3])
				tb_set_location('th_box', posx, posy)
			end
		elseif params[1]:lower() == "hide" then
			see = false
			tb_set_visibility('th_box', see)
		elseif params[1]:lower() == "show" then
			see = true
			tb_set_visibility('th_box', see)
		end
	end
end

function event_incoming_text(original, new, color)
	name = nil
	count = 0
	a,b,name,count = string.find(original,'Additional effect: Treasure Hunter effectiveness against the (.*)%s? increases to (%d+)\46')
	if name ~= nil and count ~= 0 then
		thoutput = ' '
		thoutput = (name..'\n TH: '..count)
		thbox()
		tb_set_text('th_box', thoutput);
		tb_set_visibility('th_box',see)
	end
end

function thbox()
	tb_create('th_box')
	tb_set_bg_color('th_box',200,30,30,30)
	tb_set_color('th_box',255,200,200,200)
	tb_set_location('th_box',posx,posy)
	tb_set_visibility('th_box', see)
	tb_set_bg_visibility('th_box',1)
	tb_set_font('th_box','Arial',12)
end

function event_unload()
	tb_delete('th_box')

	send_command('unalias th')
end 