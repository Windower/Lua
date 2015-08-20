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

_addon.name = 'Nostrum'
_addon.author = 'trv'
_addon.version = '2.2.0'
_addon.commands = {'Nostrum','nos',}

packets=require('packets')
require('tables')
require('strings')
require('variables')
require('logger')
require('helperfunctions')
require('sets')
require('lists')
config = require('config')
prims = require('prims')

defaults={
    text={
        buttons={
            color={a=255,r=255,g=255,b=255},
            },
        name={
            color={a=255,r=255,g=255,b=255},
            visible=true
            },
        tp={
            color={a=255,r=255,g=255,b=255},
            visible=true
            },
        hp={
            color={a=255,r=255,g=255,b=255},
            visible=true
            },
        mp={
            color={a=255,r=255,g=255,b=255},
            visible=true
            },
        hpp={
            color={a=255,r=255,g=255,b=255},
            visible=true
            },
        na={
            color={a=255,r=255,g=255,b=255},
            visible=true
            },
        buffs={
            color={a=255,r=255,g=255,b=255},
            visible=true}
            },
    primitives={
        buttons={
            visible=false,
            color={a=0, r=0, g=0, b=0},
                },
        highlight={
            color={a=100, r=255, g=255, b=255},
            },
        curaga_buttons={
            visible=false,
            color={a=0, r=0,g=0, b=0},
            },
        background={
            visible=true,
            color={a=100, r=0, g=0, b=0},
            },
        hp_bar={
            green={a=176, r=1, g=100, b=14},
            yellow={a=176, r=255,g=255,b=0},
            orange={a=176, r=255, g=100, b=1},
            red={a=176, r=255, g=0, b=0},
            },
        mp_bar={
            visible=true,
            color={a=100, r=149, g=212, b=255},
            },
        hp_bar_background={
            visible=true,
            color={a=200, r=0, g=0, b=0},
            },
        na_buttons={
            visible=false,
            color={a=0,r=255,g=255,b=255},
        },
        buff_buttons={
            visible=false,
            color={a=0, r=255, g=255, b=255},
        },
    },
    window={x_offset=0,y_offset=0,},
    profiles={
        default={
            ["cure"]=true,
            ["cureii"]=true,
            ["cureiii"]=true,
            ["cureiv"]=true,
            ["curev"]=true,
            ["curevi"]=true,
            ["curaga"]=true,
            ["curagaii"]=true,
            ["curagaiii"]=true,
            ["curagaiv"]=true,
            ["curagav"]=true,
            ["sacrifice"]=true,
            ["erase"]=true,
            ["paralyna"]=true,
            ["silena"]=true,
            ["blindna"]=true,
            ["poisona"]=true,
            ["viruna"]=true,
            ["stona"]=true,
            ["cursna"]=true,
            ["haste"]=true,
            ["hasteii"]=false,
            ["flurry"]=false,
            ["flurryii"]=false,
            ["protect"]=false,
            ["shell"]=false,
            ["protectii"]=false,
            ["shellii"]=false,
            ["protectiii"]=false,
            ["shelliii"]=false,
            ["protectiv"]=false,
            ["shelliv"]=false,
            ["protectv"]=true,
            ["shellv"]=true,
            ["refresh"]=false,
            ["refreshii"]=false,
            ["regen"]=false,
            ["regenii"]=false,
            ["regeniii"]=false,
            ["regeniv"]=true,
            ["regenv"]=false,
            ["phalanxii"]=false,
            ["adloquium"]=false,
            ["animusaugeo"]=false,
            ["animusminuo"]=false,
            ["embrava"]=false,
            ["curingwaltz"]=false,
            ["curingwaltzii"]=false,
            ["curingwaltziii"]=false,
            ["curingwaltziv"]=false,
            ["curingwaltzv"]=false,
            ["divinewaltz"]=false,
            ["divinewaltzii"]=false,
            ["healingwaltz"]=false,
        },
    },
}
_defaults = config.load(defaults)

