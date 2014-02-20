require 'tables'
require 'sets'
file = require 'files'
config = require 'config'

require 'generic_helpers'
require 'parse_action_packet'
require 'statics'
res = require 'resources'

_addon.version = '3.12'
_addon.name = 'BattleMod'
_addon.author = 'Byrth, maintainer: SnickySnacks'
_addon.commands = {'bm','battlemod'}

windower.register_event('load',function()
    if debugging then windower.debug('load') end
    options_load()
end)

windower.register_event('login',function (name)
    if debugging then windower.debug('login') end
    windower.send_command('@wait 10;lua i battlemod options_load;')
end)

windower.register_event('addon command',function (...)
    if debugging then windower.debug('addon command') end
    local term = table.concat({...}, ' ')
    local splitarr = split(term,' ')
    if splitarr[1] ~= nil then
        if splitarr[1]:lower() == 'commamode' then
            commamode = not commamode
            windower.add_to_chat(121,'Battlemod: Comma Mode flipped! - '..tostring(commamode))
        elseif splitarr[1]:lower() == 'oxford' then
            oxford = not oxford
            windower.add_to_chat(121,'Battlemod: Oxford Mode flipped! - '..tostring(oxford))
        elseif splitarr[1]:lower() == 'targetnumber' then
            targetnumber = not targetnumber
            windower.add_to_chat(121,'Battlemod: Target Number flipped! - '..tostring(targetnumber))
        elseif splitarr[1]:lower() == 'swingnumber' then
            swingnumber = not swingnumber
            windower.add_to_chat(121,'Battlemod: Round Number flipped! - '..tostring(swingnumber))
        elseif splitarr[1]:lower() == 'sumdamage' then
            sumdamage = not sumdamage
            windower.add_to_chat(121,'Battlemod: Sum Damage flipped! - '..tostring(sumdamage))
        elseif splitarr[1]:lower() == 'condensecrits' then
            condensecrits = not condensecrits
            windower.add_to_chat(121,'Battlemod: Condense Crits flipped! - '..tostring(condensecrits))
        elseif splitarr[1]:lower() == 'cancelmulti' then
            cancelmulti = not cancelmulti
            windower.add_to_chat(121,'Battlemod: Multi-canceling flipped! - '..tostring(cancelmulti))
        elseif splitarr[1]:lower() == 'reload' then
            options_load()
        elseif splitarr[1]:lower() == 'unload' then
            windower.send_command('@lua u battlemod')
        elseif splitarr[1]:lower() == 'simplify' then
            simplify = not simplify
            windower.add_to_chat(121,'Battlemod: Text simplification flipped! - '..tostring(simplify))
        elseif splitarr[1]:lower() == 'condensedamage' then
            condensedamage = not condensedamage
            windower.add_to_chat(121,'Battlemod: Condensed Damage text flipped! - '..tostring(condensedamage))
        elseif splitarr[1]:lower() == 'condensetargets' then
            condensetargets = not condensetargets
            windower.add_to_chat(121,'Battlemod: Condensed Targets flipped! - '..tostring(condensetargets))
        elseif splitarr[1]:lower() == 'colortest' then
            local counter = 0
            local line = ''
            for n = 1, 509 do
                if not color_redundant:contains(n) and not black_colors:contains(n) then
                    if n <= 255 then
                        loc_col = string.char(0x1F, n)
                    else
                        loc_col = string.char(0x1E, n - 254)
                    end
                    line = line..loc_col..string.format('%03d ', n)
                    counter = counter + 1
                end
                if counter == 16 or n == 509 then
                    windower.add_to_chat(1, line)
                    counter = 0
                    line = ''
                end
            end
            windower.add_to_chat(122,'Colors Tested!')
        elseif splitarr[1]:lower() == 'help' then
            print('   :::   '.._addon.name..' ('.._addon.version..')   :::')
            print('Toggles: (* subtoggles)')
            print('           1. simplify         --- Condenses battle text using custom messages ('..tostring(simplify)..')')
            print('           2. condensetargets  --- Collapse similar messages with multiple targets ('..tostring(condensetargets)..')')
            print('               * targetnumber  --- Toggle target number display ('..tostring(targetnumber)..')')
            print('               * oxford        --- Toggle use of oxford comma ('..tostring(oxford)..')')
            print('               * commamode     --- Toggle comma-only mode ('..tostring(commamode)..')')
            print('           3. condensedamage   --- Condenses damage messages within attack rounds ('..tostring(condensedamage)..')')
            print('               * swingnumber   --- Show # of attack rounds ('..tostring(swingnumber)..')')
            print('               * sumdamage     --- Sums condensed damage, if false damage is comma separated ('..tostring(sumdamage)..')')
            print('               * condensecrits --- Condenses critical hits and normal hits together ('..tostring(condensecrits)..')')
            print('           4. cancelmulti      --- Cancles multiple consecutive identical lines ('..tostring(cancelmulti)..')')
            print('Utilities: 1. colortest        --- Shows the 509 possible colors for use with the settings file')
            print('           2. reload           --- Reloads settings file')
            print('           3. unload           --- Unloads Battlemod')
        end
    end
end)

