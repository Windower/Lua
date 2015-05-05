--[[    BSD License Disclaimer
        Copyright © 2015, Morath86
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of BarFiller nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL Morath86 BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- Default settings
defaults = {
    Bars = {
        Background = {
            Image = windower.windower_path..'addons\\barfiller\\data\\bar_bg.png',
            Pos = {
                X = 164,
                Y = 6
            },
            Size = {
                Height = 5,
                Width = 472
            }
        },
        Foreground = {
            Image = windower.windower_path..'addons\\barfiller\\data\\bar_fg.png',
            Pos = {
                X = 166,
                Y = 6
            },
            Size = {
                Height = 5,
                Width = 1
            }
        }
    },
    TextBox = {
        Pos = {
            X = 159,
            Y = 13
        },
        Background = {
            Border = 0,
            Alpha = 0,
            Red = 0,
            Green = 0,
            Blue = 0,
            Visible = true
        },
        Flags = {
            Right = false,
            Bottom = false,
            Bold = false,
            Italic = false
        },
        Padding = 0,
        Text = {
            Size = 10,
            Font = 'Arial',
            Fonts = {},
            Alpha = 255,
            Red = 253,
            Green = 252,
            Blue = 250
        },
        Stroke = {
            Alpha = 127,
            Red = 136,
            Green = 97,
            Blue = 18,
            Width = 1
        }
    },
    RestedBonus = {
        Image = windower.windower_path..'addons\\barfiller\\data\\moon.png',
        Pos = {
            X = 636,
            Y = 0
        },
        Visible = false
    }
}

-- Current Game Resolution
windower_res_x = windower.get_windower_settings().x_res
windower_res_y = windower.get_windower_settings().y_res

-- Approved console commands
-- Thanks to Byrth & SnickySnacks' BattleMod addon
approved_commands = S{
    'clear','c',
    'reload','r',
    'unload','u',
    'help','h'
}

approved_commands = {
    clear={n=0},c={n=0},
    reload={n=0},r={n=0},
    unload={n=0},u={n=0},
    help={n=0},h={n=0}
}

function create_bars()
    -- Background Bar
    bg_image = settings_table.Bars.Background.Image
    bg_pos_x = settings_table.Bars.Background.Pos.X
    bg_pos_y = settings_table.Bars.Background.Pos.Y
    bg_bar_height = settings_table.Bars.Background.Size.Height
    bg_bar_width = settings_table.Bars.Background.Size.Width

    -- Foreground Bar
    fg_image = settings_table.Bars.Foreground.Image
    fg_pos_x = settings_table.Bars.Foreground.Pos.X
    fg_pos_y = settings_table.Bars.Foreground.Pos.Y
    fg_bar_height = settings_table.Bars.Foreground.Size.Height
    fg_bar_width = settings_table.Bars.Foreground.Size.Width

    -- Background Bar Style
    windower.prim.create('background_bar')
    windower.prim.set_position('background_bar', get_background_pos_x(), get_background_pos_y())
    windower.prim.set_size('background_bar', get_background_width(), get_background_height())
    windower.prim.set_texture('background_bar', bg_image)
    windower.prim.set_fit_to_texture('background_bar', true)
    windower.prim.set_repeat('background_bar', 1, 1)
    windower.prim.set_visibility('background_bar', true)

    -- Foreground Bar Style
    windower.prim.create('foreground_bar')
    windower.prim.set_position('foreground_bar', get_foreground_pos_x(), get_foreground_pos_y())
    windower.prim.set_size('foreground_bar', get_foreground_width(), get_foreground_height())
    windower.prim.set_texture('foreground_bar', fg_image)
    windower.prim.set_fit_to_texture('foreground_bar', true)
    windower.prim.set_repeat('foreground_bar', 1, 1)
    windower.prim.set_visibility('foreground_bar', true)

    position_bars()
    update_strings()

    -- Text Box Style and Options
    box_pos_x = settings_table.TextBox.Pos.X
    box_pos_y = settings_table.TextBox.Pos.Y
    box_alpha = settings_table.TextBox.Background.Alpha
    box_red = settings_table.TextBox.Background.Red
    box_green = settings_table.TextBox.Background.Green
    box_blue = settings_table.TextBox.Background.Blue
    box_visible = settings_table.TextBox.Background.Visible
    font_alpha = settings_table.TextBox.Text.Alpha
    font_red = settings_table.TextBox.Text.Red
    font_green = settings_table.TextBox.Text.Green
    font_blue = settings_table.TextBox.Text.Blue
    stroke_alpha = settings_table.TextBox.Stroke.Alpha
    stroke_red = settings_table.TextBox.Stroke.Red
    stroke_green = settings_table.TextBox.Stroke.Green
    stroke_blue = settings_table.TextBox.Stroke.Blue
    stroke_width = settings_table.TextBox.Stroke.Width

    -- Create Text Box
    windower.text.create('box')
    windower.text.set_location('box', box_pos_x, box_pos_y)
    windower.text.set_visibility('box', box_visible)
    windower.text.set_bg_color('box', box_alpha, box_red, box_green, box_blue)
    windower.text.set_bg_visibility('box', box_visible)
    windower.text.set_font('box', 'Montserrat', 'Michroma', 'Ubuntu Mono', 'Arial')
    windower.text.set_font_size('box', 10)
    windower.text.set_color('box', font_alpha, font_red, font_green, font_blue)
    windower.text.set_stroke_color('box', stroke_alpha, stroke_red, stroke_green, stroke_blue)
    windower.text.set_stroke_width('box', 1)
    windower.text.set_text('box', str_job..' '..str_lvl..'  '..str_exp..' '..str_tnl..' '..str_pct)

    -- Position the Text Box below the Experience Bar
    position_text()

    -- Rested Bonus Icon
    bonus_image = settings_table.RestedBonus.Image
    bonus_pos_x = get_background_pos_x() + get_background_width()   -- Right edge of Experience Bar
    bonus_pos_y = get_background_pos_y() - 6                        -- Top edge of the Experience Bar

    windower.prim.create('rested_bonus_icon')
    windower.prim.set_position('rested_bonus_icon', bonus_pos_x, bonus_pos_y)
    windower.prim.set_texture('rested_bonus_icon', bonus_image)
    windower.prim.set_fit_to_texture('rested_bonus_icon', true)
    windower.prim.set_repeat('rested_bonus_icon', 1, 1)
    windower.prim.set_visibility('rested_bonus_icon', false)
    -- FALSE until I can figure out how to detect EXP Bonus Status
end

-- Reset XP Info
-- Thanks to Byrth's PointWatch addon
function initialize()
    info = windower.ffxi.get_player()
    frame_count = 0
    xp = {
        registry = {},
        total = 0,
        rate = 0,
        current = 0,
        tnl = 0,
    }
    create_bars()
    calc_exp_bar()
end

function update_strings()
    str_job = string.upper(info.main_job)
    str_sub = string.upper(info.sub_job)
    str_lvl = 'Lv'..info.main_job_level
    str_exp = 'EXP '..xp.current..'/'..xp.total
    str_tnl = '('..xp.tnl..')'
    if xp.current > 0 then
        str_pct = math.floor((xp.current / xp.total) * 100)..'%'
    else
        str_pct = '0%'
    end
    windower.text.set_text('box', str_job..' '..str_lvl..'  '..str_exp..' '..str_tnl..' '..str_pct)
end

-- Getters
function get_background_pos_x()
    return bg_pos_x
end

function get_background_pos_y()
    return bg_pos_y
end

function get_foreground_pos_x()
    return fg_pos_x
end

function get_foreground_pos_y()
    return fg_pos_y
end

function get_background_height()
    return bg_bar_height
end

function get_background_width()
    return bg_bar_width
end

function get_foreground_height()
    return fg_bar_height
end

function get_foreground_width()
    return fg_bar_width
end

function get_box_pos_x()
    return box_pos_x
end

function get_box_pos_y()
    return box_pos_y
end

-- Setters
function set_background_pos_x(new_pos_x)
    bg_pos_x = new_pos_x
    windower.prim.set_position('background_bar', new_pos_x, get_background_pos_y())
end

function set_background_pos_y(new_pos_y)
    bg_pos_y = new_pos_y
    windower.prim.set_position('background_bar', get_background_pos_x(), new_pos_y)
end

function set_foreground_pos_x(new_pos_x)
    fg_pos_x = new_pos_x
    windower.prim.set_position('foreground_bar', new_pos_x, get_foreground_pos_y())
end

function set_foreground_pos_y(new_pos_y)
    fg_pos_y = new_pos_y
    windower.prim.set_position('foreground_bar', get_foreground_pos_x(), new_pos_y)
end

function set_background_height(new_height)
    bg_bar_height = new_height
    windower.prim.set_size('background_bar', get_background_width(), new_height)
end

function set_background_width(new_width)
    bg_bar_width = new_width
    windower.prim.set_size('background_bar', new_width, get_background_height())
end

function set_foreground_height(new_height)
    fg_bar_height = new_height
    windower.prim.set_size('foreground_bar', get_foreground_width(), new_height)
end

function set_foreground_width(new_width)
    fg_bar_width = new_width
    windower.prim.set_size('foreground_bar', new_width, get_foreground_height())
    update_strings()
end

function set_box_pos_x(new_pos_x) -- 
    box_pos_x = new_pos_x
    windower.text.set_location('box', new_pos_x, get_box_pos_y())
end

function set_box_pos_y(new_pos_y)
    box_pos_y = new_pos_y
    windower.text.set_location('box', get_box_pos_x(), new_pos_y)
end

-- Display helpful information
function help()
    windower.add_to_chat(8,_addon.name..' v'.._addon.version..': Command Listing')
    windower.add_to_chat(8,'   (c)lear - Resets EXP counter')
    windower.add_to_chat(8,'   (u)nload - Disables BarFiller')
    windower.add_to_chat(8,'   (r)eload - Reloads BarFiller')
end

-- Thanks to Byrthnoth's PointWatch addon
function exp_msg(val,msg)
    local t = os.clock()
    if msg == 8 or msg == 105 then
        xp.registry[t] = (xp.registry[t] or 0) + val
        xp.current = math.min(xp.current + val,55999)
        if xp.current > xp.tnl then
            xp.current = xp.current - xp.tnl
        end
    end
end

-- Calculate XP Bar Width
function calc_exp_bar()
    local calc = math.floor((xp.current / xp.total) * 468)
    set_foreground_width(calc)
    update_strings()
end

-- Center the Bar & Text on Screen
function position_bars()
    set_background_pos_x(((windower_res_x / 2) - (get_background_width() / 2)))
    set_foreground_pos_x(get_background_pos_x() + 2)
end

function position_text()
    set_box_pos_x(get_background_pos_x() - 6)
    set_box_pos_y(get_background_pos_y() + 4)
end
