--[[Copyright © 2014-2015, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Rhombus nor the
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

_addon.name = 'Rhombus'
_addon.author = 'trv'
_addon.version = '1.2.1'

config = require('config')
texts = require('texts')
res = require('resources')
bit = require('bit')
require 'tables'
require('lists')
require('sets')
require('logger')
require('defs')
require('helper_functions')

config.register(_defaults, function(settings_table)
    x_offset = settings_table.x_offset
    y_offset = settings_table.y_offset
    selector_pos.x = 102 + x_offset
        
    windower.prim.set_position('menu_backdrop',selector_pos.x,y_offset)
    windower.prim.set_position('selector_rectangle',selector_pos.x,y_offset)
    windower.prim.set_position('scroll_bar',selector_pos.x + 150,y_offset)
    
    display_text:pos(95 + x_offset, y_offset)
    
    menu_icon:pos(-12 + x_offset, -22 + y_offset)
    menu_icon:show()
end)

function get_templates()
    if not windower.ffxi.get_info().logged_in then return end
    local player = windower.ffxi.get_player()
    player_info.id = player.id
    player_info.main_job = main_job_id or player.main_job_id
    player_info.sub_job = sub_job_id or player.sub_job_id
    player_info.main_job_level = main_job_level or player.main_job_level
    player_info.sub_job_level = sub_job_level or player.sub_job_level
    
    local main = res.jobs[player_info.main_job].en
    local sub = res.jobs[player_info.sub_job].en
    
    local t_temp = L(res.spells:levels(function(t) return t[player_info.main_job] or t[player_info.sub_job] end):keyset())
    spells_template = loadfile(windower.addon_path .. 'data/spells_template.lua')
    if not spells_template then
        print('No template for spells was found.')
        spells_template = t_temp
    else
        spells_template = spells_template()
        count_table_elements(spells_template)
    end

    t_temp = L(res.weapon_skills:keyset())
    ws_template = loadfile(windower.addon_path .. 'data/ws_template.lua')
    if not ws_template then
        print('No template for weapon skills was found.')
        ws_template = t_temp
    else
        ws_template = ws_template()
        count_table_elements(ws_template)
        if ws_template[main] then
            if ws_template[sub] then
                ws_template = recursively_merge_tables(ws_template[main], ws_template[sub])
            else
                ws_template = recursively_merge_tables(ws_template[main],t_temp)
            end
        elseif ws_template[sub] then
            ws_template = recursively_merge_tables(ws_template[sub],t_temp)
        else
            ws_template = t_temp
        end
    end
    
    t_temp = L(res.job_abilities:prefix('/jobability'):keyset())
    ja_template = loadfile(windower.addon_path .. 'data/ja_template.lua')
    if not ja_template then
        print('No template for job abilities was found.')
        ja_template = t_temp
    else
        ja_template = ja_template()
        count_table_elements(ja_template)
        if ja_template[main] then
            if ja_template[sub] then
                ja_template = recursively_merge_tables(ja_template[main], ja_template[sub])
            else
                ja_template = recursively_merge_tables(ja_template[main],t_temp)
            end
        elseif ja_template[sub] then
            ja_template = recursively_merge_tables(ja_template[sub],t_temp)
        else
            ja_template = t_temp
        end
    end
    
    t_temp = L(res.job_abilities:prefix('/pet'):keyset())
    pet_command_template = loadfile(windower.addon_path .. 'data/pet_command_template.lua')
    if not pet_command_template then
        print('No template for pet commands was found.')
        pet_command_template = t_temp
    else
        pet_command_template = pet_command_template()
        count_table_elements(pet_command_template)
        if pet_command_template[main] then
            if pet_command_template[sub] then
                pet_command_template = recursively_merge_tables(pet_command_template[main], pet_command_template[sub])
            else
                pet_command_template = recursively_merge_tables(pet_command_template[main],t_temp)
            end
        elseif pet_command_template[sub] then
            pet_command_template = recursively_merge_tables(pet_command_template[sub],t_temp)
        else
            pet_command_template = t_temp
        end
    end
    
    spell_aliases = loadfile(windower.addon_path .. 'data/spell_aliases.lua')
    if not spell_aliases then
        spell_aliases = {}
    else
        spell_aliases = spell_aliases()
    end
    
end

function menu_general_layout(t,t2,n)
    available_category = t
    if is_menu_open then
        if last_menu_open.type == n then
            is_menu_open = false
            menu_layer_record:clear()
            close_a_menu()
            last_menu_open = {}
            current_menu = {}
            menu_history[n] = false
        else
            menu_history[last_menu_open.type] = list.copy(menu_layer_record)
            if menu_history[n] then
                last_menu_open.type = n
                menu_layer_record = menu_history[n]
                current_menu = recursively_copy_spells(t2)
                if current_menu then
                    last_menu_open = current_menu
                    last_menu_open.type = n
                    for i = 1,menu_layer_record.n do
                        if current_menu[menu_layer_record[i]] then
                            current_menu = current_menu[menu_layer_record[i]]
                        else
                            for j = 1,menu_layer_record.n+1-i do
                                menu_layer_record:remove()
                            end
                            break
                        end
                    end
                    build_a_menu(current_menu)
                else
                    close_a_menu()
                    current_menu = {}
                end
            else
                menu_layer_record:clear()
                last_menu_open.type = n
                current_menu = recursively_copy_spells(t2)
                if current_menu then
                    last_menu_open = current_menu
                    last_menu_open.type = n
                    build_a_menu(current_menu)
                else
                    close_a_menu()
                    current_menu = {}
                end
            end
        end
    else
        if menu_history[n] then
            last_menu_open.type = n
            menu_layer_record = menu_history[n]
            current_menu = recursively_copy_spells(t2)
            if current_menu then
                last_menu_open = current_menu
                last_menu_open.type = n
                for i = 1,menu_layer_record.n do
                    if current_menu[menu_layer_record[i]] then
                        current_menu = current_menu[menu_layer_record[i]]
                    else
                        for j = 1,menu_layer_record.n+1-i do
                            menu_layer_record:remove()
                        end
                        break
                    end
                end
                build_a_menu(current_menu)
            else
                close_a_menu()
                current_menu = {}
            end
        else
            menu_layer_record:clear()
            last_menu_open.type = n
            current_menu = recursively_copy_spells(t2)
            if current_menu then
                last_menu_open = current_menu
                last_menu_open.type = n
                build_a_menu(current_menu)
            else
                close_a_menu()
                current_menu = {}
            end
        end
    end
end

windower.register_event('incoming chunk', function(id, data)
    if is_menu_open and id == 0x0AC and last_menu_open.type ~= 1 then
        if not S(windower.ffxi.get_abilities()[category_to_resources[last_menu_open.type]]):equals(available_category) then
            available_category = S(windower.ffxi.get_abilities()[category_to_resources[last_menu_open.type]])
            current_menu = recursively_copy_spells({spells_template,ws_template,ja_template,pet_command_template}[last_menu_open.type])
            menu_building_snippet()
        end
    end
end)

windower.register_event('gain buff', function(buff_id)
    if is_menu_open and refresh_ma_when[buff_id] and last_menu_open.type == 1 then
        active_buffs:add(buff_id)
        number_of_jps = count_job_points()
        current_menu = recursively_copy_spells(spells_template)
        menu_building_snippet()
    end
end)

windower.register_event('lose buff', function(buff_id)
    if is_menu_open and refresh_ma_when[buff_id] and last_menu_open.type == 1 then
        active_buffs:remove(buff_id)
        number_of_jps = count_job_points()
        current_menu = recursively_copy_spells(spells_template)
        menu_building_snippet()
    end
end)

windower.register_event('job change',get_templates)

windower.register_event('login', function()
    get_templates:schedule(10)
end)

windower.register_event('load', function()
    get_templates()  
end)

windower.register_event('logout', function()
    close_a_menu()
    display_text:hide()
    menu_icon:hide()
end)

windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked then
        return
    end
    if type == 0 then
        local _x,_y = x-(51+x_offset),y-(51+y_offset)
        if drag_and_drop then
            x_offset = x-drag_and_drop.x
            y_offset = y-drag_and_drop.y
            display_text:pos(x_offset+95,y_offset)
            menu_icon:pos(x_offset-12,y_offset-22)
            selector_pos.x = x_offset+102
            windower.prim.set_position('menu_backdrop',selector_pos.x,y-drag_and_drop.y)
            windower.prim.set_position('selector_rectangle',selector_pos.x,y_offset+selector_pos.y)
            windower.prim.set_position('scroll_bar',selector_pos.x + 150,y_offset + ((12 * font_height_est * (1 - 12 / menu_list.n)) / (menu_list.n - 12)) * (menu_start - 1))
        elseif math.abs(_x) + math.abs(_y) <= 51 then
            local tan = (_y)/(_x)
            if _x > 0 then
                if tan <= -1 then
                    if not is_icon.G then
                        menu_icon:color(111,255,111)
                        colors_of_the_wind('G')
                    end
                elseif tan >= -1 and tan <= 1 then
                    if not is_icon.R then
                        menu_icon:color(255,111,111)
                        colors_of_the_wind('R')
                    end
                elseif tan >= 1 then
                    if not is_icon.B then
                        menu_icon:color(111,111,255)
                        colors_of_the_wind('B')
                    end
                end
            elseif _x < 0 then
                if tan <= -1 then
                    if not is_icon.B then
                        menu_icon:color(111,111,255)
                        colors_of_the_wind('B')
                    end
                elseif tan >= -1 and tan <= 1 then
                    if not is_icon.Y then
                        menu_icon:color(255,255,111)
                        colors_of_the_wind('Y')
                    end
                elseif tan >= 1 then
                    if not is_icon.G then
                        menu_icon:color(111,255,111)
                        colors_of_the_wind('G')
                    end
                end
            end
        elseif is_menu_open then
            if (x >= display_text:pos_x() and x <= display_text:pos_x() + 150) then
                local _,_y = display_text:extents()
                if y <= y_offset or y >= y_offset + _y then return end
                local y_17 = math.ceil((y-y_offset)/font_height_est)
                if (y_17) ~= selector_pos.y then
                    selector_pos.y = (y_17 - 1) * font_height_est
                    windower.prim.set_position('selector_rectangle',selector_pos.x,selector_pos.y + y_offset)
                end
            else
                if not is_icon[letter_to_n[last_menu_open.type]] then
                    menu_icon:color(unpack(n_to_color[last_menu_open.type]))
                    colors_of_the_wind(letter_to_n[last_menu_open.type])
                end
            end
        elseif not is_icon.W then
            menu_icon:color(255,255,255)
            colors_of_the_wind('W')
        end
    elseif type == 1 then
        local _x,_y = x-(51+x_offset),y-(51+y_offset)
        if math.abs(_x) + math.abs(_y) <= 51 then
            mouse_safety = true
            if is_shift_modified then
                drag_and_drop = {x=_x+51,y=_y+51}
                return true
            else
                local tan = (_y)/(_x)
                if _x >= 0 then
                    if tan <= -1 then
                        mouse_func[2]()
                    elseif tan >= -1 and tan <= 1 then
                        mouse_func[1]()
                    elseif tan >= 1 then
                        mouse_func[3]()
                    end
                elseif _x < 0 then
                    if tan <= -1 then
                        mouse_func[3]()
                    elseif tan >= -1 and tan <= 1 then
                        mouse_func[4]()
                    elseif tan >= 1 then
                        mouse_func[2]()
                    end
                end
                return true
            end
        elseif is_menu_open and x >= display_text:pos_x() and x <= display_text:pos_x() + 150 then
            local _,_y = display_text:extents()
            if y <= y_offset or y >= y_offset + _y then return end
            
            local y_17 = math.ceil((y-y_offset)/font_height_est + menu_start - 1)
            if current_menu.sub_menus and y_17 <= current_menu.sub_menus.n then
                menu_layer_record:append(current_menu.sub_menus[y_17])
                current_menu = current_menu[menu_layer_record:last()]
                build_a_menu(current_menu)
                mouse_safety = true
                return true
            else
                format_response(last_menu_open.type,current_menu[y_17-(current_menu.sub_menus and current_menu.sub_menus.n or 0)],is_shift_modified)
                mouse_safety = true
                return true
            end
        end
    elseif type == 2 then
        if drag_and_drop then
            _defaults.x_offset = x_offset
            _defaults.y_offset = y_offset
            _defaults:save()
            drag_and_drop = false
        end
        if mouse_safety then
            mouse_safety = false
            return true
        end
    elseif type == 10 then
        if is_menu_open and menu_list.n > 12
            and x >= display_text:pos_x() and x<= display_text:pos_x() + 150
            and y >= display_text:pos_y() and y <= display_text:pos_y() + 12 * font_height_est then

            menu_start = menu_start - delta
            if menu_start < 1 then menu_start = 1 end
            if menu_start + 11 > menu_list.n then menu_start = menu_list.n - 11 end
            display_text:text(menu_list:concat('\n',menu_start,menu_start+11))
            windower.prim.set_position('scroll_bar',selector_pos.x + 150,y_offset + ((12 * font_height_est * (1 - 12 / menu_list.n)) / (menu_list.n - 12)) * (menu_start - 1))
            return true
        end
    elseif type == 4 then
        local _x,_y = x-(51+x_offset),y-(51+y_offset)
        if math.abs(_x) + math.abs(_y) <= 51 then
            mouse_safety = true
            if is_menu_open then
                menu_history[last_menu_open.type] = list.copy(menu_layer_record)
            end
            close_a_menu()
            return true
        elseif is_menu_open and x >= display_text:pos_x() and x <= display_text:pos_x() + 150 then
            if y <= y_offset or y >= y_offset + font_height_est * 12 then return end
            if menu_layer_record.n == 0 then
                close_a_menu()
            else
                open_previous_menu()
            end
            mouse_safety = true
            return true
        end
    elseif type == 5 then
        if mouse_safety then
            mouse_safety = false
            return true
        end
    end
end)

mouse_func = {
    [1] = function()
        active_buffs = S(windower.ffxi.get_player().buffs)
        number_of_jps = count_job_points()
        menu_general_layout(windower.ffxi.get_spells(),spells_template,1)
    end,
    [2] = function()
        menu_general_layout(S(windower.ffxi.get_abilities().weapon_skills),ws_template,2)
    end,
    [3] = function()
        menu_general_layout(S(remove_categories(windower.ffxi.get_abilities().job_abilities)),ja_template,3)
    end,
    [4] = function()
        menu_general_layout(S(remove_categories(windower.ffxi.get_abilities().job_abilities)),pet_command_template,4)
    end,
}

function build_a_menu(t)
    menu_start = 1
    is_menu_open = true
    menu_list:clear()
    if t.sub_menus and (t.sub_menus.n + t.n == 1) then
        menu_layer_record:append(current_menu.sub_menus[1])
        current_menu = current_menu[menu_layer_record:last()]
        build_a_menu(current_menu)
    else
        if t.sub_menus then
            for i = 1,t.sub_menus.n do
                menu_list:append(' \\cs(' .. (custom_menu_colors[t.sub_menus[i]] or '239,195,255') .. ')' .. t.sub_menus[i] .. '\\cr')
            end
        end
        for i = 1,t.n do
            menu_list:append(' ' .. get_string_from_id(t[i]))
        end
        if menu_list.n > 12 then
            windower.prim.set_size('scroll_bar',10,(font_height_est * 144 / menu_list.n))
            windower.prim.set_visibility('scroll_bar',true)
            windower.prim.set_position('scroll_bar',selector_pos.x + 150,y_offset)
        else
            windower.prim.set_visibility('scroll_bar',false)
        end
        display_text:text(menu_list:concat('\n',1,12))
        windower.prim.set_visibility('menu_backdrop',true)
        selector_pos.y = y_offset
        windower.prim.set_position('selector_rectangle',selector_pos.x,selector_pos.y)
        windower.prim.set_visibility('selector_rectangle',true)
        display_text:show()
    end
end

function close_a_menu()
    is_menu_open = false
    menu_layer_record:clear()
    windower.prim.set_visibility('scroll_bar',false)
    windower.prim.set_visibility('menu_backdrop',false)
    windower.prim.set_visibility('selector_rectangle',false)
    display_text:hide()
end

function open_previous_menu()
    menu_layer_record:remove()
    current_menu = last_menu_open
    for i = 1,menu_layer_record.n do
        current_menu = current_menu[menu_layer_record[i]]
    end
    if current_menu.sub_menus and (current_menu.sub_menus.n + current_menu.n == 1) then
        if menu_layer_record.n == 0 then
            close_a_menu()
        else
            open_previous_menu()
        end
    else
        build_a_menu(current_menu)
    end
end

function format_response(n,p,bool)
    local t
    if n == 1 then 
        if bool then 
            if not (res.spells[p].targets['Self'] or res.spells[p].targets['Corpse']) then
                t = ' <stnpc>'
            else
                t = ' <stpc>'
            end
        else
            t = ''
        end
        n,p = '/ma',res.spells[p].en
    elseif n == 2 then
        if bool then 
            if not (res.weapon_skills[p].targets['Self'] or res.weapon_skills[p].targets['Corpse']) then
                t = ' <stnpc>'
            else
                t = ' <stpc>'
            end
        else
            t = ''
        end
        n,p = '/ws',res.weapon_skills[p].en
    else
        if bool then 
            if not (res.job_abilities[p].targets['Self'] or res.job_abilities[p].targets['Corpse']) then
                t = ' <stnpc>'
            else
                t = ' <stpc>'
            end
        else
            t = ''
        end
        n,p = res.job_abilities[p].prefix,res.job_abilities[p].en
    end
    
    windower.send_command('input %s %q%s':format(n,p,t))
end

windower.register_event('keyboard', function(dik, down, flags, blocked)
    if dik == 42 and not bit.is_set(flags, 6) then
        is_shift_modified = down
    end
end)

function determine_accessibility(spell,type) -- ability filter, slightly modified. Credit: Byrth
    if type == 1 then
        local spell_jobs = spell.levels        
        if not available_category[spell.id] and not (spell.id == 503) then
            return false
        elseif (not spell_jobs[player_info.main_job] or not (spell_jobs[player_info.main_job] <= player_info.main_job_level or
            (spell_jobs[player_info.main_job] > 99 and number_of_jps >= spell_jobs[player_info.main_job]))) and
            (not spell_jobs[player_info.sub_job] or not (spell_jobs[player_info.sub_job] <= player_info.sub_job_level)) then
            return false
        elseif player_info.main_job == 20 and ((addendum_white[spell.id] and not active_buffs[401] and not active_buffs[416]) or
            (addendum_black[spell.id] and not active_buffs[402] and not active_buffs[416])) and
            not (spell_jobs[player_info.sub_job] and spell_jobs[player_info.sub_job] <= player_info.sub_job_level) then
            return false
        elseif player_info.sub_job == 20 and ((addendum_white[spell.id] and not active_buffs[401] and not active_buffs[416]) or
            (addendum_black[spell.id] and not active_buffs[402] and not active_buffs[416])) and
            not (spell_jobs[player_info.main_job] and spell_jobs[player_info.main_job] <= player_info.main_job_level) then
            return false
        elseif spell.type == 'BlueMagic' and not ((player_info.main_job == 16 and table.contains(windower.ffxi.get_mjob_data().spells,spell.id)) or
            ((active_buffs[485] or active_buffs[505]) and unbridled_learning_set[spell.english])) and not
            (player.sub_job_id == 16 and table.contains(windower.ffxi.get_sjob_data().spells,spell.id)) then
            return false
        end
        return true
    else
        return available_category:contains(spell.id)
    end
end
