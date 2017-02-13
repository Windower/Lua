--[[Copyright © 2014-2017, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Nostrum nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL trv BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER I N CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

_addon.name = 'Nostrum_dev'
_addon.author = 'trv'
_addon.version = '3.0'
_addon.commands = {'Nostrum', 'nos'}

nostrum = {}

require 'sets'
require 'pack'
require 'lists'
require 'tables'
require 'strings'

xml = require 'xml'
bit = require 'bit'
json = require 'json'
files = require 'files'
res = require 'resources'
config = require 'config'
packets = require 'packets'

parties = require 'parties'
players = require 'players'

do
	--[[
		Grab the widgets library, which is "temporarily" stored
		in the wip folder.
	--]]
	local pattern = package.path
	local temp_pattern = windower.addon_path 
		.. 'wip/?.lua;' .. pattern
	
	package.path = temp_pattern
	
	widgets = require 'widgets'
	
	package.path = pattern
end

require 'global_definitions'
require 'event_handling'
require 'packet_parsing'
require 'helper_functions'
require 'user_environment'

do
	local _print = print
	print = function(...)
		_print(_addon.name, ...)
	end
	
	-- clean up old files
	local old_files = {
		'helperfunctions.lua',
		'variables.lua',
		'prims.lua',
	}

	for i = 1, #old_files do
		local file_path = windower.addon_path .. old_files[i]
		
		if windower.file_exists(file_path) then
			os.remove(file_path)
		end
	end
end

nostrum.state = {
	running = false,
	hidden = false,
	initializing = false,
}

nostrum.available = function()
	local state = nostrum.state
	
	return state.running and not state.hidden
end

nostrum.windower_event_ids = T{}

nostrum.event_listeners = {	
	['logout'] = function()
		nostrum.state.running = false
		nostrum.state.hidden = true
		
		for i = 1, 3 do
			alliance[i]:dissolve()
		end
		
		for id, t in pairs(alliance_lookup) do
			alliance_lookup[id] = nil
		end
		
		call_events('unload')
		clean_up_user_env()
		_G.sandbox = nil
		unregister_events()
	end,
	
	['target change'] = function(index)
		-- Update stuff other than HP?
		local mob = windower.ffxi.get_mob_by_index(index)
		
		target = mob or {index = 0, hpp = 0}
		
		local mob_readonly = readonly(mob)
		
		sandbox.target = mob_readonly
		call_events('target change', mob_readonly)
	end,
	
	['mouse'] = function(...)
		if nostrum.available() then
			local block = widget_listener(...)
			
			if block then return true end
			
			block = call_events('mouse input', ...)
			
			if block then return true end
		end
	end,
	
	['keyboard'] = function(...)
		if nostrum.available() then
			call_events('keyboard input', ...)
		end
	end,
	
	['zone change'] = function(new_id, old_id)
		-- No 0x0C8 packet is sent for solo players who zone after summoning trusts
		-- Kick trusts summoned while solo
		
		if alliance[2]:count() == 0 and alliance[3]:count() == 0 then
			local party = alliance[1]
			local kick = L{}
			local is_player_solo = true
			
			for i = party:count(), 2, -1 do
				local id = party[i]
				
				if alliance_lookup[id].is_trust then
					kick:append(id)
				else
					is_player_solo = false
					break
				end
			end
			
			if is_player_solo then
				for i = 1, kick.n do
					local id = kick[i]
					
					alliance_lookup[id] = nil
					local spot = party:kick(id)
					call_events('member leave', 1, spot)
				end
			end
		
		end
		
		low_level_visibility(true)
		call_events('zone change', new_id, old_id)
	end,
	
	['job change'] = function(main, main_level, sub, sub_level)
		call_events('job change', main, main_level, sub, sub_level)
	end,

	['addon command'] = function(...)
		call_events('addon command', ...)
	end,
}

nostrum.event_listeners['gain buff'] = function(id)
	buff_gain = true
end

nostrum.event_listeners['lose buff'] = function(id)
	buff_loss = true
end

do
	local parse = parse_lookup.incoming
	
	nostrum.event_listeners['incoming chunk'] = function(id, data)
		if parse[id] then
			parse[id](data)
		end
	end
end

do
	local parse = parse_lookup.outgoing
	
	nostrum.event_listeners['outgoing chunk'] = function(id, data)
		if parse[id] then
			parse[id](data)
		end
	end
end

windower.register_event('addon command', function(...)
	local args = {...}
	local c = args[1] and args[1]:lower() or 'help'

	if c == 'help' then
		print(help_text)
	elseif c == 'visible' or c == 'v' then
		local visible = not nostrum.state.hidden
		nostrum.state.hidden = visible

		low_level_visibility(visible)
		
		--[[if nostrum.state.running then
			call_events('visibility change', visible)
		end--]]
	elseif c == 'refresh' or c == 'r' then
		compare_alliance_to_memory()
	elseif c == 'send' or c == 's' then
		if args[2] then
			local name = tostring(args[2])
			send_string = 'send %s ':format(name)
			print('Commands will be sent to: ' .. name)
		else
			send_string = ''
			print('Input contained no name. Send disabled.')
		end
	elseif c == 'overlay' or c == 'o' then
		if not args[2] then
			print('Specify overlay file')
		else
			call_events('unload')
			clean_up_user_env()
			_G.sandbox = nil
			
			local name = tostring(args[2])
			
			initialize(name)
		end
	end
end)

windower.register_event('login', function()
	if not nostrum.state.initializing then
		stall_for_player()
	end
end)

function register_events()
	for event, fn in pairs(nostrum.event_listeners) do
		nostrum.windower_event_ids:append(windower.register_event(event, fn))
	end
end

function unregister_events()
	windower.unregister_event(unpack(nostrum.windower_event_ids))
	nostrum.windower_event_ids = T{}
end

function stall_for_player()
	nostrum.state.initializing = true
	
	local player = windower.ffxi.get_player()
	
	if player then
		local mob = windower.ffxi.get_mob_by_index(player.index)
		
		if not mob then
			coroutine.schedule(stall_for_player, 2)
			return
		end
		
		pc = {
			id = player.id,
			index = player.index,
			pos = {}
		}
		
		pc.pos.x = mob.x
		pc.pos.y = mob.y
		
		initialize(config.load({overlay = 'MsJans'}).overlay)
		
		pc.buffs = alliance_lookup[pc.id].buffs
	else
		coroutine.schedule(stall_for_player, 2)
	end
end

stall_for_player()
