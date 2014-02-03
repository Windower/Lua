-- Weather
local weather = {}

weather[0]  = {english = 'Fine patches',    french = 'Beau temps',              german = 'Zeitweise bewölkt',   japanese = '快晴',    element = 0xF,  intensity = 0}
weather[1]  = {english = 'Sunshine',        french = 'Soleil',                  german = 'Sonne',               japanese = '晴れ',    element = 0xF,  intensity = 0}
weather[2]  = {english = 'Clouds',          french = 'Nuages',                  german = 'Wolken',              japanese = 'くもり',    element = 0xF,  intensity = 0}
weather[3]  = {english = 'Fog',             french = 'Brume',                   german = 'Nebel',               japanese = '霧',      element = 0xF,  intensity = 0}
weather[4]  = {english = 'Hot spells',      french = 'Brûlant',                 german = 'Hitze',               japanese = '熱波',    element = 0x0,  intensity = 1}
weather[5]  = {english = 'Heat waves',      french = 'Ardent',                  german = 'Hitzewellen',         japanese = '灼熱波',  element = 0x0,  intensity = 2}
weather[6]  = {english = 'Rain',            french = 'Pluie',                   german = 'Regen',               japanese = '雨',      element = 0x4,  intensity = 1}
weather[7]  = {english = 'Squalls',         french = 'Averse',                  german = 'Böen',                japanese = 'スコール',  element = 0x4,  intensity = 2}
weather[8]  = {english = 'Dust storms',     french = 'Tempêtes de poussière',   german = 'Staubstürme',         japanese = '砂塵',    element = 0x3,  intensity = 1}
weather[9]  = {english = 'Sand storms',     french = 'Tempêtes de sable',       german = 'Sandstürme',          japanese = '砂嵐',    element = 0x3,  intensity = 2}
weather[10] = {english = 'Winds',           french = 'Vents',                   german = 'Wind',                japanese = '風',      element = 0x2,  intensity = 1}
weather[11] = {english = 'Gales',           french = 'Rafales',                 german = 'Orkane',              japanese = '暴風',    element = 0x2,  intensity = 2}
weather[12] = {english = 'Snow',            french = 'Neige',                   german = 'Schnee',              japanese = '雪',      element = 0x1,  intensity = 1}
weather[13] = {english = 'Blizzards',       french = 'Blizzards',               german = 'Eissturm',            japanese = '吹雪',    element = 0x1,  intensity = 2}
weather[14] = {english = 'Thunder',         french = 'Orage',                   german = 'Donner',              japanese = '雷',      element = 0x5,  intensity = 1}
weather[15] = {english = 'Thunderstorms',   french = 'Gros orage',              german = 'Gewitter',            japanese = '雷雨',    element = 0x5,  intensity = 2}
weather[16] = {english = 'Auroras',         french = 'Aurores boréales',        german = 'Polarlicht',          japanese = 'オーロラ',  element = 0x6,  intensity = 1}
weather[17] = {english = 'Stellar glare',   french = 'Aurores incandescentes',  german = 'Sternenflut',         japanese = '神光',    element = 0x6,  intensity = 2}
weather[18] = {english = 'Gloom',           french = 'Pénombre',                german = 'Dunkelheit',          japanese = '妖霧',    element = 0x7,  intensity = 1}
weather[19] = {english = 'Darkness',        french = 'Obscurité',               german = 'Finsternis',          japanese = '闇',      element = 0x7,  intensity = 2}

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
