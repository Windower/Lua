--Copyright (c) 2013, Byrthnoth
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


-- Functions that are directly exposed to users --


function debug_mode(boolean)
	if boolean == true or boolean == false then _settings.debug_mode = boolean
	elseif boolean == nil then
		_settings.debug_mode = true
	else
		error('\nGearSwap: show_swaps() was passed an invalid value ('..tostring(boolean)..'). (true/no value/nil=on, false=off)', 2)
	end
end


function show_swaps(boolean)
	if boolean == true or boolean == false then _settings.show_swaps = boolean
	elseif boolean == nil then
		_settings.show_swaps = true
	else
		error('\nGearSwap: show_swaps() was passed an invalid value ('..tostring(boolean)..'). (true/no value/nil=on, false=off)', 2)
	end
end


function verify_equip(boolean)
	print('GearSwap: verify_equip() has been deprecated due to internal changes and no longer has a purpose')
end


function cancel_spell(boolean)
	if _global.current_event ~= 'precast' and _global.current_event ~= 'pretarget' then
		error('\nGearSwap: cancel_spell() is only valid in the precast and pretarget functions', 2)
		return
	end
	if boolean == true or boolean == false then _global.cancel_spell = boolean
	elseif boolean == nil then
		_global.cancel_spell = true
	else
		error('\nGearSwap: cancel_spell() was passed an invalid value ('..tostring(boolean)..'). (true/no value/nil=Cancel the spell, false=do not cancel the spell)', 2)
	end
end

function force_send(boolean)
	print('GearSwap: force_send() has been deprecated due to internal changes and no longer has a purpose')
end

function change_target(name)
	if _global.current_event ~= 'pretarget' then
		error('\nGearSwap: change_target() is only valid in the pretarget function', 2)
		return
	end
	if name and type(name)=='string' then
		local temp_targ
		_global.storedtarget,temp_targ = valid_target(name)
		spell.target = temp_targ
	else
		error('\nGearSwap: change_target() was passed an invalid value ('..tostring(name)..'). (must be a string)', 2)
	end
end

function cast_delay(delay)
	if _global.current_event ~= 'precast' and _global.current_event ~= 'pretarget' then
		error('\nGearSwap: cast_delay() is only valid in the precast and pretarget functions', 2)
		return
	end
	if tonumber(delay) then
		_global.cast_delay = tonumber(delay)
	else
		error('\nGearSwap: cast_delay() was passed an invalid value ('..tostring(delay)..'). (cast delay must be a number of seconds)', 2)
	end
end

-- Combines the provided gear sets into a new set.  Returns the result.
function set_combine(...)
	return set_merge({}, ...)
end

-- Combines the provided gear sets into the equip_list set.
function equip(...)
	set_merge(equip_list, ...)
end

function disable(...)
	local disable_tab = {...}
	if type(disable_tab[1]) == 'table' then
		disable_tab = disable_tab[1] -- Compensates for people passing a table instead of a series of strings.
	end
	for i,v in pairs(disable_tab) do
		if slot_map[v] then
			rawset(disable_table,slot_map[v],true)
		else
			error('\nGearSwap: disable error, passed an unrecognized slot name ('..tostring(v)..').',2)
		end
	end
end

function enable(...)
	local enable_tab = {...}
	if type(enable_tab[1]) == 'table' then
		enable_tab = enable_tab[1] -- Compensates for people passing a table instead of a series of strings.
	end
	items = windower.ffxi.get_items()
	local sending_table = {}
	for i,v in pairs(enable_tab) do
		if slot_map[v] then
			local local_slot = default_slot_map[slot_map[v]]
			disable_table[slot_map[v]] = false
			local potential_gear = not_sent_out_equip[local_slot]
			if potential_gear then
				sending_table[local_slot] = not_sent_out_equip[local_slot]
				not_sent_out_equip[local_slot] = nil
			end
		else
			error('\nGearSwap: enable error, passed an unrecognized slot name ('..tostring(v)..').',2)
		end
	end
	if table.length(sending_table) > 0 then
		refresh_globals()
		equip_sets('equip_command',nil,sending_table)
	end
end

function print_set(set,title)
	if not set then
		if title then
			error('\nGearSwap: print_set error, '..title..' set is nil.', 2)
		else
			error('\nGearSwap: print_set error, set is nil.', 2)
		end
		return
	end
	if title then
		windower.add_to_chat(1,'------------------------- '..tostring(title)..' -------------------------')
	else
		windower.add_to_chat(1,'----------------------------------------------------------------')
	end
	if #set == table.length(set) then
		for i,v in ipairs(set) do
			if type(v) == 'table' and v.name then
				windower.add_to_chat(8,tostring(i)..' '..tostring(v))
			else
				windower.add_to_chat(8,tostring(i)..' '..tostring(v))
			end
		end
	else
		for i,v in pairs(set) do
			if type(v) == 'table' and v.name then
				windower.add_to_chat(8,tostring(i)..' '..tostring(v))
			else
				windower.add_to_chat(8,tostring(i)..' '..tostring(v))
			end
		end
	end
	windower.add_to_chat(1,'----------------------------------------------------------------')
end

function send_cmd_user(command)
	if string.byte(1) ~= 0x40 then
		command='@'..command
	end
	windower.send_command(command)
end

function register_event_user(str,func)
	local id = windower.register_event(str,func)
	rawset(registered_user_events,id,true)
	return id
end

function unregister_event_user(id)
	windower.unregister_event(id)
	rawset(registered_user_events,id,nil)
end

function include_user(str)
	if not (type(str) == 'string') then
		error('\nGearSwap: include() was passed an invalid value ('..tostring(str)..'). (must be a string)', 2)
		return
	end
	if str:sub(-4)~='.lua' then str = str..'.lua' end

	local path, loaded_values = pathsearch({str})
	
	if not path then
		windower.add_to_chat(123,'GearSwap: Include failure. Cannot find file.')
		return
	else
		loaded_values = dofile(path)
	end
	
	for i,v in pairs(loaded_values) do
		rawset(user_env,i,v)
		if type(v) == 'function' then
			setfenv(user_env[i],user_env)
		end
	end
end

function user_midaction(bool)
	if bool == false or bool == true then
		_global.midaction = bool
	elseif bool ~= nil then
		error('\nGearSwap: midaction() was passed an invalid value ('..tostring(bool)..'). (true=true, false=false, nil=nothing)', 2)
	end
	
	for i,v in pairs(out_arr) do
		if v.midaction then
			return true,v.spell
		end
	end
	return false
end


-- Define the user windower functions.
user_windower = {register_event = register_event_user, unregister_event = unregister_event_user, send_command = send_cmd_user}
setmetatable(user_windower,{__index=windower})