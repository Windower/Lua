--Copyright (c) 2013~2016, Byrthnoth
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
function refresh_globals(user_event_flag)
    local current = os.clock()
    local dt = current - last_refresh
    if not user_event_flag or dt > 0.05 then
        refresh_player(dt,user_event_flag)
        refresh_ffxi_info(dt,user_event_flag)
        refresh_group_info(dt,user_event_flag)
        last_refresh = current
    end
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
function load_user_files(job_id,user_file)
    job_id = tonumber(job_id)
    
    if current_file then
        user_pcall('file_unload',current_file)
    end
    
    for i in pairs(registered_user_events) do
        unregister_event_user(i)
    end
    
    for i in pairs(__raw.text.registry) do
        windower.text.delete(i)
    end
    
    for i in pairs(__raw.prim.registry) do
        windower.prim.delete(i)
    end
    
    current_file = nil
    gearswap_disabled = true
    sets = nil
    user_env = nil
    unhandled_command_events = {}
    --registered_user_events = {}
    include_user_path = nil
    
    language = 'english' -- Reset language to english when changing job files.
    refresh_globals()
    
    if job_id and res.jobs[job_id] then
        player.main_job_id = job_id
        update_job_names()
    end
    
    
    local path,base_dir,filename
    path,base_dir,filename = pathsearch({user_file})
    if not path then
        local long_job = res.jobs[job_id].english
        local short_job = res.jobs[job_id].english_short
        local tab = {player.name..'_'..short_job..'.lua',player.name..'-'..short_job..'.lua',
            player.name..'_'..long_job..'.lua',player.name..'-'..long_job..'.lua',
            player.name..'.lua',short_job..'.lua',long_job..'.lua','default.lua'}
        path,base_dir,filename = pathsearch(tab)
    end
    
    if not path then
        current_file = nil
        gearswap_disabled = true
        sets = nil
        return
    end

    user_env = {gearswap = _G, _global = _global, _settings = _settings,_addon=_addon,
        -- Player functions
        equip = equip, cancel_spell=cancel_spell, change_target=change_target, cast_delay=cast_delay,
        print_set=print_set,set_combine=set_combine,disable=disable,enable=user_enable,
        send_command=send_cmd_user,windower=user_windower,include=include_user,
        midaction=user_midaction,pet_midaction=user_pet_midaction,set_language=set_language,
        show_swaps = show_swaps,debug_mode=debug_mode,include_path=user_include_path,
        register_unhandled_command=user_unhandled_command,move_spell_target=move_spell_target,
        language=language,
        
        -- Library functions
        string=string,math=math,table=table,set=set,list=list,T=T,S=S,L=L,pack=pack,functions=functions,
        os=os,texts=texts,bit=bit,type=type,tostring=tostring,tonumber=tonumber,pairs=pairs,
        ipairs=ipairs, print=print, add_to_chat=add_to_chat_user,unpack=unpack,next=next,
        select=select,lua_base_path=windower.addon_path,empty=empty,file=file,
        loadstring=loadstring,assert=assert,error=error,pcall=pcall,io=io,dofile=dofile,
        
        debug=debug,coroutine=coroutine,setmetatable=setmetatable,getmetatable=getmetatable,
        rawset=rawset,rawget=rawget,require=include_user,
        _libs=_libs,
        
        -- Player environment things
        buffactive=buffactive,
        player=player,
        world=world,
        pet=pet,
        fellow=fellow,
        alliance=alliance,
        party=alliance[1],
        sets={naked = {main=empty,sub=empty,range=empty,ammo=empty,
                head=empty,neck=empty,ear1=empty,ear2=empty,
                body=empty,hands=empty,ring1=empty,ring2=empty,
                back=empty,waist=empty,legs=empty,feet=empty}}
        }
    
    user_env['_G'] = user_env
    
    -- Try to load data/<name>_<main job>.lua
    local funct, err = loadfile(path)
    
    -- If the file cannot be loaded, print the error and load the default.
    if funct == nil then
        print('User file problem: '..err)
        current_file = nil
        gearswap_disabled = true
        sets = nil
        return
    else
        current_file = filename
        print('GearSwap: Loaded your '..current_file..' file!')
    end
    
    setfenv(funct, user_env)
    
    -- Verify that funct contains functions.
    local status, plugin = pcall(funct)
    
    if not status then
        error('GearSwap: File failed to load: \n'..plugin)
        gearswap_disabled = true
        sets = nil
        return nil
    end
    
    _global.pretarget_cast_delay = 0
    _global.precast_cast_delay = 0
    _global.cancel_spell = false
    _global.current_event = 'get_sets'
    user_pcall('get_sets')
    
    gearswap_disabled = false
    sets = user_env.sets
