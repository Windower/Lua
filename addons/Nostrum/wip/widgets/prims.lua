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
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

windower.prim.saved_prims = {}
local prims = {}
local meta = {}

_libs = _libs or {}
_libs.prims = prims

_meta = _meta or {}
_meta.Prim = _meta.Prim or {}
_meta.Prim.__class = 'Prim'
_meta.Prim.__index = prims

--[[
    settings = {
        pos = {x,y},
        w = number,
        color = {a,r,g,b},
        h = number,
        visible = boolean,
        set_texture = boolean,
        texture = string,
        fit_texture = boolean,
        tile = {x_rep,y_rep}
    }
--]]

function prims.new(settings)
    local t = {}
    local color = settings.color

    settings = settings or {}
    settings.pos = settings.pos and {settings.pos[1], settings.pos[2]} or {0, 0}

    local m = {
        color = color and (color.a and {color.a, color.r, color.g, color.b} or {unpack(color)}) or {255, 255, 255, 255},
        width = settings.w or 0,
        height = settings.h or 0,
        visible = settings.visible or false,
        image = settings.set_texture or false,
        texture = settings.texture,
        fit = settings.fit_texture or false,
        tile = settings.tile or {1, 1},
        events = {}
    }

    -- these are almost definitely swapped.
    m.x1, m.x2 = m.width >= 0 and settings.pos[1], m.width + settings.pos[1] - 1 or m.width + settings.pos[1], settings.pos[1] - 1
    m.y1, m.y2 = m.height >= 0 and settings.pos[2], m.height + settings.pos[2] - 1 or m.height + settings.pos[2], settings.pos[2] - 1

    meta[t] = m

    m.name = (_addon and _addon.name or 'prim') .. '_gensym_' .. tostring(t):sub(8) .. '_%.8X':format(16^8 * math.random()):sub(3)
    windower.prim.create(m.name)

    if settings.color then
        windower.prim.set_color(m.name, unpack(m.color))
    end
    
    windower.prim.set_position(m.name, m.width >= 0 and m.x1 or m.x2 + 1, m.height >= 0 and m.y1 or m.y2 + 1)
    windower.prim.set_size(m.name, m.width, m.height)
    windower.prim.set_visibility(m.name, m.visible)

    if m.image then
        windower.prim.set_fit_to_texture(m.name, m.fit)
        windower.prim.set_texture(m.name, m.texture)
        if settings.tile then
            windower.prim.set_repeat(m.name, unpack(m.tile))
        end
    end
    
    return setmetatable(t, _meta.Prim)
end

-- Makes the primitive visible
function prims.show(t)
    windower.prim.set_visibility(meta[t].name, true)
    meta[t].visible = true
end

-- Makes the primitive invisible
function prims.hide(t)
    windower.prim.set_visibility(meta[t].name, false)
    meta[t].visible = false
end

-- Returns whether or not the prim object is visible
function prims.visible(t, visible)
    if visible == nil then
        return meta[t].visible
    end
    windower.prim.set_visibility(meta[t].name, visible)
    meta[t].visible = visible
end

function prims.pos(t, x, y)
    local m = meta[t]

    if not y then
        return m.width >= 0 and m.x1 or m.x2 + 1, m.height >= 0 and m.y1 or m.y2 + 1
    end
    
    local is_width_positive = m.width >= 0
    local is_height_positive = m.height >= 0

    m.x1, m.x2 = is_width_positive and x, m.width + x - 1 or m.width + x, x - 1
    m.y1, m.y2 = is_height_positive and y, m.height + y - 1 or m.height + y, y - 1

    windower.prim.set_position(m.name, x, y)
end

function prims.pos_x(t, x)
    local m = meta[t]

    if not x then
        return m.width >= 0 and m.x1 or m.x2 + 1
    end
    
    m.x1, m.x2 = m.width >= 0 and x, m.width + x - 1 or m.width + x, x - 1

    -- if x1 is the left corner, then x1 <= x < x1 + h
    -- if width is negative, then x2 + h <= x < x2
    
    --[[
        w = 10
        pos = 0
        x1 -> 0
        x2 -> 9
        
        w = -10
        pos = 0
        x1 -> -10
        x2 -> -1
        
        returning x2 - 1
    --]]
    windower.prim.set_position(m.name, x, m.height >= 0 and m.y1 or m.y2 + 1)
end

function prims.pos_y(t, y)
    local m = meta[t]

    if not y then
        return m.height >= 0 and m.y1 or m.y2 + 1
    end
    
    local is_height_positive = m.height >= 0

    m.y1, m.y2 = is_height_positive and y, m.height + y - 1 or m.height + y, y - 1

    windower.prim.set_position(m.name, m.width >= 0 and m.x1 or m.x2 + 1, y)
end

function prims.right(t, d)
    local m = meta[t]
    t:pos_x((m.width >= 0 and m.x1 or m.x2 + 1) + d)
end

function prims.left(t, d)
    local m = meta[t]
    t:pos_x((m.width >= 0 and m.x1 or m.x2 + 1) - d)
end

function prims.up(t, d)
    local m = meta[t]
    t:pos_y((m.height >= 0 and m.y1 or m.y2 + 1) - d)
end

function prims.down(t, d)
    local m = meta[t]
    t:pos_y((m.height >= 0 and m.y1 or m.y2 + 1) + d)
end

function prims.width(t, width)
    if not width then
        return meta[t].width
    end
    
    local m = meta[t]
    local w = m.width
    
    windower.prim.set_size(m.name, width, m.height)
    
    m.width = width
    
    if w * width >= 0 then
        if w >= 0 then
            m.x2 = m.x1 + width - 1
        else
            m.x1 = m.x2 + width + 1
        end
    else
        if w >= 0 then
            m.x1, m.x2 = m.x1 + width, m.x1 - 1
        else
            m.x1, m.x2 = m.x2 + 1, m.x2 + 1 + width
        end
    end
