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
_addon.version = '0.936'
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

require 'packet_parsing'
require 'statics'
require 'equip_processing'
require 'targets'
require 'user_functions'
require 'refresh'
require 'export'
require 'validate'
require 'flow'
require 'triggers'

initialize_packet_parsing()
gearswap_disabled = false

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
    if logging then logfile:close() end
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
            if f_name:sub(-4):lower() ~= '.lua' then
                f_name = f_name..'.lua'
            end
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

function incoming_chunk(id,data,modified,injected,blocked)
    windower.debug('incoming chunk '..id)
    
    if next_packet_events and next_packet_events.sequence_id ~= data:unpack('H',3) then
        if not next_packet_events.globals_update or next_packet_events.globals_update ~= data:unpack('H',3) then
            refresh_globals()
            next_packet_events.globals_update = data:unpack('H',3)
        end
        if next_packet_events.pet_status_change and not gearswap_disabled then
            equip_sets('pet_status_change',nil,next_packet_events.pet_status_change.newstatus,next_packet_events.pet_status_change.oldstatus)
            next_packet_events.pet_status_change = nil
        end
        if next_packet_events.pet_change then
            if next_packet_events.pet_change.pet and not gearswap_disabled then -- Losing a pet
                equip_sets('pet_change',nil,next_packet_events.pet_change.pet,false)
                next_packet_events.pet_change = nil
            elseif pet.isvalid and not gearswap_disabled then -- Gaining a pet
                equip_sets('pet_change',nil,pet,true)
                next_packet_events.pet_change = nil
            end
        end
        if not next_packet_events.pet_status_change and not next_packet_events.pet_change then
            next_packet_events = nil
        end
    end
    
    if not injected and parse.i[id] then
        parse.i[id](data,blocked)
    end
end

function outgoing_chunk(id,original,data,injected,blocked)
    windower.debug('outgoing chunk '..id)
    
    if not blocked and parse.o[id] then
        parse.o[id](data,injected)
    end
end

windower.register_event('incoming chunk',incoming_chunk)
windower.register_event('outgoing chunk',outgoing_chunk)

windower.register_event('status change',function(new,old)
    windower.debug('status change '..new)
    if gearswap_disabled or T{2,3,4}:contains(old) or T{2,3,4}:contains(new) then return end
    
    refresh_globals()
    equip_sets('status_change',nil,res.statuses[new].english,res.statuses[old].english)
end)

windower.register_event('login',function(name)
    windower.debug('login '..name)
    initialize_globals()
    windower.send_command('@wait 2;lua i gearswap refresh_user_env;')
end)
