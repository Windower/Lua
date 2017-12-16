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

targetBarHeight = 7
targetBarWidth = 300
subtargetBarHeight = 7
subtargetBarWidth = 200
visible = false
hasTarget = false

force_hide = false

bg_cap_path = windower.addon_path.. 'bg_cap.png'
bg_body_path = windower.addon_path.. 'bg_body.png'
fg_body_path = windower.addon_path.. 'fg_body.png'
pointer_path = windower.addon_path.. 'pointer_s.png'

center_screen = windower.get_windower_settings().x_res / 2 - targetBarWidth / 2

text_settings = {}
text_settings.pos = {}
text_settings.pos.x = center_screen
text_settings.pos.y = 50
text_settings.text = {}
text_settings.text.size = 14
text_settings.text.font = 'Arial'
text_settings.text.fonts = {'Arial'}
text_settings.text.stroke = {}
text_settings.text.stroke.width = 2
text_settings.text.stroke.alpha = 200
text_settings.text.stroke.red = 50
text_settings.text.stroke.green = 50
text_settings.text.stroke.blue = 50
text_settings.flags = {}
text_settings.flags.italic = true
text_settings.flags.bold = true
text_settings.flags.draggable = false
text_settings.bg = {}
text_settings.bg.visible = false

pointer_settings = {}
pointer_settings.pos = {}
pointer_settings.pos.x = center_screen
pointer_settings.pos.y = 50
pointer_settings.visible = true
pointer_settings.texture = {}
pointer_settings.texture.path = pointer_path
pointer_settings.texture.fit = true
pointer_settings.draggable = false

tbg_cap_settings = {}
tbg_cap_settings.pos = {}
tbg_cap_settings.pos.x = center_screen
tbg_cap_settings.pos.y = 50
tbg_cap_settings.visible = true
tbg_cap_settings.color = {}
tbg_cap_settings.color.alpha = 255
tbg_cap_settings.color.red = 150
tbg_cap_settings.color.green = 0
tbg_cap_settings.color.blue = 0
tbg_cap_settings.size = {}
tbg_cap_settings.size.width = 1
tbg_cap_settings.size.height = targetBarHeight
tbg_cap_settings.texture = {}
tbg_cap_settings.texture.path = bg_cap_path
tbg_cap_settings.texture.fit = true
tbg_cap_settings.repeatable = {}
tbg_cap_settings.repeatable.x = 1
tbg_cap_settings.repeatable.y = 1
tbg_cap_settings.draggable = false

stbg_cap_settings = {}
stbg_cap_settings.pos = {}
stbg_cap_settings.pos.x = center_screen
stbg_cap_settings.pos.y = 50
stbg_cap_settings.visible = true
stbg_cap_settings.color = {}
stbg_cap_settings.color.alpha = 255
stbg_cap_settings.color.red = 0
stbg_cap_settings.color.green = 51
stbg_cap_settings.color.blue = 255
stbg_cap_settings.size = {}
stbg_cap_settings.size.width = 1
stbg_cap_settings.size.height = subtargetBarHeight
stbg_cap_settings.texture = {}
stbg_cap_settings.texture.path = bg_cap_path
stbg_cap_settings.texture.fit = true
stbg_cap_settings.repeatable = {}
stbg_cap_settings.repeatable.x = 1
stbg_cap_settings.repeatable.y = 1
stbg_cap_settings.draggable = false

tbg_body_settings = {}
tbg_body_settings.pos = {}
tbg_body_settings.pos.x = center_screen
tbg_body_settings.pos.y = 50
tbg_body_settings.visible = true
tbg_body_settings.color = {}
tbg_body_settings.color.alpha = 255
tbg_body_settings.color.red = 150
tbg_body_settings.color.green = 0
tbg_body_settings.color.blue = 0
tbg_body_settings.size = {}
tbg_body_settings.size.width = targetBarWidth
tbg_body_settings.size.height = targetBarHeight
tbg_body_settings.texture = {}
tbg_body_settings.texture.path = bg_body_path
tbg_body_settings.texture.fit = true
tbg_body_settings.repeatable = {}
tbg_body_settings.repeatable.x = 1
tbg_body_settings.repeatable.y = 1
tbg_body_settings.draggable = false

stbg_body_settings = {}
stbg_body_settings.pos = {}
stbg_body_settings.pos.x = center_screen + 400
stbg_body_settings.pos.y = 65
stbg_body_settings.visible = true
stbg_body_settings.color = {}
stbg_body_settings.color.alpha = 255
stbg_body_settings.color.red = 0
stbg_body_settings.color.green = 51
stbg_body_settings.color.blue = 255
stbg_body_settings.size = {}
stbg_body_settings.size.width = subtargetBarWidth
stbg_body_settings.size.height = subtargetBarHeight
stbg_body_settings.texture = {}
stbg_body_settings.texture.path = bg_body_path
stbg_body_settings.texture.fit = true
stbg_body_settings.repeatable = {}
stbg_body_settings.repeatable.x = 1
stbg_body_settings.repeatable.y = 1
stbg_body_settings.draggable = false

tfgg_body_settings = {}
tfgg_body_settings.pos = {}
tfgg_body_settings.pos.x = center_screen
tfgg_body_settings.pos.y = 50
tfgg_body_settings.visible = true
tfgg_body_settings.color = {}
tfgg_body_settings.color.alpha = 200
tfgg_body_settings.color.red = 255
tfgg_body_settings.color.green = 0
tfgg_body_settings.color.blue = 0
tfgg_body_settings.size = {}
tfgg_body_settings.size.width = targetBarWidth
tfgg_body_settings.size.height = targetBarHeight
tfgg_body_settings.texture = {}
tfgg_body_settings.texture.path = fg_body_path
tfgg_body_settings.texture.fit = true
tfgg_body_settings.repeatable = {}
tfgg_body_settings.repeatable.x = 1
tfgg_body_settings.repeatable.y = 1
tfgg_body_settings.draggable = false

