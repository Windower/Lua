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

_addon = {}
_addon.name = 'AEcho'
_addon.version = '2.01'

require 'tablehelper'
require 'stringhelper'
require 'logger'
require 'sets'
local config = require 'config'
local defaults = T{}
defaults.buffs = S{	"light arts","addendum: white","penury","celerity","accession","perpetuance","rapture",
                    "dark arts","addendum: black","parsimony","alacrity","manifestation","ebullience","immanence",
                    "stun","petrified","silence","stun","sleep","slow","paralyze"
                }
defaults.alttrack = true
defaults.sitrack = true



function initialize()
    settings = config.load(defaults)
    settings:save()
    autoecho = true
end

function event_load()
    send_command('alias aecho lua c aecho')
    if get_ffxi_info()['logged_in'] then
        initialize()
    end
end

function event_login()
    initialize()
end

function event_unload()
    send_command('unalias aecho')
end

function event_gain_status(id,name)
    for key,val in pairs(settings.buffs) do
        if key:lower() ==name:lower() then
            if name:lower() == 'silence' and autoecho then
                send_command('input /item "Echo Drops" '..get_player()["name"])
            end
            if settings.alttrack then
                send_command('send @others atc '..get_player()["name"]..' - '..name)
            end
        end
    end
end

function event_incoming_text(old,new,color)
    if settings.sitrack then
        local sta,ea,txt = string.find(new,'The effect of ([%w]+) is about to wear off.')
        if sta ~= nil then 
            send_command('@send @others atc '..get_player()['name']..' - '..txt..' wearing off.')
        end
    end
    return new,color
end
function event_addon_command(...)
    local args = {...}
    if args[1] ~= nil then
        local comm = args[1]:lower()
        if comm == 'help' then
            notice('You have access to the following commands:')
            notice(' 1. aecho watch <buffname> --adds buffname to the tracker')
            notice(' 2. aecho unwatch <buffname> --removes buffname from the tracker')
            notice(' 3. aecho trackalt --Toggles alt buff/debuff messages on main (this requires send addon)')
            notice(' 4. aecho sitrack --When sneak/invis begin wearing passes this message to your alts')
            notice(' 5. aecho list --lists buffs being tracked')
            notice(' 6. aecho toggle --Toggles off automatic echo drop usage (in case you need this off. does not remain off across loads.)')
        elseif S{'watch','trackalt','unwatch','sitrack'}:contains(comm) then
            local list = ''
            local spacer = ''
            if comm == 'watch' then
                for i = 2, #args do
                    if i > 2 then spacer = ' ' end
                    list = list..spacer..args[i]
                end
                if settings.buffs[list] == nil then
                    settings.buffs:add(list:lower())
                    notice(list..' added to buffs list.')
                end
            elseif comm == 'unwatch' then
                for i = 2, #args do
                    if i > 2 then spacer = ' ' end
                    list = list..spacer..args[i]
                end
                if settings.buffs[list] ~= nil then
                    settings.buffs:remove(list:lower())
                    notice(list..' removed from buffs list.')
                end
            elseif comm == 'trackalt' then
                settings.alttrack = not settings.alttrack
            elseif comm == 'sitrack' then
                settings.sitrack = not settings.sitrack
            end
            settings:save()
        elseif comm == 'list' then
            settings.buffs:print()
        elseif comm == 'toggle' then
            autoecho = not autoecho
        else
            return
        end
    end
end
