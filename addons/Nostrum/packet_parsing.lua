parse_lookup = {
	incoming = {},
	outgoing = {},
}

parse_lookup.incoming[0x063] = function(data)
	if data:byte(5) == 9 then
		if buff_gain then
			buff_gain = false
			
			local new = L{}
			local old = pc.buffs
			
			for i=1,32 do
				local buff_id = last_buff_update:unpack('H', i*2+7)
				
				if buff_id == 255  then
					break
				else
					new:append(buff_id)
				end
			end
			
			local old_set = S(old)
			
			for i = 1, new.n do
				local buff = new[i]
				
				if not old_set:contains(buff) then
					call_events('buff change', 1, buff, true, i)
				end
			end
		elseif buff_loss then
			buff_loss = false
			
			local new = L{}
			local old = pc.buffs
			
			for i=1,32 do
				local buff_id = last_buff_update:unpack('H', i*2+7)
				
				if buff_id == 255  then
					break
				else
					new:append(buff_id)
				end
			end
			
			local new_set = S(new)
			
			for i = 1, old.n do
				local buff = old[i]
				
				if not new_set:contains(buff) then
					call_events('buff change', 1, buff, false, i)
				end
			end		
		end		
		--last_buff_update = data
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
		if bit.is_set(mask, 1) then					--mask
			local x, z, y = data:unpack('fff',0x0D) --0b000001 position updated
			local pos = player.pos					--0b000100 hp updated
													--0b011111 model appear i.e. update all
			pos.x = x                      			--0b100000 model disappear
			pos.y = y                      			
			
			if player.out_of_sight then
				player.out_of_sight = false
				call_events('member appear', player.party, player.spot)
			end
			
			call_events('distance change', player.party, player.spot, (pc.pos.x - pos.x)^2 + (pc.pos.y - pos.y)^2)
		elseif bit.is_set(mask, 6) then
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

		player.name = packet['Name']
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
				player.out_of_sight = mob.distance >= 50
				-- Catch-all: I'm pretty sure the mob table doesn't exist if distance is > 50.
			end
		end
		
		local party = player.party
		local pos = alliance[party]:invite(id)
		
		player.spot = pos
		call_events('member join', party, pos, sandbox.alliance[party][pos])
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
			local player = alliance_lookup[id]
			local old_buffs = player.buffs
			local new_buffs = L{}
			local buff
			
			for j = 1,32 do
				buff = data:byte(i*48+5+16+j-1) + 256*( math.floor( data:byte(i*48+5+8+ math.floor((j-1)/4)) / 4^((j-1)%4) )%4) -- Credit: Byrth, GearSwap
				
				if buff == 255 then
					break
				else
					new_buffs:append(buff)
				end
			end
			
			local old_buffs_set = S(old_buffs)
			local new_buffs_set = S(new_buffs)

			player.buffs = new_buffs
			
			for j = 1, old_buffs.n do
				local buff_id = old_buffs[j]
				
				if not new_buffs_set:contains(buff_id) then
					call_events('buff change', i+2, buff_id, false, j)
				end
			end
			
			for j = 1, new_buffs.n do
				local buff_id = new_buffs[j]
				
				if not old_buffs_set:contains(buff_id) then
					call_events('buff change', i+2, buff_id, true, j)
				end
			end
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

    for i=1,3 do
		local is_party_empty = p[i]:empty()
		local party = alliance[i]
		local to_kick = p[i] - packet_pt_struc[i]
        local to_invite = packet_pt_struc[i] - p[i]

		if is_party_empty and not to_invite:empty() then
			call_events('new party', i)
		end

		
		for id in to_kick:it() do
			local n_pos = party:kick(id)
			
			for j = n_pos, party:count() do
				local player = alliance_lookup[party[j]]
				
				player.spot = player.spot - 1
			end
			
			alliance_lookup[id] = nil
			call_events('member leave', i, n_pos)
		end
		
        for id in to_invite:it() do
            local player = players.new()

			player.party = i
			player.is_trust = trust_flag
			alliance_lookup[id] = player
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
	local pos = pc.pos
	
	if pos.x ~= packet.X or pos.y ~= packet.Y then
		pos.x, pos.y = packet.X, packet.Y

		local party = alliance[1]
		
		for i = 2, party:count() do
			local player = alliance_lookup[party[i]]
			
			if not (player.out_of_zone or player.out_of_sight) then
				local member_pos = player.pos
				
				call_events(
					'distance change', 
					player.party, 
					player.spot, 
					(pos.x - member_pos.x)^2 + (pos.y - member_pos.y)^2
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
						(pos.x - member_pos.x)^2 + (pos.y - member_pos.y)^2
					)				
				end
			end
		end
	end
end

parse_lookup.outgoing[0x00D] = function(data)
	nostrum.state.hidden = true
	low_level_visibility(false)
	call_events('zoning')
end
