--[[
Copyright (c) 2014, Mujihina
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of checkstorage.lua nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mujihina BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- Short script to generate a list of what items you have can be stored in a slip or with event storage NPC

require('luau')

local slips       = require('slips')
local res         = require ('resources').items
local items       = windower.ffxi.get_items()
local event_items = require ('event_items')

for _,container in pairs (slips.default_storages) do
    for _,item in ipairs (items[container]) do
        if (item.id > 0) then
            if (event_items:contains(item.id)) then
                log ("%s:%s can be stored with %s":format(container:color(259), res[item.id].name:color(258), "Event Storage NPC":color(261)))
            end                 
            for slip_id,slip_table in pairs (slips.items) do
               for _,j in ipairs (slip_table) do
                   if (j == item.id) then
                       log ("%s:%s can be stored in %s":format(container:color(259), res[item.id].name:color(258), res[slip_id].name:color(240)))
                   end
                end
            end
        end
    end
end



