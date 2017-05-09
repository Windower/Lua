-- Setup

require('luau')
packets = require('packets')

_addon.name = 'AutoJoin'
_addon.author = 'Arcon'
_addon.commands = {'autojoin', 'aj'}
_addon.version = '2.0.0.1'

defaults = {}
defaults.mode = 'whitelist'
defaults.whitelist = S{}
defaults.blacklist = S{}
defaults.autodecline = false

settings = config.load(defaults)

-- Aliases to access correct modes based on supplied arguments.
aliases = T{
    w            = 'whitelist',
    wlist        = 'whitelist',
    white        = 'whitelist',
    whitelist    = 'whitelist',
    b            = 'blacklist',
    blist        = 'blacklist',
    black        = 'blacklist',
    blacklist    = 'blacklist'
}

-- String-sets for quick aceess.
add_strs = S{'a', 'add', '+'}
rm_strs = S{'r', 'rm', 'remove', '-'}
dec_strs = S{'decline', 'autodecline', 'auto-decline'}
alias_strs = aliases:keyset()

do
    local join_packet = packets.new('outgoing', 0x074, {Join = true})
    join = function()
        local time = 0
        -- Wait until pool is empty...
        while not table.empty(windower.ffxi.get_items().treasure) do
            coroutine.sleep(1)
            time = time + 1

            -- ... but only until the max join time expires
            if time > 90 then
                return
            end
        end

        packets.inject(join_packet)
        windower.send_command:schedule(1, 'input /join')
    end

    local decline_packet = packets.new('outgoing', 0x074, {Join = false})
    decline = function()
        packets.inject(decline_packet)
        windower.send_command:schedule(1, 'input /decline')
    end
end

-- Invite handler
windower.register_event('party invite', function(sender)
    if settings.mode == 'whitelist' and settings.whitelist:contains(sender) or settings.mode == 'blacklist' and not settings.blacklist:contains(sender)then
        join()
    elseif settings.mode == 'blacklist' and settings.autodecline then
        decline()
    end
end)

-- Adds names to a given list type.
function add_name(mode, ...)
    local names = S{...}
    local duplicates = names * settings[mode]
    if not duplicates:empty() then
        notice(('User'):plural(duplicates) .. ' ' .. duplicates:format() .. ' already on ' .. aliases[mode] .. '.')
    end
    local new = names - settings[mode]
    if not new:empty() then
        settings[mode] = settings[mode] + new
        log('Added ' .. new:format() .. ' to the ' .. aliases[mode] .. '.')
    end
    settings:save()
end

-- Removes names from a given list type.
function rm_name(mode, ...)
    local names = S{...}
    local dummy = names - settings[mode]
    if not dummy:empty() then
        notice(('User'):plural(dummy) .. ' ' .. dummy:format() .. ' not found on ' .. aliases[mode] .. '.')
    end
    local remove = names * settings[mode]
    if not remove:empty() then
        settings[mode] = settings[mode] - remove
        log('Removed ' .. remove:format() .. ' from the ' .. aliases[mode] .. '.')
    end
    settings:save()
end

-- Interpreter

windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'status'
    local args = T{...}

    -- Mode switch
    if command == 'mode' then
        -- If no mode provided, print status.
        local mode = args[1] or 'status'
        if alias_strs:contains(mode) then
            settings.mode = aliases[mode]
            log('Mode switched to ' .. settings.mode .. '.')
            settings:save()
        elseif mode == 'status' then
            log('Currently in ' .. settings.mode .. ' mode.')
        else
            error('Invalid mode:', args[1])
            return
        end

    -- List management
    elseif alias_strs:contains(command) then
        mode = aliases[command]
        names = args:slice(2):map(string.ucfirst .. string.lower)

        -- If no operator provided
        if args:empty() then
            log(mode:ucfirst() .. ':', settings[mode]:format('csv'))
        else
            if add_strs:contains(args[1]) then
                add_name(mode, names:unpack())
            elseif rm_strs:contains(args[1]) then
                rm_name(mode, names:unpack())
            -- If no qualifier provided
            else
                notice('Invalid operator specified. Specify add or remove.')
            end
        end

    -- Auto-decline settings
    elseif dec_strs:contains(command) then
        if args[1] ~= nil then
            local decline = args[1]:lower()
            local success = true
            if decline == 'true' then
                settings.autodecline = true
            elseif decline == 'false' then
                settings.autodecline = false
            else
                log('Invalid command for autodecline. Specify true or false.')
                success = false
            end

            if success then
                log('Set auto-decline to ' .. tostring(settings.autodecline) .. '.')
                settings:save()
            end
        else
            log('Auto-decline is currently ' .. (settings.autodecline and 'on' or 'off') .. '.')
        end

    -- Save settings. This is only needed for global or cross-character settings, as current-chracter settings will be saved every time something is changed.
    elseif command == 'save' then
        settings:save(args[1] or 'all')
        log('Settings saved.')

    -- Print current settings status
    elseif command == 'status' then
        log('Mode:', settings.mode)
        log('Whitelist:', settings.whitelist:empty() and '(empty)' or settings.whitelist:format('csv'))
        log('Blacklist:', settings.blacklist:empty() and '(empty)' or settings.blacklist:format('csv'))
        log('Auto-decline:', settings.autodecline)

    -- Unknown command handler
    else
        warning('Unkown command \'' .. command .. '\', ignored.')

    end
end)

--[[
Copyright © 2013-2015, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
