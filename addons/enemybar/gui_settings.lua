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
defaults.global = {}
defaults.global.targetBarHeight = 12
defaults.global.targetBarWidth = 598
defaults.global.subtargetBarHeight = 12
defaults.global.subtargetBarWidth = 198
defaults.global.X = windower.get_windower_settings().x_res / 2 - defaults.global.targetBarWidth / 2
defaults.global.Y = 50

defaults.global.bg_cap_path = windower.addon_path.. 'bg_cap.png'
defaults.global.tbg_body_path = windower.addon_path.. 'tbg_body.png'
defaults.global.tfg_body_path = windower.addon_path.. 'tfg_body.png'
defaults.global.stbg_body_path = windower.addon_path.. 'stbg_body.png'
defaults.global.stfg_body_path = windower.addon_path.. 'stfg_body.png'

defaults.global.visible = false
defaults.global.font = 'Arial'
defaults.global.textSize = 14
defaults.global.strokeSize = 1
defaults.global.style = 0

settings = config.load(defaults)
config.save(settings)

function init_images()
	init_target_images()
	init_subtarget_images()		
end

target_change = function(index)
	if index == 0 then
		settings.global.visible = false
	else
		settings.global.visible = true
	end
end