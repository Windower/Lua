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
_addon.version = '1.7.0.0'
_addon.author = 'Balloon'
_addon.command = 'rolltracker'

require('luau')
chat = require('chat')
chars = require('chat.chars')
packets = require('packets')

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

--This is done because GearSwap swaps out too fast, and sometimes things aren't reported in memory.
--Therefore, we store it within rolltracker so we can do the check locally.
--  Parsing:
windower.register_event('incoming chunk', function(id, data) 
     if id == 0x050 then
        local packet = packets.parse('incoming', data)
        local slot = windower.ffxi.get_items(packet['Inventory Bag'])[packet['Inventory Index']]
        gearTable[packet['Equipment Slot']] = slot ~= nil and slot.id or 0
     end
end)

function getGear(slot)
    local equip = windower.ffxi.get_items()['equipment']
    return windower.ffxi.get_items(equip[slot..'_bag'])[equip[slot]]~= nil and windower.ffxi.get_items(equip[slot..'_bag'])[equip[slot]].id or 0
end

windower.register_event('load', function()

    --We need a gear table, and we need to initialise it when we load 
    --So that if someone doesn't swap gear, at least it still works.
    gearTable = {
        [0]=getGear('main'),[1]=getGear('sub'),[2]=getGear('range'),[3]=getGear('ammo'),
        [4]=getGear('head'),[9]=getGear('neck'),[11]=getGear('left_ear'),[12]=getGear('right_ear'),
        [5]=getGear('body'),[6]=getGear('hands'),[13]=getGear('left_ring'),[14]=getGear('right_ring'),
        [15]=getGear('back'),[10]=getGear('waist'),[7]=getGear('legs'),[8]=getGear('feet')
    }
    buffId = S{309} + S(res.buffs:english(string.endswith-{' Roll'})):map(table.get-{'id'})
    partyColour = {
        p0 = string.char(0x1E, 247),
        p1 = string.char(0x1F, 204),
        p2 = string.char(0x1E, 156),
        p3 = string.char(0x1E, 238),
        p4 = string.char(0x1E, 5),
        p5 = string.char(0x1E, 6)
    }
    local rollInfoTemp = {
        -- Okay, this goes 1-11 boost, Bust effect, Effect, Lucky, +1 Phantom Roll Effect, Bonus Equipment and Effect,
        ['Chaos'] = {64,80,96,256,112,128,160,32,176,192,320,"-9.76", '% Attack!', 4, 32},--/1024 
        ['Fighter\'s'] = {2,2,3,4,12,5,6,7,1,9,18,'-4','% Double-Attack!', 5, 1},
        ['Wizard\'s'] = {4,6,8,10,25,12,14,17,2,20,30, "-10", ' MAB', 5, 2},
        ['Evoker\'s'] = {1,1,1,1,3,2,2,2,1,3,4,'-1', ' Refresh!',5, 1},
        ['Rogue\'s'] = {2,2,3,4,12,5,6,6,1,8,14,'-6', '% Critical Hit Rate!', 5, 1},
        ['Corsair\'s'] = {10, 11, 11, 12, 20, 13, 15, 16, 8, 17, 24, '-6', '% Experience Bonus',5, 2},
        ['Hunter\'s'] = {10,13,15,40,18,20,25,5,28,30,50,'-15', ' Accuracy Bonus',4, 5},
        ['Magus\'s'] = {5,20,6,8,9,3,10,13,14,15,25,'-8',' Magic Defense Bonus',2, 2},
        ['Healer\'s'] = {3,4,12,5,6,7,1,8,9,10,16,'-4','% Cure Potency',3, 1},
        ['Drachen'] = {10,13,15,40,18,20,25,5,28,30,50,'0',' Pet: Accuracy Bonus',4, 5},
        ['Choral'] = {8,42,11,15,19,4,23,27,31,35,50,'+25', '- Spell Interruption Rate',2, 4},
        ['Monk\'s'] = {8,10,32,12,14,15,4,20,22,24,40,'-?', ' Subtle Blow', 3, 4},
        ['Beast'] = {6,8,9,25,11,13,16,3,17,19,31,'0', '% Pet: Attack Bonus',4, 3},
        ['Samurai'] = {7,32,10,12,14,4,16,20,22,24,40,'-10',' Store TP Bonus',2, 4},
        ['Warlock\'s'] = {2,3,4,12,5,6,7,1,8,9,15,'-5',' Magic Accuracy Bonus',4, 1},
        ['Puppet'] = {5,8,35,11,14,18,2,22,26,30,40,'-8',' Pet: Magic Attack Bonus',3, 3},
        ['Gallant\'s'] = {48,60,200,72,88,104,32,120,140,160,240,'-11.72','% Defense Bonus', 3, 24},--/1024
        ['Dancer\'s'] = {3,4,12,5,6,7,1,8,9,10,16,'-4',' Regen',3, 2},
        ['Bolter\'s'] = {0.3,0.3,0.8,0.4,0.4,0.5,0.5,0.6,0.2,0.7,1.0,'0','% Movement Speed',3, 0.2},
        ['Caster\'s'] = {6,15,7,8,9,10,5,11,12,13,20,'-10','% Fast Cast',2, 3,{7, 11140, 27269, 27269, 10}},
        ['Tactician\'s'] = {10,10,10,10,30,10,10,0,20,20,40,'-10',' Regain',5, 2, {5, 11100, 26930, 26931, 10}},
        ['Miser\'s'] = {30,50,70,90,200,110,20,130,150,170,250,'0',' Save TP',5, 15},
        ['Ninja'] = {10,13,15,40,18,20,25,5,28,30,50,'-15',' Evasion Bonus',4, 5},
        ['Scholar\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Conserve MP',2, 0},
        ['Allies\''] = {6,7,17,9,11,13,15,17,17,5,17,'?','% Skillchain Damage',3, 1,{6,11120, 27084, 27085, 5}},
        ['Companion\'s'] = {{4,20},{20,50},{6,20},{8,20},{10,30},{12,30},{14,30},{16,40},{18,40},{3,10},{25,60},'0',' Pet: Regen/Regain',2, {2,5}},
        ['Avenger\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Counter Rate',4, 0},
        ['Blitzer\'s'] = {2,3.4,4.5,11.3,5.3,6.4,7.2,8.3,1.5,10.2,12.1,'-?', '% Attack delay reduction',4, 1, {4,11080, 26772, 26773, 5}},
        ['Courser\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Snapshot',3, 0}, --11160, 27443, 27444
        ['Runeist\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Magic Evasion',4, 0},
        ['Naturalist\'s'] = {6,7,15,8,9,10,5,11,12,13,20,'-5','% Enhancing Magic Duration',3, 1}
    }

    rollInfo = {}
    for key, val in pairs(rollInfoTemp) do
        rollInfo[res.job_abilities:with('english', key .. ' Roll').id] = {key, unpack(val)}
    end
    
    settings = config.load(defaults)
    --Wanted to change this to true/false in config file, but it wouldn't update to everyone -- This is an inelegant solution.
    override = settings.autostop == 1 and true or false
end)

