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
	local t = groups.new(x, create_handle and y + 30 or y, w, h)
	
	meta[t] = {}
	
	local m = meta[t]

	if create_handle then
		t.handle = buttons.new(x, y, w, 30, visible)
		t.handle.visible = function()
			return groups.visible(t)
		end
		
		t:add(t.handle)
		
		if _libs.widgets then -- ehhhhhhhhhhhhhhhhhhhhhhhhhhh
			t.handle:register_event('left button down', function(x, y)
				widgets.pick_up(t, x, y)
				
				return true
			end)
			--[[t.handle:register_event('drag', function(x, y)
				local contact = t.handle._contact_point

				groups.pos(t, x + contact[1], y - contact[2])
				
				return true
			end)
			t.handle:register_event('drop', function()
				local x, y = t.handle:pos()
				print('drop')
				
				widgets.update_object(t, x, x + w, y, y + h)
			end)--]]
			
		end
		
		h = h + 30 -- spoof the height to account for the top bar
	end
	
	local bg = prims.new({
		color = {alpha, red, green, blue},
		w = w,
		h = h,
		visible = visible,
		pos = {x, y}
	})
	local bar = prims.new({
		color = {alpha, (red+100)%256, (green+100)%256, (blue+100)%256},
		w = w - 10,
		h = 20,
		visible = visible,
		pos = {x+5, y+5}
	})
	
	t:add(bg)
	t:add(bar)

	--m.events = {} -- ?
	m.visible = visible
	
	return setmetatable(t, _meta.windows)
end

function windows.destroy(t)
	meta[t] = nil
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

--[[function windows.events(t, event)
	local function_list = meta[t].events[event]
	if not function_list then return nil end
	
	local n = 1
	local m = function_list.n
	
	return function()
		local fn = function_list[n]
		
		-- handle holes in the list
		while not fn and n <= m do
			n = n + 1
			fn = function_list[n]
		end
		
		n = n + 1
		
		return fn
	end
end--]]

return windows