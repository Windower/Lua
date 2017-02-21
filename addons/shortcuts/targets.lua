--Copyright (c) 2014, Byrthnoth
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

-----------------------------------------------------------------------------------
--Name: valid_target(targ,flag)
--Args:
---- targ (string): The proposed target
---- flag (boolean): sets a more stringent criteria for target. It has to be a
----    match to a player in the mob_array.
-----------------------------------------------------------------------------------
--Returns:
---- A string or false.
-----------------------------------------------------------------------------------
function valid_target(targ,flag)
    local spell_targ
    local san_targ = find_san(strip(targ))
    -- If the target is whitelisted, pass it through.
    if pass_through_targs:contains(targ:lower()) or st_targs:contains(targ:lower()) or (tonumber(targ:lower()) and windower.ffxi.get_mob_by_id(tonumber(targ:lower()))) then
        return targ:lower()
    elseif targ and windower.ffxi.get_player() then
    -- If the target exists, scan the mob array for it
        local current_target = windower.ffxi.get_mob_by_target('t')
        local targar = {}
        for i,v in pairs(windower.ffxi.get_mob_array()) do
            if string.find(strip(v.name),san_targ) and (v.valid_target or v.id == windower.ffxi.get_player().id) then -- Malformed pattern somehow
                -- Handling for whether it's a monster or not
                if v.is_npc and v.spawn_type ~= 14 and current_target then
                    if v.id == current_target.id then
                        targar['<t>'] = math.sqrt(v.distance)
                    end
                elseif not v.is_npc or (v.spawn_type == 14 and v.in_party) then
                    targar[v.name] = math.sqrt(v.distance)
                end
            end
        end
                
        -- If flag is set, push out the target only if it is in the targ array.
        if targar[targ] then
            spell_targ = targ
        elseif flag then
            spell_targ = false
        else
            -- If targ starts an element of the monster array, use it.
            local priority = 50
            for i,v in pairs(targar) do
                if (i:lower()==san_targ:lower()) then
                    v = 0
                elseif i:lower():find('^'..san_targ:lower()) then
                    v = v/50
                end
                if v < priority then -- Use the highest priority match, with a default priority hierarchy based on distance
                    priority = v
                    spell_targ = i
                end
            end
        end
    end
    return spell_targ
end


-----------------------------------------------------------------------------------
--Name: target_make(targarr)
--Args:
---- targets (table of booleans): Keyed to potential targets
-----------------------------------------------------------------------------------
--Returns:
---- Created valid target, defaulting to '<me>'
-----------------------------------------------------------------------------------
function target_make(targets)
    local target = windower.ffxi.get_mob_by_target('<t>')
    local target_type = ''
    if not target then
        -- If target doesn't exist, leave it set to ''. This will shortcircuit the
        -- rest of the processing and just return <me>.
    elseif target.hpp == 0 then
        target_type = 'Corpse'
    elseif target.is_npc and target.spawn_type ~= 14 then
        target_type = 'Enemy'
        -- Need to add handling that differentiates 'Enemy' and 'NPC' here.
    else
        target_type = 'Ally'
        local party = windower.ffxi.get_party()
        for i,v in pairs(party) do
            if type(v) == 'table' and v.name == target.name then
                if i:sub(1,1) == 'p' then
                    if i:sub(1,2) == 'p0' then
                        target_type = 'Self'
                    else
                        target_type = 'Party'
                    end
                end
                if target.charmed and not target.is_npc then
                    target_type = 'Enemy'
                end
                break
            end
        end
    end
        
    if targets[target_type] and target_type ~= 'Self' then
        return '<t>'
    elseif targets.Self then
        return '<me>'
    elseif targets.Self or targets.Party or targets.Enemy or targets.NPC or targets.Ally or targets.Corpse then
        return '<t>'
    else
        return ''
    end
end