windower.register_event('load', 'login', function()
    isLucky = false
    ringBonus = false
    lastRoll = 0
    player = windower.ffxi.get_player()
end)

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
                    if type(party[partyMem]) == 'table' and party[partyMem].mob and act.targets[effectedTarget].id == party[partyMem].mob.id then   
                        rollMembers[effectedTarget] = partyColour[partyMem] .. party[partyMem].name .. chat.controls.reset
                    end
                end
            end

            local membersHit = table.concat(rollMembers, ', ')
            --fake 'ternary' assignment. if settings.effected is 1 then it'll show numbers, otherwise it won't.
            local amountHit = settings.effected == 1 and '[' .. #rollMembers .. '] ' or ''            
            local rollBonus = RollEffect(rollID, rollNum+1)
            local luckChat = ''
            isLucky = false
            if rollNum == rollInfo[rollID][15] or rollNum == 11 then 
                isLucky = true
                luckChat = string.char(31,158).." (Lucky!)"
            end

            if rollNum == 12 and #rollMembers > 0 then
                windower.add_to_chat(1, string.char(31,167)..amountHit..'Bust! '..chat.controls.reset..chars.implies..' '..membersHit..' '..chars.implies..' ('..rollInfo[rollID][rollNum+1]..rollInfo[rollID][14]..')')
            else
                windower.add_to_chat(1, amountHit..membersHit..chat.controls.reset..' '..chars.implies..' '..rollInfo[rollID][1]..' Roll '..chars['circle' .. rollNum]..luckChat..string.char(31,13)..' (+'..rollBonus..')'..BustRate(rollNum, id))
            end
        end
    end
