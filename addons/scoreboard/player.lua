--[[
Object to encapsulate Player battle data

For each mob fought, a separate player instance will be stored. Therefore
there will be multiple Player instances for each actual player in the game.
This allows for easier mob filtering. 
--]]

local Player = {}

function Player:new (o)
    o = o or {}
    
    -- attrs should be defined in Player above but due to interpreter bug it's here for now
    local attrs = {
        clock = nil,    -- specific DPS clock for this player
        damage = 0,     -- total damage done by this player
        ws  = T{},       -- table of all WS and their corresponding damage
        m_hits = 0,     -- total melee hits
        m_misses = 0,   -- total melee misses
        m_min = 0,      -- minimum melee damage
        m_max = 0,      -- maximum melee damage
        m_avg = 0,      -- avg melee damage
        m_crits = 0,    -- total melee crits
        m_crit_min = 0, -- minimum melee crit
        m_crit_max = 0, -- maximum melee crit
        m_crit_avg = 0, -- avg melee crit
        r_hits = 0,     -- total ranged hits
        r_min = 0,      -- minimum ranged damage
        r_max = 0,      -- maximum ranged damage
        r_avg = 0,      -- avg ranged damage
        r_misses = 0,   -- total ranged misses
        r_crits = 0,    -- total ranged crits
        r_crit_min = 0, -- minimum ranged crit
        r_crit_max = 0, -- maximum ranged crit
        r_crit_avg = 0, -- avg ranged crit
        jobabils = 0,   -- total damage from JAs
        spells = 0      -- total damage from spells
    }
    if o.name then
        attrs.name = o.name
        o = attrs
    else
        o = attrs
    end
    
    setmetatable(o, self)
    self.__index = self
    
    return o
end


function Player:add_damage(damage)
    self.damage = self.damage + damage
end


function Player:add_ws_damage(ws_id, damage)
    if not self.ws[ws_id] then
        self.ws[ws_id] = T{}
    end
    
    self.ws[ws_id]:append(damage)
    self.damage = self.damage + damage
end


-- Returns the name of this player
function Player:get_name()
    return self.name
end


-- Returns player accuracy as a percentage
function Player:acc()
    notice('got called in :acc()')
    if self.m_hits > 0 then
        return self.m_hits / (self.m_hits + self.m_misses)
    else
        return 0
    end
end


-- Merge another player instance into ourself
function Player:merge(other)
    self.damage = self.damage + other.damage

    for ws_id, values in pairs(other.ws) do
        if self.ws[ws_id] then
            for _, value in ipairs(values) do
                self.ws[ws_id]:append(value)
            end
        else
            self.ws[ws_id] = table.copy(values)
        end
    end
    
    self.m_hits   = self.m_hits + other.m_hits
    self.m_misses = self.m_misses + other.m_misses
    self.m_min    = math.min(self.m_min, other.m_min)
    self.m_max    = math.max(self.m_max, other.m_max)
    
    local total_m_hits = self.m_hits + other.m_hits
    if total_m_hits > 0 then
        self.m_avg    = self.m_avg  * self.m_hits/total_m_hits +
                        other.m_avg * other.m_hits/total_m_hits
    else
        self.m_avg = 0
    end
    
    self.m_crits   = self.m_crits + other.m_crits
    self.m_crit_min = math.min(self.m_crit_min, other.m_crit_min)
    self.m_crit_max = math.max(self.m_crit_max, other.m_crit_max)

    local total_m_crits  = self.m_crits + other.m_crits
    if total_m_crits > 0 then
        self.m_crit_avg = self.m_crit_avg  * self.m_crits / total_m_crits +
                          other.m_crit_avg * other.m_crits / total_m_crits
    else
        self.m_crit_avg = 0
    end
    
    self.r_hits   = self.r_hits + other.r_hits
    self.r_misses = self.r_misses + other.r_misses
    self.r_min    = math.min(self.r_min, other.r_min)
    self.r_max    = math.max(self.r_max, other.r_max)

    local total_r_hits = self.r_hits + other.r_hits
    if total_r_hits > 0 then
        self.r_avg    = self.r_avg  * self.r_hits/total_r_hits +
                        other.r_avg * other.r_hits/total_r_hits
    else
        self.r_avg = 0
    end
    
    self.r_crits    = self.r_crits + other.r_crits
    self.r_crit_min = math.min(self.r_crit_min, other.r_crit_min)
    self.r_crit_max = math.max(self.r_crit_max, other.r_crit_max)

    local total_r_crits  = self.r_crits + other.r_crits
    if total_r_crits > 0 then
        self.r_crit_avg = self.r_crit_avg  * self.r_crits / total_r_crits +
                          other.r_crit_avg * other.r_crits / total_r_crits
    else
        self.r_crit_avg = 0
    end
    
    self.jobabils = self.jobabils + other.jobabils
    self.spells   = self.spells + other.spells
end


-- Returns ranged accuracy as a percentage
function Player:ranged_acc()
    if self.r_hits > 0 then
        return self.r_hits / (self.r_hits + self.r_misses)
    else
        return 0
    end
end


function Player:crit()
    if self.m_hits > 0 then
        return self.m_crits / self.m_hits
    else
        return 0
    end
end


function Player:ranged_crit()
    if self.r_hits > 0 then
        return self.r_crits / self.r_hits
    else
        return 0
    end
end

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

