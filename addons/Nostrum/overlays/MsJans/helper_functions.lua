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

function split_by_pipe(s)
    return s and type(s) == 'string' and string.split(s, '|') or L{}
end

function get_palette_settings()
    palette_settings = config.load('data/settings.xml', {
        default = {},
        example = {
            macros = 'Curaga|Curaga II|Curaga III|Curaga IV|Curaga V|'
                .. 'Cure|Cure II|Cure III|Cure IV|Cure V|Cure VI'
                .. 'Divine Waltz|Curing Waltz|Curing Waltz II|Curing Waltz III',
            macro_labels = 'I|II|III|IV|V|1|2|3|4|5|6|˹I˼|˹1˼|˹2˼|˹3˼',

            buffs = 'Regen IV|Shell V|Protect V|Haste',
            buff_labels = 'R4|S5|P5|H',
            buff_icons = 'regen iv|shell v|protect v|haste',

            statuses = 'Sacrifice|Cursna|Stona|Viruna|Poisona|Blindna|'
                .. 'Silena|Paralyna|Erase',
            status_labels = 'Sac|Crs|Stn|Vir|Psn|Bln|Sln|Par|Era',
            status_icons = 'sacrifice|cursna|stona|viruna|poisona|blindna|'
                .. 'silena|paralyna|erase',
        },
    })
end

function palette_settings_parser(profile)
    local profile_palette_settings = palette_settings[type(profile) == 'string' and profile or 'default']
    
    if not profile_palette_settings then
        print('Profile not found: ' .. tostring(profile))
        return
    end
    
    macro_order = {}

    macro_order.macro = split_by_pipe(profile_palette_settings.macros)
    macro_order.macro_labels = split_by_pipe(profile_palette_settings.macro_labels)
    
    --Filter all party-only spells for alliance palettes
    macro_order.alliance_macro = L{}
    macro_order.alliance_macro_labels = L{}

    for i = macro_order.macro.n, 1, -1 do
        local spell = macro_order.macro[i]
        local resource_entry = get_action(spell)

        if resource_entry then
            macro_order.macro[i] = resource_entry[_addon.language]
            
            if resource_entry.targets.Ally then
                macro_order.alliance_macro:append(resource_entry[_addon.language])
                macro_order.alliance_macro_labels:append(macro_order.macro_labels[i])
            end
        else
            macro_order.macro:remove(i)
            macro_order.macro_labels:remove(i)
        end
    end
    
    macro_order.alliance_macro = macro_order.alliance_macro:reverse()
    macro_order.alliance_macro_labels = macro_order.alliance_macro_labels:reverse()

    macro_order.buff = split_by_pipe(profile_palette_settings.buffs)
    macro_order.buff_labels = split_by_pipe(profile_palette_settings.buff_labels)
    macro_order.buff_icons = split_by_pipe(profile_palette_settings.buff_icons)

    for i = macro_order.buff.n, 1, -1 do
        local spell = macro_order.buff[i]
        local resource_entry = get_action(spell)
        
        if resource_entry then
            macro_order.buff[i] = resource_entry[_addon.language]
        else
            macro_order.buff:remove(i)
            macro_order.buff_labels:remove(i)
            macro_order.buff_icons:remove(i)
        end
    end

    macro_order.status = split_by_pipe(profile_palette_settings.statuses)
    macro_order.status_labels = split_by_pipe(profile_palette_settings.status_labels)
    macro_order.status_icons = split_by_pipe(profile_palette_settings.status_icons)    

    for i = macro_order.status.n, 1, -1 do
        local spell = macro_order.status[i]
        local resource_entry = get_action(spell)
        
        if resource_entry then
            macro_order.status[i] = resource_entry[_addon.language]
        else
            macro_order.status:remove(i)
            macro_order.status_labels:remove(i)
            macro_order.status_icons:remove(i)
        end
    end
end