end


-----------------------------------------------------------------------------------
--Name: refresh_player()
--Args:
---- None
-----------------------------------------------------------------------------------
--Returns:
---- None
----
---- Loads player from windower.ffxi.get_player().
---- Adds in a "job", "race", "equipment", "target", and "subtarget" field
---- Also updates "pet" and assigns isvalid and element fields.
---- Further converts player.buffs to buffactive.
-------- Indexes buffs by their buff name and assigns a value equal to the number
-------- of buffs with that name active.
-----------------------------------------------------------------------------------
function refresh_player(dt,user_event_flag)
    local pl, player_mob_table
    if not user_event_flag or dt > 0.5 then
        pl = windower.ffxi.get_player()
        if not pl or not pl.vitals then return end
                
        player_mob_table = windower.ffxi.get_mob_by_index(pl.index)
        if not player_mob_table then return end
        
        table.reassign(player,pl)
        for i,v in pairs(player.vitals) do
            player[i]=v
        end
        update_job_names()
        player.status_id = player.status
        if res.statuses[player.status] then
            player.status = res.statuses[player.status].english
        else
            print(player.status_id)
        end
        player.nation_id = player.nation
        player.nation = res.regions[player.nation_id][language] or 'None'
    
        for i,v in pairs(player_mob_table) do
            if i == 'name' then
                player.mob_name = v
            elseif i~= 'is_npc' and i~='tp' and i~='mpp' and i~='claim_id' and i~='status' then
                player[i] = v
            end
        end
    
        if player_mob_table.race ~= nil then
            player.race_id = player.race
            player.race = res.races[player.race][language]
        end
        
        -- If we have a pet, create or update the table info.
        if player_mob_table and player_mob_table.pet_index then
            local player_pet_table = windower.ffxi.get_mob_by_index(player_mob_table.pet_index)
            if player_pet_table then
                table.reassign(pet, target_complete(player_pet_table))
                pet.claim_id = nil
                pet.is_npc = nil
                pet.isvalid = true
                if pet.tp then pet.tp = pet.tp/10 end
                
                if avatar_element[pet.name] then
                    pet.element = res.elements[avatar_element[pet.name]][language]
                else
                    pet.element = res.elements[-1][language] -- Physical
                end
            else
                table.reassign(pet, {isvalid=false})
            end
        else
            table.reassign(pet, {isvalid=false})
        end
        
        if player.main_job_id == 18 or player.sub_job_id == 18 then
            local auto_tab
            if player.main_job_id == 18 then auto_tab = windower.ffxi.get_mjob_data()
            else auto_tab = windower.ffxi.get_sjob_data() end
            
            if auto_tab.name then
                for i,v in pairs(auto_tab) do
                    if not T{'available_heads','attachments','available_frames','available_attachments','frame','head'}:contains(i) then
                        pet[i] = v
                    end
                end
                pet.available_heads = make_user_table()
                pet.attachments = make_user_table()
                pet.available_frames = make_user_table()
                pet.available_attachments = make_user_table()

                -- available parts
                for i,id in pairs(auto_tab.available_heads) do
                    if res.items[id] and type(res.items[id]) == 'table' then
                        pet.available_heads[res.items[id][language]] = true
                    end
                end
                for i,id in pairs(auto_tab.available_frames) do
                    if res.items[id] and type(res.items[id]) == 'table' then
                        pet.available_frames[res.items[id][language]] = true
                    end
                end
                for i,id in pairs(auto_tab.available_attachments) do
                    if res.items[id] and type(res.items[id]) == 'table' then
                        pet.available_attachments[res.items[id][language]] = true
                    end
                end

                -- actual parts
                pet.head = res.items[auto_tab.head][language]
                pet.frame = res.items[auto_tab.frame][language]
                for i,id in pairs(auto_tab.attachments) do
                    if res.items[id] and type(res.items[id]) == 'table' then
                        pet.attachments[res.items[id][language]] = true
                    end
                end
                
                if pet.max_mp ~= 0 then
                    pet.mpp = math.floor(pet.mp/pet.max_mp*100)
                else
                    pet.mpp = 0
                end
            end
        elseif player.main_job_id == 23 then
            local species_id = windower.ffxi.get_mjob_data().species
            -- Should add instincts when they become available
            
            if species_id then
                player.species = {}
                for i,v in pairs(res.monstrosity[species_id]) do
                    player.species[i] = v
                end
                player.species.name = player.species[language] 
                player.species.tp_moves = copy_entry(res.monstrosity[species_id].tp_moves)
                for i,v in pairs(player.species.tp_moves) do
                    if v > player.main_job_level then
                        player.species.tp_moves[i] = nil
                    end
                end
            end
        else
            player.species = nil
        end
    end
    
    -- This being nil does not cause a return, but items should not really be changing when zoning.
    local cur_equip = table.reassign({},items.equipment)
            
    -- Assign player.equipment to be the gear that has been sent out and the server currently thinks
    -- you are wearing. (the sent_out_equip for loop above).
    player.equipment = make_user_table()
    table.reassign(player.equipment,to_names_set(cur_equip))
    
    -- Assign player.inventory to be keyed to item.inventory[i][language] and to have a value of count, similar to buffactive
    for i,bag in pairs(res.bags) do
        local bag_name = to_windower_bag_api(bag.en)
        if items[bag_name] then player[bag_name] = refresh_item_list(items[bag_name]) end
    end

    -- Monster tables for the target and subtarget.
    player.target = target_complete(windower.ffxi.get_mob_by_target('t'))
    player.subtarget = target_complete(windower.ffxi.get_mob_by_target('st'))
    player.last_subtarget = target_complete(windower.ffxi.get_mob_by_target('lastst'))
    
    
    
    table.reassign(fellow,target_complete(windower.ffxi.get_mob_by_target('<ft>')))
    if fellow.name then
        fellow.isvalid = true
    else
        fellow.isvalid=false
    end
    
    table.reassign(buffactive,convert_buff_list(player.buffs))
    
    for global_variable_name,extradatatable in pairs(_ExtraData) do
        if _G[global_variable_name] then
            for sub_variable_name,value in pairs(extradatatable) do
                _G[global_variable_name][sub_variable_name] = value
            end
        end
    end
