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

parse = {
    i={}, -- Incoming packets
    o={}  -- Outgoing packets, currently none are really parsed for information
    }

parse.i[0x00A] = function (data)
    windower.debug('zone change')
    command_registry = Command_Registry.new()
    table.clear(not_sent_out_equip)
    
    player.id = data:unpack('I',0x05)
    player.index = data:unpack('H',0x09)
    if player.main_job_id and player.main_job_id ~= data:byte(0xB5) and player.name and player.name == data:unpack('z',0x85) and not gearswap_disabled then
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
    
    blank_0x063_v9_inc = true
end

parse.i[0x00B] = function(data)
    -- Blank temporary items when zoning.
    items.temporary = make_inventory_table()
end

parse.i[0x00E] = function (data)
    if pet.index and pet.index == data:unpack('H',9) and math.floor((data:byte(11)%8)/4)== 1 then
        local status_id = data:byte(32)
        -- Filter all statuses aside from Idle/Engaged/Dead/Engaged dead.
        if pet.status_id ~= status_id and (status_id < 4 or status_id == 33 or status_id == 47) then
            if not next_packet_events then next_packet_events = {sequence_id = data:unpack('H',3)} end
            next_packet_events.pet_status_change = {newstatus=res.statuses[status_id][language],oldstatus=pet.status}
            pet.status = res.statuses[status_id][language]
            pet.status_id = status_id
        end
    end
end

parse.i[0x01B] = function (data)
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
    if table.length(tab) > 0 and not gearswap_disabled then
        refresh_globals()
        equip_sets('equip_command',nil,tab)
    end
end

parse.i[0x01E] = function (data)
    local bag = to_windower_compact(res.bags[data:byte(0x09)].english)
    local slot = data:byte(0x0A)
    local count = data:unpack('I',5)
    local status = data:byte(0x0B)
    if not items[bag][slot] then items[bag][slot] = make_empty_item_table(slot) end
    items[bag][slot].count = count
    items[bag][slot].status = status
    if count == 0 then
        items[bag][slot].id = 0
        items[bag][slot].bazaar = 0
        items[bag][slot].status = 0
    end
end

parse.i[0x01F] = function (data)
    local bag = to_windower_compact(res.bags[data:byte(0x0B)].english)
    local slot = data:byte(0x0C)
    if not items[bag][slot] then items[bag][slot] = make_empty_item_table(slot) end
    items[bag][slot].id = data:unpack('H',9)
    items[bag][slot].count = data:unpack('I',5)
    items[bag][slot].status = data:byte(0x0D)
end

parse.i[0x020] = function (data)
        local bag = to_windower_compact(res.bags[data:byte(0x0F)].english)
        local slot = data:byte(0x10)
        if not items[bag][slot] then items[bag][slot] = make_empty_item_table(slot) end
        items[bag][slot].id = data:unpack('H',0x0D)
        items[bag][slot].count = data:unpack('I',5)
        items[bag][slot].bazaar = data:unpack('I',9)
        items[bag][slot].status = data:byte(0x11)
        items[bag][slot].extdata = data:sub(0x12,0x29)
        -- Did not mess with linkshell stuff
end

parse.i[0x037] = function (data)
    player.status_id = data:byte(0x31)
    --[[local bitmask = data:sub(0x4D,0x54)
    for i = 1,32 do
        local bitmask_position = 2*((i-1)%4)
        local id = data:byte(4+i) + 256*math.floor(bitmask:byte(1+math.floor((i-1)/4))%(2^(bitmask_position+2))/(2^bitmask_position))
        if player.buffs[i] ~= id then
            if id == 255 and player.buffs[i] then
                player.buffs[i] = nil
            elseif id ~= 255 then
                player.buffs[i] = id
            end
        end
    end]]
    
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
        if not gearswap_disabled then
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
        end
    elseif _ExtraData.player.indi then
        -- An indi effect has been lost.
        local temp_indi = _ExtraData.player.indi
        _ExtraData.player.indi = nil
        if not gearswap_disabled then
            refresh_globals()
            equip_sets('indi_change',nil,temp_indi,false)
        end
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
end

