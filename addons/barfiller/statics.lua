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

-- Default settings file
default_settings = {
	bar_settings = {
		background = { -- image: Must be the EXACT path to your Windower\Addon folder
			image = 'C:\\Program Files (x86)\\Windower4\\addons\\barfiller\\data\\bar_bg.png',
			pos = {
				x = 164,
				y = 6
			},
			size = {
				height = 5,
				width = 472
			}
		},
		foreground = { -- image: Must be the EXACT path to your Windower\Addon folder
			image = 'C:\\Program Files (x86)\\Windower4\\addons\\barfiller\\data\\bar_fg.png',
			pos = {
				x = 166,
				y = 6
			},
			size = {
				height = 5,
				width = 1
			}
		}
	}
}

-- Current Game Resolution
windowerResX = windower.get_windower_settings().x_res
windowerResY = windower.get_windower_settings().y_res

-- Approved console commands
-- Thanks to Byrth & SnickySnacks' BattleMod addon
approved_commands = S{
	'clear','c',
	'reload','r',
	'unload','u',
	'help','h'
}

approved_commands = {
	clear={n=0},c={n=0},
	reload={n=0},r={n=0},
	unload={n=0},u={n=0},
	help={n=0},h={n=0}
}

-- Reset XP Info
-- Thanks to Byrth's PointWatch addon
function initialize()
    xp = {
        registry = {},
        total = 0,
        rate = 0,
        current = 0,
        tnl = 0,
    }
    positionBars()
end

-- Getters
function getBackgroundPosX()
	return bgPosX
end

function getBackgroundPosY()
	return bgPosY
end

function getForegroundPosX()
	return fgPosX
end

function getForegroundPosY()
	return fgPosY
end

function getBackgroundHeight()
	return bgBarHeight
end

function getBackgroundWidth()
	return bgBarWidth
end

function getForegroundHeight()
	return fgBarHeight
end

function getForegroundWidth()
	return fgBarWidth
end

-- Setters
function setBackgroundPosX(new_pos_x)
	bgPosX = new_pos_x
	windower.prim.set_position('backgroundBar', new_pos_x, getBackgroundPosY())
end

function setBackgroundPosY(new_pos_y)
	bgPosY = new_pos_y
	windower.prim.set_position('backgroundBar', getBackgroundPosX(), new_pos_y)
end

function setForegroundPosX(new_pos_x)
	fgPosX = new_pos_x
	windower.prim.set_position('foregroundBar', new_pos_x, getForegroundPosY())
end

function setForegroundPosY(new_pos_y)
	fgPosY = new_pos_y
	windower.prim.set_position('foregroundBar', getForegroundPosX(), new_pos_y)
end

function setBackgroundHeight(new_height)
	bgBarHeight = new_height
	windower.prim.set_size('backgroundBar', getBackgroundWidth(), new_height)
end

function setBackgroundWidth(new_width)
	bgBarWidth = new_width
	windower.prim.set_size('backgroundBar', new_width, getBackgroundHeight())
end

function setForegroundHeight(new_height)
	fgBarHeight = new_height
	windower.prim.set_size('foregroundBar', getForegroundWidth(), new_height)
end

function setForegroundWidth(new_width)
	fgBarWidth = new_width
	windower.prim.set_size('foregroundBar', new_width, getForegroundHeight())
end

-- Display helpful information
function help()
	print(_addon.name..' v'.._addon.version..': Command Listing')
	print('   (c)lear - Resets EXP counter')
	print('   (u)nload - Disables BarFiller')
	print('   (r)eload - Reloads BarFiller')
end

-- Thanks to Byrthnoth's PointWatch addon
function exp_msg(val,msg)
    local t = os.clock()
    if msg == 8 or msg == 105 then
        xp.registry[t] = (xp.registry[t] or 0) + val
        xp.current = math.min(xp.current + val,55999)
        if xp.current > xp.tnl then
            xp.current = xp.current - xp.tnl
        end
        calcExpBarPerc()
    end
end

-- Calculate XP Bar Width
function calcExpBarPerc()
	local calc = math.floor((xp.current / xp.total) * 468)
	setForegroundWidth(calc)
end

-- Center the Bar on Screen
function positionBars()
	setBackgroundPosX(((windowerResX/2) - (getBackgroundWidth()/2)))
	setForegroundPosX((((windowerResX/2) - (getBackgroundWidth()/2))+2))
end