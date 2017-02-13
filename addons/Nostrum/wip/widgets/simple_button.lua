local simple_buttons = {}
local meta = {}

_libs = _libs or {}
_libs.simple_buttons = simple_buttons

local texts = _libs.texts or require 'texts'
local prims = _libs.prims or require 'widgets/prims'

_meta = _meta or {}
_meta.SimpleButtons = _meta.SimpleButtons or {}
_meta.SimpleButtons.__class = 'Button'
_meta.SimpleButtons.__index = function(t, k) return simple_buttons[k] or prims[k] end

function class(o)
    local mt = getmetatable(o)

    return mt and mt.__class or type(o)
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
    w = 70,
    h = 30,
    color = {255, 129, 150, 154},
    visible = false,
    labels = {}
}

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

function simple_buttons.new(settings)
	settings = amend(settings or {}, default_settings)
    local t = prims.new(settings)

	local m = {
        state = false,
        events = {},
		labels = {},
    }
	
	local labels = settings.labels
	m.labels.n = #labels
	
	for i = 1, m.labels.n do
		local text_settings = labels[i]
		if type(text_settings) == 'table' then
			text_settings.flags = text_settings.flags or {}
			text_settings.flags.draggable = false
			settings.bg = settings.bg or {visible = false}
		else
			text_settings = {text_settings, {flags = {draggable = false}}}
		end
		
		m.labels[i] = texts.new(unpack(text_settings))
		
		if settings.visible then
			m.labels[i]:show()
		end
	end
	
	meta[t] = m
    
    return setmetatable(t, _meta.SimpleButtons)
end

function simple_buttons.destroy(t)
	meta[t] = nil
end

function simple_buttons.visible(t, visible)
    if visible == nil then return prims.visible(t) end

	local m = meta[t]
    for i = 1, m.labels.n do
        m.labels[i]:visible(visible)
    end
    
    prims.visible(t, visible)
end

function simple_buttons.show(t)
    t:visible(true)
end

function simple_buttons.hide(t)
	t:visible(false)
end

function simple_buttons.pos(t, x, y)
    if not y then return prims.pos(t) end
    
	local m = meta[t]
	local _x, _y = prims.pos(t)

    for i = 1, m.labels.n do
        local label = m.labels[i]
		local lx, ly = label:pos()
		
        label:pos(x + lx - _x, y + ly - _y)
    end
    
    prims.pos(t, x, y)
end

function simple_buttons.pos_x(t, x)
    if not x then return prims.pos_x(t) end

	local m = meta[t]
	local _x = prims.pos_x(t)
	
    for i = 1, m.labels.n do
        local label = m.labels[i]
        label:pos_x(x + label:pos_x() - _x)
    end
    
    prims.pos_x(t, x)
end

function simple_buttons.pos_y(t, y)
    if not y then return prims.pos_y(t) end

	local m = meta[t]
	local _y = prims.pos_y(t)
	
    for i = 1, m.labels.n do
        local label = m.labels[i]
        label:pos_y(y + label:pos_y() - _y)
    end
    
    prims.pos_y(t, y)
end

function simple_buttons.append_label(t, text, x_offset, y_offset)
	x_offset, y_offset = x_offset or 0, y_offset or 0
	local m = meta[t]

    local n = m.labels.n + 1
	
	if class(text) == 'Text' then
		m.labels[n] = text
		
		local x, y = prims.pos(t)
		text:pos(x + x_offset, y + y_offset)
		
	elseif type(text) == 'table' then
		text.flags = text.flags or {}
		text.flags.draggable = false
		text.pos = text.pos or {x = x_offset + prims.pos_x(t), y = y_offset + prims.pos_y(t)}
		text.bg = text.bg or {visible = false}
		m.labels[n] = texts.new(unpack(text))
		
	elseif type(text) == 'string' then
		m.labels[n] = texts.new(text, {
            flags = {draggable = false},
            bg = {visible = false},
            pos = {x = x_offset + prims.pos_x(t), y = y_offset + prims.pos_y(t)},		
		})
	end
	
	m.labels.n = n

	if prims.visible(t) then
		m.labels[n]:show()
	end
end

function simple_buttons.remove_label(t, n)
    local m = meta[t]
	
	m.labels.n = m.labels.n - 1
    m.labels[n]:destroy()
    table.remove(m.labels, n)
end

function simple_buttons.label(t, n)
    return meta[t].labels[n]
end

function simple_buttons.events(t, event)
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

function simple_buttons.register_event(t, event, fn)
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
 
function simple_buttons.unregister_event(t, event, n)
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

return simple_buttons