end

-----------------------------------------------------------------------------------
--Name: refresh_ffxi_info()
--Args:
---- None
-----------------------------------------------------------------------------------
--Returns:
---- None
----
---- Updates the global "world" with windower.ffxi.get_info (ignores the target field).
---- Also sets windower.ffxi.get_info()['zone'] to be world.area for consistency with spellcast
-----------------------------------------------------------------------------------
function refresh_ffxi_info(dt,user_event_flag)
    local info = windower.ffxi.get_info()
    for i,v in pairs(info) do
        if i == 'zone' and res.zones[v] then
            world.zone = res.zones[v][language]
            world.area = world.zone
        elseif i == 'weather' and res.weather[v] then
            weather_update(v)
        elseif i == 'day' and res.days[v] then
            world.day = res.days[v][language]
            world.day_element = res.elements[res.days[v].element][language]
        elseif i == 'moon' then
            world.moon_pct = v
        elseif i == 'moon_phase' and res.moon_phases[v] then
            world.moon = res.moon_phases[v][language]
        elseif i ~= 'target' then
            world[i] = v
        end
    end
    
    for global_variable_name,extradatatable in pairs(_ExtraData) do
        if _G[global_variable_name] then
            for sub_variable_name,value in pairs(extradatatable) do
                _G[global_variable_name][sub_variable_name] = value
            end
        end
    end
end


-----------------------------------------------------------------------------------
--Name: weather_update(id)
--Args:
---- id  Current weather ID
-----------------------------------------------------------------------------------
--Returns:
---- None, updates the table.
-----------------------------------------------------------------------------------
function weather_update(id)
    world.weather_id = id
    world.real_weather_id = id
    world.real_weather = res.weather[id][language]
    world.real_weather_element = res.elements[res.weather[id].element][language]
    world.real_weather_intensity = res.weather[world.real_weather_id].intensity
    if buffactive[178] then
        world.weather_id = 4
    elseif buffactive[179] then
        world.weather_id = 12
    elseif buffactive[180] then
        world.weather_id = 10
    elseif buffactive[181] then
        world.weather_id = 8
    elseif buffactive[182] then
        world.weather_id = 14
    elseif buffactive[183] then
        world.weather_id = 6
    elseif buffactive[184] then
        world.weather_id = 16
    elseif buffactive[185] then
        world.weather_id = 18
    elseif buffactive[589] then
        world.weather_id = 5
    elseif buffactive[590] then
        world.weather_id = 13
    elseif buffactive[591] then
        world.weather_id = 11
    elseif buffactive[592] then
        world.weather_id = 9
    elseif buffactive[593] then
        world.weather_id = 15
    elseif buffactive[594] then
        world.weather_id = 7
    elseif buffactive[595] then
        world.weather_id = 17
    elseif buffactive[596] then
        world.weather_id = 19
    end
    world.weather = res.weather[world.weather_id][language]
    world.weather_element = res.elements[res.weather[world.weather_id].element][language]
    world.weather_intensity = res.weather[world.weather_id].intensity
