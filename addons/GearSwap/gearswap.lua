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

_addon.name = 'GearSwap'
_addon.version = '0.915'
_addon.author = 'Byrth'
_addon.commands = {'gs','gearswap'}

if windower.file_exists(windower.addon_path..'data/bootstrap.lua') then
    debugging = {windower_debug = true,command_registry = false,general=false,logging=false}
else
    debugging = {}
end

__raw = {lower = string.lower, upper = string.upper, debug=windower.debug,text={create=windower.text.create,
    delete=windower.text.delete,registry = {}},prim={create=windower.prim.create,delete=windower.prim.delete,registry={}}}


language = 'english'
file = require 'files'
require 'strings'
require 'tables'
require 'logger'
-- Restore the normal error function (logger changes it)
error = _raw.error

require 'lists'
require 'sets'


windower.text.create = function (str)
    if __raw.text.registry[str] then
        msg.addon_msg(123,'Text object cannot be created because it already exists.')
    else
        __raw.text.registry[str] = true
        __raw.text.create(str)
    end
end

windower.text.delete = function (str)
    if __raw.text.registry[str] then
        local library = false
        if windower.text.saved_texts then
            for i,v in pairs(windower.text.saved_texts) do
                if v._name == str then
                    __raw.text.registry[str] = nil
                    windower.text.saved_texts[i]:destroy()
                    library = true
                    break
                end
            end
        end
        if not library then
            -- Text was not created through the library, so delete it normally
            __raw.text.registry[str] = nil
            __raw.text.delete(str)
        end
    else
        __raw.text.delete(str)
    end
end

windower.prim.create = function (str)
    if __raw.prim.registry[str] then
        msg.addon_msg(123,'Primitive cannot be created because it already exists.')
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
mime = require 'mime'
res = require 'resources'
extdata = require 'extdata'
require 'helper_functions'
require 'actions'
packets = require 'packets'

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
    
    for i,v in pairs(splitup) do splitup[i] = windower.from_shift_jis(windower.convert_auto_trans(v)) end

    local cmd = table.remove(splitup,1):lower()
    
    if cmd == 'c' then
        if gearswap_disabled then return end
        if splitup[1] then
            refresh_globals()
            equip_sets('self_command',nil,_raw.table.concat(splitup,' '))
        else
            msg.addon_msg(123,'No self command passed.')
        end
    elseif cmd == 'equip' then
        if gearswap_disabled then return end
        local key_list = parse_set_to_keys(splitup)
        local set = get_set_from_keys(key_list)
        if set then
            refresh_globals()
            equip_sets('equip_command',nil,set)
        else
            msg.addon_msg(123,'Equip command cannot be completed. That set does not exist.')
        end
    elseif cmd == 'export' then
        export_set(splitup)
    elseif cmd == 'validate' then
        if user_env and user_env.sets then
            refresh_globals()
            validate(splitup)
        else
            msg.addon_msg(123,'There is nothing to validate because there is no file loaded.')
        end
    elseif cmd == 'l' or cmd == 'load' then
        if splitup[1] then
            local f_name = table.concat(splitup,' ')
            if pathsearch({f_name}) then
                refresh_globals()
                command_registry = Command_Registry.new()
                load_user_files(false,f_name)
            else
                msg.addon_msg(123,'File not found.')
            end
        else
            msg.addon_msg(123,'No file name was provided.')
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
    elseif strip(cmd) == 'help' then
        print('GearSwap: Valid commands are:')
        print(' c <string>      : passes the string to the user\'s self_command function.')
        print(' equip <string>  : attempts to equip the set indicated by the string.')
        print(' debugmode       : toggles debugmode on or off.')
        print(' demomode        : toggles demomode on or off.')
        print(' showswaps       : toggles whether gearswap displays equipment changes in the chat log.')
        print(' load <string>   : attempts to load the user file indicated by the string.')
        print(' reload          : reloads the current user file.')
        print(' export <opts>   : Exports your item collections based on the passed options.')
        print(' disable <slot>  : Disables equip commands targeting a specified slot.')
        print(' validate <opts> : Checks your current inventory against your item collections (or vice versa).')
        print('  Please see the gearswap/README.md file for more details.')
    elseif _settings.debug_mode and strip(cmd) == 'eval' then
        assert(loadstring(table.concat(splitup,' ')))()
    else
        local handled = false
        if not gearswap_disabled then
            for i,v in ipairs(unhandled_command_events) do
                handled = equip_sets(v,nil,cmd,unpack(splitup))
                if handled then break end
            end
        end
        if not handled then
            print('GearSwap: Command not found')
        end
    end
