--[[
Copyright © 2016, Sammeh of Quetzalcoatl
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
_addon.version = '1.0.2'
_addon.command = 'jc'

-- 1.0.1 first release
-- 1.0.2 added 'reset' command to simply reset to existing job.  Changes sub job to a random starting job and back.

require('tables')
packets = require('packets')
res = require ('resources')

function jobchange(job,main_sub)
	windower.add_to_chat(4,"JobChange: Changing "..main_sub.." job to:"..res.jobs[job].ens)
	if job and main_sub then 
		if main_sub == 'main' then 
			local packet = packets.new('outgoing', 0x100, {
			["Main Job"]=job,
			["Sub Job"]=0,
			["_unknown1"]=0,
			["_unknown2"]=0
			})
			packets.inject(packet)
			coroutine.sleep(0.5)
		elseif main_sub == 'sub' then
			local packet = packets.new('outgoing', 0x100, {
			["Main Job"]=0,
			["Sub Job"]=job,
			["_unknown1"]=0,
			["_unknown2"]=0
			})
			packets.inject(packet)
			coroutine.sleep(0.5)
		end
	end
end

windower.register_event('addon command', function(command, ...)
	local args = L{...}
	local job = ''
	if args[1] then 
		job = args[1]:lower()
	end
	local currentjob = windower.ffxi.get_player()
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
	local conflict = find_conflict(job)
	local jobid = find_job(job)
	if jobid then 
		local npc = find_job_change_npc()
		if npc then
			if not conflict then 
				jobchange(jobid,main_sub)
			else
				local temp_job = find_temp_job()			
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

function find_conflict(job)
	local self = windower.ffxi.get_player()
	if self.main_job == job:upper() then
		return "main"
	end
	if self.sub_job == job:upper() then
		return "sub"
	end
end

function find_temp_job()
	local starting_jobs = {
	-- WAR, MNK, WHM, BLM, THF, RDM - main starting jobs.
		["WAR"] = 1,
		["MNK"] = 2,
		["WHM"] = 3,
		["BLM"] = 4,
		["RDM"] = 5,
		["THF"] = 6,
	}
	for index,value in pairs(starting_jobs) do
		if not find_conflict(index) then 
			return value
		end
	end
end

function find_job(job)
	local self = windower.ffxi.get_player()
	local ki = windower.ffxi.get_key_items() 
	
	for index,value in pairs(res.jobs) do
		if value.ens:lower() == job then 
			jobid = index
		end
	end
	--[[
		Small rant/request/can't figure out a better way.
		windower.ffxi.get_player().jobs includes all jobs regardless if you have it unlocked.  I expected self.jobs["GEO"] to be nil if I didn't have it.  For now going to use a list of the KI's for 
		Job emotes to see which jobs are unlocked. 
	]]	
	local job_gesture_ids = {
		-- Pulled from resources. 12/26/2016
		["WAR"] = 1738,
		["MNK"] = 1739,
		["WHM"] = 1740,
		["BLM"] = 1741,
		["RDM"] = 1742,
		["THF"] = 1743,
		["PLD"] = 1744,
		["DRK"] = 1745,
		["BST"] = 1746,
		["BRD"] = 1747,
		["RNG"] = 1748,
		["SAM"] = 1749,
		["NIN"] = 1750,
		["DRG"] = 1751,
		["SMN"] = 1752,
		["BLU"] = 1753,
		["COR"] = 1754,
		["PUP"] = 1755,
		["DNC"] = 1756,
		["SCH"] = 1757,
		["GEO"] = 2963,
		["RUN"] = 2964,
	}
	local job_gesture = job_gesture_ids[job:upper()]
	for i,v in pairs(ki) do
		if v == job_gesture then
			return jobid
		end
	end
end


function find_job_change_npc()
	found = nil
	local valid_zones = { 
		-- Zones with a nomad moogle / green thumb moogle, taken from Resources
		-- All other zones check if mog_house
		[26] = {id=26,en="Tavnazian Safehold",ja="タブナジア地下壕",search="TavSafehld"},
		[53] = {id=53,en="Nashmau",ja="ナシュモ",search="Nashmau"},
		[247] = {id=247,en="Rabao",ja="ラバオ",search="Rabao"},
		[248] = {id=248,en="Selbina",ja="セルビナ",search="Selbina"},
		[249] = {id=249,en="Mhaura",ja="マウラ",search="Mhaura"},
		[250] = {id=250,en="Kazham",ja="カザム",search="Kazham"},
		[252] = {id=252,en="Norg",ja="ノーグ",search="Norg"},	
	}
	local info = windower.ffxi.get_info()
	if not (valid_zones[info['zone']] or info['mog_house']) then
		windower.add_to_chat(4,'JobChange: Not in a zone with a Change NPC')
		return
	end
	for i,v in pairs(windower.ffxi.get_mob_array()) do
		if v['name'] == 'Moogle' or v['name'] == 'Nomad Moogle' or v['name'] == 'Green Thumb Moogle' then
			found = 1
			target_index = i
			target_id = v['id']
			distance = windower.ffxi.get_mob_by_id(target_id).distance
			if math.sqrt(distance)<6 then 
				return found
			end
		end
	end
end
