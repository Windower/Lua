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


local ui = {}

local text_setup = {
    flags = {
        draggable = false
    }
}

local images_setup = {
    draggable = false
}

-- ui variables
ui.background = images.new(images_setup)

ui.hp_bar = images.new(images_setup)
ui.mp_bar = images.new(images_setup)
ui.tp_bar = images.new(images_setup)

ui.hp_text = texts.new(text_setup)
ui.mp_text = texts.new(text_setup)
ui.tp_text = texts.new(text_setup)

-- setup images
function setup_image(image, path)
    image:path(path)
    image:repeat_xy(1, 1)
    image:draggable(false)
    image:fit(true)
    image:show()
end

-- setup text
function setup_text(text, theme_options)
    text:bg_alpha(0)
    text:bg_visible(false)
    text:font(theme_options.font)
    text:size(theme_options.font_size)
    text:color(theme_options.font_color_red, theme_options.font_color_green, theme_options.font_color_blue)
    text:stroke_transparency(theme_options.font_stroke_alpha)
    text:stroke_color(theme_options.font_stroke_color_red, theme_options.font_stroke_color_green, theme_options.font_stroke_color_blue)
    text:stroke_width(theme_options.font_stroke_width)
    text:right_justified()
    text:show()
end

-- load the images and text
function ui:load(theme_options)
    setup_image(self.background, theme_options.bar_background)
    setup_image(self.hp_bar, theme_options.bar_hp)
    setup_image(self.mp_bar, theme_options.bar_mp)
    setup_image(self.tp_bar, theme_options.bar_tp)
    setup_text(self.hp_text, theme_options)
    setup_text(self.mp_text, theme_options)
    setup_text(self.tp_text, theme_options)

    self:position(theme_options)
end

-- position the images and text
function ui:position(theme_options)
    local x = windower.get_windower_settings().x_res / 2 - (theme_options.total_width / 2) + theme_options.offset_x
    local y = windower.get_windower_settings().y_res - 60 + theme_options.offset_y

    self.background:pos(x, y)

    self.hp_bar:pos(x + 15 + theme_options.bar_offset, y + 2)
    self.mp_bar:pos(x + 25 + theme_options.bar_offset + theme_options.bar_width + theme_options.bar_spacing, y + 2)
    self.tp_bar:pos(x + 35 + theme_options.bar_offset + (theme_options.bar_width*2) + (theme_options.bar_spacing*2), y + 2)
    self.hp_bar:width(0)
    self.mp_bar:width(0)
    self.tp_bar:width(0)

    self.hp_text:pos(x + 65 + theme_options.text_offset, self.background:pos_y() + 2)
    self.mp_text:pos(x + 80 + theme_options.text_offset + theme_options.bar_width + theme_options.bar_spacing, self.background:pos_y() + 2)
    self.tp_text:pos(x + 90 + theme_options.text_offset + (theme_options.bar_width*2) + (theme_options.bar_spacing*2), self.background:pos_y() + 2)
end

-- hide ui
function ui:hide()
    self.background:hide()
    self.hp_bar:hide()
    self.hp_text:hide()
    self.mp_bar:hide()
    self.mp_text:hide()
    self.tp_bar:hide()
    self.tp_text:hide()
end

-- show ui
function ui:show()
    self.background:show()
    self.hp_bar:show()
    self.hp_text:show()
    self.mp_bar:show()
    self.mp_text:show()
    self.tp_bar:show()
    self.tp_text:show()
end

return ui