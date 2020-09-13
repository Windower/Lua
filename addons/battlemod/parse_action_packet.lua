function parse_action_packet(act)
    -- Make a function that returns the action array with additional information
        -- actor : type, name, is_npc
        -- target : type, name, is_npc
    if not Self then
        Self = windower.ffxi.get_player()
        if not Self then
            return act
        end
    end
    act.actor = player_info(act.actor_id)
    act.action = get_spell(act) -- Pulls the resources line for the action
    
    if not act.action then
        return act
    end
    for i,v in ipairs(act.targets) do
        v.target = {}
        v.target[1] = player_info(v.id)
        if #v.actions > 1 then
            for n,m in ipairs(v.actions) do
                if res.action_messages[m.message] then m.fields = fieldsearch(res.action_messages[m.message][language]) end
                if res.action_messages[m.add_effect_message] then m.add_effect_fields = fieldsearch(res.action_messages[m.add_effect_message][language]) end
                if res.action_messages[m.spike_effect_message] then m.spike_effect_fields = fieldsearch(res.action_messages[m.spike_effect_message][language]) end

                if res.buffs[m.param] then --and m.param ~= 0 then
                    m.status = res.buffs[m.param][language]
                end
                if res.buffs[m.add_effect_param] then -- and m.add_effect_param ~= 0 then
                    m.add_effect_status = res.buffs[m.add_effect_param][language]
                end
                if res.buffs[m.spike_effect_param] then -- and m.spike_effect_param ~= 0 then
                    m.spike_effect_status = res.buffs[m.spike_effect_param][language]
                end
                m.number = 1
                if m.has_add_effect then
                    m.add_effect_number = 1
                end
                if m.has_spike_effect then
                    m.spike_effect_number = 1
                end
                if not check_filter(act.actor,v.target[1],act.category,m.message) then
                    m.message = 0
                    m.add_effect_message = 0
                end
                if m.spike_effect_message ~= 0 and not check_filter(v.target[1],act.actor,act.category,m.message) then
                    m.spike_effect_message = 0
                end
                if condensedamage and n > 1 then -- Damage/Action condensation within one target
                    for q=1,n-1 do
                        local r = v.actions[q]

                        if r.message ~= 0 and m.message ~= 0 then
                            if m.message == r.message or (condensecrits and S{1,67}:contains(m.message) and S{1,67}:contains(r.message)) then 
                                if (m.effect == r.effect) or (S{1,67}:contains(m.message) and S{0,2,4}:contains(m.effect) and S{0,2,4}:contains(r.effect)) then  -- combine kicks and crits
                                     if m.reaction == r.reaction then --or (S{8,10}:contains(m.reaction) and S{8,10}:contains(r.reaction)) then  -- combine hits and guards
--                                        windower.add_to_chat(8, 'Condensed: '..m.message..':'..r.message..' - '..m.effect..':'..r.effect..' - '..m.reaction..':'..r.reaction)
                                        r.number = r.number + 1
                                        if not sumdamage then
                                            if not r.cparam then
                                                r.cparam = r.param
                                                if condensecrits and r.message == 67 then
                                                    r.cparam = r.cparam..'!'
                                                end
                                            end
                                            r.cparam = r.cparam..', '..m.param
                                            if condensecrits and m.message == 67 then
                                                r.cparam = r.cparam..'!'
                                            end
                                        end
                                        r.param = m.param + r.param
                                        if condensecrits and m.message == 67 then
                                            r.message = m.message
                                            r.effect = m.effect
                                        end
                                        m.message = 0
                                    else
--                                        windower.add_to_chat(8, 'Didn\'t condense: '..m.message..':'..r.message..' - '..m.effect..':'..r.effect..' - '..m.reaction..':'..r.reaction)
                                    end
                                else
--                                    windower.add_to_chat(8, 'Didn\'t condense: '..m.message..':'..r.message..' - '..m.effect..':'..r.effect..' - '..m.reaction..':'..r.reaction)
                                end
                            else
