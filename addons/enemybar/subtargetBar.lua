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

stbg_cap_l = images.new()
stbg_cap_r = images.new()
stbg_body = images.new()
stfg_body = images.new()
st_text = texts.new()

init_subtarget_images = function(...)
	stbg_cap_l:pos(settings.X + 399, settings.Y + 15)
	stbg_cap_l:path(bg_cap_path)
	stbg_cap_l:color(255, 255, 255, 255)
	stbg_cap_l:fit(true)
	stbg_cap_l:size(settings.subtargetBarWidth, settings.subtargetBarHeight)
	stbg_cap_l:repeat_xy(1, 1)
	
	stbg_cap_r:pos(settings.X + settings.subtargetBarWidth + 400, settings.Y + 15)
	stbg_cap_r:path(bg_cap_path)
	stbg_cap_r:color(255, 255, 255, 255)
	stbg_cap_r:fit(true)
	stbg_cap_r:size(settings.subtargetBarWidth, settings.subtargetBarHeight)
	stbg_cap_r:repeat_xy(1, 1)

	stbg_body:pos(settings.X + 400, settings.Y + 15)
	stbg_body:path(stbg_body_path)
	stbg_body:fit(true)
	stbg_body:size(settings.subtargetBarWidth, settings.subtargetBarHeight)
	stbg_body:repeat_xy(1, 1)
	
    stfg_body:pos(settings.X + 400, settings.Y + 15)
	stfg_body:path(stfg_body_path)
	stfg_body:fit(true)
	stfg_body:size(settings.subtargetBarWidth, settings.subtargetBarHeight)
	stfg_body:repeat_xy(1, 1)
	
	st_text:pos(settings.X + 400, settings.Y + 15)
	st_text:font(settings.font)
	st_text:size(settings.textSize)
	st_text:bold(true)
	st_text:text('Sub Name')
	
	st_text:bg_visible(false)
	st_text:color(255, 255, 255)
	st_text:alpha(255)
	
	st_text:stroke_width(settings.strokeSize)
	st_text:stroke_color(50, 50, 50)
	st_text:stroke_transparency(127)
end

render_subtarget_bar = function(...)
	if visible == true then
		local subtarget = windower.ffxi.get_mob_by_target('st')
		local player = windower.ffxi.get_player()
		
		if subtarget ~= nil then
			stbg_cap_l:show()
			stbg_cap_r:show()
			stbg_body:show()
			stfg_body:show()
			st_text:show()
			
			local old_width = stfg_body:width()
			local i = subtarget.hpp / 100
			local new_width = math.floor(198 * i)	
			
			if settings.style == 1 then
				if new_width ~= nil and new_width > 0 then
					if old_width > new_width then
						local last_update = 0
						local x = old_width + math.ceil(((new_width - old_width) * 0.1))
						stfg_body:size(x, 12)
			
						local now = os.clock()
						if now - last_update > 0.5 then
							last_update = now
						end
					elseif old_width <= new_width then
						stfg_body:size(new_width, 12)
					end
				end
			else
				stfg_body:size(new_width, 12)
			end
						
			stbg_body:size(198, 12)
			st_text:text('  ' .. subtarget.name)
			
			if check_claim(subtarget.claim_id) then
				st_text:color(255, 80, 80)
			elseif subtarget.in_party == true and subtarget.id ~= player.id then
				st_text:color(102, 255, 255)
			elseif subtarget.is_npc == false then
				st_text:color(255, 255, 255)
			elseif subtarget.claim_id == 0 then
				st_text:color(230, 230, 138) 
			elseif subtarget.hpp == 0 then
				st_text:color(155, 155, 155)
			elseif subtarget.claim_id ~= 0 then
				st_text:color(153, 102, 255)
			end
		else
			stbg_cap_l:hide()
			stbg_cap_r:hide()
			stbg_body:hide()
			stfg_body:hide()
			st_text:hide()
		end
	end
end