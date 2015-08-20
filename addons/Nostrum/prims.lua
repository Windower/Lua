--[[
    A library to facilitate primitive creation and manipulation.
]]

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
        image = boolean,
        texture = string,
        fit = boolean,
        tile = {x_rep,y_rep}
    }
--]]

local events = {
    left_click = true,
    right_click = true,
    middle_click = true,
    scroll_up = true,
    scroll_down = true,
    hover = true,
    hover_begin = true,
    hover_end = true,
    drag = true,
    right_drag = true,
}

function prims.new(settings)
    local t = {}
    settings = settings or {}
    settings.pos = settings.pos or {0, 0}
    local m = {
        color = settings.color and {unpack(settings.color)} or {255, 255, 255, 255},
        width = settings.w or 0,
        height = settings.h or 0,
        visible = settings.visible or false,
        image = settings.set_texture or false,
        texture = settings.texture,
        fit = settings.fit_texture or false,
        tile = settings.tile or {1, 1},
        events = {}
    }
    m.x1, m.x2 = m.width >= 0 and settings.pos[1], m.width + settings.pos[1] or m.width + settings.pos[1], settings.pos[1]
    m.y1, m.y2 = m.height >= 0 and m.height + settings.pos[2], settings.pos[2] or settings.pos[2], m.height + settings.pos[2] 

    meta[t] = m
    m.name = (_addon and _addon.name or 'prim') .. '_gensym_' .. tostring(t):sub(8) .. '_%.8X':format(16^8 * math.random()):sub(3)
    windower.prim.create(m.name)
    --defaults for prims seem pointless, but these will prevent errors if people forget information.

    if settings.color then
        windower.prim.set_color(m.name, unpack(m.color))
    end
    
    windower.prim.set_position(m.name, m.x1, m.y2)
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

--[[
    The following methods all either set the respective values or return them, if no arguments to set them are provided.
]]

-- Returns whether or not the prim object is visible
function prims.visible(t, visible)
    if visible == nil then
        return meta[t].visible
    end
    windower.prim.set_visibility(meta[t].name, visible)
    meta[t].visible = visible
end

function prims.append_label(t, str)
end

function prims.pos(t, x, y)
    if not y then
        return meta[t].width >= 0 and meta[t].x1 or meta[t].x2,
               meta[t].height >= 0 and meta[t].y2 or meta[t].y1
    end

    local m = meta[t]
    windower.prim.set_position(m.name, x, y)

    m.x1, m.x2 = m.width >= 0 and x, m.width + x or m.width + x, x
    m.y1, m.y2 = m.height >= 0 and m.height + y, y or y, m.height + y 
end

function prims.pos_x(t, x)
    if not x then
        return meta[t].width >= 0 and meta[t].x1 or meta[t].x2
    end

    local m = meta[t]
    windower.prim.set_position(m.name, x, meta[t].height >= 0 and m.y2 or m.y1) -- swapped these

    m.x1, m.x2 = m.width >= 0 and x, m.width + x or m.width + x, x
end

function prims.pos_y(t, y)
    if not y then
        return meta[t].height >= 0 and meta[t].y2 or meta[t].y1 -- swapped these
    end

    local m = meta[t]
    windower.prim.set_position(m.name, m.width >= 0 and m.x1 or m.x2, y)

    m.y1, m.y2 = m.height >= 0 and m.height + y, y or y, m.height + y 
end

function prims.right(t, d)
    local m = meta[t]
    t:pos_x((m.width >= 0 and m.x1 or m.x2) + d)
end

function prims.left(t, d)
    local m = meta[t]
    t:pos_x((m.width >= 0 and m.x1 or m.x2) - d)
end

function prims.up(t, d)
    local m = meta[t]
    t:pos_y((m.height >= 0 and m.y2 or m.y1) - d)
end

function prims.down(t, d)
    local m = meta[t]
    t:pos_y((m.height >= 0 and m.y2 or m.y1) + d)
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
            m.x2 = m.x1 + width
        else
            m.x1 = m.x2 + width
        end
    else
        if w >= 0 then
            m.x1, m.x2 = m.x2 + width, m.x2
        else
            m.x1, m.x2 = m.x1 + width, m.x1
        end
    end
end

local newanimator = function(n)
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
end

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
            m.y1 = m.y2 + height
        else
            m.y2 = m.y1 + height
        end
    else
        if h >= 0 then
            m.y1, m.y2 = m.y2, m.y2 + height
        else
            m.y1, m.y2 = m.y1 + height, m.y1
        end
    end
end

function prims.height_smooth(t, height, time_interval, dheight)
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
end

function prims.size(t, width, height)
    if not height then
        return meta[t].width, meta[t].height
    end
    
    local m = meta[t]
    local w = m.width
    local h = m.height

    if w * width >= 0 then
        if w >= 0 then
            m.x2 = m.x1 + width
        else
            m.x1 = m.x2 + width
        end
    else
        if w >= 0 then
            m.x1, m.x2 = m.x2 + width, m.x2
        else
            m.x1, m.x2 = m.x1 + width, m.x1
        end
    end

    if h * height >= 0 then
        if h >= 0 then
            m.y1 = m.y2 + height
        else
            m.y2 = m.y1 + height
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
        and m.y1 >= y
        and m.y2 <= y)
end

function prims.destroy(t)
    windower.prim.delete(meta[t].name)
    meta[t] = nil
    t = nil
end

function prims.get_events(t)
    return meta[t].events
end

function prims.register_event(t, event, fn)
    if not events[event] then
        error('The event ' .. event .. ' is not available to the ' .. class(t) .. ' class.')
        return
    end
    
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
