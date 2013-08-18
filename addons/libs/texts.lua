--[[
A library to facilitate text primitive creation and manipulation.
]]

local texts = {}
local saved_texts = {}

_libs = _libs or {}
_libs.texts = texts

_meta.Text = _meta.Text or {}
_meta.Text.__class = 'Text'
_meta.Text.__index = texts
_meta.Text.__newindex = function(t, k, v)
    local l = #t._textorder
    for key, val in ipairs(t._textorder) do
        if val == k then
            break
        end

        if key == l then
            t._textorder[l + 1] = k
            t._defaults[k] = ''
        end
    end
    t._texts[k] = v ~= nil and tostring(v) or nil
    t:update()
end

--[[
    Local variables
]]

local apply_settings
local amend

local default_settings = {}
default_settings.pos = {}
default_settings.pos.x = 0
default_settings.pos.y = 0
default_settings.bg = {}
default_settings.bg.alpha = 255
default_settings.bg.red = 0
default_settings.bg.green = 0
default_settings.bg.blue = 0
default_settings.bg.visibile = true
default_settings.flags = {}
default_settings.flags.right = false
default_settings.flags.bottom = false
default_settings.flags.bold = false
default_settings.flags.italic = false
default_settings.padding = 0
default_settings.text = {}
default_settings.text.size = 12
default_settings.text.font = 'Arial'
default_settings.text.alpha = 255
default_settings.text.red = 255
default_settings.text.green = 255
default_settings.text.blue = 255
default_settings.text.content = ''

math.randomseed(os.clock())

-- Returns a new text object.
-- settings: If provided, it will overwrite the defaults with those. The structure needs to be similar
-- str:      Formatting string, if provided, will set it as default text. Supports named variables:
--           ${name|default}
--           If those are found, they will initially be set to default. They can later be adjusted by simply setting the values. Example usage:
--
--           t = texts.new('The target\'s name is ${name|(None)}, its ID is ${id|0}.')
--           -- At this point the text reads:
--           -- The target's name is (None), its ID is 0.
--           -- Now, assume the player is currently targeting its Moogle in the Port Jeuno MH (ID 17784938).
--
--           mob = get_mob_by_index(get_player()['target_index'])
--
--           t.name = mob['name']
--           -- This will instantly change the text to include the mob's name:
--           -- The target's name is Moogle, its ID is 0.
--
--           t.id = mob['id']
--           -- This instantly changes the ID part of the text, so it all reads:
--           -- The target's name is Moogle, its ID is 17784938.
--
--           t.name = nil
--           -- This unsets the name and returns it to its default:
--           -- The target's name is (None), its ID is 17784938.
--
--           -- To avoid mismatched attributes, like the name and ID in this case, you can also pass a table to update:
--           t:update(mob)
--           -- Since the mob object contains both a "name" and "id" attribute, and both are used in the text object, it will update those with the respective values. The extra values are ignored.
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
    t._name = 'text_gensym_'..tostring(math.random()):sub(3)
    t._settings = settings or {}
    t._status = t._status or {visible = false}
    t._root_settings = root_settings

    t._texts = {}
    t._defaults = {}
    t._textorder = {}

    windower.text.create(t._name)

    amend(t._settings, default_settings)
    if t._root_settings then
        config.save(t._root_settings)
    end

    apply_settings(t, t._settings)
    if _libs.config and t._root_settings then
        _libs.config.register(t._root_settings, apply_settings, t)
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

function amend(settings, text)
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

function apply_settings(t)
    windower.text.set_location(t._name, t._settings.pos.x, t._settings.pos.y)
    windower.text.set_bg_color(t._name, t._settings.bg.alpha, t._settings.bg.red, t._settings.bg.green, t._settings.bg.blue)
    windower.text.set_bg_visibility(t._name, t._settings.visible)
    windower.text.set_color(t._name, t._settings.text.alpha, t._settings.text.red, t._settings.text.green, t._settings.text.blue)
    windower.text.set_font(t._name, t._settings.text.font, t._settings.text.size)
    windower.text.set_bg_border_size(t._name, t._settings.padding)
    windower.text.set_italic(t._name, t._settings.flags.italic)
    windower.text.set_bold(t._name, t._settings.flags.bold)
    windower.text.set_right_justified(t._name, t._settings.flags.right)
--    windower.text.set_bottom_justified(t._name, t._settings.flags.bottom)
    windower.text.set_visibility(t._name, t._status.visible)
end

-- Sets string values based on the provided attributes.
function texts.update(t, attr)
    attr = attr or {}
    local str = ''
    for _, key in ipairs(t._textorder) do
        if attr[key] ~= nil then
            t._texts[key] = tostring(attr[key])
        end
        if t._texts[key] ~= nil then
            str = str..t._texts[key]
        else
            str = str..t._defaults[key]
        end
    end

    windower.text.set_text(t._name, str)
    t._settings.text.content = str

    return str
