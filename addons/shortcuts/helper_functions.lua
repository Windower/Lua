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


function parse_resources(lines_file)
	local ignore_fields = S{'german','french','japanese','index','fr','frl','de','del','jp','jpl'}
	local completed_table = {}
	local counter = 0
	for i in ipairs(lines_file) do
		local str = tostring(lines_file[i])
		local g,h,typ,key = string.find(str,'<(%w+) id="(%d+)" ')
		if typ == 's' then
			g,h,key = string.find(str,'index="(%d+)" ')
		end
		if key ~=nil then
			completed_table[tonumber(key)]={}
			local q = 1
			while q <= str:len() do
				local a,b,ind,val = string.find(str,'(%w+)="([^"]+)"',q)
				if ind~=nil then
					if not ignore_fields[ind] then
						if val == "true" or val == "false" then
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
			local k,v,english = string.find(str,'>([^<]+)</')
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

function split(msg, match)
	local length = msg:len()
	local splitarr = T{}
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

function strip(name)
	return name:gsub('4','iv'):gsub('3','iii'):gsub('2','ii'):gsub('1','i'):gsub('8','viii'):gsub('7','vii'):gsub('6','vi'):gsub('5','v'):gsub('[^%a]',''):lower()
end