windower.register_event('incoming text',function (original, modified, color)
    if debugging then windower.debug('outgoing text') end
    local redcol = color%256
    
    if redcol == 121 and cancelmulti then
        a,z = string.find(original,'Equipment changed')
        
        if a and not block_equip then
            windower.send_command('@wait 1;lua i battlemod flip_block_equip')
            block_equip = true
        elseif a and block_equip then
            modified = true
        end
    elseif redcol == 123 and cancelmulti then
        a,z = string.find(original,'You were unable to change your equipped items')
        b,z = string.find(original,'You cannot use that command while viewing the chat log')
        c,z = string.find(original,'You must close the currently open window to use that command')
        
        if (a or b or c) and not block_cannot then
            windower.send_command('@wait 1;lua i battlemod flip_block_cannot')
            block_cannot = true
        elseif (a or b or c) and block_cannot then
            modified = true
        end
    end
    
    return modified,color
end)

function flip_block_equip()
    block_equip = not block_equip
end

function flip_block_cannot()
    block_cannot = not block_cannot
end

function options_load()
    if windower.ffxi.get_player() then
        Self = windower.ffxi.get_player()
    end
    if not windower.dir_exists(windower.addon_path..'data\\') then
        windower.create_dir(windower.addon_path..'data\\')
    end
    if not windower.dir_exists(windower.addon_path..'data\\filters\\') then
        windower.create_dir(windower.addon_path..'data\\filters\\')
    end
     
    local settingsFile = file.new('data\\settings.xml',true)
    local filterFile=file.new('data\\filters\\filters.xml',true)
    local colorsFile=file.new('data\\colors.xml',true)
    
    if not file.exists('data\\settings.xml') then
        settingsFile:write(default_settings)
        print('Default settings xml file created')
    end
    
    local settingtab = config.load('data\\settings.xml',default_settings_table)
    config.save(settingtab)
    
    for i,v in pairs(settingtab) do
        _G[i] = v
    end
    
    if not file.exists('data\\filters\\filters.xml') then
        filterFile:write(default_filters)
        print('Default filters xml file created')
    end
    local tempplayer = windower.ffxi.get_player()
    if tempplayer then
        if tempplayer.main_job ~= 'NONE' then
            filterload(tempplayer.main_job)
        elseif windower.ffxi.get_mob_by_id(tempplayer.id)['race'] == 0 then
            filterload('MON')
        else
            filterload('DEFAULT')
        end
    else
        filterload('DEFAULT')
    end
    if not file.exists('data\\colors.xml') then
        colorsFile:write(default_colors)
        print('Default colors xml file created')
    end
    local colortab = config.load('data\\colors.xml',default_color_table)
    config.save(colortab)
    for i,v in pairs(colortab) do
        color_arr[i] = colconv(v,i)
    end
end

