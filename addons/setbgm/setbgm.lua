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
_addon.version = '1.2.3'
_addon.command = 'setbgm'
_addon.author = 'Seth VanHeulen (Acacia@Odin)'

require('chat')
require('pack')

music_types = {
    [0]='Idle (Day)',
    [1]='Idle (Night)',
    [2]='Battle (Solo)',
    [3]='Battle (Party)',
    [4]='Chocobo',
    [5]='Death',
    [6]='Mog House',
    [7]='Fishing'
}

songs = {
    [25]='Voracious Resurgence Unknown 1', [26]='Voracious Resurgence Unknown 2', [27]='Voracious Resurgence Unknown 3', [28]='Voracious Resurgence Unknown 4', [29]="Devils' Delight",
    [40]='Cloister of Time and Souls', [41]='Royal Wanderlust', [42]='Snowdrift Waltz', [43]='Troubled Shadows', [44]='Where Lords Rule Not', [45]='Summers Lost', [46]='Goddess Divine', [47]='Echoes of Creation', [48]='Main Theme', [49]='Luck of the Mog',
    [50]='Feast of the Ladies', [51]='Abyssea - Scarlet Skies, Shadowed Plains', [52]='Melodies Errant', [53]='Shinryu', [54]='Everlasting Bonds', [55]='Provenance Watcher', [56]='Where it All Begins', [57]='Steel Sings, Blades Dance', [58]='A New Direction', [59]='The Pioneers',
    [60]='Into Lands Primeval - Ulbuka', [61]="Water's Umbral Knell", [62]='Keepers of the Wild', [63]='The Sacred City of Adoulin', [64]='Breaking Ground', [65]='Hades', [66]='Arciela', [67]='Mog Resort', [68]='Worlds Away', [69]="Distant Worlds (Nanaa Mihgo's version)",
    [70]='Monstrosity', [71]="The Pioneers (Nanaa Mihgo's version)", [72]='The Serpentine Labyrinth', [73]='The Divine', [74]='Clouds Over Ulbuka', [75]='The Price', [76]='Forever Today', [77]='Distant Worlds (Instrumental)', [78]='Forever Today (Instrumental)', [79]='Iroha',
    [80]='The Boundless Black', [81]='Isle of the Gods', [82]='Wail of the Void', [83]="Rhapsodies of Vana'diel", [84]="Full Speed Ahead!", [85]="Times Grow Tense", [86]="Shadow Lord (Record Keeper Remix)", [87]="For a Friend", [88]="Between Dreams and Reality", [89]="Disjoined One", [90]="Winds of Change", 
    [101]='Battle Theme', [102]='Battle in the Dungeon #2', [103]='Battle Theme #2', [104]='A Road Once Traveled', [105]='Mhaura', [106]='Voyager', [107]="The Kingdom of San d'Oria", [108]="Vana'diel March", [109]='Ronfaure',
    [110]='The Grand Duchy of Jeuno', [111]='Blackout', [112]='Selbina', [113]='Sarutabaruta', [114]='Batallia Downs', [115]='Battle in the Dungeon', [116]='Gustaberg', [117]="Ru'Lude Gardens", [118]='Rolanberry Fields', [119]='Awakening',
    [120]="Vana'diel March #2", [121]='Shadow Lord', [122]='One Last Time', [123]='Hopelessness', [124]='Recollection', [125]='Tough Battle', [126]='Mog House', [127]='Anxiety', [128]='Airship', [129]='Hook, Line and Sinker',
    [130]='Tarutaru Female', [131]='Elvaan Female', [132]='Elvaan Male', [133]='Hume Male', [134]='Yuhtunga Jungle', [135]='Kazham', [136]='The Big One', [137]='A Realm of Emptiness', [138]="Mercenaries' Delight", [139]='Delve',
    [140]='Wings of the Goddess', [141]='The Cosmic Wheel', [142]='Fated Strife -Besieged-', [143]='Hellriders', [144]='Rapid Onslaught -Assault-', [145]='Encampment Dreams', [146]='The Colosseum', [147]='Eastward Bound...', [148]='Forbidden Seal', [149]='Jeweled Boughs',
    [150]='Ululations from Beyond', [151]='The Federation of Windurst', [152]='The Republic of Bastok', [153]='Prelude', [154]='Metalworks', [155]='Castle Zvahl', [156]="Chateau d'Oraguille", [157]='Fury', [158]='Sauromugue Champaign', [159]='Sorrow',
    [160]='Repression (Memoro de la Stono)', [161]='Despair (Memoro de la Stono)', [162]='Heavens Tower', [163]='Sometime, Somewhere', [164]='Xarcabard', [165]='Galka', [166]='Mithra', [167]='Tarutaru Male', [168]='Hume Female', [169]='Regeneracy',
    [170]='Buccaneers', [171]='Altepa Desert', [172]='Black Coffin', [173]='Illusions in the Mist', [174]='Whispers of the Gods', [175]="Bandits' Market", [176]='Circuit de Chocobo', [177]='Run Chocobo, Run!', [178]='Bustle of the Capital', [179]="Vana'diel March #4",
    [180]='Thunder of the March', [181]='Dash de Chocobo (Low Quality)', [182]='Stargazing', [183]="A Puppet's Slumber", [184]='Eternal Gravestone', [185]='Ever-Turning Wheels', [186]='Iron Colossus', [187]='Ragnarok', [188]='Choc-a-bye Baby', [189]='An Invisible Crown',
    [190]="The Sanctuary of Zi'Tah", [191]='Battle Theme #3', [192]='Battle in the Dungeon #3', [193]='Tough Battle #2', [194]='Bloody Promises', [195]='Belief', [196]='Fighters of the Crystal', [197]='To the Heavens', [198]="Eald'narche", [199]="Grav'iton",
    [200]='Hidden Truths', [201]='End Theme', [202]='Moongate (Memoro de la Stono)', [203]='Ancient Verse of Uggalepih', [204]="Ancient Verse of Ro'Maeve", [205]='Ancient Verse of Altepa', [206]='Revenant Maiden', [207]="Ve'Lugannon Palace", [208]='Rabao', [209]='Norg',
    [210]="Tu'Lia", [211]="Ro'Maeve", [212]='Dash de Chocobo', [213]='Hall of the Gods', [214]='Eternal Oath', [215]='Clash of Standards', [216]='On this Blade', [217]='Kindred Cry', [218]='Depths of the Soul', [219]='Onslaught',
    [220]='Turmoil', [221]='Moblin Menagerie - Movalpolos', [222]='Faded Memories - Promyvion', [223]='Conflict: March of the Hero', [224]='Dusk and Dawn', [225]="Words Unspoken - Pso'Xja", [226]='Conflict: You Want to Live Forever?', [227]='Sunbreeze Shuffle', [228]="Gates of Paradise - The Garden of Ru'Hmet", [229]='Currents of Time',
    [230]='A New Horizon - Tavnazian Archipelago', [231]='Celestial Thunder', [232]='The Ruler of the Skies', [233]="The Celestial Capital - Al'Taieu", [234]='Happily Ever After', [235]='First Ode: Nocturne of the Gods', [236]='Fourth Ode: Clouded Dawn', [237]='Third Ode: Memoria de la Stona', [238]='A New Morning', [239]='Jeuno -Starlight Celebration-',
    [240]='Second Ode: Distant Promises', [241]='Fifth Ode: A Time for Prayer', [242]='Unity', [243]="Grav'iton", [244]='Revenant Maiden', [245]='The Forgotten City - Tavnazian Safehold', [246]='March of the Allied Forces', [247]='Roar of the Battle Drums', [248]='Young Griffons in Flight', [249]='Run Maggot, Run!',
    [250]='Under a Clouded Moon', [251]='Autumn Footfalls', [252]='Flowers on the Battlefield', [253]='Echoes of a Zypher', [254]='Griffons Never Die',
    [900]='Distant Worlds'
}

