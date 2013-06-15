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

function valid_target(targ,flag)
	local spell_targ
	if pass_through_targs:contains(targ) then
		return targ
	elseif targ then
		local mob_array = get_mob_array()
		local targar = T{}
		for i,v in pairs(mob_array) do
			if string.find(v['name']:lower(),targ:lower()) then
				-- Handling for whether it's a monster or not
				if v['is_npc'] then
					if not targar:contains('<t>') then
						table.append(targar,'<t>')
					end
				else
					table.append(targar,v['name'])
				end
			elseif tonumber(targ) == v['id'] then
				table.append(targar,'<lastst>')
			end
		end
				
		if flag then
			if targar:contains(targ) then
				spell_targ = targ
			else
				spell_targ = false
			end
		elseif targar then
			if targar:contains(targ) then
				spell_targ = targ
			else
				for i,v in pairs(targar) do
					if v:lower():find('^'..targ:lower()) then
						spell_targ = v
						break
					end
				end
				if not spell_targ then
					spell_targ = targar[1]
				end
			end
		end
	end
	return spell_targ
end

function target_make(targarr)
	local spell_targ = '<me>'
	-- <me>, <t>, <bt>, <ft>, <r>, <ht>, <pet>, <scan>
	-- <p0~5>, <a10~15>, <a20~25>
	-- <st>, <stpt>, <stal>, <stnpc>, <stpc>, <lastst>
	-- http://wiki.ffxiclopedia.org/wiki/Macro#Selecting_a_Target_.28Pronouns.29
	
	local targets = targarr['validtarget']
	if targets['Player'] or targets['Party'] or targets['Ally'] or targets['Enemy'] or targets['NPC'] then
		spell_targ = '<t>'
	elseif targets['Self'] then
		spell_targ = '<me>'
	end

	return spell_targ
end