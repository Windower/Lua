--Copyright (c) 2015, Byrthnoth
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

_addon.name = 'instaLS'
_addon.version = 0.150221
_addon.author = 'Byrth'

l_time = os.time()

windower.register_event('zone change',function()
    l_time = os.time()
end)

windower.register_event('outgoing text',function(org,mod,bool)
    if bool or os.time() - l_time > 10 then return end
    local chatmode,message
    if mod:sub(1,3) == '/l ' then
        chatmode = 0x05
        message = mod:sub(4)
    elseif mod:sub(1,11) == '/linkshell ' then
        chatmode = 0x05
        message = mod:sub(12)
    elseif mod:sub(1,4) == '/l2 ' then
        chatmode = 0x1B
        message = mod:sub(5)
    elseif mod:sub(1,12) == '/linkshell2 ' then
        chatmode = 0x1B
        message = mod:sub(13)
    end
    
    if chatmode and message ~= '' then
        local length = math.floor((string.len(message)+6)/4)+1
        local padrep = 4-(string.len(message)+6)%4
        local packet = string.char(0xB5,length*2,0,0,chatmode,0)..message..string.rep(string.char(0),padrep)
        -- Packet requires the string to be null terminated (or the last byte will be dropped).
        windower.packets.inject_outgoing(0xB5,packet)
        windower.add_to_chat(chatmode == 0x05 and 6 or chatmode == 0x1B and 213,'['..(chatmode == 0x05 and '1' or chatmode == 0x1B and '2')..']<'..windower.ffxi.get_player().name..'> '..message)
        return true
    end
end)