--[[Copyright © 2014, trv
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
_addon.version = '1.1.0'

config = require('config')
texts = require('texts')
res = require('resources')
require 'tables'
require('lists')
require('sets')
require('logger')
require('defs')
packets = require('packets')

local defaults={
    x_offset = 0,
    y_offset = 0,
}
_defaults = config.load(defaults)

x_offset = _defaults.x_offset
y_offset = _defaults.y_offset

display_text = texts.new('${menu_text}', {
    pos = {
        x = 95 + x_offset,
        y = 0 + y_offset,
    },
    bg = {
        visible = false,
    },
    flags = {
        bold = true,
        draggable = false,
    },
    text = {
        font = 'Consolas',
        size = 10,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
    },
})

menu_icon = texts.new('v', {
    pos = {
        x = -12 + x_offset,
        y = -22 + y_offset,
    },
    bg = {
        visible = false,
    },
    flags = {
        bold = true,
        draggable = false,
    },
    text = {
        font = 'Wingdings',
        size = 100,
        alpha = 100,
        red = 255,
        blue = 255,
        green = 255,
        stroke = {
            width = 1,
            red = 0,
            blue = 0,
            green = 0,
            alpha = 255,
        },
    },
})

menu_icon:show()

selector_pos.x = 102 + x_offset
windower.prim.create('menu_backdrop')
windower.prim.set_position('menu_backdrop',selector_pos.x,0 + y_offset)
windower.prim.set_color('menu_backdrop',200,0,0,0)
windower.prim.set_visibility('menu_backdrop',false)
windower.prim.set_size('menu_backdrop',150,12 * font_height_est)

windower.prim.create('selector_rectangle')
windower.prim.set_position('selector_rectangle',selector_pos.x,0 + y_offset)
windower.prim.set_color('selector_rectangle',100,255,255,255)
windower.prim.set_visibility('selector_rectangle',false)
windower.prim.set_size('selector_rectangle',150,font_height_est)

windower.prim.create('scroll_bar')
windower.prim.set_position('scroll_bar',selector_pos.x + 150,0 + y_offset)
windower.prim.set_color('scroll_bar',200,255,255,255)
windower.prim.set_visibility('scroll_bar',false)
windower.prim.set_size('scroll_bar',10,1)

function colors_of_the_wind(s)
    for k,v in pairs(is_icon) do
        is_icon[k] = false
    end
    is_icon[s] = true
end

function get_templates()
    if not windower.ffxi.get_info().logged_in then return end
    player_info.id = windower.ffxi.get_player().id
    player_info.main_job = main_job_id or windower.ffxi.get_player().main_job_id
    player_info.sub_job = sub_job_id or windower.ffxi.get_player().sub_job_id
    player_info.main_job_level = main_job_level or windower.ffxi.get_player().main_job_level
    player_info.sub_job_level = sub_job_level or windower.ffxi.get_player().sub_job_level
    local t_temp
    
    local main = res.jobs[player_info.main_job].en
    local sub = res.jobs[player_info.sub_job].en
    
    t_temp = L(res.spells:levels(function(t) return t[player_info.main_job] or t[player_info.sub_job] end):keyset())
    t_temp.n = #t_temp
    spells_template = loadfile(windower.addon_path .. 'data/spells_template.lua')
    if not spells_template then
        error('No template for spells was found.')
        spells_template = t_temp
    else
        spells_template = spells_template()
        count_table_elements(spells_template)
    end

    t_temp = L(res.weapon_skills:keyset())
    t_temp.n = #t_temp
    ws_template = loadfile(windower.addon_path .. 'data/ws_template.lua')
    if not ws_template then
        error('No template for weapon skills was found.')
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
    t_temp.n = #t_temp
    ja_template = loadfile(windower.addon_path .. 'data/ja_template.lua')
    if not ja_template then
        error('No template for job abilities was found.')
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
    t_temp.n = #t_temp
    pet_command_template = loadfile(windower.addon_path .. 'data/pet_command_template.lua')
    if not pet_command_template then
        error('No template for pet commands was found.')
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
    available_category = S(t)
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
                            break
                        end
                    end
                    build_a_menu(current_menu)
                else
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
                        break
                    end
                end
                build_a_menu(current_menu)
            else
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
                current_menu = {}
            end
        end
    end
end

refresh_ja_when = S{211,212,298}
refresh_4_when = S{30}
refresh_ma_when = S{211,212,234,235}

windower.register_event('incoming chunk', function(id, data)
    if id == 0x028 then
        local packet = packets.parse('incoming', data)
        local param = packet['Param']
        if ((packet['Actor'] == player_info.id) and is_menu_open and (packet['Category'] == 6)) then
            if (refresh_ja_when:contains(param) and (last_menu_open.type == 3)) then
                menu_history[3] = list.copy(menu_layer_record)
                close_a_menu()
                coroutine.sleep(.2)
                mouse_func[3]()
            elseif (refresh_ma_when:contains(param) and (last_menu_open.type == 1)) then
                menu_history[1] = list.copy(menu_layer_record)
                close_a_menu()
                coroutine.sleep(1)
                mouse_func[1]()
            elseif (refresh_4_when:contains(param) and (last_menu_open.type == 4)) then
                menu_history[4] = list.copy(menu_layer_record)
                close_a_menu()
                coroutine.sleep(.2)
                mouse_func[4]()
            end
        end
    end
end)

windower.register_event('load','login','job change',get_templates)

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
            display_text.menu_text=menu_list:concat('\n',menu_start,menu_start+11)
            windower.prim.set_position('scroll_bar',selector_pos.x + 150,y_offset + ((12 * font_height_est * (1 - 12 / menu_list.n)) / (menu_list.n - 12)) * (menu_start - 1))
            return true
        end
    elseif type == 4 then
        if is_menu_open and x >= display_text:pos_x() and x <= display_text:pos_x() + 150 then
            local _,_y = display_text:extents()
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
            available_category = windower.ffxi.get_spells()
            active_buffs = S(windower.ffxi.get_player().buffs)
            if is_menu_open then
                if last_menu_open.type == 1 then
                    is_menu_open = false
                    menu_layer_record:clear()
                    close_a_menu()
                    last_menu_open = {}
                    current_menu = {}
                    menu_history[1] = false
                else
                    menu_history[last_menu_open.type] = list.copy(menu_layer_record)
                    if menu_history[1] then
                        last_menu_open.type = 1
                        menu_layer_record = menu_history[1]
                        current_menu = recursively_copy_spells(spells_template)
                        if current_menu then
                            last_menu_open = current_menu
                            last_menu_open.type = 1
                            for i = 1,menu_layer_record.n do
                                current_menu = current_menu[menu_layer_record[i]]
                            end
                            build_a_menu(current_menu)
                        else
                            current_menu = {}
                        end
                    else
                        menu_layer_record:clear()
                        last_menu_open.type = 1
                        current_menu = recursively_copy_spells(spells_template)
                        if current_menu then
                            last_menu_open = current_menu
                            last_menu_open.type = 1
                            build_a_menu(current_menu)
                        else
                            current_menu = {}
                        end
                    end
                end
            else
                if menu_history[1] then
                    last_menu_open.type = 1
                    menu_layer_record = menu_history[1]
                    current_menu = recursively_copy_spells(spells_template)
                    if current_menu then
                        last_menu_open = current_menu
                        last_menu_open.type = 1
                        for i = 1,menu_layer_record.n do
                            if current_menu[menu_layer_record[i]] then
                                current_menu = current_menu[menu_layer_record[i]]
                        else
                                break
                            end
                        end
                        build_a_menu(current_menu) -- changes
                    else
                        current_menu = {}
                    end
                else
                    menu_layer_record:clear()
                    last_menu_open.type = 1
                    current_menu = recursively_copy_spells(spells_template)
                    if current_menu then
                        last_menu_open = current_menu
                        last_menu_open.type = 1
                        build_a_menu(current_menu)
                    else
                        current_menu = {}
                    end
                end
            end
          end,
    [2] = function()
        menu_general_layout(windower.ffxi.get_abilities().weapon_skills,ws_template,2)
    end,
    [3] = function()
        menu_general_layout(remove_categories(windower.ffxi.get_abilities().job_abilities),ja_template,3)
    end,
    [4] = function()
        menu_general_layout(remove_categories(windower.ffxi.get_abilities().job_abilities),pet_command_template,4)
    end,
}

function remove_categories(t)
    local u = {}
    for i = 1,#t do
        if not not_a_spell:contains(res.job_abilities[t[i]].en) then
            u[#u + 1] = t[i]
        end
    end
    return u
end

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
        display_text.menu_text=menu_list:concat('\n',1,12)
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

function get_string_from_id(n)
    if last_menu_open.type == 1 then
        return (spell_aliases[n] or res.spells[n].en)
    elseif last_menu_open.type == 2 then
        return (spell_aliases[n] or res.weapon_skills[n].en)
    elseif last_menu_open.type == 3 then
        return (spell_aliases[n] or res.job_abilities[n].en)
    elseif last_menu_open.type == 4 then
        return (spell_aliases[n] or res.job_abilities[n].en)
    end
end

windower.register_event('keyboard', function(dik, flags, blocked)
    if bit.band(blocked,32)  == 32 then return end
    if dik == 42 then
        is_shift_modified = flags
    end
end)

function recursively_merge_tables(m_menu,s_menu)
    local duplicates = flatten(m_menu)
    if s_menu.sub_menus then
        if m_menu.sub_menus then
            local main_table_sub_menus = S(m_menu.sub_menus)
            for i=1,s_menu.sub_menus.n do
                if not main_table_sub_menus[s_menu.sub_menus[i]] then
                    m_menu.sub_menus[m_menu.sub_menus.n + 1] = s_menu.sub_menus[i]
                    m_menu.sub_menus.n = m_menu.sub_menus.n + 1
                    m_menu[s_menu.sub_menus[i]] = s_menu[s_menu.sub_menus[i]]
                else
                    m_menu[s_menu.s_menu[i]] = recursively_merge_tables(m_menu[s_menu.s_menu[i]],s_menu[s_menu.s_menu[i]])
                end
            end
            for i=1,s_menu.n do
                if not duplicates:contains(s_menu[i]) then
                    m_menu[m_menu.n + 1] = s_menu[i]
                    m_menu.n = m_menu.n + 1
                end
            end
        else
            m_menu.sub_menus = s_menu.sub_menus
            for i=1,m_menu.sub_menus.n do
                m_menu[m_menu.sub_menus[i]] = s_menu[s_menu.sub_menus[i]]
            end
            for i=1,s_menu.n do
                if not duplicates:contains(s_menu[i]) then
                    m_menu[m_menu.n + 1] = s_menu[i]
                    m_menu.n = m_menu.n + 1
                end
            end
        end
        s_menu.sub_menus = nil
    else
        if m_menu.sub_menus then
            for i=1,s_menu.n do
                if not duplicates:contains(s_menu[i]) then
                    m_menu[m_menu.n + 1] = s_menu[i]
                    m_menu.n = m_menu.n + 1
                end
            end
        else
            for i=1,s_menu.n do
                if not duplicates:contains(s_menu[i]) then
                    m_menu[m_menu.n + 1] = s_menu[i]
                    m_menu.n = m_menu.n + 1
                end
            end
        end
    end
    return m_menu
end

function flatten(t)
    local s = S{}
    if t.sub_menus then
        for i = 1,#t.sub_menus do
            s = s + flatten(t[t.sub_menus[i]])
        end
    end
    for i = 1,#t do
        s:add(t[i])
    end
    return s
end

category_to_resources = {
    'spells',
    'weapon_skills',
    'job_abilities',
    'job_abilities',
}

function recursively_copy_spells(t)
    local _t = {}
    if t.sub_menus then
        _t.sub_menus = L{}
        for i = 1,#t.sub_menus do
            _t[t.sub_menus[i]] = recursively_copy_spells(t[t.sub_menus[i]]) 
            if _t[t.sub_menus[i]] then
                _t.sub_menus:append(t.sub_menus[i])
            end
        end
    end
    for i = 1,#t do
        if determine_accessibility(res[category_to_resources[last_menu_open.type]][t[i]],last_menu_open.type) then
            _t[#_t+1] = t[i]
        end
    end
    _t.n = #_t
    if _t.sub_menus then
        if not (_t.n == 0 and _t.sub_menus.n == 0) then
            return _t
        else
            return nil
        end
    else
        if not (_t.n == 0) then
            return _t
        else
            return nil
        end
    end
end

function count_table_elements(t)
    for k,v in pairs(t) do
        if type(v) == 'table' then
            count_table_elements(t[k])
        end
    end
    t.n = #t
end

function determine_accessibility(spell,type) -- ability filter, slightly modified. Credit: Byrth
    if type == 1 then
        local spell_jobs = spell.levels        
        if not available_category[spell.id] and not (spell.id == 503) then
            return false
        elseif (not spell_jobs[player_info.main_job] or not (spell_jobs[player_info.main_job] <= player_info.main_job_level)) and
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
