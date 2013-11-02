--[[
enternity v1.20131102

Copyright (c) 2013, Giuliano Riccio
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of enternity nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Giuliano Riccio BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

require 'sets'

_addon = {}
_addon.name    = 'enternity'
_addon.author  = 'Zohno'
_addon.version = '1.20131102'

blist = S{
    -- Paintbrush of souls dialogue
    17428966,

    -- Geomantic Reservoirs (for Geo spells)
    17613246,
    17195707,
    17195710,
    17596856,
    17379862,
    17207950,
    17297494,
    17576434,
    17396247,
    17580413,
    17850967,
    17191529,
    17228404,
    17846822,
    17232297,
    17232300,
    17388045,
    17461577,
    17293797,
    17842739,
    17531228,
    17269285,
    17236348,
    17863490,
    17863493,
    17584498,
    17257104,
    17220194,
    17424560,
}

windower.register_event('incoming text', function(original, modified, mode)
    if (mode == 150 or mode == 151) and not original:match(string.char(0x1e, 0x02)) and not blist:contains(get_mob_by_target('t').id) then
        modified = modified:gsub(string.char(0x7F, 0x31), '')
    end

    return modified
end)
