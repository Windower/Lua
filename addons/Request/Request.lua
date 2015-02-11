--[[
Copyright © 2015, Selindrile
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Request nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Selindrile BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
]]

require('luau')

_addon.name = 'Request'
_addon.author = 'Selindrile'
_addon.commands = {'request','rq'}
_addon.version = 1.1
_addon.language = 'english'

defaults = T{}
defaults.mode = 'whitelist'
defaults.whitelist = S{}
defaults.blacklist = S{}
defaults.nicknames = S{}
defaults.forbidden = S{'Lua','U','Reload','Quit','Treasury','Unload','S','Say','Exec','Load','L','Linkshell','Sh','Shout'}
defaults.PartyLock = true
defaults.ExactLock = true
defaults.RequestLock = false

-- Statuses that stop you from sending invites.
statusblock = S{
    'Dead', 'Event', 'Charmed'
}

-- Aliases to access correct modes based on supplied arguments.
aliases = T{
    wlist        = 'whitelist',
    white        = 'whitelist',
    whitelist    = 'whitelist',
    blist        = 'blacklist',
    black        = 'blacklist',
    blacklist    = 'blacklist',
    nick         = 'nicknames',
    nickname	 = 'nicknames',
    nicknames    = 'nicknames',
    partylock	 = 'partylock',
    partyl       = 'partylock',
    plock        = 'partylock',
    pl           = 'partylock',
    requestlock  = 'requestlock',
    requestl     = 'requestlock',
    rlock        = 'requestlock',
    rl           = 'requestlock',
    exactlock    = 'exactlock',
    exact        = 'exactlock',
    exactl       = 'exactlock',
    elock        = 'exactlock',
    xlock        = 'exactlock',
    xl           = 'exactlock',
    forbidden    = 'forbidden',
    forbid       = 'forbidden',
}

-- Aliases to access the add and item_to_remove routines.
addstrs = S{'a', 'add', '+'}
rmstrs = S{'r', 'rm', 'remove', 'delete', 'del', '-'}

-- Aliases for partylock and requestlock and exactlock modes.
on = S{'on', 'yes', 'true'}
off = S{'off', 'no', 'false'}

modes = S{'whitelist', 'blacklist'}

-- Load settings from file
settings = config.load(defaults)

-- Check for permission.
windower.register_event('chat message', function(message, player, mode, is_gm)

        if settings.mode == 'blacklist' then
            if settings.blacklist:contains(player) then
                return
            else
                request(message, player)
            end
        elseif settings.mode == 'whitelist' then
            if settings.whitelist:contains(player) then
                request(message, player)
            end
        end

end)

-- Attempts to send a request, Quick Debug Line: windower.send_command('input /echo '..nick..' '..request..' '..target..'')
function request(message, player)

	local nick
	local request
	local target

	nick, request = string.match(message:lower(), '^%s*(%a+)%s+([:/%-%a*%d*]+)')
	target = string.match(message:lower(), '^%s*%a+%s+[:/%-%a*%d*]+%s+(%a+)')
	
	if nick == nil then nick = ' ' end
	if request == nil then request = ' ' end
	if target == nil then target = ' ' end

	-- Check to see if valid player is issuing a command with your nick, and check it against the list of forbidden commands.
	if settings.nicknames:contains(nick:ucfirst()) and not settings.forbidden:contains(request:ucfirst()) then
		--Party commands to check.
		if not settings.PartyLock and request == "pass" and (target == "lead" or target == "leader") then
			windower.send_command('input /pcmd leader '..player..'')
			
		elseif not settings.PartyLock and request == "disband" then
			windower.send_command('input /pcmd leave')
			
		elseif not settings.PartyLock and request == "join" or request == "accept" then
			windower.send_command('input /join')
			
		elseif not settings.PartyLock and request == "invite" then
			if target == "me" or target == " " then windower.send_command('input /pcmd add '..player..'')
			else windower.send_command('input /pcmd add '..target..'')
			end
			
		elseif not settings.PartyLock and request == "kick" then
			windower.send_command('input /pcmd kick '..target..'')
		--Exact Command?
		elseif request == "exact" and not settings.ExactLock then
			exactcommand = string.match(message, '%a+ exact (.*)')
			windower.send_command(''..exactcommand..'')
		--Anything else, mostly send on to shortcuts and user aliases, could potentially send short addon commands.
		elseif not settings.RequestLock then
			if request == "quit" or request == "stop" then windower.send_command('attackoff')
			elseif target == "bt" or target == "it" or target == "this" or target == "t" then windower.send_command(''..request..' <bt>')
			elseif target == "us" or target == "yourself" then windower.send_command(''..request..' <me>')
			elseif target == "me" or target == "now" or target == nil then windower.send_command(''..request..' '..player..'')
			else windower.send_command(''..request..' '..target..'')
			end
		end
		
	end
	
end


