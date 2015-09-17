--[[
Copyright (c) 2014, Mujihina
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of checkstorage.lua nor the
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

-- Short script to generate a list of what items you have can be stored in a slip

require('luau')

local slips = require('slips')
local res   = require ('resources').items
local items = windower.ffxi.get_items()

--[[
EVENT ITEMS
List of items currently storable with event storage NPC:

Furnishings 1
1.  86 San d'Orian holiday tree
2.  115 Bastokan holiday tree
3.  116 Windurstian holiday tree
4.  87 Kadomatsu
5.  117 Wing egg
6.  118 Lamp egg
7.  119 Flower egg
8.  193 Adventuring certificate
9.  88 Timepiece
10. 154 Miniature airship
11. 204 Pumpkin lantern
12. 203 Bomb lantern
13. 205 Mandragora lantern
14. 140 Dream platter
15. 141 Dream coffer
16. 155 Dream stocking
17. 192 Copy of "Hoary Spire"
18. 179 Jeweled egg
19. 323 Sprig of red bamboo grass
20. 324 Sprig of blue bamboo grass
21. 325 Sprig of green bamboo grass
22. 176 Snowman knight
23. 177 Snowman miner
24. 178 Snowman mage
25. 180 Bonbori
26. 215 set of festival dolls
27. 196 Melodious egg
28. 197 Clockwork egg
29. 199 Hatchling egg
30. 320 Harpsichord
31. 415 Aldebaran horn

Furnishings 2
1.  264 Stuffed chocobo
2.  455 Egg buffet
3.  265 Adamantoise statue
4.  266 Behemoth statue
5.  267 Fafnir Statue
6.  456 Pepo lantern
7.  457 Cushaw lantern
8.  458 Calabazilla lantern
9.  138 Jeunoan tree
10. 269 Shadow Lord statue
11. 3641 Kabuto-kazari
12. 3642 Katana-kazari
13. 270 Odin statue
14. 271 Alexander statue
15. 3643 Carillon vermeil
16. 3644 Aeolsglocke
17. 3645 Leafbell
18. 181 San d'Orian flag
19. 182 Bastokan flag
20. 183 Windurstian flag
21. 3622 Jack-o'-pricket
22. 3623 Djinn pricket
23. 3624 Korrigan pricket
24. 3646 Mandragora pricket

Weapons and shields
1.  17074 Chocobo wand
2.  17565 Trick staff
3.  17566 Treat staff
4.  17588 Treat staff II
5.  17830 Wooden katana
6.  17831 Hardwood katana
7.  18102 Pitchfork
8.  18103 Pitchfork +1
9.  18399 Charm wand +1
10. 18436 Lotus katana
11. 18842 Moogle rod
12. 18846 Battledore
13. 18844 Miracle wand +1
14. 18441 Shinai
15. 17748 Ibushi shinai
16. 17749 Ibushi shinai +1
17. 16182 Town moogle shield
18. 16183 Nomad moogle shield
19. 18863 Dream bell
20. 18864 Dream bell +1

Armor - Head
1.  13916 Pumpkin head
2.  13917 Horror head
3.  15176 Pumpkin head II
4.  15177 Horror head II
5.  15178 Dream hat
6.  15179 Dream hat +1
7.  15198 Sprout beret
8.  15199 Guide beret
9.  15204 Mandragora beret
10. 16075 Witch hat
11. 16076 Coven hat
12. 16109 Egg helm
13. 16118 Moogle cap
14. 16119 Nomad cap
15. 16120 (Pairs of) Redeyes
16. 16144 Sol cap
17. 16145 Lunar cap
18. 11491 Snow bunny hat +1
19. 11500 Chocobo beret

Armor - Body, Legs, Feet
1.  13819 Onoko Yukata / 13820 Omina yukata
2.  13821 Lord's Yukata / 13822 Lady's yukata
3.  14450 Hume Gilet / 14451 Hume Top
    14452 Elvaan Gilet / 14453 Elvaan Top
    14454 Tarutaru Maillot / 14471 Tarutaru Top
    14455 Mithra Top
    14456 Galka Gilet
4.  14457 Hume Gilet +1 / 14458 Hume Top +1
    14459 Elvaan Gilet +1 / 14460 Elvaan Top +1
    14461 Tarutaru Maillot +1 / 14472 Tarutaru Top +1
    14462 Mithra Top +1
    14463 Galka Gilet +1
5.  15408 Hume Trunks / 15409 Hume Shorts
    15410 Elvaan Trunks / 15411 Elvaan Shorts
    15412 Tarutaru Trunks / 15423 Tarutaru Shorts
    15413 Mithra Shorts
    15414 Galka Trunks
6.  15415 Hume Trunks +1 / 15416 Hume Shorts +1
    15417 Elvaan Trunks +1 / 15418 Elvaan Shorts +1
    15419 Tarutaru Trunks +1 / 15424 Tarutaru Shorts +1
    15420 Mithra Shorts +1
    15421 Galka Trunks +1
7.  14519 Dream robe
8.  14520 Dream robe +1
9.  14532 Otoko Yukata / 14533 Onago yukata
10. 14534 Otokogimi Yukata / 14535 Onnagimi yukata
11. 15752 (Pair of) dream boots
12. 15753 (Pair of) dream boots +1
13. 11265 Custom Gilet / 11266 Custom Top
    11267 Magna Gilet / 11268 Magna Top
    11269 Wonder Maillot / 11270 Wonder Top
    11271 Savage Top
    11272 Elder Gilet
14. 11273 Custom Gilet +1 / 11274 Custom Top +1
    11275 Magna Gilet +1 / 11276 Magna Top +1
    11277 Wonder Maillot +1 / 11278 Wonder Top +1
    11279 Savage Top +1
    11280 Elder Gilet +1
15. 16321 Custom Trunks / 16322 Custom Shorts
    16323 Magna Trunks / 16324 Magna Shorts
    16325 Wonder Trunks / 16326 Wonder Shorts
    16327 Savage Shorts
    16328 Elder Trunks
16. 16329 Custom Trunks +1 / 16330 Custom Shorts +1
    16331 Magna Trunks +1 / 16332 Magna Shorts +1
    16333 Wonder Trunks +1 / 16334 Wonder Shorts +1
    16335 Savage Shorts +1
    16336 Elder Trunks +1
17. 11300 Eerie cloak
18. 11301 Eerie cloak +1
19. 11290 Tidal talisman
20. 11316 Otokogusa yukata / 11317 Onnagusa yukata
21. 11318 Otokoeshi Yukata / 11319 Ominaeshi yukata
22. 11355 Dinner jacket
23. 16378 Dinner hose


SEALS
List of items currently storable with Shami:
1126 Beastmen's Seal
1127 Kindred's Seal
2955 Kindred's Crest
2956 High Kindred's Crest
2957 Sacred Kindred's Crest


SKIRMISH STONES
List of items currently stoable with Divainy-Gamainy:
3954 Ghastly Stone
3955 Ghastly Stone +1
3955 Ghastly Stone +2
4033 Verdigris Stone
4034 Verdigris Stone +1
4035 Verdigris Stone +2
3951 Wailing Stone
3952 Wailing Stone +1
3953 Wailing Stone +2
8930 Snowslit Stone 
8931 Snowslit Stone +1
8932 Snowslit Stone +2
8933 Leafslit Stone
8934 Leafslit Stone +1
8935 Leafslit Stone +2
8939 Snowtip Stone
8940 Snowtip Stone +1
8941 Snowtip Stone +2
8942 Leaftip Stone
8943 Leaftip Stone +1
8944 Leaftip Stone +2
8948 Snowdim Stone
8949 Snowdim Stone +1
8950 Snowdim Stone +2
8951 Leafdim Stone
8952 Leafdim Stone +1
8953 Leafdim Stone +2
8954 Leadorb Stone
8955 Leadorb Stone +1
8956 Leadorb Stone +2


SKIRMISH WINGS
List of items storable with Lola:
3950 Pulchridopt Wing
4036 Lebondopt Wing

LIMBUS
List of items storable with Sagheera:
1875 Ancient Beastcoins

ROE
List of items storable with RoE NPCs:
8711 Copper Voucher
]]

require('luau')

local slips       = require('slips')
local res         = require ('resources').items
local items       = windower.ffxi.get_items()

local storables = T{
    ['event_items'] = {
        NPC   = 'Event Item NPC', 
        items = S{ 86, 115, 116, 87, 117, 118, 119, 193, 88, 154, 204, 203, 205, 140, 141, 155, 192, 179, 323, 324, 325, 176, 177, 178, 180, 215, 196, 197, 199, 320, 415, 264, 455, 265, 266, 267, 456, 457, 458, 138, 269, 3641, 3642, 270, 271, 3643, 3644, 3645, 181, 182, 183, 3622, 3623, 3624, 3646, 17074, 17565, 17566, 17588, 17830, 17831, 18102, 18103, 18399, 18436, 18842, 18846, 18844, 18441, 17748, 17749, 16182, 16183, 18863, 18864, 13916, 13917, 15176, 15177, 15178, 15179, 15198, 15199, 15204, 16075, 16076, 16109, 16118, 16119, 16120, 16144, 16145, 11491, 11500, 13819, 13820, 13821, 13822, 14450, 14451, 14452, 14453, 14454, 14471, 14455, 14456, 14457, 14458, 14459, 14460, 14461, 14472, 14462, 14463, 15408, 15409, 15410, 15411, 15412, 15423, 15413, 15414, 15415, 15416, 15417, 15418, 15419, 15424, 15420, 15421, 14519, 14520, 14532, 14533, 14534, 14535, 15752, 15753, 11265, 11266, 11267, 11268, 11269, 11270, 11271, 11272, 11273, 11274, 11275, 11276, 11277, 11278, 11279, 11280, 16321, 16322, 16323, 16324, 16325, 16326, 16327, 16328, 16329, 16330, 16331, 16332, 16333, 16334, 16335, 16336, 11300, 11301, 11290, 11316, 11317, 11318, 11319, 11355, 16378 }, -- 179
    },
    ['seals'] = {
        NPC   = 'Shami',
        items = S{ 1126, 1127, 2955, 2956, 2957}, -- 5
    },
    ['skirmish_stones'] = {
        NPC   = 'Divainy-Gamainy',
        items = S{ 3954, 3955, 3956, 3951, 3952, 3953, 4033, 4034, 4035, 8930, 8931, 8932, 8933, 8934, 8935, 8939, 8940, 8941, 8942, 8943, 8944, 8948, 8949, 8950, 8951, 8952, 8953, 8957, 8958, 8959, 8960, 8961, 8962, }, -- 33
    },
    ['skirmish_wings'] = {
        NPC   = 'Lola',
        items = S{ 3950, 4036}, -- 2
    },
    ['limbus'] = {
        NPC   = 'Sagheera',
        items = S{ 1875, }, -- 1
    },
    ['roe'] = {
        NPC   = 'RoE NPCs',
        items = S{ 8711, }, -- 1
    },    
}       

for _,container in pairs (slips.default_storages) do
    for _,item in ipairs (items[container]) do
        if (item.id > 0) then
            -- check storables
            for item_type, item_list in pairs(storables) do
                if (item_list['items']:contains(item.id)) then
                    log ("%s/%s can be stored with %s":format(container:color(259), res[item.id].name:color(258), storables[item_type].NPC:color(261)))
                end            
            end
            -- check slips
            for slip_id,slip_table in pairs (slips.items) do
                for _,j in ipairs (slip_table) do
                    if (j == item.id) then
                    	log ("%s/%s can be stored in %s":format(container:color(259), res[item.id].name:color(258), res[slip_id].name:color(240)))
                    end
                end
            end
        end
    end
end
