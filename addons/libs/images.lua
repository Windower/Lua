--[[
    A library to facilitate image primitive creation and manipulation.
]]

local images = {}
local meta = {}

windower.prim.saved_images = {}
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
    right_drag = true,
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
default_settings.texture = {}
default_settings.texture.path = ''
default_settings.texture.fit = true
default_settings.repeatable = {}
default_settings.repeatable.x = 1
default_settings.repeatable.y = 1

math.randomseed(os.clock())

local amend
amend = function(settings, text)
    for key, val in pairs(text) do
        local sval = settings[key]
        if sval == nil then
            settings[key] = val
        else
            if type(sval) == 'table' and type(val) == 'table' then
                amend(sval, val)
            end
        end
    end
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
    images.path(t, settings.texture.path)
    images.fit(t, settings.texture.fit)
    images.repeat_xy(t, settings.repeatable.x, settings.repeatable.y)

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
            root_settings and class(root_settings) == 'Settings' and
                root_settings
            or settings and class(settings) == 'Settings' and
                settings
            or
                nil
    end

    t = {}
    local m = {}
    meta[t] = m
    m.name = (_addon and _addon.name or 'image') .. '_gensym_' .. tostring(t):sub(8) .. '_%.8X':format(16^8 * math.random()):sub(3)
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

    return setmetatable(t, _meta.Image)
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

--[[
    The following methods all either set the respective values or return them, if no arguments to set them are provided.
]]

function images.pos(t, x, y)
    local m = meta[t]
    if not x then
        return m.settings.Pos.X, m.settings.Pos.Y
    end

    local settings = windower.get_windower_settings()
    windower.prim.set_position(m.name, x, y)
    m.settings.Pos.X = x
    m.settings.Pos.Y = y
end

function images.pos_x(t, x)
    if not x then
        return meta[t].settings.Pos.X
    end

    t:pos(x, meta[t].settings.Pos.Y)
end

function images.pos_y(t, y)
    if not y then
        return meta[t].settings.Pos.Y
    end

    t:pos(meta[t].settings.Pos.X, Y)
end

function images.size(t, width, height)
    local m = meta[t]
    if not width then
        return m.settings.Size.Width and m.settings.Size.Height
    end

    windower.prim.set_size(meta[t].name, width, height)
    m.settings.Size.Width = width
    m.settings.Size.Height = height
end

function images.path(t, path)
    if not path then
        return meta[t].settings.Texture.Path
    end

    windower.prim.set_texture(meta[t].name, path)
    meta[t].settings.Texture.Path = path
end

function images.fit(t, fit)
    if not fit then
        return meta[t].settings.Texture.Fit
    end

    windower.prim.set_fit_to_texture(meta[t].name, fit)
    meta[t].settings.Texture.Fit = fit
end

function images.repeat_xy(t, x, y)
    if not x then
        return meta[t].settings.Repeatable.X
    end

    windower.prim.set_repeat(meta[t].name, x, y)
    meta[t].settings.Repeatable.X = x
    meta[t].settings.Repeatable.Y = y
end

function images.color(t, red, green, blue)
    if not red then
        return meta[t].settings.Color.Red, meta[t].settings.Color.Green, meta[t].settings.Color.Blue
    end

    windower.prim.set_color(meta[t].name, meta[t].settings.Color.Alpha, red, green, blue)
    meta[t].settings.Color.Red = red
    meta[t].settings.Color.Green = green
    meta[t].settings.Color.Blue = blue
end

function images.alpha(t, alpha)
    if not alpha then
        return meta[t].settings.Color.Alpha
    end

    windower.prim.set_color(meta[t].name, alpha, meta[t].settings.Color.Red, meta[t].settings.Color.Green, meta[t].settings.Color.Blue)
    meta[t].settings.Color.Alpha = alpha
end

-- Sets/returns text transparency. Based on percentage values, with 1 being fully transparent, while 0 is fully opaque.
function images.transparency(t, alpha)
    if not alpha then
        return 1 - meta[t].settings.Color.Alpha/255
    end

    alpha = math.floor(255*(1-alpha))
    windower.prim.set_color(meta[t].name, alpha, meta[t].settings.Color.Red, meta[t].settings.Color.Green, meta[t].settings.Color.Blue)
    meta[t].settings.Color.Alpha = alpha
end

function images.visible(t, visible)
    if visible == nil then
        return meta[t].settings.Visible
    end

    windower.prim.set_visibility(meta[t].name, visible)
    meta[t].settings.Visible = visible
end

function images.destroy(t)
    for i, t_needle in ipairs(windower.prim.saved_images) do
        if t == t_needle then
            table.remove(windower.prim.saved_images, i)
            break
        end
    end
    windower.prim.delete(meta[t].name)
    meta[t] = nil
end

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
Copyright © 2013-2015, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
