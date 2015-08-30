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


defaults = {}
defaults.targetBarHeight = 12
defaults.targetBarWidth = 598
defaults.subtargetBarHeight = 12
defaults.subtargetBarWidth = 198
defaults.pos = {}
defaults.pos.x = windower.get_windower_settings().x_res / 2 - defaults.targetBarWidth / 2
defaults.pos.y = 50

defaults.textSettings = {}
defaults.textSettings.pos = {}
defaults.textSettings.pos.x = defaults.pos.x
defaults.textSettings.pos.y = defaults.pos.y
defaults.textSettings.text = {}
defaults.textSettings.text.size = 14
defaults.textSettings.text.font = 'Arial'
defaults.textSettings.text.stroke = {}
defaults.textSettings.text.stroke.width = 2
defaults.textSettings.text.stroke.alpha = 127
defaults.textSettings.text.stroke.red = 50
defaults.textSettings.text.stroke.green = 50
defaults.textSettings.text.stroke.blue = 50 
defaults.textSettings.flags = {}
defaults.textSettings.flags.bold = true
defaults.textSettings.flags.draggable = false
defaults.textSettings.bg = {}
defaults.textSettings.bg.visible = false

visible = false

settings = config.load(defaults)
config.save(settings)

bg_cap_path = windower.addon_path.. 'bg_cap.png'
bg_body_path = windower.addon_path.. 'bg_body.png'
fg_body_path = windower.addon_path.. 'fg_body.png'

tbg_cap_settings = {}
tbg_cap_settings.pos = {}
tbg_cap_settings.pos.x = settings.pos.x
tbg_cap_settings.pos.y = settings.pos.y
tbg_cap_settings.visible = true
tbg_cap_settings.color = {}
tbg_cap_settings.color.alpha = 255
tbg_cap_settings.color.red = 150
tbg_cap_settings.color.green = 0
tbg_cap_settings.color.blue = 0
tbg_cap_settings.size = {}
tbg_cap_settings.size.width = 1
tbg_cap_settings.size.height = 12
tbg_cap_settings.texture = {}
tbg_cap_settings.texture.path = bg_cap_path
tbg_cap_settings.texture.fit = true
tbg_cap_settings.repeatable = {}
tbg_cap_settings.repeatable.x = 1
tbg_cap_settings.repeatable.y = 1
tbg_cap_settings.draggable = false

stbg_cap_settings = {}
stbg_cap_settings.pos = {}
stbg_cap_settings.pos.x = settings.pos.x
stbg_cap_settings.pos.y = settings.pos.y
stbg_cap_settings.visible = true
stbg_cap_settings.color = {}
stbg_cap_settings.color.alpha = 255
stbg_cap_settings.color.red = 0
stbg_cap_settings.color.green = 51
stbg_cap_settings.color.blue = 255
stbg_cap_settings.size = {}
stbg_cap_settings.size.width = 1
stbg_cap_settings.size.height = 12
stbg_cap_settings.texture = {}
stbg_cap_settings.texture.path = bg_cap_path
stbg_cap_settings.texture.fit = true
stbg_cap_settings.repeatable = {}
stbg_cap_settings.repeatable.x = 1
stbg_cap_settings.repeatable.y = 1
stbg_cap_settings.draggable = false

tbg_body_settings = {}
tbg_body_settings.pos = {}
tbg_body_settings.pos.x = settings.pos.x
tbg_body_settings.pos.y = settings.pos.y
tbg_body_settings.visible = true
tbg_body_settings.color = {}
tbg_body_settings.color.alpha = 255
tbg_body_settings.color.red = 150
tbg_body_settings.color.green = 0
tbg_body_settings.color.blue = 0
tbg_body_settings.size = {}
tbg_body_settings.size.width = 598
tbg_body_settings.size.height = 12
tbg_body_settings.texture = {}
tbg_body_settings.texture.path = bg_body_path
tbg_body_settings.texture.fit = true
tbg_body_settings.repeatable = {}
tbg_body_settings.repeatable.x = 1
tbg_body_settings.repeatable.y = 1
tbg_body_settings.draggable = false

stbg_body_settings = {}
stbg_body_settings.pos = {}
stbg_body_settings.pos.x = settings.pos.x
stbg_body_settings.pos.y = settings.pos.y
stbg_body_settings.visible = true
stbg_body_settings.color = {}
stbg_body_settings.color.alpha = 255
stbg_body_settings.color.red = 0
stbg_body_settings.color.green = 51
stbg_body_settings.color.blue = 255
stbg_body_settings.size = {}
stbg_body_settings.size.width = 0
stbg_body_settings.size.height = 12
stbg_body_settings.texture = {}
stbg_body_settings.texture.path = bg_body_path
stbg_body_settings.texture.fit = true
stbg_body_settings.repeatable = {}
stbg_body_settings.repeatable.x = 1
stbg_body_settings.repeatable.y = 1
stbg_body_settings.draggable = false

tfgg_body_settings = {}
tfgg_body_settings.pos = {}
tfgg_body_settings.pos.x = settings.pos.x
tfgg_body_settings.pos.y = settings.pos.y
tfgg_body_settings.visible = true
tfgg_body_settings.color = {}
tfgg_body_settings.color.alpha = 200
tfgg_body_settings.color.red = 255
tfgg_body_settings.color.green = 0
tfgg_body_settings.color.blue = 0
tfgg_body_settings.size = {}
tfgg_body_settings.size.width = 0
tfgg_body_settings.size.height = 12
tfgg_body_settings.texture = {}
tfgg_body_settings.texture.path = fg_body_path
tfgg_body_settings.texture.fit = true
tfgg_body_settings.repeatable = {}
tfgg_body_settings.repeatable.x = 1
tfgg_body_settings.repeatable.y = 1
tfgg_body_settings.draggable = false

tfg_body_settings = {}
tfg_body_settings.pos = {}
tfg_body_settings.pos.x = settings.pos.x
tfg_body_settings.pos.y = settings.pos.y
tfg_body_settings.visible = true
tfg_body_settings.color = {}
tfg_body_settings.color.alpha = 255
tfg_body_settings.color.red = 255
tfg_body_settings.color.green = 51
tfg_body_settings.color.blue = 0
tfg_body_settings.size = {}
tfg_body_settings.size.width = 0
tfg_body_settings.size.height = 12
tfg_body_settings.texture = {}
tfg_body_settings.texture.path = fg_body_path
tfg_body_settings.texture.fit = true
tfg_body_settings.repeatable = {}
tfg_body_settings.repeatable.x = 1
tfg_body_settings.repeatable.y = 1
tfg_body_settings.draggable = false

stfg_body_settings = {}
stfg_body_settings.pos = {}
stfg_body_settings.pos.x = settings.pos.x
stfg_body_settings.pos.y = settings.pos.y
stfg_body_settings.visible = true
stfg_body_settings.color = {}
stfg_body_settings.color.alpha = 255
stfg_body_settings.color.red = 0
stfg_body_settings.color.green = 102
stfg_body_settings.color.blue = 255
stfg_body_settings.size = {}
stfg_body_settings.size.width = 0
stfg_body_settings.size.height = 12
stfg_body_settings.texture = {}
stfg_body_settings.texture.path = fg_body_path
stfg_body_settings.texture.fit = true
stfg_body_settings.repeatable = {}
stfg_body_settings.repeatable.x = 1
stfg_body_settings.repeatable.y = 1
stfg_body_settings.draggable = false

require('targetBar')
require('subtargetBar')

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
        timer = os.clock()
		visible = true
	end
end