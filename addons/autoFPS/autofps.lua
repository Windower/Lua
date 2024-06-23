--[[ Copyright © 2024, Sevu
-- All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of AutoFPS nor the
       names of its contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sevi BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


-- Changelog -- 
v0.1 - Initial release.
v0.2 - Added per zone toggle.
v0.3 - Added command to control Cutscene behavior.
v0.4 - Clean up code and adding a exclude list to avoid limited FPS when navigating teleport or spark/accolade npc menu's.

--]]

_addon.name = 'autoFPS'
_addon.author = 'Sevu'
_addon.version = '0.4'
_addon.commands = {'autofps','afps'}

local settings_file_path = windower.addon_path..'settings.lua'
local zones_file_path = windower.addon_path..'zones.lua'

local function file_exists(file_path)
    local file = io.open(file_path, 'r')
    if file then
        file:close()
        return true
    else
        return false
    end
end

local function create_default_settings_file()
    local file = io.open(settings_file_path, 'w')
    file:write('return {\n')
    file:write('    exclusions = {"home point #1", "home point #2", "home point #3", "home point #4", "home point #5", "Eternal Flame", "Fhelm Jobeizat", "Rolandienne", "Isakoth", "igsli", "urbiolaine", "teldro-kesdrodo", "nunaarl bthtrogg", "survival guide", "waypoint"},\n')
    file:write('    fps_by_zone = false,\n')
    file:write('    cutscenes = true,\n')
    file:write('}\n')
    file:close()
end

local function create_default_zones_file()
    local file = io.open(zones_file_path, 'w')
    file:write([[return {
    ['Western Adoulin'] = true,
    ['Eastern Adoulin'] = true,
    ['Aht Urhgan Whitegate'] = true,
    ['Ru\'Lude Gardens'] = true,
    ['Lower Jeuno'] = true,
    ['Port Jeuno'] = true,
    ['Upper Jeuno'] = true,
    -- Add more zones to disable FPS as needed
    -- follow this format "['zoneName'] = true,"
}
]])
    file:close()
end

if not file_exists(settings_file_path) then
    create_default_settings_file()
end

if not file_exists(zones_file_path) then
    create_default_zones_file()
end

local settings = dofile(settings_file_path)
local zones_to_disable_fps = dofile(zones_file_path)
local res = require('resources')
local CUTSCENE_STATUS_ID = 4
local color = 123

local send_command = windower.send_command
local add_to_chat = windower.add_to_chat


local function disable_fps_for_cutscenes()
    return settings.cutscenes
end


local function is_cutscene(status_id)
    return status_id == CUTSCENE_STATUS_ID
end

local function disable_fps()
    send_command('config FrameRateDivisor 2')
end

local function enable_fps()
    send_command('config FrameRateDivisor 1')
end

local function toggle_display_if_cutscene(is_cutscene_playing)
    if is_cutscene_playing then
        disable_fps()
    else
        enable_fps()
    end
end


local function disable_fps_zone()
    local zone = res.zones[windower.ffxi.get_info().zone].english
    return zones_to_disable_fps[zone]
end

local function update_settings()
    local file = io.open(settings_file_path, 'w')
    file:write('return {\n')
    file:write('    exclusions = {')
    for i, exclusion in ipairs(settings.exclusions) do
        file:write(string.format('%q', exclusion))
        if i < #settings.exclusions then
            file:write(', ')
        end
    end
    file:write('},\n')
    file:write('    fps_by_zone = '..tostring(settings.fps_by_zone)..',\n')
    file:write('    cutscenes = '..tostring(settings.cutscenes)..',\n')
    file:write('}\n')
    file:close()
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

windower.register_event('load', function()
    local player = windower.ffxi.get_player()

    if player then
        enable_fps()
    else
        disable_fps()
        return
    end
    
    if settings.fps_by_zone and disable_fps_zone() then
        disable_fps()
    elseif disable_fps_for_cutscenes() and is_cutscene(player.status) then
        disable_fps()
    else
        enable_fps()
    end
end)


windower.register_event('login', function()
    if settings.fps_by_zone and disable_fps_zone() then
        disable_fps()
    elseif disable_fps_for_cutscenes() and is_cutscene(windower.ffxi.get_player().status_id) then
        disable_fps()
    else
        enable_fps()
    end
end)

windower.register_event('logout', disable_fps)

windower.register_event('status change', function(new_status_id)
    local target = windower.ffxi.get_mob_by_target('t')
    if not target or (target and not table.contains(settings.exclusions, target.name:lower())) then
        if disable_fps_for_cutscenes() and is_cutscene(new_status_id) then
            disable_fps()
        else
            toggle_display_if_cutscene(is_cutscene(new_status_id))
        end
    end
end)

windower.register_event('addon command', function(command, ...)
    local args = {...}
    if command:lower() == 'cutscene' or command:lower() == 'cs' then
        settings.cutscenes = not settings.cutscenes
        update_settings()
        send_command('lua r autofps')
        if settings.cutscenes then
            add_to_chat(color, 'AutoFPS: Cutscene Enabled')
        else
            add_to_chat(color, 'AutoFPS: Cutscene Disabled')
        end
    
    elseif command:lower() == 'reload' then
        send_command('lua r autofps')

    elseif command:lower() == 'zone' then
        settings.fps_by_zone = not settings.fps_by_zone
        update_settings()
        send_command('lua r autofps')
        if settings.fps_by_zone then
            add_to_chat(color, 'AutoFPS: Zone Enabled')
        else
            add_to_chat(color, 'AutoFPS: Zone Disabled')
        end

    elseif command:lower() == 'status' then
        add_to_chat(204, '--- Current Settings ---')
        add_to_chat(204, 'FPS by Zone: ' .. (settings.fps_by_zone and 'True' or 'False'))
        add_to_chat(204, 'Cutscene FPS Management: ' .. (settings.cutscenes and 'True' or 'False'))

    else
        add_to_chat(color, '--- AutoFPS ---')
        add_to_chat(color, 'Addon Commands: //autofps')
        add_to_chat(color, 'autofps help - This menu.')
        add_to_chat(color, 'autofps reload - Reload addon.')
        add_to_chat(color, 'autofps zone - Enable/Disable FPS behavior per zone, configured in zones.lua.')
        add_to_chat(color, 'autofps cs - Enable/Disable FPS behavior during cutscenes.')
        add_to_chat(color, 'autofps status - Display current settings.')

    end
end)