local slider = {}
local meta = {}

_libs = _libs or {}
_libs.slider = slider

_libs.prims = _libs.prims or require 'widgets/prims'
local prims = _libs.prims

_meta = _meta or {}
_meta.slider = _meta.slider or {}
_meta.slider.__class = 'Slider'
_meta.slider.__index = slider

local amend
amend = function(settings, defaults)
    for key, val in pairs(defaults) do
        if type(val) == 'table' then
            settings[key] = amend(settings[key] or {}, val)
        elseif settings[key] == nil then
            settings[key] = val
        end
    end

    return settings
end
--[[
    settings = {
        pos = {x,y},
        w = number,
        color = {a,r,g,b},
        h = number,
        visible = boolean,
        image = boolean,
        texture = string,
        fit = boolean,
        tile = {x_rep,y_rep}
    }
--]]

local default_settings = {
    handle = {
        w = 16,
        color = {255, 129, 150, 154},
        h = 30,
    },
    track = {
        w = 140,
        color = {222, 131, 199, 99},
        h = 8,
    },
    pos = {0,0},
    visible = false,
}

function slider.new(settings)
    local t = {}
    
    settings = amend(settings or {}, default_settings)
    
    settings.handle.pos = {
		settings.pos[1] - settings.handle.w / 2, 
		settings.pos[2] -- - (settings.handle.h - settings.track.h) / 2
	}
    settings.track.pos = {
		settings.pos[1],
		settings.pos[2] + settings.handle.h/2 - settings.track.h/2
	}--settings.pos
    
    t.track = prims.new(settings.track)
    t.handle = prims.new(settings.handle)
    
    local m = {}
    meta[t] = m
    
    m.slider_pos = 0
	m.decimal = 0
    m.events = {}
	m.pos = settings.pos
	
	if _libs.widgets then
		slider.register_event(t, 'left button down', function(x, y)
			slider.slide(t, x)
			widgets.pick_up(t.handle, x, y)
			
			return true
		end)
		
		t.handle:register_event('drag', function(x, y)
			slider.slide(t, x)

			return true
		end)
	end
	
	return setmetatable(t, _meta.slider)
end

function slider.destroy(t)
	t.handle:destroy()
	t.track:destroy()
	
	meta[t] = nil
end

function slider.hover(t, x, y)
    return t.handle:hover(x, y) or t.track:hover(x, y)
end

function slider.decimal(t)
	return meta[t].decimal
end

function slider.percentage(t, percent)
	if not percent then	return meta[t].decimal * 100 end

    local m = meta[t]
	
	percent = percent/100
	m.decimal = percent
	
	percent = percent * t.track:width() - t.handle:width() / 2
	t.handle:pos_x(t:pos_x() + percent)
    m.slider_pos = percent	
end

function slider.slide(t, x)    
	local m = meta[t]
	
    local _x = m.pos[1]
    local _w = t.track:width()
    
    x = (x < _x and _x or x > _x + _w and _x + _w or x)
	m.decimal = (x-_x)/_w

	x = x - t.handle:width() / 2
    t.handle:pos_x(x)
    m.slider_pos = x - _x
	local events = meta[t].events.slide
	
	if events then
		for i = 1, events.n do
			if events[i] then
				events[i](m.decimal)
			end
		end
	end
end

function slider.width(t)
	return t.track:width()
end

function slider.height(t)
	return t.handle:height()
end

function slider.show(t)
    t.handle:show()
    t.track:show()
end

function slider.hide(t)
    t.handle:hide()
    t.track:hide()
end

function slider.visible(t, visible)
    if visible == nil then return t.handle:visible() end
    
    t.handle:visible(visible)
    t.track:visible(visible)
end

function slider.pos(t, x, y)
	local m = meta[t]
    if not y then return m.pos[1], m.pos[2] end
    
    t.handle:pos(
		x + m.slider_pos,
		y
	)
    t.track:pos(x, y + (t.handle:height() - t.track:height()) / 2)
	
	m.pos[1], m.pos[2] = x, y
end

function slider.pos_x(t, x)
    if not x then return meta[t].pos[1] end
	local m = meta[t]
	
    t.handle:pos_x(x + m.slider_pos)
    t.track:pos_x(x)
	m.pos[1] = x
end

function slider.pos_y(t, y)
    if not y then return meta[t].pos[2] end

	local m = meta[t]
	
    t.handle:pos_y(y)
    t.track:pos_y(y + (t.handle:height() - t.track:height()) / 2)
	m.pos[2] = y
end

function slider.events(t, event)
	local function_list = meta[t].events[event]
	if not function_list then return nil end
	
	local n = 0
	local m = function_list.n
	
	return function()
		n = n + 1
		local fn = function_list[n]
		
		-- handle holes in the list
		while not fn and n <= m do
			n = n + 1
			fn = function_list[n]
		end

		return fn
	end
end

function slider.register_event(t, event, fn)
    local m = meta[t].events

    m[event] = m[event] or {n = 0}
    local n
    for i = 1, m[event].n do
        if not m[event][i] then
            n = i
            break
        end
    end
    if not n then
        n = m[event].n + 1
        m[event].n = n
    end
    m[event][n] = fn

    return n
end
 
function slider.unregister_event(t, event, n)
    if not (events[event] and meta[t].events[event]) then
        return
    end

    if type(n) == 'number' then
        meta[t].events[event][n] = nil
    else
        for i = 1, meta[t].events[event].n do
            if meta[t].events[event][i] == n then
                meta[t].events[event][i] = nil
                return
            end
        end
    end
end

return slider
