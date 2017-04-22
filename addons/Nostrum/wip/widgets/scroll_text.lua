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

--[[
	Old "fit" functions removed. Text extents are needed to recalculate
	dimensions of box, but the text object is not redrawn until the next
	frame render.
--]]

local scrolling_text = {}
local meta = {}

_libs = _libs or {}
_libs.scrolling_text = scrolling_text

_libs.texts = _libs.texts or require 'texts'
_libs.prims = _libs.prims or require 'widgets/prims'

local texts = _libs.texts
local prims = _libs.prims

_meta = _meta or {}
_meta.scrolling_text = _meta.scrolling_text or {}
_meta.scrolling_text.__class = 'ScrollText'
_meta.scrolling_text.__index = scrolling_text

_raw = _raw or {}
_raw.table = _raw.table or {}

local concat = _raw.table.concat or table.concat

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

local default_settings = {
    color = {
        bar = {255, 129, 150, 154},
        bg = {149, 52, 63, 65},
    },
    text = {
        font = 'Consolas',
        size = 10,
		red = 224,
		blue = 226,
		green = 228,
		lines = {},
        color_formatting = {},
        lines_to_display = 12,
		line_height = 16,
    },
    pos = {0, 0},
    w = 150,
    fit = {x = false, y = false},
}

function scrolling_text.new(settings)
    local m = settings or {}

    local t = {}
    meta[t] = m
	
    m.events = {}
    
    amend(m, default_settings)
    m.text.lines.n = #m.text.lines
    --m.lines_to_display = m.fit.y and m.text.lines.n <= m.text.lines_to_display and m.text.lines.n or m.text.lines_to_display
    m.lines_to_display = m.text.lines_to_display

    m.from, m.to = 1, m.text.lines.n < m.lines_to_display and m.text.lines.n or m.lines_to_display

    m.text.display = {}
    for i = 1, m.text.lines.n do
        if m.text.color_formatting[i] then
            m.text.display[i] = '\\cs(' .. concat(m.text.color_formatting[i],',') .. ')' .. m.text.lines[i] .. '\\cr'
        else
            m.text.display[i] = m.text.lines[i]
        end
    end
	
	m.line_height = m.text.line_height
	m.h = m.line_height * m.lines_to_display --

    t.bg = prims.new({
        pos = m.pos,
        w = m.w,
		h = m.h,
        color = m.color.bg,
        visible = m.visible,
        })
    t.bar = prims.new({
        pos = {
            m.pos[1] + m.w,
            m.pos[2],
        },
        w = 10,
		h = m.line_height,
        color = m.color.bar,
        visible = m.visible,
        })
    t.content = texts.new('', {
            pos = {x = m.pos[1], y = m.pos[2] - m.line_height},
            bg = {visible = false},
            flags = {draggable = false, bold = true},
            text = m.text,
        })
    
    --[[if m.fit.x then
        m.min_w = m.w
        m.temp_w = m.w
    end
    
    if not m.fit.y then
        scrolling_text.initialize(t)
    end--]]
    
	if _libs.widgets then
		--widgets.handle_mouse_event(t.bar, m.pos[1] + m.w, m.pos[1] + m.w + 10, m.pos[2], m.pos[2] + 1) -- ?
		scrolling_text.register_event(t, 'scroll', function(x, y, delta)
			local m = meta[t]
			scrolling_text.scroll(t, delta)

			return m.events.scroll.n == 1
		end)
		
		scrolling_text.register_event(t, 'left button down', function(x, y)
			local m = meta[t]
			if x > m.pos[1] + m.w 
				and m.text.lines.n > m.lines_to_display 
				and t.bar:hover(x, y) 
				and widgets.get_carried_object() ~= t.bar then

					widgets.pick_up(t.bar, x, y)
					return true
			end
		end)
		
		prims.register_event(t.bar, 'drag', function(x, y)
			local scroll_increment_height = (m.h - t.bar:height())/(m.text.lines.n - m.lines_to_display)
			local bar_y = scroll_increment_height * (m.from - 1) + m.pos[2]--t.bar:pos_y()
			local bar_y2 = y - t.bar._contact_point[2]
			local dy = bar_y2 - bar_y
			
			if dy > 0 then
				local max_bar_pos = m.h + m.pos[2] - t.bar:height()
				
				if bar_y2 <= max_bar_pos then
					t.bar:pos_y(bar_y2)
				else
					t.bar:pos_y(max_bar_pos)
				end				
				scrolling_text.text_scroll(t, -math.floor(dy/scroll_increment_height))
			else
				local max_bar_pos = m.pos[2]
				
				if bar_y2 >= max_bar_pos then
					t.bar:pos_y(bar_y2)
				else
					t.bar:pos_y(max_bar_pos)
				end
				scrolling_text.text_scroll(t, -math.ceil(dy/scroll_increment_height))
			end

			return true
		end)
		
		--[[scrolling_text.register_event(t, 'left button up', function(x, y)
			if widgets.get_carried_object() == t.bar then
				widgets.put_down(t.bar)
				return true
			end
		end)
		t.bar:register_event('left button down', handle_pickup)
		t.bar.height = function(t, h)
			if h then
				local x, y = t.bar:pos()
				widgets.update(t.bar, x, x + 10, y, y + h)
			end

			return prims.height(t, h)
		end
		t.bar.pos_y = function(t, y)
			if y then
				local x = t.bar:pos_x()
				widgets.update(t.bar, x, x + 10, y, y + t.bar:height())
			end
			
			return prims.pos_y(t, y)
		end
		t.bar:register_event('drag', handle_drag)--]]
	end
	
    return setmetatable(t, _meta.scrolling_text)
