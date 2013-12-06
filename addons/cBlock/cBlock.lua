--[[
Copyright (c) 2013, Ricky Gall
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


_addon.name = 'CBlock'
_addon.version = '1.05'

windower.register_event('addon command',function (...)
    local term = table.concat({...}, ' ')
    a,b,block = string.find(term,'ignore (.*)')
    c,d,delete = string.find(term,'delete (.*)')
    if block ~= nil then
        ignore[#ignore+1] = block:lower()
        local f = io.open(settingsFile,'a')
        f:write(block.."\n")
        windower.add_to_chat(55,"No longer seeing "..block.." speak in FFOchat.")
        local q,r = io.close(f)
        if not q then print(r) end
    elseif delete ~= nil then
        for u = 1, #ignore do
            if ignore[u] == delete then
                table.remove(ignore,u)
            end
        end
        windower.add_to_chat(55,"Seeing "..delete.." speak in FFOchat again.")
        local tmp = io.open(settingsPath..'tmp.txt',"w")
        for line in io.lines(settingsFile) do
            if line ~= delete then
                tmp:write(line..'\n')
            end
        end
        local q,w = io.close(tmp)
        if not q then print(w) end
        local r,es = os.rename(settingsFile,settingsPath..'tmp2.txt')
        if not r then print(es) end
        local e,rs = os.rename(settingsPath..'tmp.txt',settingsFile)
        if not e then print(rs) end
        local r,es = os.remove(settingsPath..'tmp2.txt')
        if not r then print(es) end
    end
end)

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then 
        local q,r = io.close(f)
        if not q then print(r) end
        return true 
    else
        return false 
    end
end

windower.register_event('load',function ()
    windower.send_command('alias cBlock lua c cBlock')
    ignore = {}
    settingsPath = windower.addon_path..'data/'
    settingsFile = settingsPath..'blacklist.txt'
    if not file_exists(settingsFile) then 
        local f,err = assert(io.open(settingsPath.."blacklist.txt","w"))
        io.close(f)
    else
        fill_ignore()
    end	
end)

windower.register_event('unload',function ()
    windower.send_command('unalias cblock')
end)

function fill_ignore()
    i = 1
    for line in io.lines(settingsFile) do
        ignore[i] = line
        i = i + 1
    end
end

windower.register_event('incoming text',function (old,new,color)
    for i=1,#ignore do
        c,d,text = string.find(old,'%[%d+:#%w+%](.*):')
        if text ~= nil then
            if text:lower() == ignore[i]:lower() then
                new = ''
            end
        end
    end
    return new, color  -- must be here or errors will be thrown
end)
