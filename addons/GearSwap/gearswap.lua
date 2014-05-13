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
_addon.version = '0.836'
_addon.author = 'Byrth'
_addon.commands = {'gs','gearswap'}

if windower.file_exists(windower.addon_path..'data/bootstrap.lua') then
    debugging = 1
else
    debugging = 0
end

language = 'english'
file = require 'files'
require 'strings'
require 'tables'
require 'lists'
require 'sets'
require 'texts'
res = require 'resources'
require 'helper_functions'

require 'statics'
require 'equip_processing'
require 'targets'
require 'user_functions'
require 'refresh'
require 'parse_augments'
require 'export'
require 'validate'
require 'flow'
require 'triggers'

windower.register_event('load',function()
    if debugging >= 1 then windower.debug('load') end
    if windower.dir_exists('../addons/GearSwap/data/logs') then
        logging = false
        logfile = io.open('../addons/GearSwap/data/logs/NormalLog'..tostring(os.clock())..'.log','w+')
        logit(logfile,'GearSwap LOGGER HEADER\n')
    end
    
    refresh_globals()
    
    if world.logged_in then
        refresh_user_env()
        if debugging >= 1 then windower.send_command('@unload spellcast;') end
    end
end)

windower.register_event('unload',function ()
    if debugging >= 1 then windower.debug('unload') end
    user_pcall('file_unload')
    if logging then    logfile:close() end
end)

