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
_addon.name = 'TH Tracker'
_addon.author = 'Krizz'
_addon.version = '1.1a'


local config = require('config')
texts = require('texts')
require('logger')

local thoutput = 'No current mob'
local posx = 200
local posy = 200
local see = true
local name = nil
local box_name = 'addon:gr:thbox'
mob = nil
count = 0

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
	
function initialize()
	--[[windower.text.create(box_name)
	windower.text.set_bg_color(box_name,200,30,30,30)
	windower.text.set_color(box_name,255,200,200,200)
	windower.text.set_location(box_name,posx,posy)
	windower.text.set_visibility(box_name, see)
	windower.text.set_bg_visibility(box_name,1)
	windower.text.set_font(box_name,'Arial',12)
	windower.text.set_text(box_name, thoutput)]]
	--log('Initializing TH Tracker')
	t = texts.new('test text box')
	thbox = texts.new('${boxtext}', {
		pos = {
			x = posx,
			y = posy
		},
		bg = {
			visible = true,
			alpha = 255,
			red = 30,
			green = 30,
			blue = 30
		},
		text = {
			size = 10,
			alpha = 200,
			red = 200,
			green = 200,
			blue = 200
		}
	})
	thbox.boxtext = thoutput
	thbox:show()
end

function dispose()
    windower.text.delete(box_name)
end

function thunload()
	dispose()
	windower.send_command('unalias th')
end 

windower.register_event('load', function(...)
	windower.send_command('alias th lua c thtracker')
	
	initialize()
end)

windower.register_event('login', initialize)
windower.register_event('logout', dispose)
windower.register_event('unload', thunload)


windower.register_event('addon command', function(...)
	local params = {...};
	if #params < 1 then
		return
	end
	if params[1] then
		if params[1]:lower() == "help" then
			print('th help : Shows help message')
			print('th pos <x> <y> : Positions the list')
			print('th hide : Hides the box')
			print('th show : Shows the box')
		elseif params[1]:lower() == "pos" then
			if params[3] then
				thbox.posx(tonumber(params[2]))
				thbox.posy(tonumber(params[3]))
				thbox:update()
				--windower.text.set_location(box_name, posx, posy)
			else
				print('THTracker is currently at '..posx..', '..posy)
			end
		elseif params[1]:lower() == "hide" then
			see = false
			thbox:hide()
		elseif params[1]:lower() == "show" then
			see = true
			thbox:show()
		elseif params[1]:lower() == "current" then
			print('Box text should be: '..thoutput)
		elseif params[1]:lower() == "delete" then
			--windower.text.delete(box_name)
		elseif params[1]:lower() == "create" then
			--windower.text.create(box_name)
			initialize()
		end
	end	
end)

windower.register_event('incoming text', function(original, modified, mode)
	if(see == true) then
		original = original:strip_format()
		count = 0
		if string.find(original, "Treasure Hunter") and not string.find(original, "TH Tracker:") then
			a,b,name,count = string.find(original,'Additional effect: Treasure Hunter effectiveness against the (.*)%s? increases to (%d+).')
			if name == nil then
				--log('No name')
				a,b,name,count = string.find(original,'Additional effect: Treasure Hunter effectiveness against (.*)%s? increases to (%d+).')
			end
		end
		
		if string.find(original, "defeats") and not string.find(original, "TH Tracker:") then
			a,b,deadmob = string.find(original,'%w+ defeats the (.*)\46')
			if deadmob == nill then
				a,b,deadmob = string.find(original,'%w+ defeats (.*).?')
			end
		end

		if name ~= nil and count ~= 0 then
			mob = name
			thbox.boxtext = (' '..name..'\n TH: '..count)
			--thbox:show()
			deadmob = nill
		end
		
		if deadmob ~= nil then
			thbox.boxtext = 'No current mob'
			--thbox:hide()
			mob = nil
			deadmob = nil
		end
	end
end)