end

--[[function scrolling_text.initialize(t)
    local m = meta[t]

    t.content:text('A\nB\nC\nD\nE\nF\nG\nH\nI\nJ\nK\nL\nM\nN\nO\nP\nQ\nR\nS\nT\nU\nV\nW\nX\nY\nZ')
    t.content:show()
    coroutine.sleep(.02)
    
    local w, h = t.content:extents()    
    local _h = h / 26
    m.h = _h * m.lines_to_display

    t.bg:size(m.w, m.h)

    if m.line_height ~= _h then
        m.line_height = _h
        t.content:pos_y(m.pos[2] - _h)
    end
    
    t.content:hide()
end--]]
function scrolling_text.destroy(t)
	meta[t] = nil
	t.content:destroy()
	t.bar:destroy()
	t.bg:destroy()
end

function scrolling_text.line(t, n)
	return meta[t].text.lines[n]
end

--[[
function scrolling_text.fit(t, fit_x, fit_y)
    if not (fit_x or fit_y) then return end

    local m = meta[t]
    t.content:show()
    coroutine.sleep(.02)
    
    local w, h = t.content:extents()
    if m.temp_w then
        w = w > m.temp_w and w or m.temp_w
    end
    
    if fit_x and w ~= m.w then
        m.temp_w = w
        t.bg:width(w)
        t.bar:pos_x(m.pos[1] + w)
        m.w = w
    end
    if fit_y and not m.line_height or m.h ~= m.text.lines.n * m.line_height then
        local _h = h / (m.lines_to_display + 1)
        m.h = _h * m.lines_to_display
        t.bg:height(m.h)
        if m.line_height ~= _h then
            m.line_height = _h
            t.content:pos_y(m.pos[2] - _h)
        end
    end
end
--]]

function scrolling_text.refresh(t)
    local m = meta[t]
    for i = 1, m.text.lines.n do
        if m.text.color_formatting[i] then
            m.text.display[i] = '\\cs(' .. concat(color_formatting[i],',') .. ')' .. m.text.lines[i] .. '\\cr'
        else
            m.text.display[i] = m.text.lines[i]
        end
    end
    
    if m.visible then
        t.content:text(t:concat('\n', m.from, m.to))
    end
end
 
function scrolling_text.show(t)
    t.bg:show()
    local m = meta[t]
    if m.text.lines.n > m.lines_to_display then 
        t.bar:show()
    end
    t.content:show()
    
    m.visible = true
end

function scrolling_text.hide(t)
    t.bg:hide()
    t.bar:hide()
    t.content:hide()
    
    meta[t].visible = false
end

function scrolling_text.open(t, n)
    local m = meta[t]

    if n then
        local range = m.to - m.from
        n = n < 1 and 1 or (n + range > m.text.lines.n and m.text.lines.n - range or n)
        
        m.from, m.to = n, n + range
    end
    
    --[[if m.fit.x then
        m.temp_w = m.min_w
    end--]]
        
    t.content:text(t:concat('\n',m.from,m.to))
    --t:fit(m.fit.x, m.fit.y)
    
    if m.text.lines.n > m.lines_to_display then
		local bar_height = m.h * m.lines_to_display / m.text.lines.n
