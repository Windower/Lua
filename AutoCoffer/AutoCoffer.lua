_addon.name     = 'AutoCoffer'
_addon.author   = 'Aragan'
_addon.version  = '8.4'
_addon.commands = {'autocoffer', 'acof'}

----------------------------------------------------------
-- Libraries
----------------------------------------------------------
require('logger')
require('tables')
require('strings')   -- For supporting strip_format()
res    = require('resources')
config = require('config')

----------------------------------------------------------
-- Settings
----------------------------------------------------------
local defaults = {
    delay_offset = 0,   -- Additional delay above (cast_time + 2)
    max_uses     = 0,   -- 0 = Use all available items
    debug        = true,
    ignore       = {},  -- Normalized lowercase keys
}

local settings = config.load(defaults)
settings.ignore = settings.ignore or {}

----------------------------------------------------------
-- Runtime State
----------------------------------------------------------
state = state or {}
state.AutoCofferMode = state.AutoCofferMode or { value = true }

----------------------------------------------------------
-- Internal Tables
-- inverted_box[lower_name] = { id, cast, name }
----------------------------------------------------------
local inverted_box = {}

----------------------------------------------------------
-- Current AutoCoffer State Variables
----------------------------------------------------------
local active = {
    running = false,
    name    = nil,
    id      = nil,
    count   = 0,
    delay   = 2,
}

----------------------------------------------------------
-- General Helper Functions
----------------------------------------------------------
local function is_enabled()
    return state.AutoCofferMode.value
end

local function log_chat(msg)
    windower.add_to_chat(207, '[AutoCoffer] ' .. msg)
end

local function debug_print(msg)
    if settings.debug then
        windower.add_to_chat(207, '[AutoCoffer-DEBUG] ' .. msg)
    end
end

local function trim(s)
    if not s then return s end
    return s:match('^%s*(.-)%s*$')
end

-- Normalize the name: Remove colors, auto-translation, spaces, surrounding quotes, and convert to lowercase
local function normalize_key(name)
    if not name then return '' end
    local clean = windower.convert_auto_trans(name) or name
    clean = clean:strip_format()
    clean = trim(clean)
    -- Remove surrounding quotes if present
    clean = clean:gsub('^"(.-)"$', '%1')
    clean = clean:gsub("^'(.-)'$", "%1")
    clean = trim(clean)
    return clean:lower()
end

-- Check if the name is a box-type item (Coffer / Pouch / Sack / Case / Box / Parcel / Codex)
local function name_is_box_item(name)
    if not name then return false end
    local lower = name:lower()
    return  lower:find('coffer')
        or lower:find('pouch')
        or lower:find('sack')
        or lower:find('case')
        or lower:find('box')
        or lower:find('parcel')
        or lower:find('codex')
end

-- Check if norm_key exists in the ignore list
local function is_ignored_box(norm_key)
    if not norm_key or norm_key == '' then return false end
    return settings.ignore[norm_key] == true
end

----------------------------------------------------------
-- Build inverted_box table from res.items
----------------------------------------------------------
local function build_inverted_box()
    inverted_box = {}
    local count = 0

    for id, v in pairs(res.items) do
        local candidates = {
            v.english,
            v.en,
            v.enl,
            v.log_name,
            v.log_name_plural,
        }

        local cast_time = v.cast_time or 0

        for _, nm in ipairs(candidates) do
            if nm and name_is_box_item(nm) then
                local lower = nm:lower()
                if not inverted_box[lower] then
                    inverted_box[lower] = {
                        id   = id,
                        cast = cast_time,
                        name = nm,
                    }
                    count = count + 1
                end
            end
        end
    end

    debug_print('inverted_box built with ' .. tostring(count) .. ' box-like entries.')
end