_settings=merge_user_file_and_settings(_defaults,settings)
profile=_settings.profiles.default

function build_macro()
    local x_start=_settings.window.x_res-1-_defaults.window.x_offset
    local y_start=_settings.window.y_res-h-1-_defaults.window.y_offset
    local prim = _settings.primitives
    local text = _settings.text

    for k=1,3 do
        local pt = party[k]
        if pt.n ~= 0 then
            prim_simple("BG"..tostring(k),prim.background,x_start-(macro_order[k].n)*(w+1)-153,y_start-pt.n*(h+1)+h,macro_order[k].n*(w+1)+1,pt.n*(h+1)+1)
            prim_simple("info"..tostring(k),prim.hp_bar_background,x_start-152,y_start-pt.n*(h+1)+h,152,pt.n*(h+1)+1)
            macro[k]:add("BG"..tostring(k))
        end
        for j=pt.n,1,-1 do
            local stats = stat_table[pt[j]]
            local n = position_lookup[pt[j]]
            local s = tostring(n)
            prim_simple("phpp" .. s,prim.hp_bar,x_start-151,y_start,150/100*stats.hpp,h)
            local color = prim.hp_bar[choose_color(stats.hpp)]
            windower.prim.set_color("phpp" .. s,color.a,color.r,color.g,color.b)
            prim_simple("pmpp" .. s,prim.mp_bar,x_start-151,y_start+19,150/100*stats.mpp,5)
            text_simple("tp" .. s, text.tp, x_start-151, y_start+11,stats.tp)
            text_simple("name" .. s, text.name, x_start-151, y_start-3, prepare_names(stats.name))
            text_simple("hpp" .. s, text.hpp, x_start, y_start-4, stats.hpp)
            text_simple("hp" .. s, text.hp, x_start-40, y_start-3, stats.hp)
            text_simple("mp" .. s, text.mp, x_start-40, y_start+11,stats.mp)
            prims_by_layer[n]:extend(L{"phpp" .. s,"pmpp" .. s})
            texts_by_layer[n]:extend(L{"tp" .. s,"name" .. s,"hpp" .. s,"hp" .. s,"mp" .. s})
            
            prim_rose(macro_order[k],n,x_start,y_start,k)
            y_start=y_start-(h+1)

        end

        y_start=y_start-(175-75*k)

    end
    
    prim_simple("target_background",prim.hp_bar_background,x_start-152,prim_coordinates.y['info1']-52,152,32)
    text_simple("target_name", text.name, x_start-151, prim_coordinates.y['info1']-50,'')
    windower.text.set_font_size("target_name11", 13)
    prim_simple("target",prim.hp_bar,x_start-151,prim_coordinates.y['info1']-50,150,30)
    text_simple("targethpp",text.tp,  x_start-151, prim_coordinates.y['info1']-34, '0')
    local color = prim.hp_bar[choose_color(100)]
    windower.prim.set_color("target",color.a,color.r,color.g,color.b)
    misc_hold_for_up.prims:append("target_background")
    misc_hold_for_up.prims:append("target")
    misc_hold_for_up.texts:append("target_name")
    misc_hold_for_up.texts:append("targethpp")
    prim_simple("pmenu",prim.hp_bar_background,x_start-152,prim_coordinates.y['info1']-20,152,20)
    text_simple("menu",text.name, x_start-94, prim_coordinates.y['info1']-18, 'menu')
    misc_hold_for_up.prims:append("pmenu")
    misc_hold_for_up.texts:append("menu")

    y_start=prim_coordinates.y['BG1']-27
    if macro_order[4].n~=0 then
        prim_simple("BGna",prim.background,x_start-33*macro_order[4].n-153,y_start,(macro_order[4].n)*(33)+1,27)
        misc_hold_for_up.prims:append("BGna")
        macro[1]:add("BGna")
        image_row(macro_order[4],x_start,y_start+1)
        y_start=y_start-27
    end

    if macro_order[5].n~=0 then
        prim_simple("BGbuffs",prim.background,x_start-33*macro_order[5].n-153,y_start,(macro_order[5].n)*(33)+1,27)
        misc_hold_for_up.prims:append("BGbuffs")
        macro[1]:add("BGbuffs")
        image_row(macro_order[5],x_start,y_start+1)
    end
    
    prim_simple("hover24",table.set(_defaults.primitives.highlight,'visible',false),0,0,29,24)
    prim_simple("hover32",table.set(_defaults.primitives.highlight,'visible',false),0,0,25,25)
    misc_hold_for_up.prims:append("hover24")
    misc_hold_for_up.prims:append("hover32")


    toggle_macro_visibility(1)
    toggle_macro_visibility(2)
    toggle_macro_visibility(3)

