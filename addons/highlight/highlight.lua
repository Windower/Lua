file = require 'filehelper'
chat = require 'chat'
require 'tablehelper'
require 'stringhelper'
 
_addon = {}
_addon.author = 'Balloon'
_addon.name = 'Highlight'
_addon.version = '1.0' 
_addon.command = 'highlight'
 
members={}
mulenames={}
modmember={}
nicknames={}
color={}
mulecolor={}
previousmentions={}
 
config = require 'config'
 
defaults = {}
defaults.p0 = 501
defaults.p1 = 204
defaults.p2 = 410
defaults.p3 = 492
defaults.p4 = 259
defaults.p5 = 260
defaults.a10 = 205
defaults.a11 = 359
defaults.a12 = 167
defaults.a13 = 038
defaults.a14 = 125
defaults.a15 = 185
defaults.a20 = 429
defaults.a21 = 257
defaults.a22 = 200
defaults.a23 = 481
defaults.a24 = 483
defaults.a25 = 208
 
settingdefaults = {}
settingdefaults.highlighting = true
 
settings = config.load(settingdefaults)
if file.exists('../battlemod/data/colors.xml') then
    color = config.load('../battlemod/data/colors.xml')
    print('Colors loaded from battlemod')
else
    color = config.load('/data/colors.xml', defaults)
end
 
windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'help'
    args = {...}
 
    if command == 'write' then
        io.open(lua_base_path..'/logs/'..player..'.txt',"a"):write('\n =='..string.sub(os.date(), 0, 8)..'== \n'..table.concat(previousmentions, '\n')):close()
 
    elseif command == 'view' then
        if not args[1] then 
            add_to_chat(4, "==Recent Mentions==")
            if #previousmentions > 20 then
                for i = 1, 20 do
                    add_to_chat(4, previousmentions[i])
                end
            else 
                for i = 1, #previousmentions do
                    add_to_chat(4, previousmentions[i])
                end
            end
 
        else
            if tonumber(args[1]) > #previousmentions then
                print('Not that many mentions, type //highlight view to show them all')
            else
                add_to_chat(4, '==Last '..args[1]..' Mentions==')
                for i = 1, tonumber(args[1]) do
                    add_to_chat(4, previousmentions[i])
                end
            end
        end
 
    elseif command == 'help' then
        print('To view your last mentions type //highlight view <last number>')
    end
end)
 
windower.register_event('load', 'login', send_command+{'wait 2; lua i highlight initialize'})
 
function initialize()
    send_count = 0 
    called_count = 0
 
    nicknames = config.load('/data/nicknames.xml')
    mules = config.load('/data/mules.xml')
    settings = config.load(settingdefaults)
 
    for i, v in pairs(nicknames) do
        nicknames[i] = string.split(v, ',')
    end
    for mule, name in pairs(mules) do
        mulenames[mule] = name
    end
    for i, v in pairs(color) do
        color[i] = colconv(v,i)
    end
    for i, v in pairs(mules) do
        mulecolor[i] = colconv(v,i)
    end
 
    player = windower.ffxi.get_player().name
 
    get_party_members()
end
 
windower.register_event('incoming text', function(original, modified, color)
    if not original:match('%[.*%] .* '..string.char(129, 168)..'.*') and not original:match('.* '..chat.chars['implies']..'.*') then
        for names in modified:gmatch('%w+') do
            for name in pairs(members) do
                modified = modified:igsub(members[name], modmember[name])
            end
            for k,v in pairs(nicknames) do
                for z = 1, #v do    
                    modified = modified:igsub('([^%a])'..nicknames[k][z]..'([^%a])', function (pre, app) return pre..k:capitalize()..app end):igsub('([^%a])'..nicknames[k][z]..'$', function(space) return space..k:capitalize() end)
                end
            end
            for mule, color in pairs(mulenames) do
                modified = modified:igsub(mule, mulecolor[mule]..mule:capitalize()..chat.colorcontrols.reset)
            end
            if not settings.highlighting then
                modified = modified:gsub('%(['..string.char(0x1e, 0x1f)..'].(%w+)'..'['..string.char(0x1e, 0x1f)..'].%)(.*)', function(name, rest) return '('..name..')'..rest end)            
                modified = modified:gsub('<['..string.char(0x1e, 0x1f)..'].(%w+)'..'['..string.char(0x1e, 0x1f)..'].>(.*)', function(name, rest) return '<'..name..'>'..rest end)    
            end
        end
 
    end
        --Not rolltracker and not battlemod
        if not original:match('.* '..string.char(129, 168)..'.*') and not original:match('.* '..chat.chars['implies']..'.*') and color ~= 4 then
            --Chat modes not empty
            if original:match('^%(.*%)') or original:match('^<.*>') or original:match('^%[%d:#%w+%]%w+(%[?%w-%]?):') then
                --Not myself
                if not original:match('^%('..player..'%)') and not original:match('^<'..player..'>') and not original:match('^'..player..' :') and not original:match('^%[%d:#%w+%]'..player..'(%[?%w-%]?):') then
                    if modified:match(player) then
                        table.insert(previousmentions, 1, '['..string.sub(os.date(), 10).."]>> "..colconv(color)..original    )
                    end
                end
            end
        end
 
    return modified
end)
 
windower.register_event('incoming chunk', function(id, data)
    if id == 0x0C8 then
        modmember = {}
        members = {}
        send_command('@wait 0.1; lua i highlight get_party_members')
    end
end)
 
function colconv(str, key)
    -- Taken from Battlemod
    strnum = tonumber(str)
    if strnum >= 256 and strnum < 509 then
        return string.char(0x1E, strnum - 254)
    elseif strnum > 0 then
        return string.char(0x1F, strnum)
    elseif strnum ~= 0 then
        print('You have an invalid color '..key)
    end
    return chat.colorcontrols.reset
end
 
function get_party_members()
    if settings.highlighting then
        for member, mob in pairs(windower.ffxi.get_party()) do
            if not mulenames[mob['name']:lower()] then
                members[member] = mob['name']
                modmember[member] = color[member]..mob['name']..chat.colorcontrols.reset
            end
        end
    else 
        members['p0'] = player
        modmember['p0'] = color['p0']..player..chat.colorcontrols.reset
    end    
end
 
--[[
Copyright (c) 2013, Thomas Rogers
All rights reserved.
 
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of highlight nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Thomas Rogers BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]