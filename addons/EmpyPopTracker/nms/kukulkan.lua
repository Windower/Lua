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
    name = 'Kukulkan',
    pops = { {
        id = 1466, --Mucid Ahriman Eyeball
        type = 'key item',
        dropped_from = {
            name = 'Arimaspi, Forced (K-6)',
            pops = { {
                id = 2913, --Clouded Lens
                type = 'item',
                dropped_from = { name = 'Deep Eye (K-6/K-7)' }
            } }
        }
    }, {
        id = 1464, --Tattered Hippogryph Wing
        type = 'key item',
        dropped_from = {
            name = 'Alkonost, Forced (H-6)',
            pops = { {
                id = 2912, --Giant Bugard Tusk
                type = 'item',
                dropped_from = { name = 'Ypotryll (I-7)' }
            } }
        }
    }, {
        id = 1465, --Cracked Wivre Horn
        type = 'key item',
        dropped_from = {
            name = 'Keratyrannos, Forced (G-6)',
            pops = { {
                id = 2910, --Armored Dragonhorn
                type = 'item',
                dropped_from = { name = 'Mesa Wivre (G-6)' }
            } }
        }
    } }
}
