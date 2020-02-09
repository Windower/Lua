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
    name = 'Briareus',
    pops = { {
        id = 1482, --Dented Gigas Shield
        type = 'key item',
        dropped_from = {
            name = 'Adamastor, Forced (C-4)',
            pops = { {
                id = 2894, --Trophy Shield
                type = 'item',
                dropped_from = { name = 'Bathyal Gigas (C-5/D-5)' }
            } }
        }
    }, {
        id = 1484, --Severed Gigas Collar
        type = 'key item',
        dropped_from = {
            name = 'Grandgousier, Forced (F-10)',
            pops = { {
                id = 2896, --Massive Armband
                type = 'item',
                dropped_from = { name = 'Demersal Gigas (E-9/F-9)' }
            } }
        }
    }, {
        id = 1483, --Warped Gigas Armband
        type = 'key item',
        dropped_from = {
            name = 'Pantagruel, Forced (F-7)',
            pops = { {
                id = 2895, --Oversized Sock
                type = 'item',
                dropped_from = { name = 'Hadal Gigas (F-6/F-7)' }
            } }
        }
    } }
}
