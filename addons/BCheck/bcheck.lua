--[[
Copyright © 2021, Sephodious
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Better Check nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sephodious BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

inspired by Battlemod (Byrth) from Windower and Checker (atom0s & Lolwutt) from Ashita
]]--

_addon.name = 'Better Check'
_addon.author = 'Sephodious' -- Rubenator basically wrote this with me, thanks again
_addon.version = '1.0'

-- sets local variables and requires
local packets = require ('packets')
local message_data = require ('resources').action_messages
require('chat')
require('sets')

-- sets local tables
local valid_message_ids = S{170,171,172,173,174,175,176,177,178}
local mchal = {'Very Weak':color(259),'Inredibly Easy Prey':color(259),'Easy Prey':color(259),'A Decent Challenge':color(2),'Evenly Matched':color(53),'Tough':color(159),'Very Tough':color(124),'Incredibly Tough':color(167)}
local mstat = {'high evasion and defense','high evasion','high evasion but low defense','high defense','base defense and evasion','low defense','low evasion but high defense','low evasion','low evasion and defense'}


-- uses incoming chunk so that we can block standard /check text
windower.register_event('incoming chunk',function (id,original,modified,injected,blocked)

    -- ignores packets that don't begin with 29
    if id == 0x029 then
        
        local mobinfo = packets.parse('incoming', original)
        local message_id = mobinfo['Message']
       
        -- tests message_id against valid_message_ids to ensure this only fires off if they match
        if valid_message_ids:contains(message_id) then
            
            local target = windower.ffxi.get_mob_by_id(mobinfo['Target']) or {name=('Unknown')} -- gets mob name
            local lvl = mobinfo['Param 1']
            
            -- gets mob level
            if lvl > 0x7FFFFFFF then
                lvl = -1
            end
            
            local chal = mchal[mobinfo['Param 2'] - 63]
            local stat = mstat[message_id - 170]
            
            windower.add_to_chat(5, "The [%s] is (Lvl.%s), has ~%s~ and seems like its {%s}":format(target.name:color(2), tostring(lvl):color(213), stat:color(1), chal))
            return true -- blocks standard /check message

        -- sets output for NMs
        else if (message_id == 249) then
          local target = windower.ffxi.get_mob_by_id(mobinfo['Target']) or {name=('Unknown')}

          windower.add_to_chat(2, "[%s] Their power is over 9000!! (Impossible to gauge)":format(target.name:color(167)))
        return true -- blocks standard /check message

        end
      end
    end
end)
