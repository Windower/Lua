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

_addon.name    = 'Mount Roulette'
_addon.author  = 'Dean James (Xurion of Bismarck)'
_addon.version = '3.0.1'
_addon.commands = {'mountroulette', 'mr'}

require('lists')
require('sets')
resources = require('resources')

math.randomseed(os.time())

allowed_mounts = L{}
possible_mounts = L{}
for _, mount in pairs(resources.mounts) do
    possible_mounts:append(mount.name:lower())
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

            allowed_mounts_set:add(mount)
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

windower.register_event('addon command', function()
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
end)
