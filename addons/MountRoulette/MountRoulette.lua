--[[
Copyright © 2020, Dean James (Xurion of Bismarck)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Mount Roulette nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Dean James (Xurion of Bismarck) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'Mount Roulette'
_addon.author = 'Dean James (Xurion of Bismarck)'
_addon.version = '3.1.0'
_addon.commands = {'mountroulette', 'mr'}

require('lists')
require('sets')
resources = require('resources')
config = require('config')
settings = config.load({
    blacklist = ''
})

math.randomseed(os.time())

allowed_mounts = L{}
possible_mounts = L{}
for _, mount in pairs(resources.mounts) do
    possible_mounts:append(mount.name:lower())
end

blacklist = {}
if string.len(settings.blacklist) > 0 then
    for mount in settings.blacklist:gmatch("([^,]+)") do
        table.insert(blacklist, mount)
    end
end

function update_allowed_mounts()
    local allowed_mounts_set = S{}
    local kis = windower.ffxi.get_key_items()

    for _, id in ipairs(kis) do
        local ki = resources.key_items[id]
        if ki.category == 'Mounts' and ki.name ~= "trainer's whistle" then -- Don't care about the quest KI
            local mount_index = possible_mounts:find(function(possible_mount)
                return windower.wc_match(ki.name:lower(), '♪' .. possible_mount .. '*')
            end)
            local mount = possible_mounts[mount_index]

            -- Add this to allowed mounts if it is not already there and it is not blacklisted
            if not allowed_mounts:contains(mount) and not S(blacklist):contains(mount) then
                allowed_mounts_set:add(mount)
            end
        end
    end

    allowed_mounts = L(allowed_mounts_set)
end

update_allowed_mounts()

windower.register_event('incoming chunk', function(id)
    if id == 0x055 then --ki update
        update_allowed_mounts()
    end
end)

commands = {}

commands.mount = function()
    local player = windower.ffxi.get_player()

    -- If the player is mounted, dismount now
    for _, buff in pairs(player.buffs) do
        if buff == 252 then --mounted buff
            windower.send_command('input /dismount')
            return
        end
    end

    if #allowed_mounts == 0 then return end

    -- Generate random number and use it to choose a mount
    local mount_index = math.ceil(math.random() * #allowed_mounts)
    windower.send_command('input /mount "' .. allowed_mounts[mount_index] .. '"')
end

commands.blacklist = function(args)
    local operation = args:remove(1)

    if not operation then
        windower.add_to_chat(8, 'Blacklisted mounts:')
        for k, v in ipairs(blacklist) do
            windower.add_to_chat(8, '  ' .. v)
        end
        return
    end

    local mount = args:concat(' '):lower()

    if not operation or not mount then
        commands.help()
        return
    end

    if not possible_mounts:contains(mount) then
        windower.add_to_chat(8, 'Unknown mount ' .. mount)
        return
    end

    if operation == 'add' and not S(blacklist):contains(mount) then
        for k, v in ipairs(T(allowed_mounts)) do
            if v == mount then
                allowed_mounts:remove(k)
            end
        end
        table.insert(blacklist, mount)
        windower.add_to_chat(8, 'The ' .. mount .. ' mount is now blacklisted')
        save_settings()
    elseif operation == 'remove' then
        for k, v in ipairs(blacklist) do
            if v == mount then
                table.remove(blacklist, k)
            end
        end
        allowed_mounts:append(mount)
        windower.add_to_chat(8, 'The ' .. mount .. ' mount is no longer blacklisted')
        save_settings()
    end
end

commands.help = function()
    windower.add_to_chat(8, '---Mount Roulette---')
    windower.add_to_chat(8, 'Available commands:')
    windower.add_to_chat(8, '//mr mount (or just //mr) - Selects a mount at random, or dismounts if mounted')
    windower.add_to_chat(8, '//mr blacklist - show blacklisted mounts')
    windower.add_to_chat(8, '//mr blacklist add <mount> - blacklist a mount so it is never randomly selected')
    windower.add_to_chat(8, '//mr blacklist remove <mount> - remove a mount from the blacklist')
    windower.add_to_chat(8, '//mr help - displays this help')
end

windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'mount'

    if commands[command] then
        commands[command](L{...})
    else
        commands.help()
    end
end)

function save_settings()
    settings.blacklist = table.concat(blacklist, ",")
    settings:save()
end
