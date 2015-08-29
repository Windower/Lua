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

config = require('config')
file = require('files')
packets = require('packets')
images = require('images')
texts = require('texts')
require('targetBar')
require('subtargetBar')

defaults = {}
defaults.targetBarHeight = 12
defaults.targetBarWidth = 598
defaults.subtargetBarHeight = 12
defaults.subtargetBarWidth = 198
defaults.X = windower.get_windower_settings().x_res / 2 - defaults.targetBarWidth / 2
defaults.Y = 50
defaults.font = 'Arial'
defaults.textSize = 14
defaults.strokeSize = 1
defaults.style = 0

bg_cap_path = windower.addon_path.. 'bg_cap.png'
stbg_body_path = windower.addon_path.. 'stbg_body.png'
stfg_body_path = windower.addon_path.. 'stfg_body.png'
tbg_body_path = windower.addon_path.. 'tbg_body.png'
tfg_body_path = windower.addon_path.. 'tfg_body.png'
visible = false

settings = config.load(defaults)
config.save(settings)

init_images = function()
	init_target_images()
	init_subtarget_images()		
end

check_claim = function(claim_id)
    local player = windower.ffxi.get_player()
    local party = windower.ffxi.get_party()
    
    if player.id == claim_id then
        return true
    else
        for i = 1, 5, 1 do
            member = windower.ffxi.get_mob_by_target('p'..i)
            if member == nil then
                -- do nothing
            elseif member.id == claim_id then 
                return true
            end
        end
    end
    return false
end

target_change = function(index)
	if index == 0 then
		visible = false
	else
		visible = true
	end
end