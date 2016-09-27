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
    * Neither the name of MacroPolo nor the
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
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.version = '0.55'
_addon.name = 'MacroPolo'
_addon.author = 'Omnys@Valefor'
_addon.commands = {'macropolo'}

require('tables')
require('logger')

mHistory = {}

function Commander(...)
    local args = T{...}:map(string.lower)
    if args[1] == nil or args[1] == "help" then
        log("Usage: /macropolo [current_book]-[current_set] [destination_book] [destination_set]")
        log("/macropolo back to return to the previous set.")
        log("Please see README.md for more details.")
    elseif args[1] == "back" then
        if #mHistory then
            windower.send_command("input /macro book "..mHistory[#mHistory][1].."; input /macro set "..mHistory[#mHistory][2])
        else
            error("No previous macro location recorded.")
        end
    else
        local argstring = table.concat(args)
        local current_book, current_set, target_book, target_set = argstring:match('(%d+)-(%d+) (%d+)-(%d+)$')
        
        if target_set then
            windower.send_command("input /macro book "..target_book.."; input /macro set "..target_set)
            mHistory[#mHistory+1] = {current_book,current_set}
            return ""
        else
            error('Invalid Command: Syntax should be: /macropolo current_book-current_set target_book-target_set')
            log('See README.md for more details.')
        end
    end
end

windower.register_event('outgoing text', function(original)
    if original:startswith('/macropolo ') then
        Commander(original:sub(tonumber(original:find(" "))))
        return ""
    end
end)

windower.register_event('addon command', Commander)
