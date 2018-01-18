--Copyright © 2016, geno3302
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of RAWR nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL geno3302 BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'RAWR'
_addon.author = 'Genoxd'
_addon.version = '1.0.0.0'

require('tables')

unity_leaders = 
T{
'{Pieuje}',
'{Ayame}',
'{Invincible Shield}', --galka suck.
'{Apururu}',
'{Maat}',
'{Aldo}',
'{Jakoh Wahcondalo}',
'{Naja Salaheem}',
'{Flaviria}',
'{Sylvie}',
'{Yoran-Oran}'
}

dragons = 
T{
'Azi Dahaka',
'Naga Raja',
'Quetzalcoatl'
}

windower.register_event("incoming text", function(original,modified,original_mode,modified_mode, blocked)
    if original_mode == 212 or original_mode == 211 then --Unity chat = 211/212, 211 might be outgoing
        for i,dragon in pairs(dragons) do
            if(windower.wc_match(original, "*"..dragon.."*")) then
                for i2,leader in pairs(unity_leaders) do
                    if(windower.wc_match(original, leader.."*"..dragon.."*")) then
                        windower.play_sound(windower.addon_path..'sounds/RAWR.wav')
                        return
                    end
                end
            end
        end
    end
end)