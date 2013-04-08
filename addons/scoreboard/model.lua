dps_db = T{}

-- DPS clock variables
dps_active = false
dps_clock = 1 -- avoid div/0
dps_clock_prev_time = 0

function model_init()
    dps_db = T{}

    dps_active = false
    dps_clock = 1
    dps_clock_prev_timestamp = 0
end

function update_dps_clock()
    if get_player()['in_combat'] then
        local now = os.time()

        if dps_clock_prev_time == 0 then
            dps_clock_prev_time = now
        end

        dps_clock = dps_clock + (now - dps_clock_prev_time)
        dps_clock_prev_time = now

        dps_active = true
    else
        dps_active = false
        dps_clock_prev_time = 0
    end
end


-- Adds the given data to the main DPS table
function accumulate(mob, player, damage)
    mob = string.lower(mob:gsub('^[tT]he ', ''))
    if not dps_db[mob] then
        dps_db[mob] = T{}
    end
	
    damage = tonumber(damage)
    if not dps_db[mob][player] then
        dps_db[mob][player] = damage
    else
        dps_db[mob][player] = damage + dps_db[mob][player] 
    end
end


--[[
Copyright (c) 2013, Jerry Hebert
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Scoreboard nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL JERRY HEBERT BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