end


-----------------------------------------------------------------------------------
--Name: refresh_group_info()
--Args:
---- None
-----------------------------------------------------------------------------------
--Returns:
---- None
----
---- Takes the mob arrays from windower.ffxi.get_party() and splits them from p0~5, a10~15, a20~25
---- into alliance[1][1~6], alliance[2][1~6], alliance[3][1~6], respectively.
---- Also adds a "count" field to alliance (total number of people in alliance) and
---- to the individual subtables (total number of people in each party.
-----------------------------------------------------------------------------------
function refresh_group_info(dt,user_event_flag)
    if not alliance or #alliance == 0 then
        alliance = make_alliance()
    end
    
    local c_alliance = make_alliance()
    
    local j = windower.ffxi.get_party() or {}
    
    c_alliance.leader = j.alliance_leader -- Test whether this works
    c_alliance[1].leader = j.party1_leader
    c_alliance[2].leader = j.party2_leader
    c_alliance[3].leader = j.party3_leader
    
    for i,v in pairs(j) do
        if type(v) == 'table' and v.mob and v.mob.race then
            v.mob.race_id = v.mob.race
            v.mob.race = res.races[v.mob.race][language]
        end
        
        local allyIndex
        local partyIndex
        
        -- For 'p#', ally index is 1, party index is the second char
        if i:sub(1,1) == 'p' and tonumber(i:sub(2)) then
            allyIndex = 1
            partyIndex = tonumber(i:sub(2))+1
        -- For 'a##', ally index is the second char, party index is the third char
        elseif tonumber(i:sub(2,2)) and tonumber(i:sub(3)) then
            allyIndex = tonumber(i:sub(2,2))+1
            partyIndex = tonumber(i:sub(3))+1
        end
        
        if allyIndex and partyIndex then
            if v.mob and partybuffs[v.mob.index] then
                v.buffactive = convert_buff_list(partybuffs[v.mob.index].buffs)
            elseif v.mob and v.mob.index == player.index then
                v.buffactive = buffactive
            end
            c_alliance[allyIndex][partyIndex] = v
            c_alliance[allyIndex].count = c_alliance[allyIndex].count + 1
            c_alliance.count = c_alliance.count + 1
            
            if v.mob then
                if v.mob.id == c_alliance[1].leader then
                    c_alliance[1].leader = v
                elseif v.mob.id == c_alliance[2].leader then
                    c_alliance[2].leader = v
                elseif v.mob.id == c_alliance[3].leader then
                    c_alliance[3].leader = v
                end
                
                if v.mob.id == c_alliance.leader then
                    c_alliance.leader = v
                end
            end
        end
    end
    
        
    -- Clear the old structure while maintaining the party references:
    for ally_party = 1,3 do
        for i,v in pairs(alliance[ally_party]) do
            alliance[ally_party][i] = nil
        end
        alliance[ally_party].count = 0
    end
    alliance.count = 0
    alliance.leader = nil
    
    -- Reassign to the new structure
    table.reassign(alliance[1],c_alliance[1])
    table.reassign(alliance[2],c_alliance[2])
    table.reassign(alliance[3],c_alliance[3])
    alliance.count = c_alliance.count
    alliance.leader = c_alliance.leader
end

-----------------------------------------------------------------------------------
--Name: make_alliance()
--Args:
---- none
-----------------------------------------------------------------------------------
--Returns:
---- one blank alliance structure
-----------------------------------------------------------------------------------
function make_alliance()
    local all = make_user_table()
    all[1]={count=0,leader=nil}
    all[2]={count=0,leader=nil}
    all[3]={count=0,leader=nil}
    all.count=0
    all.leader=nil
    return all
end

-----------------------------------------------------------------------------------
--Name: convert_buff_list(bufflist)
--Args:
---- bufflist (table): List of buffs from windower.ffxi.get_player()['buffs']
-----------------------------------------------------------------------------------
--Returns:
---- buffarr (table)
---- buffarr is indexed by the string buff name and has a value equal to the number
---- of that string present in the buff array. So two marches would give
---- buffarr.march==2.
-----------------------------------------------------------------------------------
function convert_buff_list(bufflist)
    local buffarr = {}
    for i,id in pairs(bufflist) do
        if res.buffs[id] then -- For some reason we always have buff 255 active, which doesn't have an entry.
            local buff = res.buffs[id][language]:lower()
            if buffarr[buff] then
                buffarr[buff] = buffarr[buff] +1
            else
                buffarr[buff] = 1
            end
            
            if buffarr[id] then
                buffarr[id] = buffarr[id] +1
            else
                buffarr[id] = 1
            end
        end
    end
    return buffarr
end

-----------------------------------------------------------------------------------
--Name: refresh_item_list(itemlist)
--Args:
---- itemlist (table): List of items from windower.ffxi.get_items().something
-----------------------------------------------------------------------------------
--Returns:
---- retarr (table)
---- retarr is indexed by the item name, and contains a table with the
---- item id, count, and short name.  If the long name for the item is
---- different than the short name, an additional entry is added for
---- that.
----
---- Overall, this allows doing simple existance checks for both short
---- and long name (eg: player.inventory["Theo. Cap +1"] and
---- player.inventory["Theopany Cap +1"] both return the same table,
---- and both would be 'true' in a conditional check)), and get the item
---- count (player.inventory["Orichalc. Bullet"].count)
---- It also allows one to check for the alternate spelling of an item.
-----------------------------------------------------------------------------------
function refresh_item_list(itemlist)
    retarr = make_user_table()
    for i,v in pairs(itemlist) do
        if type(v) == 'table' and v.id and v.id ~= 0 then
            -- If we don't already have the primary item name in the table, add it.
            if res.items[v.id] and res.items[v.id][language] and not retarr[res.items[v.id][language]] then
                retarr[res.items[v.id][language]] = table.copy(v)
                retarr[res.items[v.id][language]].shortname=res.items[v.id][language]:lower()
                -- If a long version of the name exists, and is different from the short version,
                -- add the long name to the info table and point the long name's key at that table.
                if res.items[v.id][language..'_log'] and res.items[v.id][language..'_log']:lower() ~= res.items[v.id][language]:lower() then
                    retarr[res.items[v.id][language]].longname = res.items[v.id][language..'_log']:lower()
                    retarr[res.items[v.id][language..'_log']] = retarr[res.items[v.id][language]]
                end
            elseif res.items[v.id] and res.items[v.id][language] then
                -- If there's already an entry for this item, all the hard work has already
                -- been done.  Just update the count on the subtable of the main item, and
                -- everything else will link together.
                retarr[res.items[v.id][language]].count = retarr[res.items[v.id][language]].count + v.count
            end
        end
    end
    return retarr
