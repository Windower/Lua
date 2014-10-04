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

_addon.name = 'GearSwap'
_addon.version = '0.892'
_addon.author = 'Byrth'
_addon.commands = {'gs','gearswap'}

if windower.file_exists(windower.addon_path..'data/bootstrap.lua') then
    debugging = {windower_debug = true,command_registry = false,general=false}
else
    debugging = {}
end

__raw = {lower = string.lower, upper = string.upper, debug=windower.debug,text={create=windower.text.create,
    delete=windower.text.delete,registry = {}},prim={create=windower.prim.create,delete=windower.prim.delete,registry={}}}


language = 'english'
file = require 'files'
require 'strings'
require 'tables'
require 'lists'
require 'sets'

windower.text.create = function (str)
    if __raw.text.registry[str] then
        windower.add_to_chat(123,'GearSwap: Text object cannot be created because it already exists.')
    else
        __raw.text.registry[str] = true
        __raw.text.create(str)
    end
end

windower.text.delete = function (str)
    if __raw.text.registry[str] then
        print('in here!')
        local deleted = false
        if windower.text.saved_texts then
            for i,v in pairs(windower.text.saved_texts) do
                if v._name == str then
                    __raw.text.registry[str] = nil
                    windower.text.saved_texts[i]:destroy()
                    deleted = true
                    break
                end
            end
        end
        if not deleted then
            __raw.text.registry[str] = nil
            __raw.text.delete(str)
        end
    else
        __raw.text.delete(str)
    end
end

windower.prim.create = function (str)
    if __raw.prim.registry[str] then
        windower.add_to_chat(123,'GearSwap: Primitive cannot be created because it already exists.')
    else
        __raw.prim.registry[str] = true
        __raw.prim.create(str)
    end
end

windower.prim.delete = function (str)
    if __raw.prim.registry[str] then
        __raw.prim.registry[str] = nil
        __raw.prim.delete(str)
    else
        __raw.prim.delete(str)
    end
end

texts = require 'texts'
require 'pack'
bit = require 'bit'
socket = require 'socket'
res = require 'resources'
extdata = require 'extdata'
require 'helper_functions'

-- Resources Checks
if res.items and res.bags and res.slots and res.statuses and res.jobs and res.elements and res.skills and res.buffs and res.spells and res.job_abilities and res.weapon_skills and res.monster_abilities and res.action_messages and res.skills and res.monstrosity and res.weather and res.moon_phases and res.races then
else
    error('Missing resources!')
end

require 'statics'
require 'equip_processing'
require 'targets'
require 'user_functions'
require 'refresh'
require 'export'
require 'validate'
require 'flow'
require 'triggers'

windower.register_event('load',function()
    windower.debug('load')
    if windower.dir_exists('../addons/GearSwap/data/logs') then
        logging = false
        logfile = io.open('../addons/GearSwap/data/logs/NormalLog'..tostring(os.clock())..'.log','w+')
        logit('GearSwap LOGGER HEADER\n')
    end
    
    refresh_globals()
    
    if world.logged_in then
        refresh_user_env()
        if debugging.general then windower.send_command('@unload spellcast;') end
    end
end)

windower.register_event('unload',function ()
    windower.debug('unload')
    user_pcall('file_unload')
    if logging then    logfile:close() end
end)

