--[[
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- Setup

require 'luau'

_addon = _addon or {}
_addon.name = 'AutoJoin'
_addon.command = 'autojoin'
_addon.short_command = 'aj'
_addon.version = 0.901

defaults = T{}
defaults.mode = 'whitelist'
defaults.whitelist = S{}
defaults.blacklist = S{}
defaults.autodecline = false

-- Statuses which prevents joining.
statusblock = S{
	'Dead', 'Event', 'Charmed'
}

-- Aliases to access correct modes based on supplied arguments.
aliases = T{
	w			= 'whitelist',
	wlist		= 'whitelist',
	white		= 'whitelist',
	whitelist	= 'whitelist',
	b			= 'blacklist',
	blist		= 'blacklist',
	black		= 'blacklist',
	blacklist	= 'blacklist'
}

-- Alias to access the add and remove routines.
addstrs = T{'a', 'add', '+'}
rmstrs = T{'r', 'rm', 'remove', '-'}

modes = T{'whitelist', 'blacklist'}

-- Invite handler
function event_party_invite(sender, senderId, something)
	reset()
	if settings.autodecline and settings.blacklist:contains(sender) then
		send_command('input /decline')
		notice('Blacklisted invite from '..sender..' blocked.')
		return
	end
	
	if settings.mode == 'whitelist' and settings.whitelist:contains(sender)
	or settings.mode == 'blacklist' and not settings.blacklist:contains(sender) then
		try = true
		send_command('wait 1; lua i autojoin try_join')
	end
end

-- Check incoming text for the treasure pool warning.
function event_incoming_text(original, modified, color)
	if original:strip_format() == 'Caution: All unclaimed treasure will be lost if you join a party.' then
		pool = true
	end
	
	return modified, color
end

-- Check outgoing text for joins or declines.
function event_outgoing_text(original, modified)
	if original:isin({'/decline', '/join'}) then
		reset()
	end
end

-- Resets status on zoning.
function event_zone_change(...)
	reset()
end

function reset()
	pool = false
	try = false
end

-- Attempts a join, given certain conditions are met
function try_join()
	if pool or not try then
		return
	end
	
	if statusblock:contains(get_player()['status_id']) then
		send_command('wait 1; lua i autojoin try_join')
		return
	end
	
	send_command('input /join')
	try = false
end

-- Adds names to a given list type.
function add_name(mode, ...)
	local names = S{...}
	local duplicates = names * settings[mode]
	if not duplicates:empty() then
		notice(('User'):plural(duplicates)..' '..duplicates:format()..' already on '..aliases[mode]..'.')
	end
	local new = names - settings[mode]
	if not new:empty() then
		settings[mode] = settings[mode] + new
		log('Added '..new:format()..' to the '..aliases[mode]..'.')
	end
	settings:save()
end

-- Removes names from a given list type.
function rm_name(mode, ...)
	local names = S{...}
	local dummy = names - settings[mode]
	if not dummy:empty() then
		notice(('User'):plural(dummy)..' '..dummy:format()..' not found on '..aliases[mode]..'.')
	end
	local remove = names * settings[mode]
	if not remove:empty() then
		settings[mode] = settings[mode] - remove
		log('Removed '..remove:format()..' from the '..aliases[mode]..'.')
	end
end

-- Interpreter

function event_addon_command(command, ...)
	command = command and command:lower() or 'status'
	local args = T{...}
	
	-- Mode switch
	if command == 'mode' then
		-- If no mode provided, print status.
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
		
	-- List management
	elseif command:isin(aliases:keyset()) then
		mode = aliases[command]
		names = args:slice(2):map(string.ucfirst..string.lower)
		
		-- If no operator provided
		if args:empty() then
			log(mode:ucfirst()..':', settings[mode]:format('csv'))
		else
			if args[1]:isin(addstrs) then
				add_name(mode, names:unpack())
			elseif args[1]:isin(rmstrs) then
				rm_name(mode, names:unpack())
			-- If no qualifier provided
			else
				notice('Invalid operator specified. Specify add or remove.')
			end
		end
		
	-- Auto-decline settings
	elseif command:isin({'decline', 'autodecline', 'auto-decline'}) then
		if args[1] ~= nil then
			local decline = args[1]:lower()
			local check = false
			if decline == 'true' then
				settings.autodecline = true
				check = true
			elseif decline == 'false' then
				settings.autodecline = false
				check = true
			else
				log('Invalid command for autodecline. Specify true or false.')
			end

			if check then
				log('Set auto-decline to '..tostring(settings.autodecline)..'.')
			end
		else
			log('Auto-decline is currently '..(settings.autodecline and 'on' or 'off')..'.')
		end
	
	-- Save settings. This is only needed for global or cross-character settings, as current-chracter settings will be saved every time something is changed.
	elseif command == 'save' then
		local profile = args[1] or 'all'
		settings:save(profile)
		log('Settings saved.')
		
	-- Print current settings status
	elseif command == 'status' then
		log('Mode:', settings.mode)
		log('Whitelist:', settings.whitelist:empty() and '(empty)' or settings.whitelist:format('csv'))
		log('Blacklist:', settings.blacklist:empty() and '(empty)' or settings.blacklist:format('csv'))
		log('Auto-decline:', settings.autodecline)
	
	-- Unknown command handler
	else
		warning('Unkown command \''..command..'\', ignored.')
	end
end

-- Constructor

function event_load()
	reset()
	
	initialize()
	settings:save()

	send_command('alias autojoin lua c autojoin')
	send_command('alias aj autojoin')
end

function event_login()
	initialize()
end

-- Only runs once logged in, to get proper settings.
function initialize()
	-- Load settings from file
	settings = config.load(defaults)
	settings.whitelist = settings.whitelist:map(string.ucfirst..string.lower)
	settings.blacklist = settings.blacklist:map(string.ucfirst..string.lower)
end

-- Destructor
function event_unload()
	send_command('unalias autojoin')
	send_command('unalias aj')
end