end

do
    local initialized = false
    initialize = function(bool)
        if bool ~= nil then initialized = bool return end
        if initialized or not windower.ffxi.get_info().logged_in then return end
        initialized = true
        local alliance_keys = {'p0', 'p1', 'p2', 'p3', 'p4', 'p5', 'a10', 'a11', 'a12', 'a13', 'a14', 'a15', 'a20', 'a21', 'a22', 'a23', 'a24', 'a25'}
        local party_from_memory = windower.ffxi.get_party()
        local player = windower.ffxi.get_player()
        
        player_id = player.id
        position_lookup = {}
        stat_table = {}
        party = {L{},L{},L{}}
        count_cures(profile)
        count_na(profile)
        count_buffs(profile)

        for i=1,18 do
            local party_member_from_memory = party_from_memory[alliance_keys[i]]

            if party_member_from_memory and party_member_from_memory.mob then
                local id = party_member_from_memory.mob.id
                local n = math.ceil(i/6)
                
                party[n]:append(id)
                
                local m = 6*n + 1 - party[n].n
                
                position_lookup[id] = m
                
                position[1][m] = party_member_from_memory.mob.x
                position[2][m] = party_member_from_memory.mob.y
                stat_table[id]={
                    hp = party_member_from_memory.hp,
                    mp = party_member_from_memory.mp,
                    mpp = party_member_from_memory.mpp,
                    hpp = party_member_from_memory.hpp,
                    tp = party_member_from_memory.tp,
                    name = party_member_from_memory.name,
                    buffs = {{n=0},{n=0}}
                }
            end
        end
        
        build_macro()
        define_active_regions()
        register_events(true)
        stat_table[player_id].index = player.index
    end
end

windower.register_event('load', initialize)

windower.register_event('login', function()
    coroutine.sleep(6)
    initialize()
end)

windower.register_event('logout', function()
    wrecking_ball()
    initialize(false)
    register_events(false)
end)

windower.register_event('addon command', function(...)
    local args={...}
    local c = args[1] and args[1]:lower() or 'help'
    if c == 'help' then
        print(help_text)
    elseif c == 'hide' or c == 'h' then
        toggle_visibility()
    elseif c == 'cut' or c == 'c' then
        trim_macro()
    elseif c == 'refresh' or c == 'r' then
        compare_alliance_to_memory()
    elseif c == 'send' or c == 's' then
        if args[2] then 
            send_string = 'send ' .. tostring(args[2]) .. ' '
            print('Commands will be sent to: ' .. tostring(args[2]))
        else
            send_string = ''
            print('Input contained no name. Send disabled.')
        end
    elseif c == 'profile' or c == 'p' then
        if args[2] == 'reload' or args[2] == 'r' then
            config.reload(defaults)
        elseif _settings.profiles[args[2]] then
            profile = _settings.profiles[args[2]]
            switch_profiles()
        else
            print('Profile ' .. args[2] .. ' not found.')
        end
    end
end)

do
    local incoming_chunk_event
    local outgoing_chunk_event
    local zone_change_event
    local keyboard_event
    local mouse_event
    local last_x,last_y = 0,0
    local last_x32,last_y32 = 0,0
    local prim_coordinates = prim_coordinates
    local x_offset = _defaults.window.x_offset
    local y_offset = _defaults.window.y_offset
    local x_res = settings.window.x_res
    local y_res = settings.window.y_res

