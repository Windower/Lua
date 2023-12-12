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
_addon.author = 'Sammeh; Akaden'
_addon.version = '1.0.4'
_addon.command = 'jc'

-- 1.0.1 first release
-- 1.0.2 added 'reset' command to simply reset to existing job.  Changes sub job to a random starting job and back.
-- 1.0.3 Code clean-up
-- 1.0.4 Added /jc main/sub command and organized solve for fewest changes.

require('tables')
packets = require('packets')
res = require ('resources')

local temp_jobs =  T { 'NIN', 'DNC', 'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF' } 
local mog_zones = S { 'Selbina', 'Mhaura', 'Tavnazian Safehold', 'Nashmau', 'Rabao', 'Kazham', 'Norg', 'Walk of Echoes [P1]', 'Walk of Echoes [P2]' }
local moogles = S { 'Moogle', 'Nomad Moogle', 'Green Thumb Moogle', 'Pilgrim Moogle' }

local log = function(msg)
    windower.add_to_chat(4,'JobChange: '..msg)
end

local jobchange = function(job, main)
    local packet = packets.new('outgoing', 0x100, {
        [(main and 'Main' or 'Sub')..' Job'] = job,
    })
    packets.inject(packet)
end

local find_conflict = function(job_name, p)
    if p.main_job == job_name:upper() then
        return 'main'
    end
    if p.sub_job == job_name:upper() then
        return 'sub'
    end
end

injected_poke = false
local poke = function(npc)
   local p = packets.new('outgoing', 0x1a, {
      ["Target"] = npc.id,
      ["Target Index"] = npc.index,
      })
      injected_poke = true
      packets.inject(p) 
end
windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
   local p = packets.parse('incoming',data)
	if id == 0x02E and injected_poke then
	   injected_poke = false
      return true
   end
end)
   
local find_temp_job = function(p)
    for _, job_name in ipairs(temp_jobs) do
        if not find_conflict(job_name, p) and p.jobs[job_name:upper()] > 0 then 
            for index,value in pairs(res.jobs) do
                if value.ens == job_name then
                    return index
                end
            end
        end
    end
end

local find_job = function(job,p)
    if job == nil then return nil end
    local jobLevel = p.jobs[job:upper()]
    for index,value in pairs(res.jobs) do
        if value.ens:lower() == job and jobLevel > 0 then 
            return index
        end
    end
end

local find_job_change_npc = function()
    local info = windower.ffxi.get_info()
    if not (info.mog_house or mog_zones:contains(res.zones[info.zone].english)) then
        log('Not in a zone with a Change NPC')
        return
    end

    for _, v in pairs(windower.ffxi.get_mob_array()) do
        if v.distance < 36 and v.valid_target and moogles:contains(v.name) then
            return v
        end
    end
end

windower.register_event('addon command', function(command, ...)
    command = command:lower()
    local p = windower.ffxi.get_player()
    local args = L{...}
    local job = nil
    if args[1] then 
        job = args[1]:lower()
    else
        job = command
    end
    local main = nil
    local sub = nil
    if command == 'main' then
        main = job
        if main and main:upper() == p.main_job then main = nil end
    elseif command == 'sub' then
        sub = job
        if sub and sub:upper() == p.sub_job then main = nil end
    elseif command == 'reset' then
        log('Resetting Job')
        sub = p.sub_job:lower()
    elseif command:contains('/') or command:contains('\\') then
        job = job:gsub('\\','/')
        local js = job:split('/')
        main = (js[1] ~= '' and js[1] or nil)
        sub = (js[2] ~= '' and js[2] or nil)
        -- remove identicals.
        if main and main:upper() == p.main_job then main = nil end
        if sub and sub:upper() == p.sub_job then sub = nil end
    elseif command ~= nil and command ~= '' then
        main = command
        if main and main:upper() == p.main_job then main = nil end
    else
        log('Syntax: //jc main|sub JOB  -- Chnages main or sub to target JOB')
        log('Syntax: //jc main/sub  -- Changes main and sub')
        log('Syntax: //jc reset -- Resets Current Job')
        return
    end

    local changes = T{}

    local main_id = find_job(main, p)
    if main ~= nil and main_id == nil then 
        log('Could not change main job to to '..main:upper()..' ---Mistype|NotUnlocked')
        return
    end
    local sub_id = find_job(sub, p)
    if sub ~= nil and sub_id == nil then 
        log('Could not change sub job to to '..sub:upper()..' ---Mistype|NotUnlocked')
        return
    end

    if main_id == nil and sub_id == nil then
        log('No change required.')
        return
    end

    if main_id ~= nil and main:upper() == p.sub_job then
        if sub_id ~= nil and sub:upper() == p.main_job then
            changes:append({job_id=find_temp_job(p), is_conflict=true, is_main=false})
            changes:append({job_id=main_id, is_main=true})
            changes:append({job_id=sub_id, is_main=false})
        else
            if sub_id ~= nil then
                changes:append({job_id=sub_id, is_main=false})
            else
                changes:append({job_id=find_temp_job(p), is_conflict=true, is_main=false})
            end
            changes:append({job_id=main_id, is_main=true})
        end
    elseif sub_id ~= nil and sub:upper() == p.main_job then
        if main_id ~= nil then
            changes:append({job_id=main_id, is_main=true})
        else
            changes:append({job_id=find_temp_job(p), is_conflict=true, is_main=true})
        end
        changes:append({job_id=sub_id, is_main=false})
    else
        if main_id ~= nil then
            if main:upper() == p.main_job then
                changes:append({job_id=find_temp_job(p), is_conflict=true, is_main=true})
            end
            changes:append({job_id=main_id, is_main=true})
        end
        if sub_id ~= nil then
            if sub:upper() == p.sub_job then
                changes:append({job_id=find_temp_job(p), is_conflict=true, is_main=false})
            end
            changes:append({job_id=sub_id, is_main=false})
        end
    end

    local npc = find_job_change_npc()
    if npc then
        if npc.name == 'Nomad Moogle' or npc.name == 'Pilgrim Moogle'then
            poke(npc)
            coroutine.sleep(1) -- the moogles don't return an 0x032~0x034 so can't job change in response to an incoming menu packet.
        end
        for _, change in ipairs(changes) do
            if change.is_conflict then
                log('Conflict with '..(change.is_main and 'main' or 'sub')..' job. Changing to: '..res.jobs[change.job_id].ens)
            else
                log('Changing '..(change.is_main and 'main' or 'sub')..' job to: '..res.jobs[change.job_id].ens)
            end
            jobchange(change.job_id, change.is_main)
            coroutine.sleep(0.5)
        end
    else
        log('Not close enough to a Moogle!')
    end       
end)
