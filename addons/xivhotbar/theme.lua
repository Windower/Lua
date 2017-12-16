--[[
        Copyright © 2017, SirEdeonX
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of xivhotbar nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local theme = {}

theme.apply = function (settings)
    local options = {}

    options.hotbar_number = 3
    options.hide_empty_slots = settings.Hotbar.HideEmptySlots
    options.hide_action_names = settings.Hotbar.HideActionName
    options.hide_action_cost = settings.Hotbar.HideActionCost
    options.hide_action_element = settings.Hotbar.HideActionElement
    options.hide_recast_animation = settings.Hotbar.HideRecastAnimation
    options.hide_recast_text = settings.Hotbar.HideRecastText
    options.hide_battle_notice = settings.Hotbar.HideBattleNotice

    options.battle_notice_theme = settings.Theme.BattleNotice
    options.slot_theme = settings.Theme.Slot
    options.frame_theme = settings.Theme.Frame

    options.slot_opacity = settings.Style.SlotAlpha
    options.slot_spacing = settings.Style.SlotSpacing
    options.hotbar_spacing = settings.Style.HotbarSpacing
    options.offset_x = settings.Style.OffsetX
    options.offset_y = settings.Style.OffsetY

    options.feedback_max_opacity = settings.Color.Feedback.Opacity
    options.feedback_speed = settings.Color.Feedback.Speed
    options.disabled_slot_opacity = settings.Color.Disabled.Opacity

    options.font = settings.Texts.Font
    options.font_size = settings.Texts.Size
    options.font_alpha = settings.Texts.Color.Alpha
    options.font_color_red = settings.Texts.Color.Red
    options.font_color_green = settings.Texts.Color.Green
    options.font_color_blue = settings.Texts.Color.Blue
    options.font_stroke_width = settings.Texts.Stroke.Width
    options.font_stroke_alpha = settings.Texts.Stroke.Alpha
    options.font_stroke_color_red = settings.Texts.Stroke.Red
    options.font_stroke_color_green = settings.Texts.Stroke.Green
    options.font_stroke_color_blue = settings.Texts.Stroke.Blue
    options.mp_cost_color_red = settings.Color.MpCost.Red
    options.mp_cost_color_green = settings.Color.MpCost.Green
    options.mp_cost_color_blue = settings.Color.MpCost.Blue
    options.tp_cost_color_red = settings.Color.TpCost.Red
    options.tp_cost_color_green = settings.Color.TpCost.Green
    options.tp_cost_color_blue = settings.Color.TpCost.Blue
    options.text_offset_x = settings.Texts.OffsetX
    options.text_offset_y = settings.Texts.OffsetY

    options.controls_battle_mode = settings.Controls.ToggleBattleMode

    return options
end

return theme