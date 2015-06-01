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
            },
            Draggable = false
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
            },
            Draggable = false
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
            },
            Draggable = false
        }
    },
    ExpText = {
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
            Blue = 250,
            Stroke = {
                Width = 1,
                Alpha = 127,
                Red = 136,
                Green = 97,
                Blue = 18
            }
        }
    },
    Strings = {
        MainJob = true,
        SubJob = true,
        Level = true,
        Exp = true,
        Tnl = true,
        Percent = true,
        Rate = true
    }
}

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
    bg_pos_x     = settings.Images.Background.Pos.X
    bg_pos_y     = settings.Images.Background.Pos.Y
    bg_visible   = settings.Images.Background.Visible
    bg_alpha     = settings.Images.Background.Color.Alpha
    bg_red       = settings.Images.Background.Color.Red
    bg_green     = settings.Images.Background.Color.Green
    bg_blue      = settings.Images.Background.Color.Blue
    bg_image     = settings.Images.Background.Texture.Path
    bg_fit       = settings.Images.Background.Texture.Fit
    bg_width     = settings.Images.Background.Size.Width
    bg_height    = settings.Images.Background.Size.Height
    bg_repeat_x  = settings.Images.Background.Repeatable.X
    bg_repeat_y  = settings.Images.Background.Repeatable.Y
    bg_draggable = settings.Images.Background.Draggable

    background_bar:pos(bg_pos_x, bg_pos_y)
    background_bar:visible(bg_visible)
    background_bar:alpha(bg_alpha)
    background_bar:color(bg_red, bg_green, bg_blue)
    background_bar:path(bg_image)
    background_bar:fit(bg_fit)
    background_bar:size(bg_width, bg_height)
    background_bar:repeat_xy(bg_repeat_x, bg_repeat_y)
    background_bar:show()

    -- Foreground Bar
    fg_pos_x     = settings.Images.Foreground.Pos.X
    fg_pos_y     = settings.Images.Foreground.Pos.Y
    fg_visible   = settings.Images.Foreground.Visible
    fg_alpha     = settings.Images.Foreground.Color.Alpha
    fg_red       = settings.Images.Foreground.Color.Red
    fg_green     = settings.Images.Foreground.Color.Green
    fg_blue      = settings.Images.Foreground.Color.Blue
    fg_image     = settings.Images.Foreground.Texture.Path
    fg_fit       = settings.Images.Foreground.Texture.Fit
    fg_width     = settings.Images.Foreground.Size.Width
    fg_height    = settings.Images.Foreground.Size.Height
    fg_repeat_x  = settings.Images.Foreground.Repeatable.X
    fg_repeat_y  = settings.Images.Foreground.Repeatable.Y
    fg_draggable = settings.Images.Foreground.Draggable

    foreground_bar:pos(fg_pos_x, fg_pos_y)
    foreground_bar:visible(fg_visible)
    foreground_bar:alpha(fg_alpha)
    foreground_bar:color(fg_red, fg_green, fg_blue)
    foreground_bar:path(fg_image)
    foreground_bar:fit(fg_fit)
    foreground_bar:size(fg_width, fg_height)
    foreground_bar:repeat_xy(fg_repeat_x, fg_repeat_y)
    foreground_bar:show()

    -- Rested Bonus Icon
    rb_pos_x     = settings.Images.RestedBonus.Pos.X
    rb_pos_y     = settings.Images.RestedBonus.Pos.Y
    rb_visible   = settings.Images.RestedBonus.Visible
    rb_alpha     = settings.Images.RestedBonus.Color.Alpha
    rb_red       = settings.Images.RestedBonus.Color.Red
    rb_green     = settings.Images.RestedBonus.Color.Green
    rb_blue      = settings.Images.RestedBonus.Color.Blue
    rb_image     = settings.Images.RestedBonus.Texture.Path
    rb_fit       = settings.Images.RestedBonus.Texture.Fit
    rb_width     = settings.Images.RestedBonus.Size.Width
    rb_height    = settings.Images.RestedBonus.Size.Height
    rb_repeat_x  = settings.Images.RestedBonus.Repeatable.X
    rb_repeat_y  = settings.Images.RestedBonus.Repeatable.Y
    rb_draggable = settings.Images.RestedBonus.Draggable

    rested_bonus:pos(rb_pos_x, rb_pos_y)
    rested_bonus:visible(rb_visible)
    rested_bonus:alpha(rb_alpha)
    rested_bonus:color(rb_red, rb_green, rb_blue)
    rested_bonus:path(rb_image)
    rested_bonus:fit(rb_fit)
    rested_bonus:size(rb_width, rb_height)
    rested_bonus:repeat_xy(rb_repeat_x, rb_repeat_y)
    mog_house()

    position_images()