end

--[[local newanimator = function(n)
    return function(fn)
        while fn() do
            coroutine.sleep(n)
        end
    end
end

function prims.width_smooth(t, width, time_interval, dwidth)
    local m = meta[t]
    m.width_actual = width
    
    if not t.animator then
        dwidth = (width - m.width) * dwidth > 0 and dwidth or -dwidth
        t.animator = newanimator(time_interval)
        t.animator(function()
            local n = m.width + dwidth
            if dwidth > 0 and n >= m.width_actual or dwidth < 0 and n <= m.width_actual then
                t:width(m.width_actual) 
                t.animator = nil
                return false
            else
                t:width(n) 
                return true 
            end
        end)
    end
end--]]

function prims.height(t, height)
    if not height then
        return meta[t].height
    end
    
    local m = meta[t]
    local h = m.height
    
    windower.prim.set_size(m.name, m.width, height)
    
    m.height = height
    
    if h * height >= 0 then
        if h >= 0 then
            m.y2 = m.y1 + height - 1
        else
            m.y1 = m.y2 + height
        end
    else
        if h >= 0 then
            m.y1, m.y2 = m.y2, m.y2 + height
        else
            m.y1, m.y2 = m.y1 + height, m.y1
        end
    end
end

--[[function prims.height_smooth(t, height, time_interval, dheight)
    local m = meta[t]
    m.height_actual = height

    if not t.animator then
        dheight = (height - m.height) * dheight > 0 and dheight or -dheight
        t.animator = newanimator(time_interval)
        t.animator(function()
            local n = m.height + dheight
            if dheight > 0 and n >= m.height_actual or dheight < 0 and n <= m.height_actual then
                t:height(m.height_actual) 
                t.animator = nil
                return false
            else
                t:height(n) 
                return true 
            end
        end)
    end
end--]]

function prims.size(t, width, height)
    if not height then
        return meta[t].width, meta[t].height
    end
    
    local m = meta[t]
    local w = m.width
    local h = m.height

    if w * width >= 0 then
        if w >= 0 then
            m.x2 = m.x1 + width - 1
        else
            m.x1 = m.x2 + width + 1
        end
    else
        if w >= 0 then
            m.x1, m.x2 = m.x1 + width, m.x1 - 1
        else
            m.x1, m.x2 = m.x2 + 1, m.x2 + 1 + width
        end
    end

    if h * height >= 0 then
        if h >= 0 then
            m.y2 = m.y1 + height - 1
        else
            m.y1 = m.y2 + height
        end
    else
        if h >= 0 then
            m.y1, m.y2 = m.y2, m.y2 + height
        else
            m.y1, m.y2 = m.y1 + height, m.y1
        end
    end

    windower.prim.set_size(m.name, width, height)
    m.width, m.height = width, height
end

function prims.extents(t)
    return meta[t].width, meta[t].height
end

function prims.color(t, red, green, blue)
    if not blue then
        return unpack(meta[t].color,2,4)
    end
    
    local m = meta[t]
    windower.prim.set_color(m.name, m.color[1], red, green, blue)
    m.color[2], m.color[3], m.color[4] = red, green, blue
end

function prims.alpha(t, alpha)
    if not alpha then
        return meta[t].color[1]
    end
    local m = meta[t]
    windower.prim.set_color(m.name, alpha, m.color[2], m.color[3], m.color[4])
    m.color[1] = alpha
end

function prims.argb(t, a, r, g, b)
    if not b then
        return unpack(meta[t].color)
    end
    
    local m = meta[t]
    windower.prim.set_color(m.name, a, r, g, b)
    m.color[1], m.color[2], m.color[3], m.color[4] = a, r, g, b
end

-- Sets/returns prim transparency. Based on percentage values, with 1 being fully transparent, while 0 is fully opaque.
function prims.transparency(t, alpha)
    if not alpha then
        return 1 - meta[t].color[1]/255
    end

    alpha = math.floor(255*(1-alpha))
    local m = meta[t]
    windower.prim.set_color(m.name, alpha, m.color[2], m.color[3], m.color[4])
    m.color[1] = alpha
end

function prims.tile(t, x_rep, y_rep)
    if not y_rep then
        return unpack(meta[t].tile)
    end
    
    local m = meta[t]
    windower.prim.set_repeat(m.name, x_rep, y_rep)
    m.tile[1], m.tile[2] = x_rep, y_rep
end

function prims.texture(t, path)
    if not path then
        return meta[t].texture
    end
    
    windower.prim.set_texture(meta[t].name, path)
    meta[t].texture = path
end

function prims.fit(t, fit)
    if fit == nil then
        return meta[t].fit
    end
    
    windower.prim.set_fit_to_texture(meta[t].name, fit)
    meta[t].fit = fit
end

function prims.hover(t, x, y)
    local m = meta[t]
    
    return (m.x2 >= x
        and m.x1 <= x
        and m.y2 >= y
        and m.y1 <= y)
end

function prims.destroy(t)
    windower.prim.delete(meta[t].name)
    meta[t] = nil
end


function prims.events(t, event)
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

function prims.register_event(t, event, fn)    
    local m = meta[t].events

    m[event] = m[event] or {n = 0}
    
    local n = #m[event] + 1
    
    m[event][n] = fn
    m[event].n = m[event].n > n and m[event].n or n

    return n
end
 
function prims.unregister_event(t, event, n)
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

return prims
