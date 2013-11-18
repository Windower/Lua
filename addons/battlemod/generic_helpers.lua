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

function nf(field,subfield)
	if field ~= nil then
		return field[subfield]
	else
		return nil
	end
end

function split(msg, match)
	if not msg then return {} end
	local length = #msg
	local splitarr = {}
	local u = 1
	while u <= length do
		local nextanch = msg:find(match,u)
		if nextanch ~= nil then
			splitarr[#splitarr+1] = msg:sub(u,nextanch-match:len())
			if nextanch~=length then
				u = nextanch+match:len()
			else
				u = length+1
			end
		else
			splitarr[#splitarr+1] = msg:sub(u,length)
			u = length+1
		end
	end
	return splitarr
end

function parse_resources(lines_file)
	local ignore_fields = {german=true,french=true,japanese=true,index=true,recast=true,fr=true,frl=true,de=true,del=true,jp=true,jpl=true}
	local completed_table = {}
	local counter = 0
	local find = string.find
	for i in ipairs(lines_file) do
		local str = tostring(lines_file[i])
		local g,h,typ,key = find(str,'<(%w+) id="(%d+)" ')
		if typ == 's' then
			g,h,key = find(str,'index="(%d+)" ')
		end
		if key ~=nil then
			completed_table[tonumber(key)]={}
			local q = 1
			while q <= str:len() do
				local a,b,ind,val = find(str,'(%w+)="([^"]+)"',q)
				if ind~=nil then
					if not ignore_fields[ind] then
						if str2bool(val) then
							completed_table[tonumber(key)][ind] = str2bool(val)
						else
							completed_table[tonumber(key)][ind] = val:gsub('&quot;','\42'):gsub('&apos;','\39')
						end
					end
					q = b+1
				else
					q = str:len()+1
				end
			end
			local k,v,english = find(str,'>([^<]+)</')
			if english~=nil then
				completed_table[tonumber(key)]['english']=english
			end
		end
	end

	return completed_table
end

function str2bool(input)
	-- Used in the options_load() function
	if input:lower() == 'true' then
		return true
	elseif input:lower() == 'false' then
		return false
	else
		return nil
	end
end

function bool2str(input)
	if input then
		return 'true'
	end
	return 'false'
end

function flip(p1,p1t,p2,p2t,cond)
	return p2,p2t,p1,p1t,not cond
end

function colconv(str,key)
	-- Used in the options_load() function
	local out
	strnum = tonumber(str)
	if strnum >= 256 and strnum < 509 then
		strnum = strnum - 254
		out = string.char(0x1E,strnum)
	elseif strnum >0 then
		out = string.char(0x1F,strnum)
	elseif strnum == 0 then
		out = rcol
	else
		write('You have an invalid color '..key)
		out = string.char(0x1F,1)
	end
	return out
end


function color_it(to_color,color)
	if not color and debugging then add_to_chat(8,'Color was invalid.') end
	if not color or color == 0 then return to_color end
	
	if to_color then
		local colarr = split(to_color,' ')
		return color..table.concat(colarr,rcol..' '..color)..rcol
	end
end


function conjunctions(pre,post,target_count,current)
	if current < target_count or commamode then
		pre = pre..', '
	else
		if oxford and target_count >2 then
			pre = pre..','
		end
		pre = pre..' and '
	end
	return pre..post
end



function fieldsearch(message)
	local fieldarr = {}
	string.gsub(message,"{(.-)}", function(a) fieldarr[a] = true end)
	return fieldarr
end


function check_filter(actor,target,category,msg)
	-- This determines whether the message should be displayed or filtered
	-- Returns true (don't filter) or false (filter), boolean
	if not actor.filter or not target.filter then return false end
	
	if not filter[actor.filter] and debugging then add_to_chat(8,'Battlemod - Filter Not Recognized: '..tostring(actor.filter)) end
	
	if actor.filter ~= 'monsters' and actor.filter ~= 'enemies' then
		if filter[actor.filter]['all']
		or category == 1 and filter[actor.filter]['melee']
		or category == 2 and filter[actor.filter]['ranged']
		or category == 12 and filter[actor.filter]['ranged']
		or category == 5 and filter[actor.filter]['items']
		or category == 9 and filter[actor.filter]['uses']
		or nf(dialog[msg],'color')=='D' and filter[actor.filter]['damage']
		or nf(dialog[msg],'color')=='M' and filter[actor.filter]['misses']
		or nf(dialog[msg],'color')=='H' and filter[actor.filter]['healing']
		or msg == 43 and filter[actor.filter]['readies'] or msg == 326 and filter[actor.filter]['readies']
		or msg == 3 and filter[actor.filter]['casting'] or msg == 327 and filter[actor.filter]['casting']
		then
			return false
		end
	else
		if filter[actor.filter][target.filter]['all']
		or category == 1 and filter[actor.filter][target.filter]['melee']
		or category == 2 and filter[actor.filter][target.filter]['ranged']
		or category == 12 and filter[actor.filter]['ranged']
		or category == 5 and filter[actor.filter]['items']
		or category == 9 and filter[actor.filter]['uses']
		or nf(dialog[msg],'color')=='D' and filter[actor.filter][target.filter]['damage']
		or nf(dialog[msg],'color')=='M' and filter[actor.filter][target.filter]['misses']
		or nf(dialog[msg],'color')=='H' and filter[actor.filter][target.filter]['healing']
		or msg == 43 and filter[actor.filter][target.filter]['readies'] or msg == 326 and filter[actor.filter][target.filter]['readies']
		or msg == 3 and filter[actor.filter][target.filter]['casting'] or msg == 327 and filter[actor.filter][target.filter]['casting']
		then
			return false
		end
	end

	return true
end