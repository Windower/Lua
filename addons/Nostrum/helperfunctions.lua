--[[Copyright © 2014, trv
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
    nos_saved_prims:add(name)
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
    windower.prim.set_size(name,10,10)
    windower.prim.set_visibility(name,not is_hidden)
    windower.prim.set_fit_to_texture(name, true)
    windower.prim.set_texture(name, texture)
    nos_saved_prims:add(name)
    saved_images:add(name)
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
    nos_saved_texts:add(name)
    text_coordinates.x[name]=pos_x
    text_coordinates.y[name]=pos_y
    text_coordinates.visible[name]=settings_table.visible 
end

function count_cures(t)
    _cures=0
    _curagas=0
    for i=1,6 do
        if t[options.cures[i]] then 
            _cures=_cures+1 
            macro_order.cures:append(options.cures[i]) 
        end
    end
    for i=7,11 do
        if t[options.curagas[i]] then 
            _curagas=_curagas+1 
            macro_order.curagas:append(options.curagas[i]) 
        end
    end
    macro_order.curagas:extend(macro_order.cures)
end

function count_na(t)
    _na=0
    for i=1,options.na['n'] do
        if t[options.na[i]] then 
            _na=_na+1 
            macro_order.nas:append(options.na[i]) 
        end
    end
    macro_order.nas = list.reverse(macro_order.nas)
end

function count_buffs(t)
    _buffs=0
    for i=1,options.buffs['n'] do
        if t[options.buffs[i]] then 
            _buffs=_buffs+1 
            macro_order.buffs:append(options.buffs[i]) 
        end
    end
    macro_order.buffs = list.reverse(macro_order.buffs)
end

function choose_color(hpp)
    if hpp>=75 then return 'green'
    elseif hpp>=50 then return 'yellow'
    elseif hpp>=25 then return 'orange'
    else return 'red'
    end
end

function prepare_names(s)
    if string.len(s)>10 then 
        return(string.sub(s,1,10)..'.') 
    else return(s) 
    end
end

last_hover=''
function hover(p)
    if not prim_coordinates.visible[p] then
        return
    end
    if p==last_hover then
        return
    end
    if last_hover~='' then
        windower.prim.set_color(last_hover,prim_coordinates.a[last_hover],prim_coordinates.r[last_hover],prim_coordinates.g[last_hover],prim_coordinates.b[last_hover])
    end
    last_hover=p

    windower.prim.set_color(p,settings.primitives.highlight.color.a,settings.primitives.highlight.color.r,settings.primitives.highlight.color.g,settings.primitives.highlight.color.b)

end

function zero_dark_party(n,num)
    if num == 1 then
        windower.text.set_text('name'..n,'')
        windower.text.set_text('hp'..n,'')
        windower.text.set_text('mp'..n,'')
        windower.text.set_text('tp'..n,'')
        windower.text.set_text('hpp'..n,'')
        windower.text.set_text('mpp'..n,'')
        windower.prim.set_size('phpp'..n,0,h)
        windower.prim.set_size('pmpp'..n,0,5)
    else
        windower.text.set_text('hp'..n,'')
        windower.text.set_text('mp'..n,'')
        windower.text.set_text('tp'..n,'')
        windower.text.set_text('hpp'..n,'')
        windower.text.set_text('mpp'..n,'')
        windower.prim.set_size('phpp'..n,0,h)
        windower.prim.set_size('pmpp'..n,0,5)
    end
end

function wrecking_ball()
    for key in pairs(nos_saved_texts) do
        windower.text.delete(key)
    end
    for key in pairs(nos_saved_prims) do
        windower.prim.delete(key)
    end
end

function toggle_visibility()
    is_hidden = not is_hidden
    if is_hidden then
        for key in pairs(nos_saved_prims) do
            if prim_coordinates.visible[key] then
                windower.prim.set_visibility(key,false)
            end
        end
        for key in pairs(nos_saved_texts) do
            if text_coordinates.visible[key] then
                windower.text.set_visibility(key,false)
            end
        end
    else
        for key in pairs(nos_saved_prims) do
            windower.prim.set_visibility(key,prim_coordinates.visible[key])
        end
        for key in pairs(nos_saved_texts) do
            windower.text.set_visibility(key,text_coordinates.visible[key])
        end
    end
end

function toggle_macro_visibility(n)
    macro_visibility[n] = not macro_visibility[n]
    if macro_visibility[n] then
        for key in pairs(macro[n]) do
            if nos_saved_prims[key] then
                windower.prim.set_visibility(key,prim_coordinates.visible[key])
            else
                windower.text.set_visibility(key,text_coordinates.visible[key])
            end
        end
    else
        for key in pairs(macro[n]) do
            if nos_saved_prims[key] then
                windower.prim.set_visibility(key,false)
            else
                windower.text.set_visibility(key,false)
            end
        end
    end
end

last_target=0
last_hpp=0
last_index=0
function update_target(index)
    if index == 0 or index == nil then
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
    else
        if not prim_coordinates.visible['target'] and not is_hidden then
            windower.prim.set_visibility("target_background",true)
            windower.prim.set_visibility("target",true)
            windower.text.set_visibility("targethpp",true)
            windower.text.set_visibility("target_name",true)
            text_coordinates.visible["targethpp"]=true
            text_coordinates.visible["target_name"]=true
            prim_coordinates.visible["target_background"]=settings.primitives.hp_bar_background.visible
            prim_coordinates.visible["target"]=true
        end
        local mob = windower.ffxi.get_mob_by_index(index)
        if index ~= last_index then
            windower.text.set_text("target_name",string.sub(mob.name,1,20))
        end
        local hpp = mob.hpp
        if hpp~=last_hpp then
            windower.text.set_text("targethpp",hpp)
            windower.prim.set_size("target",150/100*hpp,30)
            if math.floor(hpp/25) ~= math.floor(last_hpp/25) then
                local color=choose_color(hpp)
                windower.prim.set_color("target",settings.primitives.hp_bar[color].a,settings.primitives.hp_bar[color].r,settings.primitives.hp_bar[color].g,settings.primitives.hp_bar[color].b)
            end
        end            
        last_index = index
        last_hpp = hpp
    end
end

function compare_alliance_to_memory()
    alliance_clone = windower.ffxi.get_party()
    local ally_id=(table.keyset(alliance_clone))
    local party1 = (party_keys * ally_id)
    local party2 = (party_two_keys * ally_id)
    local party3 = (party_three_keys * ally_id)
    local names = {}
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
    new_members()
    for k,v in pairs(names) do
        if who_am_i[k] then
            windower.text.set_text('name'..position_lookup[k],prepare_names(v))
            stat_table[k].name = v
            who_am_i:remove(k)
        end
    end
end

function determine_response(x,region,w,y)
    local target
    local spell=xml_to_lua[macro_order[region_map[region]][math.ceil((x-l[region])/w)]]
    if y then 
        target = stat_table[party[region][math.ceil((y-b[region])/25)]].name
    else
        target = '<t>'
    end
    windower.send_command('%sinput /ma "%s" %s':format(send_string, spell, target))
end

function new_members() -- snippet from invite, reused in c_a_t_m
    local p = {[1]=S(party[1]),[2]=S(party[2]),[3]=S(party[3])}
    local to_kick = p[1] + p[2] + p[3] - (packet_pt_struc[3] + packet_pt_struc[2] + packet_pt_struc[1])
    for k,_ in pairs(to_kick) do
        kick(k,math.ceil(position_lookup[k]/6))
    end
    for i=1,3 do
        local to_invite = packet_pt_struc[i] - p[i]
        for k,_ in pairs(to_invite) do
            invite(k,i)
        end
        packet_pt_struc[i]:clear()
    end
    define_active_regions()
end

---------------------------------------------invite---------------------------------------------------
function invite(id,n)
    party[n]:append(id)
    position_lookup[id] = 1 + 6 * n - party[n].n
    stat_table[id]={hp=0,mp=0,mpp=0,hpp=0,name='???',tp=0,}
    seeking_information:add(id)
    who_am_i:add(id)
    if not nos_saved_prims['phpp' .. position_lookup[id]] then
        lift_macro(n)
        if n==1 then
            windower.prim.set_size('info1',152,party[1].n*(h+1)+1)
            windower.prim.set_size("BG1",(_cures+_curagas)*(w+1)+1,party[1].n*(h+1)+1)
            local block_num=12
            for i=6,1,-1 do
                if _settings[options.cures[i]] then 
                    local s = options.cures[i] .. tostring(position_lookup[id])
                    block_num=block_num-1
                    prim_simple('p' .. s,settings.primitives.buttons,x_start-(12-block_num)*(w+1)+1-153,prim_coordinates.y['BG'..n]+1+(h+1)*(party[n].n-1),w,h)
                    text_simple(s,settings.text.buttons, x_start-(12-block_num)*(w+1)+1+((w-font_widths[options.aliases[options.cures[i]]])/2)-153, prim_coordinates.y['BG'..n]+1+(h+1)*(party[n].n-1), options.aliases[options.cures[i]])
                    prims_by_layer[position_lookup[id]]:append('p' .. s)
                    texts_by_layer[position_lookup[id]]:append(s)
                    macro[1]:add('p' .. s)
                    macro[1]:add(s)
                    if not macro_visibility[1] then
                        windower.prim.set_visibility('p' .. s,false)
                        windower.text.set_visibility(s,false)
                    end
                end
            end
            for i=11,7,-1 do
                if _settings[options.curagas[i]] then
                    local s = options.curagas[i] .. tostring(position_lookup[id])
                    block_num=block_num-1
                    prim_simple('p' .. s,settings.primitives.curaga_buttons,x_start-(12-block_num)*(w+1)+1-153,prim_coordinates.y['BG'..n]+1+(h+1)*(party[n].n-1),w,h)
                    text_simple(s,settings.text.buttons, x_start-(12-block_num)*(w+1)+1+((w-font_widths[options.aliases[options.curagas[i]]])/2)-153, prim_coordinates.y['BG'..n]+1+(h+1)*(party[n].n-1), options.aliases[options.curagas[i]])
                    prims_by_layer[position_lookup[id]]:append('p' .. s)
                    texts_by_layer[position_lookup[id]]:append(s)
                    macro[1]:add('p' .. s)
                    macro[1]:add(s)
                    if not macro_visibility[1] then
                        windower.prim.set_visibility('p' .. s,false)
                        windower.text.set_visibility(s,false)
                    end
                end
            end
        else
            if not nos_saved_prims['BG'..n] then
                if n==2 then
                    prim_simple("BG2",settings.primitives.background,x_start-(_cures)*(w+1)-153,prim_coordinates.y['BG1']-100-party[2].n*(h+1)+h,_cures*(w+1)+1,party[2].n*(h+1)+1)
                    prim_simple("info2",settings.primitives.hp_bar_background,x_start-153,prim_coordinates.y['BG1']-100-party[2].n*(h+1)+h,152,party[2].n*(h+1)+1)
                    macro[2]:add("BG2")
                    if not macro_visibility[2] then
                        windower.prim.set_visibility('BG2',false)
                    end
                else
                    prim_simple("BG3",settings.primitives.background,x_start-(_cures)*(w+1)-153,prim_coordinates.y['BG2']-10-party[3].n*(h+1)+h,_cures*(w+1)+1,party[2].n*(h+1)+1)
                    prim_simple("info3",settings.primitives.hp_bar_background,x_start-153,prim_coordinates.y['BG2']-10-party[3].n*(h+1)+h,152,party[3].n*(h+1)+1)--prim_coordinates.y['BG2']-10-party[3].n*(h+1)
                    macro[3]:add("BG3")
                    if not macro_visibility[3] then
                        windower.prim.set_visibility('BG3',false)
                    end
                end
            else
                windower.prim.set_size('info'..n,152,party[n].n*(h+1)+1)
                windower.prim.set_size('BG'..n,(_cures)*(w+1)+1,party[n].n*(h+1)+1)
            end
            local block_num=7
            for i=6,1,-1 do
                if _settings[options.cures[i]] then 
                    local s = options.cures[i] .. tostring(position_lookup[id])
                    block_num=block_num-1
                    prim_simple('p' .. s,settings.primitives.buttons,x_start-(7-block_num)*(w+1)+1-153,prim_coordinates.y['BG'..n]+1+(h+1)*(party[n].n-1),w,h)
                    text_simple(s, settings.text.buttons, x_start-(7-block_num)*(w+1)+1+((w-font_widths[options.aliases[options.cures[i]]])/2)-153, prim_coordinates.y['BG'..n]+1+(h+1)*(party[n].n-1), options.aliases[options.cures[i]])
                    prims_by_layer[position_lookup[id]]:append('p' .. s)
                    texts_by_layer[position_lookup[id]]:append(s)
                    macro[n]:add('p' .. s)
                    macro[n]:add(s)
                    if not macro_visibility[n] then
                        windower.prim.set_visibility('p' .. s,false)
                        windower.text.set_visibility(s,false)
                    end
                end
            end

        end
        prim_simple("phpp".. position_lookup[id],settings.primitives.hp_bar,x_start-151,prim_coordinates.y['BG'..n]+1+(h+1)*(party[n].n-1),150,h)
        prim_simple("pmpp".. position_lookup[id],settings.primitives.mp_bar,x_start-151,prim_coordinates.y['BG'..n]+1+(h+1)*(party[n].n-1)+19,150,5)
        text_simple("tp".. position_lookup[id], settings.text.tp, x_start-151, prim_coordinates.y['BG'..n]+1+(h+1)*(party[n].n-1)+11, '')
        text_simple("name".. position_lookup[id], settings.text.name, x_start-151, prim_coordinates.y['BG'..n]+1+(h+1)*(party[n].n-1)-3, stat_table[id].name)
        text_simple("hpp".. position_lookup[id], settings.text.hpp, x_start, prim_coordinates.y['BG'..n]+1+(h+1)*(party[n].n-1)-4, '')
        text_simple("hp".. position_lookup[id], settings.text.hp, x_start-40, prim_coordinates.y['BG'..n]+1+(h+1)*(party[n].n-1)-3, '')
        text_simple("mp".. position_lookup[id], settings.text.mp, x_start-40, prim_coordinates.y['BG'..n]+1+(h+1)*(party[n].n-1)+11,'') 
        prims_by_layer[position_lookup[id]]:extend({"phpp" .. position_lookup[id],"pmpp" .. position_lookup[id]})
        texts_by_layer[position_lookup[id]]:extend({"tp" .. position_lookup[id],"name" .. position_lookup[id],"hpp" .. position_lookup[id],"hp" .. position_lookup[id],"mp" .. position_lookup[id]})
    else
        windower.text.set_text('name'..position_lookup[id],stat_table[id].name)
    end
end

function lift_macro(n)
    if n == 1 then
        up(misc_hold_for_up.texts)
        up(misc_hold_for_up.prims)
    end
    for k=n,3 do
        if nos_saved_prims["BG" .. k] then
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
    if type(t) == 'table' then
        for _,v in pairs(t) do
            if nos_saved_prims[v] then
                windower.prim.set_position(v,prim_coordinates.x[v],prim_coordinates.y[v]-25)
                prim_coordinates.y[v]=prim_coordinates.y[v]-25
            elseif nos_saved_texts[v] then
                windower.text.set_location(v,text_coordinates.x[v],text_coordinates.y[v]-25)
                text_coordinates.y[v]=text_coordinates.y[v]-25
            end
        end
    else
        if nos_saved_prims[t] then
            windower.prim.set_position(t,prim_coordinates.x[t],prim_coordinates.y[t]-25)
            prim_coordinates.y[t]=prim_coordinates.y[t]-25
        elseif nos_saved_texts[t] then
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
        if nos_saved_prims["BG" .. k] then
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
    if type(periscope) == 'table' then
        for _,v in pairs(periscope) do
            if nos_saved_prims[v] then
                windower.prim.set_position(v,prim_coordinates.x[v],prim_coordinates.y[v]+25)
                prim_coordinates.y[v]=prim_coordinates.y[v]+25
            elseif nos_saved_texts[v] then
                windower.text.set_location(v,text_coordinates.x[v],text_coordinates.y[v]+25)
                text_coordinates.y[v]=text_coordinates.y[v]+25
            end
        end
    else
        if nos_saved_prims[periscope] then
            windower.prim.set_position(periscope,prim_coordinates.x[periscope],prim_coordinates.y[periscope]+25)
            prim_coordinates.y[periscope]=prim_coordinates.y[periscope]+25
        elseif nos_saved_texts[periscope] then
            windower.text.set_location(periscope,text_coordinates.x[periscope],text_coordinates.y[periscope]+25)
            text_coordinates.y[periscope]=text_coordinates.y[periscope]+25
        end
    end
end

function trim_macro()
    for j = 1,3 do
        for i = 6*j-party[j].n,1+6*(j-1),-1 do
            local condition = 0
            for _,v in pairs(prims_by_layer[i]) do
                condition = 1
                windower.prim.delete(v)
                nos_saved_prims:remove(v)
                prim_coordinates.x[v]=nil
                prim_coordinates.y[v]=nil
                macro[j]:remove(v)
            end
            for _,v in pairs(texts_by_layer[i]) do
                condition = 1
                windower.text.delete(v)
                nos_saved_texts:remove(v)
                text_coordinates.x[v]=nil
                text_coordinates.y[v]=nil
                macro[j]:remove(v)
            end
            prims_by_layer[i]:clear()
            texts_by_layer[i]:clear()
            if condition ~= 0 then
                lower_macro(j)
            end
        end
        if nos_saved_prims['BG'..tostring(j)] then
            if party[j].n == 0 then
                windower.prim.delete('BG'..tostring(j))
                windower.prim.delete('info'..tostring(j))
                nos_saved_prims:remove('BG'..tostring(j))
                nos_saved_prims:remove('info'..tostring(j))
                macro[j]:remove('BG'..tostring(j))
                misc_hold_for_up.prims:delete('BG'..tostring(j))
                misc_hold_for_up.prims:delete('info'..tostring(j))
            else
                windower.prim.set_size('BG'..tostring(j),j == 1 and (_curagas+_cures)*(w+1)+1 or _cures*(w+1)+1,party[j].n*(h+1)+1)
                windower.prim.set_size('info'..tostring(j),152,party[j].n*(h+1)+1)
            end
        end
    end
    define_active_regions()
end

function update_macro_data(id,t)
    for i=1,t:length() do
        windower.text.set_text(t[i]..position_lookup[id],stat_table[id][t[i]])
    end
end
----------------------------------------------kick----------------------------------------------------
function kick(id,n)
    party[n]:remove(6*n+1-position_lookup[id])
    local i = position_lookup[id]
    local j = 1+6*(n-1)+5-party[n].n
    while i > j do
        local m = 6*n+1-i
        local m_id = party[n][m]
        position_lookup[m_id] = position_lookup[m_id] + 1
        update_macro_data(m_id,L{'tp','hp','mp','hpp','mpp'})
        windower.text.set_text('name'..position_lookup[m_id],prepare_names(stat_table[m_id]['name']))--shouldn't send name to update_macro... since it won't truncate
        local color=choose_color(stat_table[m_id].hpp)
        windower.prim.set_color('phpp'..position_lookup[m_id],settings.primitives.hp_bar[color].a,settings.primitives.hp_bar[color].r,settings.primitives.hp_bar[color].g,settings.primitives.hp_bar[color].b)
        windower.prim.set_size('phpp'..position_lookup[m_id],150/100*stat_table[m_id]['hpp'],h)
        windower.prim.set_size('pmpp'..position_lookup[m_id],150/100*stat_table[m_id]['mpp'],5)
        i = i - 1
    end
    zero_dark_party(6*n-party[n].n,1)
    position_lookup[id] = nil
    stat_table[id] = nil
    define_active_regions()
end

function define_active_regions()
    regions = 1
    l[1] = prim_coordinates.x['BG1']
    r[1] = prim_coordinates.x['info1']
    t[1] = prim_coordinates.y['BG1'] + party[1].n*(h+1)
    b[1] = prim_coordinates.y['BG1']
    l[6] = prim_coordinates.x['info1']
    r[6] = prim_coordinates.x['info1']+152
    t[6] = prim_coordinates.y['info1'] + party[1].n*(h+1)
    b[6] = prim_coordinates.y['info1']
    if party[2].n ~= 0 then
        regions = regions + 1
        l[2] = prim_coordinates.x['BG2']
        r[2] = prim_coordinates.x['info2']
        t[2] = prim_coordinates.y['BG2'] + party[2].n*(h+1)
        b[2] = prim_coordinates.y['BG2']
        l[7] = prim_coordinates.x['info2']
        r[7] = prim_coordinates.x['info2']+152
        t[7] = prim_coordinates.y['info2'] + party[2].n*(h+1)
        b[7] = prim_coordinates.y['info2']
    else
        l[2] = 0
        r[2] = 0
        t[2] = 0
        b[2] = 0
        l[7] = 0
        r[7] = 0
        t[7] = 0
        b[7] = 0
    end
    
    if party[3].n ~= 0 then
        regions = regions + 1
        l[3] = prim_coordinates.x['BG3']
        r[3] = prim_coordinates.x['info3']
        t[3] = prim_coordinates.y['BG3'] + party[3].n*(h+1)
        b[3] = prim_coordinates.y['BG3']
        l[8] = prim_coordinates.x['info3']
        r[8] = prim_coordinates.x['info3']+152
        t[8] = prim_coordinates.y['info3'] + party[3].n*(h+1)
        b[8] = prim_coordinates.y['info3']
    else
        l[3] = 0
        r[3] = 0
        t[3] = 0
        b[3] = 0
        l[8] = 0
        r[8] = 0
        t[8] = 0
        b[8] = 0
    end
    
    if _na ~= 0 then
        l[4] = prim_coordinates.x['BGna']
        r[4] = prim_coordinates.x['info1']
        t[4] = prim_coordinates.y['BGna']+34
        b[4] = prim_coordinates.y['BGna']
    else
        l[4] = 0
        r[4] = 0
        t[4] = 0
        b[4] = 0
    end
    
    if _buffs ~= 0 then
        l[5] = prim_coordinates.x['BGbuffs']
        r[5] = prim_coordinates.x['info1']
        t[5] = prim_coordinates.y['BGbuffs']+34
        b[5] = prim_coordinates.y['BGbuffs']
    else
        l[5] = 0
        r[5] = 0
        t[5] = 0
        b[5] = 0
    end
    
end
