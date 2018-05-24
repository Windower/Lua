--[[
Copyright © 2018, Sjshovan (Apogee)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of MountMuzzle nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Patrick Finnigan BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name     = 'Mount Muzzle'
_addon.author   = 'Sjshovan (Apogee) sjshovan@gmail.com'
_addon.version  = '0.9.2'
_addon.commands = {'mountmuzzle', 'muzzle', 'mm'}

local _logger = require('logger')
local _config  = require('config')
local _packets = require('packets')

require('helpers')

local mounted = false
local needs_inject = false

local defaults = {
    muzzle = muzzles.silent.name
}

local settings = _config.load(defaults)

local help = {
    commands = {
        buildHelpSeperator('=', 26),
        buildHelpTitle('Commands'),
        buildHelpSeperator('=', 26),
        buildHelpCommandEntry('list', 'Display the available muzzle types.'),
        buildHelpCommandEntry('set <muzzle>', 'Set the current muzzle to the given muzzle type.'),
        buildHelpCommandEntry('get', 'Display the current muzzle.'),
        buildHelpCommandEntry('default', 'Set the current muzzle to the default (Silent).'),
        buildHelpCommandEntry('reload', 'Reload Mount Muzzle.'),
        buildHelpCommandEntry('help', 'Display Mount Muzzle commands.'),
        buildHelpSeperator('=', 26),
    },

    types = {
        buildHelpSeperator('=', 23),
        buildHelpTitle('Types'),
        buildHelpSeperator('=', 23),
        buildHelpTypeEntry(ucFirst(muzzles.silent.name), muzzles.silent.description),
        buildHelpTypeEntry(ucFirst(muzzles.normal.name), muzzles.normal.description),
        buildHelpTypeEntry(ucFirst(muzzles.choco.name), muzzles.choco.description),
        buildHelpTypeEntry(ucFirst(muzzles.zone.name), muzzles.zone.description),
        buildHelpSeperator('=', 23),
    },
}

function display_help(table_help)
    for index, command in pairs(table_help) do
        displayResponse(command)
    end
end

function getMuzzle()
    return settings.muzzle
end

function setMuzzle(muzzle)
    settings.muzzle = muzzle
    settings:save()
end

function muzzleValid(muzzle)
    return muzzles[muzzle] ~= nil
end

function resolveCurrentMuzzle()
    local current_muzzle = getMuzzle()
    if not muzzleValid(current_muzzle) then
        current_muzzle = muzzles.silent.name
        setMuzzle(current_muzzle)
        displayResponse(
            'Note: Muzzle found in settings was not valid and is now set to the default (%s).':format('Silent':color(colors.secondary)),
            colors.warn
        )
    end
    return muzzles[current_muzzle]
end

function requestInject()
    needs_inject = true
end

function injectMuzzleMusic()
    windower.packets.inject_incoming(
        packets.inbound.music_change.id,
        'IHH':pack(packets.inbound.music_change.id,
            music.types.mount,
            resolveCurrentMuzzle().song
        )
    )
end

function handleInjectionNeeds() 
    if needs_inject and playerIsMounted() then
        injectMuzzleMusic()
        needs_inject = false;
    end
end

function playerIsMounted()
    local _player = windower.ffxi.get_player()
    if _player then
        return mounted or _player.status == player.statuses.mounted
    end
    return false 
end

windower.register_event('login', requestInject)
windower.register_event('load', requestInject)
windower.register_event('zone change', requestInject)

windower.register_event('addon command', function(command, ...)
    if command then
        local command = command:lower()
    else 
        display_help(help.commands)
        return
    end
    
    local command_args = {...}

    local respond = false
    local response_message = ''
    local success = true

    if command == 'list' then
        display_help(help.types)

    elseif command == 'set' then
        respond = true

        local muzzle = tostring (command_args[1]):lower()

        if not muzzleValid(muzzle) then
            success = false
            response_message = 'Muzzle type not recognized.'
        else
            needs_inject = true
            setMuzzle(muzzle)
            response_message = 'Updated current muzzle to %s.':format(ucFirst(muzzle):color(colors.secondary))
        end

    elseif command == 'get' then
        respond = true
        response_message = 'Current muzzle is %s.':format(ucFirst(getMuzzle()):color(colors.secondary))

    elseif command == 'default' then
        respond = true
        needs_inject = true

        setMuzzle(muzzles.silent.name)
        response_message = 'Updated current muzzle to the default (%s).':format('Silent':color(colors.secondary))

    elseif command == 'reload' then
        windower.send_command('lua r mountmuzzle')

    elseif command == 'help' or command == 'h' then
        display_help(help.commands)
    else
        display_help(help.commands)
    end

    if respond then
        displayResponse(
            buildCommandResponse(response_message, success)
        )
    end

    handleInjectionNeeds()
end)

windower.register_event('outgoing chunk', function(id, data)
    if id == packets.outbound.action.id then
        local packet = _packets.parse('outgoing', data)
        if packet.Category == packets.outbound.action.categories.mount then
            mounted = true
        elseif packet.Category == packets.outbound.action.categories.unmount then
            mounted = false
        end
    end
end)

windower.register_event('incoming chunk', function(id, data)
    if id == packets.inbound.music_change.id and playerIsMounted() then
        local packet = _packets.parse('incoming', data)

        if packet['BGM Type'] == music.types.mount then
            packet['Song ID'] = resolveCurrentMuzzle().song
            return _packets.build(packet)
        end
    end
    
    handleInjectionNeeds()
end)