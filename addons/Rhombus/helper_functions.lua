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

function colors_of_the_wind(s)
    for k,_ in pairs(is_icon) do
        is_icon[k] = false
    end
    is_icon[s] = true
end

function remove_categories(t)
    local u = {}
    local res = res.job_abilities
    for i = 1,#t do
        if not not_a_spell:contains(res[t[i]].en) then
            u[#u + 1] = t[i]
        end
    end
    return u
end

function get_string_from_id(n)
    return (spell_aliases[n] or res[category_to_resources[last_menu_open.type]][n].en)
end

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

function count_job_points()
    local n = 0
    for _,v in pairs(windower.ffxi.get_player().job_points[res.jobs[player_info.main_job].ens:lower()]) do
        n = n + v*(v+1)
    end 
    return n/2
end

function menu_building_snippet()
    if current_menu then
        current_menu.type = last_menu_open.type
        last_menu_open = current_menu
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
end

function bit.is_set(val, pos) -- Credit: Arcon
    return bit.band(val, 2^(pos - 1)) > 0
end
