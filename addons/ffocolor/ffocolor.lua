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


_addon.name = 'FFOColor'
_addon.version = '2.02'
_addon.author = 'Nitrous (Shiva)'
_addon.command = 'ffocolor'

require('tables')
require('strings')
require('logger')
require('lists')
config = require('config')
files = require('files')
chat = require('chat')
defaults = {}

defaults.chatTab = 'say'
defaults.chatColor = 207

settings = config.load(defaults)

chatColors = T{say=1,shout=2,tell=4,party=5,linkshell=6,none=74}

windower.register_event('addon command', function(...)
    local args = {...}
    if args[1] == nil then args[1] = 'help' end
    if args[1] ~= nil then
        comm = args[1]:lower()
        if S{'chattab','chatcolor'}:contains(comm) then
            if comm == 'chatcolor' then
                if args[2] == nil then
                    print('Current Chat Color:', settings.chatColor)
                elseif args[2] >= 1 and args[2] <= 509 then
                    settings.chatColor = tonumber(args[2])
                    print('New Chat Color:', tonumber(args[2]))
                else
                    error('Chat color must be between 1 and 509.')
                end
            elseif comm == 'chattab' then
                if args[2] == nil then
                    print('Current Chat Tab:', settings.chatTab)
                elseif S{'say','shout','linkshell','party','tell','none'}:contains(args[2]:lower()) then
                    settings.chatTab = args[2]:lower()
                    print('New Chat Tab:', args[2]:lower())
                else
                    error('Improper tab selection defaulting to say')
                    settings.chatTab = 'say'
                end
            end
            settings:save()
        elseif comm == 'getcolors' then
            local color_redundant = S{26,33,41,71,72,89,94,109,114,164,173,181,184,186,70,84,104,127,128,129,130,131,132,133,134,135,136,137,138,139,140,64,86,91,106,111,175,178,183,81,101,16,65,87,92,107,112,174,176,182,82,102,67,68,69,170,189,15,208,18,25,32,40,163,185,23,24,27,34,35,42,43,162,165,187,188,30,31,14,205,144,145,146,147,148,149,150,151,152,153,190,13,9,253,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,284,285,286,287,292,293,294,295,300,301,301,303,308,309,310,311,316,317,318,319,324,325,326,327,332,333,334,335,340,341,342,343,344,345,346,347,348,349,350,351,355,357,358,360,361,363,366,369,372,374,375,378,381,384,395,406,409,412,415,416,418,421,424,437,450,453,456,458,459,462,479,490,493,496,499,500,502,505,507,508,10,51,52,55,58,62,66,80,83,85,88,90,93,100,103,105,108,110,113,122,168,169,171,172,177,179,180,12,11,37,291} -- 37 and 291 might be unique colors, but they are not gsubbable.
            local black_colors = S{352,354,356,388,390,400,402,430,432,442,444,472,474,484,486}
            local counter = 0
            local line = ''
            for n = 1, 509 do
                if not color_redundant:contains(n) and not black_colors:contains(n) then
                    if n <= 255 then
                        loc_col = string.char(0x1F, n)
                    else
                        loc_col = string.char(0x1E, n - 254)
                    end
                    line = line..loc_col..string.format('%03d ', n)
                    counter = counter + 1
                end
                if counter == 16 or n == 509 then
                    log(line)
                    counter = 0
                    line = ''
                end
            end
        else
            local helptext = [[FFOColor - Command List:
 1. ffocolor chattab <say/shout/linkshell/party/tell> --Changes the chattab. Default: say.
 2. ffocolor chatcolor <color#> --Changes the highlight color.
 3. ffocolor getcolors -- Show a list of color codes.
 4. ffocolor help --Shows this menu.]]
            for _, line in ipairs(helptext:split('\n')) do
                windower.add_to_chat(207, line..chat.controls.reset)
            end
        end
    end
end)

windower.register_event('incoming text', function(old,new,color,newcolor)
    local stb = string.find(new,'[^%w]*%[%d+:#.-%]') or string.find(new,'^[^%w]*%[FFOChat%]')
    if stb ~= nil or old:sub(2,8) == 'PrivMsg' then
        if settings.chatTab ~= nil then
            newcolor = chatColors[settings.chatTab]
        end
        new = new:gsub('\r',''):gsub('\n','')
        local newsplit = new:split(' ')
        for it = 1, #newsplit do
            newsplit[it] = newsplit[it]:color(settings.chatColor)
        end
        new = newsplit:concat(' ')
        return new, newcolor
    end
end)
