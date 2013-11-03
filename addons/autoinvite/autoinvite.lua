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

require 'luau'

_addon = _addon or {}
_addon.name = 'AutoInvite'
_addon.commands = {'autoinvite','ai'}
_addon.version = 1.0

settings = T{}
settings.mode = 'whitelist'
settings.whitelist = S{}
settings.blacklist = S{}
settings.keywords = S{}
settings.tellback = 'on'

-- Statuses that stop you from sending invites.
statusblock = S{
	'Dead', 'Event', 'Charmed'
}

-- Aliases to access correct modes based on supplied arguments.
aliases = T{
	wlist		= 'whitelist',
	white		= 'whitelist',
	whitelist	= 'whitelist',
	blist		= 'blacklist',
	black		= 'blacklist',
	blacklist	= 'blacklist',
	key			= 'keywords',
	keyword		= 'keywords',
	keywords	= 'keywords'	
}

-- Aliases to access the add and item_to_remove routines.
addstrs = T{'a', 'add', '+'}
rmstrs = T{'r', 'rm', 'remove', '-'}

-- Aliases for tellback mode.
on = T{'on', 'yes', 'true'}
off = T{'off', 'no', 'false'}

modes = T{'whitelist', 'blacklist'}

-- Check for keyword
windower.register_event("chat message", function(is_gm, mode, player, message)
	local word = false
	if mode == 3 then
		for item,_ in pairs(settings.keywords) do
			if string.find(string.lower(message), string.lower(item)) then
				word = true
			end
		end
		-- if keyword is not found, return
		if word == false then
			return
		end
		
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

-- Attempts to send an invite
function try_invite(player)
	if get_party()['p5'] then
		notice(player.. 'cannot be invited - party is full')
		if settings.tell_back == 'on' then
			send_command('input /t '..player..' Party is currently full.')
		end
		return
	end
	
	if statusblock:contains(get_player()['status_id']) then
		notice(player.. 'cannot be invited - you cannot send an invite at this time (dead, charmed, event).')
		if settings.tell_back == 'on' then
			send_command('input /t '..player..' An invite cannot be sent at this time (dead, charmed, event).')
		end
		return
	end
	
	send_command('input /pcmd add '..player)
end

-- Adds names/items to a given list type.
function add_item(mode, ...)
	local names = S{...}
	local doubles = names * settings[mode]
	if not doubles:empty() then
		if aliases[mode] == 'keywords' then
			notice(('Keyword'):plural(doubles)..' '..doubles:format()..' already on keyword list.')
		else
			notice(('User'):plural(doubles)..' '..doubles:format()..' already on '..aliases[mode]..'.')
		end
	end
	local new = names - settings[mode]
	if not new:empty() then
		settings[mode] = settings[mode] + new
		log('Added '..new:format()..' to the '..aliases[mode]..'.')
	end
	settings:save()
end

-- Removes names/items from a given list type.
function remove_item(mode, ...)
	local names = S{...}
	local dummy = names - settings[mode]
	if not dummy:empty() then
		if aliases[mode] == 'keywords' then
			notice(('Keyword'):plural(dummy)..' '..dummy:format()..' not found on keyword list.')
		else
			notice(('User'):plural(dummy)..' '..dummy:format()..' not found on '..aliases[mode]..'.')
		end
	end
	local item_to_remove = names * settings[mode]
	if not item_to_remove:empty() then
		settings[mode] = settings[mode] - item_to_remove
		log('Removed '..item_to_remove:format()..' from the '..aliases[mode]..'.')
	end
	settings:save()
end

windower.register_event('addon command',function (command, ...)
	command = command and command:lower() or 'status'
	local args = T{...}
	
	-- Changes whitelist/blacklist mode
	if command == 'mode' then
		local mode = args[1] or 'status'
		if mode:isin(aliases:keyset()) then
			settings.mode = aliases[mode]
			log('Mode switched to '..settings.mode..'.')
		elseif mode == 'status' then
			log('Currently in '..settings.mode..' mode.')
		else
			error('Invalid mode:', args[1])
			return
		end
	
	-- Turns tellback on or off
	elseif command == 'tellback' then
		status = args[1] or 'status'
		status = string.lower(status)
		if status:isin(on) then
			settings.tellback = 'on'
			log('Tellback turned on.')
		elseif status:isin(off) then
			settings.tellback = 'off'
			log('Tellback turned off.')
		elseif status == 'status' then
			log('Tellback currently '..settings.tellback..'.')
		else
			error('Invalid status:', args[1])
			return
		end
		
	elseif command:isin(aliases:keyset()) then
		mode = aliases[command]
		names = args:slice(2):map(string.ucfirst..string.lower)
		if args:empty() then
			log(mode:ucfirst()..':', settings[mode]:format('csv'))
		else
			if args[1]:isin(addstrs) then
				add_item(mode, names:unpack())
			elseif args[1]:isin(rmstrs) then
				remove_item(mode, names:unpack())
			else
				notice('Invalid operator specified. Specify add or remove.')
			end
		end
		
	-- Print current settings status
	elseif command == 'status' then
		log('Mode:', settings.mode)
		log('Tell Back:', settings.tellback)
		log('Whitelist:', settings.whitelist:empty() and '(empty)' or settings.whitelist:format('csv'))
		log('Blacklist:', settings.blacklist:empty() and '(empty)' or settings.blacklist:format('csv'))
		log('Keywords:', settings.keywords:empty() and '(empty)' or settings.keywords:format('csv'))
	
	-- Ignores (and prints a warning) if unknown command is passed.
	else
		warning('Unkown command \''..command..'\', ignored.')
	end
	settings:save()
end)

windower.register_event('load',function ()	
	initialize()
	settings:save()
end)

windower.register_event('login',function ()
	initialize()
end)

function initialize()
	-- Load settings from file
	settings = config.load(settings)
	settings.whitelist = settings.whitelist:map(string.ucfirst..string.lower)
	settings.blacklist = settings.blacklist:map(string.ucfirst..string.lower)
end

windower.register_event('unload', function ()
	settings:save()
end)