--        t.bar:pos_y(m.pos[2] + (m.lines_to_display * m.line_height * (1 - m.lines_to_display / m.text.lines.n)) / (m.text.lines.n - m.lines_to_display) * (m.from - 1))        
        t.bar:pos_y(
			m.pos[2] 
			--+ (m.lines_to_display * m.line_height * (1 - m.lines_to_display / m.text.lines.n)) 
			+ (m.h - bar_height)
			/ (m.text.lines.n - m.lines_to_display) 
			* (m.from - 1)
		)        
        t.bar:height(bar_height)
		
		if not t.bar:visible() then 
            t.bar:show()
        end
    elseif t.bar:visible() then
        t.bar:hide()
    end
    
    t:show()
end

function scrolling_text.close(t)
    t:hide()
    local m = meta[t]
    m.from, m.to = 1, m.text.lines.n < m.lines_to_display and m.text.lines.n or m.lines_to_display
end

function scrolling_text.visible(t, visible) 
    if visible == nil then
        return meta[t].visible
    end
    
    local m = meta[t]
    
    t.bg:visible(visible)
    if visible and m.text.lines.n > m.lines_to_display then 
        t.bar:visible(visible)
    else
        t.bar:hide()
    end
    t.content:visible(visible)
    
    m.visible = visible
end

function scrolling_text.scroll(t, delta)
	t:text_scroll(delta)
	t:bar_scroll(delta)
end

function scrolling_text.text_scroll(t, delta)
	if delta == 0 or delta == -0 then return end

    local m = meta[t]
    if m.text.lines.n > m.lines_to_display then
        local n = m.from - delta
        local range = m.to - m.from

        n = n < 1 and 1 or (n + range > m.text.lines.n and m.text.lines.n - range or n)
        
        m.from, m.to = n, n + range
        
        t.content:text(t:concat('\n',m.from,m.to))
    end
end

function scrolling_text.bar_scroll(t, delta)
    local m = meta[t]
	t.bar:pos_y(
		m.pos[2] 
		+ (m.lines_to_display * m.line_height * (1 - m.lines_to_display / m.text.lines.n))
		/ (m.text.lines.n - m.lines_to_display)
		* (m.from - 1)
	)
end

function scrolling_text.force_scroll(t, delta)
	local events = m.events.scroll
	if not events then return end
	
	for i = 1, events.n do
		if events[i] then
			events[i](delta)
		end
	end
end

function scrolling_text.line_height(t)
    return meta[t].line_height
end

function scrolling_text.list_position(t)
    return meta[t].from
end

function scrolling_text.range(t)
    return meta[t].to - meta[t].from + 1
end

function scrolling_text.hover(t, x, y)
    local m = meta[t]
	local _x, _y = m.pos[1], m.pos[2]
	
	return x >= _x
		and x < _x + m.w + (t.bar:visible() and 10 or 0)
		and y >= _y
		and y < _y + m.h
	--t.bg:hover(x, y)
end

function scrolling_text.text(t, array, color_formatting)
    local m = meta[t]
    
    m.text.lines = array
    m.text.lines.n = #array
    m.text.display = {}
    m.text.color_formatting = color_formatting or {}
    --m.lines_to_display = m.fit.y and m.text.lines.n < m.text.lines_to_display and m.text.lines.n or m.text.lines_to_display
    m.from, m.to = 1, m.text.lines.n < m.lines_to_display and m.text.lines.n or m.lines_to_display
    
    for i = 1, m.text.lines.n do
        if m.text.color_formatting[i] then
            m.text.display[i] = '\\cs(' .. concat(color_formatting[i],',') .. ')' .. m.text.lines[i] .. '\\cr'
        else
            m.text.display[i] = m.text.lines[i]
        end
    end
    
end

function scrolling_text.pos(t, x, y)
    if not y then
        return unpack(meta[t].pos)
    end

    local m = meta[t]
    
    t.bg:pos(x, y)
    t.bar:pos(x + m.w, y + t.bar:pos_y() - m.pos[2])
    t.content:pos(x, y - m.line_height)
    
    m.pos[1], m.pos[2] = x, y
end

function scrolling_text.pos_x(t, x)
    if not x then
        return meta[t].pos[1]
    end
    
    t.bg:pos_x(x)
    t.bar:pos_x(x + meta[t].w)
    t.content:pos_x(x)
    
    meta[t].pos[1] = x
