--[[
chatLink v1.20130527

Copyright (c) 2013, Giuliano Riccio
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of chatLink nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Giuliano Riccio BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

require 'stringhelper'

local chatLink = {}
chatLink.links = {}

function event_load()
    send_command('alias chatlink lua c chatlink')
    send_command('alias clink lua c chatlink')
end

function event_unload()
    send_command('alias chatlink lua c chatlink')
    send_command('alias clink lua c chatlink')
end

function event_incoming_text(original, modified, mode)
    for link in modified:gmatch('([hH][tT][tT][pP][sS]?://%w[%.%w]*%w[^%s]*)') do
        table.insert(chatLink.links, link)

        modified = modified:gsub(link:escape(link), '['..(#chatLink.links)..']'..link, 1)
    end
    
    return modified
end

function event_addon_command(...)
    local args = {...}

    if #args == 0 then
        add_to_chat(55,'lua:addon:chatLink >> copies or opens a link found in the chat. if not specified, "open" will be assumed.')
        add_to_chat(55,'lua:addon:chatLink >> usage: clink [{copy|open}] \30\02number\30\01')
        add_to_chat(55,'lua:addon:chatLink >> positional arguments:')
        add_to_chat(55,'lua:addon:chatLink >>   copy    copies the link to the clipboard')
        add_to_chat(55,'lua:addon:chatLink >>   open    opens the link in the default browser')
        add_to_chat(55,'lua:addon:chatLink >>   number  the number associated to the link')
        
        return
    end
    
    local command = 'open'
    local linkNumber

    if args[1] == 'copy' then
        command = 'copy'
        linkNumber = tonumber(args[2], 10)
    elseif args[1] == 'open' then 
        linkNumber = tonumber(args[2], 10)    
    else
        linkNumber = tonumber(args[1], 10)
    end

    if linkNumber == nil then
        add_to_chat(38, 'lua:addon:chatLink >> you must specify the link number')
            
        return
    end
    
    if linkNumber > #chatLink.links then
        add_to_chat(38,'lua:addon:chatLink >> the link number '..linkNumber..' doesn\'t exist')
            
        return
    end

    if command == 'copy' then
        --clipboard(chatLink.links[linkNumber])
    elseif command == 'open' then
        open_url(chatLink.links[linkNumber])
    end
end