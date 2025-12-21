_addon.name     = 'DoorHelper'
_addon.author   = 'Aragan'
_addon.version  = '1.6'
_addon.commands = {'doorhelper', 'dh'}

packets = require('packets')
config  = require('config')
local res   = require('resources')
local zones = res.zones

----------------------------------------------------------
-- Addon settings (saved via config)
-- auto_yes     : enable/disable Auto-Yes for menus
-- debug        : if true, prints Menu ID / NPC / Index
-- sortie_only  : if true, door logic runs only inside Sortie
----------------------------------------------------------
local settings = config.load({
    auto_yes    = true,
    debug       = false,
    sortie_only = true,  -- by default: only active in Sortie
})

----------------------------------------------------------
-- Internal state variables
----------------------------------------------------------
local last_menu_id       = 0      -- last Menu ID seen
local auto_busy          = false  -- guard to avoid double work in prerender
local last_door_id       = nil    -- last door ID we interacted with
local door_message_shown = false  -- avoid chat spam for the same door

----------------------------------------------------------
-- Simple debug print helper
----------------------------------------------------------
local function debug_print(msg)
    if settings.debug then
        windower.add_to_chat(207, '[DoorHelper-DEBUG] ' .. msg)
    end
end

----------------------------------------------------------
-- Check if the player is currently inside Sortie
----------------------------------------------------------
local function in_sortie()
    local info = windower.ffxi.get_info()
    local z = zones[info.zone]
    if z and z.en == 'Sortie' then
        return true
    end
    return false
end

----------------------------------------------------------
-- Distance helper between two mob objects
----------------------------------------------------------
local function get_distance(a, b)
    if not a or not b then
        return 999
    end
    return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

----------------------------------------------------------
-- Poke the target (simulate "interact" with NPC/door)
----------------------------------------------------------
local function poke(target)
    if not target then
        return
    end
    local p = packets.new('outgoing', 0x01A, {
        ["Target"]       = target.id,
        ["Target Index"] = target.index,
        ["Category"]     = 0,
        ["Param"]        = 0,
        ["_unknown1"]    = 0,
    })
    packets.inject(p)
end

----------------------------------------------------------
-- Old-style Yes selection using last_menu_id
-- (kept as a fallback)
----------------------------------------------------------
local function select_yes_old(target)
    if not target or last_menu_id == 0 then
        return
    end
    local zone = windower.ffxi.get_info().zone
    local p = packets.new('outgoing', 0x05B, {
        ["Target"]            = target.id,
        ["Target Index"]      = target.index,
        ["Option Index"]      = 1, -- Yes
        ["_unknown1"]         = 0,
        ["_unknown2"]         = 0,
        ["Automated Message"] = false,
        ["Zone"]              = zone,
        ["Menu ID"]           = last_menu_id,
    })
    packets.inject(p)
end

----------------------------------------------------------
-- General Auto-Yes for any menu using the incoming packet
-- This uses the fields from 0x034/0x032 directly
----------------------------------------------------------
local function auto_select_yes_from_menu(pkt)
    if not pkt then
        return
    end

    if not pkt['Menu ID'] or pkt['Menu ID'] == 0 then
        return
    end

    if not pkt['NPC'] or not pkt['NPC Index'] then
        return
    end

    local zone = windower.ffxi.get_info().zone

    local yes = packets.new('outgoing', 0x05B, {
        ["Target"]            = pkt['NPC'],
        ["Target Index"]      = pkt['NPC Index'],
        ["Option Index"]      = 1,                     -- assume Yes = 1
        ["_unknown1"]         = pkt['_unknown1'] or 0, -- copy same value for safety
        ["_unknown2"]         = 0,
        ["Automated Message"] = false,
        ["Zone"]              = zone,
        ["Menu ID"]           = pkt['Menu ID'],
    })

    packets.inject(yes)
    windower.add_to_chat(207,
        ('[DoorHelper] Auto-Yes sent (MenuID: %d).'):format(pkt['Menu ID']))
end

