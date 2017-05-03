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

-- setup images with a common setup
function setup_image(image, path)
    image:path(path)
    image:repeat_xy(1, 1)
    image:draggable(false)
    image:fit(true)
    image:show()
end

-- setup text with a common setup
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

-- position the images and text
function position_ui()
    local x = windower.get_windower_settings().x_res / 2 - (total_width / 2) + settings.Bars.OffsetX
    local y = windower.get_windower_settings().y_res - 60 + settings.Bars.OffsetY

    background:pos(x, y)

    hp_foreground:pos(x + 5, y + 2)
    mp_foreground:pos(x + 15 + bar_width + bar_spacing, y + 2)
    tp_foreground:pos(x + 25 + (bar_width*2) + (bar_spacing*2), y + 2)
    hp_foreground:width(0)
    mp_foreground:width(0)
    tp_foreground:width(0)

    hp_text:pos(x + 50, background:pos_y() + 4)
    mp_text:pos(x + 65 + bar_width + bar_spacing, background:pos_y() + 4)
    tp_text:pos(x + 75 + (bar_width*2) + (bar_spacing*2), background:pos_y() + 4)
end

-- load the images and text
function load_ui()
    setup_image(background, bar_background)
    setup_image(hp_foreground, bar_hp)
    setup_image(mp_foreground, bar_mp)
    setup_image(tp_foreground, bar_tp)
    setup_text(hp_text)
    setup_text(mp_text)
    setup_text(tp_text)

    position_ui()
end

-- update a bar
function update_bar(bar, width, text, current, pp, flag)
    local old_width = width
    local new_width = math.floor((pp / 100) * bar_width)

    if new_width ~= nil and new_width >= 0 then
        if old_width == new_width then
            if new_width == 0 then
                bar:hide()
            end

            if flag == 1 then
                hp_update = false
            elseif flag == 2 then
                mp_update = false
            elseif flag == 3 then
                tp_update = false
            end
        else
            local x = old_width

            if old_width < new_width then
                x = old_width + math.ceil(((new_width - old_width) * 0.1))

                if x > bar_width then
                    x = bar_width
                end
            elseif old_width > new_width then
                x = old_width - math.ceil(((old_width - new_width) * 0.1))

                if x < 0 then
                    x = 0
                end
            end

            if flag == 1 then
                hp_bar_width = x
            elseif flag == 2 then
                mp_bar_width = x
            elseif flag == 3 then
                tp_bar_width = x
            end

            bar:size(x, total_height)
            bar:show()
        end
    end

    text:text(tostring(current))
end

-- hide the addon
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

-- show the addon
function show()
    background:show()
    hp_foreground:show()
    hp_text:show()
    mp_foreground:show()
    mp_text:show()
    tp_foreground:show()
    tp_text:show()
    ready = true
    hp_update = true
    mp_update = true
    tp_update = true
end

-- initialize addon
function initialize()
    load_ui()

    local player = windower.ffxi.get_player()

    if player ~= nil then
        hpp = player.vitals.hpp
        mpp = player.vitals.mpp
        current_hp = player.vitals.hp
        current_mp = player.vitals.mp
        current_tp = player.vitals.tp

        tpp = current_tp

        if current_tp ~= 0 then
            tpp = current_tp / 10

            if tpp > 100 then tpp = 100 end
        end
    end
end