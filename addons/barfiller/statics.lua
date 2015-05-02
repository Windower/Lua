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
    windower.prim.set_fit_to_texture('background_bar', false)
    windower.prim.set_repeat('background_bar', 1, 1)
    windower.prim.set_visibility('background_bar', true)

    -- Foreground Bar Style
    windower.prim.create('foreground_bar')
    windower.prim.set_position('foreground_bar', get_foreground_pos_x(), get_foreground_pos_y())
    windower.prim.set_size('foreground_bar', get_foreground_width(), get_foreground_height())
    windower.prim.set_texture('foreground_bar', fg_image)
    windower.prim.set_fit_to_texture('foreground_bar', false)
    windower.prim.set_repeat('foreground_bar', 1, 1)
    windower.prim.set_visibility('foreground_bar', true)
    
    position_bars()
end

-- Reset XP Info
-- Thanks to Byrth's PointWatch addon
function initialize()
    create_bars()
    xp = {
        registry = {},
        total = 0,
        rate = 0,
        current = 0,
        tnl = 0,
    }
    frame_count = 0
    calc_exp_bar()
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
        calc_exp_bar()
    end
end

-- Calculate XP Bar Width
function calc_exp_bar()
    local calc = math.floor((xp.current / xp.total) * 468)
    set_foreground_width(calc)
end

-- Center the Bar on Screen
function position_bars()
    set_background_pos_x(((windower_res_x/2) - (get_background_width()/2)))
    set_foreground_pos_x(get_background_pos_x()+2)
end

-- Animate Experience Bar Changes
windower.register_event('prerender',function()
    -- todo
end)
