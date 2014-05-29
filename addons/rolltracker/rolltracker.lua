--Copyright (c) 2013-2014, Thomas Rogers
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of RollTracker nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL THOMAS ROGERS BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'RollTracker'
_addon.version = '1.2'
_addon.author = 'Balloon'
_addon.command = 'rolltracker'

require('luau')
chat = require('chat')
chars = require('chat.chars')

defaults = {}
defaults.autostop = 0
defaults.bust = 1
defaults.effected = 1
defaults.fold = 1

settings = config.load(defaults)

windower.register_event('addon command',function (...)
    cmd = {...}
    if cmd[1] ~= nil then
        if cmd[1]:lower() == "help" then
            print('To stop rolltracker stopping rolls type: //rolltracker autostop')
            print('To restart rolltracker stopping doubleup type //rolltracker Doubleup')   
        end
        
        if cmd[1]:lower() == "autostop" then
            override = true
            print('Disabled Autostopping Double Up')
        end
        
        if cmd[1]:lower() == "doubleup" then
            override = false
            print('Enable Autostoppping Doubleup')
        end 
    end
end)

windower.register_event('load', function()
    buffId = S{res.buffs:with('english', 'Bust')} + S(res.buffs:english(string.endswith-{' Roll'}))
    partyColour = {
        p0 = string.char(0x1E, 247),
        p1 = string.char(0x1F, 204),
        p2 = string.char(0x1E, 156),
        p3 = string.char(0x1E, 238),
        p4 = string.char(0x1E, 5),
        p5 = string.char(0x1E, 6)
    }
    local rollInfoTemp = {
        ['Chaos'] = {6,8,9,25,11,13,16,3,17,19,31,"-4", '% Attack!', 4},
        ['Fighter\'s'] = {2,2,3,4,12,5,6,7,1,9,18,'-4','% Double-Attack!', 5},
        ['Wizard\'s'] = {2,3,4,4,10,5,6,7,1,7,12, "-4", ' MAB', 5},
        ['Evoker\'s'] = {1,1,1,1,3,2,2,2,1,3,4,'-1', ' Refresh!',5},
        ['Rogue\'s'] = {2,2,3,4,12,5,6,6,1,8,19,'-6', '% Critical Hit Rate!', 5},
        ['Corsair\'s'] = {10, 11, 11, 12, 20, 13, 15, 16, 8, 17, 24, '-6', '% Experience Bonus',5},
        ['Hunter\'s'] = {10,13,15,40,18,20,25,5,27,30,50,'-?', ' Accuracy Bonus',4},
        ['Magus\'s'] = {5,20,6,8,9,3,10,13,14,15,25,'-8',' Magic Defense Bonus',2},
        ['Healer\'s'] = {3,4,12,5,6,7,1,8,9,10,16,'-4','% Cure Potency',3},
        ['Drachen'] = {10,13,15,40,18,20,25,5,28,30,50,'-8',' Pet: Accuracy Bonus',4},
        ['Choral'] = {8,42,11,15,19,4,23,27,31,35,50,'+25', '- Spell Interruption Rate',2},
        ['Monk\'s'] = {8,10,32,12,14,15,4,20,22,24,40,'-?', ' Subtle Blow', 3},
        ['Beast'] = {6,8,9,25,11,13,16,3,17,19,31,'-10', '% Pet: Attack Bonus',4},
        ['Samurai'] = {7,32,10,12,14,4,16,20,22,24,40,'-10',' Store TP Bonus',2},
        ['Warlock\'s'] = {2,3,4,12,15,6,7,1,8,9,15,'-5',' Magic Accuracy Bonus',4},
        ['Puppet'] = {4,5,18,7,9,10,2,11,13,15,22,'-8',' Pet: Magic Attack Bonus',3},
        ['Gallant\'s'] = {4,5,15,6,7,8,3,9,10,11,20,'-10','% Defense Bonus', 3},
        ['Dancer\'s'] = {3,4,12,5,6,7,1,8,9,10,16,'-4',' Regen',3},
        ['Bolter\'s'] = {2,3,12,4,6,7,8,9,5,10,25,'-8','% Movement Speed',3},
        ['Caster\'s'] = {6,15,7,8,9,10,5,11,12,13,20,'-10','% Fast Cast',2},
        ['Tactician\'s'] = {2,2,2,2,4,2,2,1,3,3,5,'-1',' Regain',5},
        ['Miser\'s'] = {3,5,7,9,20,11,2,13,15,17,25,'0',' Save TP',5},
        ['Ninja'] = {4,5,5,14,6,7,9,2,10,11,18,'-10',' Evasion Bonus',4},
        ['Scholar\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Conserve MP',2},
        ['Allies\''] = {6,7,17,9,11,13,15,17,17,5,17,'?','% Skillchain Damage',3},
        ['Companion\'s'] = {'4HP +2TP','20HP +5TP','6HP +2TP','8HP +2TP','10HP +3TP','12HP +3TP','14HP +3TP','16HP +4TP','18HP +4TP','3HP +1TP','25HP +6TP','-',' Pet: Regen and Regain',2},
        ['Avenger\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Counter Rate',4},
        ['Blitzer\'s'] = {2,3.4,4.5,11.3,5.3,6.4,7.2,8.3,1.5,10.2,12.1,'-?', '% Attack delay reduction',4},
        ['Courser\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Snapshot',3}
    }

    rollInfo = {}
    for key, val in pairs(rollInfoTemp) do
        rollInfo[res.buffs:with('english', key .. ' Roll').id] = {key, unpack(val)}
    end

    settings = config.load(defaults)
    --Wanted to change this to true/false in config file, but it wouldn't update to everyone -- This is an inelegant solution.
    override = settings.autostop == 1 and true or false
                
    if windower.ffxi.get_info().logged_in then
        initialize()
    end
end)

