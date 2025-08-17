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
_addon.version = 0.250421
_addon.author = 'Byrth'

linkshell_inventories_loaded = true
queue = {}
require('strings')
bit = require 'bit'

dbg = nil

function translate_escape(str)
    return str:escape():gsub(string.char(0xFD)..".-"..string.char(0xFD),string.char(0xEF,0x27).."(.-)"..string.char(0xEF,0x25,0x25,0x28))
end

windower.register_event('zone change',function()
    linkshell_inventories_loaded = false
end)

windower.register_event('incoming chunk', function(id,org)
    if not linkshell_inventories_loaded and id == 0x01D then
        linkshell_inventories_loaded = bit.band(org:byte(0x09), 225) == 225
    end
end)

windower.register_event('outgoing chunk',function(id,org,mod,inj)
    if id == 0xB5 and not inj and mod:byte(5) == 0 and #queue > 0 then
        local pop_index, outpack = nil, nil
        local msg = org:sub(6)
        for i, v in pairs(queue) do
            -- Not injected, message currently queued
            if string.find(msg, v.message) and v.status ~= "sent" then
                outpack = mod:sub(1,4)..string.char(v.chatmode)..mod:sub(6)
                if v.status == "seen" then
                    pop_index = i
                else
                    v.status = "sent"
                end
                break
            end
        end
        if pop_index then
            table.remove(queue, pop_index)
        end
        if outpack then
            return outpack
        end
    end
end)

windower.register_event('incoming text',function(org, mod, original_mode, modified_mode, blocked)
    if #queue > 0 and original_mode == 1 then
        local player = windower.ffxi.get_player()
        if not player or not player.name then
            return
        end
        local a,b = string.find(mod,player.name)
        if a == nil then
            return
        end
        local pop_index, retarr = nil, nil
        for i,v in pairs(queue) do
            if string.find(org,translate_escape(v.message)) and v.status ~= "seen" then
                local box = '['..(v.chatcolor==6 and '1' or '2')..']<'
                if dbg and string.find(mod:sub(1,a-1), box) then
                    print("instaLS detected a queued message that already has a linkshell box")
                end
                mod = mod:sub(1,a-1)..box..mod:sub(a,b)..'>'..mod:sub(b+3)
                retarr = {mod, v.chatcolor}
                if v.status == "sent" then
                    pop_index = i
                else
                    v.status = "seen"
                end
                break
            end
        end
        if pop_index then
            table.remove(queue, pop_index)
        end
        if retarr then
            return unpack(retarr)
        end
    end
end)

windower.register_event('outgoing text',function(org, mod, blocked)
    if blocked or linkshell_inventories_loaded then return end
    local message
    if mod:sub(1,3) == '/l ' then
        message = mod:sub(4)
        queue[#queue+1] = {
            chatmode = 0x05,
            chatcolor = 6,
            message = message,
            status = "queued",
        }
    elseif mod:sub(1,11) == '/linkshell ' then
        message = mod:sub(12)
        queue[#queue+1] = {
            chatmode = 0x05,
            chatcolor = 6,
            message = message,
            status = "queued",
        }
    elseif mod:sub(1,4) == '/l2 ' then
        message = mod:sub(5)
        queue[#queue+1] = {
            chatmode = 0x1B,
            chatcolor = 213,
            message = message,
            status = "queued",
        }
    elseif mod:sub(1,12) == '/linkshell2 ' then
        message = mod:sub(13)
        queue[#queue+1] = {
            chatmode = 0x1B,
            chatcolor = 213,
            message = message,
            status = "queued",
        }
    else
        return
    end
    return '/s '..message
end)
