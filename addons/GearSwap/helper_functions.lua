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
	local find = string.find
	local ignore_fields = {index=true}
	local convert_fields = {enl='english_log',fr='french',frl='french_log',de='german',del='german_log',jp='japanese',jpl='japanese_log'}
	local hex_fields = {jobs=true,races=true,slots=true}
	
	local completed_table = {}
	for i in ipairs(lines_file) do
		local str = tostring(lines_file[i])
		local g,h,typ,key = find(str,'<(%w+) id="(%d+)" ')
		if typ == 's' then -- Packets and .dats refer to the spell index instead of ID
			g,h,key = find(str,'index="(%d+)" ')
		end
		if key~=nil then
			completed_table[tonumber(key)]={}
			local q = 1
			while q <= str:len() do
				local a,b,ind,val = find(str,'(%w+)="([^"]+)"',q)
				if ind~=nil then
					if not ignore_fields[ind] then
						if convert_fields[ind] then
							ind = convert_fields[ind]
						end
						if val == "true" or val == "false" then
							completed_table[tonumber(key)][ind] = str2bool(val)
						elseif hex_fields[ind] then
							completed_table[tonumber(key)][ind] = tonumber('0x'..val)
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
			local k,v,english = find(str,'>([^<]+)</') -- Look for a Child Text Node
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
--Name: Dec2Hex()  -- From Nitrous
--Args:
---- nValue (string or number): Value to be converted to hex
-----------------------------------------------------------------------------------
--Returns:
---- String version of the hex value.
-----------------------------------------------------------------------------------
function Dec2Hex(nValue)
	if type(nValue) == "string" then
		nValue = tonumber(nValue);
	end
	nHexVal = string.format("%X", nValue);  -- %X returns uppercase hex, %x gives lowercase letters
	sHexVal = nHexVal.."";
	return sHexVal;
end

-----------------------------------------------------------------------------------
--Name: split()
--Args:
---- msg (string): message to be subdivided
---- delim (string/char): marker for subdivision
-----------------------------------------------------------------------------------
--Returns:
---- Table containing string(s)
-----------------------------------------------------------------------------------
function split(msg, delim)
	local result = T{}

	-- If no delimiter specified, just extract alphabetic words
	if not delim or delim == '' then
		for word in msg:gmatch("%a+") do
			result[#result+1] = word
		end
	else
		-- If the delimiter isn't in the message, just return the whole message
		if string.find(msg, delim) == nil then
			result[1] = msg
		else
			-- Otherwise use a capture pattern based on the delimiter to
			-- extract text chunks.
			local pat = "(.-)" .. delim .. "()"
			local lastPos
			for part, pos in msg:gmatch(pat) do
				result[#result+1] = part
				lastPos = pos
			end
			-- Handle the last field
			if #msg > lastPos then
				result[#result+1] = msg:sub(lastPos)
			end
		end
	end
	
	return result
end

-----------------------------------------------------------------------------------
--Name: fieldsearch()
--Args:
---- message (string): Message to be searched
-----------------------------------------------------------------------------------
--Returns:
---- Table of strings that contained {something}.
---- Seems to be trying to exclude ${actor} and ${target}, but not.
-----------------------------------------------------------------------------------
function fieldsearch(message)
	fieldarr = {}
	string.gsub(message,"{(.-)}", function(a) if a ~= '${actor}' and a ~= '${target}' then fieldarr[#fieldarr+1] = a end end)
	return fieldarr
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
--Name: table.reassign()
--Args:
---- targ (table): Table to be replaced
---- new (table): Table with values to transfer to the targ table
-----------------------------------------------------------------------------------
--Returns:
---- targ (table)
---- The "targ" table is blanked, and then the values from "new" are assigned to it
---- In the event that new is not passed, targ is not filled with anything.
-----------------------------------------------------------------------------------
function table.reassign(targ,new,weak)
	if new == nil then new = {} end
	if weak then
		for i,v in pairs(new) do
			if targ[i] == nil then targ[i] = v end
		end
	else
		for i,v in pairs(targ) do
			targ[i] = nil
		end
		for i,v in pairs(new) do
			targ[i] = v
		end
	end
	return targ
end



-----------------------------------------------------------------------------------
--Name: logit()
--Args:
---- logfile (file): File to be logged to
---- str (string): String to be logged.
-----------------------------------------------------------------------------------
--Returns:
---- none
-----------------------------------------------------------------------------------
function logit(file,str)
	file:write(str)
	file:flush()
end


-----------------------------------------------------------------------------------
--Name: user_key_filter()
--Args:
---- val (key): potential key to be modified
-----------------------------------------------------------------------------------
--Returns:
---- Filtered key
-----------------------------------------------------------------------------------
function user_key_filter(val)
	if type(val) == 'string' then
		val = string.lower(val)
	end
	return val
end


-----------------------------------------------------------------------------------
--Name: make_user_table()
--Args:
---- None
-----------------------------------------------------------------------------------
--Returns:
---- Table with case-insensitive keys
-----------------------------------------------------------------------------------
function make_user_table()
	return setmetatable({}, user_data_table)
end


-----------------------------------------------------------------------------------
--Name: get_bit_packed(dat_string,start,stop)
--Args:
---- dat_string - string that is being bit-unpacked to a number
---- start - first bit
---- stop - last bit
-----------------------------------------------------------------------------------
--Returns:
---- number from the indicated range of bits 
-----------------------------------------------------------------------------------
function get_bit_packed(dat_string,start,stop)
	local newval = 0
	
	local c_count = math.ceil(stop/8)
	while c_count >= math.ceil((start+1)/8) do
		-- Grabs the most significant byte first and works down towards the least significant.
		local cur_val = dat_string:byte(c_count)
		local scal = 256
		
		if c_count == math.ceil(stop/8) then -- Take the least significant bits of the most significant byte
		-- Moduluses by 2^number of bits into the current byte. So 8 bits in would %256, 1 bit in would %2, etc.
		-- Cuts off the top.
			cur_val = cur_val%(2^((stop-1)%8+1)) -- -1 and +1 set the modulus result range from 1 to 8 instead of 0 to 7.
		end
		
		if c_count == math.ceil((start+1)/8) then -- Take the most significant bits of the least significant byte
		-- Divides by the significance of the final bit in the current byte. So 8 bits in would /128, 1 bit in would /1, etc.
		-- Cuts off the bottom.
			cur_val = math.floor(cur_val/(2^(start%8)))
			scal = 2^(8-start%8)
		end
		
		newval = newval*scal + cur_val -- Need to multiply by 2^number of bits in the next byte
		c_count = c_count - 1
	end
	return newval
end


-----------------------------------------------------------------------------------
--Name: get_wearable(player_val,val)
--Args:
---- player_val - Number representing the player's characteristic
---- val - Number representing the item's affinities
-----------------------------------------------------------------------------------
--Returns:
---- True (player_val exists in val) or false (anything else)
-----------------------------------------------------------------------------------
function get_wearable(player_val,val)
	if player_val then
		return ((val%(player_val*2))/player_val >= 1) -- Cut off the bits above it with modulus, then cut off the bits below it with division and >= 1
	else
		return false -- In cases where the provided playervalue is nil, just return false.
	end
end