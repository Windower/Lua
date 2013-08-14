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


-- Deals with refreshing player information and loading user settings --



-----------------------------------------------------------------------------------
--Name: refresh_globals()
--Args:
---- None
-----------------------------------------------------------------------------------
--Returns:
---- None
---- Updates all global variables to reflect the player's status. Generally run
---- before calling a player function.
-----------------------------------------------------------------------------------
function refresh_globals()
	refresh_player()
	refresh_ffxi_info()
	refresh_group_info()
end

-----------------------------------------------------------------------------------
--Name: load_user_files()
--Args:
---- None
-----------------------------------------------------------------------------------
--Returns:
---- user_env, a table of all of the player defined functions and their current
---- variables.
-----------------------------------------------------------------------------------
function load_user_files()
	if user_env then
		if type(user_env.file_unload)=='function' then user_env.file_unload()
		elseif user_env.file_unload then
			add_to_chat(123,'GearSwap: file_unload() is not a function')
		end
	end
	user_env = nil
	
	if not file_exists(lua_base_path..'data/'..player['name']..'_'..player.main_job..'.lua') then
		user_env = nil
		current_job_file = nil
		return
	end
	user_env = {gearswap = _G, _global = _global,
		-- Player functions
		equip = equip, verify_equip=verify_equip, cancel_spell=cancel_spell,
		force_send=force_send, change_target=change_target, cast_delay=cast_delay,
		print_set=print_set,set_combine=set_combine,
		
		-- Library functions
		string=string, math=math, sets=sets, table=table, T=T, S=S,
		tostring = tostring, tonumber = tonumber, pairs = pairs,
		ipairs = ipairs, write=write, add_to_chat=add_to_chat,
		send_command=send_cmd_user,register_event=register_event,
		require=require,next=next,
		
		-- Player environment things
		buffactive=buffactive,
		player=player,
		world=world,
		pet=pet,
		alliance=alliance,
		party=alliance[1]
		}

	-- Try to load data/<name>_<main job>.lua
	local funct, err = loadfile(lua_base_path..'data/'..player['name']..'_'..player.main_job..'.lua')
	
	-- If the file cannot be loaded, print the error and load the default.
	if funct == nil then 
		write('User file problem: '..err)
		current_job_file = nil
		return
	else
		current_job_file = player.main_job
		write('Loaded your '..player.main_job..' Lua file!')
	end
	
	setfenv(funct, user_env)
	
	-- Verify that funct contains functions.
	local status, plugin = pcall(funct)
	if not status then
		error('Plugin failed to load: \n'..plugin)
		return nil
	end
	
	if type(user_env.get_sets) == 'function' then
		user_env.get_sets()
	elseif user_env.get_sets then
		add_to_chat(123,'GearSwap: get_sets() is defined but is not a function.')
	end
	
end


-----------------------------------------------------------------------------------
--Name: refresh_player()
--Args:
---- None
-----------------------------------------------------------------------------------
--Returns:
---- None
----
---- Loads player from get_player().
---- Adds in a "job", "race", "equipment", "target", and "subtarget" field
---- Also updates "pet" and assigns isvalid and element fields.
---- Further converts player.buffs to buffactive.
-------- Indexes buffs by their buff name and assigns a value equal to the number
-------- of buffs with that name active.
-----------------------------------------------------------------------------------
function refresh_player()
	table.reassign(player,get_player())
	for i,v in pairs(player['vitals']) do
		player[i]=v
	end
	if player.main_job == 'NONE' then
		player.main_job = 'MON'
	end
	player.job = player.main_job..'/'..player.sub_job
	
	local player_mob_table = get_mob_by_index(player['index'])
	
	if player_mob_table['race']~= nil then player.race = mob_table_races[player_mob_table['race']] end
	
	items = get_items()
	local cur_equip = items['equipment'] -- i = 'head', 'feet', etc.; v = inventory ID (0~80)
	if sent_out_equip then -- If the swap is not complete, overwrite the current equipment with the equipment that you are swapping to
		for i,v in pairs(cur_equip) do
			if sent_out_equip[slot_map[i]] then
				cur_equip[i] = sent_out_equip[slot_map[i]]
			end
		end
	end
	
	-- Assign player.equipment to be the gear that has been sent out and the server currently thinks
	-- you are wearing. (the sent_out_equip for loop above).
	player.equipment = to_names_set(cur_equip,items['inventory'])
	
	-- Monster tables for the target and subtarget.
	player.target = target_type(get_mob_by_target('t'))
	player.subtarget = target_type(get_mob_by_target('lastst'))
	
	-- If you have a pet, make a pet table.
	if player_mob_table['pet_index'] ~= 0 then
		table.reassign(pet,get_mob_by_index(player_mob_table['pet_index']))
		pet.isvalid = true
		if avatar_element[pet.name] then
			pet.element = avatar_element[pet.name]
		else
			pet.element = 'None'
		end
	else
		table.reassign(pet,{isvalid=false})
	end
	
	table.reassign(buffactive,get_buff_active(player['buffs']))