end

-- Unsets all variables.
function texts.clear(t)
    t:update({})
end

-- Appends new text tokens to be displayed. Supports variables.
function texts.append(t, str)
    local i = 1
    local startpos, endpos
    local match
    local rndname
    local key = #t._textorder + 1
    local innerstart, innerend
    local defaultmatch
    while i <= #str do
        startpos, endpos = str:find('%${.-}', i)
        if startpos then
            -- Match before the tag.
            match = str:sub(i, startpos - 1)
            rndname = t._name..'_'..key
            t._textorder[key] = rndname
            t._texts[rndname] = match
            key = key + 1

            -- Match the tag.
            match = str:sub(startpos + 2, endpos - 1)
            innerstart, innerend = match:find('^.-|')
            if innerstart then
                defaultmatch = match:sub(innerend + 1)
                match = match:sub(1, innerend - 1)
            else
                defaultmatch = ''
            end
            t._textorder[key] = match
            t._texts[match] = defaultmatch
            t._defaults[match] = defaultmatch
            key = key + 1

            i = endpos + 1
        else
            match = str:sub(i)
            rndname = t._name..'_'..key
            t._textorder[key] = rndname
            t._texts[rndname] = match
            break
        end
    end

    texts.update(t)
end

-- Appends new text tokens with a line break. Supports variables.
function texts.appendline(t, str)
    t:append('\n'..str)
end

-- Makes the primitive visible.
function texts.show(t)
    windower.text.set_visibility(t._name, true)
    t._status.visible = true
end

-- Makes the primitive invisible.
function texts.hide(t)
    windower.text.set_visibility(t._name, false)
    t._status.visible = false
end

-- Returns whether or not the text object is visible.
function texts.visible(t, visible)
    if visible == nil then
        return t._status.visible
    end

    windower.text.set_visibility(t._name, visible)
    t._status.visible = visible
end

-- Sets the text. This will ignore the defined text patterns.
function texts.text(t, str)
    if not str then
        return t._settings.text.content
    end

    str = tostring(str)
    windower.text.set_text(t._name, str)
    t._settings.text.content = str
end

--[[
    The following methods all either set the respective values or return them, if no arguments to set them are provided.
]]

function texts.pos(t, x, y)
    if not x then
        return t._settings.pos.x, t._settings.pos.y
    end

    windower.text.set_location(t._name, x, y)
    t._settings.pos.x = x
    t._settings.pos.y = y
end

function texts.x_pos(t, x)
    if x then
        return t._settings.pos.x
    end

    t:pos(x, t._settings.pos.y)
end

function texts.y_pos(t, y)
    if not y then
        return t._settings.pos.y
    end

    t:pos(t._settings.pos.x, y)
end

function texts.font(t, font)
    if not font then
        return t._settings.text.font
    end

    windower.text.set_font(t._name, font, t._settings.text.size)
    t._settings.text.font = font
end

function texts.size(t, size)
    if not size then
        return t._settings.text.size
    end

    windower.text.set_font(t._name, t._settings.text.font, size)
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

function texts.bg_color(red, green, blue)
    if not red then
        return t._settings.bg.red, t._settings.bg.green, t._settings.bg.blue
    end

    windower.text.set_bg_color(t._name, t._settings.bg.alpha, red, green, blue)
    t._settings.bg.red = red
    t._settings.bg.green = green
    t._settings.bg.blue = blue
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

function texts.destroy(t)
    windower.text.delete(t._name)
end

-- Destroy all text objects when the addon unloads
local function destroy_texts()
    for _, t in pairs(saved_texts) do
        t:destroy()
    end
end

-- Handle drag and drop
local function handle_mouse(type, x, y, delta, blocked)
    if blocked then
        return
    end

    if type == 0x200 then
        if dragged_text then
            local t = dragged_text[1]
            t:pos(x - dragged_text[2], y - dragged_text[3])
            return true
        end

    elseif type == 0x201 then
        for _, t in pairs(saved_texts) do
            local x_pos, y_pos = windower.text.get_location(t._name)
            local x_off, y_off = windower.text.get_extents(t._name)

            if (x_pos <= x and x <= x_pos + x_off
                or x_pos >= x and x >= x_pos + x_off)
            and (y_pos <= y and y <= y_pos + y_off
                or y_pos >= y and y >= y_pos + y_off) then
                dragged_text = {t, x - x_pos, y - y_pos}
                return true
            end
        end

    elseif type == 0x202 then
        if dragged_text then
            if dragged_text[1]._root_settings then
                config.save(dragged_text[1]._root_settings)
            end
            dragged_text = nil
            return true
        end
    end

    return false
end

register_event('unload', destroy_texts)
register_event('mouse', handle_mouse)

return texts
