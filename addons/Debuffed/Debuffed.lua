--[[
Copyright (c) 2018, Auk
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'Debuffed'
_addon.author = 'Auk'
_addon.version = '1.0.0.1'
_addon.commands = {'dbf','debuffed'}

config = require('config')
debuffs = require('debuffs')
packets = require('packets')
res = require('resources')
texts = require('texts')
require('logger')

defaults = {}
defaults.interval = .1
defaults.mode = 'blacklist'
defaults.whitelist = S{}
defaults.blacklist = S{}

settings = config.load(defaults)
box = texts.new('${current_string}', settings)
box:show()

list_commands = T{
    w = 'whitelist',
    wlist = 'whitelist',
    white = 'whitelist',
    whitelist = 'whitelist',
    b = 'blacklist',
    blist = 'blacklist',
    black = 'blacklist',
    blacklist = 'blacklist'
}

sort_commands = T{
    a = 'add',
    add = 'add',
    ['+'] = 'add',
    r = 'remove',
    remove = 'remove',
    ['-'] = 'remove'
}

frame_time = 0
debuffed_mobs = {}

function update_box()
    local current_string = ''
    local target = windower.ffxi.get_mob_by_target('t')
    local count = 0

    if target and target.valid_target and (target.claim_id ~= 0 or target.spawn_type == 16) then
        local data = debuffed_mobs[target.id]
        
        if data then
            current_string = 'Debuffed ['..target.name..']\n'
            for effect, spell in pairs(data) do
                local name = debuffs[spell[1]].name
                
                if settings.mode == 'whitelist' and settings.whitelist:contains(name) or settings.mode == 'blacklist' and not settings.blacklist:contains(name) then
                    if debuffs[spell[1]].duration > 0 then
                        current_string = current_string..'\n'..name
                        current_string = current_string..': '..string.format('%.0f', math.max(0, spell[2] - os.clock()))
                    else
                        current_string = current_string..'\n'..name
                    end
                    count = count + 1
                end
            end
        end
    end
    box.current_string = count > 0 and current_string or ''
end

function handle_overwrites(target, new, t)
    if debuffed_mobs[target] then
        for effect, spell in pairs(debuffed_mobs[target]) do
            local old = debuffs[spell[1]].overwrites
            
            -- Check if there isn't a higher priority debuff active
            if #old > 0 then
                for _, v in ipairs(old) do
                    if new == v then
                        return false
                    end
                end
            end
            
            -- Check if a lower priority debuff is being overwritten
            if #t > 0 then
                for _, v in ipairs(t) do
                    if spell[1] == v then
                        debuffed_mobs[target][effect] = nil
                    end
                end
            end
        end
    end
    return true
end

function apply_debuff(target, effect, spell)
    if not debuffed_mobs[target] then
        debuffed_mobs[target] = {}
    end

    -- Check overwrite conditions
    local overwrites = debuffs[spell].overwrites
    if not handle_overwrites(target, spell, overwrites) then
        return
    end
    
    -- Create timer
    debuffed_mobs[target][effect] = {spell, os.clock() + debuffs[spell].duration}
end

function inc_action(act)
    if act.category == 4 then
        
        -- Damaging spells
        if S{2,252}:contains(act.targets[1].actions[1].message) then
            local target = act.targets[1].id
            local spell = act.param
            
            if debuffs[spell] then
                local effect = debuffs[spell].effect
                apply_debuff(target, effect, spell)
            end
            
        -- Non-damaging spells
        elseif S{236,237,268,271}:contains(act.targets[1].actions[1].message) then
            local effect = act.targets[1].actions[1].param
            local target = act.targets[1].id
            local spell = act.param
            
            if debuffs[spell] and debuffs[spell].effect == effect then
                apply_debuff(target, effect, spell)
            end
        end
    end
end

function inc_action_message(arr)

    -- Unit died
    if S{6,20,113,406,605,646}:contains(arr.message_id) then
        debuffed_mobs[arr.target_id] = nil
        
    -- Debuff expired
    elseif S{204,206}:contains(arr.message_id) then
        if debuffed_mobs[arr.target_id] then
            debuffed_mobs[arr.target_id][arr.param_1] = nil
        end
    end
end

windower.register_event('logout','zone change', function()
    debuffed_mobs = {}
end)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x028 then
        inc_action(windower.packets.parse_action(data))
    elseif id == 0x029 then
        local arr = {}
        arr.target_id = data:unpack('I',0x09)
        arr.param_1 = data:unpack('I',0x0D)
        arr.message_id = data:unpack('H',0x19)%32768
        
        inc_action_message(arr)
    end
end)

windower.register_event('prerender', function()
    local curr = os.clock()
    if curr > frame_time + settings.interval then
        frame_time = curr
        update_box()
    end
end)

windower.register_event('addon command', function(command1, command2, ...)
    local args = L{...}
    command1 = command1 and command1:lower() or nil
    command2 = command2 and command2:lower() or nil
    
    local name = args:concat(' ')
    if command1 == 'm' or command1 == 'mode' then
        if settings.mode == 'blacklist' then
            settings.mode = 'whitelist'
        else
            settings.mode = 'blacklist'
        end
        log('Changed to %s mode.':format(settings.mode))
        settings:save()
    elseif command1 == 'i' or command1 == 'interval' then
        settings.interval = tonumber(command2) or .1
        log('Refresh interval set to %s seconds.':format(settings.interval))
        settings:save()
    elseif list_commands:containskey(command1) then
        if sort_commands:containskey(command2) then
            local spell = res.spells:with('name', windower.wc_match-{name})
            command1 = list_commands[command1]
            command2 = sort_commands[command2]
            
            if spell == nil then
                error('No spells found that match: %s':format(name))
            elseif command2 == 'add' then
                settings[command1]:add(spell.name)
                log('Added spell to %s: %s':format(command1, spell.name))
            else
                settings[command1]:remove(spell.name)
                log('Removed spell from %s: %s':format(command1, spell.name))
            end
            settings:save()
        end
    else
        print('%s (v%s)':format(_addon.name, _addon.version))
        print('    \\cs(255,255,255)mode\\cr - Switches between blacklist and whitelist mode (default: blacklist)')
        print('    \\cs(255,255,255)interval <value>\\cr - Allows you to change the refresh interval (default: 0.1)')
        print('    \\cs(255,255,255)blacklist|whitelist add|remove <name>\\cr - Adds or removes the spell <name> to the specified list')
    end
end)