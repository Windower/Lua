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
	local ignore_fields = {german=true,french=true,japanese=true,fr=true,frl=true,de=true,del=true,jp=true,jpl=true}
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
						elseif tonumber(val) then
							completed_table[tonumber(key)][ind] = tonumber(val)
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
--Name: find_san()
--Args:
---- input (string) - Value that might be true or false
-----------------------------------------------------------------------------------
--Returns:
---- boolean or nil. Defaults to nil if input is not true or false.
-----------------------------------------------------------------------------------
function find_san(str)
	if #str == 0 then return str end
	local op,cl,opadd,last = 0,0,1
	for i=1,#str do
		local ch = str:byte(i)
		if ch == 0x5B then
			op = op +1
			opadd = i
		elseif ch == 0x5D then
			cl = cl + 1
		end
	end
	if op > cl then
		if opadd~= #str then
			str = str..string.char(0x5D)
		else
			str = str..str.char(0x7,0x5D)
		end		-- Close captures
	end
	return str
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
			splitarr[#splitarr+1] = msg:sub(u,nextanch-1)
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
---- string with a gsubbed version of name that removes non-alphanumeric characters,
-------- forces the string to lower-case, and converts numbers to Roman numerals,
-------- which are upper case.
-----------------------------------------------------------------------------------
function strip(name)
	return name:gsub('[^%w]',''):lower():gsub('(%d+)',to_roman)
end


-----------------------------------------------------------------------------------
--Name: to_roman()
--Args:
---- num (string or number): Number to be converted from Arabic to Roman numerals.
-----------------------------------------------------------------------------------
--Returns:
---- roman numerals that represent the passed number.
-------- This function returns ix for 9 instead of viiii. They are both valid, but
-------- FFXI uses the ix nomenclature so we will use that.
-----------------------------------------------------------------------------------
function to_roman(num)
	if type(num) ~= 'number' then
		num = tonumber(num)
		if num == nil then
			print('Debug to_roman')
			return ''
		end
	end
	if num>4599 then return tostring(num) end
	
	local retstr = ''
	
	if num == 0 then return 'zilch' end
	if num == 1 then return '' end
	
	while num > 0 do
		if num >= 1000 then
			num = num - 1000
			retstr = retstr..'m'
		elseif num >= 900 then
			num = num - 900
			retstr = retstr..'cm'
		elseif num >= 500 then
			num = num - 500
			retstr = retstr..'d'
		elseif num >= 400 then
			num = num - 400
			retstr = retstr..'cd'
		elseif num  >= 100 then
			num = num - 100
			retstr = retstr..'c'
		elseif num >= 90 then
			num = num - 90
			retstr = retstr..'xc'
		elseif num >= 50 then
			num = num - 50
			retstr = retstr..'l'
		elseif num >= 40 then
			num = num - 40
			retstr = retstr..'xl'
		elseif num >= 10 then
			num = num - 10
			retstr = retstr..'x'
		elseif num == 9 then
			num = num - 9
			retstr = retstr..'ix'
		elseif num >= 5 then
			num = num - 5
			retstr = retstr..'v'
		elseif num == 4 then
			num = num - 4
			retstr = retstr..'iv'
		elseif num >= 1 then
			num = num - 1
			retstr = retstr..'i'
		end
	end
	
	return retstr
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