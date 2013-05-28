--Copyright (c) 2013, Thomas Rogers / Balloon - Cerberus
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--   * Neither the name of name nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL THOMAS ROGERS BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

members={}
modmember={}
color={}
config = require 'config'
settings=config.load()

function event_load()
	send_command('alias namelights lua c namelights')
	local colortab = config.load('data/colors.xml',true)
	for i,v in pairs(colortab) do
		color[i]= colconv(v,i)
	end
		for member in pairs(get_party()) do
			members[member] = get_party()[member]['name']
			modmember[member]=color[member]..get_party()[member]['name']..'\x1E\x01'
		end

end

function event_addon_command(...)
    cmd = {...}
	if cmd[1] ~= nil then
		if cmd[1]:lower() == "start" then
			for member in pairs(get_party()) do
				members[member] = get_party()[member]['name']
				modmember[member]=color[member]..get_party()[member]['name']..'\x1E\x01'
			end
		end
	end
end

function event_incoming_text(original, modified, color)
	for names in modified:gmatch('([%w]+)') do
        for name in pairs(members) do
			if original:lower():gmatch('.*'..members[name]) then
				modified = modified:gsub(members[name], modmember[name]):gsub(members[name]:lower(), modmember[name]):gsub(members[name]:upper(), modmember[name])
			end
        end
	end
	return modified
end

function colconv(str,key)
	-- Used in the options_load() function. Taken from Battlemod
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
	
function event_incoming_chunk(id, data)
	if id == 221 then
		modmember={}
		members={}
		send_command('wait 0.1; namelights start')
	end
end