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
            * Neither the name of xivbar nor the
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

-- setup variables
background = images.new()

hp_foreground = images.new()
mp_foreground = images.new()
tp_foreground = images.new()

hp_text = texts.new(settings.Texts.Text)
mp_text = texts.new(settings.Texts.Text)
tp_text = texts.new(settings.Texts.Text)

-- style variables
total_height = 8
total_width = 472
bar_width = 142
bar_spacing = 8

bar_background = settings.Images.FFXIV.Background
bar_hp = settings.Images.FFXIV.Hp
bar_mp = settings.Images.FFXIV.Mp
bar_tp = settings.Images.FFXIV.Tp
font = settings.Texts.FFXIV.Font
font_size = settings.Texts.FFXIV.Size
font_alpha = settings.Texts.FFXIV.Alpha
font_color_red = settings.Texts.FFXIV.Red
font_color_green = settings.Texts.FFXIV.Green
font_color_blue = settings.Texts.FFXIV.Blue
font_stroke_width = settings.Texts.FFXIV.Stroke.Width
font_stroke_alpha = settings.Texts.FFXIV.Stroke.Alpha
font_stroke_color_red = settings.Texts.FFXIV.Stroke.Red
font_stroke_color_green = settings.Texts.FFXIV.Stroke.Green
font_stroke_color_blue = settings.Texts.FFXIV.Stroke.Blue

if settings.Bars.Compact then
    bar_background = settings.Images.FFXIV.BackgroundCompact
    total_width = 422
    bar_width = 127
    bar_spacing = 4
end

if settings.Bars.Style == 'ffxi' then
    bar_background = settings.Images.FFXI.Background
    bar_hp = settings.Images.FFXI.Hp
    bar_mp = settings.Images.FFXI.Mp
    bar_tp = settings.Images.FFXI.Tp

    if settings.Bars.Compact then
        bar_background = settings.Images.FFXI.BackgroundCompact
    end

    font = settings.Texts.FFXI.Font
    font_size = settings.Texts.FFXI.Size
    font_alpha = settings.Texts.FFXI.Alpha
    font_color_red = settings.Texts.FFXI.Red
    font_color_green = settings.Texts.FFXI.Green
    font_color_blue = settings.Texts.FFXI.Blue
    font_stroke_width = settings.Texts.FFXI.Stroke.Width
    font_stroke_alpha = settings.Texts.FFXI.Stroke.Alpha
    font_stroke_color_red = settings.Texts.FFXI.Stroke.Red
    font_stroke_color_green = settings.Texts.FFXI.Stroke.Green
    font_stroke_color_blue = settings.Texts.FFXI.Stroke.Blue
end

-- control variables
hide_bars = false
ready = false
hp_update = false
mp_update = false
tp_update = false