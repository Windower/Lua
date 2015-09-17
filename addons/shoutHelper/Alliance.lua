--[[
Copyright (c) 2013, Chiara De Acetis
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- Object Alliance
--[[
Concept
list = {party1={} party2={} party3={}}
list = {party1={WHM="ppl" PLD="ppl" WAR="ppl" DD="ppl" } party2={} party3={}}
if there's "add war" and only DD slots are left, it has to put the war in the DD slot
]]
local Alliance = {}

require 'logger'
local files = require 'files'

local JobList = T{
    'blm',
    'blu',
    'brd',
    'bst',
    'dnc',
    'drg',
    'drk',
    'whm',
    'rdm',
    'pup',
    'cor',
    'pld',
    'geo',
    'run',
    'sch',
    'mnk',
    'thf',
    'war',
    'sam',
    'nin',
    'smn',
    'rng',
    'dd',
    'support',
    'heal',
    'tank'
}

local DDlist = T{
    'blm',
    'blu',
    'bst',
    'dnc',
    'drg',
    'drk',
    'pup',
    'pld',
    'run',
    'mnk',
    'thf',
    'war',
    'sam',
    'nin',
    'smn',
    'rng'
}

local SupportList = T{
    'cor',
    'brd',
    'geo'
}

local HealList = T{
    'whm',
    'rdm',
    'sch'
}

--create and empty alliance
function Alliance:new()
    local ally = {
        party1 = {},
        party2 = {},
        party3 = {}
    }
    setmetatable(ally, self)
    self.__index = self
    return ally
end

--sets one or multiple job in party1
function Alliance:setParty1(jobs)
    local length = 0
    local numJob = #self.party1
    if numJob == 6 then
        return
    end
    if #jobs <= (6 - numJob) then
        length = #jobs
    else
        length = (6 - numJob)
    end
    j = 1
    for i = 1, length do
        job = jobs[i]:lower()
        if JobList:contains(job) then
            self.party1[j+numJob] = {job}
            j = j+1
        end
    end
end

--sets one or multiple job in the party2
function Alliance:setParty2(jobs)
    local length = 0
    local numJob = #self.party2
    if numJob == 6 then
            return
    end
    if #jobs <= (6 - numJob) then
        length = #jobs
    else
            length = (6 - numJob)
    end
    j = 1
    for i = 1, length do
        job = jobs[i]:lower()
        if JobList:contains(job) then
            self.party2[j+numJob] = {job}
            j = j+1
        end
    end
end

--sets one or multiple job in party3
function Alliance:setParty3(jobs)
    local length = 0
    local numJob = #self.party3
    if numJob == 6 then
        return
    end
    if #jobs <= (6 - numJob) then
        length = #jobs
    else
        length = (6 - numJob)
    end
    j = 1
    for i = 1, length do
        job = jobs[i]:lower()
        if JobList:contains(job) then
            self.party3[j+numJob] = {job}
            j = j+1
        end
    end
end

--delete a job inside the ally
function Alliance:deleteJob(job, party) --it rescale the player list too
    job = job:lower()
    -- party slot not given
    if (party == nil ) then
        party = self:findJob(job)
        if party[1] == 1 then			
            table.remove(self.party1, party[2])
        elseif party[1] == 2 then
            table.remove(self.party2, party[2])
        elseif party[1] == 3 then
            table.remove(self.party3, party[2])
        end
    else -- party given
        if (party == "party1") then
            for i=1, #self.party1 do
                local slot = self.party1[i]
                local v = slot[1]
                if(v == job) then
                    table.remove(self.party1, i)
                    return
                end
            end
        elseif (party == "party2") then
            for i=1, #self.party2 do
                    local slot = self.party2[i]
                    local v = slot[1]
                    if(v == job) then
                        table.remove(self.party2, i)
                        return
                    end
            end
        elseif (party == "party3") then
            for i=1, #self.party3 do
                if(v == job) then
                    table.remove(self.party3, i)
                    return
                end
            end
        end
    end
end

--returns the first party table that contains the given job
function Alliance:findJob(job)
    local party = nil
    for i=1, #self.party1 do
        local slot = self.party1[i]
        local v = slot[1]
        if( v == job ) then
            party = {1, i}
            return party
        end
    end
    if(party == nil) then
         for i=1, #self.party2 do
            local slot = self.party2[i]
            local v = slot[1]
            if( v == job ) then
                party = {2, i}
                return party
            end
        end
    end
    if(party == nil) then
         for i=1, #self.party3 do
            local slot = self.party3[i]
            local v = slot[1]
            if( v == job ) then
                party = {3, i}
                return party
            end
        end
    end
    if(party == nil ) then
        error(job..' not found')
        return
    end
end

--returns the string representing the party
function Alliance:printAlly()
    local s = ''
    if(#self.party1 > 0) then
        s = s..'\nPARTY 1\n'
        for i=1, #self.party1 do
            slot = self.party1[i]
            job = slot[1]
            name = slot[2]
            s = s..'['..job:upper()..']'
            if name then
                    s = s..' '..name
            end
            s = s..' \n'
        end
    end
    if(#self.party2 > 0) then
        s = s..'\nPARTY 2\n'
        for i=1, #self.party2 do
            slot = self.party2[i]
            job = slot[1]
            name = slot[2]
            s = s..'['..job:upper()..']'
            if name then
                    s = s..' '..name
            end
            s = s..' \n'
        end
    end
    if(#self.party3 > 0) then
        s = s..'\nPARTY 3\n'
        for i=1, #self.party3 do
            slot = self.party3[i]
            job = slot[1]
            name = slot[2]
            s = s..'['..job:upper()..']'
            if name then
                    s = s..' '..name
            end
            s = s..' \n'
        end
    end
    return s
end

--delete the ally
function Alliance:deleteAll()
    self.party1 = {}
    self.party2 = {}
    self.party3 = {}
end

--delete the party
function Alliance:delete(party)
    if party == "party1" then
        self.party1 = {}
    elseif party == "party2" then
        self.party2 = {}
    elseif party == "party3" then
        self.party3 = {}
    end
end

--sets one player to the first <job> slot free
function Alliance:addPlayer(job, name)
    local party = self:findFreeSlot(job)
    local rightJob = true
    --if party is null the job wasn't found
    --it means the there isn't the given job (example: one's looking for mnk and only slot DD are left)
    if not party and job then
        if DDlist:contains(job:lower()) then
            party = self:findFreeSlot('dd')
            rightJob = false
        elseif SupportList:contains(job:lower())then
            party = self:findFreeSlot('support')
            rightJob = false
        elseif HealList:contains(job:lower()) then
            party = self:findFreeSlot('heal')
            rightJob = false
        end
        if not party then
            error("Can't find a free slot")
            return
        end
    end
    local pos = party[2]	
    if (party[1] == 1) then
        local slot = self.party1[pos]
        if rightJob then
            self.party1[pos] = {slot[1], name}
        else
            self.party1[pos] = {job:lower(), name}
        end
    end
    if (party[1] == 2) then
        local slot = self.party2[pos]
        if rightJob then
            self.party2[pos] = {slot[1], name}
        else
            self.party2[pos] = {job, name}
        end
    end
    if (party[1] == 3) then
        local slot = self.party3[pos]
        if rightJob then
            self.party3[pos] = {slot[1], name}
        else
            self.party3[pos] = {job, name}
        end
    end
    --if I'm here it means it the given job is missing
end

--find the first free party slot (job is optional)
function Alliance:findFreeSlot(job)
    local party = nil --first position is pt, second is party slot
    for i=1, #self.party1 do
        local slot = self.party1[i]
        local jobName = slot[1]
        local name = slot[2]
        if ((not job) and name == nil) then 
            --no job given, I'm looking for the first free slot in party
            party = {1, i}
            return party
        elseif (job and name == nil) then
            --the job is given, I'm looking for the first free slot for the given job
            job = job:lower()
            if(jobName == job)then
                party = {1, i}
                return party
            end
        end
    end
    for i=1, #self.party2 do
        local slot = self.party2[i]
        local jobName = slot[1]
        local name = slot[2]
        if ((not job) and name == nil) then 
            --no job given, I'm looking for the first free slot in party
            party = {2, i}
            return party
        elseif (job and name == nil) then
            --the job is given, I'm looking for the first free slot for the given job
            job = job:lower()
            if(jobName == job)then
                party = {2, i}
                return party
            end
        end
    end
    for i=1, #self.party3 do
        local slot = self.party3[i]
        local jobName = slot[1]
        local name = slot[2]
        if ((not job) and name == nil) then 
            --no job given, I'm looking for the first free slot in party
            party = {3, i}
            return party
        elseif (job and name == nil) then
            --the job is given, I'm looking for the first free slot for the given job
            job = job:lower()
            if(jobName == job)then
                party = {3, i}
                return party
            end
        end
    end
end

-- removes the player from alliance list (i remove the player in i-esim position)
function Alliance:removePlayer(name)
    name = name:lower()
    --looks through the pts
    local v = ''
    local slot = nil
    for k=1, #self.party1 do
        slot = self.party1[k]
        v = slot[2]
        if(v~= nil)then
            v = v:lower()
            if v == name then
                self.party1[k] = {slot[1]}
                return
            end
        end
    end
    for k=1, #self.party2 do
        slot = self.party2[k]
        v = slot[2]
        if(v~= nil)then
            v = v:lower()
            if v == name then
                self.party2[k] = {slot[1]}
                return
            end
        end
    end
    for k=1, #self.party3 do
        slot = self.party3[k]
        v = slot[2]
        if(v~= nil)then
            v = v:lower()
            if v == name then
                self.party3[k] = {slot[1]}
                return
            end
        end
    end
end

--save the current ally in an xml file
function Alliance:save()
    --TODO (now creates only a string xml)
    local a = '<?xml version="1.0" ?>\n'
    a = a..'<alliance>\n'
    a = a..'\t<party1>\n'
    for i=1, #self.party1 do
        slot = self.party1[i]
        job = slot[1]
        a = a..'\t\t<job'..i..'>'..job:upper()..'</job'..i..'>\n'
    end
    a = a..'\t</party1>\n'
    a = a..'\t<party2>\n'
    for i=1, #self.party2 do
        slot = self.party2[i]
        job = slot[1]
        a = a..'\t\t<job'..i..'>'..job:upper()..'</job'..i..'>\n'
    end
    a = a..'\t</party2>\n'
    a = a..'\t<party3>\n'
    for i=1, #self.party3 do
        slot = self.party3[i]
        job = slot[1]
        a = a..'\t\t<job'..i..'>'..job:upper()..'</job'..i..'>\n'
    end
    a = a..'\t</party3>\n'
    a = a..'</alliance>\n'
end

return Alliance
