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



-----------------------------------------------------------------------------------
--Name: equip_sets(swap_type,ts,val1,val2)
--Desc: General purpose equipment pipeline / user function caller. 
--Args:
---- swap_type - Determines equip_sets' behavior in terms of which user function it
--      attempts to call
---- ts - index of command_registry or nil for pretarget/commands
---- val1 - First argument to be passed to the user function
---- val2 - Second argument to be passed to the user function
-----------------------------------------------------------------------------------
--Return (varies by swap type):
---- pretarget : empty string to blank packet or full string
---- Everything else : nil
-----------------------------------------------------------------------------------
function equip_sets(swap_type,ts,...)
    local results
    local var_inps = {...}
    local val1 = var_inps[1]
    local val2 = var_inps[2]
    table.reassign(_global,command_registry[ts] or {pretarget_cast_delay = 0,precast_cast_delay=0,cancel_spell = false, new_target=false,target_arrow={x=0,y=0,z=0}})
    _global.current_event = tostring(swap_type)
    
    if _global.current_event == 'precast' and val1 and val1.english and val1.english:find('Geo-') then
        _global.target_arrow = initialize_arrow_offset(val1.target)
    end
    
    windower.debug(tostring(swap_type)..' enter')
    if showphase or debugging.general then msg.debugging(8,windower.to_shift_jis(tostring(swap_type))..' enter') end
    
    local cur_equip = table.reassign({},update_equipment())
    
    table.reassign(equip_list,{})
    table.reassign(player.equipment,to_names_set(cur_equip))
    for i,v in pairs(slot_map) do
        if not player.equipment[i] then
            player.equipment[i] = player.equipment[toslotname(v)]
        end
    end
    
    logit('\n\n'..tostring(os.clock)..'(15) equip_sets: '..tostring(swap_type))
    if val1 then
        if type(val1) == 'table' and val1.english then
            logit(' : '..val1.english)
        else
            logit(' : Unknown type val1- '..tostring(val1))
        end
    else
        logit(' : nil-or-false')
    end
    if val2 then
        if type(val2) == 'table' and val2.type then logit(' : '..val2.type)
        else
            logit(' : Unknown type val2- '..tostring(val2))
        end
    else
        logit(' : nil-or-false')
    end
    
    if type(swap_type) == 'string' then
        msg.debugging("Entering "..swap_type)
    else
        msg.debugging("Entering User Event "..tostring(swap_type))
    end
    
    if not val1 then val1 = {}
        if debugging.general then
            msg.debugging(8,'val1 error')
        end
    end

    
    if type(swap_type) == 'function' then
        results = { pcall(swap_type,...) }
        if not table.remove(results,1) then error('\nUser Event Error: '..results[1]) end
    elseif swap_type == 'equip_command' then
        equip(val1)
    else
        user_pcall(swap_type,...)
    end
    
--[[    local c
    if type(swap_type) == 'function' then
        c = coroutine.create(swap_type)
    elseif swap_type == 'equip_command' then
        equip(val1)
    elseif type(swap_type) == 'string' and user_env[swap_type] and type(user_env[swap_type]) == 'function' then
        c = coroutine.create(user_env[swap_type])
    elseif type(swap_type) == 'string' and user_env[swap_type] then
        msg.addon_msg(123,windower.to_shift_jis(tostring(str))..'() exists but is not a function')
    end
    
    if c then
        while coroutine.status(c) == 'suspended' do
            local err, typ, val = coroutine.resume(c,unpack(var_inputs))
            if not err then
                error('\nGearSwap has detected an error in the user function '..tostring(swap_type)..':\n'..typ)
            elseif typ then
                if typ == 'sleep' and type(val) == 'number' and val >= 0 then
                    -- coroutine slept
                    err, typ, val = coroutine.schedule(c,val)
                else
                    -- Someone yielded or slept with a nonsensical argument.
                    err, typ, val = coroutine.resume(c)
                end
            else
                -- coroutine finished
            end
        end 
    end]]
    
    
    if type(swap_type) == 'string' and (swap_type == 'pretarget' or swap_type == 'filtered_action') then -- Target may just have been changed, so make the ind now.
        ts = command_registry:new_entry(val1)
