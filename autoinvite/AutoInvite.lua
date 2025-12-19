--[[
Copyright (c) 2013, Registry
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of autoinvite nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Registry BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
]]


--[[
    AutoInvite (Enhanced Version)
    Author: Registry + Modified by Aragan
    Description:
      - AutoAdd is enabled by default (invites anyone who sends you a /tell)
      - Does not invite someone already in the party
      - Supports on/off/status commands
      - Fully English messages
      - All original commands are available (whitelist / blacklist / keywords)
]]

require('luau')

_addon.name = 'AutoInvite'
_addon.author = 'Registry + Aragan'
_addon.commands = {'autoinvite','ainv'}
_addon.version = 1.3
_addon.language = 'english'

defaults = T{}
defaults.mode = 'whitelist'
defaults.whitelist = S{}
defaults.blacklist = S{}
defaults.keywords = S{}
defaults.tellback = 'on'

statusblock = S{'Dead','Event','Charmed'}

aliases = T{
    wlist='whitelist', white='whitelist', whitelist='whitelist',
    blist='blacklist', black='blacklist', blacklist='blacklist',
    key='keywords', keyword='keywords', keywords='keywords'
}

addstrs = S{'a','add','+'}
rmstrs = S{'r','rm','remove','-'}
on = S{'on','yes','true'}
off = S{'off','no','false'}
modes = S{'whitelist','blacklist'}

settings = config.load(defaults)

---------------------------------------------------------------
-- General Variables
---------------------------------------------------------------
autoadd_enabled = false
addon_enabled = true

---------------------------------------------------------------
-- New Control Commands
---------------------------------------------------------------
windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or ''
    local args = L{...}

    
    if command == 'help' then
        windower.add_to_chat(207, '[AutoInvite] Available Commands:')
        windower.add_to_chat(207, '  //ai on - Enable the addon.')
        windower.add_to_chat(207, '  //ai off - Disable the addon.')
        windower.add_to_chat(207, '  //ai toggle - Toggle the addon on/off.')
        windower.add_to_chat(207, '  //ai status - Show the current status of the addon.')
        windower.add_to_chat(207, '  //ai mode [whitelist|blacklist|status] - Change or view the current mode.')
        windower.add_to_chat(207, '  //ai tellback [on|off|status] - Enable/disable auto-reply to /tell messages.')
        windower.add_to_chat(207, '  //ai whitelist add [name] - Add a name to the whitelist.')
        windower.add_to_chat(207, '  //ai whitelist remove [name] - Remove a name from the whitelist.')
        windower.add_to_chat(207, '  //ai blacklist add [name] - Add a name to the blacklist.')
        windower.add_to_chat(207, '  //ai blacklist remove [name] - Remove a name from the blacklist.')
        windower.add_to_chat(207, '  //ai keywords add [word] - Add a keyword to the list.')
        windower.add_to_chat(207, '  //ai keywords remove [word] - Remove a keyword from the list.')
        windower.add_to_chat(207, '  //ai help - Show this help message.')
        return
    end
    if command == 'on' then
        addon_enabled = true
        windower.add_to_chat(207, '[AutoInvite] AutoInvite enabled.')
        return
    elseif command == 'off' then
        addon_enabled = false
        windower.add_to_chat(207, '[AutoInvite] AutoInvite disabled.')
        return
    elseif command == 'toggle' then
        addon_enabled = not addon_enabled
        windower.add_to_chat(207, ('[AutoInvite] AutoInvite %s.'):format(addon_enabled and 'enabled' or 'disabled'))
        return
    elseif command == 'status' then
        windower.add_to_chat(207, ('[AutoInvite] Current status: %s'):format(addon_enabled and 'Enabled' or 'Disabled'))
        return
    end

    if command == 'mode' then
        local mode = args[1] or 'status'
        if aliases:keyset():contains(mode) then
            settings.mode = aliases[mode]
            log('Mode changed to '..settings.mode..'.')
        elseif mode == 'status' then
            log('Current mode: '..settings.mode..'.')
        else
            error('Invalid mode:', args[1])
            return
        end
    elseif command == 'tellback' then
        if args:length() == 0 then
            settings.tellback = (settings.tellback == 'on') and 'off' or 'on'
            windower.add_to_chat(207, ('[AutoInvite] Tellback toggled to %s.'):format(settings.tellback))
            return
        end
    
        local status = args[1]
        if type(status) == 'string' then
            status = status:lower()
        end
    
        if on:contains(status) then
            settings.tellback = 'on'
            windower.add_to_chat(207, '[AutoInvite] Tellback enabled.')
        elseif off:contains(status) then
            settings.tellback = 'off'
            windower.add_to_chat(207, '[AutoInvite] Tellback disabled.')
        elseif status == 'status' then
            windower.add_to_chat(207, ('[AutoInvite] Tellback is currently: %s'):format(settings.tellback))
        else
            windower.add_to_chat(123, '[AutoInvite] Unknown tellback option.')
        end
    end
        -----------------------------------------------------------
    -- 🆓 FreeInv mode
    -----------------------------------------------------------
    if command == 'freeinv' then
        -- If no argument is provided, toggle
        if args:length() == 0 then
            settings.freeinv = not settings.freeinv
            windower.add_to_chat(207, ('[AutoInvite] FreeInv mode toggled: %s'):format(settings.freeinv and 'ON' or 'OFF'))
            return
        end

        local arg = args[1]:lower()
        if arg == 'on' then
            settings.freeinv = true
            windower.add_to_chat(207, '[AutoInvite] FreeInv mode: ON .')
        elseif arg == 'off' then
            settings.freeinv = false
            windower.add_to_chat(207, '[AutoInvite] FreeInv mode: OFF .')
        else
            windower.add_to_chat(207, ('[AutoInvite] FreeInv mode: %s'):format(settings.freeinv and 'ON' or 'OFF'))
        end
        return
    end

