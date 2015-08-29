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

tbg_cap_l = images.new()
tbg_cap_r = images.new()
tbg_body = images.new()
tfg_body = images.new()
t_text = texts.new()



init_target_images = function(...)
	tbg_cap_l:pos(settings.X - 1, settings.Y)
	tbg_cap_l:path(bg_cap_path)
	tbg_cap_l:color(255, 255, 255, 255)
	tbg_cap_l:fit(true)
	tbg_cap_l:size(settings.targetBarWidth, settings.targetBarHeight)
	tbg_cap_l:repeat_xy(1, 1)
	
	tbg_cap_r:pos(settings.X + settings.targetBarWidth, settings.Y)
	tbg_cap_r:path(bg_cap_path)
	tbg_cap_r:color(255, 255, 255, 255)
	tbg_cap_r:fit(true)
	tbg_cap_r:size(settings.targetBarWidth, settings.targetBarHeight)
	tbg_cap_r:repeat_xy(1, 1)

	tbg_body:pos(settings.X, settings.Y)
	tbg_body:path(tbg_body_path)
	tbg_body:fit(true)
	tbg_body:size(598, 12)
	tbg_body:repeat_xy(1, 1)
		
	tfg_body:pos(settings.X, settings.Y)
	tfg_body:path(tfg_body_path)
	tfg_body:fit(true)
	tfg_body:size(settings.targetBarWidth, settings.targetBarHeight)
	tfg_body:repeat_xy(1, 1)
	
	t_text:pos(settings.X, settings.Y)
	t_text:font(settings.font)
	t_text:size(settings.textSize)
	t_text:bold(true)
	t_text:text('Enemy Name')
	
	t_text:bg_visible(false)
	t_text:color(255, 255, 255)
	t_text:alpha(255)
	
	t_text:stroke_width(settings.strokeSize)
	t_text:stroke_color(50, 50, 50)
	t_text:stroke_transparency(127)
end

render_target_bar = function (...)
	if visible == true then
		tbg_cap_l:show()
		tbg_cap_r:show()
		tbg_body:show()
		tfg_body:show()
		t_text:show()
		
		local target = windower.ffxi.get_mob_by_target('t')
		local player = windower.ffxi.get_player()
		local party = windower.ffxi.get_party()
		
		if target ~= nil then
			local old_width = tfg_body:width()
			local i = target.hpp / 100
			local new_width = math.floor(settings.targetBarWidth * i)
			
			if settings.style == 1 then
				--Animated Style 'borrowed' from Morath's barfiller
				if new_width ~= nil and new_width > 0 then
					if old_width > new_width then
						local last_update = 0
						local x = old_width + math.ceil(((new_width - old_width) * 0.1))
						tfg_body:size(x, 12)
			
						local now = os.clock()
						if now - last_update > 0.5 then
							last_update = now
						end
					elseif old_width <= new_width then
						tfg_body:size(new_width, 12)
					end
				end
			else
				--Classic Style
				tfg_body:size(new_width, 12)
			end
			
			tbg_body:size(598, 12)
			t_text:text('  ' .. target.name .. ' - HP ' .. target.hpp .. '%')
			
			--Check claim_id with player and party_id 
			if check_claim(target.claim_id) then
				t_text:color(255, 80, 80)
			elseif target.in_party == true and target.id ~= player.id then
				t_text:color(102, 255, 255)
			elseif target.is_npc == false then
				t_text:color(255, 255, 255)
			elseif target.claim_id == 0 then
				t_text:color(230, 230, 138) 
			elseif target.hpp == 0 then
				t_text:color(155, 155, 155)
			elseif target.claim_id ~= 0 then
				t_text:color(153, 102, 255)
			end
		end
		
	else
		tbg_cap_l:hide()
		tbg_cap_r:hide()
		tbg_body:hide()
		tfg_body:hide()
		t_text:hide()
	end
end