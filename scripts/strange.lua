--[[
Copyright © 2014, Mujihina
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of strange.lua nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mujihina BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- Short script to generate password for doctor status when using a strange apparatus

require('luau')

if (not windower.ffxi.get_info().logged_in) then 
    log ("You must be logged in order to use this script")
    return 
end

local zone_values = T{
    [191] = {val = 0, element = "Fire",      chip = "Red"},    -- Dangruf Wadi
    [196] = {val = 1, element = "Earth",     chip = "Yellow"}, -- Gusgen Mines
    [197] = {val = 2, element = "Water",     chip = "Blue"},   -- Crawlers' Nest
    [193] = {val = 3, element = "Wind",      chip = "Green"},  -- Ordelle's Caves
    [195] = {val = 4, element = "Ice",       chip = "Clear"},  -- Eldieme Necropolis
    [194] = {val = 5, element = "Lightning", chip = "Purple"}, -- Outer Horutoto Ruins
    [200] = {val = 6, element = "Light",     chip = "White"},  -- Garlaige Citadel
    [198] = {val = 7, element = "Dark",      chip = "Black"},  -- Maze of Shakrami
}

local name = windower.ffxi.get_player().name:lower():sub(1,3) -- First 3 chars of name
local area = windower.ffxi.get_info().zone


if (not zone_values[area]) then
    log ("This is not an area with a strange apparatus")
    return
end

local values = T{}
values[0] = name:byte(1) - 97 + zone_values[area].val
values[1] = name:byte(2) - 97 + zone_values[area].val
values[2] = name:byte(3) - 97 + zone_values[area].val
values[3] = values[0] + values[1] + values[2] + zone_values[area].val

log ("Password: %02d%02d%02d%02d":format(values[0], values[1], values[2], values[3]))
log ("Chip: %s (%s)":format(zone_values[area].chip, zone_values[area].element))
 