windower.register_event('addon command',function (...)
    windower.debug('addon command')
    logit('\n\n'..tostring(os.clock)..table.concat({...},' '))
    local splitup = {...}
    if not splitup[1] then return end -- handles //gs
    local cmd = splitup[1]:lower()
    
    if cmd == 'c' then
        if gearswap_disabled then return end
        if splitup[2] then
            refresh_globals()
            equip_sets('self_command',nil,_raw.table.concat(splitup,' ',2,#splitup))
        else
            windower.add_to_chat(123,'GearSwap: No self command passed.')
        end
    elseif cmd == 'equip' then
        if gearswap_disabled then return end
        local key_list = parse_set_to_keys(table.slice(splitup, 2))
        local set = get_set_from_keys(key_list)
        if set then
            refresh_globals()
            equip_sets('equip_command',nil,set)
        else
            windower.add_to_chat(123,'GearSwap: Equip command cannot be completed. That set does not exist.')
        end
    elseif cmd == 'export' then
        table.remove(splitup,1)
        export_set(splitup)
    elseif cmd == 'validate' then
        if user_env and user_env.sets then
            refresh_globals()
            table.remove(splitup, 1)
            validate(splitup)
        else
            windower.add_to_chat(123,'GearSwap: There is nothing to validate because there is no file loaded.')
        end
    elseif cmd == 'l' or cmd == 'load' then
        if splitup[2] then
            local f_name = table.concat(splitup,' ',2)
            if pathsearch({f_name}) then
                refresh_globals()
                command_registry = {}
                load_user_files(false,f_name)
            else
                windower.add_to_chat(123,'GearSwap: File not found.')
            end
        else
            windower.add_to_chat(123,'GearSwap: No file name was provided.')
        end
    elseif cmd == 'enable' then
        disenable(splitup,command_enable,'enable',false)
    elseif cmd == 'disable' then
        disenable(splitup,disable,'disable',true)
    elseif cmd == 'reload' or cmd == 'r' then
        refresh_user_env()
    elseif strip(cmd) == 'debugmode' then
        _settings.debug_mode = not _settings.debug_mode
        print('GearSwap: Debug Mode set to '..tostring(_settings.debug_mode)..'.')
    elseif strip(cmd) == 'demomode' then
        _settings.demo_mode = not _settings.demo_mode
        print('GearSwap: Demo Mode set to '..tostring(_settings.demo_mode)..'.')
    elseif strip(cmd) == 'showswaps' then
        _settings.show_swaps = not _settings.show_swaps
        print('GearSwap: Show Swaps set to '..tostring(_settings.show_swaps)..'.')
    elseif _settings.debug_mode and strip(cmd) == 'eval' then
        table.remove(splitup,1)
        assert(loadstring(table.concat(splitup,' ')))()
    else
        print('GearSwap: Command not found')
    end
end)

function disenable(tab,funct,functname,pol)
    if tab[2] and tab[2]:lower()=='all' then
        funct('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
        print('GearSwap: All slots '..functname..'d.')
    elseif tab[2]  then
        for i=2,#tab do
            if slot_map[tab[i]:gsub('[^%a_%d]',''):lower()] then
                funct(tab[i]:gsub('[^%a_%d]',''):lower())
                print('GearSwap: '..tab[i]:gsub('[^%a_%d]',''):lower()..' slot '..functname..'d.')
            else
                print('GearSwap: Unable to find slot '..tostring(tab[i])..'.')
            end
        end
    elseif gearswap_disabled ~= pol and not tab[2] then
        print('GearSwap: User file '..functname..'d')
        gearswap_disabled = pol
    end
end

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
    windower.debug('incoming chunk '..id)
    
    if next_packet_events and next_packet_events.sequence_id ~= data:unpack('H',3) then
        if not next_packet_events.globals_update or next_packet_events.globals_update ~= data:unpack('H',3) then
            refresh_globals()
            next_packet_events.globals_update = data:unpack('H',3)
        end
        if next_packet_events.pet_status_change then
            if pet.isvalid then
                equip_sets('pet_status_change',nil,next_packet_events.pet_status_change.newstatus,next_packet_events.pet_status_change.oldstatus)
            end
            next_packet_events.pet_status_change = nil
        end
        if next_packet_events.pet_change then
            if next_packet_events.pet_change.pet then -- Losing a pet
                equip_sets('pet_change',nil,next_packet_events.pet_change.pet,false)
                next_packet_events.pet_change = nil
            elseif pet.isvalid then -- Gaining a pet
                equip_sets('pet_change',nil,pet,true)
                next_packet_events.pet_change = nil
            end
        end
        if not next_packet_events.pet_status_change and not next_packet_events.pet_change then
            next_packet_events = nil
        end
    end
    
    if injected then
    elseif id == 0x00A then
        windower.debug('zone change')
        player.name = data:unpack('z',0x85)
        player.id = data:unpack('I',0x05)
        player.index = data:unpack('H',0x09)
        player.main_job = data:byte(0xB5)
        player.sub_job = data:byte(0xB8)
        player.vitals.max_hp = data:unpack('I',0xE9)
        player.vitals.max_mp = data:unpack('I',0xED)
        update_job_names()
        
        world.zone_id = data:unpack('H',0x31)
        not_sent_out_equip = {}
        command_registry = {}
        _ExtraData.world.conquest = false
        for i,v in pairs(region_to_zone_map) do
            if v:contains(world.zone_id) then
                _ExtraData.world.conquest = {
                    region_id = i,
                    region_name = res.regions[i][language],
                    }
                break
            end
        end
        world.weather_id = data:byte(0x69)
        world.logged_in = true
        
        _ExtraData.world.in_mog_house = data:byte(0x81) == 1
        refresh_ffxi_info()
    elseif id == 0x00B then
        -- Blank temporary items when zoning.
        items.temporary = make_inventory_table()
    elseif id == 0x0E and pet.index and pet.index == data:unpack('H',9) and math.floor((data:byte(11)%8)/4)== 1 then
        local oldstatus = pet.status
        local status_id = data:byte(32)
        -- Filter all statuses aside from Idle/Engaged/Dead/Engaged dead.
        if status_id < 4 then
            local newstatus = copy_entry(res.statuses[status_id])
            if newstatus and newstatus[language] then
                newstatus = newstatus[language]
                if oldstatus ~= newstatus then
                    if not next_packet_events then next_packet_events = {sequence_id = data:byte(4)*256+data:byte(3)} end
                    next_packet_events.pet_status_change = {newstatus=newstatus,oldstatus=oldstatus}
                end
            end
        end
    elseif id == 0x01B then
        for job_id = 1,23 do
            player.jobs[to_windower_api(res.jobs[job_id].english)] = data:byte(job_id + 72)
        end
        
        local enc = data:unpack('H',0x61)
        local tab = {}
        for slot_id,slot_name in pairs(default_slot_map) do
            local tf = (((enc%(2^(slot_id+1))) / 2^slot_id) >= 1)
            if encumbrance_table[slot_id] and not tf and not_sent_out_equip[slot_name] and not disable_table[i] then
                tab[slot_name] = not_sent_out_equip[slot_name]
                not_sent_out_equip[slot_name] = nil
            end
            if encumbrance_table[slot_id] and not tf then
                debug_mode_chat("Your "..slot_name.." slot is now unlocked.")
            end
            encumbrance_table[slot_id] = tf
        end
        if table.length(tab) > 0 then
            refresh_globals()
            equip_sets('equip_command',nil,tab)
        end
    elseif id == 0x01E then
        local bag = to_windower_api(res.bags[data:byte(0x09)].english)
        local slot = data:byte(0x0A)
        local count = data:unpack('I',5)
        if not items[bag][slot] then items[bag][slot] = make_empty_item_table(slot) end
        items[bag][slot].count = count
        if count == 0 then
            items[bag][slot].id = 0
            items[bag][slot].bazaar = 0
            items[bag][slot].status = 0
        end
    elseif id == 0x01F then
        local bag = to_windower_api(res.bags[data:byte(0x0B)].english)
        local slot = data:byte(0x0C)
        if not items[bag][slot] then items[bag][slot] = make_empty_item_table(slot) end
        items[bag][slot].id = data:unpack('H',9)
        items[bag][slot].count = data:unpack('I',5)
        items[bag][slot].status = data:byte(0x0D)
    elseif id == 0x020 then
        local bag = to_windower_api(res.bags[data:byte(0x0F)].english)
        local slot = data:byte(0x10)
        if not items[bag][slot] then items[bag][slot] = make_empty_item_table(slot) end
        items[bag][slot].id = data:unpack('H',0x0D)
        items[bag][slot].count = data:unpack('I',5)
        items[bag][slot].bazaar = data:unpack('I',9)
        items[bag][slot].status = data:byte(0x11)
        items[bag][slot].extdata = data:sub(0x12,0x29)
        -- Did not mess with linkshell stuff
    elseif id == 0x28 then
        data = data:sub(5)
        local act = {}
--        act.do_not_need = get_bit_packed(data,0,8)
        act.actor_id = get_bit_packed(data,8,40)
        act.target_count = get_bit_packed(data,40,50)
        act.category = get_bit_packed(data,50,54)
        act.param = get_bit_packed(data,54,70)
        act.unknown = get_bit_packed(data,70,86)
        act.recast = get_bit_packed(data,86,118)
        act.targets = {}
        local offset = 118
        for i = 1,act.target_count do
            act.targets[i] = {}
            act.targets[i].id = get_bit_packed(data,offset,offset+32)
            act.targets[i].action_count = get_bit_packed(data,offset+32,offset+36)
            offset = offset + 36
            act.targets[i].actions = {}
            for n = 1,act.targets[i].action_count do
                act.targets[i].actions[n] = {}
                act.targets[i].actions[n].reaction = get_bit_packed(data,offset,offset+5)
                act.targets[i].actions[n].animation = get_bit_packed(data,offset+5,offset+16)
                act.targets[i].actions[n].effect = get_bit_packed(data,offset+16,offset+21)
                act.targets[i].actions[n].stagger = get_bit_packed(data,offset+21,offset+27)
                act.targets[i].actions[n].param = get_bit_packed(data,offset+27,offset+44)
                act.targets[i].actions[n].message = get_bit_packed(data,offset+44,offset+54)
                act.targets[i].actions[n].unknown = get_bit_packed(data,offset+54,offset+85)
                act.targets[i].actions[n].has_add_effect = get_bit_packed(data,offset+85,offset+86)
                offset = offset + 86
                if act.targets[i].actions[n].has_add_effect == 1 then
                    act.targets[i].actions[n].has_add_effect = true
                    act.targets[i].actions[n].add_effect_animation = get_bit_packed(data,offset,offset+6)
                    act.targets[i].actions[n].add_effect_effect = get_bit_packed(data,offset+6,offset+10)
                    act.targets[i].actions[n].add_effect_param = get_bit_packed(data,offset+10,offset+27)
                    act.targets[i].actions[n].add_effect_message = get_bit_packed(data,offset+27,offset+37)
                    offset = offset + 37
                else
                    act.targets[i].actions[n].has_add_effect = false
                    act.targets[i].actions[n].add_effect_animation = 0
                    act.targets[i].actions[n].add_effect_effect = 0
                    act.targets[i].actions[n].add_effect_param = 0
                    act.targets[i].actions[n].add_effect_message = 0
                end
                act.targets[i].actions[n].has_spike_effect = get_bit_packed(data,offset,offset+1)
                offset = offset +1
                if act.targets[i].actions[n].has_spike_effect == 1 then
                    act.targets[i].actions[n].has_spike_effect = true
                    act.targets[i].actions[n].spike_effect_animation = get_bit_packed(data,offset,offset+6)
                    act.targets[i].actions[n].spike_effect_effect = get_bit_packed(data,offset+6,offset+10)
                    act.targets[i].actions[n].spike_effect_param = get_bit_packed(data,offset+10,offset+24)
                    act.targets[i].actions[n].spike_effect_message = get_bit_packed(data,offset+24,offset+34)
                    offset = offset + 34
                else
                    act.targets[i].actions[n].has_spike_effect = false
                    act.targets[i].actions[n].spike_effect_animation = 0
                    act.targets[i].actions[n].spike_effect_effect = 0
                    act.targets[i].actions[n].spike_effect_param = 0
                    act.targets[i].actions[n].spike_effect_message = 0
                end
            end
        end
        inc_action(act)
    elseif id == 0x29 then
        if gearswap_disabled then return end
        local arr = {}
        arr.actor_id = data:unpack('I',0x05)
        arr.target_id = data:unpack('I',0x09)
        arr.param_1 = data:unpack('I',0x0D)
        arr.param_2 = get_bit_packed(data,128,134) -- First 6 bits
        arr.param_3 = get_bit_packed(data,134,160) -- Rest
        arr.actor_index = data:unpack('H',0x15)
        arr.target_index = data:unpack('H',0x17)
        arr.message_id = data:unpack('H',0x19)%32768

        inc_action_message(arr)
    elseif id == 0x037 then
        player.status_id = data:byte(0x31)
        local bitmask = data:sub(0x4D,0x54)
        for i = 1,32 do
            local bitmask_position = 2*((i-1)%4)
            player.buffs[i] = data:byte(4+i) + 256*math.floor(bitmask:byte(1+math.floor((i-1)/4))%(2^(bitmask_position+2))/(2^bitmask_position))
        end
        
        local indi_byte = data:byte(0x59)
        if indi_byte%128/64 >= 1 then
            local temp_indi = _ExtraData.player.indi
            _ExtraData.player.indi = {
                    element = res.elements[indi_byte%8][language],
                    element_id = indi_byte%8,
                    size = math.floor((indi_byte%64)/16) + 1, -- Size range of 1~4
                }
            if (indi_byte%16)/8 >= 1 then
                _ExtraData.player.indi.target = 'Enemy'
            else
                _ExtraData.player.indi.target = 'Ally'
            end
            if not temp_indi then
                -- There was not an indi spell up
                refresh_globals()
                equip_sets('indi_change',nil,_ExtraData.player.indi,true)
            elseif temp_indi.element_id ~= _ExtraData.player.indi.element_id or temp_indi.target ~= _ExtraData.player.indi.target or temp_indi.size ~= _ExtraData.player.indi.size then
                -- There was already an indi spell up, so check if it changed
                refresh_globals()
                equip_sets('indi_change',nil,temp_indi,false)
                equip_sets('indi_change',nil,_ExtraData.player.indi,true)
            end
        elseif _ExtraData.player.indi then
            -- An indi effect has been lost.
            local temp_indi = _ExtraData.player.indi
            _ExtraData.player.indi = nil
            refresh_globals()
            equip_sets('indi_change',nil,temp_indi,false)
        end
    elseif id == 0x044 then
        -- No idea what this is doing
    elseif id == 0x050 then
        local inv = items[to_windower_api(res.bags[data:byte(7)].english)]
        if data:byte(5) ~= 0 then
            items.equipment[toslotname(data:byte(6))] = {slot=data:byte(5),bag_id = data:byte(7)}
            if not inv[data:byte(5)] then inv[data:byte(5)] = make_empty_item_table(data:byte(5)) end
            items[to_windower_api(res.bags[data:byte(7)].english)][data:byte(5)].status = 5 -- Set the status to "equipped"
        else
            items.equipment[toslotname(data:byte(6))] = {slot=empty,bag_id=0}
            if not inv[data:byte(5)] then inv[data:byte(5)] = make_empty_item_table(data:byte(5)) end
            items[to_windower_api(res.bags[data:byte(7)].english)][data:byte(5)].status = 0 -- Set the status to "unequipped"
        end
    elseif id == 0x05E then -- Conquest ID
        if _ExtraData.world.conquest then
            local offset = _ExtraData.world.conquest.region_id*4 + 11
            if offset == 99 then
                offset = 95
            elseif offset == 107 then
                offset = 99
            end
            local strength_map = {[0]='Minimal',[1]='Minor',[2]='Major',[3]='Dominant'}
            local nation_map = {[0]={english='Neutral',japanese='Neutral'},[1]=res.regions[0],[2]=res.regions[1],
                [3]=res.regions[2],[4]={english='Beastman',japanese='Beastman'},[0xFF]=res.regions[3]}
            _ExtraData.world.conquest.strengths = {
                sandoria=strength_map[data:byte(offset+2)%4],
                bastok=strength_map[math.floor(data:byte(offset+2)%16/4)],
                windurst=strength_map[math.floor(data:byte(offset+2)%64/16)],
                beastmen=strength_map[math.floor(data:byte(offset+2)/64)],}
            _ExtraData.world.conquest.nation = nation_map[data:byte(offset+3)][language]
            _ExtraData.world.conquest.sandoria = data:byte(0x87)
            _ExtraData.world.conquest.bastok = data:byte(0x88)
            _ExtraData.world.conquest.windurst = data:byte(0x89)
            _ExtraData.world.conquest.beastmen = 100-data:byte(0x87)-data:byte(0x88)-data:byte(0x89)
        end
    elseif id == 0x061 then
        player.vitals.max_hp = data:unpack('I',5)
        player.vitals.max_mp = data:unpack('I',9)
        player.main_job_id = data:byte(13)
        player.main_job_level = data:byte(14)
        
        _ExtraData.player.nation_id = data:byte(0x51)
        _ExtraData.player.nation = res.regions[_ExtraData.player.nation_id][language] or 'None'
                
        if player.sub_job_id ~= data:byte(15) then
            -- Subjob change event
            local temp_sub = player.sub_job
            player.sub_job_id = data:byte(15)
            player.sub_job_level = data:byte(16)
            update_job_names()
            refresh_globals()
            equip_sets('sub_job_change',nil,player.sub_job,temp_sub)
        end
        update_job_names()
    elseif id == 0x062 then
        for i = 1,0x71,2 do
            local skill = data:unpack('H',i + 0x82)%32768
            local current_skill = res.skills[math.floor(i/2)+1]
            if current_skill then
                player.skills[to_windower_api(current_skill.english)] = skill
            end
        end
    elseif id == 0x067 then
        local flag_1 = data:byte(5)
        local flag_2 = data:byte(6)
        local owner_ind = data:unpack('H',13)
        local subj_ind = data:unpack('H',7)
                
        if flag_1 == 3 and flag_2 == 5 and windower.ffxi.get_player().index == owner_ind and not pet.isvalid then
            if not next_packet_events then next_packet_events = {sequence_id = data:unpack('H',3)} end
            next_packet_events.pet_change = {subj_ind = subj_ind}
        elseif flag_1 == 4 and flag_2 == 5 and windower.ffxi.get_player().index == subj_ind then
            if not next_packet_events then next_packet_events = {sequence_id = data:unpack('H',3)} end
            refresh_globals()
            pet.isvalid = false
            next_packet_events.pet_change = {pet = table.reassign({},pet)}
        elseif flag_2 == 7 and windower.ffxi.get_player().index == subj_ind and not pet.isvalid then
            if not next_packet_events then next_packet_events = {sequence_id = data:unpack('H',3)} end
            pet.isvalid = true
            next_packet_events.pet_change = {subj_ind = owner_ind}
        end
    elseif id == 0x0DF then
        player.vitals.hp = data:unpack('I',9)
        player.vitals.mp = data:unpack('I',13)
        player.vitals.tp = data:unpack('I',0x11)
        player.vitals.hpp = data:byte(0x17)
        player.vitals.mpp = data:byte(0x18)
    elseif id == 0x117 then
        for i=0x49,0x85,4 do
            local arr = data:sub(i,i+3)
            local inv = items[to_windower_api(res.bags[arr:byte(3)].english)]
            if arr:byte(1) ~= 0 then
                items.equipment[toslotname(arr:byte(2))] = {slot=arr:byte(1),bag_id = arr:byte(3)}
                if not inv[arr:byte(1)] then inv[arr:byte(1)] = make_empty_item_table(arr:byte(1)) end
                items[to_windower_api(res.bags[arr:byte(3)].english)][arr:byte(1)].status = 5 -- Set the status to "equipped"
            else
                items.equipment[toslotname(arr:byte(2))] = {slot=empty,bag_id=0}
                if not inv[arr:byte(1)] then inv[arr:byte(1)] = make_empty_item_table(arr:byte(1)) end
                items[to_windower_api(res.bags[arr:byte(3)].english)][arr:byte(1)].status = 0 -- Set the status to "unequipped"
            end
        end
    end
end)

windower.register_event('status change',function(new,old)
    windower.debug('status change '..new)
    if gearswap_disabled or T{2,3,4}:contains(old) or T{2,3,4}:contains(new) then return end
    
    refresh_globals()
    equip_sets('status_change',nil,res.statuses[new].english,res.statuses[old].english)
end)

windower.register_event('gain buff',function(buff_id)
    if not res.buffs[buff_id] then
        error('GearSwap: No known status for buff id #'..tostring(buff_id))
    end
    local buff_name = res.buffs[buff_id][language]
    windower.debug('gain buff '..buff_name..' ('..tostring(buff_id)..')')
    if gearswap_disabled then return end
    
    -- Need to figure out what I'm going to do with this:
    if T{'terror','sleep','stun','petrification','charm','weakness'}:contains(buff_name:lower()) then
        for i,v in pairs(command_registry) do
            if v.midaction then
                command_registry[i] = nil
            end
        end
    end
    
    refresh_globals()
    equip_sets('buff_change',nil,buff_name,true)
end)

windower.register_event('lose buff',function(buff_id)
    if not res.buffs[buff_id] then
        error('GearSwap: No known status for buff id #'..tostring(buff_id))
    end
    local buff_name = res.buffs[buff_id][language]
    windower.debug('lose buff '..buff_name..' ('..tostring(buff_id)..')')
    if gearswap_disabled then return end
    refresh_globals()
    equip_sets('buff_change',nil,buff_name,false)
end)

windower.register_event('login',function(name)
    windower.debug('login '..name)
    initialize_globals()
    windower.send_command('@wait 2;lua i gearswap refresh_user_env;')
end)