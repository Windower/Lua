--[[
Copyright © 2017, Sammeh of Quetzalcoatl
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of JobChange nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sammeh BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'Job Change'
_addon.author = 'Sammeh'
_addon.version = '1.0.3'
_addon.command = 'jc'

-- 1.0.1 first release
-- 1.0.2 added 'reset' command to simply reset to existing job.  Changes sub job to a random starting job and back.
-- 1.0.3 Code clean-up

require('tables')
packets = require('packets')
res = require ('resources')

function jobchange(job,main_sub)
    windower.add_to_chat(4,"JobChange: Changing "..main_sub.." job to:"..res.jobs[job].ens)
    if job and main_sub then 
        local packet = packets.new('outgoing', 0x100, {
            [main_sub:sub(1,1):upper()..main_sub:sub(2)..' Job'] = job,
        })
        packets.inject(packet)
        coroutine.sleep(0.5)
    end    
end

windower.register_event('addon command', function(command, ...)
    local self = windower.ffxi.get_player()
    local args = L{...}
    local job = ''
    if args[1] then 
        job = args[1]:lower()
    end
    local main_sub = ''
    if command:lower() == 'main' then
        main_sub = 'main'
    elseif command:lower() == 'sub' then
        main_sub = 'sub'
    elseif command:lower() == 'reset' then
        windower.add_to_chat(4,"JobChange: Resetting Job")
        main_sub = 'sub'
        job = windower.ffxi.get_player().sub_job:lower()
    else
        windower.add_to_chat(4,"JobChange Syntax: //jc main|sub JOB  -- Chnages main or sub to target JOB")
        windower.add_to_chat(4,"JobChange Syntax: //jc reset -- Resets Current Job")
        return
    end
    local conflict = find_conflict(job,self)
    local jobid = find_job(job,self)
    if jobid then 
        local npc = find_job_change_npc()
        if npc then
            if not conflict then 
                jobchange(jobid,main_sub)
            else
                local temp_job = find_temp_job(self)            
                windower.add_to_chat(4,"JobChange: Conflict with "..conflict)
                if main_sub == conflict then 
                    jobchange(temp_job,main_sub)
                    jobchange(jobid,main_sub)
                else
                    jobchange(temp_job,conflict)
                    jobchange(jobid,main_sub)
                end
            end
        else
            windower.add_to_chat(4,"JobChange: Not close enough to a Moogle!")
        end        
    else
        windower.add_to_chat(4,"JobChange: Could not change "..command.." to "..job:upper().." ---Mistype|NotUnlocked")
    end
    
end)

function find_conflict(job,self)
    if self.main_job == job:upper() then
        return "main"
    end
    if self.sub_job == job:upper() then
        return "sub"
    end
end

function find_temp_job(self)
    local starting_jobs = S { 'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF' } 
    for i in pairs(starting_jobs) do
        if not find_conflict(i,self) then 
            for index,value in pairs(res.jobs) do
                if value.ens == i then
                    return index
                end
            end
        end
    end
end

function find_job(job,self)
    local jobLevel = self.jobs[job:upper()]
    for index,value in pairs(res.jobs) do
        if value.ens:lower() == job and jobLevel > 0 then 
            return index
        end
    end
end


function find_job_change_npc()
    local info = windower.ffxi.get_info()
    if not (info.mog_house or S{'Selbina', 'Mhaura', 'Tavnazian Safehold', 'Nashmau', 'Rabao', 'Kazham', 'Norg'}:contains(res.zones[info.zone].english)) then
        windower.add_to_chat(4,'JobChange: Not in a zone with a Change NPC')
        return
    end

    for i, v in pairs(windower.ffxi.get_mob_array()) do
        if v.distance < 36 and S{'Moogle', 'Nomad Moogle', 'Green Thumb Moogle'}:contains(v.name) then
            return v
        end
    end
end
