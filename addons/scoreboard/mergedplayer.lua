--[[
    The entire mergedplayer file exists to flatten individual stats in the db
    into two numbers (per name). So normally the db is:
    dps_db.dp[mob_name][player_name] = {stats}
    Mergedplayer iterates over mob_name and returns a table that's just:
    tab[player_name] = {CalculatedStatA,CalculatedStatB}
]]

local MergedPlayer = {}

function MergedPlayer:new (o)
    o = o or {}
    
    assert(o.players and #o.players > 0,
           "MergedPlayer constructor requires at least one Player instance.")

    setmetatable(o, self)
    self.__index = self
    
    return o
end

--[[
    'wsmin', 'wsmax', 'wsavg'
]]

function MergedPlayer:mavg()
    local hits, hit_dmg = 0, 0
    
    for _, p in ipairs(self.players) do
        hits    = hits + p.m_hits
        hit_dmg = hit_dmg + p.m_hits*p.m_avg
    end
    
    if hits > 0 then
        return { hit_dmg / hits, hits}
    else
        return {0, 0}
    end
end


function MergedPlayer:mrange()
    local m_min, m_max = math.huge, 0
    
    for _, p in ipairs(self.players) do
        m_min = math.min(m_min, p.m_min)
        m_max = math.max(m_max, p.m_max)
    end

    return {m_min~=math.huge and m_min or m_max, m_max}
end


function MergedPlayer:critavg()
    local crits, crit_dmg = 0, 0
    
    for _, p in ipairs(self.players) do
        crits    = crits + p.m_crits
        crit_dmg = crit_dmg + p.m_crits*p.m_crit_avg
    end
    
    if crits > 0 then
        return { crit_dmg / crits, crits}
    else
        return {0, 0}
    end
end


function MergedPlayer:critrange()
    local m_crit_min, m_crit_max = math.huge, 0
    
    for _, p in ipairs(self.players) do
        m_crit_min = math.min(m_crit_min, p.m_crit_min)
        m_crit_max = math.max(m_crit_max, p.m_crit_max)
    end
    
    return {m_crit_min~=math.huge and m_crit_min or m_crit_max, m_crit_max}
end


function MergedPlayer:ravg()
    local r_hits, r_hit_dmg = 0, 0
    
    for _, p in ipairs(self.players) do
        r_hits    = r_hits + p.r_hits
        r_hit_dmg = r_hit_dmg + p.r_hits*p.r_avg
    end
    
    if r_hits > 0 then
        return { r_hit_dmg / r_hits, r_hits}
    else
        return {0, 0}
    end
end


function MergedPlayer:rrange()
    local r_min, r_max = math.huge, 0
    
    for _, p in ipairs(self.players) do
        r_min = math.min(r_min, p.r_min)
        r_max = math.max(r_max, p.r_max)
    end
    
    return {r_min~=math.huge and r_min or r_max, r_max}
end


function MergedPlayer:rcritavg()
    local r_crits, r_crit_dmg = 0, 0
    
    for _, p in ipairs(self.players) do
        r_crits    = r_crits + p.r_crits
        r_crit_dmg = r_crit_dmg + p.r_crits*p.r_crit_avg
    end
    
    if r_crits > 0 then
        return { r_crit_dmg / r_crits, r_crits}
    else
        return {0, 0}
    end
end


function MergedPlayer:rcritrange()
    local r_crit_min, r_crit_max = math.huge, 0
    
    for _, p in ipairs(self.players) do
        r_crit_min = math.min(r_crit_min, p.r_crit_min)
        r_crit_max = math.max(r_crit_max, p.r_crit_max)
    end
    
    return {r_crit_min~=math.huge and r_crit_min or r_crit_max, r_crit_max}
end


function MergedPlayer:acc()
    local hits, crits, misses = 0, 0, 0
    
    for _, p in ipairs(self.players) do
        hits   = hits + p.m_hits
        crits  = crits + p.m_crits
        misses = misses + p.m_misses
    end
    
    local total = hits + crits + misses
    if total > 0 then
        return {(hits + crits) / total, total}
    else
        return {0, 0}
    end
end


function MergedPlayer:racc()
    local hits, crits, misses = 0, 0, 0
    
    for _, p in ipairs(self.players) do
        hits   = hits + p.r_hits
        crits  = crits + p.r_crits
        misses = misses + p.r_misses
    end
    
    local total = hits + crits + misses
    if total > 0 then
        return {(hits + crits) / total, total}
    else
        return {0, 0}
    end
end


function MergedPlayer:crit()
    local hits, crits = 0, 0
    
    for _, p in ipairs(self.players) do
        hits   = hits + p.m_hits
        crits  = crits + p.m_crits
    end
    
    local total = hits + crits
    if total > 0 then
        return {crits / total, total}
    else
        return {0, 0}
    end
end


function MergedPlayer:rcrit()
    local hits, crits = 0, 0
    
    for _, p in ipairs(self.players) do
        hits   = hits + p.r_hits
        crits  = crits + p.r_crits
    end
    
    local total = hits + crits
    if total > 0 then
        return {crits / total, total}
    else
        return {0, 0}
    end
end


function MergedPlayer:wsavg()
    local wsdmg   = 0
    local wscount = 0
    --[[
    for _, p in pairs(self.players) do
        for _, dmgtable in pairs(p.ws) do
            for _, dmg in pairs(dmgtable) do
                wsdmg = wsdmg + dmg
                wscount = wscount + 1
            end
        end 
    end
    ]]
    
    for _, p in pairs(self.players) do
        for _, dmg in pairs(p.ws) do
            wsdmg = wsdmg + dmg
            wscount = wscount + 1
        end
    end
    
    if wscount > 0 then
        return {wsdmg / wscount, wscount}
    else
        return {0, 0}
    end
end

function MergedPlayer:wsacc()
    local hits, misses = 0, 0
    
    for _, p in ipairs(self.players) do
        hits = hits + table.length(p.ws)
        misses = misses + p.ws_misses
    end
    
    local total = hits + misses
    if total > 0 then
        return {hits / total, total}
    else
        return {0, 0}
    end
end

-- Unused atm
function MergedPlayer:merge(other)
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




return MergedPlayer

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


