--[[
vwhl - voidwatch highlighter v1.20130407

Copyright (c) 2013, Giuliano Riccio
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of vwhl nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Giuliano Riccio BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local _vwhl = {}

function _vwhl:test(...)
    add_to_chat(0, 'The fiend appears extremely vulnerable to club weapon skills!')
    add_to_chat(0, 'The fiend appears highly vulnerable to light elemental blood pacts!')
    add_to_chat(0, 'The fiend appears highly vulnerable to staff weapon skills!')
    add_to_chat(0, 'The fiend appears vulnerable to club weapon skills!')
    add_to_chat(0, 'The fiend appears vulnerable to corsair abilities!')
    add_to_chat(0, 'The fiend appears vulnerable to water elemental blood pacts!')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
    add_to_chat(0, 'RANDOM FILL TO TEST HOLD')
end

function event_load()
    send_command('alias vwhl lua c vwhl')
end

function event_unload()
    send_command('unalias vwhl')
end

function event_addon_command(cmd)
    if cmd == 'test' then
        vwhl.test()
    end
end

function event_incoming_text(original, modified, mode)
    --[[todo: fill with vw messages stream id
    if ( mode != 0 ) then
        return modified, mode
    end
    ]]
    
    if modified:match('The fiend appears') then
        if modified:match('extremely vulnerable') then
            modified = modified:gsub('extremely vulnerable', '\30\02extremely vulnerable (5)\30\01')
        elseif modified:match('highly vulnerable') then
            modified = modified:gsub('highly vulnerable', '\30\02highly vulnerable (3)\30\01')
        else
            modified = modified:gsub('vulnerable', '\30\02vulnerable (1)\30\01')
        end

        if modified:match('great sword') then
            modified = modified:gsub('great sword', '\30\02great sword\30\01')
        elseif modified:match('sword') then
            modified = modified:gsub('sword', '\30\02sword\30\01')
        elseif modified:match('great axe') then
            modified = modified:gsub('great axe', '\30\02great axe\30\01')
        elseif modified:match('axe') then
            modified = modified:gsub('axe', '\30\02axe\30\01')
        end

        modified = modified
            :gsub('(%w+) elemental', '\30\02%1\30\01 elemental')
            :gsub('white magic', '\30\02white magic\30\01')
            :gsub('black magic', '\30\02black magic\30\01')
            :gsub('ninjutsu', '\30\02ninjutsu\30\01')
            :gsub('bard songs', '\30\02bard songs\30\01')
            :gsub('blue magic', '\30\02blue magic\30\01')
            :gsub('abilities', '\30\02abilities\30\01')
            :gsub('warrior', '\30\02warrior\30\01')
            :gsub('monk', '\30\02monk\30\01')
            :gsub('white mage', '\30\02white mage\30\01')
            :gsub('black mage', '\30\02black mage\30\01')
            :gsub('red mage', '\30\02red mage\30\01')
            :gsub('thief', '\30\02thief\30\01')
            :gsub('paladin', '\30\02paladin\30\01')
            :gsub('dark knight', '\30\02dark knight\30\01')
            :gsub('beastmaster', '\30\02beastmaster\30\01')
            :gsub('bard', '\30\02bard\30\01')
            :gsub('ranger', '\30\02ranger\30\01')
            :gsub('samurai', '\30\02samurai\30\01')
            :gsub('ninja', '\30\02ninja\30\01')
            :gsub('dragoon', '\30\02dragoon\30\01')
            :gsub('summoner', '\30\02summoner\30\01')
            :gsub('blue mage', '\30\02blue mage\30\01')
            :gsub('corsair', '\30\02corsair\30\01')
            :gsub('puppetmaster', '\30\02puppetmaster\30\01')
            :gsub('dancer', '\30\02dancer\30\01')
            :gsub('scholar', '\30\02scholar\30\01')
            :gsub('hand-to-hand', '\30\02hand-to-hand\30\01')
            :gsub('dagger', '\30\02dagger\30\01')
            :gsub('scythe', '\30\02scythe\30\01')
            :gsub('polearm', '\30\02polearm\30\01')
            :gsub('katana', '\30\02katana\30\01')
            :gsub('great katana', '\30\02great katana\30\01')
            :gsub('club', '\30\02club\30\01')
            :gsub('staff', '\30\02staff\30\01')
            :gsub('archery', '\30\02archery\30\01')
            :gsub('marksmanship', '\30\02marksmanship\30\01')
            :gsub('pet', '\30\02pet\30\01')
            :gsub('automaton', '\30\02automaton\30\01')
            :gsub('avatar', '\30\02avatar\30\01')
            :gsub('wyvern', '\30\02wyvern\30\01')
            :gsub('weapon skills', '\30\02weapon skills\30\01')
            :gsub('special attacks', '\30\02special attacks\30\01')
            :gsub('blood pacts', '\30\02blood pacts\30\01')

        return '>>> '..modified, 4
    elseif modified:match('L\'un des points faibles') then
        if modified:match('points faibles critiques') then
            modified = modified:gsub('points faibles critiques', '\30\02points faibles critiques (5)\30\01')
        elseif modified:match('points faibles majeurs') then
            modified = modified:gsub('points faibles majeurs', '\30\02points faibles majeurs (3)\30\01')
        else
            modified = modified:gsub('points faibles', '\30\02points faibles (1)\30\01')
        end

        if modified:match('grande épée') then
            modified = modified:gsub('grande épée', '\30\02grande épée\30\01')
        elseif modified:match('épée') then
            modified = modified:gsub('épée', '\30\02épée\30\01')
        elseif modified:match('grande hache') then
            modified = modified:gsub('grande hache', '\30\02grande hache\30\01')
        elseif modified:match('hache') then
            modified = modified:gsub('hache', '\30\02hache\30\01')
        end

        modified = modified
            :gsub('feu', '\30\02feu\30\01')
            :gsub('glace', '\30\02glace\30\01')
            :gsub('vent', '\30\02vent\30\01')
            :gsub('terre', '\30\02terre\30\01')
            :gsub('foudre', '\30\02foudre\30\01')
            :gsub('eau', '\30\02eau\30\01')
            :gsub('lumière', '\30\02lumière\30\01')
            :gsub('ténèbres', '\30\02ténèbres\30\01')
            :gsub('magie blanche', '\30\02magie blanche\30\01')
            :gsub('magie noire', '\30\02magie noire\30\01')
            :gsub('ninjutsu', '\30\02ninjutsu\30\01')
            :gsub('chant', '\30\02chant\30\01')
            :gsub('magie bleue', '\30\02magie bleue\30\01')
            :gsub('souffle', '\30\02souffle\30\01')

            :gsub('guerrier', '\30\02guerrier\30\01')
            :gsub('moine', '\30\02moine\30\01')
            :gsub('mage blanc', '\30\02mage blanc\30\01')
            :gsub('mage noir', '\30\02mage noir\30\01')
            :gsub('mage rouge', '\30\02mage rouge\30\01')
            :gsub('voleur', '\30\02voleur\30\01')
            :gsub('paladin', '\30\02paladin\30\01')
            :gsub('chevalier noir', '\30\02chevalier noir\30\01')
            :gsub('dresseur', '\30\02dresseur\30\01')
            :gsub('barde', '\30\02barde\30\01')
            :gsub('chasseur', '\30\02chasseur\30\01')
            :gsub('samouraï', '\30\02samouraï\30\01')
            :gsub('ninja', '\30\02ninja\30\01')
            :gsub('chevalier dragon', '\30\02chevalier dragon\30\01')
            :gsub('invocateur', '\30\02invocateur\30\01')
            :gsub('mage bleu', '\30\02mage bleu\30\01')
            :gsub('corsaire', '\30\02corsaire\30\01')
            :gsub('marionnettiste', '\30\02marionnettiste\30\01')
            :gsub('danseur', '\30\02danseur\30\01')
            :gsub('érudit', '\30\02érudit\30\01')

            :gsub('corps à corps', '\30\02corps à corps\30\01')
            :gsub('dague', '\30\02dague\30\01')
            :gsub('faux', '\30\02faux\30\01')
            :gsub('arme d\'hast', '\30\02arme d\'hast\30\01')
            :gsub('katana', '\30\02katana\30\01')
            :gsub('grand katana', '\30\02grand katana\30\01')
            :gsub('massue', '\30\02massue\30\01')
            :gsub('crosse', '\30\02crosse\30\01')
            :gsub('archerie', '\30\02archerie\30\01')
            :gsub('artillerie', '\30\02artillerie\30\01')
            :gsub('familier', '\30\02familier\30\01')
            :gsub('automate', '\30\02automate\30\01')
            :gsub('avatar', '\30\02avatar\30\01')
            :gsub('wyvern', '\30\02wyvern\30\01')
            :gsub('compétence arme', '\30\02compétence arme\30\01')
            :gsub('attaque spéciale', '\30\02attaque spéciale\30\01')
            :gsub('pacte de sang', '\30\02pacte de sang\30\01')

        return '>>> '..modified, 4
    elseif modified:match('Das Monster ist nun') then
        if modified:match('ganz besonders anfällig') then
            modified = modified:gsub('ganz besonders anfällig', '\30\02ganz besonders anfällig (5)\30\01')
        elseif modified:match('besonders anfällig') then
            modified = modified:gsub('besonders anfällig', '\30\02besonders anfällig (3)\30\01')
        else
            modified = modified:gsub('anfällig', '\30\02anfällig (1)\30\01')
        end

        modified = modified
            :gsub('(%w+)-Elementarschaden', '\30\02%1\30\01-Elementarschaden')
            :gsub('(%w+)-Magie', '\30\02%1\30\01-Magie')
            :gsub('Weißmagie', '\30\02Weißmagie\30\01')
            :gsub('Schwarzmagie', '\30\02Schwarzmagie\30\01')
            :gsub('Ninjutsu', '\30\02Ninjutsu\30\01')
            :gsub('Gesang', '\30\02Gesang\30\01')
            :gsub('Blaumagie', '\30\02Blaumagie\30\01')

            :gsub('Kriegern', '\30\02Kriegern\30\01')
            :gsub('Mönchen', '\30\02Mönchen\30\01')
            :gsub('Weißmagiern', '\30\02Weißmagiern\30\01')
            :gsub('Schwarzmagiern', '\30\02Schwarzmagiern\30\01')
            :gsub('Rotmagiern', '\30\02Rotmagiern\30\01')
            :gsub('Dieben', '\30\02Dieben\30\01')
            :gsub('Paladinen', '\30\02Paladinen\30\01')
            :gsub('Dunkelrittern', '\30\02Dunkelrittern\30\01')
            :gsub('Bestienbändigern', '\30\02Bestienbändigern\30\01')
            :gsub('Barden', '\30\02Barden\30\01')
            :gsub('Jägern', '\30\02Jägern\30\01')
            :gsub('Samurai', '\30\02Samurai\30\01')
            :gsub('Ninja', '\30\02Ninja\30\01')
            :gsub('Dragoons', '\30\02Dragoons\30\01')
            :gsub('Beschwörern', '\30\02Beschwörern\30\01')
            :gsub('Blaumagiern', '\30\02Blaumagiern\30\01')
            :gsub('Freibeutern', '\30\02Freibeutern\30\01')
            :gsub('Puppenmeistern', '\30\02Puppenmeistern\30\01')
            :gsub('Tänzern', '\30\02Tänzern\30\01')
            :gsub('Gelehrten', '\30\02Gelehrten\30\01')

            :gsub('Fäusten', '\30\02Fäusten\30\01')
            :gsub('Dolchen', '\30\02Dolchen\30\01')
            :gsub('Schwertern', '\30\02Schwertern\30\01')
            :gsub('Großschwertern', '\30\02Großschwertern\30\01')
            :gsub('Äxten', '\30\02Äxten\30\01')
            :gsub('Großäxten', '\30\02Großäxten\30\01')
            :gsub('Sensen', '\30\02Sensen\30\01')
            :gsub('Lanzen', '\30\02Lanzen\30\01')
            :gsub('Katanas', '\30\02Katanas\30\01')
            :gsub('Großkatanas', '\30\02Großkatanas\30\01')
            :gsub('Keulen', '\30\02Keulen\30\01')
            :gsub('Kampfstöcken', '\30\02Kampfstöcken\30\01')
            :gsub('Bögen', '\30\02Bögen\30\01')
            :gsub('Schusswaffen', '\30\02Schusswaffen\30\01')
            :gsub('Haustieren', '\30\02Haustieren\30\01')
            :gsub('Automaten', '\30\02Automaten\30\01')
            :gsub('Avataren', '\30\02Avataren\30\01')
            :gsub('(Wyverns?)', '\30\02%1\30\01')
            :gsub('Waffenfertigkeiten', '\30\02Waffenfertigkeiten\30\01')
            :gsub('Spezialattacken', '\30\02Spezialattacken\30\01')
            :gsub('Blutsbünde', '\30\02Blutsbünde\30\01')

        return '>>> '..modified, 4
    end

    return modified, mode
end