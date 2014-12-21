--[[
Copyright © 2014, Seth VanHeulen
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

_addon.name = 'setbgm'
_addon.version = '1.1.0'
_addon.command = 'setbgm'
_addon.author = 'Seth VanHeulen (Acacia@Odin)'

require('pack')

mtype = {
    [0]='Idle (Day)',
    [1]='Idle (Night)',
    [2]='Battle (Solo)',
    [3]='Battle (Party)',
    [4]='Unknown',
    [5]='Death',
    [6]='Mog House',
    [7]='Unknown'
}

bgm = {
    [40]='Cloister of Time and Souls', [41]='Royal Wanderlust', [42]='Snowdrift Waltz', [43]='Troubled Shadows', [44]='Where Lords Rule Not', [45]='Summers Lost', [46]='Goddess Divine', [47]='Echoes of Creation', [48]='Main Theme', [49]='Luck of the Mog',
    [50]='Feast of the Ladies', [51]='Abyssea - Scarlet Skies, Shadowed Plains', [52]='Melodies Errant', [53]='Shinryu', [54]='Everlasting Bonds', [55]='Provenance Watcher', [56]='Where it All Begins', [57]='Steel Sings, Blades Dance', [58]='A New Direction', [59]='The Pioneers',
    [60]='Into Lands Primeval - Ulbuka', [61]="Water's Umbral Knell", [62]='Keepers of the Wild', [63]='The Sacred City of Adoulin', [64]='Breaking Ground', [65]='Hades', [66]='Arciela', [67]='Mog Resort', [68]='Worlds Away', [69]='Unknown',
    [70]='Monstrosity', [71]='Unknown', [72]='The Serpentine Labyrinth', [73]='The Divine', [74]='Clouds Over Ulbuka', [75]='The Price', [76]='Forever Today',
    [101]='Battle Theme', [102]='Battle in the Dungeon #2', [103]='Battle Theme #2', [104]='A Road Once Traveled', [105]='Mhaura', [106]='Voyager', [107]="The Kingdom of San d'Oria", [108]="Vana'diel March", [109]='Ronfaure',
    [110]='The Grand Duchy of Jeuno', [111]='Blackout', [112]='Selbina', [113]='Sarutabaruta', [114]='Batallia Downs', [115]='Battle in the Dungeon', [116]='Gustaberg', [117]="Ru'Lude Gardens", [118]='Rolanberry Fields', [119]='Awakening',
    [120]="Vana'diel March #2", [121]='Shadow Lord', [122]='One Last Time', [123]='Hopelessness', [124]='Recollection', [125]='Tough Battle', [126]='Mog House', [127]='Anxiety', [128]='Airship', [129]='Hook, Line and Sinker',
    [130]='Tarutaru Female', [131]='Elvaan Female', [132]='Elvaan Male', [133]='Hume Male', [134]='Yuhtunga Jungle', [135]='Kazham', [136]='The Big One', [137]='A Realm of Emptiness', [138]="Mercenaries' Delight", [139]='Delve',
    [140]='Wings of the Goddess', [141]='The Cosmic Wheel', [142]='Fated Strife -Besieged-', [143]='Hellriders', [144]='Rapid Onslaught -Assault-', [145]='Encampment Dreams', [146]='The Colosseum', [147]='Eastward Bound...', [148]='Forbidden Seal', [149]='Jeweled Boughs',
    [150]='Ululations from Beyond', [151]='The Federation of Windurst', [152]='The Republic of Bastok', [153]='Prelude', [154]='Metalworks', [155]='Castle Zvahl', [156]="Charteau d'Oraguille", [157]='Fury', [158]='Sauromugue Champaign', [159]='Sorrow',
    [160]='Repression (Memoro de la Stono)', [161]='Despair (Memoro de la Stono)', [162]='Heavens Tower', [163]='Sometime, Somewhere', [164]='Xarcabard', [165]='Galka', [166]='Mithra', [167]='Tarutaru Male', [168]='Hume Female', [169]='Regeneracy',
    [170]='Buccaneers', [171]='Altepa Desert', [172]='Black Coffin', [173]='Illusions in the Mist', [174]='Whispers of the Gods', [175]="Bandits' Market", [176]='Circuit de Chocobo', [177]='Run Chocobo, Run!', [178]='Bustle of the Capital', [179]="Vana'diel March #4",
    [180]='Thunder of the March', [181]='Unknown', [182]='Stargazing', [183]="A Puppet's Slumber", [184]='Eternal Gravestone', [185]='Ever-Turning Wheels', [186]='Iron Colossus', [187]='Ragnarok', [188]='Choc-a-bye Baby', [189]='An Invisible Crown',
    [190]="The Sanctuary of Zi'Tah", [191]='Battle Theme #3', [192]='Battle in the Dungeon #3', [193]='Tough Battle #2', [194]='Bloody Promises', [195]='Belief', [196]='Fighters of the Crystal', [197]='To the Heavens', [198]="Eald'narche", [199]="Grav'iton",
    [200]='Hidden Truths', [201]='End Theme', [202]='Moongate (Memoro de la Stono)', [203]='Ancient Verse of Uggalepih', [204]="Ancient Verse of Ro'Maeve", [205]='Ancient Verse of Altepa', [206]='Revenant Maiden', [207]="Ve'Lugannon Palace", [208]='Rabao', [209]='Norg',
    [210]="Tu'Lia", [211]="Ro'Maeve", [212]='Dash de Chocobo', [213]='Hall of the Gods', [214]='Eternal Oath', [215]='Clash of Standards', [216]='On this Blade', [217]='Kindred Cry', [218]='Depths of the Soul', [219]='Onslaught',
    [220]='Turmoil', [221]='Moblin Menagerie - Movalpolos', [222]='Faded Memories - Promyvion', [223]='Conflict: March of the Hero', [224]='Dusk and Dawn', [225]="Words Unspoken - Pso'Xja", [226]='Conflict: You Want to Live Forever?', [227]='Sunbreeze Shuffle', [228]="Gates of Paradise - The Garden of Ru'Hmet", [229]='Currents of Time',
    [230]='A New Horizon - Tavnazian Archipelago', [231]='Celestial Thunder', [232]='The Ruler of the Skies', [233]="The Celestial Capital - Al'Taieu", [234]='Happily Ever After', [235]='First Ode: Nocturne of the Gods', [236]='Fourth Ode: Clouded Dawn', [237]='Third Ode: Memoria de la Stona', [238]='A New Morning', [239]='Jeuno -Starlight Celebration-',
    [240]='Second Ode: Distant Promises', [241]='Fifth Ode: A Time for Prayer', [242]='Unity', [243]="Grav'iton", [244]='Revenant Maiden', [245]='The Forgotten City - Tavnazian Safehold', [246]='March of the Allied Forces', [247]='Roar of the Battle Drums', [248]='Young Griffons in Flight', [249]='Run Maggot, Run!',
    [250]='Under a Clouded Moon', [251]='Autumn Footfalls', [252]='Flowers on the Battlefield', [253]='Echoes of a Zypher', [254]='Griffons Never Die',
    [900]='Distant Worlds'
}

function setbgm_command(...)
    local arg = {...}
    if #arg == 1 or #arg == 2 then
        if arg[1]:lower() == 'list' then
            if #arg == 1 or arg[2]:lower() == 'music' then
                windower.add_to_chat(207, 'Available background music:')
                for id=40,900,5 do
                    local output = '  '
                    for i=0,4 do
                        if bgm[id+i] then
                            output = output .. '  \31\204%d\30\1: %s':format(id+i, bgm[id+i])
                        end
                    end
                    if output ~= '  ' then
                        windower.add_to_chat(207, output)
                    end
                end
                return
            elseif arg[2]:lower() == 'type' then
                windower.add_to_chat(207, 'Available music types:')
                local output = '  '
                for id=0,7 do
                    output = output .. '  \31\204%d\30\1: %s':format(id, mtype[id])
                end
                windower.add_to_chat(207, output)
                return
            end
        end
        local id = tonumber(arg[1])
        if id and bgm[id] then
            if #arg == 1 then
                windower.add_to_chat(207, 'Setting background music: \31\200%s\30\1':format(bgm[id]))
                windower.packets.inject_incoming(0x05F, 'IHH':pack(0x45F, 0, id))
                windower.packets.inject_incoming(0x05F, 'IHH':pack(0x45F, 1, id))
                windower.packets.inject_incoming(0x05F, 'IHH':pack(0x45F, 6, id))
                return
            else
                local tid = tonumber(arg[2])
                if tid and mtype[tid] then
                    windower.add_to_chat(207, 'Setting %s music: \31\200%s\30\1':format(mtype[tid], bgm[id]))
                    windower.packets.inject_incoming(0x05F, 'IHH':pack(0x45F, tid, id))
                    return
                end
            end
        end
    end
    windower.add_to_chat(167, 'Command usage:')
    windower.add_to_chat(167, '    setbgm list [music|type]')
    windower.add_to_chat(167, '    setbgm <music id> [<type id>]')
end

windower.register_event('addon command', setbgm_command)
