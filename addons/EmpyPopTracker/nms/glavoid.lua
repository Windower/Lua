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
    name = 'Glavoid',
    collectable = 2927, --Glavoid Shell
    collectable_target_count = 50,
    pops = { {
        id = 1473, --Sodden Sandworm Husk
        type = 'key item',
        dropped_from = { name = 'Minhocao, Timed (I-6)' }
    }, {
        id = 1475, --Sticky Gnat Wing
        type = 'key item',
        dropped_from = { name = 'Adze, Timed (G-5)' }
    }, {
        id = 1472, --Fat-lined Cockatrice Skin
        type = 'key item',
        dropped_from = {
            name = 'Alectryon (H-8)',
            pops = { {
                id = 2923, --Cockatrice Tailmeat
                type = 'item',
                dropped_from = { name = 'Cluckatrice (H-8)' }
            }, {
                id = 2949, --Quivering Eft Egg
                type = 'item',
                dropped_from = {
                    name = 'Abas, Forced (K-10)',
                    pops = { {
                        id = 2922, --Eft Egg
                        dropped_from = { name = 'Canyon Eft (J-10/J-11)' }
                    } }
                }
            } }
        }
    }, {
        id = 1474, --Luxuriant manticore mane
        type = 'key item',
        dropped_from = {
            name = 'Muscaliet, Forced (J-6)',
            pops = { {
                id = 2925, --Resilient Mane
                type = 'item',
                dropped_from = { name = 'Hieracosphinx (J-6)' }
            }, {
                id = 2950, --Smooth Whisker
                type = 'item',
                dropped_from = {
                    name = 'Tefenet, Forced (G-6)',
                    pops = { {
                        id = 2924, --Shocking Whisker
                        dropped_from = { name = 'Jaguarundi (G-6)' }
                    } }
                }
            } }
        }
    } }
}
