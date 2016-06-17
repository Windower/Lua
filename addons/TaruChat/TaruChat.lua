--Copyright © 2016, geno3302
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of TaruChat nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL geno3302 BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'TaruChat'
_addon.author = 'Genoxd'
_addon.version = '1.0.0.0'
_addon.commands = {'taru', 'a'}

socket = require('socket')
connected_socket = nil
try_wrapper = nil
try_error_handler = nil
try_read = nil
server_ip_address = "50.62.22.125" --Please don't mess with my server :)
server_port = 4242
game_server_id = 0
character_name = nil
frame_count = 0

windower.register_event("load", function()
    character_name = windower.ffxi.get_player().name
    game_server_id = windower.ffxi.get_info()['server']
    init_udp()
    if character_name ~= nil and character_name ~= "" then
        connected_socket:send('CMD::rgistr::'..character_name..'::'..tostring(game_server_id))
    end
end)

windower.register_event("unload", function()
    connected_socket:send('CMD::unrgistr::'..character_name..'::'..tostring(game_server_id))
    connected_socket:close()
end)

windower.register_event("login", function(name)
    character_name = windower.ffxi.get_player().name
    game_server_id = windower.ffxi.get_info()['server']
    connected_socket:send('CMD::rgistr::'..character_name..'::'..tostring(game_server_id))
end)

windower.register_event("logout", function(name)
    connected_socket:send('CMD::unrgistr::'..character_name..'::'..tostring(game_server_id))
    game_server_id = 0
    character_name = ""
end)

function init_udp()
    connected_socket = socket.udp()
    connected_socket:setpeername(server_ip_address, server_port)
    connected_socket:settimeout(0) --for non-blocking receive
end

windower.register_event("prerender", function()
    if(game_server_id == 0) then return end
    frame_count = frame_count + 1
    if((frame_count % 300) == 0) then
        connected_socket:send('CMD::hbeat::'..character_name..'::'..tostring(game_server_id))
        frame_count = 0
    end
    local data = connected_socket:receive()
    if(data ~= nil) then
        if windower.wc_match(data, "Registered") then
            windower.add_to_chat(10, "Registered, adding channels...")
            connected_socket:send('CMD::addch::'..character_name..'::TaruChat'..tostring(game_server_id)..'::TaruChat')
            --auto translate and jis logic done with help from Byrth
        elseif #data < #character_name+1 or not (data:sub(2,1+#character_name)==character_name) then
            windower.add_to_chat(10, windower.to_shift_jis(tostring(data)))
        end
        data = nil
    end
end)

windower.register_event("outgoing text",function(original,modified,blocked)
--text outgoing text function done with help from Byrth
    if #modified > 3 and modified:sub(1,3) == '/a ' then
        send_message(modified:sub(4))
        return true
    elseif #modified > 6 and modified:sub(1,6) == '/taru ' then
        send_message(modified:sub(7))
        return true
    end
end)

windower.register_event('addon command', function(...)
--addon command logic cleaned up by Byrth
    local args = {...}
    local command = args[1]:lower()
    if command and command == 'help' then
        windower.add_to_chat(2, 'Use "/a" or "/taru" to talk in the channel. Use "//taru chcount" to see how many people are online. Use "//taru who" to see online users.')
    elseif command and command == 'chcount' then
        connected_socket:send('CMD::chcount::TaruChat'..tostring(game_server_id))
    elseif command and command == 'who' then
        connected_socket:send('CMD::who::TaruChat'..tostring(game_server_id))
    elseif #args > 0 then
        local msg = table.concat(args,' ')
        send_message(msg)
    end
end)

function send_message(msg)
    connected_socket:send('MSG::TaruChat'..tostring(game_server_id)..'::TaruChat::'..tostring(game_server_id)..'::'..character_name..'::'..windower.from_shift_jis(windower.convert_auto_trans(msg)))
    --auto translate and jis logic done with help from Byrth
    windower.add_to_chat(2,'('..character_name..')'..' '..windower.convert_auto_trans(msg))
end