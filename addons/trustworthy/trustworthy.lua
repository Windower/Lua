--[[
Copyright © 2016, Omnys of Valefor
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of Trustworthy nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL OMNYS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'Trustworthy'
_addon.version = '0.1'
_addon.author = 'Omnys@Valefor'
_addon.commands = {'trustworthy','tw'}

res = require('resources')
require('logger')

spells = res.spells
trusts = S(res.spells:type('Trust'):map(table.get-{'name'}))
MyTrusts = {}
known = {}

function establishTrusts()
    known = windower.ffxi.get_spells()

    MyTrusts = T{}
    for k, v in pairs(known) do
        if spells[k] then 
            MyTrusts[string.lower(spells[k].english)] = v
        end
    end
end
establishTrusts()

windower.register_event('zone change',function()
    -- Get Trust list again in case ciphers were learned, makes searches accurate
    establishTrusts:schedule(10)
end)

windower.register_event('addon command', function(...)
    local args = T{...}:map(string.lower)
    local cmd = table.concat(args," ")
    if args[1] == nil or args[1] == "help" then
        log("Type //tw [partial trust name]")
    elseif (args[1] == "find" or args[1] == "search") and #args > 1 then
        cmd = windower.regex.replace(cmd,"^"..args[1].." ","")
        local found = 0
        log("Trusts matching '"..cmd.."'.")
        for k, v in pairs(MyTrusts) do
            if string.find(k,string.lower(cmd)) then
                if v then
                    windower.add_to_chat(255,"    You already have "..string.upper(k)..".")
                else
                    windower.add_to_chat(167,"    You do not have "..string.upper(k)..".")
                end
            end
        end
    end
end)
