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
default_settings = {
    Images = {
        Background = {
            Pos = {
                X = 164,
                Y = 6
            },
            Visible = true,
            Texture = {
                Path =  windower.addon_path..'bar_bg.png',
                Fit = true
            },
            Color = {
                Alpha = 255,
                Red = 255,
                Green = 255,
                Blue = 255
            },
            Size = {
                Height = 5,
                Width = 472
            },
            Repeatable = {
                X = 1,
                Y = 1
            }
        },
        Foreground = {
            Pos = {
                X = 166,
                Y = 6
            },
            Visible = true,
            Texture = {
                Path =  windower.addon_path..'bar_fg.png',
                Fit = false
            },
            Color = {
                Alpha = 255,
                Red = 255,
                Green = 255,
                Blue = 255
            },
            Size = {
                Height = 5,
                Width = 1
            },
            Repeatable = {
                X = 1,
                Y = 1
            }
        },
        RestedBonus = {
            Pos = {
                X = 636,
                Y = 6
            },
            Visible = false,
            Texture = {
                Path =  windower.addon_path..'moon.png',
                Fit = true
            },
            Color = {
                Alpha = 255,
                Red = 255,
                Green = 255,
                Blue = 255
            },
            Size = {
                Height = 32,
                Width = 32
            },
            Repeatable = {
                X = 1,
                Y = 1
            }
        }
    },
    TextBox = {
        Pos = {
            X = 159,
            Y = 13
        },
        Background = {
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
            Draggable = false,
            Italic = false
        },
        Padding = 0,
        Text = {
            Size = 10,
            Font = 'Montserrat',
            Fonts = {'Montserrat', 'Ubuntu Mono', 'Arial'},
            Alpha = 255,
            Red = 253,
            Green = 252,
            Blue = 250
        },
        Stroke = {
            Width = 1,
            Alpha = 127,
            Red = 136,
            Green = 97,
            Blue = 18
        },
        Draggable = false
    },
    Strings = {
        MainJob = true,
        SubJob = false,
        Level = true,
        Exp = true,
        Tnl = true,
        Percent = true,
        Rate = true
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

function load_images()
    -- Background Bar
    bg_pos_x    = settings.Images.Background.Pos.X
    bg_pos_y    = settings.Images.Background.Pos.Y
    bg_visible  = settings.Images.Background.Visible
    bg_alpha    = settings.Images.Background.Color.Alpha
    bg_red      = settings.Images.Background.Color.Red
    bg_green    = settings.Images.Background.Color.Green
    bg_blue     = settings.Images.Background.Color.Blue
    bg_image    = settings.Images.Background.Texture.Path
    bg_fit      = settings.Images.Background.Texture.Fit
    bg_width    = settings.Images.Background.Size.Width
    bg_height   = settings.Images.Background.Size.Height
    bg_repeat_x = settings.Images.Background.Repeatable.X
    bg_repeat_y = settings.Images.Background.Repeatable.Y

    background_bar:pos(get_bg_pos_x(), get_bg_pos_y())
    background_bar:visible(get_bg_visible())
    background_bar:alpha(get_bg_alpha())
    background_bar:color(get_bg_red(), get_bg_green(), get_bg_blue())
    background_bar:path(get_bg_image())
    background_bar:fit(get_bg_fit())
    background_bar:size(get_bg_width(), get_bg_height())
    background_bar:repeat_xy(get_bg_repeat_x(), get_bg_repeat_y())
    background_bar:show()

    -- Foreground Bar
    fg_pos_x    = settings.Images.Foreground.Pos.X
    fg_pos_y    = settings.Images.Foreground.Pos.Y
    fg_visible  = settings.Images.Foreground.Visible
    fg_alpha    = settings.Images.Foreground.Color.Alpha
    fg_red      = settings.Images.Foreground.Color.Red
    fg_green    = settings.Images.Foreground.Color.Green
    fg_blue     = settings.Images.Foreground.Color.Blue
    fg_image    = settings.Images.Foreground.Texture.Path
    fg_fit      = settings.Images.Foreground.Texture.Fit
    fg_width    = settings.Images.Foreground.Size.Width
    fg_height   = settings.Images.Foreground.Size.Height
    fg_repeat_x = settings.Images.Foreground.Repeatable.X
    fg_repeat_y = settings.Images.Foreground.Repeatable.Y

    foreground_bar:pos(get_fg_pos_x(), get_fg_pos_y() )
    foreground_bar:visible(get_fg_visible())
    foreground_bar:alpha(get_fg_alpha())
    foreground_bar:color(get_fg_red(), get_fg_green(), get_fg_blue())
    foreground_bar:path(get_fg_image())
    foreground_bar:fit(get_fg_fit())
    foreground_bar:size(get_fg_width(), get_fg_height())
    foreground_bar:repeat_xy(get_fg_repeat_x(), get_fg_repeat_y())
    foreground_bar:show()

    -- Rested Bonus Icon
    rb_pos_x    = settings.Images.RestedBonus.Pos.X
    rb_pos_y    = settings.Images.RestedBonus.Pos.Y
    rb_visible  = settings.Images.RestedBonus.Visible
    rb_alpha    = settings.Images.RestedBonus.Color.Alpha
    rb_red      = settings.Images.RestedBonus.Color.Red
    rb_green    = settings.Images.RestedBonus.Color.Green
    rb_blue     = settings.Images.RestedBonus.Color.Blue
    rb_image    = settings.Images.RestedBonus.Texture.Path
    rb_fit      = settings.Images.RestedBonus.Texture.Fit
    rb_width    = settings.Images.RestedBonus.Size.Width
    rb_height   = settings.Images.RestedBonus.Size.Height
    rb_repeat_x = settings.Images.RestedBonus.Repeatable.X
    rb_repeat_y = settings.Images.RestedBonus.Repeatable.Y

    rested_bonus:pos(get_rb_pos_x(), get_rb_pos_y())
    rested_bonus:visible(false)
    rested_bonus:alpha(get_rb_alpha())
    rested_bonus:color(get_rb_red(), get_rb_green(), get_rb_blue())
    rested_bonus:path(get_rb_image())
    rested_bonus:fit(get_rb_fit())
    rested_bonus:size(get_rb_width(), get_rb_height())
    rested_bonus:repeat_xy(get_rb_repeat_x(), get_rb_repeat_y())
    rested_bonus:hide()

    position_images()
end

function create_text_box()
    -- Text Box Style and Options
    box_pos_x    = settings.TextBox.Pos.X
    box_pos_y    = settings.TextBox.Pos.Y
    box_alpha    = settings.TextBox.Background.Alpha
    box_red      = settings.TextBox.Background.Red
    box_green    = settings.TextBox.Background.Green
    box_blue     = settings.TextBox.Background.Blue
    box_visible  = settings.TextBox.Background.Visible
    font_font    = settings.TextBox.Text.Font
    font_size    = settings.TextBox.Text.Size
    font_alpha   = settings.TextBox.Text.Alpha
    font_red     = settings.TextBox.Text.Red
    font_green   = settings.TextBox.Text.Green
    font_blue    = settings.TextBox.Text.Blue
    padding      = settings.TextBox.Padding
    stroke_alpha = settings.TextBox.Stroke.Alpha
    stroke_red   = settings.TextBox.Stroke.Red
    stroke_green = settings.TextBox.Stroke.Green
    stroke_blue  = settings.TextBox.Stroke.Blue
    stroke_width = settings.TextBox.Stroke.Width

    -- Textbox Global Settings
    box:pos(get_box_pos_x(), get_box_pos_y())
    box:bg_color(box_red, box_green, box_blue)
    box:bg_alpha(box_alpha)
    
    -- Textbox Font Settings
    box:font(font_font)
    box:size(font_size)
    box:color(font_red, font_green, font_blue)
    box:alpha(font_alpha)

    -- Textbox Stroke Settings
    box:stroke_width(stroke_width)
    box:stroke_color(stroke_red, stroke_green, stroke_blue)
    box:stroke_transparency(stroke_alpha)

    -- String Toggles
    main_job_visible   = settings.Strings.MainJob
    sub_job_visible    = settings.Strings.SubJob
    main_level_visible = settings.Strings.Level
    exp_visible        = settings.Strings.Exp
    tnl_visible        = settings.Strings.Tnl
    percent_visible    = settings.Strings.Percent
    rate_visible       = settings.Strings.Rate

    box:show()
end

-- Reset XP Info
-- Thanks to Byrth's PointWatch addon
function initialize()
    info = windower.ffxi.get_player()
    xp = {
        registry = {},
        total = 0,
        rate = 0,
        current = 0,
        tnl = 0
    }
    player = {
        job = string.upper(info.main_job),
        sub = string.lower(info.sub_job),
        lvl = 'Lv'..info.main_job_level..'  ',
        exp = 'EXP '..xp.current..'/'..xp.total,
        tnl = '('..xp.tnl..')',
        phr = 'EXP/hr 0.0k',
        pct = '0%'
    }
    load_images()
    create_text_box()
    calc_exp_bar()
    update_strings()
    ready = true
end

function update_strings()
    player.job = string.upper(info.main_job)
    player.sub = '('..string.lower(info.sub_job)..') '
    player.lvl = 'Lv'..info.main_job_level..'  '
    player.exp = 'EXP '..xp.current..'/'..xp.total..' '
    player.tnl = '('..xp.tnl..') '
    player.phr = 'EXP/hr '..string.format('%.1f',math.floor(xp.rate/100)/10)..'k'
    if xp.current > 0 and xp.total > 0 then
        player.pct = math.floor((xp.current / xp.total) * 100)..'% '
    else
        player.pct = '0% '
    end

    box:clear()

    if not sub_job_visible then
        box:append(player.job..' ')                       -- JOB
    else
        box:append(player.job..player.sub)                -- JOB(sub)
    end

    if main_level_visible then box:append(player.lvl) end -- Lv##
    if exp_visible        then box:append(player.exp) end -- EXP 59,999/60,000
    if tnl_visible        then box:append(player.tnl) end -- (exp to next level)
    if percent_visible    then box:append(player.pct) end -- ##%
    if rate_visible       then box:append(player.phr) end -- EXP/hr #.#k
end

-- Display helpful information
function help()
    windower.add_to_chat(8,_addon.name..' v'.._addon.version..': Command Listing')
    windower.add_to_chat(8,'   (c)lear - Resets EXP counter')
    windower.add_to_chat(8,'   (u)nload - Disables BarFiller')
    windower.add_to_chat(8,'   (r)eload - Reloads BarFiller')
end

-- Corrects EXP Bar's position on Level Up
-- Thanks to Byrth's PointWatch addon
function exp_msg(val,msg)
    local t = os.clock()
    if msg == 8 or msg == 105 then
        xp.registry[t] = (xp.registry[t] or 0) + val
        xp.current = math.min(xp.current + val,55999)
        if xp.current > xp.tnl then
            xp.current = xp.current - xp.tnl
        end
        chunk_update = true
    end
end

-- Calculate EXP earned per hour
-- Thanks to Byrth's PointWatch addon
function analyze_points_table(tab)
    local t = os.clock()
    local running_total = 0
    local maximum_timestamp = 29
    for ts,points in pairs(tab) do
        local time_diff = t - ts
        if t - ts > 600 then
            tab[ts] = nil
        else
            running_total = running_total + points
            if time_diff > maximum_timestamp then
                maximum_timestamp = time_diff
            end
        end
    end
    
    local rate
    if maximum_timestamp == 29 then
        rate = 0
    else
        rate = math.floor((running_total/maximum_timestamp)*3600)
    end
    
    return rate
end

-- Calculate XP Bar Width
function calc_exp_bar()
    if xp.current > 0 and xp.total > 0 then
        local calc = math.floor((xp.current / xp.total) * 468)
        xp.rate = analyze_points_table(xp.registry)
        return calc
    end
end

-- Center the Bar & Text on Screen
function position_images()
    set_bg_pos_x(((windower_res_x / 2) - (get_bg_width() / 2)))
    set_fg_pos_x(get_bg_pos_x() + 2)
    set_rb_pos_x(get_bg_pos_x() + get_bg_width())
    set_rb_pos_y(get_bg_pos_y() - 6)
end

function position_text()
    set_box_pos_x(get_bg_pos_x() - 6)
    set_box_pos_y(get_bg_pos_y() + 4)
end

-- When logging out, hides the player stats
function hide()
    background_bar:hide()
    foreground_bar:hide()
    rested_bonus:hide()
    box:clear()
    ready = false
end

-- Background Bar Getters
function get_bg_pos_x()
    return bg_pos_x
end

function get_bg_pos_y()
    return bg_pos_y
end

function get_bg_visible()
    return bg_visible
end

function get_bg_alpha()
    return bg_alpha
end

function get_bg_red()
    return bg_red
end

function get_bg_green()
    return bg_green
end

function get_bg_blue()
    return bg_blue
end

function get_bg_image()
    return bg_image
end

function get_bg_fit()
    return bg_fit
end

function get_bg_width()
    return bg_width
end

function get_bg_height()
    return bg_height
end

function get_bg_repeat_x()
    return bg_repeat_x
end

function get_bg_repeat_y()
    return bg_repeat_y
end

-- Foreground Bar Getters
function get_fg_pos_x()
    return fg_pos_x
end

function get_fg_pos_y()
    return fg_pos_y
end

function get_fg_visible()
    return fg_visible
end

function get_fg_alpha()
    return fg_alpha
end

function get_fg_red()
    return fg_red
end

function get_fg_green()
    return fg_green
end

function get_fg_blue()
    return fg_blue
end

function get_fg_image()
    return fg_image
end

function get_fg_fit()
    return fg_fit
end

function get_fg_width()
    return fg_width
end

function get_fg_height()
    return fg_height
end

function get_fg_repeat_x()
    return fg_repeat_x
end

function get_fg_repeat_y()
    return fg_repeat_y
end

-- Rested Bonus Getters
function get_rb_pos_x()
    return rb_pos_x
end

function get_rb_pos_y()
    return rb_pos_y
end

function get_rb_visible()
    return rb_visible
end

function get_rb_alpha()
    return rb_alpha
end

function get_rb_red()
    return rb_red
end

function get_rb_green()
    return rb_green
end

function get_rb_blue()
    return rb_blue
end

function get_rb_image()
    return rb_image
end

function get_rb_fit()
    return rb_fit
end

function get_rb_width()
    return rb_width
end

function get_rb_height()
    return rb_height
end

function get_rb_repeat_x()
    return rb_repeat_x
end

function get_rb_repeat_y()
    return rb_repeat_y
end

-- TextBox Getters
function get_box_pos_x()
    return box_pos_x
end

function get_box_pos_y()
    return box_pos_y
end

function get_box_visible()
    return box_visible
end

function get_box_font_size()
    return font_size
end

function get_rested_bonus_pos_x()
    return bonus_pos_x
end

function get_rested_bonus_pos_y()
    return bonus_pos_y
end

function get_rested_bonus_visible()
    return bonus_visible
end

-- Background Bar Setters
function set_bg_pos_x(new_pos_x)
    bg_pos_x = new_pos_x
    background_bar:pos(new_pos_x, get_bg_pos_y())
end

function set_bg_pos_y(new_pos_y)
    bg_pos_y = new_pos_y
    background_bar:pos(get_bg_pos_x(), new_pos_y)
end

function set_bg_visible(new_visible_state)
    bg_visible = new_visible_state
    background_bar:visible(new_visible_state)
end

function set_bg_alpha(new_alpha)
    bg_alpha = new_alpha
    background_bar:alpha(new_alpha)
end

function set_bg_red(new_red)
    bg_red = new_red
    background_bar:color(new_red, get_bg_green(), get_bg_blue())
end

function set_bg_green(new_green)
    bg_green = new_green
    background_bar:color(get_bg_red(), new_green, get_bg_blue())
end

function set_bg_blue(new_blue)
    bg_blue = new_blue
    background_bar:color(get_bg_red(), get_bg_green(), new_blue)
end

function set_bg_image(new_path)
    bg_image = new_path
    background_bar:path(new_path)
end

function set_bg_fit(new_fit)
    bg_fit = new_fit
    background_bar:fit(new_fit)
end

function set_bg_width(new_width)
    bg_width = new_width
    background_bar:size(new_width, get_bg_height())
end

function set_bg_height(new_height)
    bg_height = new_height
    background_bar:size(get_bg_width(), new_height)
end

function set_bg_repeat_x(new_repeat_x)
    bg_repeat_x = new_repeat_x
    background_bar:repeat_xy(new_repeat_x, get_bg_repeat_y())
end

function set_bg_repeat_y(new_repeat_y)
    bg_repeat_y = new_repeat_y
    background_bar:repeat_xy(get_bg_repeat_x(), new_repeat_y)
end

-- Foreground Bar Setters
function set_fg_pos_x(new_pos_x)
    fg_pos_x = new_pos_x
    foreground_bar:pos(new_pos_x, get_fg_pos_y())
end

function set_fg_pos_y(new_pos_y)
    fg_pos_y = new_pos_y
    foreground_bar:pos(get_fg_pos_x(), new_pos_y)
end

function set_fg_visible(new_visible_state)
    fg_visible = new_visible_state
    foreground_bar:visible(new_visible_state)
end

function set_fg_alpha(new_alpha)
    fg_alpha = new_alpha
    foreground_bar:alpha(new_alpha)
end

function set_fg_red(new_red)
    fg_red = new_red
    foreground_bar:color(new_red, get_fg_green(), get_fg_blue())
end

function set_fg_green(new_green)
    fg_green = new_green
    foreground_bar:color(get_fg_red(), new_green, get_fg_blue())
end

function set_fg_blue(new_blue)
    fg_blue = new_blue
    foreground_bar:color(get_fg_red(), get_fg_green(), new_blue)
end

function set_fg_image(new_path)
    fg_image = new_path
    foreground_bar:path(new_path)
end

function set_fg_fit(new_fit)
    fg_fit = new_fit
    foreground_bar:fit(new_fit)
end

function set_fg_width(new_width)
    fg_width = new_width
    foreground_bar:size(new_width, get_fg_height())
    update_strings()
end

function set_fg_height(new_height)
    fg_height = new_height
    foreground_bar:size(get_fg_width(), new_height)
end

function set_fg_repeat_x(new_repeat_x)
    fg_repeat_x = new_repeat_x
    foreground_bar:repeat_xy(new_repeat_x, get_fg_repeat_y())
end

function set_fg_repeat_y(new_repeat_y)
    fg_repeat_y = new_repeat_y
    foreground_bar:repeat_xy(get_fg_repeat_x(), new_repeat_y)
end

-- Rested Bonus Setters
function set_rb_pos_x(new_pos_x)
    rb_pos_x = new_pos_x
    rested_bonus:pos(new_pos_x, get_rb_pos_y())
end

function set_rb_pos_y(new_pos_y)
    rb_pos_y = new_pos_y
    rested_bonus:pos(get_rb_pos_x(), new_pos_y)
end

function set_rb_visible(new_visible_state)
    rb_visible = new_visible_state
    rested_bonus:visible(new_visible_state)
end

function set_rb_alpha(new_alpha)
    rb_alpha = new_alpha
    rested_bonus:alpha(new_alpha)
end

function set_rb_red(new_red)
    rb_red = new_red
    rested_bonus:color(new_red, get_rb_green(), get_rb_blue())
end

function set_rb_green(new_green)
    rb_green = new_green
    rested_bonus:color(get_rb_red(), new_green, get_rb_blue())
end

function set_rb_blue(new_blue)
    rb_blue = new_blue
    rested_bonus:color(get_rb_red(), get_rb_green(), new_blue)
end

function set_rb_image(new_path)
    rb_image = new_path
    rested_bonus:path(new_path)
end

function set_rb_fit(new_fit)
    rb_fit = new_fit
    rested_bonus:fit(new_fit)
end

function set_rb_width(new_width)
    rb_width = new_width
    rested_bonus:size(new_width, get_rb_height())
end

function set_rb_height(new_height)
    rb_height = new_height
    rested_bonus:size(get_rb_width(), new_height)
end

function set_rb_repeat_x(new_repeat_x)
    rb_repeat_x = new_repeat_x
    rested_bonus:repeat_xy(new_repeat_x, get_rb_repeat_y())
end

function set_rb_repeat_y(new_repeat_y)
    rb_repeat_y = new_repeat_y
    rested_bonus:repeat_xy(get_rb_repeat_x(), new_repeat_y)
end

-- TextBox Setters
function set_box_pos_x(new_pos_x)
    box_pos_x = new_pos_x
    windower.text.set_location('box', new_pos_x, get_box_pos_y())
end

function set_box_pos_y(new_pos_y)
    box_pos_y = new_pos_y
    windower.text.set_location('box', get_box_pos_x(), new_pos_y)
end
