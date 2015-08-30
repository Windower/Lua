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
    if visible == true then		
        tbg_cap_l:show()
        tbg_cap_r:show()
        tbg_body:show()
        tfg_body:show()
        tfgg_body:show()
        t_text:show()
        
        target = windower.ffxi.get_mob_by_target('t')
        
        if target ~= nil then
            local player = windower.ffxi.get_player()
            local i = target.hpp / 100
            local new_width = math.floor(targetBarWidth * i)
            local old_width = tfgg_body:width()

            tfgg_body:width(0)
 
            local now = os.clock()
            if new_width ~= nil and new_width > 0 then
                if new_width < old_width and player.in_combat then
                    local x = old_width + math.floor(((new_width - old_width) * 0.1))
                    tfgg_body:width(x)
                elseif new_width >= old_width or not player.in_combat then
                    tfgg_body:width(new_width)
                end			
            end

            tfg_body:width(new_width)
            tbg_body:width(targetBarWidth) -- I still have no idea why removing this breaks the bg.

            t_text.name = target.name
            t_text.hpp = target.hpp
            t_text.debug = debug_string
            
            --Check claim_id with player and party_id
            if target.hpp == 0 then
                t_text:color(155, 155, 155)
            elseif check_claim(target.claim_id) then
                t_text:color(255, 204, 204)
            elseif target.in_party == true and target.id ~= player_id then
                t_text:color(102, 255, 255)
            elseif target.is_npc == false then
                t_text:color(255, 255, 255)
            elseif target.claim_id == 0 then
                t_text:color(230, 230, 138) 
            elseif target.claim_id ~= 0 then
                t_text:color(153, 102, 255)
            end			
        end
        
    else
        tbg_cap_l:hide()
        tbg_cap_r:hide()
        tbg_body:hide()
        tfg_body:hide()
        tfgg_body:hide()
        tfgg_body:size(0, 12)
        t_text:hide()
    end
end