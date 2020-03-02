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
    name = "Warder of Courage",
    pops = { {
        id = 2986, --Primal Nazar
        type = 'key item',
        dropped_from = {
            name = 'Dremi (NPC)',
            pops = { {
                id = 2976, --Primary Nazar
                type = 'key item',
                dropped_from = { name = 'Warder of Temperance (Zdei, portal #1)' }
            }, {
                id = 2977, --Secondary Nazar
                type = 'key item',
                dropped_from = { name = 'Warder of Fortitude (Ghrah, portal #3)' }
            }, {
                id = 2978, --Tertiary Nazar
                type = 'key item',
                dropped_from = { name = 'Warder of Faith (Euvhi, portal #12)' }
            }, {
                id = 2979, --Quaternary Nazar
                type = 'key item',
                dropped_from = { name = 'Warder of Justice (Xzomit, portal #6)' }
            }, {
                id = 2980, --Quinary Nazar
                type = 'key item',
                dropped_from = { name = 'Warder of Hope (Phuabo, portal #1)' }
            }, {
                id = 2981, --Senary Nazar
                type = 'key item',
                dropped_from = { name = 'Warder of Prudence (Hpemde, portal #9)' }
            }, {
                id = 2982, --Septenary Nazar
                type = 'key item',
                dropped_from = { name = 'Warder of Love (Yovra)' }
            }, {
                id = 2983, --Octonary Nazar
                type = 'key item',
                dropped_from = { name = 'Warder of Dignity (Limule, portal #4)' }
            }, {
                id = 2984, --Nonary Nazar
                type = 'key item',
                dropped_from = { name = 'Warder of Loyalty (Clionid, portal #13)' }
            }, {
                id = 2985, --Denary Nazar
                type = 'key item',
                dropped_from = { name = 'Warder of Mercy (Murex, portal #7)' }
            }}
        }
    } }
}