function measure_text_labels(settings, label_list)
    local measurements
    
    if text_dimensions[settings.font] then
        if text_dimensions[settings.font][settings.font_size] then
            measurements = text_dimensions[settings.font][settings.font_size]
        else
            measurements = {}
            text_dimensions[settings.font][settings.font_size] = measurements
        end
    else
        text_dimensions[settings.font] = {}
        measurements = {}
        text_dimensions[settings.font][settings.font_size] = measurements
    end
    
    -- check that dimensions are available for each label 
    local temp_texts = {}
    local is_measurement_necessary = false

    for label, _  in label_list:it() do
        if not measurements[label] then    
            is_measurement_necessary = true
            
            temp_texts[label] = texts.new(label, {
                text = {
                    size = settings.font_size,
                    font = settings.font,
                },
                flags = {
                    bold = settings.bold,
                    right = settings.right_justified,
                    draggable = false,
                },
                bg = {
                    visible = false,
                },
                pos = {
                    x = 50*_, -- arbitrary
                    y = 20*_,
                },
            })
            
            temp_texts[label]:show()
        end
    end
    
    if is_measurement_necessary then
        -- stall until the text is visible
        coroutine.sleep(1)

        -- measure the missing labels
        for label, text in pairs(temp_texts) do
            local w, h = text:extents()

            measurements[label] = {x = w, y = h}

            text:destroy()
            temp_texts[label] = nil
        end
        
        -- add new dimensions to records
        text_dimensions = table.update(text_dimensions, temp_texts, true)
        
        -- format -> json and write to /data/textdb.json
        -- Credit: Zohno, Findall
        local json_file = files.new('data/textdb.json')
        local font_json = L{}
        
        for font, size_bin in pairs(text_dimensions) do
        
            local size_json = L{}
            
            for font_size, label_bin in pairs(size_bin) do
            
                local label_json = L{}
                
                for label, dimension_bin in pairs(label_bin) do
                    label_json:append(
                        '\n\t\t\t"' .. label .. '":{"x":' .. dimension_bin.x
                        .. ',"y":' .. dimension_bin.y .. '}'
                    )
                end
                
                size_json:append(
                    '\n\t\t' .. font_size .. ':{' .. label_json:concat(',')
                    .. '\n\t\t}'
                )
            end
            
            font_json:append(
                '"' .. font .. '":{' .. size_json:concat(',')
                .. '\n\t}'
            )
        end
        
        json_file:write('{\n\t' .. font_json:concat(',\n\t') .. '\n}')
    end    
end

function load_text_dimensions()
    local path = 'data/textdb.json'
    
    if files.exists(path) then
        text_dimensions = json.read(path) or {}
    else
        text_dimensions = {}
        local file = files.new(path)
        file:create()
    end
end

function update_all_target()
    target_display.hpp:text(tostring(target.hpp))
    target_display.phpp:width(settings.prim.target.width * target.hpp / 100)
    target_display.name:text(target.name)
end

function toggle_macro_visibility(bool)
    local grid = palette_grid[1]
    
    if grid then
        for object in pairs(grid._subwidgets) do
            object:visible(bool)
        end
    end
    
    grid = specials_grid
    
    if grid then
        for object in pairs(grid._subwidgets) do
            object:visible(bool)
        end
    end
    
    grid = buff_grid
    
    if grid then
        grid:visible(not bool)
    end
end

function check_display_state(n)
    return macro_grid[n] and true or false
end

function locate_macro(n)
    local grid = macro_grid[n]
    
    if grid then return grid:pos() end
end

