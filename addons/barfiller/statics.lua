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

defaults = {}
defaults.Images = {}
defaults.Images.Background = {}
defaults.Images.Background.Pos = {}
defaults.Images.Background.Pos.X = -843
defaults.Images.Background.Pos.Y = -40
defaults.Images.Background.Color = {}
defaults.Images.Background.Color.Alpha = 255
defaults.Images.Background.Color.Red = 255
defaults.Images.Background.Color.Green = 255
defaults.Images.Background.Color.Blue = 255
defaults.Images.Foreground = {}
defaults.Images.Foreground.Color = {}
defaults.Images.Foreground.Color.Alpha = 255
defaults.Images.Foreground.Color.Red = 255
defaults.Images.Foreground.Color.Green = 255
defaults.Images.Foreground.Color.Blue = 255
defaults.Images.RestedBonus = {}
defaults.Images.RestedBonus.Color = {}
defaults.Images.RestedBonus.Color.Alpha = 255
defaults.Images.RestedBonus.Color.Red = 255
defaults.Images.RestedBonus.Color.Green = 255
defaults.Images.RestedBonus.Color.Blue = 255
defaults.Texts = {}
defaults.Texts.Exp = {}
defaults.Texts.Exp.Draggable = false
defaults.Texts.Exp.Background = {}
defaults.Texts.Exp.Background.Alpha = 0
defaults.Texts.Exp.Background.Red = 0
defaults.Texts.Exp.Background.Green = 0
defaults.Texts.Exp.Background.Blue = 0
defaults.Texts.Exp.Background.Visible = false
defaults.Texts.Exp.Flags = {}
defaults.Texts.Exp.Flags.Bold = false
defaults.Texts.Exp.Flags.Italic = true
defaults.Texts.Exp.Padding = 0
defaults.Texts.Exp.Text = {}
defaults.Texts.Exp.Text.Size = 9
defaults.Texts.Exp.Text.Font = 'sans-serif'
defaults.Texts.Exp.Text.Fonts = {'Trebuchet MS', 'Arial'}
defaults.Texts.Exp.Text.Alpha = 255
defaults.Texts.Exp.Text.Red = 253
defaults.Texts.Exp.Text.Green = 252
defaults.Texts.Exp.Text.Blue = 250
defaults.Texts.Exp.Text.Stroke = {}
defaults.Texts.Exp.Text.Stroke.Width = 2
defaults.Texts.Exp.Text.Stroke.Alpha = 200
defaults.Texts.Exp.Text.Stroke.Red = 50
defaults.Texts.Exp.Text.Stroke.Green = 50
defaults.Texts.Exp.Text.Stroke.Blue = 50
defaults.ShowDetails = {}
defaults.ShowDetails.MainJob = true
defaults.ShowDetails.SubJob = true
defaults.ShowDetails.Level = true
defaults.ShowDetails.SubJobLevel = true
defaults.ShowDetails.ExperiencePoints = true
defaults.ShowDetails.ToNextLevel = false
defaults.ShowDetails.Percent = false
defaults.ShowDetails.Rate = false
defaults.HideKey = 70

approved_commands = S{
    'clear','c',
    'visible','v',
    'reload','r',
    'unload','u',
    'help','h'
}

approved_commands = {
    clear={n=0},c={n=0},
    visible={n=0},v={n=0},
    reload={n=0},r={n=0},
    unload={n=0},u={n=0},
    help={n=0},h={n=0}
}

function load_images()
    local xRes = windower.get_windower_settings().ui_x_res
    local yRes = windower.get_windower_settings().ui_y_res

    background_image:pos(xRes + settings.Images.Background.Pos.X, yRes + settings.Images.Background.Pos.Y)
    background_image:path(settings.Images.Background.Texture.Path)
    background_image:repeat_xy(settings.Images.Background.Repeatable.X, settings.Images.Background.Repeatable.Y)
    background_image:color(settings.Images.Background.Color.Red,settings.Images.Background.Color.Green,settings.Images.Background.Color.Blue,settings.Images.Background.Color.Alpha)
    background_image:draggable(settings.Images.Background.Draggable)
    background_image:show()

    foreground_image:path(settings.Images.Foreground.Texture.Path)
    foreground_image:fit(settings.Images.Foreground.Texture.Fit)
    foreground_image:color(settings.Images.Foreground.Color.Red,settings.Images.Foreground.Color.Green,settings.Images.Foreground.Color.Blue,settings.Images.Foreground.Color.Alpha)
    foreground_image:draggable(settings.Images.Foreground.Draggable)
    foreground_image:show()

    rested_bonus_image:visible(settings.Images.RestedBonus.Visible)
    rested_bonus_image:path(settings.Images.RestedBonus.Texture.Path)
    rested_bonus_image:color(settings.Images.RestedBonus.Color.Red,settings.Images.RestedBonus.Color.Green,settings.Images.RestedBonus.Color.Blue,settings.Images.RestedBonus.Color.Alpha)
    mog_house()

    position_images()
    position_text()
end

