--[[
    A library to facilitate image primitive creation and manipulation.
]]

local table = require('table')
local math = require('math')

local images = {}
local meta = {}

saved_images = {}
local dragged

local events = {
    reload = true,
    left_click = true,
    double_left_click = true,
    right_click = true,
    double_right_click = true,
    middle_click = true,
    scroll_up = true,
    scroll_down = true,
    hover = true,
    drag = true,
    right_drag = true
}

_libs = _libs or {}
_libs.images = images

_meta = _meta or {}
_meta.Image = _meta.Image or {}
_meta.Image.__class = 'Image'
_meta.Image.__index = images

local set_value = function(t, key, value)
    local m = meta[t]
    m.values[key] = value
    m.images[key] = value ~= nil and (m.formats[key] and m.formats[key]:format(value) or tostring(value)) or m.defaults[key]
end

_meta.Image.__newindex = function(t, k, v)
    set_value(t, k, v)
    t:update()
end

--[[
    Local variables
]]

local default_settings = {}
default_settings.pos = {}
default_settings.pos.x = 0
default_settings.pos.y = 0
default_settings.visible = true
default_settings.color = {}
default_settings.color.alpha = 255
default_settings.color.red = 255
default_settings.color.green = 255
default_settings.color.blue = 255
default_settings.size = {}
default_settings.size.width = 0
default_settings.size.height = 0
default_settings.texture = {}
default_settings.texture.path = ''
default_settings.texture.fit = true
default_settings.repeatable = {}
default_settings.repeatable.x = 1
default_settings.repeatable.y = 1
default_settings.draggable = true

math.randomseed(os.clock())

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

local call_events = function(t, event, ...)
    if not meta[t].events[event] then
        return
    end

    -- Trigger registered post-reload events
    for _, event in ipairs(meta[t].events[event]) do
        event(t, meta[t].root_settings)
    end
end

local apply_settings = function(_, t, settings)
    settings = settings or meta[t].settings
    images.pos(t, settings.pos.x, settings.pos.y)
    images.visible(t, meta[t].status.visible)
    images.alpha(t, settings.color.alpha)
    images.color(t, settings.color.red, settings.color.green, settings.color.blue)
    images.size(t, settings.size.width, settings.size.height)
    images.fit(t, settings.texture.fit)
    images.path(t, settings.texture.path)
    images.repeat_xy(t, settings.repeatable.x, settings.repeatable.y)
    images.draggable(t, settings.draggable)

    call_events(t, 'reload')
end

function images.new(str, settings, root_settings)
    if type(str) ~= 'string' then
        str, settings, root_settings = '', str, settings
    end

    -- Sets the settings table to the provided settings, if not separately provided and the settings are a valid settings table
    if not _libs.config then
        root_settings = nil
    else
        root_settings =
            root_settings and class(root_settings) == 'settings' and
                root_settings
            or settings and class(settings) == 'settings' and
                settings
            or
                nil
    end

    t = {}
    local m = {}
    meta[t] = m
    m.name = (_addon and _addon.name or 'image') .. '_gensym_' .. tostring(t):sub(8) .. '_%.8x':format(16^8 * math.random()):sub(3)
    m.settings = settings or {}
    m.status = m.status or {visible = false, image = {}}
    m.root_settings = root_settings
    m.base_str = str

    m.events = {}

    m.keys = {}
    m.values = {}
    m.imageorder = {}
    m.defaults = {}
    m.formats = {}
    m.images = {}

    windower.prim.create(m.name)

    amend(m.settings, default_settings)
    if m.root_settings then
        config.save(m.root_settings)
    end

    if _libs.config and m.root_settings and settings then
        _libs.config.register(m.root_settings, apply_settings, t, settings)
    else
        apply_settings(_, t, settings)
    end

    -- Cache for deletion
    table.insert(saved_images, 1, t)

    return setmetatable(t, _meta.Image)
end

function images.update(t, attr)
    attr = attr or {}
    local m = meta[t]

    -- Add possibly new keys
    for key, value in pairs(attr) do
        m.keys[key] = true
    end

    -- Update all image segments
    for key in pairs(m.keys) do
        set_value(t, key, attr[key] == nil and m.values[key] or attr[key])
    end
end

function images.clear(t)
    local m = meta[t]
    m.keys = {}
    m.values = {}
    m.imageorder = {}
    m.images = {}
    m.defaults = {}
    m.formats = {}
end

-- Makes the primitive visible
function images.show(t)
    windower.prim.set_visibility(meta[t].name, true)
    meta[t].status.visible = true
end

-- Makes the primitive invisible
function images.hide(t)
    windower.prim.set_visibility(meta[t].name, false)
    meta[t].status.visible = false
end

-- Returns whether or not the image object is visible
function images.visible(t, visible)
    local m = meta[t]
    if visible == nil then
        return m.status.visible
    end

    windower.prim.set_visibility(m.name, visible)
    m.status.visible = visible
end

--[[
    The following methods all either set the respective values or return them, if no arguments to set them are provided.
]]

function images.pos(t, x, y)
    local m = meta[t]
    if x == nil then
        return m.settings.pos.x, m.settings.pos.y
    end

    windower.prim.set_position(m.name, x, y)
    m.settings.pos.x = x
    m.settings.pos.y = y
end

