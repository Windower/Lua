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
    * Neither the name of Mount Muzzle nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sjshovan (Apogee) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

_addon.name = 'Mount Muzzle'
_addon.description = 'Change or remove the default mount music.'
_addon.author = 'Sjshovan (Apogee) sjshovan@gmail.com'
_addon.version = '0.9.5'
_addon.commands = {'mountmuzzle', 'muzzle', 'mm'}

local _logger = require('logger')
local _config = require('config')
local _packets = require('packets')

require('constants')
require('helpers')

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
        buildHelpCommandEntry('unload', 'Unload Mount Muzzle.'),
        buildHelpCommandEntry('reload', 'Reload Mount Muzzle.'),
        buildHelpCommandEntry('about', 'Display information about Mount Muzzle.'),
        buildHelpCommandEntry('help', 'Display Mount Muzzle commands.'),
        buildHelpSeperator('=', 26),
    },
    types = {
        buildHelpSeperator('=', 23),
        buildHelpTitle('Types'),
        buildHelpSeperator('=', 23),
        buildHelpTypeEntry(muzzles.silent.name:ucfirst(), muzzles.silent.description),
        buildHelpTypeEntry(muzzles.mount.name:ucfirst(), muzzles.mount.description),
        buildHelpTypeEntry(muzzles.chocobo.name:ucfirst(), muzzles.chocobo.description),
        buildHelpTypeEntry(muzzles.zone.name:ucfirst(), muzzles.zone.description),
        buildHelpSeperator('=', 23),
    },
    about = {
        buildHelpSeperator('=', 23),
        buildHelpTitle('About'),
        buildHelpSeperator('=', 23),
        buildHelpTypeEntry('Name', _addon.name),
        buildHelpTypeEntry('Description', _addon.description),
        buildHelpTypeEntry('Author', _addon.author),
        buildHelpTypeEntry('Version', _addon.version),
        buildHelpSeperator('=', 23),
    },
    aliases = {
        muzzles = {
            s = muzzles.silent.name,
            m = muzzles.mount.name,
            c = muzzles.chocobo.name,
            z = muzzles.zone.name
        }
    }
}

function display_help(table_help)
    for index, command in pairs(table_help) do
        displayResponse(command)
    end
end

function getMuzzle()
    return settings.muzzle
end

function getPlayerBuffs() 
    return T(windower.ffxi.get_player().buffs)
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

function setMuzzle(muzzle)
    settings.muzzle = muzzle
    settings:save()
end

function playerInReive()
    return getPlayerBuffs():contains(player.buffs.reiveMark)
end

function playerIsMounted()
    local _player = windower.ffxi.get_player()
    
    if _player then
        return _player.status == player.statuses.mounted or getPlayerBuffs():contains(player.buffs.mounted)
    end
    
    return false 
end

function muzzleValid(muzzle)
    return muzzles[muzzle] ~= nil
end

function injectMuzzleMusic()
    injectMusic(music.types.mount, resolveCurrentMuzzle().song)
end

function injectMusic(bgmType, songID) 
    _packets.inject(_packets.new('incoming', packets.inbound.music_change.id, {
        ['BGM Type'] = bgmType,
        ['Song ID'] = songID,
    }))
end

function requestInject()
    needs_inject = true
end

function handleInjectionNeeds() 
    if needs_inject and playerIsMounted() then
        injectMuzzleMusic()
        needs_inject = false; 
    end
end

function tryInject()
    requestInject()
    handleInjectionNeeds()
end

windower.register_event('login', 'load', 'zone change', function() 
    tryInject()
end)

windower.register_event('addon command', function(command, ...)
    if command then
        command = command:lower()
    else 
        return display_help(help.commands)
    end
    
    local command_args = {...}
    local respond = false
    local response_message = ''
    local success = true
    
    if command == 'list' or command == 'l' then
        display_help(help.types)

    elseif command == 'set' or command == 's' then
        respond = true
        
        local muzzle = tostring(command_args[1]):lower()
        local from_alias = help.aliases.muzzles[muzzle]
        
        if (from_alias ~= nil) then
            muzzle = from_alias
        end

        if not muzzleValid(muzzle) then
            success = false
            response_message = 'Muzzle type not recognized.'
        else
            requestInject()
            setMuzzle(muzzle)
            response_message = 'Updated current muzzle to %s.':format(muzzle:ucfirst():color(colors.secondary))
        end

    elseif command == 'get' or command == 'g' then
        respond = true
        response_message = 'Current muzzle is %s.':format(getMuzzle():ucfirst():color(colors.secondary))

    elseif command == 'default' or command == 'd' then
        respond = true
        requestInject()

        setMuzzle(muzzles.silent.name)
        response_message = 'Updated current muzzle to the default (%s).':format('Silent':color(colors.secondary))

    elseif command == 'reload' or command == 'r' then
        windower.send_command('lua r mountmuzzle')
    
    elseif command == 'unload' or command == 'u' then
        respond = true
        response_message = 'Thank you for using Mount Muzzle. Goodbye.'
        injectMusic(music.types.mount, muzzles.zone.song)
        windower.send_command('lua unload mountmuzzle')

    elseif command == 'about' or command == 'a' then
        display_help(help.about)
        
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

windower.register_event('incoming chunk', function(id, data)
     if id == packets.inbound.music_change.id then
        local packet = _packets.parse('incoming', data)
        
        if packet['BGM Type'] == music.types.mount then
            packet['Song ID'] = resolveCurrentMuzzle().song
            return _packets.build(packet)
        end
        
        tryInject()
    end
end)