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

-- Parameters: <party number> <party spot>
-- No arguments: Kick debug players from party 2 -> 1 -> 3 (that's the most interesting order).

local function kick_all_of_party(n)
    local j = 1
    local count = alliance[n]:count()

    while j <= count do
        for i = 1, alliance[n]:count() do
            local player = alliance_lookup[alliance[n][i]]

            if player.debug then
                forget(player.id)
                alliance[n]:kick_pos(i)
                
                if n == 1 then
                    table.remove(buff_lookup, i)
                    buff_lookup[6] = {array = L{}, active = L{}}
                end
                
                dbg['member leave'](n, i)

                break
            end        
        end
        
        coroutine.sleep(0.3)
        j = j + 1
    end

    if alliance[n]:count() == 0 then
        dbg['disband party'](n)
    end
end

return function(pt_n, spot)
    pt_n = tonumber(pt_n)
    
    if not pt_n then
        kick_all_of_party(2)
        kick_all_of_party(1)
        kick_all_of_party(3)
    elseif not spot then
        kick_all_of_party(pt_n)
    else
        spot = tonumber(spot)
        
        if not spot then print('Expected a number, got ' .. tostring(spot)) return end
        
        local party = alliance[pt_n]
        local id = party[spot]
        
        if not id then print('Could not kick %d %d. There is no player':format(pt_n, spot)) return end
        
        if alliance_lookup[id].debug then
            forget(id)
            party:kick_pos(spot)
                
            if pt_n == 1 then
                table.remove(buff_lookup, spot)
                buff_lookup[6] = {array = L{}, active = L{}}
            end
            
            dbg['member leave'](pt_n, spot)
        end

        if alliance[pt_n]:count() == 0 then
            dbg['disband party'](pt_n)
        end
    end
end, [[This test will kick dummy players.]]
