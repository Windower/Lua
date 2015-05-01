--[[	BSD License Disclaimer
		Copyright © 2015, Morath86
		All rights reserved.

		Redistribution and use in source and binary forms, with or without
		modification, are permitted provided that the following conditions are met:

			* Redistributions of source code must retain the above copyright
			  notice, this list of conditions and the following disclaimer.
			* Redistributions in binary form must reproduce the above copyright
			  notice, this list of conditions and the following disclaimer in the
			  documentation and/or other materials provided with the distribution.
			* Neither the name of BarFiller nor the
			  names of its contributors may be used to endorse or promote products
			  derived from this software without specific prior written permission.

		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
		ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
		WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
		DISCLAIMED. IN NO EVENT SHALL Morath86 BE LIABLE FOR ANY
		DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
		(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
		LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
		ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
		(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
		SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'BarFiller'
_addon.author = 'Morath'
_addon.version = '0.1.5'
_addon.commands = {'bf','barfiller'}
_addon.language = 'english'

--Windower Libs
config = require('config')
require('functions')
require('maths')
require('pack')

--BarFiller Libs
require('statics')

settings = config.load('data\\settings.xml',default_settings)
config.register(settings,initialize,bgImage,bgPosX,bgPosY,bgBarHeight,bgBarWidth,fgImage,fgPosX,fgPosY,fgBarHeight,fgBarWidth)

-- Background Bar
bgImage = settings.bar_settings.background.image
bgPosX = settings.bar_settings.background.pos.x
bgPosY = settings.bar_settings.background.pos.y
bgBarHeight = settings.bar_settings.background.size.height
bgBarWidth = settings.bar_settings.background.size.width

-- Foreground Bar
fgImage = settings.bar_settings.foreground.image
fgPosX = settings.bar_settings.foreground.pos.x
fgPosY = settings.bar_settings.foreground.pos.y
fgBarHeight = settings.bar_settings.foreground.size.height
fgBarWidth = settings.bar_settings.foreground.size.width

-- Background Bar Style
windower.prim.create('backgroundBar')
windower.prim.set_position('backgroundBar', getBackgroundPosX(), getBackgroundPosY())
windower.prim.set_size('backgroundBar', getBackgroundWidth(), getBackgroundHeight())
windower.prim.set_texture('backgroundBar', bgImage)
windower.prim.set_fit_to_texture('backgroundBar', false)
windower.prim.set_repeat('backgroundBar', 1, 1)
windower.prim.set_visibility('backgroundBar', true)

-- Foreground Bar Style
windower.prim.create('foregroundBar')
windower.prim.set_position('foregroundBar', getForegroundPosX(), getForegroundPosY())
windower.prim.set_size('foregroundBar', getForegroundWidth(), getForegroundHeight())
windower.prim.set_texture('foregroundBar', fgImage)
windower.prim.set_fit_to_texture('foregroundBar', false)
windower.prim.set_repeat('foregroundBar', 1, 1)
windower.prim.set_visibility('foregroundBar', true)

-- windower.register_event('login',function(name)
--     windower.send_command('lua i barfiller clear;')
-- end)

-- Addon commands
-- Thanks to Byrth & SnickySnacks' BattleMod addon
windower.register_event('addon command',function(...)
	local commands = {...}
	local first_cmd = table.remove(commands,1):lower()
	if approved_commands[first_cmd] and #commands >= approved_commands[first_cmd].n then
		if first_cmd == 'clear' or first_cmd == 'c' then		-- Reset EXP bar to 0
			initialize()
			print('BarFiller successfully reset the experience counter.')
		elseif first_cmd == 'reload' or first_cmd == 'r' then	-- Reloads BarFiller
			windower.send_command('lua r barfiller;')
		elseif first_cmd == 'unload' or first_cmd == 'u' then	-- Unloads BarFiller
			windower.send_command('lua u barfiller;')
		elseif first_cmd == 'help' or first_cmd == 'h' then		-- Display helpful information
			help()
		end
	else
		print('Missing or invalid command, use "bf help" or "bf h" for list of available commands.')
	end
end)

-- Capture XP Values
-- Thanks to Byrth's PointWatch addon
windower.register_event('incoming chunk',function(id,org,modi,is_injected,is_blocked)
	if is_injected then return end
	if id == 0x2D then
        local val = org:unpack('I',0x11)
        local msg = org:unpack('H',0x19)%1024
        exp_msg(val,msg)
	elseif id == 0x61 then
        xp.current = org:unpack('H',0x11)
        xp.total = org:unpack('H',0x13)
        xp.tnl = xp.total - xp.current
		calcExpBarPerc()
	end
end)