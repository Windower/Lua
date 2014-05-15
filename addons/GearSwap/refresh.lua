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
function load_user_files(job_id)
    job_id = tonumber(job_id)
    local path
    
    refresh_globals()
    user_pcall('file_unload')
    
    for i,v in pairs(registered_user_events) do
        windower.unregister_event(i)
    end
    
    user_env = nil
    registered_user_events = {}
    
    local tab = {player.name..'_'..res.jobs[job_id].short..'.lua',player.name..'-'..res.jobs[job_id].short..'.lua',
        player.name..'_'..res.jobs[job_id].english..'.lua',player.name..'-'..res.jobs[job_id].english..'.lua',
        player.name..'.lua',res.jobs[job_id].short..'.lua',res.jobs[job_id].english..'.lua','default.lua'}
    
    local path = pathsearch(tab)
    
    if not path then
        current_job_file = nil
        gearswap_disabled = true
        sets = nil
        return
    end
    user_env = {gearswap = _G, _global = _global, _settings = _settings,
        -- Player functions
        equip = equip, verify_equip=verify_equip, cancel_spell=cancel_spell,
        force_send=force_send, change_target=change_target, cast_delay=cast_delay,
        print_set=print_set,set_combine=set_combine,disable=disable,enable=enable,
        send_command=send_cmd_user,windower=user_windower,include=include_user,
        midaction=user_midaction,pet_midaction=user_pet_midaction,
        
        -- Library functions
        string=string,math=math,table=table,set=set,list=list,T=T,S=S,L=L,os=os,
        text=text,type=type,tostring=tostring,tonumber=tonumber,pairs=pairs,
        ipairs = ipairs, print=print, add_to_chat=windower.add_to_chat,
        next=next,lua_base_path=windower.addon_path,empty=empty,
        
        -- Player environment things
        buffactive=buffactive,
        player=player,
        world=world,
        pet=pet,
        alliance=alliance,
        party=alliance[1],
        sets={naked = {main=empty,sub=empty,range=empty,ammo=empty,
                head=empty,neck=empty,ear1=empty,ear2=empty,
                body=empty,hands=empty,ring1=empty,ring2=empty,
                back=empty,waist=empty,legs=empty,feet=empty}}
        }

    -- Try to load data/<name>_<main job>.lua
    local funct, err = loadfile(path)
    
    -- If the file cannot be loaded, print the error and load the default.
    if funct == nil then 
        print('User file problem: '..err)
        current_job_file = nil
        gearswap_disabled = true
        sets = nil
        return
    else
        current_job_file = res.jobs[job_id].short
        print('GearSwap: Loaded your '..res.jobs[job_id].short..' Lua file!')
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
function refresh_player()
    local pl = windower.ffxi.get_player()
    if not pl then return end
    
    local player_mob_table = windower.ffxi.get_mob_by_index(pl.index)
    if not player_mob_table then return end
    
    table.reassign(player,pl)
    for i,v in pairs(player.vitals) do
        player[i]=v
    end
    if not player.sub_job then
        player.sub_job = 'NONE'
        player.sub_job_level = 0
        player.sub_job_full = 'None'
        player.sub_job_id = 0
    end
    player.job = player.main_job..'/'..player.sub_job
    player.status_id = player.status
    player.status = res.statuses[player.status][language]
    
    for i,v in pairs(player_mob_table) do
        if i == 'name' then
            player.mob_name = v
        elseif i~= 'is_npc' and i~='tp' and i~='mpp' and i~='claim_id' and i~='status' then
            player[i] = v
        end
    end
    
    if player_mob_table.race ~= nil then
        player.race_id = player.race
        player.race = mob_table_races[player.race]
    end
    
    
    
    local item_table = windower.ffxi.get_items()
    if item_table then items = item_table end
    -- This being nil does not cause a return, but items should not really be changing when zoning.
    if items.equipment then
        local cur_equip = convert_equipment(items.equipment) -- i = 'head', 'feet', etc.; v = inventory ID (0~80)
        
        if sent_out_equip then -- If the swap is not complete, overwrite the current equipment with the equipment that you are swapping to
            for i,v in pairs(cur_equip) do
                if sent_out_equip[slot_map[i]] then
                    v = sent_out_equip[slot_map[i]]
                end
                if v == 0 then
                    v = empty
                end
            end
        end
        
        -- Assign player.equipment to be the gear that has been sent out and the server currently thinks
        -- you are wearing. (the sent_out_equip for loop above).
        player.equipment = make_user_table()
        table.reassign(player.equipment,to_names_set(cur_equip))
    end
    
    -- Assign player.inventory to be keyed to item.inventory[i][language] and to have a value of count, similar to buffactive
    if items.inventory then player.inventory = refresh_item_list(items.inventory) end
    if items.sack then player.sack = refresh_item_list(items.sack) end
    if items.satchel then player.satchel = refresh_item_list(items.satchel) end
    if items.case then player.case = refresh_item_list(items.case) end
    if items.wardrobe then player.wardrobe = refresh_item_list(items.wardrobe) end
    
    -- Monster tables for the target and subtarget.
    player.target = target_complete(windower.ffxi.get_mob_by_target('t'))
    player.subtarget = target_complete(windower.ffxi.get_mob_by_target('st'))
    player.last_subtarget = target_complete(windower.ffxi.get_mob_by_target('lastst'))
    
    -- If we have a pet, create or update the table info.
    if player_mob_table.pet_index then
        local player_pet_table = windower.ffxi.get_mob_by_index(player_mob_table.pet_index)
        if player_pet_table then
            table.reassign(pet, target_complete(player_pet_table))
            pet.claim_id = nil
            pet.is_npc = nil
            pet.isvalid = true
            if pet.tp then pet.tp = pet.tp/10 end
            
            if avatar_element[pet.name] then
                pet.element = avatar_element[pet.name]
            else
                pet.element = 'None'
            end
        else
            table.reassign(pet, {isvalid=true})
        end
    else
        table.reassign(pet, {isvalid=false})
    end
    
    if player.main_job == 'PUP' or player.sub_job == 'PUP' then
        local auto_tab
        if player.main_job == 'PUP' then auto_tab = windower.ffxi.get_mjob_data()
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
    end
    
    if player.main_job == 'MON' then
        local species_id = windower.ffxi.get_mjob_data().species
        -- Should add instincts when they become available
        
        if species_id then
            player.species = {}
            for i,v in pairs(res.monstrosity[species_id]) do
                if i ~= 'id' then
                    player.species[i] = v
                end
            end
        end
    else
        player.species = nil
    end
    
    table.reassign(fellow,target_complete(windower.ffxi.get_mob_by_target('<ft>')))
    if fellow.name then
        fellow.isvalid = true
    else
        fellow.isvalid=false
    end
    
    refresh_buff_active(player.buffs)
    
    for global_variable_name,extradatatable in pairs(_ExtraData) do
        if _G[global_variable_name] then
            for sub_variable_name,value in pairs(extradatatable) do
                _G[global_variable_name][sub_variable_name] = value
            end
        end
    end
