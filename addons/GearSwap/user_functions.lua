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


-- Functions that are directly exposed to users --


function set_language(lang)
    if _global.current_event ~= 'get_sets' then
        error('\nGearSwap: set_language() is only valid in the get_sets function', 2)
        return
    end
    if lang and type(lang) == 'string' and (lang == 'english' or lang == 'japanese') then
        rawset(_G,'language',lang)
        refresh_globals()
    else
        error('\nGearSwap: set_language() was passed an invalid value ('..tostring(lang)..'). (must be a string)', 2)
    end
end

function debug_mode(boolean)
    if type(boolean) == "boolean" then _settings.debug_mode = boolean
    elseif boolean == nil then
        _settings.debug_mode = true
    else
        error('\nGearSwap: show_swaps() was passed an invalid value ('..tostring(boolean)..'). (true/no value/nil=on, false=off)', 2)
    end
end

function show_swaps(boolean)
    if type(boolean) == "boolean" then _settings.show_swaps = boolean
    elseif boolean == nil then
        _settings.show_swaps = true
    else
        error('\nGearSwap: show_swaps() was passed an invalid value ('..tostring(boolean)..'). (true/no value/nil=on, false=off)', 2)
    end
end

function cancel_spell(boolean)
    if _global.current_event ~= 'precast' and _global.current_event ~= 'pretarget' and _global.current_event ~= 'filtered_action' then
        error('\nGearSwap: cancel_spell() is only valid in the precast, pretarget, or filtered_action functions', 2)
        return
    end
    if type(boolean) == "boolean" then _global.cancel_spell = boolean
    elseif boolean == nil then
        _global.cancel_spell = true
    else
        error('\nGearSwap: cancel_spell() was passed an invalid value ('..tostring(boolean)..'). (true/no value/nil=Cancel the spell, false=do not cancel the spell)', 2)
    end
end

function move_spell_target(position_table)
    if _global.current_event ~= 'precast' then
        error('\nGearSwap: move_spell_target() is only valid in the precast function', 2)
        return
    end
    
    if type(position_table) == 'table' and type(position_table.x or position_table.X) == 'number' and
        type(position_table.y or position_table.Y) == 'number' and
        type(position_table.z or positino_table.Z) == 'number' then
        _global.target_arrow.x = position_table.x or position_table.X
        _global.target_arrow.y = position_table.y or position_table.Y
        _global.target_arrow.z = position_table.z or position_table.Z
        print_set(_global.target_arrow)
    else
        error('\nGearSwap: move_spell_target() was passed an invalid value ('..tostring(position_table)..'). Should be a table with x, y, and z keys (offset from target)', 2)
    end
end

function change_target(name)
    if _global.current_event ~= 'pretarget' then
        error('\nGearSwap: change_target() is only valid in the pretarget function', 2)
        return
    end
    if name and type(name)=='string' then
        if valid_target(name) then
            _,_global.new_target = valid_target(name)
        else
            error('\nGearSwap: change_target() was passed an invalid value ('..tostring(name)..'). (must be a valid target)', 2)
        end
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
        _global[_global.current_event.."_cast_delay"] = tonumber(delay)
    else
        error('\nGearSwap: cast_delay() was passed an invalid value ('..tostring(delay)..'). (cast delay must be a number of seconds)', 2)
    end
end

-- Combines the provided gear sets into a new set.  Returns the result.
function set_combine(...)
    return set_merge(false,{}, ...)
end

-- Combines the provided gear sets into the equip_list set.
function equip(...)
    set_merge(true,equip_list, ...)
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
            error('\nGearSwap: disable error, passed an unrecognized slot name. ('..tostring(v)..')',2)
        end
    end
end

function enable(...)
    local enable_tab = {...}
    if type(enable_tab[1]) == 'table' then
        enable_tab = enable_tab[1] -- Compensates for people passing a table instead of a series of strings.
    end
    local sending_table = {}
    for i,v in pairs(enable_tab) do
        local local_slot = get_default_slot(v)
        if local_slot then
            disable_table[toslotid(v)] = false
            if not_sent_out_equip[local_slot] then
                sending_table[local_slot] = not_sent_out_equip[local_slot]
                not_sent_out_equip[local_slot] = nil
            end
        else
            error('\nGearSwap: enable error, passed an unrecognized slot name. ('..tostring(v)..')',2)
        end
    end
    
    return sending_table