function parse_equip_chunk(chunk)
    local inv_slot = chunk:byte(1) -- 0 indicates unequipping the item
    local equip_slot = toslotname(chunk:byte(2))
    if inv_slot == 0 then -- Unequipping
        local bag_id = items.equipment[equip_slot].bag_id
        inv_slot = items.equipment[equip_slot].slot
        
        if inv_slot == empty then return end -- unequipping something that was already unequipped?
        
        local inv = items[to_windower_compact(res.bags[bag_id].english)]
        if not inv[inv_slot] then inv[inv_slot] = make_empty_item_table(inv_slot) end
        
        inv[inv_slot].status = 0 -- Set the status to "unequipped"
        items.equipment[equip_slot] = {slot=empty,bag_id=0}
    else
        local bag_id = chunk:byte(3)
        local inv = items[to_windower_compact(res.bags[bag_id].english)]
        items.equipment[equip_slot] = {slot=inv_slot,bag_id = bag_id}
        if not inv[inv_slot] then inv[inv_slot] = make_empty_item_table(inv_slot) end
        inv[inv_slot].status = 5 -- Set the status to "equipped"
    end
end

parse.o[0x050] = function (data,injected) --equip
    if injected then return end
    -- Because of the way windower works, uninjected chunks will appear after
    -- injected chunks in the chunk events but will hit the server before them.
    -- Thus, I use insert here instead of append
    injected_equipment_registry[data:byte(6)]:insert(1,data:sub(5,7))
end

parse.o[0x051] = function (data,injected) --equipset
    if injected then return end
    for i=9,9+4*(data:byte(5)-1),4 do
        injected_equipment_registry[data:byte(i+1)]:insert(1,data:sub(i,i+2))
    end
end

parse.i[0x050] = function (data)
    -- should simplify this code using return when I gain confidence in it
    parse_equip_chunk(data:sub(5,7))
    local slot = data:byte(6)
    for chunk,ind in injected_equipment_registry[slot]:it() do
        if chunk == data:sub(5,7) then
            -- Matched
            injected_equipment_registry[slot] = injected_equipment_registry[slot]:slice(ind+1) -- Eliminate current and all preceding packets if we get a match
            matched = true
            return
        end
        --[[for i=9,9+4*(chunk:byte(5)-1),4 do -- The server replies to equipset packets with both single equip packets and equipset packets.
            if chunk:sub(i,i+2) == data:sub(5,7) then
                matched = true
                break
            end
        end]]
    end
    -- Unexpected packet found!
end

function update_equipment()
    local tab = {}
    for i,v in pairs(items.equipment) do
        tab[i] = {bag_id = v.bag_id,slot=v.slot}
    end
    for i,v in pairs(injected_equipment_registry) do
        local last = v:last()
        if last then
            tab[default_slot_map[i]] = {
                bag_id = last:byte(3),
                slot = last:byte(1) == 0 and empty or last:byte(1),
                }
        end
    end
    return tab
end

-- The server always sends both equip responses and equipset responses following an equipset command
-- Equip responses are sent for pieces the successfully equip
-- The equipset response contains a copy of the original equipset and a new list of all your currently worn gear
-- It always comes after the equip commands, so one way to address this is to simply read the new list of currently worn gear
-- and act as if it's all unexpected.
parse.i[0x117] = function (data)
    -- should simplify this code using return when I gain confidence in it
    for i=9,9+4*(data:byte(5)-1),4 do -- Byte position for the start of the current chunk
        local slot = data:byte(i+1)
        for chunk,ind in injected_equipment_registry[slot]:it() do
            if chunk == data:sub(i,i+2) then
                -- This is the response to an injected equipset packet, so remove those packets from the registry even if it actually failed to swap.
                injected_equipment_registry[slot] = injected_equipment_registry[slot]:slice(ind+1)
            end
        end
    end
    for i=0x49,0x85,4 do
        -- Update items.equipment
        parse_equip_chunk(data:sub(i,i+2))
    end
end

