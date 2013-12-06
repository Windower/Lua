--Copyright (c) 2013, Byrthnoth
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


-- Target Processing --

function valid_target(targ)
	if not spelltarget then spelltarget = {} end
	
	local spell_targ
	if st_targs:contains(targ) then
		st_flag = true
		spell_targ = nil
	elseif st_flag then
		st_flag = false
		spell_targ = nil
	elseif pass_through_targs:contains(targ) then
		local j = windower.ffxi.get_mob_by_target(targ)
		
		if j == nil then
			table.reassign(spelltarget,target)
		else
			table.reassign(spelltarget,target_type(j))
		end
		spelltarget.raw = targ
--		add_to_chat(8,'Returning targ! '..targ)
		return targ
	elseif targ then
		local mob_array = windower.ffxi.get_mob_array()
		local lower_targ = targ:lower()
		for i,v in pairs(mob_array) do
			if v['name']:lower()==lower_targ and not v['is_npc'] then
				spell_targ = targ
				table.reassign(spelltarget,target_type(v))
				spelltarget.raw = targ
			elseif tonumber(targ) == v['id'] then
				spell_targ = '<lastst>'
				table.reassign(spelltarget,target_type(v))
				spelltarget.raw = '<lastst>'
			end
		end
	end
	return spell_targ
end

function target_type(mob_table)
	if mob_table == nil then return end
	
	
	------------------------------- Should consider moving the partycount part of this code to refresh_player() ----------------------------------
	mob_table.isallymember = false
	if not mob_table.id then
		mob_table.type = 'NONE'
	else
		local j = windower.ffxi.get_party()
		
		for i,v in pairs(j) do
			if v['mob'] then
				if v['mob']['id'] == mob_table['id'] then
					mob_table.isallymember = true
				end
			end
		end
	------------------------------------------------------------------------------------------------------------------------------------
		
		if player['id'] == mob_table['id'] then
			mob_table.type = 'SELF'
		elseif mob_table['is_npc'] then
			if mob_table['id']%4096>2047 then
				mob_table.type = 'NPC'
			else
				mob_table.type = 'MONSTER'
			end
		else
			mob_table.type = 'PLAYER'
		end
	end
	return mob_table
end