-- Adds names/items to a given list type.
function add_item(mode, ...)
    local names = S{...}
    local doubles = names * settings[mode]
    if not doubles:empty() then
        if aliases[mode] == 'nicknames' then
            notice('User':plural(doubles)..' '..doubles:format()..' already on nickname list.')
        elseif aliases[mode] == 'forbidden' then
			notice('Command':plural(doubles)..' '..doubles:format()..' already on forbidden list.')
		else
            notice('User':plural(doubles)..' '..doubles:format()..' already on '..aliases[mode]..'.')
        end
    end
    local new = names - settings[mode]
    if not new:empty() then
        settings[mode] = settings[mode] + new
        log('Added '..new:format()..' to the '..aliases[mode]..'.')
    end
end

-- Removes names/items from a given list type.
function remove_item(mode, ...)
    local names = S{...}
    local dummy = names - settings[mode]
    if not dummy:empty() then
        if aliases[mode] == 'nicknames' then
            notice('User':plural(dummy)..' '..dummy:format()..' not found on nickname list.')
        elseif aliases[mode] == 'forbidden' then
			notice('Command':plural(dummy)..' '..dummy:format()..' not found on forbidden list.')
		else
            notice('User':plural(dummy)..' '..dummy:format()..' not found on '..aliases[mode]..'.')
        end
    end
    local item_to_remove = names * settings[mode]
    if not item_to_remove:empty() then
        settings[mode] = settings[mode] - item_to_remove
        log('Removed '..item_to_remove:format()..' from the '..aliases[mode]..'.')
    end
end

windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'status'
    local args = L{...}
    -- Changes whitelist/blacklist mode
    if command == 'mode' then
        local mode = args[1] or 'status'
        if aliases:keyset():contains(mode) then
            settings.mode = aliases[mode]
            log('Mode switched to '..settings.mode..'.')
        elseif mode == 'status' then
            log('Currently in '..settings.mode..' mode.')
        else
            error('Invalid mode:', args[1])
            return
        end
    
	-- Turns Party Lock on or off
    elseif command == 'partylock' then
        status = args[1] or 'status'
        status = string.lower(status)
        if on:contains(status) then
            settings.PartyLock = true
            log('Party Lock turned on.')
        elseif off:contains(status) then
            settings.PartyLock = false
            log('Party Lock turned off.')
        elseif status == 'status' then
            log('Party Lock currently '..display(settings.PartyLock)..'.')
        else
            error('Invalid status:', args[1])
            return
        end

	-- Turns Request Lock on or off
    elseif command == 'requestlock' then
        status = args[1] or 'status'
        status = string.lower(status)
        if on:contains(status) then
            settings.RequestLock = true
            log('Request Lock turned on.')
        elseif off:contains(status) then
            settings.RequestLock = false
            log('Request Lock turned off.')
        elseif status == 'status' then
            log('Request Lock currently '..display(settings.RequestLock)..'.')
        else
            error('Invalid status:', args[1])
            return
        end	
		
	-- Turns Request Lock on or off
    elseif command == 'exactlock' then
        status = args[1] or 'status'
        status = string.lower(status)
        if on:contains(status) then
            settings.ExactLock = true
            log('Exact Lock turned on.')
        elseif off:contains(status) then
            settings.ExactLock = false
            log('Exact Lock turned off.')
        elseif status == 'status' then
            log('Exact Lock currently '..display(settings.ExactLock)..'.')
        else
            error('Invalid status:', args[1])
            return
        end	
		
    elseif aliases:keyset():contains(command) then
        mode = aliases[command]
        names = args:slice(2):map(string.ucfirst..string.lower)
        if args:empty() then
            log(mode:ucfirst()..':', settings[mode]:format('csv'))
        else
            if addstrs:contains(args[1]) then
                add_item(mode, names:unpack())
            elseif rmstrs:contains(args[1]) then
                remove_item(mode, names:unpack())
            else
                notice('Invalid operator specified. Specify add or remove.')
            end
        end
        
    -- Print current settings status
    elseif command == 'status' then
    log('~~~~~~~ Request Settings ~~~~~~~')
    log('Mode:', settings.mode:ucfirst())
    log('Whitelist:', settings.whitelist:empty() and '(empty)' or settings.whitelist:format('csv'))
    log('Blacklist:', settings.blacklist:empty() and '(empty)' or settings.blacklist:format('csv'))
    log('Nicknames:', settings.nicknames:empty() and '(empty)' or settings.nicknames:format('csv'))
    log('Forbidden Commands:', settings.forbidden:empty() and '(empty)' or settings.forbidden:format('csv'))
    log('Party Lock:', display(settings.PartyLock))
    log('Request Lock:', display(settings.RequestLock))
    log('Exact Lock:', display(settings.ExactLock))
    
    -- Ignores (and prints a warning) if unknown command is passed.
    else
        warning('Unkown command \''..command..'\', ignored.')

    end

    config.save(settings)
end)

display = function(setting)
    if class(setting) == 'Set' then
        return setting:empty() and '(empty)' or setting:format('csv')
    elseif class(setting) == 'boolean' then
        return setting and 'On' or 'Off'
    end

    return tostring(setting)
end
