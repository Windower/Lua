--[[
Copyright © 2020, Dean James (Xurion of Bismarck)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Empy Pop Tracker nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Dean James (Xurion of Bismarck) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

return {
    name = 'Chloris',
    collectable = 2928, --2Lf. Chloris Bud
    collectable_target_count = 50,
    pops = { {
        id = 1470, --Gory Scorpion Claw
        type = 'key item',
        dropped_from = {
            name = 'Hedetet, Forced (F-7)',
            pops = { {
                id = 2921, --Venomous Scorpion Stinger
                type = 'item',
                dropped_from = { name = 'Canyon Scorpion (F-7)' }
            }, {
                id = 2948, --Acidic Humus
                type = 'item',
                dropped_from = {
                    name = 'Gancanagh, Forced (H-8)',
                    pops = { {
                        id = 2920, --Alkaline Humus
                        type = 'item',
                        dropped_from = { name = 'Pachypodium (H-8)' }
                    } }
                }
            } }
        }
    }, {
        id = 1469, --Torn Bat Wing
        type = 'key item',
        dropped_from = {
            name = 'Treble Noctules, Forced (I-9)',
            pops = { {
                id = 2919, --Bloody Fang
                type = 'item',
                dropped_from = { name = 'Blood Bat (I-9)' }
            }, {
                id = 2947, --Exorcised Skull
                type = 'item',
                dropped_from = {
                    name = 'Cannered Noz, Forced (F-6)',
                    pops = { {
                        id = 2918, --Baleful Skull
                        type = 'item',
                        dropped_from = { name = 'Caoineag (F-6)' }
                    } }
                }
            } }
        }
    }, {
        id = 1468, --Veinous Hecteyes Eyelid
        type = 'key item',
        dropped_from = {
            name = 'Ophanim, Forced (G-9)',
            pops = { {
                id = 2917, --Bloodshot Hecteye
                type = 'item',
                dropped_from = { name = 'Beholder (G-9)' }
            }, {
                id = 2946, --Tarnished Pincer
                type = 'item',
                dropped_from = {
                    name = 'Vetehinen, Forced (H-10)',
                    pops = { {
                        id = 2916, --High-quality Limule Pincer
                        type = 'item',
                        dropped_from = { name = 'Gulch Limule (H-10)' }
                    } }
                }
            }, {
                id = 2945, --Shriveled Wing
                type = 'item',
                dropped_from = {
                    name = 'Halimede, Forced (G-12)',
                    pops = { {
                        id = 2915, --High-quality Clionid Wing
                        type = 'item',
                        dropped_from = { name = 'Gully Clionid (G-12)' }
                    } }
                }
            } }
        }
    }, {
        id = 1471, --Mossy Adamantoise Shell
        type = 'key item',
        dropped_from = { name = 'Chukwa, Timed (F-5)' }
    } }
}
