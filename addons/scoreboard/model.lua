require 'tablehelper'


local DamageDB = {
    dps_db = T{}
}


function DamageDB:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    
    return o
end

function DamageDB:isempty()
    return self.dps_db:isempty()
end

function DamageDB:init()
    self.dps_db = T{}
end


-- Adds the given data to the main DPS table
function DamageDB:accumulate(mob, player, damage)
    if not self.dps_db[mob] then
        self.dps_db[mob] = T{}
    end
	
    damage = tonumber(damage)
    if not self.dps_db[mob][player] then
        self.dps_db[mob][player] = damage
    else
        self.dps_db[mob][player] = damage + self.dps_db[mob][player] 
    end
end

return DamageDB

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