function filterload(job)
    if Current_job == job then return end
    if file.exists('data\\filters\\filters-'..job..'.xml') then
        default_filt = false
        filter = config.load('data\\filters\\filters-'..job..'.xml',default_filter_table,false)
        windower.add_to_chat(4,'Loaded '..job..' Battlemod filters')
    elseif not default_filt then
        default_filt = true
        filter = config.load('data\\filters\\filters.xml',default_filter_table,false)
        windower.add_to_chat(4,'Loaded default Battlemod filters')
    end
    Current_job = job
end

windower.register_event('incoming chunk',function (id,original,modified,is_injected,is_blocked)
    if debugging then windower.debug('incoming chunk '..id) end
    local pref = original:sub(1,4)
    local data = original:sub(5)
    
-------------- ACTION PACKET ---------------
    if id == 0x28 and original ~= last_28_packet then
        last_28_packet = original
        local act = {}
        act.do_not_need = get_bit_packed(data,0,8)
        act.actor_id = get_bit_packed(data,8,40)
        act.target_count = get_bit_packed(data,40,50)
        act.category = get_bit_packed(data,50,54)
        act.param = get_bit_packed(data,54,70)
        act.unknown = get_bit_packed(data,70,86)
        act.recast = get_bit_packed(data,86,118)
        act.targets = {}
        local offset = 118
        for i = 1,act.target_count do
            act.targets[i] = {}
            act.targets[i].id = get_bit_packed(data,offset,offset+32)
            act.targets[i].action_count = get_bit_packed(data,offset+32,offset+36)
            offset = offset + 36
            act.targets[i].actions = {}
            for n = 1,act.targets[i].action_count do
                act.targets[i].actions[n] = {}
                act.targets[i].actions[n].reaction = get_bit_packed(data,offset,offset+5)
                act.targets[i].actions[n].animation = get_bit_packed(data,offset+5,offset+16)
                act.targets[i].actions[n].effect = get_bit_packed(data,offset+16,offset+21)
                act.targets[i].actions[n].stagger = get_bit_packed(data,offset+21,offset+27)
                if debugging then --act.targets[i].actions[n].stagger > 2  then
                    -- Value 8 to 63 will knockback
                    act.targets[i].actions[n].stagger = act.targets[i].actions[n].stagger%8
                end
                act.targets[i].actions[n].param = get_bit_packed(data,offset+27,offset+44)
                act.targets[i].actions[n].message = get_bit_packed(data,offset+44,offset+54)
                act.targets[i].actions[n].unknown = get_bit_packed(data,offset+54,offset+85)
                act.targets[i].actions[n].has_add_effect = get_bit_packed(data,offset+85,offset+86)
                offset = offset + 86
                if act.targets[i].actions[n].has_add_effect == 1 then
                    act.targets[i].actions[n].has_add_effect = true
                    act.targets[i].actions[n].add_effect_animation = get_bit_packed(data,offset,offset+6)
                    act.targets[i].actions[n].add_effect_effect = get_bit_packed(data,offset+6,offset+10)
                    act.targets[i].actions[n].add_effect_param = get_bit_packed(data,offset+10,offset+27)
                    act.targets[i].actions[n].add_effect_message = get_bit_packed(data,offset+27,offset+37)
                    offset = offset + 37
                else
                    act.targets[i].actions[n].has_add_effect = false
                    act.targets[i].actions[n].add_effect_animation = 0
                    act.targets[i].actions[n].add_effect_effect = 0
                    act.targets[i].actions[n].add_effect_param = 0
                    act.targets[i].actions[n].add_effect_message = 0
                end
                act.targets[i].actions[n].has_spike_effect = get_bit_packed(data,offset,offset+1)
                offset = offset +1
                if act.targets[i].actions[n].has_spike_effect == 1 then
                    act.targets[i].actions[n].has_spike_effect = true
                    act.targets[i].actions[n].spike_effect_animation = get_bit_packed(data,offset,offset+6)
                    act.targets[i].actions[n].spike_effect_effect = get_bit_packed(data,offset+6,offset+10)
                    act.targets[i].actions[n].spike_effect_param = get_bit_packed(data,offset+10,offset+24)
                    act.targets[i].actions[n].spike_effect_message = get_bit_packed(data,offset+24,offset+34)
                    offset = offset + 34
                else
                    act.targets[i].actions[n].has_spike_effect = false
                    act.targets[i].actions[n].spike_effect_animation = 0
                    act.targets[i].actions[n].spike_effect_effect = 0
                    act.targets[i].actions[n].spike_effect_param = 0
                    act.targets[i].actions[n].spike_effect_message = 0
                end
            end
        end
        act = parse_action_packet(act)

        local react = assemble_bit_packed('',act.do_not_need,0,8)
        react = assemble_bit_packed(react,act.actor_id,8,40)
        react = assemble_bit_packed(react,act.target_count,40,50)
        react = assemble_bit_packed(react,act.category,50,54)
        react = assemble_bit_packed(react,act.param,54,70)
        react = assemble_bit_packed(react,act.unknown,70,86)
        react = assemble_bit_packed(react,act.recast,86,118)
        
        local offset = 118
        for i = 1,act.target_count do
            react = assemble_bit_packed(react,act.targets[i].id,offset,offset+32)
            react = assemble_bit_packed(react,act.targets[i].action_count,offset+32,offset+36)
            offset = offset + 36
            for n = 1,act.targets[i].action_count do
                react = assemble_bit_packed(react,act.targets[i].actions[n].reaction,offset,offset+5)
                react = assemble_bit_packed(react,act.targets[i].actions[n].animation,offset+5,offset+16)
                react = assemble_bit_packed(react,act.targets[i].actions[n].effect,offset+16,offset+21)
                react = assemble_bit_packed(react,act.targets[i].actions[n].stagger,offset+21,offset+27)
                react = assemble_bit_packed(react,act.targets[i].actions[n].param,offset+27,offset+44)
                react = assemble_bit_packed(react,act.targets[i].actions[n].message,offset+44,offset+54)
                react = assemble_bit_packed(react,act.targets[i].actions[n].unknown,offset+54,offset+85)
                
                react = assemble_bit_packed(react,act.targets[i].actions[n].has_add_effect,offset+85,offset+86)
                offset = offset + 86
                if act.targets[i].actions[n].has_add_effect then
                    react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_animation,offset,offset+6)
                    react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_effect,offset+6,offset+10)
                    react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_param,offset+10,offset+27)
                    react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_message,offset+27,offset+37)
                    offset = offset + 37
                end
                react = assemble_bit_packed(react,act.targets[i].actions[n].has_spike_effect,offset,offset+1)
                offset = offset + 1
                if act.targets[i].actions[n].has_spike_effect then
                    react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_animation,offset,offset+6)
                    react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_effect,offset+6,offset+10)
                    react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_param,offset+10,offset+24)
                    react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_message,offset+24,offset+34)
                    offset = offset + 34
                end
            end
        end
