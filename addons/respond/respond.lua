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


_addon.name = 'Respond'
_addon.version = '1.2'
_addon.commands = {'r','respond'}

current_mode = '/tell'

windower.register_event('addon command',function(...)
    if current_r then
        windower.send_command('input '..current_mode..' '..current_r..' '..table.concat({...},' '))
    end
end)

windower.register_event('chat message',function (message, player, mode, isGM)
	if mode==3 and (player~=current_r or current_mode ~= '/tell') then
		current_r=player
        current_mode = '/tell'
	end
end)

windower.register_event('incoming text',function (original, modified, color)
	if original:sub(1,4) == '[PM]' then
		a,b = string.find(original,'>>')
		if a~=6 then
			local name = original:sub(6,a-1)
			if name~=current_r or current_mode ~= '/pm' then
				current_r = name
                current_mode = '/pm'
			end
		end
    end
end)