----------------------------------------------------------
-- SKIP EVENT helper
-- Sends ESC several times to try to close stuck menus/dialogs
----------------------------------------------------------
local function skip_event()
    windower.add_to_chat(207, '[DoorHelper] Trying to skip event (ESC spam)...')

    for i = 0, 2 do
        coroutine.schedule(function()
            windower.send_command('setkey escape down; wait 0.1; setkey escape up')
        end, i * 0.3)
    end
end

----------------------------------------------------------
-- Find the nearest door-like NPC around the player
-- Includes:
--   * Any NPC with "door" in its name
--   * Special case: Gilded Gateway (ID: 17084923)
----------------------------------------------------------
local function find_nearest_door()
    local player = windower.ffxi.get_mob_by_target('me')
    if not player then
        return nil
    end

    local mobs = windower.ffxi.get_mob_array()
    local nearest
    local min_dist = 3.2

    for _, mob in pairs(mobs) do
        if mob and mob.is_npc then
            local is_door = false

            -- Name contains "door" (case-insensitive)
            if mob.name and mob.name:lower():find('door', 1, true) then
                is_door = true
            end

            -- Special case: Gilded Gateway
            if mob.id == 17084923 then
                is_door = true
            end

            if is_door then
                local dist = get_distance(player, mob)
                if dist < min_dist then
                    nearest  = mob
                    min_dist = dist
                end
            end
        end
    end

    return nearest
end

----------------------------------------------------------
-- Addon commands:
--   //dh yes     [on|off|toggle|status]
--   //dh debug   [on|off|toggle|status]
--   //dh sortie  [on|off|toggle|status]
--   //dh skip
----------------------------------------------------------
windower.register_event('addon command', function(cmd, ...)
    cmd = cmd and cmd:lower() or ''
    local args = {...}

    if cmd == 'yes' then
        --------------------------------------------------
        -- Manage Auto-Yes mode
        --------------------------------------------------
        local sub = (args[1] or 'toggle'):lower()

        if sub == 'on' then
            settings.auto_yes = true
            config.save(settings)
            windower.add_to_chat(207, '[DoorHelper] Auto-Yes: ON')

        elseif sub == 'off' then
            settings.auto_yes = false
            windower.add_to_chat(207, '[DoorHelper] Auto-Yes: OFF')

        elseif sub == 'toggle' then
            settings.auto_yes = not settings.auto_yes
            config.save(settings)
            windower.add_to_chat(207,
                ('[DoorHelper] Auto-Yes toggled: %s'):format(settings.auto_yes and 'ON' or 'OFF'))

        elseif sub == 'status' then
            windower.add_to_chat(207,
                ('[DoorHelper] Auto-Yes status: %s'):format(settings.auto_yes and 'ON' or 'OFF'))
        else
            windower.add_to_chat(207,
                '[DoorHelper] Usage: //dh yes [on|off|toggle|status]')
        end

    elseif cmd == 'debug' then
        --------------------------------------------------
        -- Manage DEBUG mode
        --------------------------------------------------
        local sub = (args[1] or 'toggle'):lower()

        if sub == 'on' then
            settings.debug = true
            config.save(settings)
            windower.add_to_chat(207, '[DoorHelper] DEBUG: ON')

        elseif sub == 'off' then
            settings.debug = false
            windower.add_to_chat(207, '[DoorHelper] DEBUG: OFF')

        elseif sub == 'toggle' then
            settings.debug = not settings.debug
            config.save(settings)
            windower.add_to_chat(207,
                ('[DoorHelper] DEBUG toggled: %s'):format(settings.debug and 'ON' or 'OFF'))

        elseif sub == 'status' then
            windower.add_to_chat(207,
                ('[DoorHelper] DEBUG status: %s'):format(settings.debug and 'ON' or 'OFF'))
        else
            windower.add_to_chat(207,
                '[DoorHelper] Usage: //dh debug [on|off|toggle|status]')
        end

    elseif cmd == 'sortie' then
        --------------------------------------------------
        -- Restrict door logic to Sortie only or allow all zones
        --------------------------------------------------
        local sub = (args[1] or 'toggle'):lower()

        if sub == 'on' then
            settings.sortie_only = true
            config.save(settings)
            windower.add_to_chat(207, '[DoorHelper] Sortie-Only Mode: ON')

        elseif sub == 'off' then
            settings.sortie_only = false
            config.save(settings)
            windower.add_to_chat(207, '[DoorHelper] Sortie-Only Mode: OFF')

        elseif sub == 'toggle' then
            settings.sortie_only = not settings.sortie_only
            config.save(settings)
            windower.add_to_chat(207,
                ('[DoorHelper] Sortie-Only toggled: %s'):format(settings.sortie_only and 'ON' or 'OFF'))

        elseif sub == 'status' then
            windower.add_to_chat(207,
                ('[DoorHelper] Sortie-Only status: %s'):format(settings.sortie_only and 'ON' or 'OFF'))
        else
            windower.add_to_chat(207,
                '[DoorHelper] Usage: //dh sortie [on|off|toggle|status]')
        end

    elseif cmd == 'skip' then
        --------------------------------------------------
        -- SKIP EVENT command
        --------------------------------------------------
        skip_event()

    else
        windower.add_to_chat(207,
            '[DoorHelper] Commands: //dh yes [...]  |  //dh debug [...]  |  //dh sortie [...]  |  //dh skip')
    end
end)

