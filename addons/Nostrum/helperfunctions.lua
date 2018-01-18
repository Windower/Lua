--[[Copyright © 2014-2015, trv
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

function prim_simple(name,settings_table,pos_x,pos_y,width,height)
    windower.prim.create(name)
    windower.prim.set_position(name,pos_x,pos_y)
    windower.prim.set_size(name,width,height)
    windower.prim.set_color(name,settings_table.color.a,settings_table.color.r,settings_table.color.g,settings_table.color.b)
    windower.prim.set_visibility(name, not is_hidden and settings_table.visible)
    saved_prims:add(name)
    prim_coordinates.x[name]=pos_x
    prim_coordinates.y[name]=pos_y
    prim_coordinates.visible[name]=settings_table.visible
    prim_coordinates.a[name]=settings_table.color.a
    prim_coordinates.r[name]=settings_table.color.r
    prim_coordinates.g[name]=settings_table.color.g
    prim_coordinates.b[name]=settings_table.color.b
end

function img_simple(name,texture,pos_x,pos_y)
    windower.prim.create(name)
    windower.prim.set_position(name,pos_x,pos_y)
    windower.prim.set_size(name,25,25)
    windower.prim.set_visibility(name,not is_hidden)
    windower.prim.set_fit_to_texture(name, false)
    windower.prim.set_texture(name, texture)
    saved_prims:add(name)
    prim_coordinates.x[name]=pos_x
    prim_coordinates.y[name]=pos_y
    prim_coordinates.visible[name]=true
end

function text_simple(name, settings_table, pos_x, pos_y, text)
    windower.text.create(name)
    windower.text.set_color(name, settings_table.color.a, settings_table.color.r, settings_table.color.g, settings_table.color.b)
    windower.text.set_bold(name,settings_table.bold)
    windower.text.set_font(name,settings_table.font)
    windower.text.set_font_size(name,settings_table.font_size)
    windower.text.set_location(name, pos_x, pos_y)
    windower.text.set_right_justified(name,settings_table.right_justified)
    windower.text.set_text(name,text)
    windower.text.set_visibility(name, not is_hidden and settings_table.visible)
    saved_texts:add(name)
    text_coordinates.x[name]=pos_x
    text_coordinates.y[name]=pos_y
    text_coordinates.visible[name]=settings_table.visible 
end

function count_cures(t)
    for i=options.cures.n,1,-1 do
        if t[options.cures[i]] then 
            macro_order[2]:append(xml_to_lua[options.cures[i]])
        end
        macro_order[3] = macro_order[2]
    end
    macro_order[1] = macro_order[2]:copy(false)
    for i=options.curagas.n,1,-1 do
        if t[options.curagas[i]] then
            macro_order[1]:append(xml_to_lua[options.curagas[i]]) 
        end
    end
end

function count_na(t)
    for i=1,options.na['n'] do
        if t[options.na[i]] then 
            macro_order[4]:append(xml_to_lua[options.na[i]]) 
        end
    end
    if macro_order[4].n ~= 0 then
        mouse_map2:append(T(macro_order[4]))
    end
end

function count_buffs(t)
    for i=1,options.buffs['n'] do
        if t[options.buffs[i]] then 
            macro_order[5]:append(xml_to_lua[options.buffs[i]]) 
        end
    end
    if macro_order[5].n ~= 0 then
        mouse_map2:append(T(macro_order[5]))
    end
end

function choose_color(hpp)
    if hpp >= 75 then
        return 'green'
    elseif hpp >= 50
        then return 'yellow'
    elseif hpp >= 25 then
        return 'orange'
    else
        return 'red'
    end
end

function prepare_names(s)
    if string.len(s)>10 then 
        return(string.sub(s,1,10)..'.') 
    else
        return(s) 
    end
end

function merge_user_file_and_settings(t,u)
    for k,v in pairs(t) do
        if u[k] then
            if type(u[k]) == 'table' then
                u[k] = merge_user_file_and_settings(t[k],u[k])
            end
        else
            u[k] = v
        end
    end
    return u
end

function indicate_distance(bool,n,x,y)
    if bool then --Invisible conflict?
        out_of_view[n] = true
        if not out_of_range[n] then
            out_of_range[n] = true
            windower.text.set_color('name'..tostring(n), 255, 175, 98, 177)
        end
    elseif ((position[1][6] - x)^2 + (position[2][6] - y)^2) > 441 then
        out_of_view[n] = false
        if not out_of_range[n] then
            out_of_range[n] = true
            windower.text.set_color('name'..tostring(n), 255, 175, 98, 177)
        end
    elseif out_of_range[n] then
        out_of_view[n] = false
        out_of_range[n] = false
        windower.text.set_color('name'..tostring(n), 255, 255, 255, 255)
    end
end

function remove_macro_information(s,bool)
    windower.text.set_text('hp'..s,'')
    windower.text.set_text('mp'..s,'')
    windower.text.set_text('tp'..s,'')
    windower.text.set_text('hpp'..s,'')
    windower.text.set_text('mpp'..s,'')
    windower.prim.set_size('phpp'..s,0,h)
    windower.prim.set_size('pmpp'..s,0,5)
    if bool then
        windower.text.set_text('name'..s,'')
    end
end

function wrecking_ball()
    for i = 1,18 do
        prims_by_layer[i]:clear()
        texts_by_layer[i]:clear()
    end
    misc_hold_for_up.texts:clear()
    misc_hold_for_up.prims:clear()
    for i = 1,3 do
        macro[i]:clear()
    end
    for key in pairs(saved_texts) do
        windower.text.delete(key)
        saved_texts:remove(key)
    end
    for key in pairs(saved_prims) do
        windower.prim.delete(key)
        saved_prims:remove(key)
    end
    for i=1,5 do
        macro_order[i]:clear()
    end
    mouse_map2:clear()
end

function toggle_visibility()
    is_hidden = not is_hidden
    if is_hidden then
        for key in pairs(saved_prims) do
            if prim_coordinates.visible[key] then
                windower.prim.set_visibility(key,false)
            end
        end
        for key in pairs(saved_texts) do
            if text_coordinates.visible[key] then
                windower.text.set_visibility(key,false)
            end
        end
    else
        for key in pairs(saved_prims) do
            windower.prim.set_visibility(key,prim_coordinates.visible[key])
        end
        for key in pairs(saved_texts) do
            windower.text.set_visibility(key,text_coordinates.visible[key])
        end
    end
    toggle_buff_visibility(not is_hidden)
end

function toggle_buff_visibility(b)
    local party = party[1]
    for i = 1, party.n do
        local id = party[i]
        local buffs = stat_table[id].buffs[1]
        local debuffs = stat_table[id].buffs[2]
        local prims = buff_map[position_lookup[id]]

        for j = 1, buffs.n do
            prims[1][j]:visible(b)
        end
        for j = 1, debuffs.n do
            prims[2][j]:visible(b)
        end
    end
end

function toggle_macro_visibility(n)
    macro_visibility[n] = not macro_visibility[n]
    if macro_visibility[n] then
        for key in pairs(macro[n]) do
            if saved_prims:contains(key) then
                windower.prim.set_visibility(key,prim_coordinates.visible[key])
            else
                windower.text.set_visibility(key,text_coordinates.visible[key])
            end
        end
    else
        for key in pairs(macro[n]) do
            if saved_prims:contains(key) then
                windower.prim.set_visibility(key,false)
            else
                windower.text.set_visibility(key,false)
            end
        end
    end
    if n == 1 then
        toggle_buff_visibility(not macro_visibility[1])
    end
end

function switch_profiles()
    wrecking_ball()
    count_cures(profile)
    count_na(profile)
    count_buffs(profile)
    coroutine.sleep(1)
    build_macro()
    define_active_regions()
    last_index=-1
end

function image_row(t,x_start,y_start)
    local s
    for i = 1,t.n do
        s = t[i]
        prim_simple('p' .. s,_settings.primitives.buff_buttons,x_start-26*i-152,y_start,26,26)
        img_simple(s..'i',windower.windower_path.."/plugins/icons/"..options.images[s],x_start-26*i-152,y_start)
        text_simple(s, _settings.text.buffs, x_start-26*i-152, y_start, options.aliases[s])
        misc_hold_for_up.texts:append(s)
        misc_hold_for_up.prims:extend({s..'i','p' .. s})
        macro[1]:add(s)
        macro[1]:add(s..'i')
        macro[1]:add('p' .. s)
        windower.text.set_stroke_color(s, 255, 0, 0, 0)
        windower.text.set_stroke_width(s, 1)
    end
end

function prim_rose(t,pos,x_start,y_start,n) --Pun!
    local spell
    local s
    local prim = _settings.primitives.buttons
    local text = _settings.text.buttons
    
    for i = 1,t.n do
        spell = t[i]
        s = spell .. tostring(pos)
        prim_simple('p' .. s,prim,x_start-(i)*(w+1)+1-153,y_start,w,h)
        text_simple(s, text, x_start-(i)*(w+1)+1+((w-font_widths[options.aliases[spell]])/2)-153, y_start, options.aliases[spell])
        prims_by_layer[pos]:append('p' .. s)
        texts_by_layer[pos]:append(s)
        macro[n]:add('p' .. s)
        macro[n]:add(s)
        if not macro_visibility[n] then
            windower.prim.set_visibility('p' .. s,false)
            windower.text.set_visibility(s,false)
        end
    end
end

last_hpp=0
last_index=-1
function update_target(mob)
    if not mob or mob.index == 0 then
        if prim_coordinates.visible['target'] then
            windower.prim.set_visibility("target_background",false)
            windower.prim.set_visibility("target",false)
            windower.text.set_visibility("targethpp",false)
            windower.text.set_visibility("target_name",false)
            text_coordinates.visible["targethpp"]=false
            text_coordinates.visible["target_name"]=false
            prim_coordinates.visible["target_background"]=false
            prim_coordinates.visible["target"]=false
        end
        last_index = 0
    else
        if not prim_coordinates.visible['target'] and not is_hidden then
            windower.prim.set_visibility("target_background",true)
            windower.prim.set_visibility("target",true)
            windower.text.set_visibility("targethpp",true)
            windower.text.set_visibility("target_name",true)
            text_coordinates.visible["targethpp"]=true
            text_coordinates.visible["target_name"]=true
            prim_coordinates.visible["target_background"]=_settings.primitives.hp_bar_background.visible
            prim_coordinates.visible["target"]=true
        end
        if mob.index ~= last_index then
            windower.text.set_text("target_name",string.sub(mob.name,1,20))
            last_index = mob.index
        end
        if mob.hpp ~= last_hpp then
            update_target_hp(mob.hpp)
        end
    end
end

function update_target_hp(hpp)
    if hpp~=last_hpp then
        windower.text.set_text("targethpp",tostring(hpp))
        windower.prim.set_size("target",150/100*hpp,30)
        if math.floor(hpp/25) ~= math.floor(last_hpp/25) then
            local color=_settings.primitives.hp_bar[choose_color(hpp)]
            windower.prim.set_color("target",color.a,color.r,color.g,color.b)
        end
    end            
    last_hpp = hpp
end

function compare_alliance_to_memory()
    local alliance_keys = {'p5', 'p4', 'p3', 'p2', 'p1', 'p0', 'a15', 'a14', 'a13', 'a12', 'a11', 'a10', 'a25', 'a24', 'a23', 'a22', 'a21', 'a20'}
    local alliance_clone = windower.ffxi.get_party()
    local ally_id=(table.keyset(alliance_clone))
    local party1 = (party_keys * ally_id)
    local party2 = (party_two_keys * ally_id)
    local party3 = (party_three_keys * ally_id)
    local names = {}
    local packet_pt_struc = {S{},S{},S{}}
    for i=1,18 do
        if ally_id[alliance_keys[i]] and alliance_clone[alliance_keys[i]].mob then
            names[alliance_clone[alliance_keys[i]].mob.id]=alliance_clone[alliance_keys[i]].mob.name
        end
        if party1[alliance_keys[i]] and alliance_clone[alliance_keys[i]].mob then
            packet_pt_struc[1]:add(alliance_clone[alliance_keys[i]].mob.id)
        elseif party2[alliance_keys[i]] and alliance_clone[alliance_keys[i]].mob then
            packet_pt_struc[2]:add(alliance_clone[alliance_keys[i]].mob.id)
        elseif party3[alliance_keys[i]] and alliance_clone[alliance_keys[i]].mob then
            packet_pt_struc[3]:add(alliance_clone[alliance_keys[i]].mob.id)
        end
    end
    new_members(packet_pt_struc)
    for k,v in pairs(names) do
        if who_am_i[k] then
            windower.text.set_text('name'..position_lookup[k],prepare_names(v))
            stat_table[k].name = v
            who_am_i[k] = nil
            update_name_map(k,v)
        end
    end
end

function new_members(packet_pt_struc) -- snippet from invite, reused in c_a_t_m
    local p = {S(party[1]),S(party[2]),S(party[3])}
    local to_kick = p[1] + p[2] + p[3] - (packet_pt_struc[3] + packet_pt_struc[2] + packet_pt_struc[1])
    for k in pairs(to_kick) do
        kick(k,math.ceil(position_lookup[k]/6))
    end
    for i=1,3 do
        local to_invite = packet_pt_struc[i] - p[i]
        for k in pairs(to_invite) do
            invite(k,i)
        end
    end
    define_active_regions()
end

function invite(id,n)
    local prim = _settings.primitives
    local text = _settings.text
    local x_start=_settings.window.x_res-1-_defaults.window.x_offset
    party[n]:append(id)
    local ptn = party[n].n
    position_lookup[id] = 1 + 6 * n - ptn
    local pos_id = position_lookup[id]
    stat_table[id]={hp=0,mp=0,mpp=0,hpp=0,name='???',tp=0,buffs={{n = 0},{n = 0}}}
    seeking_information[id] = true
    who_am_i[id] = true
    local m = tostring(n)
    local pos_tostring = tostring(pos_id)
    if vacancies[n] == 0 then
        lift_macro(n)
        if not saved_prims:contains('BG'..m) then
            local y_start = prim_coordinates.y['BG'..tostring(n-1)]-(175-75*(n-1))-ptn*(h+1)
            prim_simple('BG'..m,prim.background,x_start-macro_order[n].n*(w+1)-153,y_start,macro_order[n].n*(w+1)+1,ptn*(h+1)+1)
            prim_simple("info"..m,prim.hp_bar_background,x_start-152,y_start,152,ptn*(h+1)+1)
            macro[n]:add('BG'..m)
            if not macro_visibility[n] then
                windower.prim.set_visibility('BG'..m,false)
            end
        else
            windower.prim.set_size('info'..m,152,ptn*(h+1)+1)
            windower.prim.set_size('BG'..m,macro_order[n].n*(w+1)+1,ptn*(h+1)+1)
        end
        local y_start = prim_coordinates.y['BG'..m]+1+(h+1)*(ptn-1)
        prim_rose(macro_order[n],pos_id,x_start,y_start,n)
        prim_simple("phpp"..pos_tostring,prim.hp_bar,x_start-151,y_start,150,h)
        prim_simple("pmpp"..pos_tostring,prim.mp_bar,x_start-151,y_start+19,150,5)
        text_simple("tp"..pos_tostring, text.tp, x_start-151, y_start+11, '')
        text_simple("name"..pos_tostring, text.name, x_start-151, y_start-3, stat_table[id].name)
        text_simple("hpp"..pos_tostring, text.hpp, x_start, y_start-4, '')
        text_simple("hp"..pos_tostring, text.hp, x_start-40, y_start-3, '')
        text_simple("mp"..pos_tostring, text.mp, x_start-40, y_start+11,'') 
        prims_by_layer[pos_id]:extend(L{"phpp" ..pos_tostring,"pmpp" ..pos_tostring})
        texts_by_layer[pos_id]:extend(L{"tp" ..pos_tostring,"name" ..pos_tostring,"hpp" ..pos_tostring,"hp" ..pos_tostring,"mp" ..pos_tostring})
    else
        vacancies[n] = vacancies[n]-1
        windower.text.set_text('name'..pos_id,stat_table[id].name)
    end
    local pos = windower.ffxi.get_mob_by_id(id)
    if pos then
        position[1][pos_id] = pos.x
        position[2][pos_id] = pos.y
        indicate_distance(false,pos_id,pos.x,pos.y)
    elseif not out_of_view[pos_id] then
        indicate_distance(true,pos_id)
    end
end

function lift_macro(n)
    if n == 1 then
        up(misc_hold_for_up.texts)
        up(misc_hold_for_up.prims)
    end
    for k=n,3 do
        if saved_prims:contains("BG" .. tostring(k)) then
            up("BG" .. tostring(k))
            up("info" .. tostring(k))
        end
    end
    for j=6*n-party[n].n+1,18 do--+2?
        up(prims_by_layer[j])
        up(texts_by_layer[j])
    end
end

function up(t)
    if not t then return end
    if class(t) == 'List' then
        for i=1,t.n do
            if saved_prims:contains(t[i]) then
                windower.prim.set_position(t[i],prim_coordinates.x[t[i]],prim_coordinates.y[t[i]]-25)
                prim_coordinates.y[t[i]]=prim_coordinates.y[t[i]]-25
            elseif saved_texts:contains(t[i]) then
                windower.text.set_location(t[i],text_coordinates.x[t[i]],text_coordinates.y[t[i]]-25)
                text_coordinates.y[t[i]]=text_coordinates.y[t[i]]-25
            elseif class(t[i]) == 'Prim' then
                t[i]:up(25)
            end
        end
    elseif type(t) == 'table' then
        for _,v in pairs(t) do
            if saved_prims:contains(v) then
                windower.prim.set_position(v,prim_coordinates.x[v],prim_coordinates.y[v]-25)
                prim_coordinates.y[v]=prim_coordinates.y[v]-25
            elseif saved_texts:contains(v) then
                windower.text.set_location(v,text_coordinates.x[v],text_coordinates.y[v]-25)
                text_coordinates.y[v]=text_coordinates.y[v]-25
            elseif class(v) == 'Prim' then
                v:up(25)
            end
        end
    else
        if saved_prims:contains(t) then
            windower.prim.set_position(t,prim_coordinates.x[t],prim_coordinates.y[t]-25)
            prim_coordinates.y[t]=prim_coordinates.y[t]-25
        elseif saved_texts:contains(t) then
            windower.text.set_location(t,text_coordinates.x[t],text_coordinates.y[t]-25)
            text_coordinates.y[t]=text_coordinates.y[t]-25
        end
    end
end

function lower_macro(n)
    if n == 1 then
        down(misc_hold_for_up.texts)
        down(misc_hold_for_up.prims)
    end
    for k=n,3 do
        if saved_prims:contains("BG" .. k) then
            down("BG" .. tostring(k))
            down("info" .. tostring(k))
        end
    end
    for j=6*n-party[n].n+1,18 do
        down(prims_by_layer[j])
        down(texts_by_layer[j])
    end
end

function down(periscope)
    if not periscope then return end
    if class(periscope) == 'list' then
        for i=1,periscope.n do
            if saved_prims:contains(i) then
                windower.prim.set_position(i,prim_coordinates.x[i],prim_coordinates.y[i]+25)
                prim_coordinates.y[i]=prim_coordinates.y[i]+25
            elseif saved_texts:contains(i) then
                windower.text.set_location(i,text_coordinates.x[i],text_coordinates.y[i]+25)
                text_coordinates.y[i]=text_coordinates.y[i]+25
            elseif class(i) == 'Prim' then
                i:down(25)
            end
        end
    elseif type(periscope) == 'table' then
        for _,v in pairs(periscope) do
            if saved_prims:contains(v) then
                windower.prim.set_position(v,prim_coordinates.x[v],prim_coordinates.y[v]+25)
                prim_coordinates.y[v]=prim_coordinates.y[v]+25
            elseif saved_texts:contains(v) then
                windower.text.set_location(v,text_coordinates.x[v],text_coordinates.y[v]+25)
                text_coordinates.y[v]=text_coordinates.y[v]+25
            elseif class(v) == 'Prim' then
                v:down(25)
            end
        end
    else
        if saved_prims:contains(periscope) then
            windower.prim.set_position(periscope,prim_coordinates.x[periscope],prim_coordinates.y[periscope]+25)
            prim_coordinates.y[periscope]=prim_coordinates.y[periscope]+25
        elseif saved_texts:contains(periscope) then
            windower.text.set_location(periscope,text_coordinates.x[periscope],text_coordinates.y[periscope]+25)
            text_coordinates.y[periscope]=text_coordinates.y[periscope]+25
        end
    end
end

function trim_macro()
    for j = 1,3 do
        for i = 6*j-party[j].n,1+6*(j-1),-1 do
            local prim = prims_by_layer[i]
            for k=1,prim.n do
                if class(prim[k]) == 'Prim' then
                    prim[k]:destroy()
                else
                    windower.prim.delete(prim[k])
                    saved_prims:remove(prim[k])
                    prim_coordinates.x[prim[k]]=nil
                    prim_coordinates.y[prim[k]]=nil
                    macro[j]:remove(prim[k])
                end
            end
            local text = texts_by_layer[i]
            for k=1,text.n do
                windower.text.delete(text[k])
                saved_texts:remove(text[k])
                text_coordinates.x[text[k]]=nil
                text_coordinates.y[text[k]]=nil
                macro[j]:remove(text[k])
            end
            if prim.n ~= 0 or text.n ~= 0 then
                lower_macro(j)
            end
            prims_by_layer[i]:clear()
            texts_by_layer[i]:clear()
        end
        if saved_prims:contains('BG'..tostring(j)) then
            local s1 = 'BG'..tostring(j)
            local s2 = 'info'..tostring(j)
            if party[j].n == 0 then
                windower.prim.delete(s1)
                windower.prim.delete(s2)
                saved_prims:remove(s1)
                saved_prims:remove(s2)
                macro[j]:remove(s1)
                misc_hold_for_up.prims:delete(s1)
                misc_hold_for_up.prims:delete(s2)
            else
                windower.prim.set_size(s1,macro_order[j].n*(w+1)+1,party[j].n*(h+1)+1)
                windower.prim.set_size(s2,152,party[j].n*(h+1)+1)
            end
        end
    end
    vacancies={0,0,0}
    define_active_regions()
end

function update_macro_data(id,t)
    for i=1,t:length() do
        windower.text.set_text(t[i]..tostring(position_lookup[id]),tostring(stat_table[id][t[i]]))
    end
end

function kick(id,n)
    local i = position_lookup[id]
    
    if i < 6 then
        local party = party[1]
        local last = party[party.n]

        for k = 1, 2 do
            local prim = buff_map[position_lookup[last]][k]
            for j = 1, stat_table[last].buffs[k].n do
                prim[j]:hide()
            end
        end

        for j = party.n, 8 - i, -1 do            
            draw_buff_display(stat_table[party[j]].buffs[1], party[j - 1], 1)
            draw_buff_display(stat_table[party[j]].buffs[2], party[j - 1], 1)
        end
    end

    party[n]:remove(6*n+1-i)
    local j = 6*(n)-party[n].n
    vacancies[n] = vacancies[n] + 1

    while i > j do
        local m = 6*n+1-i
        local m_id = party[n][m]
        local pos_tostring = tostring(i)

        position_lookup[m_id] = position_lookup[m_id] + 1
        update_macro_data(m_id,L{'tp','hp','mp','hpp','mpp'})
        windower.text.set_text('name'..pos_tostring,prepare_names(stat_table[m_id]['name']))--shouldn't send name to update_macro... since it won't truncate
        local color=_settings.primitives.hp_bar[choose_color(stat_table[m_id].hpp)]
        windower.prim.set_color('phpp'..pos_tostring,color.a,color.r,color.g,color.b)
        windower.prim.set_size('phpp'..pos_tostring,150/100*stat_table[m_id]['hpp'],h)
        windower.prim.set_size('pmpp'..pos_tostring,150/100*stat_table[m_id]['mpp'],5)
        if out_of_range[i] and not out_of_range[i-1] then
            windower.text.set_color('name' .. tostring(i), 255, 255, 255, 255)
        end
        if out_of_range[i-1] and not out_of_range[i] then
            windower.text.set_color('name' .. tostring(i), 255, 175, 98, 177)
        end
        out_of_range[i] = out_of_range[i-1]
        out_of_view[i] = out_of_view[i-1]
        position[1][i] = position[1][i-1]
        position[2][i] = position[2][i-1]

        i = i - 1
    end
    
    remove_macro_information(tostring(i),true)
    stat_table[id] = nil
    out_of_zone[id] = nil
    who_am_i[id] = nil
    seeking_information[id] = nil
    position_lookup[id] = nil
end

function draw_buff_display(t, id, type)
    local p_id = position_lookup[id]
    local buffs = stat_table[id].buffs[type]

    for i = 1, t.n do
        if t[i] ~= buffs[i] then
            local prim = buff_map[p_id][type]
            
            if not prim[i] then
                local hpp_string = 'phpp'..tostring(p_id)
                prim[i] = prims.new({
                    pos = {prim_coordinates.x[hpp_string] - 1 - 12 * i, prim_coordinates.y[hpp_string] + (type == 2 and 12 or 0)},
                    w = 12,
                    color = color_over_texture[t[i]],
                    h = 12,
                    visible = not is_hidden and not macro_visibility[1],
                    set_texture = true,
                    texture = tracked_buffs[type][t[i]],
                    fit_texture = false,
                })
                prims_by_layer[p_id]:append(prim[i])
            else
                prim[i]:texture(tracked_buffs[type][t[i]])
                if color_over_texture[t[i]] then
                    prim[i]:argb(unpack(color_over_texture[t[i]]))
                else
                    prim[i]:argb(255, 255, 255, 255)
                end
                prim[i]:visible(not macro_visibility[1])
            end
        end
    end
    for i = t.n + 1, buffs.n do
        buff_map[p_id][type][i]:hide()
    end
end

function update_name_map(id,name)
    local pos_id = position_lookup[id]
    if pos_id < 7 then
        region_to_name_map[pos_id-(6-(party[1].n+vacancies[1]))] = name
    elseif pos_id < 13 then
        region_to_name_map[party[1].n+vacancies[1]+pos_id-6-(6-(party[2].n+vacancies[2]))+4] = name
    elseif pos_id < 19 then
        region_to_name_map[party[1].n+vacancies[1]+party[2].n+vacancies[2]+pos_id-12-(6-(party[3].n+vacancies[3]))+5] = name
    end
end

function define_active_regions()
    mouse_map=T{}
    region_to_name_map=T{}
    position_to_region_map=T{}
    local copy={{},{},{}} -- lists accept negative indices
    for j = 1,3 do
        for i = 1,macro_order[j].n do
            copy[j][i] = macro_order[j][i]
        end
    end
    for i = 1,vacancies[1] do
        mouse_map:append(false)
        region_to_name_map:append(false)
        position_to_region_map:append(false)
    end
    for i = 1,party[1].n do
        mouse_map:append(copy[1])
        region_to_name_map:append(stat_table[party[1][party[1].n-i+1]].name)
        position_to_region_map:append(1)
    end
    for i = 1,4 do
        mouse_map:append(false)
        region_to_name_map:append(false)
        position_to_region_map:append(false)
    end
    for i = 1,vacancies[2] do
        mouse_map:append(false)
        region_to_name_map:append(false)
        position_to_region_map:append(false)
    end
    for i = 1,party[2].n do
        mouse_map:append(copy[2])
        region_to_name_map:append(stat_table[party[2][party[2].n-i+1]].name)
        position_to_region_map:append(2)
    end
    mouse_map:append(false)
    region_to_name_map:append(false)
    position_to_region_map:append(false)
    for i = 1,vacancies[3] do
        mouse_map:append(false)
        region_to_name_map:append(false)
        position_to_region_map:append(false)
    end
    for i = 1,party[3].n do
        mouse_map:append(copy[3])
        region_to_name_map:append(stat_table[party[3][party[3].n-i+1]].name)
        position_to_region_map:append(3)
    end
end

function bit.is_set(val, pos) -- Credit: Arcon
    return bit.band(val, 2^(pos - 1)) > 0
end