tfg_body_settings = {}
tfg_body_settings.pos = {}
tfg_body_settings.pos.x = center_screen
tfg_body_settings.pos.y = 50
tfg_body_settings.visible = true
tfg_body_settings.color = {}
tfg_body_settings.color.alpha = 255
tfg_body_settings.color.red = 255
tfg_body_settings.color.green = 51
tfg_body_settings.color.blue = 0
tfg_body_settings.size = {}
tfg_body_settings.size.width = targetBarWidth
tfg_body_settings.size.height = targetBarHeight
tfg_body_settings.texture = {}
tfg_body_settings.texture.path = fg_body_path
tfg_body_settings.texture.fit = true
tfg_body_settings.repeatable = {}
tfg_body_settings.repeatable.x = 1
tfg_body_settings.repeatable.y = 1
tfg_body_settings.draggable = false

stfg_body_settings = {}
stfg_body_settings.pos = {}
stfg_body_settings.pos.x = center_screen + 400
stfg_body_settings.pos.y = 65
stfg_body_settings.visible = true
stfg_body_settings.color = {}
stfg_body_settings.color.alpha = 255
stfg_body_settings.color.red = 0
stfg_body_settings.color.green = 102
stfg_body_settings.color.blue = 255
stfg_body_settings.size = {}
stfg_body_settings.size.width = subtargetBarWidth
stfg_body_settings.size.height = subtargetBarHeight
stfg_body_settings.texture = {}
stfg_body_settings.texture.path = fg_body_path
stfg_body_settings.texture.fit = true
stfg_body_settings.repeatable = {}
stfg_body_settings.repeatable.x = 1
stfg_body_settings.repeatable.y = 1
stfg_body_settings.draggable = false

defaults = {}
defaults.font = 'Arial'
defaults.font_size = 14
defaults.pos = {}
defaults.pos.x = 400
defaults.pos.y = 50

settings = config.load(defaults)
config.save(settings)

config.register(settings, function(settings_table)
    --Validating settings.xml values
    local nx = 0
    if settings_table.pos.x == nil or settings_table.pos.x < 0 then
        nx = center_screen
    else
        nx = settings_table.pos.x
    end

    text_settings.pos.x = nx - 8
    text_settings.pos.y = settings_table.pos.y - 15
    text_settings.text.font = settings_table.font
    text_settings.text.size = settings_table.font_size

    tbg_cap_settings.pos.x = nx
    tbg_cap_settings.pos.y = settings_table.pos.y

    stbg_cap_settings.pos.x = nx
    stbg_cap_settings.pos.y = settings_table.pos.y

    tbg_body_settings.pos.x = nx
    tbg_body_settings.pos.y = settings_table.pos.y

    stbg_body_settings.pos.x = nx
    stbg_body_settings.pos.y = settings_table.pos.y

    tfgg_body_settings.pos.x = nx
    tfgg_body_settings.pos.y = settings_table.pos.y

    tfg_body_settings.pos.x = nx
    tfg_body_settings.pos.y = settings_table.pos.y

    stfg_body_settings.pos.x = nx
    stfg_body_settings.pos.y = settings_table.pos.y

    pointer_settings.pos.y = settings_table.pos.y - 2

    tbg_cap_l = images.new(tbg_cap_settings)
    tbg_cap_r = images.new(tbg_cap_settings)
    tbg_body = images.new(tbg_body_settings)
    tfgg_body = images.new(tfgg_body_settings)
    tfg_body = images.new(tfg_body_settings)
    t_text = texts.new('  ${name|(Name)} ${debug|}', text_settings)

    pointer = images.new(pointer_settings)
    stbg_cap_l = images.new(stbg_cap_settings)
    stbg_cap_r = images.new(stbg_cap_settings)
    stbg_body = images.new(stbg_body_settings)
    stfg_body = images.new(stfg_body_settings)
    st_text = texts.new(' ${name|(Name)}', text_settings)

    tbg_cap_l:pos_x(tbg_cap_l:pos_x() - 1)
    tbg_cap_r:pos_x(tbg_cap_r:pos_x() + targetBarWidth + 1)

    pointer:pos_x(tbg_cap_r:pos_x() + 3)
    stbg_cap_l:pos_x(stbg_cap_l:pos_x() + 320)
    stbg_cap_r:pos_x(stbg_cap_r:pos_x() + subtargetBarWidth)
    stfg_body:pos_x(stfg_body:pos_x() + 320)
    stbg_body:pos_x(stbg_body:pos_x() + 320)
    st_text:pos_x(st_text:pos_x() + 324)
end)



check_claim = function(claim_id)
    if player_id == claim_id then
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
        hasTarget = false
    else
        visible = true
        hasTarget = true
	end
end

windower.register_event('keyboard', function(dik, flags, blocked)
  if dik == 70 and flags == true and (hasTarget == true) and visible == true then
    visible = false
  elseif dik == 70 and flags == true and (hasTarget == true) and visible == false then
    visible = true
  end
end)

windower.register_event('status change', function(new_status_id)
    if force_hide == false and (new_status_id == 4)  and (hasTarget == true) and visible == true then
        force_hide = true
        visible = false
    elseif force_hide and new_status_id ~= 4 and (hasTarget == true) and visible == false then
        force_hide = false
        visible = true
    end
end)
