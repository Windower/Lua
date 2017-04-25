--[[Copyright © 2014-2017, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Nostrum nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL trv BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

macro_builder = {}

macro_builder.target = function()
    if not settings.prim.target.create_target_display then return end

    local x, y = locate_macro(1)
    local width = settings.prim.target.width
    local height = settings.prim.target.height
    local is_target_valid = target.valid_target or false
    local category
    y = y - height - misc_bin.header:height()

    target_display = groups.new(x, y - 2, width, height)

    if settings.prim.bg.visible then
        target_display.bg = prims.new({
            pos = {x, y - 1},
            w = width + 2,
            color = settings.prim.bg.color,
            h = height + 2,
            visible = is_target_valid,
        })

        target_display:add(target_display.bg)
    end

    target_display.phpp = prims.new({
        pos = {x + 1, y},
        w = width * target.hpp / 100,
        color = settings.prim.hp[100],
        h = height,
        visible = is_target_valid,
    })

    category = settings.text.name
    
    target_display.hpp = texts.new(tostring(target.hpp), {
        text = {
            size = category.font_size,
            font = category.font,
        },
        flags = {
            bold = category.bold,
            right = false,
            draggable = false,
        },
        bg = {
            visible = false,
        },
        pos = {
            x = x + 1,
            y = y + category.offset.y + text_dimensions[category.font][category.font_size].menu.y,
        },    
    })
    
    target_display.hpp:visible(is_target_valid)
    
    category = settings.text.name
    
    target_display.name = texts.new(target.name or '', {
        text = {
            size = category.font_size,
            font = category.font,
        },
        flags = {
            bold = category.bold,
            right = false,
            draggable = false,
        },
        bg = {
            visible = false,
        },
        pos = {
            x = x + category.offset.x + 1,
            y = y + category.offset.y,
        },    
    })
    
    target_display.name:visible(target.valid_target)

    target_display:add(target_display.phpp)
    target_display:add(target_display.hpp)
    target_display:add(target_display.name)
end

macro_builder.highlight = function()
    if not settings.prim.palette.highlight.visible then return end

    palette_highlighter = --[[palette_highlighter or--]] prims.new({
        pos = {0, 0},
        w = settings.prim.palette.main.buttons.width,
        color = settings.prim.palette.highlight.color,
        h = settings.prim.unit_height,
        visible = false,
    })
    
    if macro_order.status.n + macro_order.buff.n > 0 then
        specials_highlighter = --[[specials_highlighter or--]] prims.new({
            pos = {0, 0},
            w = settings.prim.palette.specials.buttons.width,
            color = settings.prim.palette.highlight.color,
            h = settings.prim.palette.specials.buttons.height,
            visible = false,
        })
    end
end

macro_builder.new_party = function(alliance_spot)
    local macro = macro[alliance_spot]
    macro.display = macro.display or {}
    macro.labels = macro.labels or {}
    macro.buttons = macro.buttons or {}
    local bar_width = settings.prim.bar_width

    -- jump to the display's position
    local y = windower_settings.y_res - settings.location.y_offset
    local x = windower_settings.x_res - settings.location.x_offset - bar_width - 2
    
    for i = alliance_spot-1, 1, -1 do
        y = y - get_party(i).count * (settings.prim.unit_height+1) - 1 
            - ({
                settings.distance_between_parties_one_and_two,
                settings.distance_between_parties_two_and_three,
            })[i]
    end
    
    -- build the display grid and background (buttons built in new_player)
    local count = get_party(alliance_spot).count
    local w, h = bar_width + 2, (settings.prim.unit_height + 1)
    
    local mgrid = grids.new(x, y, w, h, 0, 1) -- set rows to 0: new_player will ++
    
    if settings.prim.bg.visible then
        macro_builder.bg(x, y, w, 0, alliance_spot)
        mgrid:add(bg[alliance_spot])
    end
    
    widgets.track(mgrid, x, x + w - 1, y, y)
    macro_grid[alliance_spot] = mgrid

    -- build the palette grid and background (buttons built in new_player)
    local macro_count = macro_order[alliance_spot == 1 and 'macro' or 'alliance_macro'].n
    
    if macro_count > 0 then
        macro_builder.palette_grid(alliance_spot, macro_count)
    end
    
    if alliance_spot == 1 and settings.prim.buffs.display_party_buffs then
        local z = math.floor(h/2)
        local x, y = x - z * 16, y
        
        buff_grid = grids.new(x, y, z, z, 0, 16)
    end
    
    if (settings.prim.bg.visible or settings.prim.palette.buttons.background_visible)
        and settings.prim.palette.highlight.visible then
        
        if palette_highlighter then
            palette_highlighter:destroy()
        end
        
        if specials_highlighter then
            specials_highlighter:destroy()
        end
        
        macro_builder.highlight()
    end
end

macro_builder.palette_grid = function(alliance_spot, count)
    local x, y = locate_macro(alliance_spot)
    local palette_settings = settings.prim.palette.main
    local width = settings.prim.palette.main.buttons.width
    local macro_x = x - count * (width + 1) - 1
    
    local sgrid = grids.new(
        macro_x + 1,
        y + 1,
        width + 1,
        settings.prim.unit_height + 1,
        0,
        count
    )
    
    if palette_settings.background_visible then
        local background = prims.new({
            pos = {macro_x, y},
            w = count * (width + 1) + 1,
            color = settings.prim.bg.color,
            h = (settings.prim.unit_height + 1) * get_party(alliance_spot).count + 1,
            visible = false,
        })
        
        sgrid:add(background)
        
        macro[alliance_spot].palette_bg = background
    end
    
    --[[
        Grid should remain "visible" at all times for widget tracking, but grid
        contents can be hidden on focus change. 
    --]]
    if alliance_spot == 1 then
        -- main party palette grid and specials grid are linked
        sgrid:register_event('focus change', function(in_focus)
            palette_highlighter:visible(in_focus)
            toggle_macro_visibility(in_focus)
        end)
    else
        sgrid:register_event('focus change', function(in_focus)
            for object in pairs(sgrid._subwidgets) do
                object:visible(in_focus)
            end

            palette_highlighter:visible(in_focus)
        end)
    end

    widgets.track(sgrid, macro_x + 1, macro_x + count * (width + 1), y + 1, y + 1)
    widgets.allow_focus(sgrid)
    palette_grid[alliance_spot] = sgrid
end

macro_builder.bg = function(x, y, w, h, spot)
    local background = prims.new({
        pos = {x, y},
        w = w,
        color = settings.prim.bg.color,
        h = h,
        visible = true,
    })
    
    bg[spot] = background
    -- is this background prim in a group (for v-adj purposes)?
end

macro_builder.new_player = function(party, position)
    local bin = display.new {}
    local unit_height = settings.prim.unit_height
    local bar_width = settings.prim.bar_width
    local grid = macro_grid[party]

    grid:new_row()
    
    -- adjust background height
    if bg[party] then
        bg[party]:height((unit_height+1) * position + 1)
    end
    
    -- build the text objects
    widget_lookup[party][position] = bin
    
    local x = windower_settings.x_res - settings.location.x_offset - bar_width - 2
    local y = grid:pos_y() + (unit_height + 1)*(position-1)-- - settings.location.y_offset
    local cat
    local player = get_player(party, position)
    local is_player_in_zone = not player.out_of_zone
    
    for _, stat in pairs{'hp', 'tp', 'mp', 'hpp', 'name'} do
        cat = settings.text[stat]
        
        if cat.visible then
            local snippet = texts.new(tostring(player[stat]), {
                text = {
                    size = cat.font_size,
                    font = cat.font,
                },
                flags = {
                    bold = cat.bold,
                    right = cat.right_justified,
                    draggable = false,
                },
                bg = {
                    visible = false,
                },
                pos = {
                    x = (cat.right_justified and -settings.location.x_offset or x) + cat.offset.x,
                    y = y + cat.offset.y,
                },
            })
            
            bin[stat] = snippet
            snippet:visible(is_player_in_zone) -- check if player is in zone
            grid:add(snippet)
        end
    end
    
    bin:draw_name(player.name)
    
    local distance = (character.x - player.x)^2 + (character.y - player.y)^2
    
    if distance > 441 then
        player.out_of_range = true
        bin:out_of_range()
        
        if player.out_of_sight then
            bin:out_of_sight()
        end
    end
    
    bin.name:show()
    
    -- build the hp/mp bars
    bin.phpp = prims.new({
        pos = {x+1, y+1},
        w = bar_width * player.hpp / 100,
        color = settings.prim.hp[math.ceil(player.hpp/25) * 25],
        h = unit_height,
        visible = is_player_in_zone,
        image = false,
    })
    
    bin.pmpp = prims.new({
        pos = {x + 1, y + unit_height - settings.prim.mp.height + 1},
        w = bar_width * player.mpp / 100,
        color = settings.prim.mp.color,
        h = settings.prim.mp.height,
        visible = is_player_in_zone,
        image = false,
    })
    
    bin:link(player)
    
    grid:add(bin.phpp)
    grid:add(bin.pmpp)
    
    macro[party].display[position] = bin
    
    -- build a button
    local button = buttons.new(x, y, bar_width + 2, unit_height + 1, true)

    button:register_event('left click', function()
        local player = get_player(party, position)
        
        if player then
            action('target', player.name)
        end
    end)
    
    button:register_event('left button down', function()
        return true
    end)
    
    button:register_event('right click', function()
        if clipboard then
            local player = get_player(party, position)
            
            if player then
                action(clipboard, player.name)
            end
        end
    end)
    
    button:register_event('right button down', function()
        return true
    end)
    
    grid[position][1] = button
    grid:add(button)
    
    macro_builder.palette(party, position, x, y)
    vertical_adjustment(party, true, 1)
    
    if party == 1 and buff_grid then
        buff_grid:new_row()
        buff_grid:new_row()
    end
end

macro_builder.header = function()
    local grid = macro_grid[1]
    local y = grid:pos_y()
    local x = windower_settings.x_res - settings.location.x_offset
    local cat = settings.text.name
    local bar_width = settings.prim.bar_width + 2
    local text_measurements = text_dimensions[cat.font][cat.font_size]
    
    misc_bin.header_text = texts.new('menu', {
        text = {
            size = cat.font_size,
            font = cat.font,
        },
        flags = {
            bold = cat.bold,
            right = false,
            draggable = false,
        },
        bg = {
            visible = false,
        },
        pos = {
            x = x - bar_width + (bar_width - text_measurements.menu.x) / 2,
            y = y - text_measurements.menu.y - 1,
        },
    })
    
    misc_bin.header_text:show()

    local buffered_font_height = text_measurements.menu.y + 2
    
    misc_bin.header = prims.new({
        pos = {x - bar_width, y - buffered_font_height},
        w = bar_width,
        color = settings.prim.bg.color,
        h = buffered_font_height,
        visible = settings.prim.bg.visible,
    })
    
    grid:add(misc_bin.header)
    grid:add(misc_bin.header_text)
end

macro_builder.palette = function(party, position, x, y)
    local palette_type = party == 1 and 'macro' or 'alliance_macro'
    
    if not (macro_order[palette_type].n > 0) then return end

    y = y + 1
    local labels = {}
    local backgrounds = {}
    local height = settings.prim.unit_height
    local width = settings.prim.palette.main.buttons.width
    local grid = palette_grid[party]
    local is_palette_visible = not addon_state.hidden and widgets.get_object_with_focus() == grid
    
    if macro[party].palette_bg then
        macro[party].palette_bg:height((height+1) * position + 1)
    end

    grid:new_row()
    x = x - macro_order[palette_type].n * (width + 1) - 1
    
    local mbutton_settings = settings.prim.palette.main.buttons
    
    if mbutton_settings.background_visible then
        local x, y = x, y
        local macro = macro_order[palette_type]
        
        for i = 1, macro.n do
            backgrounds[i] = prims.new({
                pos = {x + 1, y},
                w = width,
                color = mbutton_settings.color,
                h = height,
                visible = is_palette_visible,
                image = false,
            })

            x = x + width + 1

            grid:add(backgrounds[i])
        end
    end
    
    do
        local x, y = x, y
        local macro = macro_order[palette_type]
        
        for i = 1, macro.n do
            local button = buttons.new(
                x + 1,
                y - 1,
                width + 1,
                height + 1,
                true
            )
            
            button:register_event('left click', function()
                local player = get_player(party, position)
                
                if player then
                    action(macro[i], player.name)
                end
                
            end)
            
            button:register_event('left button down', function()
                return true
            end)

            widgets.allow_focus(button)
            button:register_event('focus change', function(in_focus)
                if in_focus then
                    local x, y = button:pos()
                    palette_highlighter:pos(x, y + 1)
                end
            end)
            
            grid[position][i] = button

            x = x + width + 1

            grid:add(button)
        end
    end
    
    local cat = settings.text.macro_buttons
    local label_dimensions = text_dimensions[cat.font][cat.font_size]
    for label, n in macro_order[palette_type .. '_labels']:it() do
        labels[n] = texts.new(label, {
            text = {
                size = cat.font_size,
                font = cat.font,
            },
            flags = {
                bold = cat.bold,
                right = cat.right_justified,
                draggable = false,
            },
            bg = {
                visible = false,
            },
            pos = {
                x = x + (width-label_dimensions[label].x)/2 + 1,
                y = y + (height-label_dimensions[label].y)/2,
            },
        })
        
        x = x + width + 1
        
        labels[n]:visible(is_palette_visible)
        grid:add(labels[n])
    end
    
    macro[party].labels[position] = labels
    macro[party].buttons[position] = backgrounds
end

macro_builder.specials = function()
    if macro_order.status:empty() and macro_order.buff:empty() then return end
    
    local x, y = locate_macro(1)
    local prim_settings = settings.prim.palette.specials
    local button_settings = prim_settings.buttons
    local height, width = button_settings.height, button_settings.width
    
    -- create specials grid
    local grid_columns = math.max(macro_order.status.n, macro_order.buff.n)
    local grid_rows = (macro_order.status.n > 0 and 1 or 0) 
        + (macro_order.buff.n > 0 and 1 or 0)
    local grid_width = grid_columns * (width + 1)
    local grid_height = (height + 1) * grid_rows-- - 2
    
        
    local grid = grids.new(
        x - grid_width + 1,
        y - grid_height + 1,
        width + 1,
        height + 1,
        grid_rows, 
        grid_columns
    )
    
    specials_grid = grid
    
    -- tell the widgets library to track the grid
    widgets.allow_focus(grid)
    widgets.track(grid, x - grid_width, x, y - grid_height, y)
    
    grid:register_event('focus change', function(in_focus)
        specials_highlighter:visible(in_focus)

        toggle_macro_visibility(in_focus)
    end)

    -- create specials display
    for spell_type, n in L{'status', 'buff'}
        :filter(function(s) return macro_order[s].n > 0 end)
        :it() do
    
        local macro = macro_order[spell_type]
        local bg_width = macro.n * (width + 1) + 1
        local x, y = x - bg_width, y - height * n - 2
    
        -- build the background
        if prim_settings.background_visible then
            local background = prims.new({
                pos = {x, y},
                w = bg_width,
                color = settings.prim.bg.color,
                h = height + 2, -- -1?
                visible = false,
            })
            
            grid:add(background)
        end
        
        -- build the button outlines
        if button_settings.background_visible then
            local x, y = x, y
            
            for i = 1, macro.n do
                local outline = prims.new({
                    pos = {x + 1, y + 1},
                    w = width,
                    color = button_settings.color,
                    h = height,
                    visible = false,
                    image = false,
                })
                
                x = x + width + 1

                grid:add(outline)                
            end
        end
        
        -- build the images
        if button_settings.images_visible then
            local x, y = x, y
            local path = addon_path .. 'icons/'
            local icons_key = spell_type .. '_icons'

            for i = 1, macro.n do
                local file_name = macro_order[icons_key][i]
                
                if file_name then
                    local icon = prims.new({
                        pos = {x + 1, y + 1},
                        w = width,
                        h = height,
                        visible = false,
                        set_texture = true,
                        texture = path .. file_name .. '.png',
                        fit_texture = false,
                    })
                    
                    grid:add(icon)
                end
                
                x = x + width + 1
            end
        end
        
        -- build the text labels
        if settings.text.specials.visible then
            local x, y = x, y
            local cat = settings.text.specials
            local labels_key = spell_type .. '_labels'
            
            for i = 1, macro.n do
                local label = texts.new(macro_order[labels_key][i], {
                    text = {
                        size = cat.font_size,
                        font = cat.font,
                        stroke = {
                            width = 1,
                        }
                    },
                    flags = {
                        bold = cat.bold,
                        right = cat.right_justified,
                        draggable = false,
                    },
                    bg = {
                        visible = false,
                    },
                    pos = {
                        x = x + 1,
                        y = y + 1,
                    },
                })
                
                x = x + width + 1
                --label:show()
                grid:add(label)                
            end
        end
        
        -- build buttons
        do
            local x, y = x + 1, y + 1
            local offset = grid_columns - macro.n
            local row = grid[n % grid:rows() + 1] -- consequence of building bottom row first
            
            for i = 1, macro.n do
                local button = buttons.new(
                    x,
                    y,
                    width + 1,
                    height + 1,
                    false --true -- visible
                )
                
                x = x + width + 1
                
                row[i + offset] = button
                grid:add(button)            
                
                button:register_event('left click', function()
                    if macro[i] then
                        action(macro[i], '<t>')
                    end
                end)
                
                button:register_event('left button down', function()
                    return true
                end)
                
                button:register_event('right click', function()
                    if macro[i] then
                        clipboard = macro[i]
                        
                        local cat = settings.text.name
                        local dimensions = text_dimensions[cat.font][cat.font_size][clipboard]
                        local bar_width = settings.prim.bar_width + 2
                        local x = locate_macro(1)
                        
                        misc_bin.header_text:text(clipboard)
                        misc_bin.header_text:pos_x(x + (bar_width - dimensions.x) / 2)
                    end
                end)
                
                button:register_event('right button down', function()
                    return true
                end)
                
                widgets.allow_focus(button)
                button:register_event('focus change', function(in_focus)
                    if in_focus then
                        local x, y = button:pos()
                        specials_highlighter:pos(x, y)
                    end
                end)

            end
        end
    end
end