windower.register_event('login', initialize)

function initialize()
    isLucky = false
    player = windower.ffxi.get_player()
end

windower.register_event('incoming text', function(old, new, color)
    --Hides Battlemod
    if old:match("Roll.* The total.*") or old:match('.*Roll.*' .. string.char(0x81, 0xA8)) or old:match('.*uses Double.*The total') and color ~= 123 then
        return true
    end

    --Hides normal
    if old:match('.* receives the effect of .* Roll.') ~= nil then
        return true
    end

    --Hides Older Battlemod versions --Antiquated
    if old:match('%('..'%w+'..'%).* Roll ') then
        new = old
    end

    return new, color
end)

windower.register_event('action', function(act)
    if act.category == 6 and table.containskey(rollInfo, act.param) then
        --This is used later to allow/disallow busting
        --If you are not the rollActor you will not be disallowed to bust.
        rollActor = act.actor_id
        local rollID = act.param
        local rollNum = act.targets[1].actions[1].param
        
        -- anonymous function that checks if the player.id is in the targets without wrapping it in another layer of for loops.
        if 
            function(act)
                for i = 1, #act.targets do 
                    if act.targets[i].id == player.id then
                        return true
                    end
                end
                return false
            end(act)
        then
            local party = windower.ffxi.get_party()
            rollMembers = {}
            for partyMem in pairs(party) do
                for effectedTarget = 1, #act.targets do
                    --if mob is nil then the party member is not in zone, will fire an error.
                    if party[partyMem].mob and act.targets[effectedTarget].id == party[partyMem].mob.id then   
                        rollMembers[effectedTarget] = partyColour[partyMem] .. party[partyMem].name .. chat.controls.reset
                    end
                end
            end

            local membersHit = table.concat(rollMembers, ', ')
            --fake 'ternary' assignment. if settings.effected is 1 then it'll show numbers, otherwise it won't.
            local amountHit = settings.effected == 1 and '[' .. #rollMembers .. '] ' or ''
            
            isLucky = false
            if rollNum == rollInfo[rollID][15] or rollNum == 11 then 
                isLucky = true
                windower.add_to_chat(1, amountHit..membersHit..chat.controls.reset..' '..chars.implies..' '..rollInfo[rollID][1]..' Roll '..chars['circle' .. rollNum]..string.char(31,158)..' (Lucky!)'..string.char(31,13)..' (+'..rollInfo[rollID][rollNum+1]..rollInfo[rollID][14]..')'..BustRate(rollNum, id))
            elseif rollNum == 12 and #rollMembers > 0 then
                windower.add_to_chat(1, string.char(31,167)..amountHit..'Bust! '..chat.controls.reset..chars.implies..' '..membersHit..' '..chars.implies..' ('..rollInfo[rollID][rollNum+1]..rollInfo[rollID][14]..')')
            else
                windower.add_to_chat(1, amountHit..membersHit..chat.controls.reset..' '..chars.implies..' '..rollInfo[rollID][1]..' Roll '..chars['circle' .. rollNum]..string.char(31,13)..' (+'..rollInfo[rollID][rollNum+1]..rollInfo[rollID][14]..')'..BustRate(rollNum, id))
            end
        end
    end
end)

function BustRate(num, rollerID)
    if num <= 5 or num == 11 or rollerID ~= player.id or settings.bust == 0 then
        return ''
    end
    return '\7  [Chance to Bust]: ' .. '%.1f':format((num-5)*16.67) .. '%'
end

--Checks to see if the below event has ran more than twice to enable busting
ranMultiple = false
windower.register_event('outgoing text', function(original, modified)
    if not original:match('/raw') then
        if original:match('/jobability \"Double.*Up') then
            if isLucky and not override and rollActor == player.id then
                windower.add_to_chat(159,'Attempting to Doubleup on a Lucky Roll: Re-double up to continue.')
                isLucky = false
                return true
            end
        end
        
        if settings.fold == 1 and original:match('/jobability \"Fold') then
            local count = 0
            local canBust = false

            --Check to see how many buffs are active
            local cor_buffs = S(player.buffs) * buffId
            canBust = cor_buffs:contains(res.buffs:with('name', 'Bust').id) or cor_buffs:length() > 1

            if canBust or ranMultiple then
                modified = original
                ranMultiple = false
            else
                windower.add_to_chat(159, 'No \'Bust\'. Fold again to continue.')
                ranMultiple = true
                return true
            end
            
            return modified
        end
    end
    
end)