function vertical_adjustment(party_number, up_or_down, multiplier)
    local adjustment = (up_or_down and -1 or 1) * (settings.prim.unit_height + 1) * multiplier

    -- bump the main display and palette
    for i = party_number, 3 do
        if not check_display_state(i) then break end

        local grid = macro_grid[i]
        local x, y = grid:pos()
        
        grid:pos(x, y + adjustment)
        widgets.update_object(grid, x, x + grid:width() - 1, y + adjustment, y + adjustment + grid:height() - 1)

        grid = palette_grid[i]
        
        if grid then
            x, y = grid:pos()
            grid:pos(x, y + adjustment)
            widgets.update_object(grid, x, x + grid:width() - 1, y + adjustment, y + adjustment + grid:height() - 1)
        end
    end

    -- bump the specials display and buff grid
    if party_number == 1 then
        local grid = specials_grid
        
        if grid then
            local x, y = grid:pos()
            
            grid:pos(x, y + adjustment)
            widgets.update_object(grid, x, x + grid:width() - 1, y + adjustment, y + adjustment + grid:height() - 1)
        end

        grid = buff_grid
        
        if grid then
            local x, y = grid:pos()
            
            grid:pos(x, y + adjustment)
        end

        if target_display then
            local x, y = target_display:pos()
            
            target_display:pos(x, y + adjustment)
        end
    end
end

function cut()
    if buff_grid then
        local count = get_party(1).count
        local n = macro_grid[1]:rows() - count

        for j = count + n, count + 1, -1 do
            local spot = (j - 1) * 2 + 1

            for r = spot + 1, spot, -1 do
                local row = buff_grid[r] 
                
                for k = 1, 16 do
                    local image = row[k]
                    
                    if image then
                        buff_grid:remove(image)
                        image:destroy()
                        row[k] = nil
                    else
                        break
                    end
                end
                
                buff_grid:remove_row()
            end
        end
    end

    for i = 1, 3 do
        if not check_display_state(i) then break end
        
        local party = get_party(i)
        local p_grid = palette_grid[i]
        local m_grid = macro_grid[i]
        local party_macro = macro[i]
        local count = party.count
        
        local n = m_grid:rows() - count
        
        if n > 0 then
            -- destroy the palette objects
            if p_grid then
                for j = count + n, count + 1, -1 do
                    local backgrounds = party_macro.buttons[j]
                    local labels = party_macro.labels[j]
                    
                    for k = 1, #backgrounds do
                        local prim = backgrounds[k]
                        
                        p_grid:remove(prim)
                        prim:destroy()
                        backgrounds[k] = nil
                    end
                    party_macro.buttons[j] = nil
                    
                    for k = 1, #labels do
                        local text = labels[k]
                        
                        p_grid:remove(text)
                        text:destroy()
                        labels[k] = nil
                    end
                    party_macro.labels[j] = nil
                    
                    for k = 1, p_grid:columns() do
                        local button = p_grid[j][k]

                        p_grid:remove(button)
                        button:destroy()
                    end
                    
                    -- resize the grid
                    p_grid:remove_row()
                end
            end

            -- destroy the macro objects
            for j = count + n, count + 1, -1 do
                local widget_bin = widget_lookup[i][j]
                
                for k, v in pairs(widget_bin) do
                    m_grid:remove(v)
                end
                
                widget_bin:destroy()
                widget_lookup[i][j] = nil
                
                -- resize the grid
                m_grid:remove_row()
            end

            if count > 0 then
                -- resize the palette background
                if party_macro.palette_bg then
                    party_macro.palette_bg:height(count * (settings.prim.unit_height + 1) + 1)
                end
                
                -- resize the macro background
                if bg[i] then
                    bg[i]:height(count * (settings.prim.unit_height + 1) + 1)
                end
                
                -- update the grids
                local x, y
                
                x, y = m_grid:pos()
                widgets.update_object(m_grid, x, x + m_grid:width() - 1, y, y + m_grid:height() - 1)
                
                if p_grid then
                    x, y = p_grid:pos()
                    widgets.update_object(p_grid, x, x + p_grid:width() - 1, y, y + p_grid:height() - 1)
                end            
            else
                if party_macro.palette_bg then
                    party_macro.palette_bg:destroy()
                    party_macro.palette_bg = nil
                end

                if bg[i] then
                    bg[i]:destroy()
                    bg[i] = nil
                end

                if m_grid then
                    widgets.do_not_track(m_grid)
                    m_grid:destroy()
                    macro_grid[i] = nil
                end

                if p_grid then
                    widgets.do_not_track(p_grid)
                    p_grid:destroy()
                    palette_grid[i] = nil
                end
            end
        
            vertical_adjustment(i, false, n)
        end
    end
