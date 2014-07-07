--Copyright (c) 2014, Byrthnoth
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

_addon.name = 'Pet Fix'
_addon.ver = 0
_addon.author = 'Byrth'

windower.register_event('incoming chunk',function (id,original,modified,is_injected,is_blocked)
    if debugging then windower.debug('incoming chunk '..id) end
    local pref = modified:sub(1,4)
    local data = modified:sub(5)
    
-------------- ACTION PACKET ---------------
    if id == 0x28 then
        local act = {}
        act.do_not_need = get_bit_packed(data,0,8)
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
        
        local pet_indices = {}
        for i,v in pairs(windower.ffxi.get_mob_array()) do
            if v.pet_index then
                pet_indices[v.pet_index] = true
            end
        end
        
        local actor = windower.ffxi.get_mob_by_id(act.actor_id)
        if actor and pet_indices[actor.index] then
            act.category = 0
        end
        
        for i,v in pairs(act.targets) do
            local mob = windower.ffxi.get_mob_by_id(v.id)
            if mob and pet_indices[mob.index] then
                act.category = 0
                for n,m in pairs(act.targets[i].actions) do
                    act.targets[i].actions[n].animation = 0
                    act.targets[i].actions[n].add_effect_animation = 0
                    act.targets[i].actions[n].spike_effect_animation = 0
                end
            end
        end

        local react = assemble_bit_packed('',act.do_not_need,0,8)
        react = assemble_bit_packed(react,act.actor_id,8,40)
        react = assemble_bit_packed(react,act.target_count,40,50)
        react = assemble_bit_packed(react,act.category,50,54)
        react = assemble_bit_packed(react,act.param,54,70)
        react = assemble_bit_packed(react,act.unknown,70,86)
        react = assemble_bit_packed(react,act.recast,86,118)
        
        local offset = 118
        for i = 1,act.target_count do
            react = assemble_bit_packed(react,act.targets[i].id,offset,offset+32)
            react = assemble_bit_packed(react,act.targets[i].action_count,offset+32,offset+36)
            offset = offset + 36
            for n = 1,act.targets[i].action_count do
                react = assemble_bit_packed(react,act.targets[i].actions[n].reaction,offset,offset+5)
                react = assemble_bit_packed(react,act.targets[i].actions[n].animation,offset+5,offset+16)
                react = assemble_bit_packed(react,act.targets[i].actions[n].effect,offset+16,offset+21)
                react = assemble_bit_packed(react,act.targets[i].actions[n].stagger,offset+21,offset+27)
                react = assemble_bit_packed(react,act.targets[i].actions[n].param,offset+27,offset+44)
                react = assemble_bit_packed(react,act.targets[i].actions[n].message,offset+44,offset+54)
                react = assemble_bit_packed(react,act.targets[i].actions[n].unknown,offset+54,offset+85)
                
                react = assemble_bit_packed(react,act.targets[i].actions[n].has_add_effect,offset+85,offset+86)
                offset = offset + 86
                if act.targets[i].actions[n].has_add_effect then
                    react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_animation,offset,offset+6)
                    react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_effect,offset+6,offset+10)
                    react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_param,offset+10,offset+27)
                    react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_message,offset+27,offset+37)
                    offset = offset + 37
                end
                react = assemble_bit_packed(react,act.targets[i].actions[n].has_spike_effect,offset,offset+1)
                offset = offset + 1
                if act.targets[i].actions[n].has_spike_effect then
                    react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_animation,offset,offset+6)
                    react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_effect,offset+6,offset+10)
                    react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_param,offset+10,offset+24)
                    react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_message,offset+24,offset+34)
                    offset = offset + 34
                end
            end
        end
        while #react < #data do
            react = react..data:sub(#react+1,#react+1)
        end

        return pref..react
    end
end)

function get_bit_packed(dat_string,start,stop)
    local newval = 0
    
    local c_count = math.ceil(stop/8)
    while c_count >= math.ceil((start+1)/8) do
        -- Grabs the most significant byte first and works down towards the least significant.
        local cur_val = dat_string:byte(c_count)
        local scal = 256
        
        if c_count == math.ceil(stop/8) then -- Take the least significant bits of the most significant byte
        -- Moduluses by 2^number of bits into the current byte. So 8 bits in would %256, 1 bit in would %2, etc.
        -- Cuts off the top.
            cur_val = cur_val%(2^((stop-1)%8+1)) -- -1 and +1 set the modulus result range from 1 to 8 instead of 0 to 7.
        end
        
        if c_count == math.ceil((start+1)/8) then -- Take the most significant bits of the least significant byte
        -- Divides by the significance of the final bit in the current byte. So 8 bits in would /128, 1 bit in would /1, etc.
        -- Cuts off the bottom.
            cur_val = math.floor(cur_val/(2^(start%8)))
            scal = 2^(8-start%8)
        end
        
        newval = newval*scal + cur_val -- Need to multiply by 2^number of bits in the next byte
        c_count = c_count - 1
    end
    return newval
end

function assemble_bit_packed(init,val,initial_length,final_length,debug_val)
    if type(val) == 'boolean' then
        if val then val = 1 else val = 0 end
    end
    local bits = initial_length%8
    local byte_length = math.ceil(final_length/8)
    
    local out_val = 0
    if bits > 0 then
        out_val = init:byte(#init) -- Initialize out_val to the remainder in the active byte.
        init = init:sub(1,#init-1) -- Take off the active byte
    end
    out_val = out_val + val*2^bits -- left-shift val by the appropriate amount and add it to the remainder (now the lsb-s in val)
    if debug_val then print(out_val..' '..#init) end
    
    while out_val > 0 do
        init = init..string.char(out_val%256)
        out_val = math.floor(out_val/256)
    end
    while #init < byte_length do
        init = init..string.char(0)
    end
    return init
end