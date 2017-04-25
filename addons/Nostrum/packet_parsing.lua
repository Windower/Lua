--[[Copyright © 2014-2017, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Nostrum nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL trv BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

parse_lookup = {
    incoming = {},
    outgoing = {},
}

parse_lookup.incoming[0x063] = function(data)
    if data:byte(5) == 9 then
        if ignore_0x063 then
            ignore_0x063 = false
            return
        end
            
        local new = L{}
        local old = pc.buffs.array
        local changes = {}

        pc.buffs.array = new
        buff_lookup[1].array = new
        
        for i = 1, 32 do
            local buff_id = data:unpack('H', 7 + i * 2)
            
            if buff_id == 255  then
                break
            else
                new:append(buff_id)
                
                if old[i] ~= buff_id then
                    changes[i] = buff_id
                end
            end
        end
        
        local old_set = pc.buffs.active
        local new_set = {}
        
        local buff_resources = res.buffs
        local buff_strings = {}
        
        for i = 1, new.n do
            local buff = new[i]
            
            local res_string = buff_resources[buff][_addon.language]:lower()
            
            buff_strings[buff] = res_string
            
            new_set[buff] = true
            new_set[res_string] = true
        end
        
        buff_lookup[1].active = new_set
        pc.buffs.active = new_set
        
        for i = 1, old.n do
            local buff = old[i]
            
            if not new_set[buff] then
                call_events('buff loss', 1, i, buff, buff_strings[buff])
            end
        end        

        for i = 1, new.n do
            local buff = new[i]
            
            if not old_set[buff] then
                call_events('buff gain', 1, i, buff, buff_strings[buff])
            end
        end
        
        call_events('buff change', 1, old.n, new.n, changes)
    end
end

parse_lookup.incoming[0x00D] = function(data)
    local mask = data:unpack('C', 0x0B)
    
    if data:unpack('H', 9) == target.index and bit.is_set(mask, 3) then
        local new_hpp = data:unpack('C', 0x1F)
        local old_hpp = target.hpp
        
        if new_hpp ~= old_hpp then
            target.hpp = new_hpp
            call_events('target hpp change', new_hpp, old_hpp)
        end
    end
    
    local player = alliance_lookup[data:unpack('I', 5)]
    
    if player and player.id ~= pc.id then
        if bit.is_set(mask, 1) then                    --mask
            local x, z, y = data:unpack('fff',0x0D) --0b000001 position updated
                                                    --0b000100 hp updated
            player.x = x                            --0b011111 model appear i.e. update all
            player.y = y                              --0b100000 model disappear
            
            if player.out_of_sight then
                player.out_of_sight = false
                call_events('member appear', player.party, player.spot)
            end
            
            call_events('distance change', player.party, player.spot, (pc.x - player.x)^2 + (pc.y - player.y)^2)
        elseif bit.is_set(mask, 6) then
            player.out_of_sight = true
            call_events('member disappear', player.party, player.spot)
        end
    end
end

parse_lookup.incoming[0x00E] = parse_lookup.incoming[0x00D]

parse_lookup.incoming[0x0DF] = function(data)
    local packet = packets.parse('incoming', data)
    local id = packet['ID']
    local player = alliance_lookup[id]
    
    if not player then return end

    if player.hp ~= packet['HP'] then
        local old = player.hp
        local new = packet.HP
        
        player.hp = new
        call_events('hp change', player.party, player.spot, new, old)
    end
    
    if player.mp ~= packet['MP'] then
        local old = player.mp
        local new = packet.MP

        player.mp = new
        call_events('mp change', player.party, player.spot, new, old)
    end
    
    if player.tp ~= packet['TP'] then
        local old = player.tp
        local new = packet.TP

        player.tp = new
        call_events('tp change', player.party, player.spot, new, old)
    end
    
    if player.hpp ~= packet['HPP'] then
        local old = player.hpp
        local new = packet.HPP

        player.hpp = new
        call_events('hpp change', player.party, player.spot, new, old)
    end
    
    if player.mpp ~= packet['MPP'] then
        local old = player.mpp
        local new = packet.MPP

        player.mpp = new
        call_events('mpp change', player.party, player.spot, new, old)
    end
end

parse_lookup.incoming[0x0DD] = function(data)
    local packet = packets.parse('incoming', data)
    local id = packet['ID']
    local player = alliance_lookup[id]
    
    if not player then return end
    
    if player.seeking_information then
        player.seeking_information = false

        local zone = packet.Zone

        player.name = packet.Name
        player.zone = zone

        if zone == 0 then
            player.hp = packet.HP
            player.mp = packet.MP
            player.tp = packet.TP
            player.index = packet.Index
            player.hpp = packet['HP%']
            player.mpp = packet['MP%']
            player.out_of_zone = false
            
            local mob = windower.ffxi.get_mob_by_index(player.index)
            
            if mob then
                player.out_of_sight = mob.distance >= 50 -- Catch-all: I'm pretty sure the mob table doesn't exist if distance is > 50.
                player.x = mob.x
                player.y = mob.y
            end
        end
        
        local party = player.party
        local pos = alliance[party]:invite(id)
        
        player.spot = pos
        call_events('member join', party, pos, sandbox_lookup[id])
    elseif packet.Zone ~= player.zone then
        local old = player.zone
        local new = packet.Zone
        player.zone = new

        if new == 0 then
            local old, new;
            local party, spot = player.party, player.spot
            
            player.index = packet.Index
            player.out_of_zone = false

            old = player.hp
            new = packet.HP
            player.hp = new
            
            if old ~= new then
                call_events('hp change', party, spot, new, old)
            end
            
            old = player.mp
            new = packet.MP
            player.mp = new
            
            if old ~= new then
                call_events('mp change', party, spot, new, old)
            end

            old = player.tp
            new = packet.TP
            player.tp = new
            
            if old ~= new then
                call_events('tp change', party, spot, new, old)
            end

            old = player.hpp
            new = packet['HP%']
            player.hpp = new
            
            if old ~= new then
                call_events('hpp change', party, spot, new, old)
            end

            old = player.mpp
            new = packet['MP%']
            player.mpp = new
            
            if old ~= new then
                call_events('mpp change', party, spot, new, old)
            end
        elseif old == 0 then
            player.out_of_zone = true
            player.out_of_sight = true
        end
        
        call_events('member zone', player.party, player.spot, new, old)
    end
end

parse_lookup.incoming[0x076] = function(data)
    for i = 0, 4 do
        local id = data:unpack('I', i*48+5)
        
        if id == 0 then
            break
        elseif alliance_lookup[id] then
            local lookup = buff_lookup[i + 2]
            local old_buffs = lookup.array
            local new_buffs = L{}
            local changes = {}
            local buff
            
            for j = 1,32 do
                buff = data:byte(i*48+5+16+j-1) + 256*( math.floor( data:byte(i*48+5+8+ math.floor((j-1)/4)) / 4^((j-1)%4) )%4) -- Credit: Byrth, GearSwap
                
                if buff == 255 then
                    break
                else
                    new_buffs:append(buff)
                    
                    if old_buffs[j] ~= buff then
                        changes[j] = buff
                    end
                end
            end
            
            local old_buffs_set = lookup.active
            local new_buffs_set = {}


            lookup.array = new_buffs
            lookup.active = new_buffs_set
            
            local buff_strings = {}
            local buff_resources = res.buffs
            
            for j = 1, new_buffs.n do
                local buff_id = new_buffs[j]
                local res_string = buff_resources[buff_id][_addon.language]:lower()
                
                buff_strings[buff_id] = res_string
                
                new_buffs_set[buff_id] = true
                new_buffs_set[res_string] = true
            end
            
            for j = 1, new_buffs.n do
                local buff_id = new_buffs[j]
                
                if not old_buffs_set[buff_id] then
                    call_events('buff gain', i+2, j, buff_id, buff_strings[buff_id])
                end
            end

            for j = 1, old_buffs.n do
                local buff_id = old_buffs[j]
                
                if not new_buffs_set[buff_id] then
                    call_events('buff loss', i+2, j, buff_id, buff_strings[buff_id])
                end
            end

            call_events('buff change', i, old_buffs.n, new_buffs.n, changes)
        end
    end
end

parse_lookup.incoming[0x0C8] = function(data)
    local packet_pt_struc = {S{}, S{}, S{}}
    local trust_flag = false

    for i = 1, 3 do
        for j = 1, 6 do
            local offset = 9 + 12*(6*(i-1) + (j-1))

            local id = data:unpack('I', offset)
            if id == 0 then break end
            
            local flags = data:unpack('H', offset + 6)
            local party = bit.band(flags, 3)
            
            trust_flag = trust_flag or party == 0
            packet_pt_struc[trust_flag and 1 or party]:add(id)
        end
    end

    if packet_pt_struc[3]:contains(pc.id) then
        packet_pt_struc[1], packet_pt_struc[3] = packet_pt_struc[3], packet_pt_struc[1]
    elseif packet_pt_struc[2]:contains(pc.id) then
        packet_pt_struc[1], packet_pt_struc[2] = packet_pt_struc[2], packet_pt_struc[1]
    end
    
    if packet_pt_struc[2]:length() == 0 then
        packet_pt_struc[2], packet_pt_struc[3] = packet_pt_struc[3], packet_pt_struc[2]
    end

    local p = {S(alliance[1]), S(alliance[2]), S(alliance[3])}

    for i = 1, 3 do
        local is_party_empty = p[i]:empty()
        local party = alliance[i]
        local to_kick = p[i] - packet_pt_struc[i]
        local to_invite = packet_pt_struc[i] - p[i]

        if is_party_empty and not to_invite:empty() then
            call_events('new party', i)
        end

        
        for id in to_kick:it() do
            local n_pos = party:kick(id)
            
            if i == 1 then
                table.remove(buff_lookup, n_pos)
                buff_lookup[6] = {array = L{}, active = {}}
            end
            
            for j = n_pos, party:count() do
                local player = alliance_lookup[party[j]]
                
                player.spot = player.spot - 1
            end
            
            forget(id)
            
            call_events('member leave', i, n_pos)
        end
        
        for id in to_invite:it() do
            local player = players.new()

            player.party = i
            player.is_trust = trust_flag;
            
            --[[
                The 0x0DF packet can arrive before finish_trust_invitation runs.
                If a trust id is added to alliance_lookup, an hp change event will
                run with spot = 0, causing an error.
                Stash the player table temporarily, then add it to alliance_lookup
                in finish_trust_invitation.
            --]]
            (trust_flag and trust_lookup or alliance_lookup)[id] = player
        end

        if party:count() == 0 and not is_party_empty then
            call_events('disband party', i)
        end        
    end

    -- The server does not send an 0x0DD packet in the case
    -- where a solo player summons a trust.
    if trust_flag then
        coroutine.schedule(finish_trust_invitation, 0.3)
    end
end

parse_lookup.outgoing[0x015] = function(data)
    --[[
        If the player is targeted, no target hpp event will be called
        from 0x00D or 0x00E.
        Checks here are relatively infrequent.
        Could be moved to 0x0DF at the cost of an extra check.
    ]]--
    if target.index ~= 0 then
        local mob = windower.ffxi.get_mob_by_index(target.index)
        local hpp = mob.hpp
        
        if hpp ~= target.hpp then
            target.hpp = hpp
            call_events('target hpp change', hpp)
        end
    end
    
    local packet = packets.parse('outgoing', data)
    local pc = pc
    
    if pc.x ~= packet.X or pc.y ~= packet.Y then
        pc.x, pc.y = packet.X, packet.Y
        
        local self = alliance_lookup[pc.id]
        
        self.x, self.y = packet.X, packet.Y
        
        local party = alliance[1]
        
        for i = 2, party:count() do
            local player = alliance_lookup[party[i]]
            
            if not (player.out_of_zone or player.out_of_sight) then                
                call_events(
                    'distance change', 
                    player.party, 
                    player.spot, 
                    (pc.x - player.x)^2 + (pc.y - player.y)^2
                )
            end
        end
        
        for i = 2, 3 do
            local party = alliance[i]
            
            for j = 1, party:count() do
                local player = alliance_lookup[party[j]]

                if not (player.out_of_zone or player.out_of_sight) then
                    local member_pos = player.pos

                    call_events(
                        'distance change', 
                        player.party, 
                        player.spot, 
                        (pc.x - player.x)^2 + (pc.y - player.y)^2
                    )                
                end
            end
        end
    end
end

parse_lookup.outgoing[0x00D] = function(data)
    nostrum.state.running = false
    low_level_visibility(false)
    ignore_0x063 = true
    call_events('zoning')
end
