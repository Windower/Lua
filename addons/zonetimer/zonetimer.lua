--[[
Copyright (c) 2013, Ihina
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of zonetimer nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL IHINA BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'zonetimer'
_addon.author = 'Ihina'
_addon.version = '2.0.0.0'
_addon.commands = {'zonetimer', 'zt'}

local config = require('config')
local texts = require('texts')
local res = require('resources')
local files = require('files')
local xml = require('xml')
require('lists')

-- Defaults and runtime state
local defaults = {}
defaults.pos = {}
defaults.pos.x = 400
defaults.pos.y = 0
defaults.text = {}
defaults.text.font = 'Arial'
defaults.text.size = 12
defaults.text.fonts = L{}
defaults.text.red = 255
defaults.text.green = 255
defaults.text.blue = 255
defaults.text.alpha = 255
defaults.text.stroke = {width = 1, red = 0, green = 0, blue = 0, alpha = 255}
defaults.flags = {bold = false, draggable = true, italic = false, right = false, bottom = false}
defaults.padding = 0
defaults.bg = {}
defaults.bg.visible = true
defaults.bg.red = 0
defaults.bg.green = 0
defaults.bg.blue = 0
defaults.bg.alpha = 255
defaults.visible = true
defaults.fade_enabled = true
defaults.reminder_interval = 0
-- The zone record is internal state, not a user-facing setting.
defaults.zone_state = {zone_id = 0, entered_at = 0, character = '', server = 0, resume_at = 0}

local shared_defaults = table.copy(defaults)
local legacy_characters = {}
local settings = table.copy(defaults)
local character_settings
local active_character
local character_files = {}
local pending_resume = false
local in_event = false
local zoning = false
local timer
local zone_id = 0
local entered_at = 0
local next_reminder
local last_displayed
local running = false
local tick_task
local display_task
local fade_event
local mouse_release_event
local drag_reminder = false
local fade_to
local fade_opacity = 1
local temporary_display = false
local temporary_reminder = false
local FADE_SECONDS = 1
local REMINDER_SECONDS = 10
local PREVIEW_SECONDS = 3
local RESUME_SECONDS = 300
local CHAT_COLOR = 207
local CHAT_WHITE = string.char(0x1F, 1)
local CHAT_BLUE = string.char(0x1F, 207)
local CHAT_GREEN = string.char(0x1F, 158)
local CHAT_YELLOW = string.char(0x1F, 159)

-- Configuration: read shared defaults; write only the active character file.
local function read_xml_values(node)
    local result = {}
    local text
    for _, child in ipairs(node.children) do
        if child.type == 'tag' then
            result[child.name:lower()] = read_xml_values(child)
        elseif child.type == 'text' then
            text = child.value
        end
    end
    if next(result) then return result end
    if text and text:lower() == 'true' then return true end
    if text and text:lower() == 'false' then return false end
    return tonumber(text) or text or ''
end

local function font_list(value)
    if type(value) == 'table' then
        return L(table.copy(value))
    end
    local result = L{}
    if type(value) == 'string' then
        -- Windower stores fallback font lists as CSV, including quoted names.
        local item, quoted, index = '', false, 1
        while index <= #value do
            local char = value:sub(index, index)
            if char == '"' then
                if quoted and value:sub(index + 1, index + 1) == '"' then
                    item = item .. '"'
                    index = index + 1
                else
                    quoted = not quoted
                end
            elseif char == ',' and not quoted then
                local name = item:match('^%s*(.-)%s*$')
                if name ~= '' then result:append(name) end
                item = ''
            else
                item = item .. char
            end
            index = index + 1
        end
        local name = item:match('^%s*(.-)%s*$')
        if name ~= '' then result:append(name) end
    end
    return result
end

local function apply_values(target, source)
    for key, value in pairs(source or {}) do
        if key == 'fonts' then
            target[key] = font_list(value)
        elseif type(value) == 'table' and type(target[key]) == 'table'
            and class(target[key]) ~= 'List' then
            apply_values(target[key], value)
        elseif value ~= '' or type(target[key]) ~= 'table' then
            target[key] = value
        end
    end
end

local function read_shared_settings()
    local path = 'data/settings.xml'
    local file = files.new(path)
    if not file:exists() then
        local global_defaults = table.copy(defaults)
        global_defaults.zone_state = nil
        config.load(path, global_defaults)
    end
    local root, err = xml.read(file)
    if not root or root.name ~= 'settings' then
        error('ZoneTimer: Could not read settings.xml: ' .. (err or 'Invalid root element.'))
    end
    for _, section in ipairs(root.children) do
        if section.type == 'tag' then
            local values = read_xml_values(section)
            if type(values) ~= 'table' then values = {} end
            if section.name:lower() == 'global' then
                values.zone_state = nil
                apply_values(shared_defaults, values)
            else
                legacy_characters[section.name:lower()] = values
            end
        end
    end
    settings = table.copy(shared_defaults)
end

local function load_character(player)
    local name = player.name:lower()
    local stored = character_files[name]
    if not stored then
        local path = 'data/' .. name .. '.xml'
        local migrate = not files.new(path):exists() and legacy_characters[name]
        stored = config.load(path, {overrides = {}, zone_state = table.copy(defaults.zone_state)})
        if migrate then
            -- Import once without rewriting the shared file.
            local previous = legacy_characters[name]
            stored.overrides = table.copy(previous)
            stored.overrides.zone_state = nil
            if type(previous.zone_state) == 'table' then
                apply_values(stored.zone_state, previous.zone_state)
            end
            config.save(stored, 'all')
        end
        -- config retains every loaded table; reuse it when this character returns.
        character_files[name] = stored
        legacy_characters[name] = nil
    end
    character_settings = stored
    active_character = name
    settings = table.copy(shared_defaults)
    apply_values(settings, stored.overrides)
    settings.zone_state = table.copy(defaults.zone_state)
    apply_values(settings.zone_state, stored.zone_state)
end

local function save_settings(changes)
    if character_settings then
        -- Commands supply only the preferences they explicitly set. Unrelated
        -- preferences keep inheriting shared defaults, even after zone saves.
        apply_values(character_settings.overrides, changes)
        character_settings.zone_state = table.copy(settings.zone_state)
        config.save(character_settings, 'all')
    end
end

-- Timer text and chat output
local function chat(message)
    if windower.ffxi.get_info().logged_in then
        windower.add_to_chat(CHAT_COLOR, message)
    end
end

local function elapsed_seconds()
    return math.max(0, os.time() - entered_at)
end

local function format_time(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor(seconds / 60) % 60
    return ('%02d:%02d:%02d'):format(hours, minutes, seconds % 60)
end

local function zone_name()
    local zone = res.zones[zone_id]
    return zone and zone.name or ('Zone %d'):format(zone_id)
end

local function zone_message()
    return CHAT_BLUE .. '[Zone timer]' .. CHAT_WHITE .. ' You have currently been in ' .. CHAT_GREEN
        .. zone_name() .. CHAT_WHITE .. ' for ' .. CHAT_YELLOW .. format_time(elapsed_seconds()) .. CHAT_WHITE
end

local function update_text()
    if timer and zone_id ~= 0 then
        local elapsed = elapsed_seconds()
        if elapsed ~= last_displayed then
            timer:text(format_time(elapsed))
            last_displayed = elapsed
        end
    end
end

-- Visibility: one fade event and at most one temporary-display timeout.
local function set_opacity(opacity)
    fade_opacity = opacity
    timer:alpha(math.floor(settings.text.alpha * opacity + 0.5))
    timer:stroke_alpha(math.floor(settings.text.stroke.alpha * opacity + 0.5))
    timer:bg_alpha(math.floor(settings.bg.alpha * opacity + 0.5))
end

local function cancel_transition()
    if display_task then
        coroutine.close(display_task)
        display_task = nil
    end
    temporary_display = false
    temporary_reminder = false
    drag_reminder = false
    if fade_event then
        windower.unregister_event(fade_event)
        fade_event = nil
    end
    if mouse_release_event then
        windower.unregister_event(mouse_release_event)
        mouse_release_event = nil
        -- A zone change or unload can interrupt a drag before mouse release.
        save_settings({pos = {x = settings.pos.x, y = settings.pos.y}})
    end
end

local function stop_fade()
    cancel_transition()
    if timer then
        set_opacity(1)
        timer:visible(settings.visible and zone_id ~= 0 and not in_event and not zoning)
    end
end

local function fade_to_opacity(target, after)
    if fade_event then
        windower.unregister_event(fade_event)
        fade_event = nil
    end
    if not settings.fade_enabled then
        set_opacity(target)
        if after then
            after()
        end
        return
    end
    local started = os.clock()
    local from = fade_opacity
    fade_to = target
    fade_event = windower.register_event('prerender', function()
        local progress = math.min(1, (os.clock() - started) / FADE_SECONDS)
        set_opacity(from + (target - from) * progress)
        if progress >= 1 then
            windower.unregister_event(fade_event)
            fade_event = nil
            if after then
                after()
            end
        end
    end)
end

local function fade_visibility(visible)
    visible = visible and not in_event and not zoning
    cancel_transition()
    if zone_id == 0 then
        set_opacity(1)
        timer:hide()
    elseif visible then
        update_text()
        if not timer:visible() then
            set_opacity(0)
            timer:show()
        end
        if fade_opacity < 1 then
            fade_to_opacity(1)
        end
    elseif timer:visible() then
        if fade_opacity > 0 then
            fade_to_opacity(0, function()
                timer:hide()
                set_opacity(1)
            end)
        else
            timer:hide()
            set_opacity(1)
        end
    end
end

local function show_temporarily(duration, reminder)
    if settings.visible or zone_id == 0 or in_event or zoning or (temporary_reminder and not reminder) then
        return
    end
    if mouse_release_event then
        drag_reminder = drag_reminder or reminder == true
        return
    end
    temporary_display = true
    temporary_reminder = reminder == true
    if display_task then
        coroutine.close(display_task)
        display_task = nil
    end
    update_text()
    if not timer:visible() then
        timer:show()
        set_opacity(0)
        fade_to_opacity(1)
    elseif fade_event and fade_to == 0 then
        -- Reverse an outgoing fade without blinking on repeated changes.
        fade_to_opacity(1)
    end
    display_task = coroutine.schedule(function()
        display_task = nil
        fade_to_opacity(0, function()
            timer:hide()
            set_opacity(1)
            temporary_display = false
            temporary_reminder = false
        end)
    end, duration - (settings.fade_enabled and FADE_SECONDS or 0))
end

local function save_appearance(changes)
    save_settings(changes)
    show_temporarily(PREVIEW_SECONDS)
end

local function schedule_reminder()
    local interval = tonumber(settings.reminder_interval) or 0
    next_reminder = nil
    if interval > 0 and zone_id ~= 0 then
        local period = interval * 60
        next_reminder = (math.floor(elapsed_seconds() / period) + 1) * period
    end
end

local function apply_display_settings()
    timer:pos(settings.pos.x, settings.pos.y)
    timer:font(settings.text.font, unpack(settings.text.fonts))
    timer:size(settings.text.size)
    timer:pad(settings.padding)
    timer:stroke_width(settings.text.stroke.width)
    timer:stroke_color(settings.text.stroke.red, settings.text.stroke.green, settings.text.stroke.blue)
    timer:italic(settings.flags.italic == true)
    timer:right_justified(settings.flags.right == true)
    timer:bold(settings.flags.bold)
    timer:draggable(settings.flags.draggable)
    timer:bg_visible(settings.bg.visible)
    timer:color(settings.text.red, settings.text.green, settings.text.blue)
    timer:bg_color(settings.bg.red, settings.bg.green, settings.bg.blue)
    set_opacity(fade_opacity)
end

-- Zone lifecycle and the single once-per-second scheduler
local function save_zone(zone)
    local player = windower.ffxi.get_player()
    local info = windower.ffxi.get_info()
    settings.zone_state.zone_id = zone
    settings.zone_state.entered_at = entered_at
    settings.zone_state.character = player and player.name or ''
    settings.zone_state.server = info.server or 0
    settings.zone_state.resume_at = 0
    save_settings()
end

local function start_zone(zone, fade_in)
    stop_fade()
    zone_id = zone
    entered_at = os.time()
    last_displayed = nil
    save_zone(zone)
    schedule_reminder()
    update_text()
    if fade_in and not zoning and settings.visible and not in_event then
        timer:hide()
        fade_visibility(true)
    else
        timer:visible(settings.visible and zone ~= 0 and not in_event and not zoning)
    end
end

local function clear_zone()
    stop_fade()
    zone_id = 0
    entered_at = 0
    next_reminder = nil
    last_displayed = nil
    settings.zone_state = table.copy(defaults.zone_state)
    save_settings()
    in_event = false
    zoning = false
    timer:hide()
end

local function restore_zone(info, player)
    local saved = settings.zone_state
    local now = os.time()
    local valid = saved.zone_id == info.zone
        and saved.character == player.name
        and saved.server == (info.server or 0)
        and saved.entered_at > 0 and saved.entered_at <= now
        and saved.resume_at > 0 and saved.resume_at <= now
        and now - saved.resume_at <= RESUME_SECONDS

    if valid then
        zone_id = info.zone
        entered_at = saved.entered_at
        schedule_reminder()
        update_text()
        timer:visible(settings.visible and not in_event)
        saved.resume_at = 0
        save_settings()
    else
        start_zone(info.zone)
    end
end

local function activate_player(player, info, resume)
    if active_character ~= player.name:lower() then
        if zone_id ~= 0 then clear_zone() end
        if player.status ~= nil then in_event = player.status == 4 end
        load_character(player)
        stop_fade()
        apply_display_settings()
    end
    if info.zone ~= 0 then
        if resume then
            restore_zone(info, player)
        else
            start_zone(info.zone)
        end
        pending_resume = false
    end
end

local function tick()
    tick_task = nil
    if not running then
        return
    end
    local info = windower.ffxi.get_info()
    if not info.logged_in then
        if zone_id ~= 0 then
            clear_zone()
        end
    else
        local player = windower.ffxi.get_player()
        if player and (active_character ~= player.name:lower() or zone_id == 0) then
            activate_player(player, info, pending_resume)
        elseif player and info.zone ~= 0 and info.zone ~= zone_id then
            start_zone(info.zone, true)
        end
        if player and zone_id ~= 0 then
            if timer:visible() then
                update_text()
            end
            if next_reminder and elapsed_seconds() >= next_reminder then
                chat(zone_message())
                show_temporarily(REMINDER_SECONDS, true)
                schedule_reminder()
            end
        end
    end
    tick_task = coroutine.schedule(tick, 1)
end

-- Dragging and Windower event entry points
local function on_drag(_, x, y)
    settings.pos.x = x
    settings.pos.y = y
    if not mouse_release_event then
        if not settings.visible and zone_id ~= 0 then
            local was_reminder = temporary_reminder
            cancel_transition()
            drag_reminder = was_reminder
            set_opacity(1)
        end
        mouse_release_event = windower.register_event('mouse', function(event_type)
            if event_type == 2 then
                windower.unregister_event(mouse_release_event)
                mouse_release_event = nil
                save_settings({pos = {x = settings.pos.x, y = settings.pos.y}})
                local reminder = drag_reminder
                drag_reminder = false
                if running and not settings.visible and zone_id ~= 0 then
                    show_temporarily(reminder and REMINDER_SECONDS or PREVIEW_SECONDS, reminder)
                end
            end
        end)
    end
end

local function on_load()
    read_shared_settings()
    -- Keep temporary fade alpha separate from persistent user settings.
    local display_settings = table.copy(settings)
    setmetatable(display_settings, nil)
    timer = texts.new(display_settings)
    timer:register_event('drag', on_drag)

    local info = windower.ffxi.get_info()
    local player = windower.ffxi.get_player()
    -- Preserve reload eligibility until both the player and zone are available.
    pending_resume = info.logged_in
    if info.logged_in and player then
        activate_player(player, info, pending_resume)
    else
        timer:hide()
    end
    running = true
    tick_task = coroutine.schedule(tick, 1)
end

windower.register_event('load', on_load)
windower.register_event('login', function()
    local info = windower.ffxi.get_info()
    local player = windower.ffxi.get_player()
    pending_resume = false
    if player then
        activate_player(player, info, false)
    else
        clear_zone()
    end
end)

windower.register_event('logout', function()
    clear_zone()
    -- The character's file is saved even after LuaCore marks logout complete.
    character_settings = nil
    active_character = nil
    settings = table.copy(shared_defaults)
    pending_resume = false
end)

windower.register_event('status change', function(status)
    if in_event ~= (status == 4) then
        in_event = status == 4
        if timer then fade_visibility(settings.visible) end
    end
end)

-- Event status does not identify every zoning transition.
windower.register_event('incoming chunk', function(id, data, _, injected, blocked)
    if injected or blocked or not running then return end
    if id == 0x00B and zone_id ~= 0 then
        zoning = true
        fade_visibility(false)
    elseif id == 0x00A and zoning then
        local low, high = data:byte(0x31, 0x32)
        local zone = low + 256 * high
        if zone ~= zone_id then start_zone(zone) end
        zoning = false
        in_event = data:byte(0x20) == 4 -- Zone-in status at offset 0x1F.
        fade_visibility(settings.visible)
    end
end)

windower.register_event('zone change', function(new_zone)
    local player = windower.ffxi.get_player()
    if windower.ffxi.get_info().logged_in and player and not pending_resume
        and active_character == player.name:lower() and new_zone ~= 0 and new_zone ~= zone_id then
        start_zone(new_zone, true)
    end
end)

windower.register_event('unload', function()
    running = false
    if tick_task then
        coroutine.close(tick_task)
        tick_task = nil
    end
    if zone_id ~= 0 and windower.ffxi.get_info().logged_in then
        settings.zone_state.resume_at = os.time()
        save_settings()
    end
    stop_fade()
    if timer then
        timer:destroy()
    end
end)

-- In-game commands
local function number_argument(value, min, max, whole)
    local number = tonumber(value)
    if number and number >= min and number <= max
        and (not whole or number == math.floor(number)) then return number end
end

windower.register_event('addon command', function(command, ...)
    local args = {...}
    command = command and command:lower() or ''

    if command == '' or command == 'time' or command == 't' then
        if zone_id ~= 0 then
            chat(zone_message())
        else
            chat('ZoneTimer: No active zone timer.')
        end
    elseif command == 'help' then
        chat('ZoneTimer: //zt [time|t], show, hide, fade <on|off>, reset, reminder <minutes|off>')
        chat('ZoneTimer: //zt posX <x>, posY <y>, fontsize <size>, font <name>, padding <0-100>')
        chat('ZoneTimer: //zt bg <show|hide>, stroke <width|off>, bold <on|off>, drag <on|off>')
        chat('ZoneTimer: //zt color <R G B>, bg_color <R G B>, alpha <0-255>, bg_alpha <0-255>')
        chat('ZoneTimer: //zt reminder (show current interval), //zt print (debug)')
    elseif command == 'show' or command == 'hide' then
        settings.visible = command == 'show'
        save_settings({visible = settings.visible})
        fade_visibility(settings.visible)
        chat('ZoneTimer: HUD ' .. (settings.visible and 'shown.' or 'hidden.'))
    elseif command == 'fade' then
        local mode = args[1] and args[1]:lower()
        if not mode then
            chat('ZoneTimer: Fade ' .. (settings.fade_enabled and 'on.' or 'off.'))
            return
        end
        if #args ~= 1 or (mode ~= 'on' and mode ~= 'off') then
            chat('ZoneTimer: Use fade <on|off>.')
            return
        end
        local enabled = mode == 'on'
        if settings.fade_enabled ~= enabled then
            local keep_reminder = temporary_reminder
            local keep_preview = temporary_display
            settings.fade_enabled = enabled
            if not mouse_release_event then
                stop_fade()
                if keep_preview then
                    show_temporarily(keep_reminder and REMINDER_SECONDS or PREVIEW_SECONDS, keep_reminder)
                end
            end
        end
        save_settings({fade_enabled = enabled})
        chat('ZoneTimer: Fade ' .. (settings.fade_enabled and 'on.' or 'off.'))
    elseif command == 'bg' or command == 'background' then
        local mode = args[1] and args[1]:lower()
        if mode == 'show' or mode == 'on' or mode == 'hide' or mode == 'off' then
            settings.bg.visible = mode == 'show' or mode == 'on'
            timer:bg_visible(settings.bg.visible)
            save_appearance({bg = {visible = settings.bg.visible}})
        elseif mode then
            chat('ZoneTimer: Use bg <show|hide>.')
            return
        end
        chat('ZoneTimer: Background ' .. (settings.bg.visible and 'shown.' or 'hidden.'))
    elseif command == 'color' or command == 'bg_color' then
        local is_background = command == 'bg_color'
        local target = is_background and settings.bg or settings.text
        local label = is_background and 'Background' or 'Text'
        if #args == 0 then
            chat(('ZoneTimer: %s RGB %d %d %d.'):format(label, target.red, target.green, target.blue))
            return
        end
        local red = number_argument(args[1], 0, 255, true)
        local green = number_argument(args[2], 0, 255, true)
        local blue = number_argument(args[3], 0, 255, true)
        if #args ~= 3 or not red or not green or not blue then
            chat(('ZoneTimer: Use %s <R G B> (each 0-255).'):format(command))
            return
        end
        target.red, target.green, target.blue = red, green, blue
        if is_background then
            timer:bg_color(red, green, blue)
        else
            timer:color(red, green, blue)
        end
        save_appearance({[is_background and 'bg' or 'text'] = {red = red, green = green, blue = blue}})
        chat(('ZoneTimer: %s RGB set to %d %d %d.'):format(label, red, green, blue))
    elseif command == 'alpha' or command == 'text_alpha' or command == 'bg_alpha' then
        local is_background = command == 'bg_alpha'
        local label = is_background and 'Background' or 'Text'
        local target = is_background and settings.bg or settings.text
        if #args == 0 then
            chat(('ZoneTimer: %s alpha %d.'):format(label, target.alpha))
            return
        end
        local alpha = number_argument(args[1], 0, 255, true)
        if #args ~= 1 or not alpha then
            chat(('ZoneTimer: Use %s <0-255>.'):format(command))
            return
        end
        target.alpha = alpha
        set_opacity(fade_opacity)
        save_appearance({[is_background and 'bg' or 'text'] = {alpha = alpha}})
        chat(('ZoneTimer: %s alpha set to %d.'):format(label, alpha))
    elseif command == 'stroke' then
        local value = args[1] and args[1]:lower()
        if not value then
            chat(('ZoneTimer: Stroke width %s.'):format(settings.text.stroke.width))
            return
        end
        local width = value == 'off' and 0 or value == 'on' and 1
            or number_argument(value, 0, 10, false)
        if not width then
            chat('ZoneTimer: Use stroke <width 0-10|on|off>.')
            return
        end
        settings.text.stroke.width = width
        timer:stroke_width(width)
        save_appearance({text = {stroke = {width = width}}})
        chat(('ZoneTimer: Stroke width set to %s.'):format(width))
    elseif command == 'bold' or command == 'drag' then
        local option = args[1] and args[1]:lower()
        local key = command == 'bold' and 'bold' or 'draggable'
        if option and option ~= 'on' and option ~= 'off' then
            chat(('ZoneTimer: Use %s <on|off>.'):format(command))
            return
        end
        if option then
            settings.flags[key] = option == 'on'
            if command == 'bold' then
                timer:bold(settings.flags.bold)
            else
                timer:draggable(settings.flags.draggable)
            end
            save_appearance({flags = {[key] = settings.flags[key]}})
        end
        chat(('ZoneTimer: %s %s.'):format(command, settings.flags[key] and 'on' or 'off'))
    elseif command == 'reminder' then
        local value = args[1] and args[1]:lower()
        if not value then
            chat(('ZoneTimer: Reminders %s.'):format(settings.reminder_interval == 0
                and 'disabled' or ('every %d minute(s)'):format(settings.reminder_interval)))
        elseif value == 'off' or value == '0' then
            settings.reminder_interval = 0
            save_settings({reminder_interval = 0})
            stop_fade()
            schedule_reminder()
            chat('ZoneTimer: Reminders disabled.')
        else
            local minutes = number_argument(value, 1, 1000000, true)
            if not minutes then
                chat('ZoneTimer: Use reminder <whole minutes|off> (minimum 1).')
                return
            end
            settings.reminder_interval = minutes
            save_settings({reminder_interval = minutes})
            schedule_reminder()
            chat(('ZoneTimer: Reminders every %d minute(s).'):format(minutes))
        end
    elseif command == 'reset' then
        if zone_id ~= 0 then
            start_zone(zone_id)
            chat('ZoneTimer: Timer reset.')
        else
            chat('ZoneTimer: No active zone timer.')
        end
    elseif command == 'posx' or command == 'posy' then
        local position = number_argument(args[1], -100000, 100000, true)
        if not position then
            chat(('ZoneTimer: Use %s <integer>.'):format(command))
            return
        end
        if command == 'posx' then
            settings.pos.x = position
            timer:pos_x(position)
        else
            settings.pos.y = position
            timer:pos_y(position)
        end
        save_appearance({pos = {[command == 'posx' and 'x' or 'y'] = position}})
        chat(('ZoneTimer: %s set to %d.'):format(command, position))
    elseif command == 'padding' or command == 'pad' then
        if not args[1] then
            chat(('ZoneTimer: Background padding %s.'):format(settings.padding))
            return
        end
        local padding = number_argument(args[1], 0, 100, true)
        if #args ~= 1 or not padding then
            chat('ZoneTimer: Use padding <integer 0-100>.')
            return
        end
        settings.padding = padding
        timer:pad(padding)
        save_appearance({padding = padding})
        chat(('ZoneTimer: Background padding set to %d.'):format(padding))
    elseif command == 'fontsize' then
        local size = number_argument(args[1], 1, 100, false)
        if not size then
            chat('ZoneTimer: Use fontsize <number> (1-100).')
            return
        end
        settings.text.size = size
        timer:size(size)
        save_appearance({text = {size = size}})
        chat(('ZoneTimer: Font size set to %s.'):format(size))
    elseif command == 'font' then
        local font = table.concat(args, ' '):gsub('^"(.-)"$', '%1')
        if font == '' then
            chat('ZoneTimer: Use font <font name>.')
            return
        end
        settings.text.font = font
        timer:font(font, unpack(settings.text.fonts))
        save_appearance({text = {font = font}})
        chat(('ZoneTimer: Font set to %s.'):format(font))
    elseif command == 'print' then
        print(entered_at .. ' ' .. os.time())
    else
        chat('ZoneTimer: Unknown command. Use //zt help.')
    end
end)