end


-----------------------------------------------------------------------------------
--Name: refresh_ffxi_info()
--Args:
---- None
-----------------------------------------------------------------------------------
--Returns:
---- None
----
---- Updates the global "world" with get_ffxi_info (ignores the target field).
---- Also sets get_ffxi_info()['zone'] to be world.area for consistency with spellcast
-----------------------------------------------------------------------------------
function refresh_ffxi_info()
	local info = get_ffxi_info()
	for i,v in pairs(info) do
		if i ~= 'target' then
			world[i] = v
		end
		if i == 'zone' then
			world.area = v
		end
	end
	world.real_weather = info.weather
	world.real_weather_element = info.weather_element
	if buffactive['voidstorm'] then
		world.weather = 'dark'
		world.weather_element = 'dark'
	elseif buffactive['aurorastorm'] then
		world.weather = 'light'
		world.weather_element = 'light'
	elseif buffactive['firestorm'] then
		world.weather = 'fire'
		world.weather_element = 'fire'
	elseif buffactive['sandstorm'] then
		world.weather = 'earth'
		world.weather_element = 'earth'
	elseif buffactive['rainstorm'] then
		world.weather = 'water'
		world.weather_element = 'water'
	elseif buffactive['windstorm'] then
		world.weather = 'wind'
		world.weather_element = 'wind'
	elseif buffactive['hailstorm'] then
		world.weather = 'ice'
		world.weather_element = 'ice'
	elseif buffactive['thunderstorm'] then
		world.weather = 'thunder'
		world.weather_element = 'thunder'
	end
end


-----------------------------------------------------------------------------------
--Name: refresh_group_info()
--Args:
---- None
-----------------------------------------------------------------------------------
--Returns:
---- None
----
---- Takes the mob arrays from get_party() and splits them from p0~5, a10~15, a20~25
---- into alliance[1][1~6], alliance[2][1~6], alliance[3][1~6], respectively.
---- Also adds a "count" field to alliance (total number of people in alliance) and
---- to the individual subtables (total number of people in each party.
-----------------------------------------------------------------------------------
function refresh_group_info()
	local temp_alliance = {[1]={count=0},[2]={count=0},[3]={count=0}}
	local j = get_party()
	for i,v in pairs(j) do
		if i:sub(1) == 'p' then
			temp_alliance[1][tonumber(i:sub(2))+1] = v
			temp_alliance[1]['count'] = temp_alliance[1]['count'] +1
		elseif i:sub(1,2) == 'a1' then
			temp_alliance[2][tonumber(i:sub(3))+1] = v
			temp_alliance[2]['count'] = temp_alliance[2]['count'] +1
		elseif i:sub(1,2) == 'a2' then
			temp_alliance[3][tonumber(i:sub(3))+1] = v
			temp_alliance[3]['count'] = temp_alliance[3]['count'] +1
		end
	end
	table.reassign(alliance,temp_alliance)
	alliance['count'] = temp_alliance[1]['count'] + temp_alliance[2]['count'] + temp_alliance[3]['count']
end

-----------------------------------------------------------------------------------
--Name: get_buff_active(bufflist)
--Args:
---- bufflist (table): List of buffs from get_player()['buffs']
-----------------------------------------------------------------------------------
--Returns:
---- buffarr (table)
---- buffarr is indexed by the string buff name and has a value equal to the number
---- of that string present in the buff array. So two marches would give
---- buffarr.march==2.
-----------------------------------------------------------------------------------
function get_buff_active(bufflist)
	buffarr = {}
	for i,v in pairs(bufflist) do
		if r_status[v] then -- For some reason we always have buff 255 active, which doesn't have an entry.
			local buff = r_status[v][language]:lower()
			if buffarr[buff] then
				buffarr[buff] = buffarr[buff] +1
			else
				buffarr[buff] = 1
			end
		end
	end
	return buffarr
end


-----------------------------------------------------------------------------------
--Name: refresh_user_env()
--Args:
---- none
-----------------------------------------------------------------------------------
--Returns:
---- none, but loads user files if they exist.
-----------------------------------------------------------------------------------
function refresh_user_env()
	refresh_globals()
	load_user_files()
--	if player then
--		if player.job == 'NONE' then
--			gearswap_disabled = true
--			sets = nil
--			user_env = nil
--			return
--		end
--	end
	if not user_env then
		gearswap_disabled = true
		sets = nil
	else
		gearswap_disabled = false
		sets = user_env.sets
	end
end