parse.i[0x053] = function (data)
    local message = data:unpack('H',0xD)
    if (message == 0x12D or message == 0x12A or message == 0x12B or message == 0x12C) and player then
        -- You're unable to use trust magic if you're not the party leader, solo, pt full or trying to summon an already summoned trust
        local ts,tab = command_registry:find_by_time()
        if tab and tab.spell and tab.spell.prefix ~= '/pet' and not gearswap_disabled then
            tab.spell.action_type = 'Interruption'
            tab.spell.interrupted = true
            equip_sets('aftercast',nil,tab.spell)
        end
    end
end

parse.i[0x05E] = function (data)
    -- Conquest ID
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
end

parse.i[0x061] = function (data)
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
        if not gearswap_disabled then
            refresh_globals()
            equip_sets('sub_job_change',nil,player.sub_job,temp_sub)
        end
    end
    update_job_names()
end

parse.i[0x062] = function (data)
    for i = 1,0x71,2 do
        local skill = data:unpack('H',i + 0x82)%32768
        local current_skill = res.skills[math.floor(i/2)+1]
        if current_skill then
            player.skills[to_windower_api(current_skill.english)] = skill
        end
    end
end

parse.i[0x063] = function (data)
    if data:byte(0x05) == 0x09 and blank_0x063_v9_inc then
        -- After zoning, players receive a blank 0x063 v9 packet
        -- (because their buff line is temporarily empty)
        -- So this flag is set in 0x00A 
        blank_0x063_v9_inc = false
        -- However, players can also reload gearswap and fail to get a 0x063 v9 packet from
        -- windower.packets.last_incoming, which leaves them without buff information but with a
        -- informative 0x063 v9 packet coming next. So this step checks confirms the packet is
        -- empty before returning
        if data:sub(0x49,0xC8) == string.char(0):rep(128) then
            return
        end
    end
    if data:byte(0x05) == 0x09 then
        local newbuffs = {}
        for i=1,32 do
            local buff_id = data:unpack('H',i*2+7)
            if buff_id ~= 255 and buff_id ~= 0 then -- 255 is used for "no buff"
                local t = data:unpack('I',i*4+0x45)/60+572662306+1009810800
                newbuffs[i] = setmetatable({
                    name=res.buffs[buff_id].name,
                    buff=copy_entry(res.buffs[buff_id]),
                    id = buff_id,
                    time=t,
                    date=os.date('*t',t),
                    },
                    {__index=function(t,k)
                        if k and k=='duration' then
                            return rawget(t,'time')-os.time()
                        else
                            return rawget(t,k)
                        end
                    end})
            end
        end
        if seen_0x063_type9 then
        
            -- Look for exact matches
            for n,new in pairs(newbuffs) do
                newbuffs[n].matched_exactly = nil
                for i,old in pairs(_ExtraData.player.buff_details) do
                    -- Find unchanged buffs
                    if old.id == new.id and math.abs(old.time-new.time) < 1 and not old.matched_exactly then
                        newbuffs[n].matched_exactly = true
                        _ExtraData.player.buff_details[i].matched_exactly = true
                        break
                    end
                end
            end
            
            -- Look for time-independent matches, which are assumedly a spell overwriting itself
            for n,new in pairs(newbuffs) do
                newbuffs[n].matched_imprecisely = nil
                if not new.matched_exactly then
                    for i,old in pairs(_ExtraData.player.buff_details) do
                        -- Buffs can be overwritten
                        if old.id == new.id and not (old.matched_exactly or old.matched_imprecisely) then
                            newbuffs[n].matched_imprecisely = true
                            _ExtraData.player.buff_details[i].matched_imprecisely = true
                            break
                        end
                    end
                end
            end
            
            for n,new in pairs(newbuffs) do
                if new.matched_exactly then
                    newbuffs[n].matched_exactly = nil
                elseif new.matched_imprecisely then
                    newbuffs[n].matched_imprecisely = nil
                    -- Matched a previous buff, but the time didn't jive so it's assumed
                    -- that it was overwritten with the same status effect
                    if not res.buffs[new.id] then
                        error('GearSwap: No known status for buff id #'..tostring(new.id))
                    end
                    local buff_name = res.buffs[new.id][language]
                    windower.debug('refresh buff '..buff_name..' ('..tostring(new.id)..')')
                    if not gearswap_disabled then
                        refresh_globals()
                        equip_sets('buff_refresh',nil,buff_name,new)
                    end
                else
                    -- Not matched, so it's assumed the buff is new
                    if not res.buffs[new.id] then
                        error('GearSwap: No known status for buff id #'..tostring(new.id))
                    end
                    local buff_name = res.buffs[new.id][language]
                    windower.debug('gain buff '..buff_name..' ('..tostring(new.id)..')')
                    -- Need to figure out what I'm going to do with this:
                    if T{'terror','sleep','stun','petrification','charm','weakness'}:contains(buff_name:lower()) then
                        for ts,v in pairs(command_registry) do
                            if v.midaction then
                                command_registry:delete_entry(ts)
                            end
                        end
                    end
                    if not gearswap_disabled then
                        refresh_globals()
                        equip_sets('buff_change',nil,buff_name,true,new)
                    end
                end
            end
            for i,old in pairs(_ExtraData.player.buff_details) do
                if not (old.matched_exactly or old.matched_imprecisely) then
                    -- Old status was not matched to any new status, so it's assumed it was lost
                    if not res.buffs[old.id] then
                        error('GearSwap: No known status for buff id #'..tostring(old.id))
                    end
                    local buff_name = res.buffs[old.id][language]
                    windower.debug('lose buff '..buff_name..' ('..tostring(old.id)..')')
                    if not gearswap_disabled then
                        refresh_globals()
                        equip_sets('buff_change',nil,buff_name,false,old)
                    end
                end
            end
        end
        
        table.reassign(_ExtraData.player.buff_details,newbuffs)
        for i=1,32 do
            player.buffs[i] = (newbuffs[i] and newbuffs[i].id) or nil
        end
        -- Cannot reliably recall this packet using last_incoming on load because there
        -- are 9 version of it and you only get the last one. Hence, this flag:
        seen_0x063_type9 = true
    end
