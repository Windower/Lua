--[[
    A library to facilitate text primitive creation and manipulation.
]]

local texts = {}
local saved_texts = {}
local dragged

_libs = _libs or {}
_libs.texts = texts

_meta = _meta or {}
_meta.Text = _meta.Text or {}
_meta.Text.__class = 'Text'
_meta.Text.__index = texts
_meta.Text.__newindex = function(t, k, v)
    t:update({[k] = v})
end

--[[
    Local variables
]]

local default_settings = {}
default_settings.pos = {}
default_settings.pos.x = 0
default_settings.pos.y = 0
default_settings.bg = {}
default_settings.bg.alpha = 255
default_settings.bg.red = 0
default_settings.bg.green = 0
default_settings.bg.blue = 0
default_settings.bg.visible = true
default_settings.flags = {}
default_settings.flags.right = false
default_settings.flags.bottom = false
default_settings.flags.bold = false
default_settings.flags.draggable = true
default_settings.flags.italic = false
default_settings.padding = 0
default_settings.text = {}
default_settings.text.size = 12
default_settings.text.font = 'Arial'
default_settings.text.fonts = {}
default_settings.text.alpha = 255
default_settings.text.red = 255
default_settings.text.green = 255
default_settings.text.blue = 255

math.randomseed(os.clock())

local amend = function(settings, text)
    for key, val in pairs(text) do
        local sval = rawget(settings, key)
        if sval == nil then
            rawset(settings, key, val)
        else
            if type(sval) == 'table' and type(val) == 'table' then
                amend(sval, val)
            end
        end
    end
end

local apply_settings = function(_, t, settings)
    settings = settings or t._settings
    texts.pos(t, settings.pos.x, settings.pos.y)
    texts.bg_alpha(t, settings.bg.alpha)
    texts.bg_color(t, settings.bg.red, settings.bg.green, settings.bg.blue)
    texts.bg_visible(t, settings.bg.visible)
    texts.color(t, settings.text.red, settings.text.green, settings.text.blue)
    texts.alpha(t, settings.text.alpha)
    texts.font(t, settings.text.font, unpack(settings.text.fonts))
    texts.size(t, settings.text.size)
    texts.pad(t, settings.padding)
    texts.italic(t, settings.flags.italic)
    texts.bold(t, settings.flags.bold)
    texts.right_justified(t, settings.flags.right_justified)
    texts.bottom_justified(t, settings.flags.bottom_justified)
    texts.visible(t, t._status.visible)

    -- Trigger registered post-reload events
    for _, event in ipairs(t._events) do
        event(t, t._root_settings)
    end
end

