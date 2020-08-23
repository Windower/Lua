require 'tables'
require 'sets'
file = require 'files'
config = require 'config'
require 'strings'
res = require 'resources'
require 'actions'
require 'pack'
bit = require 'bit'

require 'generic_helpers'
require 'parse_action_packet'
require 'statics'

_addon.version = '3.27'
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

windower.register_event('addon command', function(command, ...)
    if debugging then windower.debug('addon command') end
    local args = {...}
    command = command and command:lower()
    if command then
        if command:lower() == 'commamode' then
            commamode = not commamode
            windower.add_to_chat(121,'Battlemod: Comma Mode flipped! - '..tostring(commamode))
        elseif command:lower() == 'oxford' then
            oxford = not oxford
            windower.add_to_chat(121,'Battlemod: Oxford Mode flipped! - '..tostring(oxford))
        elseif command:lower() == 'targetnumber' then
            targetnumber = not targetnumber
            windower.add_to_chat(121,'Battlemod: Target Number flipped! - '..tostring(targetnumber))
        elseif command:lower() == 'swingnumber' then
            swingnumber = not swingnumber
            windower.add_to_chat(121,'Battlemod: Round Number flipped! - '..tostring(swingnumber))
        elseif command:lower() == 'sumdamage' then
            sumdamage = not sumdamage
            windower.add_to_chat(121,'Battlemod: Sum Damage flipped! - '..tostring(sumdamage))
        elseif command:lower() == 'condensecrits' then
            condensecrits = not condensecrits
            windower.add_to_chat(121,'Battlemod: Condense Crits flipped! - '..tostring(condensecrits))
        elseif command:lower() == 'cancelmulti' then
            cancelmulti = not cancelmulti
            windower.add_to_chat(121,'Battlemod: Multi-canceling flipped! - '..tostring(cancelmulti))
        elseif command:lower() == 'reload' then
            current_job = 'NONE'
            options_load()
        elseif command:lower() == 'unload' then
            windower.send_command('@lua u battlemod')
        elseif command:lower() == 'simplify' then
            simplify = not simplify
            windower.add_to_chat(121,'Battlemod: Text simplification flipped! - '..tostring(simplify))
        elseif command:lower() == 'condensedamage' then
            condensedamage = not condensedamage
            windower.add_to_chat(121,'Battlemod: Condensed Damage text flipped! - '..tostring(condensedamage))
        elseif command:lower() == 'condensetargets' then
            condensetargets = not condensetargets
            windower.add_to_chat(121,'Battlemod: Condensed Targets flipped! - '..tostring(condensetargets))
        elseif command:lower() == 'colortest' then
            local counter = 0
            local line = ''
            for n = 1, 262 do
                if not color_redundant:contains(n) and not black_colors:contains(n) then
                    if n <= 255 then
                        loc_col = string.char(0x1F, n)
                    else
                        loc_col = string.char(0x1E, n - 254)
                    end
                    line = line..loc_col..string.format('%03d ', n)
                    counter = counter + 1
                end
                if counter == 16 or n == 262 then
                    windower.add_to_chat(6, line)
                    counter = 0
                    line = ''
                end
            end
            windower.add_to_chat(122,'Colors Tested!')
        elseif command:lower() == 'help' then
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

windower.register_event('incoming text',function (original, modified, color, color_m, blocked)
    if debugging then windower.debug('incoming text') end
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
    if block_modes:contains(color) then
        local endline = string.char(0x7F, 0x31)
        local item = string.char(0x1E)
        if not bm_message(original) then
            if original:endswith(endline) then --allow add_to_chat messages with the modes we blocking
                blocked = true
                return blocked
            end
        elseif original:endswith(endline) and string.find(original, item) then --block items action messages
            blocked = true
            return blocked
        end
    end
    
    return modified,color
end)

function bm_message(original)
    local check = string.char(0x1E)
    local check2 = string.char(0x1F)
    if string.find(original, check) or string.find(original, check2) then
        return true
    end
end

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
    if current_job == job then return end
    if file.exists('data\\filters\\filters-'..job..'.xml') then
        default_filt = false
        filter = config.load('data\\filters\\filters-'..job..'.xml',default_filter_table,false)
        config.save(filter)
        windower.add_to_chat(4,'Loaded '..job..' Battlemod filters')
    elseif not default_filt then
        default_filt = true
        filter = config.load('data\\filters\\filters.xml',default_filter_table,false)
        config.save(filter)
        windower.add_to_chat(4,'Loaded default Battlemod filters')
    end
    current_job = job
end

ActionPacket.open_listener(parse_action_packet)

windower.register_event('incoming chunk',function (id,original,modified,is_injected,is_blocked)
    if debugging then windower.debug('incoming chunk '..id) end

------- ACTION MESSAGE -------    
    if id == 0x29 then
        local am = {}
        am.actor_id = original:unpack("I",0x05)
        am.target_id = original:unpack("I",0x09)
        am.param_1 = original:unpack("I",0x0D)
        am.param_2 = original:unpack("H",0x11)%2^9 -- First 7 bits
        am.param_3 = math.floor(original:unpack("I",0x11)/2^5) -- Rest
        am.actor_index = original:unpack("H",0x15)
        am.target_index = original:unpack("H",0x17)
        am.message_id = original:unpack("H",0x19)%2^15 -- Cut off the most significant bit
        
        local actor = player_info(am.actor_id)
        local target = player_info(am.target_id)
        
        -- Filter these messages
        if not check_filter(actor,target,0,am.message_id) then return true end
        
        if not actor or not target then -- If the actor or target table is nil, ignore the packet
        elseif am.message_id == 800 then -- Spirit bond message
            local status = color_it(res.buffs[am.param_1][language],color_arr.statuscol)
            local targ = color_it(target.name or '',color_arr[target.owner or target.type])
            local number = am.param_2
            local color = color_filt(res.action_messages[am.message_id].color, am.target_id==Self.id)
            if simplify then
                local msg = line_noactor
                    :gsub('${abil}',status or '')
                    :gsub('${target}',targ)
                    :gsub('${numb}',number or '')
                windower.add_to_chat(color, msg)
            else
                local msg = res.action_messages[am.message_id][language]
                    :gsub('${status}',status or '')
                    :gsub('${target}',targ)
                    :gsub('${number}',number or '')
                windower.add_to_chat(color, msg)
            end
        elseif am.message_id == 206 and condensetargets then -- Wears off messages
            -- Condenses across multiple packets
            local status
            
            if enfeebling:contains(am.param_1) and res.buffs[param_1] then
                status = color_it(res.buffs[param_1][language],color_arr.enfeebcol)
            elseif color_arr.statuscol == rcol then
                status = color_it(res.buffs[am.param_1][language],string.char(0x1F,191))
            else
                status = color_it(res.buffs[am.param_1][language],color_arr.statuscol)
            end
            
            if not multi_actor[status] then multi_actor[status] = player_info(am.actor_id) end
            if not multi_msg[status] then multi_msg[status] = am.message_id end
            
            if not multi_targs[status] and not stat_ignore:contains(am.param_1) then
                multi_targs[status] = {}
                multi_targs[status][1] = target
                windower.send_command('@wait 0.5;lua i battlemod multi_packet '..status)
            elseif not (stat_ignore:contains(am.param_1)) then
                multi_targs[status][#multi_targs[status]+1] = target
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
                if log_form_debuffs:contains(am.param_1) then
                    status = res.buffs[am.param_1].english_log
                else
                    status = nf(res.buffs[am.param_1],language)
                end
                if enfeebling:contains(am.param_1) then
                    status = color_it(status,color_arr.enfeebcol)
                else
                    status = color_it(status,color_arr.statuscol)
                end
            end
            
            if fields.spell then
                if not res.spells[am.param_1] then
                    return false
                end
                spell = nf(res.spells[am.param_1],language)
            end
            
            if fields.item then
                if not res.items[am.param_1] then
                    return false
                end
                item = nf(res.items[am.param_1],'english_log')
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
                    skill = 'to be level -1 ('..ratings_arr[am.param_2-63]..')'
                else
                    skill = 'to be level '..am.param_1..' ('..ratings_arr[am.param_2-63]..')'
                end
            end
            local outstr = (res.action_messages[am.message_id][language]
                :gsub('$\123actor\125',color_it((actor.name or '') .. (actor.owner_name or ""),color_arr[actor.owner or actor.type]))
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
        elseif debugging and res.action_messages[am.message_id] then 
        -- 38 is the Skill Up message, which (interestingly) uses all the number params.
        -- 202 is the Time Remaining message, which (interestingly) uses all the number params.
            print('debug_EAM#'..am.message_id..': '..res.action_messages[am.message_id][language]..' '..am.param_1..'   '..am.param_2..'   '..am.param_3)
        elseif debugging then
            print('debug_EAM#'..am.message_id..': '..'Unknown'..' '..am.param_1..'   '..am.param_2..'   '..am.param_3)
        end
        if not am.message_id then
            return true
        end

------------ SYNTHESIS ANIMATION --------------
    elseif id == 0x030 then
        if windower.ffxi.get_player().id == original:unpack("I",5) or windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').id == original:unpack("I",5) then
            local crafter_name = (windower.ffxi.get_player().id == original:unpack("I",5) and windower.ffxi.get_player().name) or windower.ffxi.get_mob_by_target('t').name
            local result = original:byte(13)
            if result == 0 then
                windower.add_to_chat(8,' ------------- NQ Synthesis ('..crafter_name..') -------------')
            elseif result == 1 then
                windower.add_to_chat(8,' ---------------- Break ('..crafter_name..') -----------------')
            elseif result == 2 then
                windower.add_to_chat(8,' ------------- HQ Synthesis ('..crafter_name..') -------------')
            else
                windower.add_to_chat(8,'Craftmod: Unhandled result '..tostring(result))
            end
        end
    elseif id == 0x06F then
        if original:byte(5) == 0 or original:byte(5) == 12 then
            local result = original:byte(6)
            if result == 1 then
                windower.add_to_chat(8,' -------------- HQ Tier 1! --------------')
            elseif result == 2 then
                windower.add_to_chat(8,' -------------- HQ Tier 2! --------------')
            elseif result == 3 then
                windower.add_to_chat(8,' -------------- HQ Tier 3! --------------')
            end
        end
        
    ------------- JOB INFO ----------------
    elseif id == 0x01B then
        filterload(res.jobs[original:byte(9)][language..'_short'])
    end
end)

function multi_packet(...)
    local ind = table.concat({...},' ')
    local targets = assemble_targets(multi_actor[ind],multi_targs[ind],0,multi_msg[ind])
    local outstr = res.action_messages[multi_msg[ind]][language]
        :gsub('$\123target\125',targets)
        :gsub('$\123status\125',ind)
    windower.add_to_chat(res.action_messages[multi_msg[ind]].color,outstr)
    multi_targs[ind] = nil
    multi_msg[ind] = nil
    multi_actor[ind] = nil
end