end

parse.i[0x067] = function (data)
    if player.index == data:unpack('H',0x0D) then -- You are the owner
        _ExtraData.pet.tp = data:unpack('H',0x11)
    end
end

parse.i[0x068] = function (data)
    
    if player.index == data:unpack('H',0x07) then -- You are the owner
        _ExtraData.pet.tp = data:unpack('H',0x11)
    end
end

parse.i[0x076] = function (data)
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
                if cur_player and cur_player.buffactive and not gearswap_disabled then
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
end

parse.i[0x0DF] = function (data)
    if data:unpack('I',5) == player.id then
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
    end
end

parse.i[0x0E2] = function (data)
    if data:unpack('I',5)==player.id then
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
    end
end

parse.o[0x100] = function(data)
    -- Scrub the equipment array if a valid outgoing job change packet is sent.
    local newmain = data:byte(5)
    if res.jobs[newmain] and newmain ~= 0 and newmain ~= player.main_job_id then
        windower.debug('job change')
        
        command_registry = Command_Registry.new()
        
        table.clear(not_sent_out_equip)
        table.clear(equip_list_history)
        table.clear(equip_list)
        player.main_job_id = newmain
        update_job_names()
        for i=0,15 do
            injected_equipment_registry[i]:clear()
            items.equipment[default_slot_map[i]] = {bag_id=0,slot=empty}
        end
        windower.send_command('lua i '.._addon.name..' load_user_files '..newmain)
    end
    
    
    if gearswap_disabled then return end
    
    local newmain = data:byte(5)
    if res.jobs[newmain] and newmain ~= player.main_job_id then
        command_enable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet') -- enable all slots
    end
end

function initialize_packet_parsing()
    for i,v in pairs(parse.i) do
        local lastpacket = windower.packets.last_incoming(i)
        if lastpacket then
            v(lastpacket)
        end
        if i == 0x63 and lastpacket and lastpacket:byte(5) ~= 9 then
            -- Not receiving an accurate buff line on load because the wrong 0x063 packet was sent last
            
        end
    end
end