--        if react:sub(1) ~= data:sub(1,#react) then
--            print('REACT does not match up')
--        end
        while #react < #data do
            react = react..data:sub(#react+1,#react+1)
        end
--        local first_error = true
--        for i=1,#data do
--            if data:byte(i) ~= react:byte(i) then
--                if first_error then
--                    first_error = nil
--                end
--                windower.add_to_chat(8,'Mismatch at byte '..i..'.')
--            end
--        end

        return pref..react


----------- ACTION MESSAGE ------------        
    elseif id == 0x29 then
        local am = {}
        am.actor_id = get_bit_packed(data,0,32)
        am.target_id = get_bit_packed(data,32,64)
        am.param_1 = get_bit_packed(data,64,96)
        am.param_2 = get_bit_packed(data,96,106) -- First 6 bits
        am.param_3 = get_bit_packed(data,106,128) -- Rest
        am.actor_index = get_bit_packed(data,128,144)
        am.target_index = get_bit_packed(data,144,160)
        am.message_id = get_bit_packed(data,160,175) -- Cut off the most significant bit, hopefully
        
        local actor = player_info(am.actor_id)
        local target = player_info(am.target_id)
        
        -- Filter these messages
        if not check_filter(actor,target,0,am.message_id) then return true end
        
        if not actor or not target then -- If the actor or target table is nil, ignore the packet
        elseif T{206}:contains(am.message_id) and condensetargets then -- Wears off messages
            -- Condenses across multiple packets
            local status
            
            if enfeebling:contains(am.param_1) and r_status[param_1] then
                status = color_it(r_status[param_1][language],color_arr.enfeebcol)
            elseif color_arr.statuscol == rcol then
                status = color_it(r_status[am.param_1][language],string.char(0x1F,191))
            else
                status = color_it(r_status[am.param_1][language],color_arr.statuscol)
            end
            
            if not multi_actor[status] then multi_actor[status] = player_info(am.actor_id) end
            if not multi_msg[status] then multi_msg[status] = am.message_id end
            
            if not multi_targs[status] and not stat_ignore:contains(am.param_1) then
                multi_targs[status] = {}
                multi_targs[status][1] = target
                windower.send_command('@wait 0.5;lua i battlemod multi_packet '..status)
            elseif not (stat_ignore:contains(am.param_1)) then
                multi_targs[status][#multi_targs[status]+1] = color_it(target.name,color_arr[target.owner or target.type])
            else
            -- This handles the stat_ignore values, which are things like Utsusemi,
            -- Sneak, Invis, etc. that you don't want to see on a delay
                multi_targs[status] = {}
                multi_targs[status][1] = target
                windower.send_command('@lua i battlemod multi_packet '..status)
            end
            am.message_id = false
        elseif passed_messages:contains(am.message_id) then
            local item,status,spell,skill,number,number2
            
            local fields = fieldsearch(res.action_messages[am.message_id][language])
            
            if fields.status then
                status = (enLog[am.param_1] or nf(r_status[am.param_1],language))
                if enfeebling:contains(am.param_1) then
                    status = color_it(status,color_arr.enfeebcol)
                else
                    status = color_it(status,color_arr.statuscol)
                end
            end
            
            if fields.spell then
                spell = nf(r_spells[am.param_1],language)
            end
            
            if fields.item then
                item = nf(r_items[am.param_1],'enl')
            end
            
            if fields.number then
                number = am.param_1
            end
            
            if fields.number2 then
                number2 = am.param_2
            end
            
            if fields.skill and res.skills[am.param_1] then
                skill = res.skills[am.param_1][language]:lower()
            end
            
            if am.message_id > 169 and am.message_id <179 then
                if am.param_1 > 2147483647 then
                    skill = 'like level -1 ('..ratings_arr[am.param_2-63]..')'
                else
                    skill = 'like level '..am.param_1..' ('..ratings_arr[am.param_2-63]..')'
                end
            end
            
            local outstr = (res.action_messages[am.message_id][language]
                :gsub('$\123actor\125',color_it(actor.name or '',color_arr[actor.owner or actor.type]))
                :gsub('$\123status\125',status or '')
                :gsub('$\123item\125',color_it(item or '',color_arr.itemcol))
                :gsub('$\123target\125',color_it(target.name or '',color_arr[target.owner or target.type]))
                :gsub('$\123spell\125',color_it(spell or '',color_arr.spellcol))
                :gsub('$\123skill\125',color_it(skill or '',color_arr.abilcol))
                :gsub('$\123number\125',number or '')
                :gsub('$\123number2\125',number2 or '')
                :gsub('$\123skill\125',skill or '')
                :gsub('$\123lb\125','\7'))
            windower.add_to_chat(res.action_messages[am.message_id]['color'],outstr)
            am.message_id = false
        elseif debugging then 
        -- 38 is the Skill Up message, which (interestingly) uses all the number params.
        -- 202 is the Time Remaining message, which (interestingly) uses all the number params.
            print('debug_EAM#'..am.message_id..': '..res.action_messages[am.message_id][language]..' '..am.param_1..'   '..am.param_2..'   '..am.param_3)
        end
        if not am.message_id then
            return true
        end

------------ SYNTHESIS ANIMATION --------------
    elseif id == 0x030 then
        if windower.ffxi.get_player().id == (data:byte(3,3)*256*256 + data:byte(2,2)*256 + data:byte(1,1)) then
            local result = data:byte(9,9)
            if result == 0 then
                windower.add_to_chat(8,' ------------- NQ Synthesis -------------')
            elseif result == 1 then
                windower.add_to_chat(8,' ---------------- Break -----------------')
            elseif result == 2 then
                windower.add_to_chat(8,' ------------- HQ Synthesis -------------')
            else
                windower.add_to_chat(8,'Craftmod: Unhandled result '..tostring(result))
            end
        end
        
------------- JOB INFO ----------------
    elseif id == 0x06F then
        local result = data:byte(2,2)
        if result == 1 then
            windower.add_to_chat(8,' -------------- HQ Tier 1! --------------')
        elseif result == 2 then
            windower.add_to_chat(8,' -------------- HQ Tier 2! --------------')
        elseif result == 3 then
            windower.add_to_chat(8,' -------------- HQ Tier 3! --------------')
        end
        
    elseif id == 0x01B then
        filterload(res.jobs[data:byte(5)].short)
    end
end)

function multi_packet(...)
    local ind = table.concat({...},' ')
--    windower.add_to_chat(8,tostring(multi_actor[ind].name)..' '..tostring(multi_targs[ind][1].name)..' '..tostring(multi_msg[ind]))
    local targets = assemble_targets(multi_actor[ind],multi_targs[ind],0,multi_msg[ind])
    local outstr = res.action_messages[multi_msg[ind]][language]
        :gsub('$\123target\125',targets)
        :gsub('$\123status\125',ind)
    windower.add_to_chat(res.action_messages[multi_msg[ind]].color,outstr)
    multi_targs[ind] = nil
    multi_msg[ind] = nil
    multi_actor[ind] = nil
end

function get_bit_packed(dat_string,start,stop)
    local newval = 0
    
    local c_count = math.ceil(stop/8)
    while c_count >= math.ceil((start+1)/8) do
        -- Grabs the most significant byte first and works down towards the least significant.
        local cur_val = dat_string:byte(c_count)
        local scal = 256
        
        if c_count == math.ceil(stop/8) then -- Take the least significant bits of the most significant byte
        -- Moduluses by 2^number of bits into the current byte. So 8 bits in would %256, 1 bit in would %2, etc.
        -- Cuts off the top.
            cur_val = cur_val%(2^((stop-1)%8+1)) -- -1 and +1 set the modulus result range from 1 to 8 instead of 0 to 7.
        end
        
        if c_count == math.ceil((start+1)/8) then -- Take the most significant bits of the least significant byte
        -- Divides by the significance of the final bit in the current byte. So 8 bits in would /128, 1 bit in would /1, etc.
        -- Cuts off the bottom.
            cur_val = math.floor(cur_val/(2^(start%8)))
            scal = 2^(8-start%8)
        end
        
        newval = newval*scal + cur_val -- Need to multiply by 2^number of bits in the next byte
        c_count = c_count - 1
    end
    return newval
end

function assemble_bit_packed(init,val,initial_length,final_length,debug_val)
    if type(val) == 'boolean' then
        if val then val = 1 else val = 0 end
    end
    local bits = initial_length%8
    local byte_length = math.ceil(final_length/8)
    
    local out_val = 0
    if bits > 0 then
        out_val = init:byte(#init) -- Initialize out_val to the remainder in the active byte.
        init = init:sub(1,#init-1) -- Take off the active byte
    end
    out_val = out_val + val*2^bits -- left-shift val by the appropriate amount and add it to the remainder (now the lsb-s in val)
    if debug_val then print(out_val..' '..#init) end
    
    while out_val > 0 do
        init = init..string.char(out_val%256)
        out_val = math.floor(out_val/256)
    end
    while #init < byte_length do
        init = init..string.char(0)
    end
    return init
end
