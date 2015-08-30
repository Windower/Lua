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

tbg_cap_l = images.new(tbg_cap_settings)
tbg_cap_r = images.new(tbg_cap_settings)
tbg_body = images.new(tbg_body_settings)
tfgg_body = images.new(tfgg_body_settings)
tfg_body = images.new(tfg_body_settings)
t_text = texts.new('  ${name|(Name)} - HP: ${hpp|(100)}% ${debug|}', settings.textSettings, settings)

init_target_images = function(...)
    tbg_cap_l:pos(settings.pos.x - 1, settings.pos.y)
    tbg_cap_r:pos(settings.pos.x + settings.targetBarWidth, settings.pos.y)
end

timer = 0

render_target_bar = function (...)
    if visible == true then		
        tbg_cap_l:show()
        tbg_cap_r:show()
        tbg_body:show()
        tfg_body:show()
        tfgg_body:show()
        t_text:show()
        
        local target = windower.ffxi.get_mob_by_target('t')
        local player = windower.ffxi.get_player()
        local party = windower.ffxi.get_party()

        if target ~= nil then
            local i = target.hpp / 100
            local new_width = math.floor(settings.targetBarWidth * i)
            local old_width = tfgg_body:width()

            tfgg_body:size(0, 12)
 
            local now = os.clock()
            if new_width ~= nil and new_width > 0 then
                if new_width < old_width and player.in_combat then
                    local x = old_width + math.floor(((new_width - old_width) * 0.1))
                    tfgg_body:size(x, 12)
                elseif new_width >= old_width or not player.in_combat then
                    tfgg_body:size(new_width, 12)
                end			
            end

            tfg_body:size(new_width ,12)	
            tbg_body:size(598, 12)

            t_text.name = target.name
            t_text.hpp = target.hpp
            --t_text.debug = tfgg_body:width()..new_width

            --Check claim_id with player and party_id
            if target.hpp == 0 then
                t_text:color(155, 155, 155)
            elseif check_claim(target.claim_id) then
                t_text:color(255, 204, 204)
            elseif target.in_party == true and target.id ~= player.id then
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