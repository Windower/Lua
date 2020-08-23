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
    name = 'Sobek',
    item = 2964, --Sobek's Skin
    item_target_count = 50,
    pops = { {
        id = 1500, --Molted Peiste Skin
        type = 'key item',
        dropped_from = { name = 'Gukumatz, Timed (J-11)' }
    }, {
        id = 1498, --Bloodstained Bugard Fang
        type = 'key item',
        dropped_from = {
            name = 'Minax Bugard, Forced (K-10)',
            pops = { {
                id = 3085, --Bewitching Tusk
                type = 'item',
                dropped_from = { name = 'Abyssobugard (J-10/K-11)' }
            } }
        }
    }, {
        id = 1499, --Gnarled Lizard Nail
        type = 'key item',
        dropped_from = {
            name = 'Sirrush, Forced (I-11)',
            pops = { {
                id = 3086, --Molt Scraps
                type = 'item',
                dropped_from = { name = 'Dusk Lizard (J-11)' }
            } }
        }
    } }
}
