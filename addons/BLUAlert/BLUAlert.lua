--[[
BLUAlert v1.0.0.0

Copyright © 2017, Christopher Szewczyk
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of BLUAlert nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Christopher Szewczyk BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

require('sets')
res = require('resources')
chat = require('chat')

_addon.name    = 'BLUAlert'
_addon.author  = 'Kainsin'
_addon.version = '1.0.0.0'

-- Some BLU spells have a different name then the monster abilities they come from.
blu_different_names = {
    ["Everyone's Grudge"]     = "Evryone. Grudge",
    ["Nature's Meditation"]   = "Nat. Meditation",
    ["Orcish Counterstance"]  = "O. Counterstance",
    ["Tempestuous Upheaval"]  = "Tem. Upheaval",
    ["Atramentous Libations"] = "Atra. Libations",
    ["Winds of Promyvion"]    = "Winds of Promy.",
    ["Quadratic Continuum"]   = "Quad. Continuum",
}

-- Traverse through all of the BLU spells looking for the one with the given name.
blu_spells = res.spells:type('BlueMagic')
function find_blu_spell(monster_ability_name)
    for i,v in pairs(blu_spells) do
        if (v.english == monster_ability_name) then
            return v.id
        end
    end
end

-- Since the action packet gives monster abilities by ID, we'll want to create a
-- Monster Ability -> BLU Spell mapping to quickly find out which monster ability
-- corresponds to which spell.
spell_id_map = {}
for i,v in pairs(res.monster_abilities) do
    local monster_ability_name = blu_different_names[v.english] or v.english
    spell_id_map[i] = find_blu_spell(monster_ability_name)
end

function get_action_id(targets)
    for i,v in pairs(targets) do
        for i2,v2 in pairs(v['actions']) do
            if v2['param'] then
                return v2['param']
            end
        end
    end
end

windower.register_event('action', function(action)
    -- Category 7 is the readies message for abilities.
    if (action['category'] == 7) then
        local action_id = get_action_id(action['targets'])
        local spell_id = spell_id_map[action_id]
        if spell_id and not windower.ffxi.get_spells()[spell_id] then
            windower.add_to_chat(123, "Unknown Blue Magic Used!")
            windower.play_sound(windower.addon_path..'sounds/UnknownBlueMagicUsed.wav')
        end
    end
end)
