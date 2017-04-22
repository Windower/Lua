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
ON ANY THEORY OF LIABILITY, WHETHER I N CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

-- Parameters: <party number> <number of players to invite>
return function(pt_n, count)
	pt_n = tonumber(pt_n) or 'all'
	count = tonumber(count)
	count = count and count > 0 and count < 7 and count or 6
	
	local offset = math.random(1, 40000)
	
	local names = {
		Bahamut = true,
		Tiamat = true,
		Fenrir = true,
		Opoopo = true,
		Cardian = true,
		Crawler = true,
		Throatstab = true,
		Balance = true,
		Matsui = true,
		Leviathan = true,
		Onethousandneedles = true,
		Nidhogg = true,
		Adamantoise = true,
		Aspid = true,
		Behemoth = true,
		Valkurm = true,
		Sandoria = true,
		Windurst = true,
		Bastok = true,
		Spinyspipi = true,
	}
	
	local function spoof_player(party, position)
		local player = players.new()
		
		player.hp = math.random(1, 3000)
		player.mp = math.random(1, 3000)
		player.tp = math.random(1, 3000)
		player.hpp = math.random(1, 100)
		player.mpp = math.random(1, 100)
		player.spot = position
		player.name = next(names)
		player.id = offset + ('0x' .. string.hex(player.name)):sub(1, 10):number()

		while alliance_lookup[player.id] do -- it could happen
			player.id = player.id + 1
		end
		
		player.zone = 0
		player.index = 0
		player.party = party
		player.is_trust = false
		player.out_of_zone = false
		player.out_of_sight = false
		player.seeking_information = false
		player.debug = true

		names[player.name] = nil
		alliance[party]:invite(player.id)
		alliance_lookup[player.id] = player

		return player
	end

	if pt_n == 'all' then
		for i = 1, 3 do
			if alliance[i]:count() == 0 then
				dbg['new party'](i)
			end
		end

		for i = 1, count do
			for j = 1, 3 do
				local player = alliance[j][i]
				
				if not player then
					player = spoof_player(j, i)
					
					dbg['member join'](j, i, player)
					
					coroutine.sleep(0.3)
				end
			end
		end
	else
		if alliance[pt_n]:count() == 0 then
			dbg['new party'](pt_n)
		end

		for i = 1, count do
			local player = alliance[pt_n][i]
			
			if not player then
				player = spoof_player(pt_n, i)
		
				dbg['member join'](pt_n, i, player)
				
				coroutine.sleep(0.3)
			end
		end
	end
end, [[This test will invite dummy players.]]