end)

---------------------------------------------------------------
-- AutoAdd: Automatically invite anyone who sends a /tell
---------------------------------------------------------------
windower.register_event('chat message', function(message, player, mode, is_gm)
    if not addon_enabled then return end

    if settings.freeinv and mode == 3 then
        if not player or player == '' then return end
        local p = windower.ffxi.get_party()
        local me = windower.ffxi.get_player()
        if not p or p.party1_leader ~= me.id then
            windower.add_to_chat(123, '[AutoInvite] You are not the leader - FreeInv is temporarily paused.')
            return
        end
        for i = 0, 5 do
            local member = p['p'..i]
            if member and member.name and member.name:lower() == player:lower() then
                return
            end
        end
        windower.add_to_chat(207, ('[AutoInvite] FreeInv: %s has been invited automatically.'):format(player))
        coroutine.schedule(function()
            windower.send_command('input /pcmd add '..player)
        end, 0.5)
        return
    end


    if autoadd_enabled and mode == 3 then
        if not player or player == '' then return end

        local p = windower.ffxi.get_party()
        local me = windower.ffxi.get_player()
        if not p or p.party1_leader ~= me.id then
            windower.add_to_chat(123, '[AutoInvite] You are not the party leader - no invite will be sent.')
            return
        end

        for i = 0, 5 do
            local member = p['p'..i]
            if member and member.name and member.name:lower() == player:lower() then
                windower.add_to_chat(123, ('[AutoInvite] %s is already in the party - no need to invite.'):format(player))
                return
            end
        end

        windower.add_to_chat(207, ('[AutoInvite] %s has been invited automatically.'):format(player))
        coroutine.schedule(function()
            windower.send_command('input /pcmd add '..player)
        end, 0.5)
        return
    end

    local word = false
    if mode == 3 then
        for item in settings.keywords:it() do
            if message:lower():match(item:lower()) then
                word = true
                break
            end
        end
        if word == false then return end

        if settings.mode == 'blacklist' then
            if settings.blacklist:contains(player) then
                return
            else
                try_invite(player)
            end
        elseif settings.mode == 'whitelist' then
            if settings.whitelist:contains(player) then
                try_invite(player)
            end
        end
    end
end)

---------------------------------------------------------------
-- Invite Function
---------------------------------------------------------------
function try_invite(player)
    if windower.ffxi.get_party().p5 then
        notice(player..' cannot be invited - the party is full.')
        if settings.tellback == 'on' then
            coroutine.sleep(3)
            windower.send_command('input /t '..player..' The party is currently full. If a spot becomes free, I will let you know.')
        end
        return
    end

    local status = res.statuses[windower.ffxi.get_player().status].english
    if statusblock:contains(status) then
        notice(player..' cannot be invited ('..status..').')
        if settings.tellback == 'on' then
            windower.send_command('input /t '..player..' Cannot invite at the moment ('..status..').')
        end
        return
    end

    windower.send_command('input /pcmd add '..player)
end

---------------------------------------------------------------
-- Original Helper Functions
---------------------------------------------------------------
function add_item(mode, ...)
    local names = S{...}
    local doubles = names * settings[mode]
    if not doubles:empty() then
        if aliases[mode] == 'keywords' then
            notice('The keyword '..doubles:format()..' already exists.')
        else
            notice('The name '..doubles:format()..' already exists in '..aliases[mode]..'.')
        end
    end
    local new = names - settings[mode]
    if not new:empty() then
        settings[mode] = settings[mode] + new
        log('Added: '..new:format()..' to '..aliases[mode]..'.')
    end
end

function remove_item(mode, ...)
    local names = S{...}
    local dummy = names - settings[mode]
    if not dummy:empty() then
        notice('The name '..dummy:format()..' does not exist in '..aliases[mode]..'.')
    end
    local item_to_remove = names * settings[mode]
    if not item_to_remove:empty() then
        settings[mode] = settings[mode] - item_to_remove
        log('Removed: '..item_to_remove:format()..' from '..aliases[mode]..'.')
    end
end
