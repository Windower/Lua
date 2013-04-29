local Player = require 'player'

local DamageDB = {
    db = T{}
}

DamageDB.player_stat_fields = T{
    'acc', 'racc', 'crit', 'rcrit',
    'mmin', 'mmax', 'mavg',
    'rmin', 'rmax', 'ravg',
    'wsmin', 'wsmax', 'wsavg'
}


function DamageDB:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    
    return o
end


-- Returns the corresponding Player instance. Will create it if necessary.
function DamageDB:_get_player(mob, player_name)
    if not self.db[mob] then
        self.db[mob] = T{}
    end
    
    if not self.db[mob][player_name] then
        self.db[mob][player_name] = Player:new{name = player_name}
    end
    
    return self.db[mob][player_name]
end


function DamageDB:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    
    return o
end

function DamageDB:isempty()
    return self.db:isempty()
end


function DamageDB:reset()
    self.db = T{}
end


function DamageDB:_incr_field(mob, player_name, field)
    local player = self:_get_player(mob, player_name)
    player[field] = player[field] + 1
end


function DamageDB:incr_hits(mob, player)     self:_incr_field(mob, player, 'm_hits') end
function DamageDB:incr_misses(mob, player)   self:_incr_field(mob, player, 'm_misses') end
function DamageDB:incr_crits(mob, player)    self:_incr_field(mob, player, 'm_crits') end
function DamageDB:incr_r_hits(mob, player)   self:_incr_field(mob, player, 'r_hits') end
function DamageDB:incr_r_misses(mob, player) self:_incr_field(mob, player, 'r_misses') end
function DamageDB:incr_r_crits(mob, player)  self:_incr_field(mob, player, 'r_crits') end


function DamageDB:add_damage(mob, player_name, damage)
    local player = self:_get_player(mob, player_name)
    player:add_damage(damage)
end


function DamageDB:add_ws_damage(mob, player_name, damage)
    local player = self:_get_player(mob, player_name)
    player:add_ws_damage(0, damage)
end

function DamageDB:iter()
    -- need to write this
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