end

-----------------------------------------------------------------------------------
--Name: refresh_user_env()
--Args:
---- none
-----------------------------------------------------------------------------------
--Returns:
---- none, but loads user files if they exist.
-----------------------------------------------------------------------------------
function refresh_user_env(job_id)
    refresh_globals()
    if not job_id then job_id = windower.ffxi.get_player().main_job_id end
    
    if not job_id then
        windower.send_command('@wait 1;lua i '.._addon.name..' refresh_user_env')
    else
        load_user_files(job_id)
    end
end


-----------------------------------------------------------------------------------
--Name: pathsearch()
--Args:
---- files_list - table of strings of the file name to search.
-----------------------------------------------------------------------------------
--Returns:
---- path of a valid file, if it exists. False if it doesn't.
-----------------------------------------------------------------------------------
function pathsearch(files_list)

    -- base directory search order:
    -- windower
    -- %appdata%/Windower/GearSwap
    
    -- sub directory search order:
    -- libs-dev (only in windower addon path)
    -- libs (only in windower addon path)
    -- data/player.name
    -- data/common
    -- data
    
    local gearswap_data = windower.addon_path .. 'data/'
    local gearswap_appdata = (os.getenv('APPDATA') or '') .. '/Windower/GearSwap/'
    
    local search_path = {
        [1] = windower.addon_path .. 'libs-dev/',
        [2] = windower.addon_path .. 'libs/',
        [3] = gearswap_data .. player.name .. '/',
        [4] = gearswap_data .. 'common/',
        [5] = gearswap_data,
        [6] = gearswap_appdata .. player.name .. '/',
        [7] = gearswap_appdata .. 'common/',
        [8] = gearswap_appdata,
        [9] = windower.windower_path .. 'addons/libs/'
    }
    
    local user_path
    local normal_path

    for _,basepath in ipairs(search_path) do
        if windower.dir_exists(basepath) then
            for i,v in ipairs(files_list) do
                if v ~= '' then
                    if include_user_path then
                        user_path = basepath .. include_user_path .. '/' .. v
                    end
                    normal_path = basepath .. v
                    
                    if user_path and windower.file_exists(user_path) then
                        return user_path,basepath,v
                    elseif normal_path and windower.file_exists(normal_path) then
                        return normal_path,basepath,v
                    end
                end
            end
        end
    end
    
    return false
end
