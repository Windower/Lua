-- Functions that are directly exposed to users --


function debug_mode(boolean)
	if boolean == true or boolean == false then _global.debug_mode = boolean
	elseif boolean == nil then
		_global.debug_mode = true
	else
		add_to_chat(123,'GearSwap: debug_mode was passed an invalid value')
	end
end


function show_swaps(boolean)
	if boolean == true or boolean == false then _global.show_swaps = boolean
	elseif boolean == nil then
		_global.show_swaps = true
	else
		add_to_chat(123,'GearSwap: show_swaps was passed an invalid value')
	end
end


function verify_equip(boolean)
	if boolean == true or boolean == false then _global.verify_equip = boolean
	elseif boolean == nil then
		_global.verify_equip = true
	else
		add_to_chat(123,'GearSwap: verify_equip was passed an invalid value')
	end
end


function cancel_spell(boolean)
	if boolean == true or boolean == false then _global.cancel_spell = boolean
	elseif boolean == nil then
		_global.cancel_spell = true
	else
		add_to_chat(123,'GearSwap: cancel_spell was passed an invalid value')
	end
end

function force_send(boolean)
	if boolean == true or boolean == false then _global.force_send = boolean
	elseif boolean == nil then
		_global.force_send = true
	else
		add_to_chat(123,'GearSwap: force_send was passed an invalid value')
	end
end

function change_target(name)
	if name and type(name)=='string' then _global.storedtarget = name else
		add_to_chat(123,'GearSwap: change_target was passed an invalid value')
	end
end

function cast_delay(delay)
	if tonumber(delay) then
		_global.cast_delay = tonumber(delay)
	else
		add_to_chat(123,'GearSwap: Cast delay is not a number')
	end
end

function set_combine(set1,set2)
	if set1 == nil then add_to_chat(123,'GearSwap: set_combine error, Set 1 is nil') end
	if set2 == nil then add_to_chat(123,'GearSwap: set_combine error, Set 2 is nil') end
	local set3 = {}
	for i,v in pairs(set1) do
		if slot_map[i] then
			set3[default_slot_map[slot_map[i]]] = v
		else
			add_to_chat(123,'GearSwap: set_combine error, Set 1 contains an unrecognized slot name ('..i..')')
		end
	end
	for i,v in pairs(set2) do
		if slot_map[i] then
			set3[default_slot_map[slot_map[i]]] = v
		else
			add_to_chat(123,'Gearswap: set_combine error, Set 2 contains an unrecognized slot name ('..i..')')
		end
	end
	return set3
end

function equip(...)
	local gearsets = {...}
	for i in ipairs(gearsets) do
		local temp_set = unify_slots(gearsets[i])
		for n,m in pairs(temp_set) do
			rawset(equip_list,n,m)
		end
	end
end

function print_set(set,title)
	if title then
		add_to_chat(1,'------------------------- '..title..' -------------------------')
	else
		add_to_chat(1,'----------------------------------------------------------------')
	end
	for i,v in pairs(set) do
		add_to_chat(8,tostring(i)..' '..tostring(v))
	end
	add_to_chat(1,'----------------------------------------------------------------')
end

function send_cmd_user(command)
	if string.byte(1) ~= 0x40 then
		command='@'..command
	end
	send_command(command)
end