end)


function RollEffect(rollid, rollnum)
    if rollnum == 13 then
        return
    end

    --There's gotta be a better way to do this.
    local rollName = rollInfo[rollid][1]
    local rollVal = rollInfo[rollid][rollnum]
    
    if lastRoll ~= rollid then 
        lastRoll = rollid
        ringBonus = false
        gearBonus = false
    end

    --I'm handling one roll a bit odd, so I need to deal with it seperately.
    --Which is stupid, I know, but look at how I've done most of this
    if rollName == "Companion\'s" then
        local hpVal = rollVal[1]
        local tpVal = rollVal[2]
        if gearTable[9] == 26038 or ringBonus then
            hpVal =  hpVal + (rollInfo[rollid][16][1]*7)
            tpVal = tpVal  + (rollInfo[rollid][16][2]*7)
            ringBonus = true
        elseif gearTable[13] == 28548 or gearTable[14]== 28548 or ringBonus then
            hpVal =  hpVal + (rollInfo[rollid][16][1]*5)
            tpVal = tpVal  + (rollInfo[rollid][16][2]*5)
            ringBonus = true
        elseif gearTable[13] == 28547 or gearTable[14] == 28547 or ringBonus then
            hpVal =  hpVal + (rollInfo[rollid][16][1]*3)
            tpVal = tpVal  + (rollInfo[rollid][16][2]*3)
            ringBonus = true
        end
        return "Pet:"..hpVal.." Regen".." +"..tpVal.." Regain" 
    end

    --If there's no Roll Val can't add to it
    if rollVal ~= '?' then
        if gearTable[9] == 26038 or ringBonus then
            rollVal = rollVal + (rollInfo[rollid][16]*7)
            ringBonus = true
        elseif gearTable[13] == 28548 or gearTable[14] == 28548 or ringBonus then
            rollVal = rollVal + (rollInfo[rollid][16]*5)
            ringBonus = true
        elseif gearTable[13] == 28547 or gearTable[14] == 28547 or ringBonus then
            rollVal = rollVal + (rollInfo[rollid][16]*3)
            ringBonus = true
        end
    end

    --Handle Emp +2, 109 and 119 gear bonus
    if(rollInfo[rollid][17] ~= nil) then
        local bonusVal = gearTable[rollInfo[rollid][17][1]] == rollInfo[rollid][17][2] or gearTable[rollInfo[rollid][17][1]] == rollInfo[rollid][17][3] or gearTable[rollInfo[rollid][17][1]] ==  rollInfo[rollid][17][4] and rollInfo[rollid][17][5] or 0
       if gearBonus == true then
          rollVal = rollVal + rollInfo[rollid][17][5]
        else
          gearBonus = true
          rollVal = rollVal + bonusVal
        end
  end
  
    -- Convert Bolters to Movement Speed based on 5.0 being 100%
    if(rollName == "Bolter\'s") then
        rollVal = '%.0f':format(100*((5+rollVal) / 5 - 1))
    end
    
    --Convert Chaos to % with 2 decimials
    if(rollName == "Chaos") then
        rollVal = '%.2f':format(rollVal/1024 * 100)
    end
    
    --Convert Gallant's to % with 2 decimials
    if(rollName == "Gallant\'s") then
        rollVal = '%.2f':format(rollVal/1024 * 100)
    end

    return rollVal..rollInfo[rollid][14]
end


function BustRate(num, rollerID)
    if num <= 5 or num == 11 or rollerID ~= player.id or settings.bust == 0 then
        return ''
    end
    return '\7  [Chance to Bust]: ' .. '%.1f':format((num-5)*16.67) .. '%'
end

--Checks to see if the below event has ran more than twice to enable busting
ranMultiple = false
windower.register_event('outgoing text', function(original, modified)
    modified = original
    if original:match('/jobability \"Double.*Up') then
        if isLucky and not override and rollActor == player.id then
            windower.add_to_chat(159,'Attempting to Doubleup on a Lucky Roll: Re-double up to continue.')
            isLucky = false
            modified = ""
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
            modified = ""
        end
        
        return modified
    end
   return modified
    
end)