end

function load_new_profile(profile)
    if not (profile and palette_settings[profile]) then
        print('Profile ' .. tostring(profile) .. ' is nil.')
        return
    end
    
    palette_settings_parser(profile)
    measure_text_labels(settings.text.macro_buttons, macro_order.macro_labels)
    measure_text_labels(settings.text.name, L{}
        :extend(macro_order.status_labels)
        :extend(macro_order.buff_labels)
        :extend(macro_order.buff)
        :extend(macro_order.status)
    )
    
    for i = 1, 3 do
        if not check_display_state(i) then break end
        
        local m_order = macro_order[i == 1 and 'macro' or 'alliance_macro']
        local x, y = locate_macro(i)
        local party_palette_grid = palette_grid[i]

        if party_palette_grid then
            for widget in pairs(party_palette_grid._subwidgets) do
                widget:destroy()
            end
            
            party_palette_grid:destroy()
            widgets.do_not_track(party_palette_grid)
            palette_grid[i] = nil

        end
        
        if m_order.n > 0 then
            macro_builder.palette_grid(i, m_order.n)
            
            for j = 1, macro_grid[i]:rows() do -- build by rows(), not count(): empty spots should have palette rows as well.
                macro_builder.palette(i, j, x, y + (settings.prim.unit_height + 1) * (j - 1))
            end
            
            local palette = palette_grid[i]
            local x, y = palette:pos()
            widgets.update_object(palette, x, x + palette:width(), y, y + palette:height())
        end
    end
    
    if specials_grid then
        for widget in pairs(specials_grid._subwidgets) do
            widget:destroy()
        end
        
        specials_grid:destroy()
        widgets.do_not_track(specials_grid)
        specials_grid = nil
    end

    if macro_order.buff.n + macro_order.status.n > 0 then
        macro_builder.specials()
    end
    
    --[[
        There's no way to move a prim forward, so the highlighters have
        to be rebuilt after the grids.
        How did that work in 2.0?
    --]]

    if not settings.prim.palette.highlight.visible then return end

    if specials_highlighter then
        specials_highlighter:destroy()
        specials_highlighter = nil
    end
    
    if palette_highlighter then
        palette_highlighter:destroy()
        palette_highlighter = nil
    end
    
    if macro_order.macro.n > 0 or macro_order.buff.n + macro_order.status.n > 0 then
        macro_builder.highlight()
    end
end

function draw_buff_display(spot, diff_table, old_count, new_count)
    local row_offset = 2 * (spot - 1)

    for index, buff_id in pairs(diff_table) do
        local r, c = math.ceil(index/16) + row_offset, (-index)%16 + 1
        local path = addon_path .. 'icons/' .. tostring(buff_id) .. '.png'
        local prim = buff_grid[r][c]
        
        if prim then
            prim:texture(path)
            prim:show()
            buff_grid:ignore_visibility(prim, false)
        else
            local measure = math.floor(settings.prim.unit_height / 2)
            
            buff_grid:snap(
                prims.new({
                    w = measure,
                    h = measure,
                    visible = buff_grid:visible(),
                    set_texture = true,
                    texture = path,
                }),
                r,
                c
            )
        end
    end
    
    for i = new_count + 1, old_count do
        local row = math.ceil(i/16)
        local r, c = row_offset + row, 17 - (i - 16 * (row - 1))
        
        local prim = buff_grid[r][c]
        
        prim:hide()
        buff_grid:ignore_visibility(prim, true)
    end
end
