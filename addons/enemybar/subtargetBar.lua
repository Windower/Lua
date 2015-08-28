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
txtSubTarget = texts.new()

init_subTargetImages = function(...)
	stbg_cap_l:pos(settings.global.X + 399, settings.global.Y + 15)
	stbg_cap_l:path(settings.global.bg_cap_path)
	stbg_cap_l:color(255, 255, 255, 255)
	stbg_cap_l:fit(true)
	stbg_cap_l:size(settings.global.subtargetBarWidth, settings.global.subtargetBarHeight)
	stbg_cap_l:repeat_xy(1, 1)
	
	stbg_cap_r:pos(settings.global.X + settings.global.subtargetBarWidth + 400, settings.global.Y + 15)
	stbg_cap_r:path(settings.global.bg_cap_path)
	stbg_cap_r:color(255, 255, 255, 255)
	stbg_cap_r:fit(true)
	stbg_cap_r:size(settings.global.subtargetBarWidth, settings.global.subtargetBarHeight)
	stbg_cap_r:repeat_xy(1, 1)

	stbg_body:pos(settings.global.X + 400, settings.global.Y + 15)
	stbg_body:path(settings.global.stbg_body_path)
	stbg_body:fit(true)
	stbg_body:size(settings.global.subtargetBarWidth, settings.global.subtargetBarHeight)
	stbg_body:repeat_xy(1, 1)
	
    stfg_body:pos(settings.global.X + 400, settings.global.Y + 15)
	stfg_body:path(settings.global.stfg_body_path)
	stfg_body:fit(true)
	stfg_body:size(settings.global.subtargetBarWidth, settings.global.subtargetBarHeight)
	stfg_body:repeat_xy(1, 1)
	
	txtSubTarget:pos(settings.global.X + 400, settings.global.Y + 15)
	txtSubTarget:font(settings.global.font)
	txtSubTarget:size(settings.global.size)
	txtSubTarget:bold(true)
	txtSubTarget:text('Sub Name')
	
	txtSubTarget:bg_visible(false)
	txtSubTarget:color(255, 255, 255)
	txtSubTarget:alpha(255)
	
	txtSubTarget:stroke_width(settings.global.strkSize)
	txtSubTarget:stroke_color(50, 50, 50)
	txtSubTarget:stroke_transparency(127)
end

renderSubTargetBar = function(...)
	if settings.global.visible == true then
		local subtarget = windower.ffxi.get_mob_by_target('st')
		
		if subtarget ~= nil then
			stbg_cap_l:show()
			stbg_cap_r:show()
			stbg_body:show()
			stfg_body:show()
			txtSubTarget:show()
			
			local old_width = stfg_body:width()
			local i = subtarget.hpp / 100
			local new_width = math.floor(198 * i)	
			
			if settings.global.style == 1 then
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
			txtSubTarget:text('  ' .. subtarget.name)
		else
			stbg_cap_l:hide()
			stbg_cap_r:hide()
			stbg_body:hide()
			stfg_body:hide()
			txtSubTarget:hide()
		end
	end
end