function images.pos_x(t, x)
    if x == nil then
        return meta[t].settings.pos.x
    end

    t:pos(x, meta[t].settings.pos.y)
end

function images.pos_y(t, y)
    if y == nil then
        return meta[t].settings.pos.y
    end

    t:pos(meta[t].settings.pos.x, y)
end

function images.size(t, width, height)
    local m = meta[t]
    if width == nil then
        return m.settings.size.width, m.settings.size.height
    end

    windower.prim.set_size(m.name, width, height)
    m.settings.size.width = width
    m.settings.size.height = height
end

function images.width(t, width)
    if width == nil then
        return meta[t].settings.size.width
    end

    t:size(width, meta[t].settings.size.height)
end

function images.height(t, height)
    if height == nil then
        return meta[t].settings.size.height
    end

    t:size(meta[t].settings.size.width, height)
end

function images.path(t, path)
    if path == nil then
        return meta[t].settings.texture.path
    end

    windower.prim.set_texture(meta[t].name, path)
    meta[t].settings.texture.path = path
end

function images.fit(t, fit)
    if fit == nil then
        return meta[t].settings.texture.fit
    end

    windower.prim.set_fit_to_texture(meta[t].name, fit)
    meta[t].settings.texture.fit = fit
end

function images.repeat_xy(t, x, y)
    local m = meta[t]
    if x == nil then
        return m.settings.repeatable.x, m.settings.repeatable.y
    end

    windower.prim.set_repeat(m.name, x, y)
    m.settings.repeatable.x = x
    m.settings.repeatable.y = y
end

function images.draggable(t, drag)
    if drag == nil then
        return meta[t].settings.draggable
    end

    meta[t].settings.draggable = drag
end

function images.color(t, red, green, blue)
    local m = meta[t]
    if red == nil then
        return m.settings.color.red, m.settings.color.green, m.settings.color.blue
    end

    windower.prim.set_color(m.name, m.settings.color.alpha, red, green, blue)
    m.settings.color.red = red
    m.settings.color.green = green
    m.settings.color.blue = blue
end

function images.alpha(t, alpha)
    local m = meta[t]
    if alpha == nil then
        return m.settings.color.alpha
    end

    windower.prim.set_color(m.name, alpha, m.settings.color.red, m.settings.color.green, m.settings.color.blue)
    m.settings.color.alpha = alpha
end

-- Sets/returns image transparency. Based on percentage values, with 1 being fully transparent, while 0 is fully opaque.
function images.transparency(t, alpha)
    local m = meta[t]
    if alpha == nil then
        return 1 - m.settings.color.alpha/255
    end

    alpha = math.floor(255*(1-alpha))
    windower.prim.set_color(m.name, alpha, m.settings.color.red, m.settings.color.green, m.settings.color.blue)
    m.settings.color.alpha = alpha
end

-- Returns true if the coordinates are currently over the image object
function images.hover(t, x, y)
    if not t:visible() then
        return false
    end

    local pos_x, pos_y = t:pos()
    local off_x, off_y = t:get_extents()
    
    -- print(pos_x, pos_y, off_x, off_y)

    return (pos_x <= x and x <= pos_x + off_x
        or pos_x >= x and x >= pos_x + off_x)
    and (pos_y <= y and y <= pos_y + off_y
        or pos_y >= y and y >= pos_y + off_y)
end

function images.destroy(t)
    for i, t_needle in ipairs(saved_images) do
        if t == t_needle then
            table.remove(saved_images, i)
            break
        end
    end
    windower.prim.delete(meta[t].name)
    meta[t] = nil
end

function images.get_extents(t)
    local m = meta[t]
    
    local ext_x = m.settings.pos.x + m.settings.size.width
    local ext_y = m.settings.pos.y + m.settings.size.height

    return ext_x, ext_y
end

-- Handle drag and drop
windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked then
        return
    end

    -- Mouse drag
    if type == 0 then
        if dragged then
            dragged.image:pos(x - dragged.x, y - dragged.y)
            return true
        end

    -- Mouse left click
    elseif type == 1 then
        for _, t in pairs(saved_images) do
            local m = meta[t]
            if m.settings.draggable and t:hover(x, y) then
                local pos_x, pos_y = t:pos()
                dragged = {image = t, x = x - pos_x, y = y - pos_y}
                return true
            end
        end

    -- Mouse left release
    elseif type == 2 then
        if dragged then
            if meta[dragged.image].root_settings then
                config.save(meta[dragged.image].root_settings)
            end
            dragged = nil
            return true
        end
    end

    return false
end)

-- Can define functions to execute every time the settings are reloaded
function images.register_event(t, key, fn)
    if not events[key] then
        error('Event %s not available for text objects.':format(key))
        return
    end

    local m = meta[t]
    m.events[key] = m.events[key] or {}
    m.events[key][#m.events[key] + 1] = fn
    return #m.events[key]
end

function images.unregister_event(t, key, fn)
    if not (events[key] and meta[t].events[key]) then
        return
    end

    if type(fn) == 'number' then
        table.remove(meta[t].events[key], fn)
    else
        for index, event in ipairs(meta[t].events[key]) do
            if event == fn then
                table.remove(meta[t].events[key], index)
                return
            end
        end
    end
end

return images

--[[
Copyright © 2015, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