----------------------------------------------------------
-- Incoming menu packets:
--   0x034 / 0x032 (menu open/adjust)
-- Here we:
--   * log MenuID / NPC / Index in debug mode
--   * apply Auto-Yes only when:
--       - auto_yes is enabled
--       - zone is not 72 (Alzadaal Undersea Ruins)
--       - sortie_only is satisfied (if enabled)
--       - the NPC matches last_door_id
----------------------------------------------------------
windower.register_event('incoming chunk', function(id, data)
    if id ~= 0x034 and id ~= 0x032 then
        return
    end

    local p = packets.parse('incoming', data)
    if not p then
        return
    end

    if p['Menu ID'] and p['Menu ID'] ~= 0 then
        last_menu_id = p['Menu ID']
    end

    if settings.debug then
        local info = windower.ffxi.get_info()
        windower.add_to_chat(207,
            ('[DoorHelper-DEBUG] MenuID:%d | NPC:%d | Index:%d | Zone:%d'):format(
                p['Menu ID'] or 0,
                p['NPC'] or 0,
                p['NPC Index'] or 0,
                info.zone or 0
            ))
    end

    local info = windower.ffxi.get_info()

    -- if Sortie-only mode is enabled and we are not in Sortie, do nothing
    if settings.sortie_only and not in_sortie() then
        return
    end

    -- safety: never auto-yes in Alzadaal Undersea Ruins (zone 72)
    if info.zone == 72 then
        return
    end

    if not settings.auto_yes then
        return
    end

    -- only auto-yes menus whose NPC matches the last door we found
    if not last_door_id or p['NPC'] ~= last_door_id then
        return
    end

    coroutine.schedule(function()
        auto_select_yes_from_menu(p)
    end, 5.1)

    -- block this menu from appearing in the client
    return true
end)

----------------------------------------------------------
-- prerender: main loop for auto door logic
--   * finds nearest door
--   * pokes it
--   * optional old-style menu yes using last_menu_id
----------------------------------------------------------
windower.register_event('prerender', function()
    if auto_busy then
        return
    end
    auto_busy = true

    -- if Sortie-only mode is enabled, do nothing outside Sortie
    if settings.sortie_only and not in_sortie() then
        auto_busy = false
        return
    end

    local door = find_nearest_door()

    if door then
        if last_door_id ~= door.id then
            last_door_id       = door.id
            door_message_shown = false
        end

        if not door_message_shown then
            windower.add_to_chat(200,
                '[DoorHelper] Found door: ' .. door.name .. ' (ID: ' .. door.id .. ')')
            door_message_shown = true
        end

        -- poke the door (good enough for Sortie doors and Gilded Gateway)
        poke(door)

        -- optional fallback using last_menu_id
        coroutine.schedule(function()
            select_yes_old(door)
            auto_busy = false
        end, 6.2)
    else
        auto_busy = false
    end
end)
