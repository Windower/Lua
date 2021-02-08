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
    name = 'Itzpapalotl',
    collectable = 2962, --Itzpapa. Scale
    collectable_target_count = 50,
    pops = { {
        id = 1488, --Venomous Wamoura Feeler
        type = 'key item',
        dropped_from = {
            name = 'Granite Borer, Forced (K-10)',
            pops = { {
                id = 3072, --Withered Cocoon
                type = 'item',
                dropped_from = { name = 'Gullycampa (K-10)' }
            } }
        }
    }, {
        id = 1490, --Distended Chigoe Abdomen
        type = 'key item',
        dropped_from = { name = 'Tunga, Timed (K-10)' }
    }, {
        id = 1489, --Bulbous crawler cocoon
        type = 'key item',
        dropped_from = {
            name = 'Blazing Eruca, Forced (J-10)',
            pops = { {
                id = 3073, --Eruca Egg
                type = 'item',
                dropped_from = { name = 'Ignis Eruca (J-10)' }
            } }
        }
    } }
}
