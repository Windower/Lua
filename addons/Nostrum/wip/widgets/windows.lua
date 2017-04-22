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

local windows = {}
local meta = {}

_libs = _libs or {}
_libs.windows = windows

local prims = _libs.prims or require 'widgets/prims'
local groups = _libs.groups or require 'widgets/groups'
local buttons = _libs.buttons or require 'widgets/buttons'

_meta = _meta or {}
_meta.windows = _meta.windows or {}
_meta.windows.__class = 'Window'
_meta.windows.__index = function(t, k)
	return windows[k] or groups[k]
end

function windows.new(x, y, w, h, visible, alpha, red, green, blue, create_handle)
	local t = groups.new(x, y, w, create_handle and h + 30 or h)
	
	meta[t] = {}
	
	local m = meta[t]

	if create_handle then
		t.handle = buttons.new(x, y, w, 30, visible)
		t.handle.visible = function()
			return groups.visible(t)
		end
		
		t:add(t.handle)
		
		if _libs.widgets then
			t.handle:register_event('left button down', function(x, y)
				widgets.pick_up(t, x, y)
				
				return true
			end)
		end
		
		t.bar = prims.new({
			color = {alpha, (red+100)%256, (green+100)%256, (blue+100)%256},
			w = w - 10,
			h = 20,
			visible = visible,
			pos = {x+5, y+5}
		})
		
		t:add(t.bar)
	end
	
	t.bg = prims.new({
		color = {alpha, red, green, blue},
		w = w,
		h = create_handle and h + 30 or h, -- spoof the height to account for the top bar
		visible = visible,
		pos = {x, y}
	})
	
	t:add(t.bg)

	m.visible = visible
	
	return setmetatable(t, _meta.windows)
end

function windows.destroy(t)
	meta[t] = nil
	
	t.bg:destroy()
	t.bg = nil
	
	if t.handle then
		t.handle:destroy()
		t.bar:destroy()
		t.handle = nil
		t.bar = nil
	end
	
	groups.destroy(t)
end

--[[
function windows.visible(t, bool)
	groups.visible(t, bool)
end

function windows.hide(t)
	t:visible(false)
end

function windows.show(t)
	t:visible(true)
end
function windows.hover(t, x, y)
	local m = meta[t]
	
	return  x >= m.x1 -- check for the bar
		and x <= m.x2
		and y >= m.y1
		and y <= m.y2
end

function windows.pos(t, x, y)
	if not y then
		return t.bg:pos()
	end
	
	groups.pos(t, x, y)
end

function windows.pos_y(t, y)
	if not y then
		return t.bg:pos_y()
	end
	
	groups.pos_y(t, y)
end

function windows.pos_x(t, x)
	if not x then
		return t.bg:pos_x()
	end
	
	groups.pos_x(t, x)
end

function windows.width(t, width)
	if not width then
		return t.bg:width()
	end
	
	t._subwidgets[1]:width(width)
	t._subwidgets[2]:width(width-10)
end

function windows.height(t, height)
	return t._subwidgets[1]:height(height)
end--]]


return windows