-- Returns a new text object.
-- settings: If provided, it will overwrite the defaults with those. The structure needs to be similar
-- str:      Formatting string, if provided, will set it as default text. Supports named variables:
--           ${name|default|format}
--           If those are found, they will initially be set to default. They can later be adjusted by simply
--           setting the values and it will format them according to the format specifier. Example usage:
--
--           t = texts.new('The target\'s name is ${name|(None)}, its ID is ${id|0|%.8X}.')
--           -- At this point the text reads:
--           -- The target's name is (None), its ID is 00000000.
--           -- Now, assume the player is currently targeting its Moogle in the Port Jeuno MH (ID 17784938).
--
--           mob = windower.ffxi.get_mob_by_index(windower.ffxi.get_player()['target_index'])
--
--           t.name = mob['name']
--           -- This will instantly change the text to include the mob's name:
--           -- The target's name is Moogle, its ID is 00000000.
--
--           t.id = mob['id']
--           -- This instantly changes the ID part of the text, so it all reads:
--           -- The target's name is Moogle, its ID is 010F606A.
--           -- Note that the ID has been converted to an 8-digit hex number, as specified with the "%.8X" format.
--
--           t.name = nil
--           -- This unsets the name and returns it to its default:
--           -- The target's name is (None), its ID is 010F606A.
--
--           -- To avoid mismatched attributes, like the name and ID in this case, you can also pass a table to update:
--           t:update(mob)
--           -- Since the mob object contains both a "name" and "id" attribute, and both are used in the text object,
--           -- it will update those with the respective values. The extra values are ignored.
function texts.new(str, settings, root_settings)
    if type(str) ~= 'string' then
        str, settings, root_settings = nil, str, settings
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
    t._name = (_addon and _addon.name or 'text') .. '_gensym_' .. tostring(t):sub(8) .. '_%.8X':format(16^8 * math.random()):sub(3)
    t._settings = settings or {}
    t._status = t._status or {visible = false, text = {}}
    t._root_settings = root_settings
    t._base_str = str
    t._events = {}

    t._texts = {}
    t._defaults = {}
    t._formats = {}
    t._textorder = {}

    windower.text.create(t._name)

    amend(t._settings, default_settings)
    if t._root_settings then
        config.save(t._root_settings)
    end

    if _libs.config and t._root_settings and settings then
        _libs.config.register(t._root_settings, apply_settings, t, settings)
    else
        apply_settings(_, t, settings)
    end

    if str then
        texts.append(t, str)
    else
        windower.text.set_text(t._name, '')
    end

    -- Cache for deletion
    saved_texts[#saved_texts + 1] = t

    return setmetatable(t, _meta.Text)
end

-- Sets string values based on the provided attributes.
function texts.update(t, attr)
    attr = attr or {}
    local str = ''
    for _, key in ipairs(t._textorder) do
        if attr[key] ~= nil then
            t._texts[key] = t._formats[key]:format(attr[key])
        end

        if t._texts[key] ~= nil then
            str = str .. t._texts[key]
        else
            str = str .. t._defaults[key]
        end
    end

    windower.text.set_text(t._name, str)
    t._status.text.content = str

    return str
end

-- Restores the original text object not counting updated settings
-- If second argument is true, will erase the original text as well and create a blank text object
function texts.clear(t, erase)
    t._texts = {}
    t._defaults = {}
    t._textorder = {}
    t._formats = {}

    if not erase and t._base_str then
        texts.append(t, t._base_str)
    else
        windower.text.set_text(t._name, '')
    end
end

-- Appends new text tokens to be displayed
function texts.append(t, str)
    local i = 1
    local index = #t._textorder + 1
    while i <= #str do
        local startpos, endpos = str:find('%${.-}', i)
        local rndname = '%s_%u':format(t._name, index)
        if startpos then
            -- Match before the tag
            local match = str:sub(i, startpos - 1)
            if match ~= '' then
                t._textorder[index] = rndname
                t._texts[rndname] = match
                index = index + 1
            end

            -- Set up defaults
            match = str:sub(startpos + 2, endpos - 1)
            local key = match
            local default = ''
            local format = '%s'

            -- Match the key
            local keystart, keyend = match:find('^.-|')
            if keystart then
                key = match:sub(1, keyend - 1)
                match = match:sub(keyend + 1)
                default = match
            end

            -- Match the default and format
            local defaultstart, defaultend = match:find('^.-|')
            if defaultstart then
                default = match:sub(1, defaultend - 1)
                format = match:sub(defaultend + 1)
            end

            t._textorder[index] = key
            t._texts[key] = default
            t._defaults[key] = default
            t._formats[key] = format

            index = index + 1
            i = endpos + 1

        else
            t._textorder[index] = rndname
            t._texts[rndname] = str:sub(i)
            break

        end
    end

    texts.update(t)
end

-- Appends new text tokens with a line break
function texts.appendline(t, str)
    t:append('\n' .. str)
end

-- Makes the primitive visible
function texts.show(t)
    windower.text.set_visibility(t._name, true)
    t._status.visible = true
end

-- Makes the primitive invisible
function texts.hide(t)
    windower.text.set_visibility(t._name, false)
    t._status.visible = false
end

-- Returns whether or not the text object is visible
function texts.visible(t, visible)
    if visible == nil then
        return t._status.visible
    end

    windower.text.set_visibility(t._name, visible)
    t._status.visible = visible
end

-- Sets a new text
function texts.text(t, str)
    if not str then
        return t._status.text.content
    end

    texts.clear(t, true)
    texts.append(t, str)
end

--[[
    The following methods all either set the respective values or return them, if no arguments to set them are provided.
]]

function texts.pos(t, x, y)
    if not x then
        return t._settings.pos.x, t._settings.pos.y
    end

    local settings = windower.get_windower_settings()
    windower.text.set_location(t._name, x + (t._settings.flags.right and settings.ui_x_res or 0), y + (t._settings.flags.bottom and settings.ui_y_res or 0))
    t._settings.pos.x = x
    t._settings.pos.y = y
end

function texts.pos_x(t, x)
    if not x then
        return t._settings.pos.x
    end

    t:pos(x, t._settings.pos.y)
end

function texts.pos_y(t, y)
    if not y then
        return t._settings.pos.y
    end

    t:pos(t._settings.pos.x, y)
end

function texts.font(t, ...)
    if not ... then
        return t._settings.text.font
    end

    windower.text.set_font(t._name, ...)
    t._settings.text.font = (...)
    t._settings.text.fonts = {select(2, ...)}
end

function texts.size(t, size)
    if not size then
        return t._settings.text.size
    end

    windower.text.set_font_size(t._name, size)
    t._settings.text.size = size
end

function texts.pad(t, padding)
    if not padding then
        return t._settings.padding
    end

    windower.text.set_bg_border_size(t._name, padding)
    t._settings.padding = padding
end

function texts.color(t, red, green, blue)
    if not red then
        return t._settings.text.red, t._settings.text.green, t._settings.text.blue
    end

    windower.text.set_color(t._name, t._settings.text.alpha, red, green, blue)
    t._settings.text.red = red
    t._settings.text.green = green
    t._settings.text.blue = blue
end

function texts.alpha(t, alpha)
    if not alpha then
        return t._settings.text.alpha
    end

    windower.text.set_color(t._name, alpha, t._settings.text.red, t._settings.text.green, t._settings.text.blue)
    t._settings.text.alpha = alpha
end

-- Sets/returns text transparency. Based on percentage values, with 1 being fully transparent, while 0 is fully opaque.
function texts.transparency(t, alpha)
    if not alpha then
        return 1 - t._settings.text.alpha/255
    end

    alpha = math.floor(255*(1-alpha))
    windower.text.set_color(t._name, alpha, t._settings.text.red, t._settings.text.green, t._settings.text.blue)
    t._settings.text.alpha = alpha
end

function texts.right_justified(t, rj)
    if not rj then
        return t._settings.flags.right
    end

    windower.text.set_right_justified(t._name, rj)
end

function texts.bottom_justified(t, bj)
    if not bj then
        return t._settings.flags.bottom
    end

    windower.text.set_bottom_justified(t._name, bj)
end

function texts.italic(t, italic)
    if not italic then
        return t._settings.flags.italic
    end

    windower.text.set_italic(t._name, italic)
end

function texts.bold(t, bold)
    if not bold then
        return t._settings.flags.bold
    end

    windower.text.set_bold(t._name, bold)
end

function texts.bg_color(t, red, green, blue)
    if not red then
        return t._settings.bg.red, t._settings.bg.green, t._settings.bg.blue
    end

    windower.text.set_bg_color(t._name, t._settings.bg.alpha, red, green, blue)
    t._settings.bg.red = red
    t._settings.bg.green = green
    t._settings.bg.blue = blue
end

function texts.bg_visible(t, visible)
    if not visible then
        return t._settings.bg.visible
    end

    windower.text.set_bg_visibility(t._name, visible)
    t._settings.bg.visible = visible
end

function texts.bg_alpha(t, alpha)
    if not alpha then
        return t._settings.bg.alpha
    end

    windower.text.set_bg_color(t._name, alpha, t._settings.bg.red, t._settings.bg.green, t._settings.bg.blue)
    t._settings.bg.alpha = alpha
end

-- Sets/returns background transparency. Based on percentage values, with 1 being fully transparent, while 0 is fully opaque.
function texts.bg_transparency(t, alpha)
    if not alpha then
        return 1 - t._settings.bg.alpha/255
    end

    alpha = math.floor(255*(1-alpha))
    windower.text.set_bg_color(t._name, alpha, t._settings.bg.red, t._settings.bg.green, t._settings.bg.blue)
    t._settings.bg.alpha = alpha
end

-- Returns true if the coordinates are currently over the text object
function texts.hover(t, x, y)
    if not t:visible() then
        return false
    end

    local pos_x, pos_y = windower.text.get_location(t._name)
    local off_x, off_y = windower.text.get_extents(t._name)

    return (pos_x <= x and x <= pos_x + off_x
        or pos_x >= x and x >= pos_x + off_x)
    and (pos_y <= y and y <= pos_y + off_y
        or pos_y >= y and y >= pos_y + off_y)
end

function texts.destroy(t)
    for i, t_needle in ipairs(saved_texts) do
        if t == t_needle then
            table.remove(t, i)
        end
    end
    windower.text.delete(t._name)
end

-- Handle drag and drop
windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked then
        return
    end

    -- Mouse drag
    if type == 0 then
        if dragged then
            dragged.text:pos(x - dragged.x, y - dragged.y)
            return true
        end

    -- Mouse left click
    elseif type == 1 then
        for _, t in pairs(saved_texts) do
            if t._settings.flags.draggable and t:hover(x, y) then
                local pos_x, pos_y = windower.text.get_location(t._name)

                if t._settings.flags.right or t._settings.flags.bottom then
                    local info = windower.get_windower_settings()
                    if t._settings.flags.right then
                        pos_x = pos_x - info.ui_x_res
                    else
                        pos_y = pos_y - info.ui_y_res
                    end
                end

                dragged = {text = t, x = x - pos_x, y = y - pos_y}
                return true
            end
        end

    -- Mouse left release
    elseif type == 2 then
        if dragged then
            if dragged.text._root_settings then
                config.save(dragged.text._root_settings)
            end
            dragged = nil
            return true
        end
    end

    return false
end)

-- Can define functions to execute every time the settings are reloaded
function texts.register_reload_event(t, fn)
    t._events[#t._events + 1] = fn
    return #t._events
end

function texts.unregister_reload_event(t, fn)
    if type(fn) == 'number' then
        table.remove(t._events, fn)
    else
        for index, event in ipairs(t._events) do
            if event == fn then
                table.remove(t._events, index)
                return
            end
        end
    end
end

return texts

--[[
Copyright © 2013-2014, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
