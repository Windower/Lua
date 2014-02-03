-- Skills
local skills = {}

skills[0]  = {english = '(N/A)',                category = 'None'}

skills[1]  = {english = 'Hand-to-Hand',         category = 'Combat'}
skills[2]  = {english = 'Dagger',               category = 'Combat'}
skills[3]  = {english = 'Sword',                category = 'Combat'}
skills[4]  = {english = 'Great Sword',          category = 'Combat'}
skills[5]  = {english = 'Axe',                  category = 'Combat'}
skills[6]  = {english = 'Great Axe',            category = 'Combat'}
skills[7]  = {english = 'Scythe',               category = 'Combat'}
skills[8]  = {english = 'Polearm',              category = 'Combat'}
skills[9]  = {english = 'Katana',               category = 'Combat'}
skills[10] = {english = 'Great Katana',         category = 'Combat'}
skills[11] = {english = 'Club',                 category = 'Combat'}
skills[12] = {english = 'Staff',                category = 'Combat'}

for i = 13, 21, 1 do
    skills[i] = {english = '(Weapon '..tostring(24 - i + 1)..')', category = 'None'}
end

skills[22] = {english = 'Automaton Melee',      category = 'Puppet'}
skills[23] = {english = 'Automaton Archery',    category = 'Puppet'}
skills[24] = {english = 'Automaton Magic',      category = 'Puppet'}

skills[25] = {english = 'Archery',              category = 'Combat'}
skills[26] = {english = 'Marksmanship',         category = 'Combat'}
skills[27] = {english = 'Throwing',             category = 'Combat'}

skills[28] = {english = 'Guard',                category = 'Combat'}
skills[29] = {english = 'Evasion',              category = 'Combat'}
skills[30] = {english = 'Shield',               category = 'Combat'}
skills[31] = {english = 'Parrying',             category = 'Combat'}

skills[32] = {english = 'Divine Magic',         category = 'Magic'}
skills[33] = {english = 'Healing Magic',        category = 'Magic'}
skills[34] = {english = 'Enhancing Magic',      category = 'Magic'}
skills[35] = {english = 'Enfeebling Magic',     category = 'Magic'}
skills[36] = {english = 'Elemental Magic',      category = 'Magic'}
skills[37] = {english = 'Dark Magic',           category = 'Magic'}
skills[38] = {english = 'Summoning Magic',      category = 'Magic'}
skills[39] = {english = 'Ninjutsu',             category = 'Magic'}
skills[40] = {english = 'Singing',              category = 'Magic'}
skills[41] = {english = 'Stringed Instrument',  category = 'Magic'}
skills[42] = {english = 'Wind Instrument',      category = 'Magic'}
skills[43] = {english = 'Blue Magic',           category = 'Magic'}
skills[44] = {english = 'Geomancy',             category = 'Magic'}
skills[45] = {english = 'Handbell',             category = 'Magic'}

for i = 46, 47, 1 do
    skills[i] = {english = '(Magic '..tostring(47 - i + 1)..')', category = 'None'}
end

skills[48] = {english = 'Fishing',              category = 'Synthesis'}
skills[49] = {english = 'Woodworking',          category = 'Synthesis'}
skills[50] = {english = 'Smithing',             category = 'Synthesis'}
skills[51] = {english = 'Goldsmithing',         category = 'Synthesis'}
skills[52] = {english = 'Clothcraft',           category = 'Synthesis'}
skills[53] = {english = 'Leathercraft',         category = 'Synthesis'}
skills[54] = {english = 'Bonecraft',            category = 'Synthesis'}
skills[55] = {english = 'Alchemy',              category = 'Synthesis'}
skills[56] = {english = 'Cooking',              category = 'Synthesis'}
skills[57] = {english = 'Synergy',              category = 'Synthesis'}

for i = 58, 63, 1 do
    skills[i] = {english = '(Synthesis '..tostring(63 - i + 1)..')', category = 'None'}
end

return skills

--[[
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