--                                windower.add_to_chat(8, 'Didn\'t condense: '..m.message..':'..r.message..' - '..m.effect..':'..r.effect..' - '..m.reaction..':'..r.reaction)
                            end
                        end
                        if m.has_add_effect and r.add_effect_message ~= 0 then
                            if m.add_effect_effect == r.add_effect_effect and m.add_effect_message == r.add_effect_message and m.add_effect_message ~= 0 then
                                r.add_effect_number = r.add_effect_number + 1
                                if not sumdamage then
                                    r.cadd_effect_param = (r.cadd_effect_param or r.add_effect_param)..', '..m.add_effect_param
                                end
                                r.add_effect_param = m.add_effect_param + r.add_effect_param
                                m.add_effect_message = 0
                            end
                        end
                        if m.has_spike_effect and r.spike_effect_message ~= 0 then
                            if r.spike_effect_effect == r.spike_effect_effect and m.spike_effect_message == r.spike_effect_message and m.spike_effect_message ~= 0 then
                                r.spike_effect_number = r.spike_effect_number + 1
                                if not sumdamage then
                                    r.cspike_effect_param = (r.cspike_effect_param or r.spike_effect_param)..', '..m.spike_effect_param
                                end
                                r.spike_effect_param = m.spike_effect_param + r.spike_effect_param
                                m.spike_effect_message = 0
                            end
                        end
                    end
                end
            end
        else
            local tempact = v.actions[1]
            if res.action_messages[tempact.message] then tempact.fields = fieldsearch(res.action_messages[tempact.message][language]) end
            if res.action_messages[tempact.add_effect_message] then tempact.add_effect_fields = fieldsearch(res.action_messages[tempact.add_effect_message][language]) end
            if res.action_messages[tempact.spike_effect_message] then tempact.spike_effect_fields = fieldsearch(res.action_messages[tempact.spike_effect_message][language]) end
            
                
            --if tempact.add_effect_fields and tempact.add_effect_fields.status then windower.add_to_chat(8,tostring(tempact.add_effect_fields.status)..' '..res.action_messages[tempact.add_effect_message][language]) end
            
            if not check_filter(act.actor,v.target[1],act.category,tempact.message) then
                tempact.message = 0
                tempact.add_effect_message = 0
            end
            if tempact.spike_effect_message ~= 0 and not check_filter(v.target[1],act.actor,act.category,tempact.message) then
                tempact.spike_effect_message = 0
            end
            tempact.number = 1
            if tempact.has_add_effect and tempact.message ~= 674 then
                tempact.add_effect_number = 1
            end
            if tempact.has_spike_effect then
                tempact.spike_effect_number = 1
            end
            if res.buffs[tempact.param] then -- and tempact.param ~= 0 then
                tempact.status = res.buffs[tempact.param][language]
            end
            if res.buffs[tempact.add_effect_param] then -- and tempact.add_effect_param ~= 0 then
                tempact.add_effect_status = res.buffs[tempact.add_effect_param][language]
            end
            if res.buffs[tempact.spike_effect_param] then -- and tempact.spike_effect_param ~= 0 then
                tempact.spike_effect_status = res.buffs[tempact.spike_effect_param][language]
            end
        end
        
        if condensetargets and i > 1 then
            for n=1,i-1 do
                local m = act.targets[n]
