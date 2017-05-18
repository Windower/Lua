--[[
Object to encapsulate Player battle data

For each mob fought, a separate player instance will be stored. Therefore
there will be multiple Player instances for each actual player in the game.
This allows for easier mob filtering. 
]]

local Player = {}

function Player:new (o)
    o = o or {}
    
    assert(o.name, "Must pass a name to player constructor")
    -- attrs should be defined in Player above but due to interpreter bug it's here for now
    local attrs = {
        clock = nil,            -- specific DPS clock for this player
        damage = 0,             -- total damage done by this player
        ws  = T{},              -- table of all WS and their corresponding damage
        ws_misses = 0,          -- total ws misses
        m_hits = 0,             -- total melee hits
        m_misses = 0,           -- total melee misses
        m_min = math.huge,      -- minimum melee damage
        m_max = 0,              -- maximum melee damage
        m_avg = 0,              -- avg melee damage
        m_crits = 0,            -- total melee crits
        m_crit_min = math.huge, -- minimum melee crit
        m_crit_max = 0,         -- maximum melee crit
        m_crit_avg = 0,         -- avg melee crit
        r_hits = 0,             -- total ranged hits
        r_min = math.huge,      -- minimum ranged damage
        r_max = 0,              -- maximum ranged damage
        r_avg = 0,              -- avg ranged damage
        r_misses = 0,           -- total ranged misses
        r_crits = 0,            -- total ranged crits
        r_crit_min = math.huge, -- minimum ranged crit
        r_crit_max = 0,         -- maximum ranged crit
        r_crit_avg = 0,         -- avg ranged crit
        jobabils = 0,           -- total damage from JAs
        spells = 0,             -- total damage from spells
        
        parries = 0,            -- total number of parries
        blocks = 0,             -- total number of blocks/guards
        nonblocks = 0,          -- total number of nonblocks
        evades = 0,             -- total number of evades
        damage_taken = 0,       -- total damage taken by this player
        
    }
    attrs.name = o.name
    o = attrs
    if o.name:match('^Skillchain%(') then
        o.is_sc = true
    else
        o.is_sc = false
    end
    
    setmetatable(o, self)
    self.__index = self
    
    return o
end


function Player:add_damage(damage)
    self.damage = self.damage + damage
end


function Player:add_ws_damage(ws_name, damage)
    --[[
    if not self.ws[ws_name] then
        self.ws[ws_name] = L{}
    end
    
    self.ws[ws_name]:append(damage)
    ]]
    self.ws:append(damage)
    self.damage = self.damage + damage
end


function Player:add_m_hit(damage)
    -- increment hits
    self.m_hits = self.m_hits + 1

    -- update min/max/avg melee values
    self.m_min = math.min(self.m_min, damage)
    self.m_max = math.max(self.m_max, damage)
    self.m_avg = self.m_avg * (self.m_hits - 1)/self.m_hits + damage/self.m_hits
        
    -- accumulate damage
    self.damage = self.damage + damage 
end


function Player:add_m_crit(damage)
    -- increment crits
    self.m_crits = self.m_crits + 1

    -- update min/max/avg melee values
    self.m_crit_min = math.min(self.m_crit_min, damage)
    self.m_crit_max = math.max(self.m_crit_max, damage)
    self.m_crit_avg = self.m_crit_avg * (self.m_crits - 1)/self.m_crits + damage/self.m_crits
        
    -- accumulate damage
    self.damage = self.damage + damage 
end

function Player:incr_m_misses() self.m_misses = self.m_misses + 1 end

function Player:incr_ws_misses() self.ws_misses = self.ws_misses + 1 end

function Player:add_r_hit(damage)
    -- increment hits
    self.r_hits = self.r_hits + 1

    -- update min/max/avg melee values
    self.r_min = math.min(self.r_min, damage)
    self.r_max = math.max(self.r_max, damage)
    self.r_avg = self.r_avg * (self.r_hits - 1)/self.r_hits + damage/self.r_hits
        
    -- accumulate damage
    self.damage = self.damage + damage 
end


function Player:add_r_crit(damage)
    -- increment crits
    self.r_crits = self.r_crits + 1

    -- update min/max/avg melee values
    self.r_crit_min = math.min(self.r_crit_min, damage)
    self.r_crit_max = math.max(self.r_crit_max, damage)
    self.r_crit_avg = self.r_crit_avg * (self.r_crits - 1)/self.r_crits + damage/self.r_crits
        
    -- accumulate damage
    self.damage = self.damage + damage 
end


function Player:incr_r_misses() self.r_misses = self.r_misses + 1 end

-- Returns the name of this player
function Player:get_name() return self.name end



return Player

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