function load_text_box()
    exp_text:bg_alpha(settings.Texts.Exp.Background.Alpha)
    exp_text:bg_visible(settings.Texts.Exp.Background.Visible)
    exp_text:font(settings.Texts.Exp.Text.Font, unpack(settings.Texts.Exp.Text.Fonts))
    exp_text:size(settings.Texts.Exp.Text.Size)
    exp_text:italic(settings.Texts.Exp.Flags.Italic)
    exp_text:bold(settings.Texts.Exp.Flags.Bold)
    exp_text:color(settings.Texts.Exp.Text.Red, settings.Texts.Exp.Text.Green, settings.Texts.Exp.Text.Blue)
    exp_text:stroke_alpha(settings.Texts.Exp.Text.Stroke.Alpha)
    exp_text:stroke_color(settings.Texts.Exp.Text.Stroke.Red, settings.Texts.Exp.Text.Stroke.Green,
        settings.Texts.Exp.Text.Stroke.Blue)
    exp_text:stroke_width(settings.Texts.Exp.Text.Stroke.Width)

    exp_text:show()
end

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
    update_bar()
    ready = true
end

function update_bar()
  local old_width = foreground_image:width()
  local new_width = calc_new_width()

  -- Thanks to Iryoku for the logic on smooth animations
  if new_width ~= nil and new_width >= 0 then
      if old_width < new_width then
          local last_update = 0
          local x = old_width + math.ceil(((new_width - old_width) * 0.1))
          foreground_image:size(x, settings.Images.Foreground.Size.Height)
          if debug then print(old_width, x, new_width) end

          local now = os.clock()
          if now - last_update > 0.5 then
              update_strings()
              last_update = now
          end
      elseif old_width >= new_width then
          foreground_image:size(new_width, settings.Images.Foreground.Size.Height)
          chunk_update = false
          if debug then print(chunk_update) end
      end
  end
end

function update_strings()
    info = windower.ffxi.get_player()
    player.job = string.upper(info.main_job)
    player.sub = (info.sub_job and '/'..string.upper(info.sub_job)..' ' or ' ')
    player.lvl = 'Lv'..info.main_job_level
    player.lsb = (info.sub_job_level and '/'..info.sub_job_level..' ' or ' ')
    player.exp = ' EXP '..comma_value(xp.current)..'/'..comma_value(xp.total)..' '
    player.tnl = '('..comma_value(xp.tnl)..') '
    player.pct = (xp.total > 0 and math.floor((xp.current / xp.total) * 100)..'% ' or '0% ')
    player.phr = ' EXP/hr '..string.format('%.1f',math.floor(xp.rate/100)/10)..'k'
    exp_text:clear()
    if settings.ShowDetails.MainJob          then exp_text:append(player.job) end
    if settings.ShowDetails.SubJob           then exp_text:append(player.sub) else exp_text:append(' ') end
    if settings.ShowDetails.Level            then exp_text:append(player.lvl) end
    if settings.ShowDetails.SubJobLevel      then exp_text:append(player.lsb) else exp_text:append(' ') end
    if settings.ShowDetails.ExperiencePoints then exp_text:append(player.exp) end
    if settings.ShowDetails.ToNextLevel      then exp_text:append(player.tnl) end
    if settings.ShowDetails.Percent          then exp_text:append(player.pct) end
    if settings.ShowDetails.Rate             then exp_text:append(player.phr) end
end

function display_help()
    windower.add_to_chat(8,_addon.name..' v'.._addon.version..': Command Listing')
    windower.add_to_chat(8,'   (c)lear - Resets EXP counter')
    windower.add_to_chat(8,'   (v)isible - Toggles visibility')
    windower.add_to_chat(8,'   (u)nload - Disables BarFiller')
    windower.add_to_chat(8,'   (r)eload - Reloads BarFiller')
end

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

function calc_new_width()
    local calc = math.floor((xp.current / xp.total) * 468)
    xp.rate = analyze_points_table(xp.registry)
    return calc
end

function position_images()
    local xRes = windower.get_windower_settings().ui_x_res
    local yRes = windower.get_windower_settings().ui_y_res

    foreground_image:pos(xRes + settings.Images.Background.Pos.X + 2,
      yRes + settings.Images.Background.Pos.Y)
    rested_bonus_image:pos(xRes + settings.Images.Background.Pos.X + (settings.Images.Background.Size.Width / 2) - (settings.Images.RestedBonus.Size.Width/2),
      yRes + settings.Images.Background.Pos.Y - settings.Images.Background.Size.Height)
end

function position_text()
    local xRes = windower.get_windower_settings().ui_x_res
    local yRes = windower.get_windower_settings().ui_y_res
    exp_text:pos(xRes + settings.Images.Background.Pos.X - 10,
      yRes + settings.Images.Background.Pos.Y + settings.Images.Background.Size.Height)
end

function hide()
    background_image:hide()
    foreground_image:hide()
    rested_bonus_image:hide()
    exp_text:hide()
    ready = false
end

function show()
    background_image:show()
    foreground_image:show()
    mog_house()
    exp_text:show()
    ready = true
end

function mog_house()
  if (windower.ffxi.get_info().mog_house) then
    rested_bonus_image:show()
  else
    rested_bonus_image:hide()
  end
end
