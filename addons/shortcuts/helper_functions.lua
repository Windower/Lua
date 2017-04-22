--Copyright (c) 2014, Byrthnoth
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
--Name: find_san()
--Args:
---- str (string) - string to be sanitized
-----------------------------------------------------------------------------------
--Returns:
---- sanitized string
-----------------------------------------------------------------------------------
function find_san(str)
	if #str == 0 then return str end
	
	str = bracket_closer(str,0x28,0x29)
	str = bracket_closer(str,0x5B,0x5D)
	
	-- strip precentages
	local hanging_percent,num = 0,num
	while str:byte(#str-hanging_percent) == 37 do
		hanging_percent = hanging_percent + 1
	end
	str = str:sub(1,#str-hanging_percent%2)
	return str
end

-----------------------------------------------------------------------------------
--Name: bracket_closer()
--Args:
---- str (string) - string to have its brackets closed
---- opener (number) - opening character's ASCII code
---- closer (number) - closing character's ASCII code
-----------------------------------------------------------------------------------
--Returns:
---- string with its opened brackets closed
-----------------------------------------------------------------------------------
function bracket_closer(str,opener,closer)
	op,cl,opadd = 0,0,1
	for i=1,#str do
		local ch = str:byte(i)
		if ch == opener then
			op = op +1
			opadd = i
		elseif ch == closer then
			cl = cl + 1
		end
	end
	if op > cl then
		if opadd ~= #str then
			str = str..string.char(closer)
		else
			str = str..str.char(0x7,closer)
		end		-- Close captures
	end
	return str
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
--Name: check_usability()
--Args:
---- player (table): get_player() table
---- resource (string): name of the resource to be examined
---- id (num): ID of the spell/ability of interest
-----------------------------------------------------------------------------------
--Returns:
---- boolean : true indicates that the spell/ability is known to you and false indicates that it is not.
-----------------------------------------------------------------------------------
function check_usability(player,resource,id)
    if resource == 'spells' and ( (res.spells[id].levels[player.main_job_id] and res.spells[id].levels[player.main_job_id] <= player.main_job_level) or
      (res.spells[id].levels[player.sub_job_id] and res.spells[id].levels[player.sub_job_id] <= player.sub_job_level) ) then -- Should check to see if you know the spell
        return true
    elseif L(windower.ffxi.get_abilities()[resource] or {}):contains(id) then
        return true
    elseif resource == 'monster_abilities' and player.main_job_id == 23 and (res.monstrosity[windower.ffxi.get_mjob_data().species].tp_moves[id] or 0) <= player.main_job_level then
        return true
    elseif resource == 'mounts' and math.floor((windower.packets.last_incoming(0x0AE):byte(math.floor(id/8)+5)%2^(id%8+1))/2^(id%8)) == 1 then
        return true
    end
end


-----------------------------------------------------------------------------------
--Name: debug_chat()
--Args:
---- str (string): string to be printed to the log
-----------------------------------------------------------------------------------
--Returns:
---- None
-----------------------------------------------------------------------------------
function debug_chat(str)
    if not debugging then return end
    
    if tostring(str) then
        windower.add_to_chat(8,str)
    else
        error('Debug chat is not a string',2)
    end
end