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
    if visible == true and is_hidden_by_cutscene == false then
        old_subtarget = subtarget
        subtarget = windower.ffxi.get_mob_by_target('st')
        if subtarget ~= nil and target ~= nil then
            pointer:show()
            stbg_cap_l:show()
            stbg_cap_r:show()
            stbg_body:show()
            stfg_body:show()
            stfgg_body:show()
            st_text:show()

            local player = windower.ffxi.get_mob_by_target('me')
            local i = subtarget.hpp / 100
            local new_width = math.floor(subtargetBarWidth * i)
            local old_width = stfgg_body:width()
            if (old_subtarget ~= nil and subtarget.id == old_subtarget.id) and new_width ~= nil and new_width > 0 then
                if new_width < old_width then
                    local x = old_width + math.floor(((new_width - old_width) * 0.1))
                    stfg_body:width(new_width)
                    stfgg_body:width(x)
                elseif new_width >= old_width then
                    local zx = old_width + math.ceil(((new_width - old_width) * 0.1))
                    stfgg_body:width(new_width)
                    stfg_body:width(zx)
                end
            else
                stfgg_body:width(new_width)
                stfg_body:width(new_width)
            end
            stbg_body:width(subtargetBarWidth)
            stfgg_body:height(subtargetBarHeight)
            stbg_cap_l:height(subtargetBarHeight)
            stbg_cap_r:height(subtargetBarHeight)

            st_text.name = subtarget.name

            --Check claim_id with player and party_id
            if subtarget.spawn_type == 2 or subtarget.spawn_type == 34 then
              --npc
              stbg_cap_l:color(26,151,58)
              stbg_cap_r:color(26,151,58)
              stbg_body:color(26,151,58)
              stfg_body:color(56,201,88)
              stfgg_body:color(26,151,58)
              st_text:stroke_color(33,39,29,200)
              pointer:color(200,255,200)
              st_text:color(200,255,200)
            elseif subtarget.spawn_type == 16 then
              --monster
              if check_claim(subtarget.claim_id, player.id) then
                stbg_cap_l:color(255,64,65)
                stbg_cap_r:color(255,64,65)
                stbg_body:color(255,64,65)
                stfg_body:color(255,103,127)
                stfgg_body:color(215,63,87)
                st_text:stroke_color(49,17,19,200)
                pointer:color(255,180,180)
                st_text:color(255,143,138)
              elseif subtarget.claim_id ~= 0 then
                stbg_cap_l:color(81,80,178)
                stbg_cap_r:color(81,80,178)
                stbg_body:color(81,80,178)
                pointer:color(133,92,215)
                stfg_body:color(245,122,245)
                stfgg_body:color(81,80,178)
                st_text:stroke_color(44,19,44,200)
                pointer:color(255,200,255)
                st_text:color(255,132,255)
              else
                stbg_cap_l:color(181,131,59)
                stbg_cap_r:color(181,131,59)
                stbg_body:color(181,131,59)
                stfg_body:color(252,232,166)
                stfgg_body:color(212,192,126)
                st_text:stroke_color(51,47,38,200)
                pointer:color(255,255,200)
                st_text:color(255,255,193)
              end
            else
              --pc
              if subtarget.in_party == true and subtarget.id ~= player.id then
                stbg_cap_l:color(52, 200, 200)
                stbg_cap_r:color(52, 200, 200)
                stbg_body:color(52, 200, 200)
                stfg_body:color(128, 255, 255)
                stfgg_body:color(88, 215, 215)
                st_text:stroke_color(38,43,46,200)
                pointer:color(200,255,255)
                st_text:color(201, 255, 255)
              else
                stbg_cap_l:color(0, 100, 166)
                stbg_cap_r:color(0, 100, 166)
                stbg_body:color(0, 100, 166)
                stfg_body:color(163, 209, 245)
                stfgg_body:color(123, 189, 205)
                st_text:stroke_color(50,50,50,200)
                pointer:color(200,200,255)
                st_text:color(255, 255, 255)
              end
            end
        else
            pointer:hide()
            stbg_cap_l:hide()
            stbg_cap_r:hide()
            stbg_body:hide()
            stfg_body:hide()
            stfgg_body:show()
            stfgg_body:width(0)
            st_text:hide()
        end
    else
        pointer:hide()
        stbg_cap_l:hide()
        stbg_cap_r:hide()
        stbg_body:hide()
        stfg_body:hide()
        stfgg_body:show()
        stfgg_body:width(0)
        st_text:hide()
    end
end