end

-----------------------------------------------------------------------------------
--Name: convert_equipment(equipment)
--Args:
---- equipment - Current equipment table (with _bag indices)
-----------------------------------------------------------------------------------
--Returns:
---- Table where equipment slot name = {inv_id,slot}
-----------------------------------------------------------------------------------
function convert_equipment(equipment)
    local retset = {}
    for i,v in pairs(equipment) do
        if i== 'sub' or i:sub(-4) ~= '_bag' then
            retset[i] = {inv_id=equipment[i..'_bag'],slot=v}
        end
    end
    return retset
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
function refresh_ffxi_info()
    local info = windower.ffxi.get_info()
    for i,v in pairs(info) do
        if i == 'zone' and res.zones[v] then
            world.zone = res.zones[v][language]
            world.area = world.zone
        elseif i == 'weather' and res.weather[v] then
            world.weather_id = v
            world.weather = res.weather[v][language]
            world.real_weather = world.weather
            world.weather_element = res.elements[res.weather[v].element][language]
            world.real_weather_element = world.weather_element
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

    if buffactive.voidstorm then
        world.weather = 'Voidstorm'
        world.weather_element = 'Dark'
    elseif buffactive.aurorastorm then
        world.weather = 'Aurorastorm'
        world.weather_element = 'Light'
    elseif buffactive.firestorm then
        world.weather = 'Firestorm'
        world.weather_element = 'Fire'
    elseif buffactive.sandstorm then
        world.weather = 'Sandstorm'
        world.weather_element = 'Earth'
    elseif buffactive.rainstorm then
        world.weather = 'Rainstorm'
        world.weather_element = 'Water'
    elseif buffactive.windstorm then
        world.weather = 'Windstorm'
        world.weather_element = 'Wind'
    elseif buffactive.hailstorm then
        world.weather = 'Hailstorm'
        world.weather_element = 'Ice'
    elseif buffactive.thunderstorm then
        world.weather = 'Thunderstorm'
        world.weather_element = 'Lightning'
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
---- Takes the mob arrays from windower.ffxi.get_party() and splits them from p0~5, a10~15, a20~25
---- into alliance[1][1~6], alliance[2][1~6], alliance[3][1~6], respectively.
---- Also adds a "count" field to alliance (total number of people in alliance) and
---- to the individual subtables (total number of people in each party.
-----------------------------------------------------------------------------------
function refresh_group_info()
    clean_alliance()
    
    local j = windower.ffxi.get_party() or {}
    for i,v in pairs(j) do
        if v.mob and v.mob.race then
            v.mob.race_id = v.mob.race
            v.mob.race = mob_table_races[v.mob.race]
        end
        
        local allyIndex
        local partyIndex
        
        -- For 'p#', ally index is 1, party index is the second char
        if i:sub(1,1) == 'p' then
            allyIndex = 1
            partyIndex = tonumber(i:sub(2))+1
        -- For 'a##', ally index is the second char, party index is the third char
        else
            allyIndex = tonumber(i:sub(2,2))+1
            partyIndex = tonumber(i:sub(3))+1
        end
        
        alliance[allyIndex][partyIndex] = v
        alliance[allyIndex].count = alliance[allyIndex].count + 1
        alliance.count = alliance.count + 1
    end
end

-- Cleans the current alliance array while keeping the subtable pointers intact.
function clean_alliance()
    if not alliance or #alliance == 0 then
        alliance = make_user_table()
        alliance[1]={count=0}
        alliance[2]={count=0}
        alliance[3]={count=0}
        alliance.count=0
    else
        for ally_party = 1,3 do
            for i,v in pairs(alliance[ally_party]) do
                alliance[ally_party][i] = nil
            end
            alliance[ally_party].count = 0
        end
        alliance.count = 0
    end
end

-----------------------------------------------------------------------------------
--Name: refresh_buff_active(bufflist)
--Args:
---- bufflist (table): List of buffs from windower.ffxi.get_player()['buffs']
-----------------------------------------------------------------------------------
--Returns:
---- buffarr (table)
---- buffarr is indexed by the string buff name and has a value equal to the number
---- of that string present in the buff array. So two marches would give
---- buffarr.march==2.
-----------------------------------------------------------------------------------
function refresh_buff_active(bufflist)
    buffarr = {}
    for i,v in pairs(bufflist) do
        if res.buffs[v] then -- For some reason we always have buff 255 active, which doesn't have an entry.
            local buff = res.buffs[v][language]:lower()
            if buffarr[buff] then
                buffarr[buff] = buffarr[buff] +1
            else
                buffarr[buff] = 1
            end
        end
    end
    table.reassign(buffactive,buffarr)
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
        if v.id and v.id ~= 0 then
            -- If we don't already have the primary item name in the table, add it.
            if res.items[v.id] and res.items[v.id][language] and not retarr[res.items[v.id][language]] then
                -- We add the entry as a sub-table containing the id and count
                retarr[res.items[v.id][language]] = {id=v.id, count=v.count, shortname=res.items[v.id][language]:lower()}
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
    command_registry = {}
    if not job_id then job_id = windower.ffxi.get_player().main_job_id end
    windower.send_command('@wait 0.5;lua i '.._addon.name..' load_user_files '..job_id)
end


-----------------------------------------------------------------------------------
--Name: pathsearch()
--Args:
---- tab - table of strings of the file name to search.
-----------------------------------------------------------------------------------
--Returns:
---- path of a valid file, if it exists. False if it doesn't.
-----------------------------------------------------------------------------------
function pathsearch(tab)
    local basetab = {[1]=windower.addon_path..'data/'..player.name..'/',[2]=windower.addon_path..'data/common/',
        [3]=windower.addon_path..'data/'}
    
    for _,basepath in ipairs(basetab) do
        if windower.dir_exists(basepath) then
            for i,v in ipairs(tab) do
                if windower.file_exists(basepath..v) then
                    return basepath..v
                end
            end
        end
    end
    return false
end