function set_music(music_type, song)
    if music_type then
        local m = tonumber(music_type)
        if music_types[m] then
            local s = tonumber(song)
            if songs[s] then
                windower.add_to_chat(207, 'Setting %s music: %s':format(music_types[m], songs[s]:color(200)))
                windower.packets.inject_incoming(0x05F, 'IHH':pack(0x45F, m, s))
            else
                windower.add_to_chat(167, 'Invalid song: %s':format(song))
            end
        else
            windower.add_to_chat(167, 'Invalid music type: %s':format(music_type))
        end
    else
        local s = tonumber(song)
        if songs[s] then
            windower.add_to_chat(207, 'Setting all music: %s':format(songs[s]:color(200)))
            for music_type=0,7 do
                windower.packets.inject_incoming(0x05F, 'IHH':pack(0x45F, music_type, s))
            end
        else
            windower.add_to_chat(167, 'Invalid song: %s':format(song))
        end
    end
end

function display_songs()
    windower.add_to_chat(207, 'Available songs:')
    for id=25,900,5 do
        local output = '  '
        for i=0,4 do
            if songs[id+i] then
                output = output .. '  %s: %s':format(tostring(id+i):color(204), songs[id+i])
            end
        end
        if output ~= '  ' then
            windower.add_to_chat(207, output)
        end
    end
end

function display_music_types()
    windower.add_to_chat(207, 'Available music types:')
    local output = '  '
    for music_type=0,7 do
        output = output .. '  %s: %s':format(tostring(music_type):color(204), music_types[music_type])
    end
    windower.add_to_chat(207, output)
end

function display_help()
    windower.add_to_chat(167, 'Command usage:')
    windower.add_to_chat(167, '    setbgm list [music|type]')
    windower.add_to_chat(167, '    setbgm <song id> [<music type id>]')
    windower.add_to_chat(167, '    setbgm <song id> <song id> <song id> <song id> <song id> <song id> <song id> <song id>')
end

function setbgm_command(...)
    local arg = {...}
    if #arg == 1 and arg[1]:lower() == 'list' then
        display_songs()
        return
    elseif #arg == 2 and arg[1]:lower() == 'list' and arg[2]:lower() == 'music' then
        display_songs()
        return
    elseif #arg == 2 and arg[1]:lower() == 'list' and arg[2]:lower() == 'type' then
        display_music_types()
        return
    elseif #arg == 1 then
        set_music(nil, arg[1])
        return
    elseif #arg == 2 then
        set_music(arg[2], arg[1])
        return
    elseif #arg == 8 then
        set_music(0, arg[1])
        set_music(1, arg[2])
        set_music(2, arg[3])
        set_music(3, arg[4])
        set_music(4, arg[5])
        set_music(5, arg[6])
        set_music(6, arg[7])
        set_music(7, arg[8])
        return
    end
    display_help()
end

windower.register_event('addon command', setbgm_command)
