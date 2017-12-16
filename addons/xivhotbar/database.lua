--[[
        Copyright © 2017, SirEdeonX
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of xivhotbar nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local database = {}

local abilities_file = file.new('/resources/abils.xml')
local spells_file = file.new('/resources/spells.xml')

database.spells = {}
database.abilities = {}

-- import skills from xml files
function database:import()
    self:parse_abilities()
    self:parse_spells()

    return true
end

-- parse abilities xml
function database:parse_abilities()
    local contents = xml.read(abilities_file)

    for key, abil in ipairs(contents.children) do
        local new_abil = {}

        for key, attr in ipairs(abil.children) do
            if attr.name == 'id' then
                new_abil.id = attr.value
            elseif attr.name == 'index' then
                new_abil.icon = attr.value
            elseif attr.name == 'english' then
                new_abil.name = attr.value
            elseif attr.name == 'mpcost' then
                new_abil.mpcost = attr.value
            elseif attr.name == 'tpcost' then
                new_abil.tpcost = attr.value
            elseif attr.name == 'casttime' then
                new_abil.cast = attr.value
            elseif attr.name == 'recast' then
                new_abil.recast = attr.value
            elseif attr.name == 'element' then
                new_abil.element = attr.value
            elseif attr.name == 'wsA' then
                new_abil.skillChainA = attr.value
            elseif attr.name == 'wsB' then
                new_abil.skillChainB = attr.value
            elseif attr.name == 'wsC' then
                new_abil.skillChainC = attr.value
            end
        end

        self.abilities[(new_abil.name):lower()] = new_abil
    end
end

-- parse spells xml
function database:parse_spells()
    local contents = xml.read(spells_file)

    for key, spell in ipairs(contents.children) do
        local new_spell = {}

        for key, attr in ipairs(spell.children) do
            if attr.name == 'id' then
                new_spell.id = attr.value
            elseif attr.name == 'index' then
                new_spell.icon = attr.value
            elseif attr.name == 'english' then
                new_spell.name = attr.value
            elseif attr.name == 'mpcost' then
                new_spell.mpcost = attr.value
            elseif attr.name == 'casttime' then
                new_spell.cast = attr.value
            elseif attr.name == 'element' then
                new_spell.element = attr.value
            elseif attr.name == 'recast' then
                new_spell.recast = attr.value
            end
        end

        self.spells[(new_spell.name):lower()] = new_spell
    end
end

return database