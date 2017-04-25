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

--[[
    A short class for maintaining accurate party lists.
--]]

local parties = {}
local meta = {}
_meta = _meta or {}
_meta.parties = {__index = parties}

function parties.new()
    local t = {nil, nil, nil, nil, nil, nil}
    local m = {}
    meta[t] = m

    m.n = 0
    
    return setmetatable(t, _meta.parties)
end

function parties.form_alliance(...)
    local t = {...}
    local alliance = {}
    
    for i = 1, #t do
        local party = t[i]
        for j = 1, 6 do
            alliance[6 * (i - 1) + j] = party[j]
        end
    end
    
    return alliance
end

function parties.kick(t, id)
    local i = 1
    local position
    local m = meta[t]
    local n = m.n
    
    repeat
        position = t[i] == id and i or nil
        i = i + 1
    until position or i > n
    
    if position then
        table.remove(t, position)
        t[6] = nil
        m.n = n - 1
        
        return position
    else
        return false
    end
end

function parties.kick_pos(t, n)
    local m = meta[t]
    
    local id = table.remove(t, n)
    m.n = #t
    
    return id or false
end

function parties.invite(t, id)
    local m = meta[t]
    local n = m.n + 1
    
    m.n = n
    t[n] = id
    
    return n
end

function parties.carbon_copy(t)
    local m = meta[t]
    local cc = {}
    
    for i = 1, m.n do
        cc[i] = t[i]
    end
    
    cc.n = m.n
    
    return cc
end

function parties.count(t)
    return meta[t].n
end

function parties.dissolve(t)
    --meta[t] = nil
    for i = 1, meta[t].n do
        t[i] = nil
    end
    
    meta[t].n = 0
end

return parties
