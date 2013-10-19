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

_addon = {}
_addon.name = 'Cancel'
_addon.version = '0.5'
_addon.author = 'Byrth'
_addon.commands = {'cancel'}

file = require 'filehelper'

statusFile = file.new('../../plugins/resources/status.xml')

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
	local ignore_fields = {['duration']=true,['de']=true,['fr']=true,['jp']=true,['enLog']=true}
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
--Name: strip()
--Args:
---- name (string): Name to be slugged
-----------------------------------------------------------------------------------
--Returns:
---- string with a gsubbed version of name that removes non-letter/numbers and
-------- forces it to lower case.
-----------------------------------------------------------------------------------
function strip(name)
	return name:gsub('[^%a]',''):lower()
end

statuses = parse_resources(statusFile:readlines())
name_index = {}
language = 'english' --get_ffxi_info().language

for i,v in pairs(statuses) do
	local stripped = strip(v.english)
	if name_index[stripped] then
		if type(name_index[stripped]) == 'table' then
			name_index[stripped][#name_index[stripped]+1] = tonumber(i)
		else
			local tempval = name_index[stripped]
			name_index[stripped] = {tempval,tonumber(i)}
		end
	else
		name_index[strip(v.english)] = tonumber(i) -- Need to add something to deal with ambiguous cases
	end
end


windower.register_event('addon command',function (...)
	local command = table.concat({...},' ')
	local status_id = tonumber(command) or name_index[strip(command)]
	if not status_id then return end
	
	local buffs = get_player().buffs
	
	for _,v in pairs(buffs) do
		if type(status_id) == 'table' then
			for _,m in pairs(status_id) do
				if v == m then
					cancel(v)
					return
				end
			end
		elseif status_id == v then
			cancel(status_id)
			return
		end
	end
	
	add_to_chat(123,'Cancel: Status '..statuses[status_id].english..' not found active in your buff list.')
end)

function cancel(id)
	if id > 255 then
		windower.packets.inject_outgoing(0x0F1,string.char(id%256,math.floor(id/256),0,0) -- Inject the cancel packet
	else
		windower.packets.inject_outgoing(0x0F1,string.char(id,0,0,0)) -- Inject the cancel packet
	end
end