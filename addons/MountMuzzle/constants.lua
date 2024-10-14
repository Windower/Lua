--[[
Copyright © 2018, Sjshovan (Apogee)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Mount Muzzle nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sjshovan (Apogee) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

packets = {
    inbound = {
        music_change = {
            id = 0x05F
        },
        zone_update = {
            id = 0x00A
        }
    },
    outbound = {
        action = {
            id = 0x1A,
            categories = {
                mount = 0x1A,
                unmount = 0x12
            },
        }
    },
}

player = {
    statuses = {
        mounted = 85
    },
    buffs = {
        reiveMark = 511,
        mounted = 252
    }
}

music = {
    songs = {
        silent = 9999,
        custom = 9999,
        mount = 84,
        chocobo = 212,
        zone = 0
    },
    types = {
        mount = 4,
        idle_day = 0,
        idle_night = 1
    }
}

colors = {
    primary = 200,
    secondary = 207,
    info = 0,
    warn = 140,
    danger = 167,
    success = 158
}

muzzles = {
    silent = {
        name = 'silent',
        song = music.songs.silent,
        description = 'No Music (Default)'
    },
    mount = {
        name = 'mount',
        song = music.songs.mount,
        description = 'Mount Music'
    },
    chocobo = {
        name = 'chocobo',
        song = music.songs.chocobo,
        description = 'Chocobo Music'
    },
    zone = {
        name = 'zone',
        song = music.songs.zone,
        description = 'Current Zone Music'
    },
    custom = {
        name = 'custom',
        song = music.songs.custom,
        description = 'User-Defined Per-Mount Music'
    }
}

songs = {
    [0] = 'No Music',
    [25]='The Voracious Resurgence', [26]='The Devoured', [27]='Enroaching Perils', [28]='The Destiny Destroyers', [29]="Devils' Delight",  [30]="Sojourner", [31]='Black Stars Rise', [32]='All Smiles',
    [33]='Valhalla', [34]="We Are Vana'diel", [35]='Goddessspeed', [36]='Good Fortune', [37]='All-Consuming Chaos', [38]='Your Choice',
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

return {
    packets = packets,
    player = player,
    music = music,
    colors = colors,
    muzzles = muzzles,
    songs = songs
}