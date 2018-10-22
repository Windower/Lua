--[[
Copyright © 2015, Mike McKee
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.
    * Neither the name of enemybar nor the
        names of its contributors may be used to endorse or promote products
        derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mike McKee BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

_addon.name = 'enemybar'
_addon.author = 'mmckee,akaden'
_addon.version = '1.1.0'
_addon.language = 'English'
_addon.commands = {'enemybar','eb'}

config = require('config')
images = require('images')
texts = require('texts')
table = require('table')
packets = require('packets')

require('bars')
require('actionTracking')

player_id = nil
party_members = {}
debug_string = ''

local state = {}
state.setup = false
state.focustarget = nil

function initialize_bars()
    if target_bar then 
        bars.destroy(target_bar) 
        target_bar = nil
    end
    if subtarget_bar then 
        bars.destroy(subtarget_bar)
        subtarget_bar = nil 
    end
    if focustarget_bar then 
        bars.destroy(focustarget_bar) 
        focustarget_bar = nil
    end
    if aggro_bars then
        for i,b in ipairs(aggro_bars) do
            bars.destroy(b)
        end
    end

    target_bar = bars.new(settings.target_bar)
    subtarget_bar = bars.new(settings.subtarget_bar)
    focustarget_bar = bars.new(settings.focustarget_bar)
    local y = settings.aggro_bar.pos.y
    aggro_bars = {}
    for i = 1, settings.aggro_bar.count do
        aggro_bars[i] = bars.new(settings.aggro_bar)
        bars.move(aggro_bars[i], settings.aggro_bar.pos.x, y)
        if settings.aggro_bar.stack_dir == 'down' then
            y = y + settings.aggro_bar.stack_padding
        elseif settings.aggro_bar.stack_dir == 'up' then
            y = y - settings.aggro_bar.stack_padding
        end
    end

    bar_sets = {{target_bar}, {subtarget_bar}, {focustarget_bar}, aggro_bars}
end

function update_bar(bar, target, show)
    if state.setup then
        if show then
            bars.show(bar)
            if bar == target_bar then bars.update_target(bar, "Target Name", 79, 12.1, 1)
            elseif bar == subtarget_bar then bars.update_target(bar, "Subtarget Name", 53, 11.4, 2)
            elseif bar == focustarget_bar then bars.update_target(bar, "Focus Target Name", 36, 8.6, 1)
            else bars.update_target(bar, "Aggro Target Name", 47, 6.6, 1) end
            bars.update_action(bar, "Action Name", '')
            bars.update_enmity(bar, "Mob Target", {red=102, green=255, blue=255})
            bars.update_status(bar, {})
            bars.set_name_color(bar, {red=255, green=180, blue=180})
        else
            bars.hide(bar)
        end
    else
        if target ~= nil and show then     
            bars.show(bar)

            local dist = get_distance(windower.ffxi.get_mob_by_target('me'), target)

            local t = windower.ffxi.get_mob_by_target('t')
            local st = windower.ffxi.get_mob_by_target('st')
            local target_type = nil
            if t and t.id == target.id then 
                target_type = 1
            elseif st and st.id == target.id then
                target_type = 2
            end
            bars.update_target(bar, target.name, target.hpp, dist, target_type)

            local action = tracked_actions[target.id]
            if action and not action.complete then
                bars.update_action(bar, action.ability.name, '')
            else
                bars.update_action(bar, nil, '')
            end

            local enmity_target = tracked_enmity[target.id]
            if enmity_target and enmity_target.pc then
                local pc = windower.ffxi.get_mob_by_id(enmity_target.pc)
                if pc then
                    bars.update_enmity(bar, pc.name, get_tint_by_target(pc))
                else
                    bars.update_enmity(bar, nil)
                end
            elseif not target.is_npc then
                local target_target = windower.ffxi.get_mob_by_index(target.target_index)
                if target_target then
                    bars.update_enmity(bar, target_target.name, get_tint_by_target(target_target))
                else
                    bars.update_enmity(bar, nil)
                end
            else
                bars.update_enmity(bar, nil)
            end

            bars.update_status(bar, tracked_debuff[target.id])

            bars.set_name_color(bar, get_tint_by_target(target))
        else
            bars.hide(bar)
        end
    end
end

function update_aggro_bars(show)
    if state.setup then
        for i=1, (aggro_bars and #aggro_bars or 0) do
            update_bar(aggro_bars[i], nil, show)
        end
    else
        local ordered_aggro = get_ordered_aggro()

        local e_bar_i = 1
        if show then
            for i,v in ipairs(ordered_aggro) do
                if e_bar_i > settings.aggro_bar.count then
                    break
                end
                local bar = aggro_bars[e_bar_i]
                target = windower.ffxi.get_mob_by_id(v.mob)
                update_bar(bar, target, show)
                e_bar_i = e_bar_i + 1
            end
        end
        -- hide bars not updated (all of them, if show is off)
        for i=e_bar_i, (aggro_bars and #aggro_bars or 0) do
            local bar = aggro_bars[i]
            if bar then
                bars.hide(bar)
            end
        end
    end
end

-- sort by hpp (lowest -> highest) then group by debuff status.
function get_ordered_aggro()
    local debuffed = {}
    local ordered = {}
    for k,n in pairs(tracked_enmity) do
        local mob = windower.ffxi.get_mob_by_id(k)
        if mob then
            n.hpp = mob.hpp
            local is_debuffed = false
            if tracked_debuff[k] then
                for id,debuff in pairs(tracked_debuff[k]) do
                    if tracked_debuff_ids:contains(id) then
                        table.insert(debuffed,n)
                        is_debuffed = true
                        break
                    end
                end
            end
            if not is_debuffed then
                table.insert(ordered,n) 
            end
        end
    end
    local hpp_sort = function(left,right)
            return left.hpp < right.hpp
        end
    table.sort(ordered, hpp_sort)
    table.sort(debuffed, hpp_sort)
    for i,n in ipairs(debuffed) do
        table.insert(ordered, n)
    end
    return ordered
end

function check_claim(claim_id)
    if player_id == claim_id then
            return true
    else
        if is_party_member_or_pet(claim_id) then
            return true
        end
    end
    return false
end

function get_tint_by_target(target)
    if target.hpp == 0 then
        return {red=155, green=155, blue=155}
    elseif check_claim(target.claim_id) then
        return {red=255, green=180, blue=180}
    elseif is_party_member_or_pet(target.id) and target.id ~= player_id then
        return {red=102, green=255, blue=255}
    elseif not target.is_npc then
        return {red=255, green=255, blue=255}
    elseif target.claim_id == 0 then
        return {red=230, green=230, blue=138} 
    elseif target.claim_id ~= 0 then
        return {red=153, green=102, blue=255}
    end    
end

function get_distance(player, target)
    local dx = player.x-target.x
    local dy = player.y-target.y
    return math.sqrt(dx*dx + dy*dy)
end

function looking_at(a, b)
    if not a or not b then return false end
    local h = a.facing % math.pi
    local h2 = (math.atan2(a.x-b.x,a.y-b.y) + math.pi/2) % math.pi
    return math.abs(h-h2) < 0.15
end

function is_npc(mob_id)
    local is_pc = mob_id < 0x01000000
    local is_pet = mob_id > 0x01000000 and mob_id % 0x1000 > 0x700

    -- filter out pcs and known pet IDs
    if is_pc or is_pet then return false end

    -- check if the mob is charmed
    local mob = windower.ffxi.get_mob_by_id(mob_id)
    if not mob then return nil end
    return mob.is_npc and not mob.charmed
end

function is_party_member_or_pet(mob_id)
    if mob_id == player_id then return true end

    if is_npc(mob_id) then return false end

    return party_members[mob_id]
end

function handle_party_packets(id, data)
    if id == 0x0DD then
        -- cache party 
        cache_party_members()
    elseif id == 0x067 then
        local p =  packets.parse('incoming', data)
        if p['Owner Index'] > 0 then
            local owner = windower.ffxi.get_mob_by_index(p['Owner Index'])
            if owner and is_party_member_or_pet(owner.id) then
                party_members[p['Pet ID']] = {is_pet = true, owner = owner.id}
            end
        end
    end
end

function cache_party_members()
    party_members = {}
    local party = windower.ffxi.get_party()
    if not party then return end
    for i=0, (party.party1_count or 0) - 1 do
        cache_party_member(party['p'..i])            
    end
    for i=0, (party.party2_count or 0) - 1 do
        cache_party_member(party['a1'..i])            
    end
    for i=0, (party.party3_count or 0) - 1 do
        cache_party_member(party['a2'..i])            
    end
end

function cache_party_member(p)
    if p and p.mob then
        party_members[p.mob.id] = {is_pc = true,}
        if p.mob.pet_index then
            local pet = windower.ffxi.get_mob_by_index(p.mob.pet_index)
            if pet then
                party_members[pet.id] = {is_pet = true, owner = p.id}
            end
        end
    end
end

function handle_command(c, ...)
    if not c then return end
    local args = L{...}
    c = c:lower()
    if S{'set','s'}:contains(c) and args[1] and args[2] then
        local setting = args[1]:lower()
        local bar = normalize_bar_name(args[2])
        if not bar then
            windower.add_to_chat(123, 'EnemyBar: Unknown bar name: "'..args[2]:lower()..'"')
            return
        end
        if setting == 'pos' then
            if args[3] and args[4] then
                if not tonumber(args[3]) or not tonumber(args[4]) then
                    windower.add_to_chat(123, 'EnemyBar: value is not numeric for "'..setting..'"')
                else
                    set_setting(bar, setting, {x=tonumber(args[3]),y=tonumber(args[4])})
                end
            else
                windower.add_to_chat(123, 'EnemyBar: not enough arguments for "'..setting..'"')
            end
        elseif setting == 'color' then
            if args[3] and args[4] and args[5] then
                if not tonumber(args[3]) or not tonumber(args[4]) or not tonumber(args[5]) then
                    windower.add_to_chat(123, 'EnemyBar: value is not numeric for "'..setting..'"')
                else
                    set_setting(bar, setting, {red=tonumber(args[3]),green=tonumber(args[4]),blue=tonumber(args[5])})
                end
            else
                windower.add_to_chat(123, 'EnemyBar: not enough arguments for "'..setting..'"')
            end
        elseif S{'font','stack_dir'}:contains(setting) then
            if args[3] then
                set_setting(bar, setting, args[3])
            else
                windower.add_to_chat(123, 'EnemyBar: not enough arguments for "'..setting..'"')
            end
        elseif S{'font_size','width','count','stack_padding'}:contains(setting) then
            if args[3] then
                if not tonumber(args[3]) then
                    windower.add_to_chat(123, 'EnemyBar: value is not numeric for "'..setting..'"')
                else
                    set_setting(bar, setting, tonumber(args[3]))
                end
            else
                windower.add_to_chat(123, 'EnemyBar: not enough arguments for "'..setting..'"')
            end
        elseif S{'show','show_target_icon','show_target','show_debuff','show_action','show_dist'}:contains(setting) then
            if args[3] then
                local b = normalize_boolean(args[3])
                if b == nil then
                    windower.add_to_chat(123, 'EnemyBar: unknown value for "'..setting..'"')
                else
                    set_setting(bar, setting, b)
                end
            else
                windower.add_to_chat(123, 'EnemyBar: not enough arguments for "'..setting..'"')
            end
        else
            windower.add_to_chat(123, 'EnemyBar: Unknown setting: "'..setting..'"')
        end
    elseif S{'focustarget','ft','f'}:contains(c) then
        if args[1] then
            if args[1]:lower() == "clear" then
                state.focustarget = nil
                windower.add_to_chat(207, 'EnemyBar: focus target is now off')
            elseif tonumber(args[1]) then
                local t = windower.ffxi.get_mob_by_id(tonumber(args[1]))
                if t then
                    state.focustarget = t.id
                    windower.add_to_chat(207, 'EnemyBar: focus target is now "'..t.name..'"')
                else
                    windower.add_to_chat(123, 'EnemyBar: could not find a target with that ID')
                end    
            else
                local t = get_mob_by_name(args[1])
                if t then
                    state.focustarget = t.id
                    windower.add_to_chat(207, 'EnemyBar: focus target is now "'..t.name..'"')
                else
                    windower.add_to_chat(123, 'EnemyBar: could not find a target by that name')
                end                
            end
        else 
            local t = windower.ffxi.get_mob_by_target('t')
            if t then
                state.focustarget = t.id
                windower.add_to_chat(207, 'EnemyBar: focus target is now "'..t.name..'"')
            else
                windower.add_to_chat(123, 'EnemyBar: no target selected to focustarget')
            end
        end
    elseif S{'demo','setup','debug','test'}:contains(c) then
        if args[3] then
            state.setup = normalize_boolean(args[3])
        else
            state.setup = not state.setup
        end
        windower.add_to_chat(207, 'EnemyBar: setup mode is now "'..(state.setup and 'on' or 'off')..'"')
    elseif S{'help','h','man','manual'}:contains(c) then
        helptext = [[Enemy Bar - Command List:')
1. set/s [setting] [target/t/subtarget/st/aggro/a/all] [value] - set a setting to its value
    setting: pos(x y)/font/font_size/color(r g b)/width/count/show/show_target_icon/show_debuff/show_dist/show_action/show_target
2. focustarget/ft/f (player_name or id or blank or clear) - create a bar for a particular party member, mob by ID, or by current target (blank), or clear the current focus target
3. setup/demo/debug/test - toggles setup mode displaying test versions of all options and enabling drag for each frame
4. help/h/manual/man --Shows this menu.]]
        for _, line in ipairs(helptext:split('\n')) do
                windower.add_to_chat(207, line)
        end
    end
end

function get_mob_by_name(n)
    n = n:lower()
    local worse_match = nil
    local worser_match = nil
    for _,mob in pairs(windower.ffxi.get_mob_array()) do
        local mobname = mob.name:lower()
        if n == mobname then
            return mob
        elseif not worse_match and mobname:sub(1, #n) == n then
            worse_match = mob
        elseif not worser_match and mobname:match(n) then
            worser_match = mob
        end
    end
    return worse_match or worser_match
end

function normalize_bar_name(n)
    n = n:lower()
    if n == 't' then
        n = 'target'
    elseif n == 'st' then
        n = 'subtarget'
    elseif n == 'a' then
        n = 'aggro'
    elseif S{'f','ft'}:contains(n) then
        n = 'focustarget'
    elseif not S{'target','subtarget','aggro','focustarget','all'}:contains(n) then
        n = nil
    end

    return n
end

function normalize_boolean(b)
    b = b:lower()
    if S{'true','t','yes','y','on'}:contains(b) then
        return true
    elseif S{'false','f','no','n','off'}:contains(b) then
        return false
    else return nil end
end

function set_setting(bar, setting, v)
    if bar == 'all' then
        settings['target_bar'][setting] = v
        settings['subtarget_bar'][setting] = v
        settings['aggro_bar'][setting] = v
        settings['focustarget_bar'][setting] = v
    else
        settings[bar..'_bar'][setting] = v
    end
    windower.add_to_chat(207, 'EnemyBar: "'..setting..'" updated for "'..bar..'" bar')
    settings:save()
    initialize_bars()
end

windower.register_event('prerender', function()
    if player_id then
        update_bar(target_bar, windower.ffxi.get_mob_by_target('t'), settings.target_bar.show)
        update_bar(subtarget_bar, windower.ffxi.get_mob_by_target('st'), settings.subtarget_bar.show)
        update_bar(focustarget_bar, state.focustarget and windower.ffxi.get_mob_by_id(state.focustarget) or nil, settings.focustarget_bar.show)
        update_aggro_bars(settings.aggro_bar.show)
    else
        update_bar(target_bar, nil, false)
        update_bar(subtarget_bar, nil, false)
        update_bar(focustarget_bar, nil, false)
        update_aggro_bars(false)
    end
end)
windower.register_event('prerender', clean_tracked_actions)
windower.register_event('incoming chunk', function(id, data)
    handle_action_packet(id, data)
    handle_party_packets(id, data)
end)
windower.register_event('zone change', reset_tracked_actions)
windower.register_event('addon command', handle_command)
windower.register_event('logout', function(...)
    player_id = nil    
    state = {}      
end)
windower.register_event('login', function(...)
    if windower.ffxi.get_info().logged_in then
        player_id = windower.ffxi.get_player().id
    end
    state = {}
end)

-- Handle drag and drop
windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked or not bar_sets then
        return
    end

    -- Mouse drag
    if type == 0 then
        if dragged then
            local d_x = 0
            local d_y = 0
            if drag_snap_key_down then
                -- snap
                d_x = math.floor(((x - dragged.x) + dragged.bars[1].x)/10)*10 - dragged.bars[1].x
                d_y = math.floor(((y - dragged.y) + dragged.bars[1].y)/10)*10 - dragged.bars[1].y
            else
                -- no snap
                d_x = x - dragged.x
                d_y = y - dragged.y
            end

            for i, b in ipairs(dragged.bars) do
                    bars.move(b, b.x + d_x, b.y + d_y)
            end
            dragged.x = dragged.x + d_x
            dragged.y = dragged.y + d_y
            return true
        end

    -- Mouse left click
    elseif type == 1 then
        if not state.setup then return false end
        for _, s in ipairs(bar_sets) do
            for _, b in ipairs(s) do
                if bars.hover(b, x, y) then
                    dragged = {bars = s, x = x , y = y}
                    return true
                end
            end
        end

    -- Mouse left release
    elseif type == 2 then
        if dragged then
            settings.target_bar.pos = {x=target_bar.x,y=target_bar.y}
            settings.subtarget_bar.pos = {x=subtarget_bar.x,y=subtarget_bar.y}
            settings.focustarget_bar.pos = {x=focustarget_bar.x,y=focustarget_bar.y}
            settings.aggro_bar.pos = {x=aggro_bars[1].x,y=aggro_bars[1].y}
            settings:save()
            dragged = nil
            return true
        end
    end

    return false
end)
windower.register_event('keyboard', function(dik, down) -- lol diks
    if dik == 29 then -- if ctrl
        drag_snap_key_down = down
    end
end)

if windower.ffxi.get_info().logged_in then
    player_id = windower.ffxi.get_player().id
    party_members = {}
end

defaults = {}
defaults.target_bar = {
    pos={x=650,y=750}, width=600,
    color={alpha=255,red=255,green=0,blue=0},
    font='Arial', font_size=14,
    show=true, show_target=false, show_target_icon=false,
    show_action=false, show_dist=false, show_debuff=false}
defaults.subtarget_bar = {
    pos={x=680,y=700}, width=300,
    color={alpha=255,red=12,green=50,blue=101},
    font='Arial', font_size=12,
    show=true, show_target=false, show_target_icon=false,
    show_action=false, show_dist=false, show_debuff=false}
defaults.focustarget_bar = {
    pos={x=680,y=670}, width=250,
    color={alpha=255,red=93,green=0,blue=255},
    font='Arial', font_size=12,
    show=true, show_target=false, show_target_icon=false,
    show_action=false, show_dist=false, show_debuff=false}
defaults.aggro_bar = {
    pos={x=350,y=550}, width=180,
    color={alpha=255,red=0,green=150,blue=50},
    font='Arial', font_size=9,
    show=false, show_target=false, show_target_icon=false,
    show_action=false, show_dist=false, show_debuff=false,
    count=6, stack_dir='down', stack_padding = 27}
settings_old = config.load({})
if settings_old.pos then
    -- settings.pos was the old position setting. if it's set that means we're upgrading from 1.0
    defaults.target_bar.pos = settings_old.pos
    defaults.target_bar.font = settings_old.font
    defaults.subtarget_bar.font = settings_old.font
    defaults.target_bar.font_size = settings_old.font_size
    defaults.subtarget_bar.font_size = settings_old.font_size
end
settings = config.load(defaults)
config.register(settings, initialize_bars)