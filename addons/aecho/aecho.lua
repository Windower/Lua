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
_addon.version = '1.0'
function event_load()
    player = get_player()
    watchbuffs = {	"Light Arts",
                    "Addendum: White",
                    "Penury",
                    "Celerity",
                    "Accession",
                    "Perpetuance",
                    "Rapture",
                    "Dark Arts",
                    "Addendum: Black",
                    "Parsimony",
                    "Alacrity",
                    "Manifestation",
                    "Ebullience",
                    "Immanence",
                    "Stun",
                    "Petrified",
                    "Silence",
                    "Stun",
                    "Sleep",
                    "Slow",
                    "Paralyze"
                }
end

function event_login()
    player = get_player()
end

function event_gain_status(id,name)
    for u = 1, #watchbuffs do
        if watchbuffs[u]:lower() == name:lower() then
            if name:upper() == 'SILENCE' then
                send_command('input /item "Echo Drops" '..player["name"])
                send_command('send @others atc '..player["name"]..' - '..name)
            else
                send_command('send @others atc '..player["name"]..' - '..name)
            end
        end
    end
end