----------------------------------------------------------
-- Map chat name to resources name
----------------------------------------------------------
local function resolve_box_from_name(chat_name)
    if not chat_name or chat_name == '' then
        return nil
    end

    local clean = windower.convert_auto_trans(chat_name) or chat_name
    clean = clean:strip_format()
    clean = trim(clean)
    if clean == '' then
        return nil
    end

    local key = clean:lower()

    -- 1) Exact match
    if inverted_box[key] then
        debug_print(('resolve_box_from_name: exact match "%s" → "%s"'):format(key, inverted_box[key].name))
        return inverted_box[key]
    end

    -- 2) Partial match
    local best
    local best_len = 0
    for k, rec in pairs(inverted_box) do
        if k:find(key, 1, true) or key:find(k, 1, true) then
            local len = #k
            if len > best_len then
                best_len = len
                best = rec
            end
        end
    end

    if best then
        debug_print(('resolve_box_from_name: partial match "%s" → "%s"'):format(key, best.name))
        return best
    end

    debug_print(('resolve_box_from_name: no match for "%s"'):format(key))
    return nil
end

----------------------------------------------------------
-- Loop: Use /item "<name>" <me> for count times
----------------------------------------------------------
local function use_active_item()
    if not is_enabled() then
        active.running = false
        return
    end

    if not active.running or not active.name or active.count <= 0 then
        debug_print('use_active_item: stop. running=' .. tostring(active.running)
            .. ' name=' .. tostring(active.name)
            .. ' count=' .. tostring(active.count))
        active.running = false
        return
    end

    debug_print('Using item: ' .. active.name .. ' (remaining: ' .. tostring(active.count) .. ')')
    windower.chat.input('/item "' .. active.name .. '" <me>')
    active.count = active.count - 1

    if active.count > 0 and windower.ffxi.get_player().status == 0 then
        use_active_item:schedule(active.delay)
    else
        debug_print('Finished using "' .. tostring(active.name) .. '".')
        active.running = false
    end
end

----------------------------------------------------------
-- Start auto-use from chat line
----------------------------------------------------------
local function start_from_chat_box(chat_name)
    local rec = resolve_box_from_name(chat_name)
    if not rec then
        log_chat('Box item "' .. chat_name .. '" does not exist in resources (for AutoCoffer).')
        return
    end

    local inv = windower.ffxi.get_items(0)
    if not inv then
        log_chat('Cannot read main inventory.')
        return
    end

    local count = 0
    for _, v in ipairs(inv) do
        if v.id == rec.id then
            count = count + v.count
        end
    end

    if count <= 0 then
        log_chat('Item "' .. rec.name .. '" not found in main inventory.')
        return
    end

    if settings.max_uses and settings.max_uses > 0 and count > settings.max_uses then
        debug_print('Clamping count from ' .. tostring(count) .. ' to max_uses=' .. tostring(settings.max_uses))
        count = settings.max_uses
    end

    active.name  = rec.name
    active.id    = rec.id
    active.count = count

    local base_delay = (rec.cast or 0) + 2
    local extra      = tonumber(settings.delay_offset) or 0
    if extra < 0 then extra = 0 end
    active.delay = base_delay + extra
    if active.delay < 1 then active.delay = 1 end

    active.running = true

    log_chat('Found ' .. tostring(active.count) .. ' "' .. active.name .. '". Commencing auto-use (Pouches-style) after ' .. tostring(active.delay) .. 's.')
    log_chat('You may simply type /heal or use another box to interrupt naturally.')

    use_active_item:schedule(active.delay)
end