end)

function disenable(tab,funct,functname,pol)
    local slot_name = ''
    local ltab = L{}
    for i,v in pairs(tab) do
        ltab:append(v:gsub('[^%a_%d]',''):lower())
    end
    if ltab:contains('all') then
        funct('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
        print('GearSwap: All slots '..functname..'d.')
    elseif ltab.n > 0  then
        local found = L{}
        local not_found = L{}
        for slot_name in ltab:it() do
            if slot_map[slot_name] then
                funct(slot_name)
                found:append(slot_name)
            else
                not_found:append(slot_name)
            end
        end
        if found.n > 0 then
            print('GearSwap: '..found:tostring()..' slot'..(found.n>1 and 's' or '')..' '..functname..'d.')
        end
        if not_found.n > 0 then
            print('GearSwap: Unable to find slot'..(not_found.n>1 and 's' or '')..' '..not_found:tostring()..'.')
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
            equip_sets('pet_status_change',nil,next_packet_events.pet_status_change.newstatus,next_packet_events.pet_status_change.oldstatus)
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
        command_registry = Command_Registry.new()
        table.clear(not_sent_out_equip)
        
        player.id = data:unpack('I',0x05)
        player.index = data:unpack('H',0x09)
        if player.main_job_id and player.main_job_id ~= data:byte(0xB5) and player.name and player.name == data:unpack('z',0x85) then
            windower.debug('job change on zone')
            load_user_files(data:byte(0xB5))
        else
            player.name = data:unpack('z',0x85)
        end
        player.main_job_id = data:byte(0xB5)
        player.sub_job_id = data:byte(0xB8)
        player.vitals.max_hp = data:unpack('I',0xE9)
        player.vitals.max_mp = data:unpack('I',0xED)
        player.max_hp = data:unpack('I',0xE9)
        player.max_mp = data:unpack('I',0xED)
        update_job_names()
        
        world.zone_id = data:unpack('H',0x31)
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
        weather_update(data:byte(0x69))
        world.logged_in = true
        
        _ExtraData.world.in_mog_house = data:byte(0x81) == 1
        
        _ExtraData.player.base_str = data:unpack('H',0xCD)
        _ExtraData.player.base_dex = data:unpack('H',0xCF)
        _ExtraData.player.base_vit = data:unpack('H',0xD1)
        _ExtraData.player.base_agi = data:unpack('H',0xD3)
        _ExtraData.player.base_int = data:unpack('H',0xD5)
        _ExtraData.player.base_mnd = data:unpack('H',0xD7)
        _ExtraData.player.base_chr = data:unpack('H',0xD9)
        _ExtraData.player.add_str = data:unpack('h',0xDB)
        _ExtraData.player.add_dex = data:unpack('h',0xDD)
        _ExtraData.player.add_vit = data:unpack('h',0xDF)
        _ExtraData.player.add_agi = data:unpack('h',0xE1)
        _ExtraData.player.add_int = data:unpack('h',0xE3)
        _ExtraData.player.add_mnd = data:unpack('h',0xE5)
        _ExtraData.player.add_chr = data:unpack('h',0xE7)
        
        _ExtraData.player.str = _ExtraData.player.base_str + _ExtraData.player.add_str
        _ExtraData.player.dex = _ExtraData.player.base_dex + _ExtraData.player.add_dex
        _ExtraData.player.vit = _ExtraData.player.base_vit + _ExtraData.player.add_vit
        _ExtraData.player.agi = _ExtraData.player.base_agi + _ExtraData.player.add_agi
        _ExtraData.player.int = _ExtraData.player.base_int + _ExtraData.player.add_int
        _ExtraData.player.mnd = _ExtraData.player.base_mnd + _ExtraData.player.add_mnd
        _ExtraData.player.chr = _ExtraData.player.base_chr + _ExtraData.player.add_chr
        refresh_ffxi_info()
    elseif id == 0x00B then
        -- Blank temporary items when zoning.
        items.temporary = make_inventory_table()
    elseif id == 0x0E and pet.index and pet.index == data:unpack('H',9) and math.floor((data:byte(11)%8)/4)== 1 then
        local status_id = data:byte(32)
        -- Filter all statuses aside from Idle/Engaged/Dead/Engaged dead.
        if pet.status_id ~= status_id and (status_id < 4 or status_id == 33 or status_id == 47) then
            if not next_packet_events then next_packet_events = {sequence_id = data:unpack('H',3)} end
            next_packet_events.pet_status_change = {newstatus=res.statuses[status_id][language],oldstatus=pet.status}
            pet.status = res.statuses[status_id][language]
            pet.status_id = status_id
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
                msg.debugging("Your "..slot_name.." slot is now unlocked.")
            end
            encumbrance_table[slot_id] = tf
        end
        if table.length(tab) > 0 then
            refresh_globals()
            equip_sets('equip_command',nil,tab)
        end
    elseif id == 0x01E then
        local bag = to_windower_compact(res.bags[data:byte(0x09)].english)
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
        local bag = to_windower_compact(res.bags[data:byte(0x0B)].english)
        local slot = data:byte(0x0C)
        if not items[bag][slot] then items[bag][slot] = make_empty_item_table(slot) end
        items[bag][slot].id = data:unpack('H',9)
        items[bag][slot].count = data:unpack('I',5)
        items[bag][slot].status = data:byte(0x0D)
    elseif id == 0x020 then
        local bag = to_windower_compact(res.bags[data:byte(0x0F)].english)
        local slot = data:byte(0x10)
        if not items[bag][slot] then items[bag][slot] = make_empty_item_table(slot) end
        items[bag][slot].id = data:unpack('H',0x0D)
        items[bag][slot].count = data:unpack('I',5)
        items[bag][slot].bazaar = data:unpack('I',9)
        items[bag][slot].status = data:byte(0x11)
        items[bag][slot].extdata = data:sub(0x12,0x29)
        -- Did not mess with linkshell stuff
    elseif id == 0x28 then
        inc_action(windower.packets.parse_action(data))
    elseif id == 0x29 then
        if gearswap_disabled then return end
        local arr = {}
        arr.actor_id = data:unpack('I',0x05)
        arr.target_id = data:unpack('I',0x09)
        arr.param_1 = data:unpack('I',0x0D)
        arr.param_2 = data:unpack('I',0x11)%64 -- First 6 bits
        arr.param_3 = math.floor(data:unpack('I',0x11)/64) -- Rest
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

        local subj_ind = data:unpack('H', 0x35) / 8
        if subj_ind == 0 and pet.isvalid then
            if not next_packet_events then next_packet_events = {sequence_id = data:unpack('H',3)} end
            refresh_globals()
            pet.isvalid = false
            _ExtraData.pet = {}
            next_packet_events.pet_change = {pet = table.reassign({},pet)}
        elseif subj_ind ~= 0 and not pet.isvalid then
            if not next_packet_events then next_packet_events = {sequence_id = data:unpack('H',3)} end
            _ExtraData.pet.tp = 0
            next_packet_events.pet_change = {subj_ind = subj_ind}
        end
    elseif id == 0x044 then
        -- No idea what this is doing
    elseif id == 0x050 then
        local inv = items[to_windower_compact(res.bags[data:byte(7)].english)]
        if data:byte(5) ~= 0 then
            items.equipment[toslotname(data:byte(6))] = {slot=data:byte(5),bag_id = data:byte(7)}
            if not inv[data:byte(5)] then inv[data:byte(5)] = make_empty_item_table(data:byte(5)) end
            items[to_windower_compact(res.bags[data:byte(7)].english)][data:byte(5)].status = 5 -- Set the status to "equipped"
        else
            items.equipment[toslotname(data:byte(6))] = {slot=empty,bag_id=0}
            if not inv[data:byte(5)] then inv[data:byte(5)] = make_empty_item_table(data:byte(5)) end
            items[to_windower_compact(res.bags[data:byte(7)].english)][data:byte(5)].status = 0 -- Set the status to "unequipped"
        end
    elseif id == 0x053 then
        if data:unpack('H',0xD) == 0x12D and player then
            -- You're unable to use trust magic if you're not the party leader or solo
            local ts,tab = command_registry:find_by_time()
            if tab and tab.spell and tab.spell.prefix ~= '/pet' then
                tab.spell.action_type = 'Interruption'
                tab.spell.interrupted = true
                equip_sets('aftercast',nil,tab.spell)
            end
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
        player.max_hp = data:unpack('I',5)
        player.max_mp = data:unpack('I',9)
        player.main_job_id = data:byte(13)
        player.main_job_level = data:byte(14)
        
        _ExtraData.player.nation_id = data:byte(0x51)
        _ExtraData.player.nation = res.regions[_ExtraData.player.nation_id][language] or 'None'
        _ExtraData.player.base_str = data:unpack('H',0x15)
        _ExtraData.player.base_dex = data:unpack('H',0x17)
        _ExtraData.player.base_vit = data:unpack('H',0x19)
        _ExtraData.player.base_agi = data:unpack('H',0x1B)
        _ExtraData.player.base_int = data:unpack('H',0x1D)
        _ExtraData.player.base_mnd = data:unpack('H',0x1F)
        _ExtraData.player.base_chr = data:unpack('H',0x21)
        _ExtraData.player.add_str = data:unpack('h',0x23)
        _ExtraData.player.add_dex = data:unpack('h',0x25)
        _ExtraData.player.add_vit = data:unpack('h',0x27)
        _ExtraData.player.add_agi = data:unpack('h',0x29)
        _ExtraData.player.add_int = data:unpack('h',0x2B)
        _ExtraData.player.add_mnd = data:unpack('h',0x2D)
        _ExtraData.player.add_chr = data:unpack('h',0x2F)
        _ExtraData.player.attack = data:unpack('H',0x31)
        _ExtraData.player.defense = data:unpack('H',0x33)
        _ExtraData.player.fire_resistance = data:unpack('h',0x35)
        _ExtraData.player.wind_resistance = data:unpack('h',0x37)
        _ExtraData.player.lightning_resistance = data:unpack('h',0x39)
        _ExtraData.player.light_resistance = data:unpack('h',0x3B)
        _ExtraData.player.ice_resistance = data:unpack('h',0x3D)
        _ExtraData.player.earth_resistance = data:unpack('h',0x3F)
        _ExtraData.player.water_resistance = data:unpack('h',0x41)
        _ExtraData.player.dark_resistance = data:unpack('h',0x43)
        
        _ExtraData.player.str = _ExtraData.player.base_str + _ExtraData.player.add_str
        _ExtraData.player.dex = _ExtraData.player.base_dex + _ExtraData.player.add_dex
        _ExtraData.player.vit = _ExtraData.player.base_vit + _ExtraData.player.add_vit
        _ExtraData.player.agi = _ExtraData.player.base_agi + _ExtraData.player.add_agi
        _ExtraData.player.int = _ExtraData.player.base_int + _ExtraData.player.add_int
        _ExtraData.player.mnd = _ExtraData.player.base_mnd + _ExtraData.player.add_mnd
        _ExtraData.player.chr = _ExtraData.player.base_chr + _ExtraData.player.add_chr
                
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
        if data:byte(7)%128 == 4 and player.index == data:unpack('H',0x0D) then -- You are the owner
            _ExtraData.pet.tp = data:unpack('H',0x11)
        end
    elseif id == 0x068 then
        if data:byte(7)%128 == 4 and player.id == data:unpack('I',0x09) then -- You are the owner
            _ExtraData.pet.tp = data:unpack('H',0x11)
        end
    elseif id == 0x076 then
        partybuffs = {}
        for i = 0,4 do
            if data:unpack('I',i*48+5) == 0 then
                break
            else
                local index = data:unpack('H',i*48+5+4)
                partybuffs[index] = {
                    id = data:unpack('I',i*48+5+0),
                    index = data:unpack('H',i*48+5+4),
                    buffs = {}
                }
                for n=1,32 do
                    partybuffs[index].buffs[n] = data:byte(i*48+5+16+n-1) + 256*( math.floor( data:byte(i*48+5+8+ math.floor((n-1)/4)) / 4^((n-1)%4) )%4)
                end
                
                
                if alliance[1] then
                    local cur_player
                    for n,m in pairs(alliance[1]) do
                        if type(m) == 'table' and m.mob and m.mob.index == index then
                            cur_player = m
                            break
                        end
                    end
                    local new_buffs = convert_buff_list(partybuffs[index].buffs)
                    if cur_player and cur_player.buffactive then
                        local old_buffs = cur_player.buffactive
                    -- Make sure the character existed before (with a buffactive list) - Avoids zoning.
                        for n,m in pairs(new_buffs) do
                            if type(n) == 'number' and m ~= old_buffs[n] then
                                if not old_buffs[n] or m > old_buffs[n] then -- gaining buff
                                    equip_sets('party_buff_change',nil,cur_player,res.buffs[n][language],true,copy_entry(res.buffs[n]))
                                    old_buffs[n] = nil
                                else -- losing buff
                                    equip_sets('party_buff_change',nil,cur_player,res.buffs[n][language],false,copy_entry(res.buffs[n]))
                                    old_buffs[n] = nil
                                end
                            elseif type(n) ~= 'number' then
                                -- Clear out the string entries so we don't have to iterate over them in the second loop
                                old_buffs[n] = nil
                            end
                        end
                        
                        for n,m in pairs(old_buffs) do
                            if type(n) == 'number' and m ~= new_buffs[n] then-- losing buff
                                equip_sets('party_buff_change',nil,cur_player,res.buffs[n][language],false,copy_entry(res.buffs[n]))
                            end
                        end
                    end
                    if cur_player then
                        cur_player.buffactive = new_buffs
                    end
                end
                
            end
        end
    elseif id == 0x0DF and data:unpack('I',5) == player.id then
        player.vitals.hp = data:unpack('I',9)
        player.vitals.mp = data:unpack('I',13)
        player.vitals.tp = data:unpack('I',0x11)
        player.vitals.hpp = data:byte(0x17)
        player.vitals.mpp = data:byte(0x18)
        
        player.hp = data:unpack('I',9)
        player.mp = data:unpack('I',13)
        player.tp = data:unpack('I',0x11)
        player.hpp = data:byte(0x17)
        player.mpp = data:byte(0x18)
    elseif id == 0x0E2 and data:unpack('I',5)==player.id then
        player.vitals.hp = data:unpack('I',9)
        player.vitals.mp = data:unpack('I',0xB)
        player.vitals.tp = data:unpack('I',0x11)
        player.vitals.hpp = data:byte(0x1E)
        player.vitals.mpp = data:byte(0x1F)
        
        player.hp = data:unpack('I',9)
        player.mp = data:unpack('I',0xB)
        player.tp = data:unpack('I',0x11)
        player.hpp = data:byte(0x1E)
        player.mpp = data:byte(0x1F)
    elseif id == 0x117 then
        for i=0x49,0x85,4 do
            local arr = data:sub(i,i+3)
            local inv = items[to_windower_compact(res.bags[arr:byte(3)].english)]
            if arr:byte(1) ~= 0 then
                items.equipment[toslotname(arr:byte(2))] = {slot=arr:byte(1),bag_id = arr:byte(3)}
                if not inv[arr:byte(1)] then inv[arr:byte(1)] = make_empty_item_table(arr:byte(1)) end
                items[to_windower_compact(res.bags[arr:byte(3)].english)][arr:byte(1)].status = 5 -- Set the status to "equipped"
            else
                items.equipment[toslotname(arr:byte(2))] = {slot=empty,bag_id=0}
                if not inv[arr:byte(1)] then inv[arr:byte(1)] = make_empty_item_table(arr:byte(1)) end
                items[to_windower_compact(res.bags[arr:byte(3)].english)][arr:byte(1)].status = 0 -- Set the status to "unequipped"
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
        for ts,v in pairs(command_registry) do
            if v.midaction then
                command_registry:delete_entry(ts)
            end
        end
    end
    
    refresh_globals()
    equip_sets('buff_change',nil,buff_name,true,copy_entry(res.buffs[buff_id]))
end)

windower.register_event('lose buff',function(buff_id)
    if not res.buffs[buff_id] then
        error('GearSwap: No known status for buff id #'..tostring(buff_id))
    end
    local buff_name = res.buffs[buff_id][language]
    windower.debug('lose buff '..buff_name..' ('..tostring(buff_id)..')')
    if gearswap_disabled then return end
    refresh_globals()
    equip_sets('buff_change',nil,buff_name,false,copy_entry(res.buffs[buff_id]))
end)

windower.register_event('login',function(name)
    windower.debug('login '..name)
    initialize_globals()
    windower.send_command('@wait 2;lua i gearswap refresh_user_env;')
end)