end

function user_enable(...)
    local sending_table = enable(...)
    
    if table.length(sending_table) > 0 then
        equip(sending_table)
    end
    return sending_table
end

function command_enable(...)
    local sending_table = enable(...)
    
    if table.length(sending_table) > 0 then
        refresh_globals()
        equip_sets('equip_command',nil,sending_table)
    end
end

function print_set(set,title)
    if not set then
        if title then
            error('\nGearSwap: print_set error, '..windower.to_shift_jis(tostring(title))..' set is nil.', 2)
        else
            error('\nGearSwap: print_set error, set is nil.', 2)
        end
        return
    elseif type(set) ~= 'table' then
        if title then
            error('\nGearSwap: print_set error, '..windower.to_shift_jis(tostring(title))..' set is not a table.', 2)
        else
            error('\nGearSwap: print_set error, set is not a table.', 2)
        end
    end
    if table.length(set) == 0 then
        if title then
            msg.add_to_chat(1,'------------------'.. windower.to_shift_jis(tostring(title))..' -- Empty Table -----------------')
        else
            msg.add_to_chat(1,'-------------------------- Empty Table -------------------------')
        end
        return
    elseif title then
        msg.add_to_chat(1,'------------------------- '..windower.to_shift_jis(tostring(title))..' -------------------------')
    else
        msg.add_to_chat(1,'----------------------------------------------------------------')
    end
    local function print_element(key,value)
        if type(value) == 'table' and value.name then
            msg.add_to_chat(8,windower.to_shift_jis(tostring(key))..' '..windower.to_shift_jis(tostring(value.name))..' (Adv.)')
        else
            msg.add_to_chat(8,windower.to_shift_jis(tostring(key))..' '..windower.to_shift_jis(tostring(value)))
        end
    end
    local function cmp_key(key,tab)
        for k in pairs(tab) do
            if k:lower() == key:lower() then
                return k
            end
        end
    end
    
    if #set == table.length(set) then -- If it is a list (keyed by continuous whole number starting at 1), then print it out in order
        for key,value in ipairs(set) do
            print_element(key,value)
        end
    else -- Otherwise, try to print out the gear in order and then everything else.
        for _,key in ipairs({'main','sub','ranged','range','ammo','head','neck','lear','ear1','learring','left_ear','rear','ear2','rearring','right_ear','body','hands','lring','ring1','left_ring','rring','ring2','right_ring','back','waist','legs','feet'}) do
            local k = cmp_key(key,set)
            if k then
                print_element(k,set[k])
            end
        end
        for key,value in pairs(set) do
            if not slot_map[key] then
                print_element(key,set[key])
            end
        end
    end
    msg.add_to_chat(1,'----------------------------------------------------------------')
end

function send_cmd_user(command)
    if string.byte(1) ~= 0x40 then
        command='@'..command
    end
    windower.send_command(command)
end

function register_event_user(str,func)
    if type(func)~='function' then
        error('\nGearSwap: windower.register_event() was passed an invalid value ('..tostring(func)..'). (must be a function)', 2)
    elseif type(str) ~= 'string' then
        error('\nGearSwap: windower.register_event() was passed an invalid value ('..tostring(str)..'). (must be a string)', 2)
    end
    local id = windower.register_event(str,user_equip_sets(func))
    registered_user_events[id] = true
    return id
end

function raw_register_event_user(str,func)
    if type(func)~='function' then
        error('\nGearSwap: windower.register_event() was passed an invalid value ('..tostring(func)..'). (must be a function)', 2)
    elseif type(str) ~= 'string' then
        error('\nGearSwap: windower.register_event() was passed an invalid value ('..tostring(str)..'). (must be a string)', 2)
    end
    local id = windower.register_event(str,setfenv(func,user_env))
    registered_user_events[id] = true
    return id
end