----------------------------------------------------------
-- Capture chat text
----------------------------------------------------------
windower.register_event('incoming text', function(original, modified, original_mode, modified_mode, blocked)
    if not original or original == '' then
        return
    end

    local text  = original
    local lower = text:lower()

    -- Ignore messages from the addon itself to prevent loops
    if text:find('%[AutoCoffer') then
        return
    end

    if not is_enabled() then
        return
    end

    if active.running then
        return
    end

    if not (lower:find(' uses ') or lower:find('you use ') or lower:find('you open ')) then
        return
    end

    debug_print('Incoming line: ' .. text)

    local item_name =
        text:match('uses a ([^%.]+)%.')     or
        text:match('uses an ([^%.]+)%.')    or
        text:match('uses the ([^%.]+)%.')   or
        text:match('You use a ([^%.]+)%.')  or
        text:match('You use an ([^%.]+)%.') or
        text:match('You use the ([^%.]+)%.') or
        text:match('You open the ([^%.]+)%.') or
        text:match('You open a ([^%.]+)%.')   or
        text:match('You open an ([^%.]+)%.')

    if not item_name then
        local clean = windower.convert_auto_trans(text) or text
        clean = clean:strip_format()
        item_name =
            clean:match('uses a ([^%.]+)%.')     or
            clean:match('uses an ([^%.]+)%.')    or
            clean:match('uses the ([^%.]+)%.')   or
            clean:match('You use a ([^%.]+)%.')  or
            clean:match('You use an ([^%.]+)%.') or
            clean:match('You use the ([^%.]+)%.') or
            clean:match('You open the ([^%.]+)%.') or
            clean:match('You open a ([^%.]+)%.')   or
            clean:match('You open an ([^%.]+)%.')
    end

    if not item_name then
        return
    end

    item_name = item_name:strip_format()
    item_name = trim(item_name)

    if not item_name or item_name == '' then
        return
    end

    -- Ignore placeholder/help text like "<Coffer/Sack/Pouch/...>"
    if item_name:find('[<>/]') then
        debug_print('Item_name "' .. item_name .. '" looks like placeholder/help text. Ignoring.')
        return
    end

    debug_print('Extracted item_name: ' .. item_name)

    if not name_is_box_item(item_name) then
        debug_print('Item "' .. item_name .. '" is not box-type. Ignoring.')
        return
    end

    local norm_key = normalize_key(item_name)
    if is_ignored_box(norm_key) then
        debug_print('Item "' .. item_name .. '" is in ignore list (key="' .. norm_key .. '"). Skipping auto-use.')
        return
    end

    start_from_chat_box(item_name)
end)