end

function scrolling_text.pos_y(t, y)
    if not y then
        return meta[t].pos[2]
    end
    
    t:pos(meta[t].pos[1], y)
end

function scrolling_text.width(t, width)
    if not width then return meta[t].w end
    local m = meta[t]
    
    m.w = width
    t.bg:width(width)
    t.bar:pos_x(m.pos[1] + width)
end

function scrolling_text.height(t)
    return meta[t].h -- to do, maybe
end

function scrolling_text.extents(t)
    return meta[t].h, meta[t].w -- to do, maybe
end

function scrolling_text.edit_line(t, n, s)
    local m = meta[t]
    
    if type(n) == 'table' then
        local bool = false
        
        for line, edit in pairs(n) do
            bool = bool or m.from <= index and index <= m.to
            m.text.display[line] = edit
        end
        
        if bool then
            t.content:text(t:concat('\n',m.from,m.to))
        end
    else
        m.text.display[n] = s
        
        if m.from <= n and n <= m.to then
            t.content:text(t:concat('\n',m.from,m.to))
        end
    end
end

function scrolling_text.new_line(t, n, s, color)
    local m = meta[t]
    
    table.insert(m.text.lines, n, s)
    m.text.lines.n = m.text.lines.n + 1
    
    if color then
        table.insert(m.text.display, n, '\\cs(' .. concat(unpack(color), ',') .. ')' .. s .. '\\cr')
    else
        table.insert(m.text.display, n, s)
    end

    --m.lines_to_display = m.fit.y and m.text.lines.n < m.text.lines_to_display and m.text.lines.n or m.text.lines_to_display
    m.to = m.to < m.lines_to_display and m.to + 1 or m.to
    
    if m.from <= n and n <= m.to then
        t.content:text(t:concat('\n', m.from, m.to))
    end


    --t:fit(m.fit.x, m.fit.y)
   
    if m.text.lines.n > m.lines_to_display then
        t.bar:height(m.h * m.lines_to_display / m.text.lines.n)
        t.bar:pos_y(m.pos[2] + (m.lines_to_display * m.line_height * (1 - m.lines_to_display / m.text.lines.n)) / (m.text.lines.n - m.lines_to_display) * (m.from - 1))
        if not t.bar:visible() then 
            t.bar:show()
        end
    elseif t.bar:visible() then
        t.bar:hide()
    end
end

function scrolling_text.append(t, s, color)
    local m = meta[t]
    
    t:new_line(m.text.lines.n + 1, s, color)
    
    if m.to + 1 == m.text.lines.n then
        t:scroll(-1)
    end
end

function scrolling_text.cs(t, n, r, g, b)
    local m = meta[t]
    
    if type(n) == 'table' then
        local bool = false
        
        for index, color_table in pairs(n) do
            bool = bool or m.from <= index and index <= m.to
            m.text.display[index] = '\\cs(' .. concat(color_table,',') .. ')' .. m.text.lines[index] .. '\\cr'
        end
        
        if bool then
            t.content:text(t:concat('\n',m.from,m.to))
        end
    else
        m.text.display[n] = '\\cs('.. tostring(r) ..','.. tostring(g) .. ',' .. tostring(b) .. ')' .. m.text.lines[n] .. '\\cr'
        
        if m.from <= n and n <= m.to then
            t.content:text(t:concat('\n',m.from,m.to))
        end
    end
end

function scrolling_text.cr(t, n)
    local m = meta[t]
    
    if type(n) == 'table' then
        local bool = false
        
        for i = 1, #n do
            bool = bool or m.from <= n[i] and n[i] <= m.to
            m.text.display[n[i]] = m.text.lines[n[i]]
        end
        
        if bool then
            t.content:text(t:concat('\n',m.from,m.to))
        end
    else
        m.text.display[n] = m.text.lines[n]
        
        if m.from <= n and n <= m.to then
            t.content:text(t:concat('\n',m.from,m.to))
        end
    end
end

function scrolling_text.concat(t, sep, from, to)
    if to == 0 then return end
    
    return ' \n' .. concat(meta[t].text.display, sep, from, to) -- see windower/issues/issues/#655
end

function scrolling_text.events(t, event)
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

function scrolling_text.register_event(t, event, fn)
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
 
function scrolling_text.unregister_event(t, event, n)
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

return scrolling_text