function unregister_event_user(id)
    if type(id)~='number' then
        error('\nGearSwap: windower.unregister_event() was passed an invalid value ('..tostring(id)..'). (must be a number)', 2)
    end
    windower.unregister_event(id)
    registered_user_events[id] = nil
end

function user_equip_sets(func)
    return setfenv(function(...)
            if not gearswap.gearswap_disabled then
                gearswap.refresh_globals(true)
                return gearswap.equip_sets(func,nil,...)
            end
        end,user_env)
end

function user_unhandled_command(func)
    if type(func) ~= 'function' then
        error('\nGearSwap: unhandled_command was passed an invalid value ('..tostring(func)..'). (must be a function)', 2)
    end
    unhandled_command_events[#unhandled_command_events+1] = setfenv(func,user_env)
end

function include_user(str, load_include_in_this_table)
    if not (type(str) == 'string') then
        error('\nGearSwap: include() was passed an invalid value ('..tostring(str)..'). (must be a string)', 2)
    end
    
    str = str:lower()
    if type(package.loaded[str]) == 'table' then
        return package.loaded[str]
    elseif T{'pack'}:contains(str) then
        return
    end
    
    if str:sub(-4)~='.lua' then str = str..'.lua' end
    local path, loaded_values = pathsearch({str})
    
    if not path then
        error('\nGearSwap: Cannot find the include file ('..tostring(str)..').', 2)
    end
    
    local f, err = loadfile(path)
    if f and not err then
        if load_include_in_this_table and type(load_include_in_this_table) == 'table' then
            setmetatable(load_include_in_this_table, {__index=user_env._G})
            setfenv(f, load_include_in_this_table)
            pcall(f, load_include_in_this_table)
            return load_include_in_this_table
        else
            setfenv(f,user_env)
            return f()
        end
    else
        error('\nGearSwap: Error loading file ('..tostring(str)..'): '..err, 2)
    end
end

-- Allow the user to set a path subdirectory to check when searching for included files.
-- This path is checked as a subdirectory to each fixed path, before the fixed path itself is checked.
-- Path argument can only be a string; otherwise this is set to nil.
function user_include_path(path)
    if type(path) == 'string' then
        include_user_path = path
    else
        include_user_path = nil
    end
end


function user_midaction(bool)
    if bool == false then
        for i,v in pairs(command_registry) do
            if v.midaction then
                command_registry[i].midaction = false
            end
        end
    end

    for i,v in pairs(command_registry) do
        if type(v) == 'table' and v.midaction then
            return true, v.spell
        end
    end
    
    return false
end

function user_pet_midaction(bool)
    if bool == false then
        for i,v in pairs(command_registry) do
            if v.pet_midaction then
                command_registry.pet_midaction = false
            end
        end
    end

    for i,v in pairs(command_registry) do
        if v.pet_midaction then
            return true, v.spell
        end
    end

    return false
end

function add_to_chat_user(num,str)
    local backup_str
    if type(num) == 'string' then
        -- It was passed a string as the first argument.
        str = not tonumber(str) and str or num
        num = 8
    elseif not num and str and type(str) == 'string' then
        -- It only needs the number.
        num=8
    end
    
    if language == 'japanese' then
        msg.add_to_chat(num,windower.to_shift_jis(str))
    else
        msg.add_to_chat(num,str)
    end
end


function user_sleep(delay)
    if not delay then
        error('\nGearSwap: coroutine.sleep() not passed a delay value', 2)
    elseif type(delay) ~= 'number' or delay < 0 then
        error('\nGearSwap: coroutine.sleep() was passed an invalid value ('..tostring(delay)..'). (must be a number >= 0)', 2)
    else
        coroutine.yield('sleep',delay)
    end
end

function user_yield()
    coroutine.yield('yield')
end


-- Define the user windower functions.
user_windower = {register_event = register_event_user, raw_register_event = raw_register_event_user,
    unregister_event = unregister_event_user, send_command = send_cmd_user,add_to_chat=add_to_chat_user}
user_coroutine = coroutine
user_coroutine.sleep = user_sleep
user_coroutine.yield = user_yield
setmetatable(user_windower,{__index=windower})