register_events = function(bool)
    if bool then
        keyboard_event = windower.register_event('keyboard', function(dik,down,flags,blocked)
            if down and tab_keys[dik] and not bit.is_set(flags, 6) then
                coroutine.sleep(.02)
                local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
                if target then update_target(target) end
            end
        end)
        
        mouse_event = windower.register_event('mouse', function(type, x, y, delta, blocked)
            if is_hidden then return end
            if type == 0 then
                local _x = math.ceil((x_res-x-x_offset-152)/30)
                local _y = math.ceil((y_res-y-y_offset)/25)
                if mouse_map[_y] and mouse_map[_y][_x] then
                    if not macro_visibility[position_to_region_map[_y]] then
                        toggle_macro_visibility(position_to_region_map[_y])
                    end
                    if not prim_coordinates.visible['hover24'] then
                        windower.prim.set_visibility("hover24",true)
                        windower.prim.set_visibility("hover32",false)
                        prim_coordinates.visible['hover32'] = false
                        prim_coordinates.visible['hover24'] = true
                    end
                    if _x ~= last_x or _y ~= last_y then
                        prim_coordinates.x['hover24'] = x_res-153-x_offset-_x*30
                        prim_coordinates.y['hover24'] = y_res-y_offset-25*_y
                        windower.prim.set_position("hover24",prim_coordinates.x['hover24'],prim_coordinates.y['hover24'])
                        last_x = _x
                        last_y = _y
                    end
                    return
                end
                _y = math.ceil((y_res-y-y_offset-25*(party[1].n+vacancies[1]))/28)
                _x = math.ceil((x_res-x-x_offset-152)/26)
                if mouse_map2[_y] and mouse_map2[_y][_x] then
                    if not macro_visibility[1] then
                        toggle_macro_visibility(1)
                    end
                    if not prim_coordinates.visible['hover32'] then
                        windower.prim.set_visibility("hover32",true)
                        windower.prim.set_visibility("hover24",false)
                        prim_coordinates.visible['hover32'] = true
                        prim_coordinates.visible['hover24'] = false
                    end
                    if _x ~= last_x32 or _y ~= last_y32 then
                        prim_coordinates.x['hover32'] = x_res-153-x_offset-_x*26
                        prim_coordinates.y['hover32'] = y_res-y_offset-25*_y-25*(party[1].n+vacancies[1])-2*_y
                        windower.prim.set_position("hover32",prim_coordinates.x['hover32'],prim_coordinates.y['hover32'])
                        last_x32 = _x
                        last_y32 = _y
                    end
                    return
                end
                for i = 1,3 do
                    if macro_visibility[i] then
                        toggle_macro_visibility(i)
                    end
                end
                if prim_coordinates.visible['hover32'] then
                    windower.prim.set_visibility("hover32",false)
                    prim_coordinates.visible['hover32'] = false
                end
                if prim_coordinates.visible['hover24'] then
                    windower.prim.set_visibility("hover24",false)
                    prim_coordinates.visible['hover24'] = false
                end
            elseif type == 1 then
                local _x = (x_res-x-x_offset)
                local _y = math.ceil((y_res-y-y_offset)/25)
                if _x < 153 then
                    if region_to_name_map[_y] then
                        windower.send_command('%sinput /target %s':format(send_string,region_to_name_map[_y]))
                        dragged = true
                        return true
                    end
                else
                    _x = math.ceil((_x-152)/30)
                    if mouse_map[_y] and mouse_map[_y][_x] then
                        local spell = mouse_map[_y][_x]
                        windower.send_command('%sinput %s "%s" %s':format(send_string, prefix[spell], spell, region_to_name_map[_y]))
                        dragged = true
                        return true
                    end
                    _y = math.ceil((y_res-y-y_offset-25*(party[1].n+vacancies[1]))/28)
                    _x = math.ceil((x_res-x-x_offset-152)/26)
                    if mouse_map2[_y] and mouse_map2[_y][_x] then
                        local spell = mouse_map2[_y][_x]
                        windower.send_command('%sinput %s "%s" %s':format(send_string, prefix[spell], spell, '<t>'))
                        dragged = true
                        return true
                    end
                end
            elseif type == 2 then
                if dragged then
                    dragged = false
                    return true
                end
            elseif type == 4 then
                local _x = (x_res-x-x_offset)
                local _y = math.ceil((y_res-y-y_offset)/25)
                if _x < 153 then
                    if region_to_name_map[_y] then
                        windower.send_command('%sinput %s "%s" %s':format(send_string, prefix[spell_default] or '', spell_default, region_to_name_map[_y]))
                        dragged = true
                        return true
                    end
                else
                    _y = math.ceil((y_res-y-y_offset-25*(party[1].n+vacancies[1]))/28)
                    _x = math.ceil((_x-152)/26)
                    if mouse_map2[_y] and mouse_map2[_y][_x] then
                        spell_default = mouse_map2[_y][_x]
                        windower.text.set_text('menu', spell_default)
                        text_coordinates.x['menu'] = prim_coordinates.x['pmenu'] + 1 + (150 - 7.55 * string.length(spell_default))/2
                        windower.text.set_location('menu',text_coordinates.x['menu'],text_coordinates.y['menu'])
                        dragged = true
                        return true
                    end
                end
            elseif type == 5 then
                if dragged then
                    dragged = false
                    return true
                end
            end
        end)
        
        outgoing_chunk_event = windower.register_event('outgoing chunk', function(id,data)
            if id == 0x015 then
                local packet = packets.parse('outgoing', data)
                
                if packet['Target Index'] ~= last_index or last_index == stat_table[player_id].index then
                    update_target(windower.ffxi.get_mob_by_index(packet['Target Index']))
                end
                
                local position = position
                
                if position[1][6] ~= packet['X'] or position[2][6] ~= packet['Y'] then
                    position[1][6],position[2][6] = packet['X'],packet['Y']

                    local party = party
                    
                    for i = 5,7-party[1].n,-1 do
                        if not (out_of_zone[party[1][7 - i]] or out_of_view[i]) then
                            indicate_distance(false,i,position[1][i],position[2][i])
                        end
                    end
                    
                    for j = 2,3 do
                        for i = j*6,j*6-party[j].n+1,-1 do
                            if not (out_of_zone[party[j][j*6-i+1]] or out_of_view[i]) then
                                indicate_distance(false,i,position[1][i],position[2][i])
                            end
                        end
                    end
                end
            elseif id == 0x00D then
                is_zoning = true
                if not is_hidden then
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
                    
                    toggle_buff_visibility(false)
                    
                    for i = 1,party[1].n do
                        stat_table[party[1][i]].buffs={{n = 0},{n = 0}} -- wipe buffs on zone
                    end
                end
            end
        end)

        incoming_chunk_event = windower.register_event('incoming chunk', function(id, data)
            if id == 0x00D or id == 0x00E then -- kind of weird
                local Mask = data:unpack('C',0x0B)
                if data:unpack('H',9) == last_index and bit.band(Mask,4) > 0 then
                    update_target_hp(data:unpack('C',0x1F))
                end
                local f = position_lookup[data:unpack('I',5)]
                if f and f ~= 6 then
                    if bit.band(Mask,1) > 0 then               --Mask
                        local X,Z,Y = data:unpack('fff',0x0D)   --0b000001 position updated
                        position[1][f] = X                      --0b000100 hp updated
                        position[2][f] = Y                      --0b011111 model appear i.e. update all
                        indicate_distance(false,f,X,Y)          --0b100000 model disappear
                    elseif bit.band(Mask,32) > 0 then         
                        indicate_distance(true,f)
                    end
                end
            elseif id == 0x0DF then
                local packet = packets.parse('incoming', data)
                local id = packet['ID']
                if not position_lookup[id] then return end
                local to_update = L{}
                local stats = stat_table[id]
                if stats.hp ~= packet['HP'] then
                    stats.hp = packet['HP']
                    to_update:append('hp')
                end
                if stats.mp ~= packet['MP'] then
                    stats.mp = packet['MP']
                    to_update:append('mp')
                end
                if stats.tp ~= packet['TP'] then
                    stats.tp = packet['TP']
                    to_update:append('tp')
                end
                if stats.hpp ~= packet['HPP'] then
                    if math.floor(stats.hpp/25) ~= math.floor(packet['HPP']/25) then
                        local color=_settings.primitives.hp_bar[choose_color(packet['HPP'])]
                        windower.prim.set_color('phpp'..position_lookup[id],color.a,color.r,color.g,color.b)
                    end
                    stats.hpp = packet['HPP']
                    to_update:append('hpp')
                    windower.prim.set_size('phpp'..position_lookup[id],150/100*stats['hpp'],h)
                end
                if stats.mpp ~= packet['MPP'] then
                    stats.mpp = packet['MPP']
                    windower.prim.set_size('pmpp'..position_lookup[id],150/100*stats['mpp'],5)
                end
                
                update_macro_data(id,to_update)
            elseif id == 0x076 then
                for i = 0,4 do
                    local id = data:unpack('I', i*48+5)
                    
                    if id == 0 then
                        break
                    elseif position_lookup[id] then
                        local packet_buffs = L{}
                        local packet_debuffs = L{}
                        local buff
                        
                        for j = 1,32 do
                            buff = data:byte(i*48+5+16+j-1) + 256*( math.floor( data:byte(i*48+5+8+ math.floor((j-1)/4)) / 4^((j-1)%4) )%4) -- Credit: Byrth, GearSwap
                            
                            if buff == 255 then
                                break
                            elseif tracked_buffs[1][buff] then
                                packet_buffs:append(buff)
                            elseif tracked_buffs[2][buff] then
                                packet_debuffs:append(buff)
                            end
                        end
                        
                        draw_buff_display(packet_buffs, id, 1)
                        draw_buff_display(packet_debuffs, id, 2)
                        
                        stat_table[id].buffs[1] = packet_buffs
                        stat_table[id].buffs[2] = packet_debuffs
                    end
                end
            elseif id == 0x0DD then
                local packet = packets.parse('incoming',data)
                local id = packet['ID']
                if not position_lookup[id] then return end
                local pos_tostring = tostring(position_lookup[id])
                if packet['Zone'] ~= 0 then
                    if not out_of_zone[id] then
                        remove_macro_information(pos_tostring,false)
                        out_of_zone[id] = true
                        seeking_information[id] = true
                    end
                    if who_am_i[id] then
                        stat_table[id].name = packet['Name']
                        windower.text.set_text("name"..pos_tostring,prepare_names(packet['Name']))
                        who_am_i[id] = nil
                        update_name_map(id,packet['Name'])
                    end
                elseif is_zoning or seeking_information[packet['ID']] then
                    local to_update = L{}
                    local stats = stat_table[id]
                    stats.hp = packet['HP']
                    to_update:append('hp')
                    stats.mp = packet['MP']
                    to_update:append('mp')
                    stats.tp = packet['TP']
                    to_update:append('tp')
                    local color=_settings.primitives.hp_bar[choose_color(packet['HP%'])]
                    windower.prim.set_color('phpp'..pos_tostring,color.a,color.r,color.g,color.b)
                    stats.hpp = packet['HP%']
                    to_update:append('hpp')
                    windower.prim.set_size('phpp'..pos_tostring,150/100*stats['hpp'],h)
                    stats.mpp = packet['MP%']
                    windower.prim.set_size('pmpp'..pos_tostring,150/100*stats['mpp'],5)
                    update_macro_data(id,to_update)
                    if who_am_i[id] then
                        stats.name = packet['Name']
                        windower.text.set_text("name"..pos_tostring,prepare_names(packet['Name']))
                        who_am_i[id] = false
                        update_name_map(id,packet['Name'])
                    end
                    seeking_information[id] = false
                    out_of_zone[id] = false
                end
            elseif id == 0x0C8 then
                local packet = packets.parse('incoming', data)

                local packet_id_struc = {
                    packet['ID 1'],
                    packet['ID 2'],
                    packet['ID 3'],
                    packet['ID 4'],
                    packet['ID 5'],
                    packet['ID 6'],
                    packet['ID 7'],
                    packet['ID 8'],
                    packet['ID 9'],
                    packet['ID 10'],
                    packet['ID 11'],
                    packet['ID 12'],
                    packet['ID 13'],
                    packet['ID 14'],
                    packet['ID 15'],
                    packet['ID 16'],
                    packet['ID 17'],
                    packet['ID 18']
                }
                local packet_flag_struc = {
                    packet['Flags 1'],
                    packet['Flags 2'],
                    packet['Flags 3'],
                    packet['Flags 4'],
                    packet['Flags 5'],
                    packet['Flags 6'],
                    packet['Flags 7'],
                    packet['Flags 8'],
                    packet['Flags 9'],
                    packet['Flags 10'],
                    packet['Flags 11'],
                    packet['Flags 12'],
                    packet['Flags 13'],
                    packet['Flags 14'],
                    packet['Flags 15'],
                    packet['Flags 16'],
                    packet['Flags 17'],
                    packet['Flags 18']
                }
                local packet_pt_struc = {S{},S{},S{}}
                for i = 1,18 do
                    if packet_id_struc[i]~=0 then
                        if bit.band(packet_flag_struc[i],2) == 2 then
                            if bit.band(packet_flag_struc[i],1) == 1 then   --Flags
                                packet_pt_struc[3]:add(packet_id_struc[i])  --0b0000 Solo (trusts)
                            else                                            --0b0001 Party A
                                packet_pt_struc[1]:add(packet_id_struc[i])  --0b0010 Party B
                            end                                             --0b0011 Party C
                        elseif bit.band(packet_flag_struc[i],1) == 1 then   --The order of the parties
                            packet_pt_struc[2]:add(packet_id_struc[i])      --is not determined by which
                        else                                                --party contains the player
                            packet_pt_struc[1]:add(packet_id_struc[i])
                        end
                    end
                end
                
                if packet_pt_struc[3]:contains(player_id) then
                    packet_pt_struc[1],packet_pt_struc[3] = packet_pt_struc[3],packet_pt_struc[1]
                elseif packet_pt_struc[2]:contains(player_id) then
                    packet_pt_struc[1],packet_pt_struc[2] = packet_pt_struc[2],packet_pt_struc[1]
                end
                
                if packet_pt_struc[2]:length() == 0 then
                    packet_pt_struc[2],packet_pt_struc[3] = packet_pt_struc[3],packet_pt_struc[2]
                end
                new_members(packet_pt_struc)
            end
        end)
        zone_change_event = windower.register_event('zone change', function()
            if not is_hidden then
                for key in pairs(saved_prims - (macro[1] + macro[2] + macro[3])) do
                    windower.prim.set_visibility(key,prim_coordinates.visible[key])
                end
                for key in pairs(saved_texts - (macro[1] + macro[2] + macro[3])) do
                    windower.text.set_visibility(key,text_coordinates.visible[key])
                end
            end
            is_zoning = false
            if windower.ffxi.get_info().logged_in then
                stat_table[player_id].index = windower.ffxi.get_player().index
            end
        end)
    else
        windower.unregister_event(keyboard_event)
        windower.unregister_event(mouse_event)
        windower.unregister_event(incoming_chunk_event)
        windower.unregister_event(outgoing_chunk_event)
        windower.unregister_event(zone_change_event)
    end
end
end