windower.register_event('addon command',function (...)
    if debugging >= 1 then windower.debug('addon command') end
    if logging then
        local command = table.concat({...},' ')
        logit(logfile,'\n\n'..tostring(os.clock)..command)
    end
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
        local set_split = string.split(_raw.table.concat(splitup,' ',2,#splitup):gsub('%[','%.'):gsub('[%]\']',''),'.')
        local n = 1
        local tempset
        if set_split[1] == 'sets' then tempset = user_env
        else tempset = user_env.sets end
        while n <= #set_split do
            if tempset[set_split[n]] or tempset[tonumber(set_split[n])] then
                tempset = tempset[set_split[n]] or tempset[tonumber(set_split[n])]
                if n == #set_split then
                    refresh_globals()
                    equip_sets('equip_command',nil,tempset)
                    break
                else
                    n = n+1
                end
            else
                windower.add_to_chat(123,'GearSwap: Equip command cannot be completed. That set does not exist.')
                break
            end
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
    elseif cmd == 'enable' then
        disenable(splitup,enable,'enable',false)
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
    elseif not (S{'eval','visible','invisible','clocking'}:contains(cmd) and debugging>0) then
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
                funct(tab[i])
                print('GearSwap: '..tab[i]..' slot '..functname..'d.')
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
    if debugging >= 1 then windower.debug('incoming chunk '..id) end
    
    if next_packet_events and next_packet_events.sequence_id ~= data:byte(4)*256+data:byte(3) then
        if not next_packet_events.globals_update or next_packet_events.globals_update ~= data:byte(4)*256 + data:byte(3) then
            refresh_globals()
            next_packet_events.globals_update = data:byte(4)*256+data:byte(3)
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
    
    if id == 0x0E and not injected and pet.index and pet.index == data:byte(9) + data:byte(10)*256 and math.floor((data:byte(11)%8)/4)== 1 then
        local oldstatus = pet.status
        local status_id = data:byte(32)
        -- Ignore all statuses aside from Idle/Engaged/Dead/Engaged dead.
        if status_id < 4 then
            local newstatus = res.statuses[status_id]
            if newstatus and newstatus.english then
                newstatus = newstatus.english
                if oldstatus ~= newstatus then
                    if not next_packet_events then next_packet_events = {sequence_id = data:byte(4)*256+data:byte(3)} end
                    next_packet_events.pet_status_change = {newstatus=newstatus,oldstatus=oldstatus}
--                    refresh_globals()
        
--                    if pet.isvalid then
--                        pet.status = newstatus
--                        equip_sets('pet_status_change',nil,newstatus,oldstatus)
--                    end
                end
            end
        end
    elseif id == 0x28 and not injected then
        if clocking then windower.add_to_chat(8,'Action Packet: '..(os.clock() - out_time)) end
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
    elseif id == 0x29 and not injected then
        if clocking then windower.add_to_chat(8,'Action Message: '..(os.clock() - out_time)) end
        if gearswap_disabled then return end
        data = data:sub(5)
        local arr = {}
        arr.actor_id = get_bit_packed(data,0,32)
        arr.target_id = get_bit_packed(data,32,64)
        arr.param_1 = get_bit_packed(data,64,96)
        arr.param_2 = get_bit_packed(data,96,102) -- First 6 bits
        arr.param_3 = get_bit_packed(data,102,128) -- Rest
        arr.actor_index = get_bit_packed(data,128,144)
        arr.target_index = get_bit_packed(data,144,160)
        arr.message_id = get_bit_packed(data,160,175) -- Cut off the most significant bit, hopefully

        inc_action_message(arr)
    elseif id == 0x01B and not injected then
--        'Job Info Packet'
        local enc = data:byte(97) + data:byte(98)*256
        items = windower.ffxi.get_items()
        local tab = {}
        for i,v in pairs(default_slot_map) do
            if encumbrance_table[i] and math.floor( (enc%(2^(i+1))) / 2^i ) ~= 1 and not_sent_out_equip[v] and not disable_table[i] then
                tab[v] = not_sent_out_equip[v]
                not_sent_out_equip[v] = nil
                debug_mode_chat("Your "..v.." are now unlocked.")
            end
            encumbrance_table[i] = tf
        end
        if table.length(tab) > 0 then
            refresh_globals()
            equip_sets('equip_command',nil,tab)
        end
    elseif id == 0x067 and not injected then
        local flag_1 = data:byte(5)
        local flag_2 = data:byte(6)
        local owner_ind = data:byte(14)*256+data:byte(13)
        local subj_ind = data:byte(8)*256+data:byte(7)
    --    if debugging >= 1 and (windower.ffxi.get_player().index == owner_ind or windower.ffxi.get_player().index == subj_ind) then windower.add_to_chat(8,flag_2..' '..flag_1) end
        
        if flag_1 == 3 and flag_2 == 5 and windower.ffxi.get_player().index == owner_ind and not pet.isvalid then
            if not next_packet_events then next_packet_events = {sequence_id = data:byte(4)*256+data:byte(3)} end
            next_packet_events.pet_change = {subj_ind = subj_ind}
        elseif flag_1 == 4 and flag_2 == 5 and windower.ffxi.get_player().index == subj_ind then
            if not next_packet_events then next_packet_events = {sequence_id = data:byte(4)*256+data:byte(3)} end
            refresh_globals()
            pet.isvalid = false
            next_packet_events.pet_change = {pet = table.reassign({},pet)}
        end
<<<<<<< HEAD
    elseif id == 0x037 and not injected then
        local indi_byte = original:byte(0x59)
        if indi_byte%128/64 >= 1 then
            _ExtraData.player.indi = {
                    element = res.elements[indi_byte%8][language],
                    element_id = indi_byte%8,
                    size = math.floor(indi_byte%64)/16 + 1, -- Size range of 1~4
                }
            if (indi_byte%16)/8 >= 1 then
                _ExtraData.player.indi.target = 'Enemy'
            else
                _ExtraData.player.indi.target = 'Ally'
            end
        else
            _ExtraData.player.indi = nil
        end
=======
>>>>>>> parent of 00e66b1... GearSwap v0.837 - Indi spell info
    elseif gearswap_disabled then
        return
    elseif id == 0x050 and not injected then
--        'Equipment packet'
        if sent_out_equip[data:byte(6)] == data:byte(5) then
            sent_out_equip[data:byte(6)] = nil
            limbo_equip[data:byte(6)] = data:byte(5)
        end
    elseif id == 0x01D and not injected then
        limbo_equip = {}
    end
end)

windower.register_event('status change',function(new,old)
    if debugging >= 1 then windower.debug('status change '..new) end
    if gearswap_disabled or T{2,3,4}:contains(old) or T{2,3,4}:contains(new) then return end
    
    refresh_globals()
    equip_sets('status_change',nil,res.statuses[new].english,res.statuses[old].english)
end)

windower.register_event('gain buff',function(buff_id)
    if not res.buffs[buff_id] then
        error('GearSwap: No known status for buff id #'..tostring(buff_id))
    end
    local buff_name = res.buffs[buff_id][language]
    if debugging >= 1 then windower.debug('gain buff '..buff_name..' ('..tostring(buff_id)..')') end
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
    if debugging >= 1 then windower.debug('lose buff '..buff_name..' ('..tostring(buff_id)..')') end
    if gearswap_disabled then return end
    refresh_globals()
    equip_sets('buff_change',nil,buff_name,false)
end)

windower.register_event('job change',function(mjob_id, mjob_lvl, sjob_id, sjob_lvl)
    if debugging >= 1 then windower.debug('job change') end
    disable_table = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
    not_sent_out_equip = {}
    sent_out_equip = {}
    limbo_equip = {}

    if current_job_file ~= res.jobs[mjob_id].short then
        refresh_user_env(mjob_id)
    elseif player.sub_job ~= res.jobs[sjob_id].short then
        local temp_sub = player.sub_job
        refresh_globals()
        equip_sets('sub_job_change',nil,res.jobs[sjob_id].short,temp_sub)
    end
end)

windower.register_event('login',function(name)
    if debugging >= 1 then windower.debug('login '..name) end
    windower.send_command('@wait 2;lua i gearSwap refresh_user_env;')
end)

windower.register_event('day change',function(new,old)
    if debugging >= 1 then windower.debug('day change') end
    windower.send_command('@wait 0.5;lua invoke gearSwap refresh_ffxi_info')
end)

windower.register_event('weather change',function(new_weather, new_weather_id, old_weather, old_weather_id)
    if debugging >= 1 then windower.debug('weather change') end
    refresh_ffxi_info()
end)

windower.register_event('zone change',function(new_zone,new_zone_id,old_zone,old_zone_id)
    if debugging >= 1 then windower.debug('zone change') end
    _global.midaction = false
    _global.pet_midaction = false
    sent_out_equip = {}
    not_sent_out_equip = {}
    command_registry = {}
end)

if debugging and debugging >= 1 then
    require('data/bootstrap')

    windower.register_event('addon command', function(...)
        local pantsu = {...}
        local opt = table.remove(pantsu,1)
        if opt == 'eval' then
            assert(loadstring(table.concat(pantsu,' ')))()
        elseif opt == 'visible' then
            windower.text.set_visibility('precast',true)
            windower.text.set_visibility('midcast',true)
            windower.text.set_visibility('aftercast',true)
            windower.text.set_visibility('buff_change',true)
        elseif opt == 'invisible' then
            windower.text.set_visibility('precast',false)
            windower.text.set_visibility('midcast',false)
            windower.text.set_visibility('aftercast',false)
            windower.text.set_visibility('buff_change',false)
        elseif opt == 'clocking' then
            if clocking then clocking = false else clocking = true end
        end
    end)
    
    windower.text.create('precast')
    windower.text.set_bg_color('precast',100,100,100,100)
    windower.text.set_bg_visibility('precast',true)
    windower.text.set_font('precast','Consolas')
    windower.text.set_font_size('precast',12)
    windower.text.set_color('precast',255,255,255,255)
    windower.text.set_location('precast',250,10)
    windower.text.set_visibility('precast',false)
    windower.text.set_text('precast','Panda')
    
    windower.text.create('midcast')
    windower.text.set_bg_color('midcast',100,100,100,100)
    windower.text.set_bg_visibility('midcast',true)
    windower.text.set_font('midcast','Consolas')
    windower.text.set_font_size('midcast',12)
    windower.text.set_color('midcast',255,255,255,255)
    windower.text.set_location('midcast',500,10)
    windower.text.set_visibility('midcast',false)
    windower.text.set_text('midcast','Panda')
    
    windower.text.create('aftercast')
    windower.text.set_bg_color('aftercast',100,100,100,100)
    windower.text.set_bg_visibility('aftercast',true)
    windower.text.set_font('aftercast','Consolas')
    windower.text.set_font_size('aftercast',12)
    windower.text.set_color('aftercast',255,255,255,255)
    windower.text.set_location('aftercast',750,10)
    windower.text.set_visibility('aftercast',false)
    windower.text.set_text('aftercast','Panda')
    
    windower.text.create('buff_change')
    windower.text.set_bg_color('buff_change',100,100,100,100)
    windower.text.set_bg_visibility('buff_change',true)
    windower.text.set_font('buff_change','Consolas')
    windower.text.set_font_size('buff_change',12)
    windower.text.set_color('buff_change',255,255,255,255)
    windower.text.set_location('buff_change',1000,10)
    windower.text.set_visibility('buff_change',false)
    windower.text.set_text('buff_change','Panda')
end