----------------------------------------------------------
-- Addon Commands
----------------------------------------------------------
windower.register_event('addon command', function(command, ...)
    local args = {...}
    command = command and command:lower() or ''

    if command == '' or command == 'status' then
        log_chat('Status: ' .. (is_enabled() and 'ON' or 'OFF')
            .. ' | DelayOffset: ' .. tostring(settings.delay_offset)
            .. ' | MaxUses: ' .. tostring(settings.max_uses)
            .. ' | Debug: ' .. (settings.debug and 'ON' or 'OFF'))
        if active.name then
            log_chat('Current/Last box: "' .. active.name .. '" (running=' .. tostring(active.running)
                .. ', count=' .. tostring(active.count) .. ', delay=' .. tostring(active.delay) .. 's)')
        end
        local c = 0
        for _ in pairs(settings.ignore) do c = c + 1 end
        log_chat('Ignore list count: ' .. tostring(c))
        return
    end

    if command == 'on' then
        state.AutoCofferMode.value = true
        log_chat('Enabled.')
        return
    end

    if command == 'off' then
        state.AutoCofferMode.value = false
        log_chat('Disabled.')
        return
    end

    if command == 'toggle' or command == 't' then
        state.AutoCofferMode.value = not state.AutoCofferMode.value
        log_chat('Toggled: ' .. (is_enabled() and 'ON' or 'OFF'))
        return
    end

    if command == 'delay' or command == 'delayoffset' then
        local val = tonumber(args[1])
        if not val then
            log_chat('Usage: //autocoffer delay <seconds offset>')
            return
        end
        if val < 0 then val = 0 end
        settings.delay_offset = val
        config.save(settings)
        log_chat('Delay offset set to ' .. tostring(val) .. ' seconds (final delay = cast_time + 2 + offset).')
        return
    end

    if command == 'max' or command == 'maxuses' then
        local val = tonumber(args[1])
        if not val or val < 0 then
            log_chat('Usage: //autocoffer max <count>  (0 = no limit, use all)')
            return
        end
        settings.max_uses = val
        config.save(settings)
        log_chat('Max uses set to ' .. tostring(val) .. ' (0 = no limit).')
        return
    end

    if command == 'debug' then
        settings.debug = not settings.debug
        config.save(settings)
        log_chat('Debug: ' .. (settings.debug and 'ON' or 'OFF'))
        return
    end

    if command == 'stop' then
        active.running = false
        active.count   = 0
        log_chat('Stopped current auto-use loop.')
        return
    end

    --------------------------------------------------
    -- Ignore Commands
    --------------------------------------------------
    if command == 'ignore' then
        local sub = args[1] and args[1]:lower() or ''

        if sub == 'add' then
            table.remove(args, 1)
            local name = table.concat(args, ' ')
            name = trim(name)
            if name == '' then
                log_chat('Usage: //autocoffer ignore add <item name>')
                return
            end
            local key = normalize_key(name)
            settings.ignore[key] = true
            config.save(settings)
            log_chat('Added "' .. name .. '" to ignore list (key="' .. key .. '").')
            return

        elseif sub == 'remove' or sub == 'del' or sub == 'rm' then
            table.remove(args, 1)
            local name = table.concat(args, ' ')
            name = trim(name)
            if name == '' then
                log_chat('Usage: //autocoffer ignore remove <item name>')
                return
            end
            local key = normalize_key(name)
            if settings.ignore[key] then
                settings.ignore[key] = nil
                config.save(settings)
                log_chat('Removed "' .. name .. '" from ignore list (key="' .. key .. '").')
            else
                log_chat('"' .. name .. '" is not in ignore list (key="' .. key .. '").')
            end
            return

        elseif sub == 'list' or sub == '' then
            log_chat('Ignore list items (normalized keys):')
            local c = 0
            for k, v in pairs(settings.ignore) do
                if v then
                    c = c + 1
                    log_chat('  - ' .. k)
                end
            end
            if c == 0 then
                log_chat('  (empty)')
            end
            return

        else
            log_chat('Usage: //autocoffer ignore [add|remove|list] <item name>')
            return
        end
    end

    if command == 'help' then
        log_chat('Commands:')
        log_chat('//autocoffer                    → Show status')
        log_chat('//autocoffer on                 → Enable auto mode')
        log_chat('//autocoffer off                → Disable auto mode')
        log_chat('//autocoffer toggle             → Toggle on/off')
        log_chat('//autocoffer delay X            → Set extra delay offset (seconds) after cast_time+2')
        log_chat('//autocoffer max N              → Set max uses per box (0 = no limit, use all inventory count)')
        log_chat('//autocoffer debug              → Toggle debug messages')
        log_chat('//autocoffer stop               → Stop current auto-use loop')
        log_chat('//autocoffer ignore add "<name>"    → Add box name (any form) to ignore list')
        log_chat('//autocoffer ignore remove "<name>" → Remove box name from ignore list')
        log_chat('//autocoffer ignore list             → Show all ignored names (normalized)')
        log_chat('Behavior: When chat shows "Aragan uses a <Coffer/Sack/Pouch/...>",')
        log_chat('AutoCoffer resolves it via resources, counts inventory like Pouches,')
        log_chat('and auto-/item it that many times (respecting MaxUses and Ignore list).')
        return
    end

    log_chat('Unknown command. Use "//autocoffer help".')
end)

----------------------------------------------------------
-- On Load
----------------------------------------------------------
windower.register_event('load', function()
    build_inverted_box()
    log_chat('Loaded v8.4. Watching "uses / You use / You open" lines for box-type items with ignore list + Pouches-style counting (no debug spam).')
end)