--    elseif type(swap_type) == 'string' and swap_type == 'precast' and not command_registry[ts] and debugging.command_registry then
--        print_set(spell,'precast nil error') -- spell's scope changed to local
    end
    
    if player.race ~= 'Precomposed NPC' then
        -- Short circuits the routine and gets out  before equip processing
        -- if there's no swapping to be done because the user is a monster.
        
        for v,i in pairs(default_slot_map) do
            if equip_list[i] and encumbrance_table[v] then
                not_sent_out_equip[i] = equip_list[i]
                equip_list[i] = nil
                msg.debugging(i..' slot was not equipped because you are encumbered.')
            end
        end
        
        table.update(equip_list_history,equip_list)
        
        -- Attempts to identify the player-specified item in inventory
        -- Starts with (i=slot name, v=item name) 
        -- Ends with (i=slot id and v={bag_id=bag_id, slot=inventory slot}).
        local equip_next,priorities = unpack_equip_list(equip_list,cur_equip)
        
        if (_settings.show_swaps and table.length(equip_next) > 0) or _settings.demo_mode then --and table.length(equip_next)>0 then
            local tempset = to_names_set(equip_next)
            print_set(tempset,tostring(swap_type))
        end
        
        if (buffactive.charm or player.charmed) or (player.status == 2 or player.status == 3) then -- dead or engaged dead statuses
            local failure_reason
            if (buffactive.charm or player.charmed) then
                failure_reason = 'Charmed'
            elseif player.status == 2 or player.status == 3 then
                failure_reason = 'KOed'
            end
            msg.debugging("Cannot change gear right now: "..tostring(failure_reason))
            logit('\n\n'..tostring(os.clock)..'(69) failure_reason: '..tostring(failure_reason))
        else
            local chunk_table = L{}
            for eq_slot_id,priority in priorities:it() do
                if equip_next[eq_slot_id] and not encumbrance_table[eq_slot_id] and not _settings.demo_mode then
                    local minichunk = equip_piece(eq_slot_id,equip_next[eq_slot_id].bag_id,equip_next[eq_slot_id].slot)
                    chunk_table:append(minichunk)
                end
            end

            if swap_type == 'midcast' and command_registry[ts] and command_registry[ts].proposed_packet and not _settings.demo_mode then
                windower.packets.inject_outgoing(command_registry[ts].proposed_packet:byte(1),command_registry[ts].proposed_packet)
            end

            if chunk_table.n >= 3 then
                local big_chunk = string.char(0x51,0x24,0,0,chunk_table.n,0,0,0)
                for i=1,chunk_table.n do
                    big_chunk = big_chunk..chunk_table[i]
                end
                while string.len(big_chunk) < 0x48 do big_chunk = big_chunk..string.char(0) end
                windower.packets.inject_outgoing(0x51,big_chunk)
            elseif chunk_table.n > 0 then
                for i=1,chunk_table.n do
                    local chunk = string.char(0x50,4,0,0)..chunk_table[i]
                    windower.packets.inject_outgoing(0x50,chunk)
                end
            end
        end
    end
    
    windower.debug(tostring(swap_type)..' exit')
    
    if type(swap_type) == 'function' then
        return unpack(results)
    end
    
    return equip_sets_exit(swap_type,ts,val1)
end


-----------------------------------------------------------------------------------
--Name: equip_sets_exit(swap_type,ind,val1)
--Desc: Cleans up the global table and leaves equip_sets properly.
--Args:
---- swap_type - Current swap type for equip_sets
---- ts - Current index of command_registry
---- val1 - First argument of equip_sets
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function equip_sets_exit(swap_type,ts,val1)
    if command_registry[ts] then
        table.update(command_registry[ts],_global)
    end
    if type(swap_type) == 'string' then
        if swap_type == 'pretarget' then
            
            if command_registry[ts].cancel_spell then
                msg.debugging("Action canceled ("..storedcommand..' '..val1.target.raw..")")
                storedcommand = nil
                command_registry:delete_entry(ts)
                return true
            elseif not ts or not command_registry[ts] or not storedcommand then
                msg.debugging('This case should not be hittable - 1')
                return true
            end
            
            if command_registry[ts].new_target then
                val1.target = command_registry[ts].new_target -- Switch target, if it is requested.
            end
            
            -- Compose a proposed packet for the given action (this should be possible after pretarget)
            command_registry[ts].spell = val1
            if val1.target and val1.target.id and val1.target.index and val1.prefix and unify_prefix[val1.prefix] then
                if val1.prefix == '/item' then
                    -- Item use packet handling here
                    if bit.band(val1.target.spawn_type, 2) == 2 and find_inventory_item(val1.id) then
                        -- 0x36 packet
                        if val1.target.distance <= 6 then
                            command_registry[ts].proposed_packet = assemble_menu_item_packet(val1.target.id,val1.target.index,val1.id)
                        else
                            windower.add_to_chat(67, "Target out of range.")
                        end
                    elseif find_usable_item(val1.id) then
                        -- 0x37 packet
                        command_registry[ts].proposed_packet = assemble_use_item_packet(val1.target.id,val1.target.index,val1.id)
                    end
                    if not command_registry[ts].proposed_packet then
                        command_registry:delete_entry(ts)
                    end
                elseif outgoing_action_category_table[unify_prefix[val1.prefix]] then
                    if filter_precast(val1) then
                        command_registry[ts].proposed_packet = assemble_action_packet(val1.target.id,val1.target.index,outgoing_action_category_table[unify_prefix[val1.prefix]],val1.id,command_registry[ts].target_arrow)
                        if not command_registry[ts].proposed_packet then
                            command_registry:delete_entry(ts)
                            
                            msg.debugging("Unable to create a packet for this command because the target is still invalid after pretarget ("..storedcommand..' '..val1.target.raw..")")
                            storedcommand = nil
                            return storedcommand..' '..val1.target.raw
                        end
                    end
                else
                    msg.debugging(8,"Hark, what weird prefix through yonder window breaks? "..tostring(val1.prefix))
                end
            end
            
            if ts and command_registry[ts] and val1.target then
                if st_targs[val1.target.raw] then
                -- st targets
                    st_flag = true
                elseif not val1.target.name then
                -- Spells with invalid pass_through_targs, like using <t> without a target
                    command_registry:delete_entry(ts)
                    msg.debugging("Change target was used to pick an invalid target ("..storedcommand..' '..val1.target.raw..")")
                    local ret = storedcommand..' '..val1.target.raw
                    storedcommand = nil
                    return ret
                else
                -- Spells with complete target information
                -- command_registry[ts] is deleted for cancelled spells
                    if command_registry[ts].pretarget_cast_delay == 0 then
                        equip_sets('precast',ts,val1)
                    else
                        windower.send_command('@wait '..command_registry[ts].pretarget_cast_delay..';lua i '.._addon.name..' pretarget_delayed_cast '..ts)
                    end
                    return true
                end
            elseif not ts or not command_registry[ts] then
                msg.debugging('This case should not be hittable - 2')
                return true
            end

        elseif swap_type == 'precast' then
            -- Update the target_arrow
            if val1.prefix ~= '/item' then
                command_registry[ts].proposed_packet = assemble_action_packet(val1.target.id,val1.target.index,outgoing_action_category_table[unify_prefix[val1.prefix]],val1.id,command_registry[ts].target_arrow)
            end
            return precast_send_check(ts)
        elseif swap_type == 'filtered_action' and command_registry[ts] and command_registry[ts].cancel_spell then
            storedcommand = nil
            command_registry:delete_entry(ts)
            return true
        elseif swap_type == 'midcast' and _settings.demo_mode then
            command_registry[ts].midaction = false
            equip_sets('aftercast',ts,val1)
        elseif swap_type == 'aftercast' then
            if ts then
                command_registry:delete_entry(ts)
            end
        elseif swap_type == 'pet_aftercast' then
            if ts then
                command_registry:delete_entry(ts)
            end
        end
    end
