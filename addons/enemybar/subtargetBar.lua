--[[
Copyright © 2015, Mike McKee
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of enemybar nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mike McKee BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

render_subtarget_bar = function(...)
    if visible == true then
        local subtarget = windower.ffxi.get_mob_by_target('st')
        if subtarget ~= nil and target ~= nil then
            pointer:show()
            --stbg_cap_l:show()
            --stbg_cap_r:show()
            stbg_body:show()
            stfg_body:show()
            st_text:show()

            local i = subtarget.hpp / 100
            local new_width = math.floor(subtargetBarWidth * i)
            stfg_body:width(new_width)
            stbg_body:width(subtargetBarWidth)

            st_text.name = subtarget.name

            --Check claim_id with player and party_id
            if subtarget.spawn_type == 2 or subtarget.spawn_type == 34 then
              --npc
              stbg_cap_l:color(26,151,58)
              stbg_cap_r:color(26,151,58)
              stbg_body:color(26,151,58)
              stfg_body:color(56,201,88)
              st_text:stroke_color(33,39,29,200)
              pointer:color(200,255,200)
              st_text:color(200,255,200)
            elseif subtarget.spawn_type == 16 then
              --monster
              if check_claim(subtarget.claim_id) then
                stbg_cap_l:color(255,64,65)
                stbg_cap_r:color(255,64,65)
                stbg_body:color(255,64,65)
                stfg_body:color(255,103,127)
                st_text:stroke_color(49,17,19,200)
                pointer:color(255,200,200)
                st_text:color(255,143,138)
              elseif subtarget.claim_id ~= 0 then
                stbg_cap_l:color(81,80,178)
                stbg_cap_r:color(81,80,178)
                stbg_body:color(81,80,178)
                pointer:color(133,92,215)
                stfg_body:color(133,92,215)
                st_text:stroke_color(44,19,44,200)
                pointer:color(255,200,255)
                st_text:color(255,132,255)
              else
                stbg_cap_l:color(181,131,59)
                stbg_cap_r:color(181,131,59)
                stbg_body:color(181,131,59)
                stfg_body:color(252,232,166)
                st_text:stroke_color(51,47,38,200)
                pointer:color(255,255,200)
                st_text:color(255,255,193)
              end
            else
              --pc
              if subtarget.in_party == true and subtarget.id ~= player_id then
                stbg_cap_l:color(52, 200, 200)
                stbg_cap_r:color(52, 200, 200)
                stbg_body:color(52, 200, 200)
                stfg_body:color(128, 255, 255)
                st_text:stroke_color(38,43,46,200)
                pointer:color(200,255,255)
                st_text:color(201, 255, 255)
              else
                stbg_cap_l:color(0, 100, 166)
                stbg_cap_r:color(0, 100, 166)
                stbg_body:color(0, 100, 166)
                stfg_body:color(163, 209, 245)
                st_text:stroke_color(50,50,50,200)
                pointer:color(200,200,255)
                st_text:color(255, 255, 255)
              end
            end
        else
            pointer:hide()
            --stbg_cap_l:hide()
            --stbg_cap_r:hide()
            stbg_body:hide()
            stfg_body:hide()
            st_text:hide()
        end
    end
end
