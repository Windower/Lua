--Copyright (c) 2013~2016, Byrthnoth
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


-- Target Processing --

function valid_target(targ)
    local spelltarget = {}
    
    local spell_targ
    if pass_through_targs[targ] then
        local j = windower.ffxi.get_mob_by_target(targ)
        
        if j then spelltarget = target_complete(j) end
        
        spelltarget.raw = targ
        return targ, spelltarget
    elseif targ and tonumber(targ) and tonumber(targ) > 255 then
        local j = windower.ffxi.get_mob_by_id(tonumber(targ))
        
        if j then spelltarget = target_complete(j) end
        
        spelltarget.raw = targ
        return targ, spelltarget
    elseif targ and not tonumber(targ) and targ ~= '' then
        local mob_array = windower.ffxi.get_mob_array()
        for i,v in pairs(mob_array) do
            if v.name:lower()==targ:lower() and (not v.is_npc or v.spawn_type == 14) then
                spelltarget = target_complete(v)
                spelltarget.raw = targ
                return targ, spelltarget
            end
        end
    end
    return false, false
end

function target_complete(mob_table)
    if mob_table == nil then return {type = 'NONE'} end
    
    ------------------------------- Should consider moving the partycount part of this code to refresh_player() ----------------------------------
    mob_table.isallymember = false
    if not mob_table.id then
        mob_table.type = 'NONE'
    else
        local j = windower.ffxi.get_party()
        
        for i,v in pairs(j) do
            if type(v) == 'table' and v.mob then
                if v.mob.id == mob_table.id then
                    mob_table.isallymember = true
                    if i:sub(1,1) == 'p' then
                        mob_table.ispartymember = true
                    end
                end
            end
        end
    ------------------------------------------------------------------------------------------------------------------------------------
        
        if player.id == mob_table.id then
            mob_table.type = 'SELF'
        elseif mob_table.is_npc then
            if mob_table.id%4096>2047 then
                mob_table.type = 'NPC'
            else
                mob_table.type = 'MONSTER'
            end
        else
            mob_table.type = 'PLAYER'
        end
    end
    
    if mob_table.race then 
        mob_table.race_id = mob_table.race
        if res.races[mob_table.race] then
            mob_table.race = res.races[mob_table.race][language]
        else
            mob_table.race = 'Unknown'
        end
    end
    if mob_table.status then
        mob_table.status_id = mob_table.status
        if res.statuses[mob_table.status] then
            mob_table.status = res.statuses[mob_table.status].english
        else
            mob_table.status = 'Unknown'
        end
    end
    if mob_table.distance then
        mob_table.distance = math.sqrt(mob_table.distance)
    end
    return mob_table
end

function target_type_check(spell)
    --[[ Spawn type mapping:
        1 = Other players
        2 = Town NPCs, AH counters, Logging Points, etc.
        Bit 1 = 1 PC
        Bit 2 = 2 NPC (not attackable)
        Bit 3 = 4 Party Member
        Bit 4 = 8 Ally
        Bit 5 = 16 Enemy
        Bit 6 = 32 Door (Environment)
        13 = Self
        14 = Trust NPC in party
        16 = Monsters
        34 = Some doors
    ]]
    
    local temptype = spell.target.type
    if temptype ~= 'NPC' then
        temptype = temptype:lower():ucfirst()
    end
    
    if temptype == 'Player' and spell.target.hpp == 0 then
        temptype = 'Corpse'
    elseif temptype == 'Player' and spell.target.ispartymember then
        temptype = 'Party'
    elseif temptype == 'Player' and spell.target.isallymember then
        temptype = 'Ally'
    end
    
    if spell.targets[temptype] then return true end
    return false
end