_addon.name    = 'Mount Roulette'
_addon.author  = 'Dean James (Xurion of Bismarck)'
_addon.version = '3.0.0'
_addon.commands = {'mountroulette', 'mr'}

require('lists')
resources = require('resources')

math.randomseed(os.time())

allowed_mounts = L{}
possible_mounts = L{}
for _, mount in ipairs(resources.mounts) do
    possible_mounts:append(mount.name:lower())
end

function update_allowed_mounts()
    local kis = windower.ffxi.get_key_items()

    for _, id in ipairs(kis) do
        local ki = resources.key_items[id]
        if ki.category == 'Mounts' and ki.name ~= "trainer's whistle" then -- Don't care about the quest KI
            local mount_index = possible_mounts:find(function(possible_mount)
                return windower.wc_match(ki.name:lower(), '♪' .. possible_mount .. '*')
            end)
            local mount = possible_mounts[mount_index]

            -- Add this to allowed mounts if it is not already there
            if not allowed_mounts:contains(mount) then
                allowed_mounts:append(mount)
            end
        end
    end
end

windower.register_event('load', function()
    update_allowed_mounts()
end)

windower.register_event('incoming chunk', function(id)
    if id == 0x055 then --ki update
        update_allowed_mounts()
    end
end)

windower.register_event('addon command', function(command)
    command = command and command:lower() or 'mount'

    if commands[command] then
        commands[command]()
    else
        commands.help()
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

    -- Generate random number and use it to choose a mount
    local mount_index = math.ceil(math.random() * #allowed_mounts)
    windower.send_command('input /mount ' .. allowed_mounts[mount_index])
end

commands.help = function()
    windower.add_to_chat(8, '---Mount Roulette---')
    windower.add_to_chat(8, 'Available commands:')
    windower.add_to_chat(8, '//mr mount (or just //mr) - Selects a mount at random, or dismounts if mounted')
    windower.add_to_chat(8, '//mr help - displays this help')
end