end


-----------------------------------------------------------------------------------
--Name: user_pcall(str,val1,val2,exit_funct)
--Desc: Calls a user function, if it exists. If not, throws an error.
--Args:
---- str - Function's key in user_env.
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function user_pcall(str,...)
    if user_env then
        if type(user_env[str]) == 'function' then
            bool,err = pcall(user_env[str],...)
            if not bool then error('\nGearSwap has detected an error in the user function '..str..':\n'..err) end
        elseif user_env[str] then
            msg.addon_msg(123,windower.to_shift_jis(tostring(str))..'() exists but is not a function')
        end
    end
end


-----------------------------------------------------------------------------------
--Name: pretarget_delayed_cast(ts)
--Desc: Triggers an outgoing action packet (if the passed key is valid).
--Args:
---- ts - Timestamp argument to precast_delayed_cast
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function pretarget_delayed_cast(ts)
    ts = tonumber(ts)
    if ts then
        equip_sets('precast',ts,command_registry[ts].spell)
    else
        msg.debugging("Bad index passed to pretarget_delayed_cast")
    end
end



-----------------------------------------------------------------------------------
--Name: precast_send_check(ts)
--Desc: Determines whether or not to send the current packet.
--      Cancels if _global.cancel_spell is true
--          If command_registry[ts].precast_cast_delay is not 0, cues precast_delayed_cast with the proper
--          delay instead of sending immediately.
--Args:
---- ts - key of command_registry
-----------------------------------------------------------------------------------
--Returns:
---- true (to block) or the outgoing packet
-----------------------------------------------------------------------------------
function precast_send_check(ts)
    if ts and command_registry[ts] then
        if command_registry[ts].cancel_spell then
            command_registry:delete_entry(ts)
        else
            if command_registry[ts].precast_cast_delay == 0 then
                send_action(ts)
                return
            else
                windower.send_command('@wait '..command_registry[ts].precast_cast_delay..';lua i '.._addon.name..' precast_delayed_cast '..ts)
            end
        end
    end
    return true
end


-----------------------------------------------------------------------------------
--Name: precast_delayed_cast(ts)
--Desc: Triggers an outgoing action packet (if the passed key is valid).
--Args:
---- ts - Timestamp argument to precast_delayed_cast
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function precast_delayed_cast(ts)
    ts = tonumber(ts)
    if ts then
        send_action(ts)
    else
        msg.debugging("Bad index passed to precast_delayed_cast")
    end
end


-----------------------------------------------------------------------------------
--Name: send_action(ts)
--Desc: Sends the cued action packet, if it exists.
--Args:
---- ts - index for a command_registry entry that includes an action packet (hopefully)
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function send_action(ts)
    command_registry[ts].midaction = true
    equip_sets('midcast',ts,command_registry[ts].spell)
end