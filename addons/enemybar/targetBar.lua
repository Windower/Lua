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

render_target_bar = function (...)
    if visible == true and is_hidden_by_cutscene == false then
        old_target = target
        target = windower.ffxi.get_mob_by_target('t')

        local subtarget = windower.ffxi.get_mob_by_target('st')
        if subtarget ~= nil and target == nil then
          target = subtarget
        end

        if target ~= nil then
            tbg_cap_l:show()
            tbg_cap_r:show()
            tbg_body:show()
            tfg_body:show()
            tfgg_body:show()
            t_text:show()

            local player = windower.ffxi.get_mob_by_target('me')
            local i = target.hpp / 100
            local new_width = math.floor(targetBarWidth * i)
            local old_width = tfgg_body:width()
            if (old_target ~= nil and target.id == old_target.id) and new_width ~= nil and new_width > 0 then
                if new_width < old_width then
                    local x = old_width + math.floor(((new_width - old_width) * 0.1))
                    tfgg_body:width(x)
                    tfg_body:width(new_width)
                elseif new_width >= old_width then
                    local zx = old_width + math.ceil(((new_width - old_width) * 0.1))
                    tfg_body:width(zx)
                    tfgg_body:width(new_width)
                end
            else
                tfgg_body:width(new_width)
                tfg_body:width(new_width)
            end
            tfgg_body:height(targetBarHeight)
            tbg_body:width(targetBarWidth) -- I still have no idea why removing this breaks the bg.
            tbg_cap_l:height(targetBarHeight)
            tbg_cap_r:height(targetBarHeight)

            t_text.name = target.name
            t_text.hpp = target.hpp
            t_text.debug = debug_string

            --Check claim_id with player and party_id
            if target.spawn_type == 2 or target.spawn_type == 34 then
              --npc
              tbg_cap_l:color(26,151,58)
              tbg_cap_r:color(26,151,58)
              tbg_body:color(26,151,58)
              tfg_body:color(56,201,88)
              tfgg_body:color(26,151,58)
              t_text:stroke_color(33,39,29,200)
              t_text:color(200,255,200)
            elseif target.spawn_type == 16 then
              --monster
              if check_claim(target.claim_id,player.id) then
                tbg_cap_l:color(255,64,65)
                tbg_cap_r:color(255,64,65)
                tbg_body:color(255,64,65)
                tfg_body:color(255,103,127)
                tfgg_body:color(215,63,87)
                t_text:stroke_color(49,17,19,200)
                t_text:color(255,143,138)
              elseif target.claim_id ~= 0 then
                tbg_cap_l:color(81,80,178)
                tbg_cap_r:color(81,80,178)
                tbg_body:color(81,80,178)
                tfg_body:color(245,122,245)
                tfgg_body:color(81,80,178)
                t_text:stroke_color(44,19,44,200)
                t_text:color(255,132,255)
              else
                tbg_cap_l:color(181,131,59)
                tbg_cap_r:color(181,131,59)
                tbg_body:color(181,131,59)
                tfg_body:color(252,232,166)
                tfgg_body:color(212,192,126)
                t_text:stroke_color(51,47,38,200)
                t_text:color(255,255,193)
              end
            else
              --pc
              if target.in_party == true and target.id ~= player.id then
                tbg_cap_l:color(52, 200, 200)
                tbg_cap_r:color(52, 200, 200)
                tbg_body:color(52, 200, 200)
                tfg_body:color(128, 255, 255)
                tfgg_body:color(88, 215, 215)
                t_text:stroke_color(38,43,46,200)
                t_text:color(201, 255, 255)
              else
                tbg_cap_l:color(0, 100, 166)
                tbg_cap_r:color(0, 100, 166)
                tbg_body:color(0, 100, 166)
                tfg_body:color(163, 209, 245)
                tfgg_body:color(123, 189, 205)
                t_text:stroke_color(50,50,50,200)
                t_text:color(255, 255, 255)
              end
            end
        end

    else
        tbg_cap_l:hide()
        tbg_cap_r:hide()
        tbg_body:hide()
        tfg_body:hide()
        tfgg_body:hide()
        tfgg_body:width(0)
        t_text:hide()
    end
end
