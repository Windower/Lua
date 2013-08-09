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


-----------------------------------------------------------------------------------
--Name: parse_resources()
--Args:
---- lines_file (table of strings) - Table loaded with readlines() from an opened file
-----------------------------------------------------------------------------------
--Returns:
---- Table of subtables indexed by their id (or index).
---- Subtables contain the child text nodes/attributes of each resources line.
----
---- Child text nodes are given the key "english".
---- Attributes keyed by the attribute name, for example:
---- <a id="1500" a="1" b="5" c="10">15</a>
---- turns into:
---- completed_table[1500]['a']==1
---- completed_table[1500]['b']==5
---- completed_table[1500]['c']==10
---- completed_table[1500]['english']==15
----
---- There is also currently a field blacklist (ignore_fields) for the sake of memory bloat.
-----------------------------------------------------------------------------------
function parse_resources(lines_file)
	local ignore_fields = S{'german','french','japanese','index','fr','frl','de','del','jp','jpl'}
	local completed_table = {}
	for i in ipairs(lines_file) do
		local str = tostring(lines_file[i])
		local g,h,typ,key = string.find(str,'<(%w+) id="(%d+)" ')
		if typ == 's' then -- Packets and .dats refer to the spell index instead of ID
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
			local k,v,english = string.find(str,'>([^<]+)</') -- Look for a Child Text Node
			if english~=nil then -- key it to 'english' if it exists
				completed_table[tonumber(key)]['english']=english
			end
		end
	end

	return completed_table
end

-----------------------------------------------------------------------------------
--Name: str2bool()
--Args:
---- input (string) - Value that might be true or false
-----------------------------------------------------------------------------------
--Returns:
---- boolean or nil. Defaults to nil if input is not true or false.
-----------------------------------------------------------------------------------
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

-----------------------------------------------------------------------------------
--Name: split()
--Args:
---- msg (string): message to be subdivided
---- match (string/char): marker for subdivision
-----------------------------------------------------------------------------------
--Returns:
---- Table containing string(s)
-----------------------------------------------------------------------------------
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

-----------------------------------------------------------------------------------
--Name: strip()
--Args:
---- name (string): Name to be slugged
-----------------------------------------------------------------------------------
--Returns:
---- string with a gsubbed version of name that converts numbers to Roman numerals
-------- removes non-letter/numbers, and forces it to lower case.
-----------------------------------------------------------------------------------
function strip(name)
	return name:gsub('4','iv'):gsub('9','ix'):gsub('0','p'):gsub('3','iii'):gsub('2','ii'):gsub('1','i'):gsub('8','viii'):gsub('7','vii'):gsub('6','vi'):gsub('5','v'):gsub('[^%a]',''):lower()
end

-----------------------------------------------------------------------------------
--Name: percent_strip()
--Args:
---- line (string): string to be checked for % signs and stripped
-----------------------------------------------------------------------------------
--Returns:
---- line, without any trailing %s.
-----------------------------------------------------------------------------------
function percent_strip(line)
	local line_len = #line
	while line:byte(line_len) == 37 do
		line = line:sub(1,line_len-1)
		line_len = line_len -1
	end
	return line
end