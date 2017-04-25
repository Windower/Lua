--[[Copyright © 2014-2017, trv
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

function texts.up(t, n)
    local y = t:pos_y()
    
    t:pos_y(y - n)
end

function texts.down(t, n)
    local y = t:pos_y()
    
    t:pos_y(y + n)
end

function bit.is_set(val, pos) -- Credit: Arcon
    return bit.band(val, 2^(pos - 1)) > 0
end

function readonly(t)
    return setmetatable({}, {
        __index = t,
        __newindex = function()
            print("Error: Attempt to modify read-only table")
        end,
        __metatable = false -- prevents user from yanking table anyway
    })
end

function weak_readonly(t)
    return setmetatable({}, {
        __index = t,
        __newindex = function(u, k, v)
            if t[k] then
                print("Error: Attempting to modify a protected value.")
            else
                rawset(u, k, v)
            end
        end
    })
end

function recursive_readonly(t)
    return setmetatable({}, {
        __index = function(u, k)
            local v = t[k]
            
            return type(v) == 'table' and recursive_readonly(v) or v
        end
    })
end

function initialize(overlay_name)
    -- try to load the overlay
    local fn, err = attempt_to_load_overlay(overlay_name)
    
    if not fn then
        print('Bailed out. Initialize will run when overlay is loaded via command.')
        print(err)
        nostrum.state.initializing = false    

        return
    end
        
    for event in pairs(events) do
        event_registry[event] = {n = 0}
    end
    
    -- build alliance tables
    local alliance_from_memory = gather_alliance_from_memory()
    
    for i = 1, 3 do
        local party_from_memory = alliance_from_memory[i]
        local party = alliance[i]
        
        for j = 1, party_from_memory.n do
            local id = party_from_memory[j]
            
            alliance_lookup[id].spot = party:invite(id)
        end
    end
    
    -- sandbox
    build_a_sandbox(overlay_name)
    
    -- create overlay
    setfenv(fn, sandbox)
    fn()
    
    -- register Nostrum's events
    nostrum.state.running = true
    nostrum.state.initializing = false
    
    register_events()
    call_events('load')
    
    -- hide the display if Nostrum is hidden
    if nostrum.state.hidden then
        low_level_visibility(false)
    end
end

function attempt_to_load_overlay(name)
    local path = '%soverlays/%s.lua':format(windower.addon_path, name)
    local overlay_file, err = loadfile(path)
    
    return overlay_file, err
end

function gather_alliance_from_memory()
    local alliance_keys = {
        'p0', 'p1', 'p2', 'p3', 'p4', 'p5', 
        'a10', 'a11', 'a12', 'a13', 'a14', 'a15', 
        'a20', 'a21', 'a22', 'a23', 'a24', 'a25'
    }
    local alliance_clone = windower.ffxi.get_party()
    local party = {L{}, L{}, L{}}
    
    for i = 1, 3 do
        local n = 6 * (i - 1)
        local party_from_memory = party[i]
        
        for j = 1, 6 do
            local identifier = alliance_keys[n + j]
            local player_table = alliance_clone[identifier]
            
            if not player_table then break end
            
            local mob = player_table.mob
            
            if mob then -- Cannot track player without id
                local id = mob.id
                party_from_memory:append(id)
                
                if not alliance_lookup[id] then
                    local lookup = players.new()
                    
                    alliance_lookup[id] = lookup
                    lookup.party = i                    
                    
                    for k, v in pairs(lookup) do
                        lookup[k] = player_table[k] or mob[k] or lookup[k]
                    end
                    -- Note: all stats seem to be 0 when this is run on login.
                    -- Not a big deal. After loading, '<stat> change' events will be called.
                    
                    lookup.zone = player_table.zone
                    lookup.out_of_sight = false
                    lookup.out_of_zone = false
                    lookup.seeking_information = false
                    lookup.is_trust = mob.is_npc
                    -- existence of mob implies out_of_sight/zone false
                end
            end
        end
    end

    return party
end

function low_level_visibility(visible)
    for name, is_visible in pairs(bucket.prim) do
        windower.prim.rawset_visibility(name, visible and is_visible)
    end
    
    for name, is_visible in pairs(bucket.text) do
        windower.text.rawset_visibility(name, visible and is_visible)
    end
end

function compare_alliance_to_memory()
    local alliance_from_memory = gather_alliance_from_memory()
    
    for i = 1, 3 do
        local party = alliance_from_memory[i]
        
        if not party:empty() then
            local current_party = alliance[i]

            if current_party:count() == 0 and party.n > 0 then -- that won't work
                call_events('new party', i, party.n)
            end
            
            local party_record = S(current_party)
            
            for j = 1, party.n do
                local id = party[j]
                
                if not party_record:contains(id) then
                    local lookup = alliance_lookup[id]
                    
                    lookup.spot = current_party:invite(id)
                    call_events('member join', i, lookup.spot, sandbox_lookup[id])
                end
            end
        end
    end
    
    --[[ only adding players here:
       if trusts are kicked on zone change, no one should
       ever need to be kicked in this function --]]
end

function finish_trust_invitation()
    -- there is no 0x0DD packet sent when a solo player summons a trust
    local party = alliance[1]
    local alliance_clone = windower.ffxi.get_party()
    
    for _, identifier in ipairs({'p1', 'p2', 'p3', 'p4', 'p5'}) do
        local member = alliance_clone[identifier]
        if not member then break end

        local mob = member.mob
        
        if mob then
            local lookup = trust_lookup[mob.id]
            
            if lookup and lookup.is_trust and lookup.seeking_information then
                alliance_lookup[mob.id] = lookup
                lookup.seeking_information = false
                lookup.hp = member.hp
                lookup.mp = member.mp
                lookup.zone = 0
                lookup.tp = member.tp
                lookup.index = mob.index
                lookup.hpp = member.hpp
                lookup.mpp = member.mpp
                lookup.name = member.name -- name might be pulled out of 0x0DF for trusts
                lookup.out_of_zone = false
                lookup.out_of_sight = false
                
                local pos = party:invite(mob.id)
                
                lookup.spot = pos
                call_events('member join', 1, pos, sandbox_lookup[mob.id])
                
                trust_lookup[mob.id] = nil
            end
        end
    end
end

function get_action_interpreter(cache)
    return function(act_string)
        if not act_string then return end
        
        act_string = act_string:lower()
        
        if cache[act_string] then return recursive_readonly(cache[act_string]) end
        
        local action
        
        for _, category in ipairs{
            'spells', 'job_abilities', 'weapon_skills',
        } do
            for id, resource_entry in pairs(res[category]) do
                if resource_entry[_addon.language]:lower() == act_string then
                    action = resource_entry
                    break
                end
                
                if action then break end
            end
        end
        
        if action then
            cache[act_string] = action
            
            return recursive_readonly(action) 
        end
        
        for _, mabil in ipairs(res.monster_abilities) do
            if mabil[_addon.language]:lower() == act_string then
                action = mabil
                mabil.type = 'MonsterAbility'
                mabil.targets = S{'self', 'others', 'enemy', 'alliance', 'party'} -- prevent filtering: there are no resources available for this
                mabil.prefix = '/monsterskill'
                
                cache[act_string] = action
                
                return recursive_readonly(action)
            end
        end
    end
end

function forget(id)
    alliance_lookup[id] = nil
    sandbox_lookup[id] = nil
end
