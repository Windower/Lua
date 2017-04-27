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

function setup_image(image, path)
    image:path(path)
    image:repeat_xy(1, 1)
    image:draggable(false)
    image:fit(true)
    image:show()
end

function setup_text(text)
    text:bg_alpha(0)
    text:bg_visible(false)
    text:font(font)
    text:size(font_size)
    text:color(font_color_red, font_color_green, font_color_blue)
    text:stroke_transparency(font_stroke_alpha)
    text:stroke_color(font_stroke_color_red, font_stroke_color_green, font_stroke_color_blue)
    text:stroke_width(font_stroke_width)
    text:right_justified()
    text:show()
end

function position_images()
    local x = windower.get_windower_settings().x_res / 2 - (total_width / 2) + settings.Bars.OffsetX
    local y = windower.get_windower_settings().y_res - 60 + settings.Bars.OffsetY

    background:pos(x, y)

    hp_foreground:pos(x + 5, y + 2)
    mp_foreground:pos(x + 15 + bar_width + bar_spacing, y + 2)
    tp_foreground:pos(x + 25 + (bar_width*2) + (bar_spacing*2), y + 2)
    hp_foreground:width(0)
    mp_foreground:width(0)
    tp_foreground:width(0)
end

function position_text()
    local x = windower.get_windower_settings().x_res / 2 - (total_width / 2) + settings.Bars.OffsetX

    hp_text:pos(x + 50, background:pos_y() + 4)
    mp_text:pos(x + 65 + bar_width + bar_spacing, background:pos_y() + 4)
    tp_text:pos(x + 75 + (bar_width*2) + (bar_spacing*2), background:pos_y() + 4)
end

function load_images()
    setup_image(background, bar_background)

    setup_image(hp_foreground, bar_hp)
    setup_image(mp_foreground, bar_mp)
    setup_image(tp_foreground, bar_tp)

    position_images()
end

function load_text()
    setup_text(hp_text)
    setup_text(mp_text)
    setup_text(tp_text)

    position_text()
end

function update_hp()
    local info         = windower.ffxi.get_player()
    local old_hp_width = hp_foreground:width()
    local new_hp_width = math.floor((info.vitals.hpp / 100) * bar_width)

    if new_hp_width ~= nil and new_hp_width >= 0 then
        if old_hp_width < new_hp_width then
            local x = old_hp_width + math.ceil(((new_hp_width - old_hp_width) * 0.1))

            if x > bar_width then
                x = bar_width
            end

            hp_foreground:show()
            hp_foreground:size(x, total_height)
        elseif old_hp_width > new_hp_width then
            local x = old_hp_width - math.ceil(((old_hp_width - new_hp_width) * 0.1))

            if x < 0 then
                x = 0
            end

            hp_foreground:show()
            hp_foreground:size(x, total_height)
        elseif old_hp_width == new_hp_width then
            if new_hp_width == 0 then
                hp_foreground:hide()
            end
            hp_update = false
        end
    end

    hp_text:clear()
    hp_text:append('' .. info.vitals.hp)
end

function update_mp()
    local info         = windower.ffxi.get_player()
    local old_mp_width = mp_foreground:width()
    local new_mp_width = math.floor((info.vitals.mpp / 100) * bar_width)

    if new_mp_width ~= nil and new_mp_width >= 0 then
        if old_mp_width < new_mp_width then
            local x = old_mp_width + math.ceil(((new_mp_width - old_mp_width) * 0.1))

            if x > bar_width then
                x = bar_width
            end

            mp_foreground:show()
            mp_foreground:size(x, total_height)
        elseif old_mp_width > new_mp_width then
            local x = old_mp_width - math.ceil(((old_mp_width - new_mp_width) * 0.1))

            if x < 0 then
                x = 0
            end

            mp_foreground:show()
            mp_foreground:size(x, total_height)
        elseif old_mp_width == new_mp_width then
            if new_mp_width == 0 then
                mp_foreground:hide()
            end
            mp_update = false
        end
    end

    mp_text:clear()
    mp_text:append('' .. info.vitals.mp)
end

function update_tp()
    local info         = windower.ffxi.get_player()
    local old_tp_width = tp_foreground:width()
    local new_tp_width = bar_width

    if info.vitals.tp < 1000 then
        new_tp_width = math.floor((info.vitals.tp / 1000) * bar_width)
    end

    if new_tp_width ~= nil and new_tp_width >= 0 then
        if old_tp_width < new_tp_width then
            local x = old_tp_width + math.ceil(((new_tp_width - old_tp_width) * 0.1))

            if x > bar_width then
                x = bar_width
            end

            tp_foreground:show()
            tp_foreground:size(x, total_height)
        elseif old_tp_width > new_tp_width then
            local x = old_tp_width - math.ceil(((old_tp_width - new_tp_width) * 0.1))

            if x < 0 then
                x = 0
            end

            tp_foreground:show()
            tp_foreground:size(x, total_height)
        elseif old_tp_width == new_tp_width then
            if new_tp_width == 0 then
                tp_foreground:hide()
            end
            tp_update = false
        end
    end

    tp_text:clear()
    tp_text:append('' .. info.vitals.tp)
end

function hide()
    background:hide()
    hp_foreground:hide()
    hp_text:hide()
    mp_foreground:hide()
    mp_text:hide()
    tp_foreground:hide()
    tp_text:hide()
    ready = false
end

function show()
    background:show()
    hp_foreground:show()
    hp_text:show()
    mp_foreground:show()
    mp_text:show()
    tp_foreground:show()
    tp_text:show()
    ready = true
end

function initialize()
    load_images()
    load_text()
    ready = true
    hp_update = true
    mp_update = true
    tp_update = true
end