end

function load_text_box()
    -- Text Box Style and Options
    box_pos_x             = settings.ExpText.Pos.X
    box_pos_y             = settings.ExpText.Pos.Y
    box_bg_alpha          = settings.ExpText.Background.Alpha
    box_bg_red            = settings.ExpText.Background.Red
    box_bg_green          = settings.ExpText.Background.Green
    box_bg_blue           = settings.ExpText.Background.Blue
    box_bg_visible        = settings.ExpText.Background.Visible
    box_flags_right       = settings.ExpText.Flags.Right
    box_flags_bottom      = settings.ExpText.Flags.Bottom
    box_flags_bold        = settings.ExpText.Flags.Bold
    box_flags_draggable   = settings.ExpText.Flags.Draggable
    box_flags_italic      = settings.ExpText.Flags.Italic
    box_padding           = settings.ExpText.Padding
    box_font              = settings.ExpText.Text.Font
    box_font_size         = settings.ExpText.Text.Size
    box_font_alpha        = settings.ExpText.Text.Alpha
    box_font_red          = settings.ExpText.Text.Red
    box_font_green        = settings.ExpText.Text.Green
    box_font_blue         = settings.ExpText.Text.Blue
    box_font_stroke_alpha = settings.ExpText.Text.Stroke.Alpha
    box_font_stroke_red   = settings.ExpText.Text.Stroke.Red
    box_font_stroke_green = settings.ExpText.Text.Stroke.Green
    box_font_stroke_blue  = settings.ExpText.Text.Stroke.Blue
    box_font_stroke_width = settings.ExpText.Text.Stroke.Width

    box:pos(box_pos_x, box_pos_y)
    box:bg_color(box_bg_red, box_bg_green, box_bg_blue)
    box:bg_alpha(box_bg_alpha)
    box:bg_visible(box_bg_visible)
    box:right_justified(box_flags_right)
    box:bottom_justified(box_flags_bottom)
    box:bold(box_flags_bold)
    box:italic(box_flags_italic)
    box:pad(box_padding)
    box:font(box_font)
    box:size(box_font_size)
    box:alpha(box_font_alpha)
    box:color(box_font_red, box_font_green, box_font_blue)
    box:stroke_transparency(box_font_stroke_alpha)
    box:stroke_color(box_font_stroke_red, box_font_stroke_green, box_font_stroke_blue)
    box:stroke_width(box_font_stroke_width)

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
    xp = {
        registry = {},
        total = 0,
        rate = 0,
        current = 0,
        tnl = 0
    }
    player = {
        job = '',
        sub = '',
        lvl = '',
        exp = '',
        tnl = '',
        phr = '',
        pct = ''
    }
    load_images()
    load_text_box()
    calc_new_width()
    update_strings()
    ready = true
end

function update_strings()
    info = windower.ffxi.get_player()
    player.job = string.upper(info.main_job)
    player.sub = (info.sub_job and '('..string.lower(info.sub_job)..') ' or '(---) ')
    player.lvl = 'Lv'..info.main_job_level..'  '
    player.exp = 'EXP '..xp.current..'/'..xp.total..' '
    player.tnl = '('..xp.tnl..') '
    player.pct = (xp.total > 0 and math.floor((xp.current / xp.total) * 100)..'% ' or '0% ')
    player.phr = 'EXP/hr '..string.format('%.1f',math.floor(xp.rate/100)/10)..'k'

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
function calc_new_width()
    if xp.current > 0 and xp.total > 0 then
        local calc = math.floor((xp.current / xp.total) * 468)
        xp.rate = analyze_points_table(xp.registry)
        return calc
    end
end

-- Center the Bar & Text on Screen
function position_images()
    local width = bg_width
    local x = windower.get_windower_settings().x_res / 2 - width / 2
    
    background_bar:pos(x, bg_pos_y)
    foreground_bar:pos(x + 2, fg_pos_y)
    rested_bonus:pos(x + width, bg_pos_y - 6)
end

function position_text()
    box:pos((background_bar:pos_x() - 6), (background_bar:pos_y() + 4))
end

-- When logging out, hides the player stats
function hide()
    background_bar:hide()
    foreground_bar:hide()
    rested_bonus:hide()
    box:clear()
    box:hide()
    ready = false
end

function mog_house()
    return (windower.ffxi.get_info().mog_house and rested_bonus:show() or rested_bonus:hide())
end
