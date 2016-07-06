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

_addon.version = '0.5'
_addon.name = 'MacroPolo'
_addon.author = 'Omnys@Valefor'
_addon.commands = {'macropolo','mp'}

require('strings')
require('tables')
require('logger')

mHistory = {}

windower.register_event('outgoing text',function(original,modified)
	if windower.regex.match(original,"^/macro(polo)? [0-9]+[-][0-9]+ [0-9]+[-][0-9]+") then
		local coms = split(string.lower(original)," ")
		if windower.regex.match(coms[2],"[0-9]+[-][0-9]+") and windower.regex.match(coms[3],"[0-9]+[-][0-9]+") then
			local pos2 = split(coms[2],"-")
			local pos3 = split(coms[3],"-")
			windower.send_command("input /macro book "..pos3[1].."; input /macro set "..pos3[2])
			mHistory[#mHistory+1] = {pos2[1],pos2[2]}
			return ""
		end
	elseif original == "/macro back" or original == "/macropolo back" then
		windower.send_command("input /macro book "..mHistory[#mHistory][1].."; input /macro set "..mHistory[#mHistory][2])
		-- if #mHistory then
			-- table.remove(mHistory) -- doesn't eally seem necessary to remove the most recent macro position
		-- end
		return ""
	end
end)

windower.register_event('addon command', function(...)
    local args    = T{...}:map(string.lower)
    if args[1] == nil or args[1] == "help" then
		log("MacroPolo is a macro management addon that")
		log("enables the use of a single 'back' command")
		log("thus allowing shared sets across different")
		log("macro books.")
		log("")
		log("Usage: /macropolo [current_book]-[current_set] [destination_book] [destination_set]")
		log("/macro prefix also works")
		log("Example: '/macro 3-1 1-5': records the")
		log("current macro position, as book 3 set 1")
		log("and then effectively executes:")
		log("  /macro book 1")
		log("  /macro set 5")
		log("")
		log("You may then use '/macro back' or ")
		log("'/macropolo back' to return to the")
		log("previous book and set.")
	end
end)

--This function was made by Byrth. It's used to split strings
--at a specific character and store them in a table
function split(msg, match)
    if msg == nil then return '' end
    local length = msg:len()
    local splitarr = {}
    local u = 1
    while u <= length do
        local nextanch = msg:find(match,u)
        if nextanch ~= nil then
            splitarr[#splitarr+1] = msg:sub(u,nextanch-match:len())
            if nextanch~=length then
                u = nextanch+match:len()
            else
                u = length
            end
        else
            splitarr[#splitarr+1] = msg:sub(u,length)
            u = length+1
        end
    end
    return splitarr
end
