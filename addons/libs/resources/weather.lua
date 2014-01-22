-- Weather
local weather = {}

weather[0]  = {english = 'Clear',           element = 0xF,  intensity = 0}
weather[1]  = {english = 'Sunshine',        element = 0xF,  intensity = 0}
weather[2]  = {english = 'Clouds',          element = 0xF,  intensity = 0}
weather[3]  = {english = 'Fog',             element = 0xF,  intensity = 0}
weather[4]  = {english = 'Hot spells',      element = 0x0,  intensity = 1}
weather[5]  = {english = 'Heat waves',      element = 0x0,  intensity = 2}
weather[6]  = {english = 'Rains',           element = 0x4,  intensity = 1}
weather[7]  = {english = 'Squalls',         element = 0x4,  intensity = 2}
weather[8]  = {english = 'Dust storms',     element = 0x3,  intensity = 1}
weather[9]  = {english = 'Sand storms',     element = 0x3,  intensity = 2}
weather[10] = {english = 'Winds',           element = 0x2,  intensity = 1}
weather[11] = {english = 'Gales',           element = 0x2,  intensity = 2}
weather[12] = {english = 'Snow',            element = 0x1,  intensity = 1}
weather[13] = {english = 'Blizzards',       element = 0x1,  intensity = 2}
weather[14] = {english = 'Thunder',         element = 0x5,  intensity = 1}
weather[15] = {english = 'Thunderstorms',   element = 0x5,  intensity = 2}
weather[16] = {english = 'Auroras',         element = 0x6,  intensity = 1}
weather[17] = {english = 'Stellar glare',   element = 0x6,  intensity = 2}
weather[18] = {english = 'Gloom',           element = 0x7,  intensity = 1}
weather[19] = {english = 'Miasma',          element = 0x7,  intensity = 2}

return weather

--[[
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