--                windower.add_to_chat(8,m.actions[1].message..'  '..v.actions[1].message)
                if (v.actions[1].message == m.actions[1].message and v.actions[1].param == m.actions[1].param) or
                    (message_map[m.actions[1].message] and message_map[m.actions[1].message]:contains(v.actions[1].message) and v.actions[1].param == m.actions[1].param) or
                    (message_map[m.actions[1].message] and message_map[m.actions[1].message]:contains(v.actions[1].message) and v.actions[1].param == m.actions[1].param) then
                    m.target[#m.target+1] = v.target[1]
                    v.target[1] = nil
                    v.actions[1].message = 0
                end
            end
        end
    end
    
    for i,v in pairs(act.targets) do
        for n,m in pairs(v.actions) do
            if m.message ~= 0 and res.action_messages[m.message] ~= nil then
                local col = res.action_messages[m.message].color
                local targ = assemble_targets(act.actor,v.target,act.category,m.message)
                local color = color_filt(col,v.target[1].id==Self.id)
                if m.reaction == 11 and act.category == 1 then m.simp_name = 'parried by'
                --elseif m.reaction == 12 and act.category == 1 then m.simp_name = 'blocked by'
                elseif m.message == 1 and (act.category == 1 or act.category == 11) then m.simp_name = 'hit'
                elseif m.message == 15 then m.simp_name = 'missed'
                elseif m.message == 29 or m.message == 84 then m.simp_name = 'is paralyzed'
                elseif m.message == 30 then m.simp_name = 'anticipated by'
                elseif m.message == 31 then m.simp_name = 'absorbed by'
                elseif m.message == 32 then m.simp_name = 'dodged by'
                elseif m.message == 67 and (act.category == 1 or act.category == 11) then m.simp_name = 'critical hit'
                elseif m.message == 106 then m.simp_name = 'intimidated by'
                elseif m.message == 153 then m.simp_name = act.action.name..' fails'
                elseif m.message == 244 then m.simp_name = 'Mug fails'
                elseif m.message == 282 then m.simp_name = 'evaded by'
                elseif m.message == 373 then m.simp_name = 'absorbed by'
                elseif m.message == 352 then m.simp_name = 'RA'
                elseif m.message == 353 then m.simp_name = 'critical RA'
                elseif m.message == 354 then m.simp_name = 'missed RA'
                elseif m.message == 576 then m.simp_name = 'RA hit squarely'
                elseif m.message == 577 then m.simp_name = 'RA struck true'
                elseif m.message == 157 then m.simp_name = 'Barrage'
                elseif m.message == 77 then m.simp_name = 'Sange'
                elseif m.message == 360 then m.simp_name = act.action.name..' (JA reset)'
                elseif m.message == 426 or m.message == 427 then m.simp_name = 'Bust! '..act.action.name
                elseif m.message == 435 or m.message == 436 then m.simp_name = act.action.name..' (JAs)'
                elseif m.message == 437 or m.message == 438 then m.simp_name = act.action.name..' (JAs and TP)'
                elseif m.message == 439 or m.message == 440 then m.simp_name = act.action.name..' (SPs, JAs, TP, and MP)'
                elseif T{252,265,268,269,271,272,274,275,379,650}:contains(m.message) then m.simp_name = 'Magic Burst! '..act.action.name
                elseif not act.action then
                   m.simp_name = ''
                   act.action = {}
                else m.simp_name = act.action.name or ''
                end

                -- Debuff Application Messages
                if message_map[82]:contains(m.message) then
                    if m.status == 'Evasion Down' then
                        m.message = 237
                    end
                    if m.status == 'addle' then m.status = 'addled'
                    elseif m.status == 'bind' then m.status = 'bound'
                    elseif m.status == 'blindness' then m.status = 'blinded'
                    elseif m.status == 'Inundation' then m.status = 'inundated'
                    elseif m.status == 'paralysis' then m.status = 'paralyzed'
                    elseif m.status == 'petrification' then m.status = 'petrified'
                    elseif m.status == 'poison' then m.status = 'poisoned'
                    elseif m.status == 'silence' then m.status = 'silenced'
                    elseif m.status == 'sleep' then m.status = 'asleep'
                    elseif m.status == 'slow' then m.status = 'slowed'
                    elseif m.status == 'stun' then m.status = 'stunned'
                    elseif m.status == 'weight' then m.status = 'weighed down'
                    end
                end

--                if m.message == 93 or m.message == 273 then m.status=color_it('Vanish',color_arr['statuscol']) end

                -- Special Message Handling
                if m.message == 93 or m.message == 273 then
                    m.status=color_it('Vanish',color_arr['statuscol'])
                elseif m.message == 522 and simplify then
                    targ = targ..' (stunned)'
                elseif m.message == 1023 then
                    m.status = color_it('attacks and defenses enhanced',color_arr['statuscol'])
                elseif T{158,188,245,324,592,658}:contains(m.message) and simplify then
                    -- When you miss a WS or JA. Relevant for condensed battle.
                    m.status = 'Miss' --- This probably doesn't work due to the if a==nil statement below.
                elseif m.message == 653 or m.message == 654 then
                    m.status = color_it('Immunobreak',color_arr['statuscol'])
                elseif m.message == 655 or m.message == 656 then
                    m.status = color_it('Completely Resists',color_arr['statuscol'])
                elseif m.message == 85 or m.message == 284 then
                    if m.unknown == 2 then
                        m.status = color_it('Resists!',color_arr['statuscol'])
                    else
                        m.status = color_it('Resists',color_arr['statuscol'])
                    end
                elseif m.message == 351 then
                    m.status = color_it('status ailments',color_arr['statuscol'])
                    m.simp_name = color_it('remedy',color_arr['itemcol'])
                elseif T{75,114,156,189,248,283,312,323,336,355,408,422,423,425,659}:contains(m.message) then
                    m.status = color_it('No effect',color_arr['statuscol']) -- The status code for "No Effect" is 255, so it might actually work without this line
                end
                if m.message == 188 then
                    m.simp_name = m.simp_name..' (Miss)'
            --    elseif m.message == 189 then
            --        m.simp_name = m.simp_name..' (No Effect)'
                elseif T{78,198,328}:contains(m.message) then
                    m.simp_name = '(Too Far)'
                end
                local msg,numb = simplify_message(m.message)
                if not color_arr[act.actor.owner or act.actor.type] then windower.add_to_chat(123,'Battlemod error, missing filter:'..tostring(act.actor.owner)..' '..tostring(act.actor.type)) end
                if m.fields.status then numb = m.status else numb = pref_suf((m.cparam or m.param),m.message) end
    
                if msg and m.message == 70 and not simplify then -- fix pronoun on parry
                    if v.target[1].race == 0 then
                        msg = msg:gsub(' his ',' its ')
                    elseif female_races:contains(v.target[1].race) then
                        msg = msg:gsub(' his ',' her ')
                    end
                end
                
                local reaction_lookup = reaction_offsets[act.category] and (m.reaction - reaction_offsets[act.category]) or 0
                local has_line_break = string.find(res.action_messages[m.message].en, '${lb}') and true or false
                local prefix = (not has_line_break or simplify) and S{1,3,4,6,11,13,14,15}:contains(act.category) and (bit.band(m.unknown,1)==1 and "Cover! " or "")
                                ..(bit.band(m.unknown,4)==4 and "Magic Burst! " or "") --Used on Swipe/Lunge MB
                                ..(bit.band(m.unknown,8)==8 and "Immunobreak! " or "") --Unused? Displayed directly on message
                                ..(bit.band(m.unknown,16)==16 and "Critical Hit! " or "") --Unused? Crits have their own message
                                ..(reaction_lookup == 4 and "Blocked! " or "")
                                ..(reaction_lookup == 2 and "Guarded! " or "")
                                ..(reaction_lookup == 3 and S{3,4,6,11,13,14,15}:contains(act.category) and "Parried! " or "") or "" --Unused? They are send the same as missed
                local prefix2 = has_line_break and S{1,3,4,6,11,13,14,15}:contains(act.category) and (bit.band(m.unknown,1)==1 and "Cover! " or "")
                                ..(bit.band(m.unknown,2)==2 and "Resist! " or "")
                                ..(bit.band(m.unknown,4)==4 and "Magic Burst! " or "") --Used on Swipe/Lunge MB
                                ..(bit.band(m.unknown,8)==8 and "Immunobreak! " or "") --Unused? Displayed directly on message
                                ..(bit.band(m.unknown,16)==16 and "Critical Hit! " or "") --Unused? Crits have their own message
                                ..(reaction_lookup == 4 and "Blocked! " or "")
                                ..(reaction_lookup == 2 and "Guarded! " or "")
                                ..(reaction_lookup == 3 and S{3,4,6,11,13,14,15}:contains(act.category) and "Parried! " or "") or "" --Unused? They are send the same as missed
                windower.add_to_chat(color,prefix..make_condensedamage_number(m.number)..( (msg or tostring(m.message))
                    :gsub('${spell}',color_it(act.action.spell or 'ERROR 111',color_arr.spellcol))
                    :gsub('${ability}',color_it(act.action.ability or 'ERROR 112',color_arr.abilcol))
                    :gsub('${item}',color_it(act.action.item or 'ERROR 113',color_arr.itemcol))
                    :gsub('${item2}',color_it(act.action.item2 or 'ERROR 121',color_arr.itemcol))
                    :gsub('${weapon_skill}',color_it(act.action.weapon_skill or 'ERROR 114',color_arr.wscol))
                    :gsub('${abil}',m.simp_name or 'ERROR 115')
                    :gsub('${numb}',col == 'D' and color_it(numb or 'ERROR 116', color_arr[act.actor.damage]) or (numb or 'ERROR 116'))
                    :gsub('${actor}',color_it((act.actor.name or 'ERROR 117' ) .. (act.actor.owner_name or "") ,color_arr[act.actor.owner or act.actor.type]))
                    :gsub('${target}',targ)
                    :gsub('${lb}','\7'..prefix2)
                    :gsub('${number}',act.action.number or m.param)
                    :gsub('${status}',m.status or 'ERROR 120')
                    :gsub('${gil}',m.param..' gil')))
                    if not non_block_messages:contains(m.message) then
                        m.message = 0
                    end
            end
            if m.has_add_effect and m.add_effect_message ~= 0 and add_effect_valid[act.category] then
                local targ = assemble_targets(act.actor,v.target,act.category,m.add_effect_message)
                local col = res.action_messages[m.add_effect_message].color
                local color = color_filt(col,v.target[1].id==Self.id)
                if m.add_effect_message > 287 and m.add_effect_message < 303 then m.simp_add_name = skillchain_arr[m.add_effect_message-287]
                elseif m.add_effect_message > 384 and m.add_effect_message < 399 then m.simp_add_name = skillchain_arr[m.add_effect_message-384]
                elseif m.add_effect_message > 766 and m.add_effect_message < 769 then m.simp_add_name = skillchain_arr[m.add_effect_message-752]
                elseif m.add_effect_message > 768 and m.add_effect_message < 771 then m.simp_add_name = skillchain_arr[m.add_effect_message-754]
                elseif m.add_effect_message ==603 then m.simp_add_name = 'TH'
                elseif m.add_effect_message ==776 then m.simp_add_name = 'AE: Chainbound'
                else m.simp_add_name = 'AE'
                end
                local msg,numb = simplify_message(m.add_effect_message)
                if m.add_effect_fields.status then numb = m.add_effect_status else numb = pref_suf((m.cadd_effect_param or m.add_effect_param),m.add_effect_message) end
                if not act.action then
--                    windower.add_to_chat(color, 'act.action==nil : '..m.message..' - '..m.add_effect_message..' - '..msg)
                else
                    windower.add_to_chat(color,make_condensedamage_number(m.add_effect_number)..(msg
                        :gsub('${spell}',act.action.spell or 'ERROR 127')
                        :gsub('${ability}',act.action.ability or 'ERROR 128')
                        :gsub('${item}',act.action.item or 'ERROR 129')
                        :gsub('${weapon_skill}',act.action.weapon_skill or 'ERROR 130')
                        :gsub('${abil}',m.simp_add_name or act.action.name or 'ERROR 131')
                        :gsub('${numb}',col == 'D' and color_it(numb or 'ERROR 132', color_arr[act.actor.damage]) or (numb or 'ERROR 132'))
                        :gsub('${actor}',color_it(act.actor.name,color_arr[act.actor.owner or act.actor.type]))
                        :gsub('${target}',targ)
                        :gsub('${lb}','\7')
                        :gsub('${number}',m.add_effect_param)
                        :gsub('${status}',m.add_effect_status or 'ERROR 178')))
                        if not non_block_messages:contains(m.add_effect_message) then
                            m.add_effect_message = 0
                        end
                end
            end
            if m.has_spike_effect and m.spike_effect_message ~= 0 and spike_effect_valid[act.category] then
                local targ = assemble_targets(act.actor,v.target,act.category,m.spike_effect_message)
                local col = res.action_messages[m.spike_effect_message].color
                local color = color_filt(col,act.actor.id==Self.id)
                
                local actor = act.actor
                if m.spike_effect_message == 14 then 
                    m.simp_spike_name = 'from counter'
                elseif T{33,606}:contains(m.spike_effect_message) then
                    m.simp_spike_name = 'counter'
                    actor = v.target[1] --Counter dmg is done by the target, fix for coloring the dmg
                elseif m.spike_effect_message == 592 then
                    m.simp_spike_name = 'missed counter'
                elseif m.spike_effect_message == 536 then
                    m.simp_spike_name = 'retaliation'
                    actor = v.target[1] --Retaliation dmg is done by the target, fix for coloring the dmg
                elseif m.spike_effect_message == 535 then
                    m.simp_spike_name = 'from retaliation'
                else
                    m.simp_spike_name = 'spikes'
                    actor = v.target[1] --Spikes dmg is done by the target, fix for coloring the dmg
                end

                local msg = simplify_message(m.spike_effect_message)
                if m.spike_effect_fields.status then numb = m.spike_effect_status else numb = pref_suf((m.cspike_effect_param or m.spike_effect_param),m.spike_effect_message) end
                windower.add_to_chat(color,make_condensedamage_number(m.spike_effect_number)..(msg
                    :gsub('${spell}',act.action.spell or 'ERROR 142')
                    :gsub('${ability}',act.action.ability or 'ERROR 143')
                    :gsub('${item}',act.action.item or 'ERROR 144')
                    :gsub('${weapon_skill}',act.action.weapon_skill or 'ERROR 145')
                    :gsub('${abil}',m.simp_spike_name or act.action.name or 'ERROR 146')
                    :gsub('${numb}',col == 'D' and color_it(numb or 'ERROR 147', color_arr[actor.damage]) or (numb or 'ERROR 147'))
                    :gsub((simplify and '${target}' or '${actor}'),color_it(act.actor.name,color_arr[act.actor.owner or act.actor.type]))
                    :gsub((simplify and '${actor}' or '${target}'),targ)
                    :gsub('${lb}','\7')
                    :gsub('${number}',m.spike_effect_param)
                    :gsub('${status}',m.spike_effect_status or 'ERROR 150')))
                    if not non_block_messages:contains(m.spike_effect_message) then
                        m.spike_effect_message = 0
                    end
            end
        end
    end
    
    return act
end

function pref_suf(param,msg_ID)
    local outstr = tostring(param)
    if res.action_messages[msg_ID] and res.action_messages[msg_ID].prefix then
        outstr = res.action_messages[msg_ID].prefix..' '..outstr
    end
    if res.action_messages[msg_ID] and res.action_messages[msg_ID].suffix then
        outstr = outstr..' '..res.action_messages[msg_ID].suffix
    end
    return outstr
end

function simplify_message(msg_ID)
    local msg = res.action_messages[msg_ID][language]
    local fields = fieldsearch(msg)

    if simplify and not T{23,64,133,139,140,204,210,211,212,213,214,350,442,516,531,557,565,582,674}:contains(msg_ID) then
        if T{93,273,522,653,654,655,656,85,284,75,114,156,189,248,283,312,323,336,351,355,408,422,423,425,453,659,158,245,324,658,1023}:contains(msg_ID) then
            fields.status = true
        end
        if msg_ID == 31 or msg_ID == 798 or msg_ID == 799 then
            fields.actor = true
        end
        if (msg_ID > 287 and msg_ID < 303) or (msg_ID > 384 and msg_ID < 399) or (msg_ID > 766 and msg_ID < 771) or
            T{129,152,161,162,163,165,229,384,453,603,652,798,1023}:contains(msg_ID) then
                fields.ability = true
        end
        
        if T{125,593,594,595,596,597,598,599}:contains(msg_ID) then
            fields.ability = true
            fields.item = true
        end
        
        if T{129,152,153,160,161,162,163,164,165,166,167,168,229,244,652,1023}:contains(msg_ID) then
            fields.actor  = true
            fields.target = true
        end

        local Despoil_msg = {[593] = 'Attack Down', [594] = 'Defense Down', [595] = 'Magic Atk. Down', [596] = 'Magic Def. Down', [597] = 'Evasion Down', [598] = 'Accuracy Down', [599] = 'Slow',}
        if line_full and fields.number and fields.target and fields.actor then
            msg = line_full
        elseif line_aoebuff and fields.status and fields.target then --and fields.actor then -- and (fields.spell or fields.ability or fields.item or fields.weapon_skill) then
            msg = line_aoebuff
        elseif line_item and fields.item2 then
            if fields.number then
                msg = line_itemnum
            else
                msg = line_item
            end
        elseif line_steal and fields.item and fields.ability then
            if T{593,594,595,596,597,598,599}:contains(msg_ID) then
                msg = line_steal..''..string.char(0x07)..'AE: '..color_it(Despoil_msg[msg_ID],color_arr['statuscol'])
            else
                msg = line_steal
            end
        elseif line_nonumber and not fields.number then
            msg = line_nonumber
        elseif line_aoe and T{264}:contains(msg_ID) then
            msg = line_aoe
        elseif line_noactor and not fields.actor and (fields.spell or fields.ability or fields.item or fields.weapon_skill) then
            msg = line_noactor
        elseif line_noability and not fields.actor then
            msg = line_noability
        elseif line_notarget and fields.actor and fields.number then
            if msg_ID == 798 then --Maneuver message
                msg = line_notarget.."%"
            elseif msg_ID == 799 then --Maneuver message with overload
                msg = line_notarget.."% (${actor} overloaded)"
            else
                msg = line_notarget
            end
        end
    end
    return msg
end

function assemble_targets(actor,targs,category,msg)
    local targets = {}
    for i,v in pairs(targs) do
    -- Done in two loops so that the ands and commas don't get out of place.
    -- This loop filters out unwanted targets.
        if check_filter(actor,v,category,msg) then
            targets[#targets+1] = v
        end
    end
    
    local out_str
    if targetnumber and #targets > 1 then
        out_str = '{'..#targets..'} '
    else
        out_str = ''
    end
    
    for i,v in pairs(targets) do
        if i == 1 then
            out_str = out_str..color_it(v.name,color_arr[v.owner or v.type]) 
        else
            out_str = conjunctions(out_str,color_it(v.name,color_arr[v.owner or v.type]),#targets,i)
        end
    end
    return out_str
end

function make_condensedamage_number(number)
    if swingnumber and condensedamage and 1 < number then
        return '['..number..'] '
    else
        return ''
    end
end

function player_info(id)
    local player_table = windower.ffxi.get_mob_by_id(id)
    local typ,dmg,owner,filt,owner_name
    
    if player_table == nil then
        return {name=nil,id=nil,is_npc=nil,type='debug',owner=nil, owner_name=nil,race=nil}
    end
    
    for i,v in pairs(windower.ffxi.get_party()) do
        if type(v) == 'table' and v.mob and v.mob.id == player_table.id then
            typ = i
            if i == 'p0' then
                filt = 'me'
                dmg = 'mydmg'
            elseif i:sub(1,1) == 'p' then
                filt = 'party'
                dmg = 'partydmg'
            else
                filt = 'alliance'
                dmg = 'allydmg'
            end
        end
    end
    
    if not filt then
        if player_table.is_npc then
            if player_table.index>1791 then
                typ = 'other_pets'
                filt = 'other_pets'
                owner = 'other'
                dmg = 'otherdmg'
                for i,v in pairs(windower.ffxi.get_party()) do
                    if type(v) == 'table' and v.mob and v.mob.pet_index and v.mob.pet_index == player_table.index then
                        if i == 'p0' then
                            typ = 'my_pet'
                            filt = 'my_pet'
                            dmg = 'mydmg'
                        end
                        owner = i
                        owner_name = showownernames and ' (' .. v.mob.name .. ')'
                        break
                    elseif type(v) == 'table' and v.mob and v.mob.fellow_index and v.mob.fellow_index == player_table.index then
                        if i == 'p0' then
                            typ = 'my_fellow'
                            filt = 'my_fellow'
                            dmg = 'mydmg'
                        end
                        owner = i
                        owner_name = showownernames and ' (' .. v.mob.name .. ')'
                        break
                    end
                end
            else
                typ = 'mob'
                filt = 'monsters'
                dmg = 'mobdmg'
                
                if filter.enemies then
                    for i,v in pairs(Self.buffs) do
                        if domain_buffs:contains(v) then
                            -- If you are in Domain Invasion, or a Reive, or various other places
                            -- then all monsters should be considered enemies.
                            filt = 'enemies'
                            break
                        end
                    end
                    
                    if filt ~= 'enemies' then
                        for i,v in pairs(windower.ffxi.get_party()) do
                            if type(v) == 'table' and nf(v.mob,'id') == player_table.claim_id then
                                filt = 'enemies'
                                break
                            end
                        end
                    end
                end
            end
        else
            typ = 'other'
            filt = 'others'
            dmg = 'otherdmg'
        end
    end
    if not typ then typ = 'debug' end
    return {name=player_table.name,id=id,is_npc = player_table.is_npc,type=typ,damage=dmg,filter=filt,owner=(owner or nil), owner_name=(owner_name or nil),race = player_table.race}
end

function get_spell(act)
    local spell, abil_ID, effect_val = {}
    local msg_ID = act.targets[1].actions[1].message

    if T{7,8,9}:contains(act['category']) then
        abil_ID = act.targets[1].actions[1].param
    elseif T{3,4,5,6,11,13,14,15}:contains(act.category) then
        abil_ID = act.param
        effect_val = act.targets[1].actions[1].param
    end
    
    if act.category == 1 then
        spell.english = 'hit'
        spell.german = spell.english
        spell.japanese = spell.english
        spell.french = spell.english
    elseif act.category == 2 and act.category == 12 then
        if msg_ID == 77 then
            spell = res.job_abilities[171] -- Sange
            if spell then
                spell.name = color_it(spell[language],color_arr.abilcol)
            end
        elseif msg_ID == 157 then
            spell = res.job_abilities[60] -- Barrage
            if spell then
                spell.name = color_it(spell[language],color_arr.abilcol)
            end
        else
            spell.english = 'Ranged Attack'
            spell.german = spell.english
            spell.japanese = spell.english
            spell.french = spell.english
        end
    else
        if not res.action_messages[msg_ID] then
            if T{4,8}:contains(act['category']) then
                spell = res.spells[abil_ID]
            elseif T{6,14,15}:contains(act['category']) or T{7,13}:contains(act['category']) and false then
                spell = res.job_abilities[abil_ID] -- May have to correct for charmed pets some day, but I'm not sure there are any monsters with TP moves that give no message.
            elseif T{3,7,11}:contains(act['category']) then
                if abil_ID < 256 then
                    spell = res.weapon_skills[abil_ID] -- May have to correct for charmed pets some day, but I'm not sure there are any monsters with TP moves that give no message.
                else
                    spell = res.monster_abilities[abil_ID]
                end
            elseif T{5,9}:contains(act['category']) then
                spell = res.items[abil_ID]
            else
                spell = {none=tostring(msg_ID)} -- Debugging
            end
            return spell
        end
        
        local fields = fieldsearch(res.action_messages[msg_ID][language])
        
        if fields.spell then
            spell = res.spells[abil_ID]
            if spell then
                spell.name = color_it(spell[language],color_arr.spellcol)
                spell.spell = color_it(spell[language],color_arr.spellcol)
            end
        elseif fields.ability then
            spell = res.job_abilities[abil_ID]
            if spell then
                spell.name = color_it(spell[language],color_arr.abilcol)
                spell.ability = color_it(spell[language],color_arr.abilcol)
            end
        elseif fields.weapon_skill then
            if abil_ID > 256 then -- WZ_RECOVER_ALL is used by chests in Limbus
                spell = res.monster_abilities[abil_ID]
                if not spell then
                    spell = {english= 'Special Attack'}
                end
            elseif abil_ID <= 256 then
                spell = res.weapon_skills[abil_ID]
            end
            if spell then
                spell.name = color_it(spell[language],color_arr.wscol)
                spell.weapon_skill = color_it(spell[language],color_arr.wscol)
            end
        elseif msg_ID == 303 then
            spell = res.job_abilities[74] -- Divine Seal
            if spell then
                spell.name = color_it(spell[language],color_arr.abilcol)
                spell.ability = color_it(spell[language],color_arr.abilcol)
            end
        elseif msg_ID == 304 then
            spell = res.job_abilities[75] -- 'Elemental Seal'
            if spell then
                spell.name = color_it(spell[language],color_arr.abilcol)
                spell.ability = color_it(spell[language],color_arr.abilcol)
            end
        elseif msg_ID == 305 then
            spell = res.job_abilities[76] -- 'Trick Attack'
            if spell then
                spell.name = color_it(spell[language],color_arr.abilcol)
                spell.ability = color_it(spell[language],color_arr.abilcol)
            end
        elseif msg_ID == 311 or msg_ID == 312 then
            spell = res.job_abilities[79] -- 'Cover'
            if spell then
                spell.name = color_it(spell[language],color_arr.abilcol)
                spell.ability = color_it(spell[language],color_arr.abilcol)
            end
        elseif msg_ID == 240 or msg_ID == 241 then
            spell = res.job_abilities[43] -- 'Hide'
            if spell then
                spell.name = color_it(spell[language],color_arr.abilcol)
                spell.ability = color_it(spell[language],color_arr.abilcol)
            end
        end

        if fields.item then
            if T{125,593,594,595,596,597,598,599}:contains(msg_ID) then
                spell.item = color_it(res.items[effect_val]['english_log'], color_arr.itemcol)
            else
                spell = res.items[abil_ID]
                if spell then
                    spell.name = color_it(spell['english_log'],color_arr.itemcol)
                    spell.item = color_it(spell['english_log'],color_arr.itemcol)
                end
            end
        end
        
        if fields.item2 then
            local tempspell = res.items[effect_val]
            spell.item2 = color_it(tempspell.english_log,color_arr.itemcol)
            if fields.number then
                spell.number = act.targets[1].actions[1].add_effect_param
            end
        end
    end
    
    if spell and not spell.name then spell.name = spell[language] end
    return spell
end


function color_filt(col,is_me)
    --Used to convert situational colors from the resources into real colors
    --Depends on whether or not the target is you, the same as using in-game colors
    -- Returns a color code for windower.add_to_chat()
    -- Does not currently support a Debuff/Buff distinction
    if col == "D" then -- Damage
        if is_me then
            return 28
        else
            return 20
        end
    elseif col == "M" then -- Misses
        if is_me then
            return 29
        else
            return 21
        end
    elseif col == "H" then -- Healing
        if is_me then
            return 30
        else
            return 22
        end
    elseif col == "B" then -- Beneficial effects
        if is_me then
            return 56
        else
            return 60
        end
    elseif col == "DB" then -- Detrimental effects (I don't know how I'd split these)
        if is_me then
            return 57
        else
            return 61
        end
    elseif col == "R" then -- Resists
        if is_me then
            return 59
        else
            return 63
        end
    else
        return col
    end
end

function condense_actions(action_array)
    for i,v in pairs(action_array) do
        local comb_table = {}
        for n,m in pairs(v) do
            if comb_table[m.primary.name] then
                if m.secondary.name == 'number' then
                    comb_table[m.primary.name].secondary.name = tostring(tonumber(comb_table[m.primary.name].secondary.name)+tonumber(m.secondary.name))
                end
                comb_table[m.primary.name].count = comb_table[m.primary.name].count + 1
            else
                comb_table[m.primary.name] = m
                comb_table[m.primary.name].count = 1
            end
            m = nil -- Could cause next() error
        end
        for n,m in pairs(comb_table) do
            v[#v+1] = m
        end
    end
    return action_array
end

function condense_targets(action_array)
    local comb_table = {}
    for i,v in pairs(action_array) do
        local was_created = false
        for n,m in pairs(comb_table) do
            if table.equal(v,m,3) then -- Compares 3 levels deep
                n[#n+1] = i[1]
                was_created = true
            end
        end
        if not was_created then
            comb_table[{i[1]}] = v
        end
    end
    return comb_table
end
