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
_addon.version = '1.8.1.0'
_addon.author = 'Balloon'
_addon.commands = {'rolltracker','rt'}

require('luau')
chat = require('chat')
chars = require('chat.chars')
packets = require('packets')

defaults = {}
defaults.autostopper = true
defaults.bust = 1
defaults.effected = 1
defaults.fold = 1
defaults.luckyinfo = true

settings = config.load(defaults)

windower.register_event('addon command',function (...)
    cmd = {...}
    if cmd[1] ~= nil then
        if cmd[1]:lower() == "help" then
            log('To toggle rolltracker from allowing/stopping rolls type: //rolltracker autostop')
            log('To toggle rolltracker from showing/hiding Lucky Info type: //rolltracker luckyinfo')
        elseif cmd[1]:lower() == "autostop" then
            if settings.autostopper then
               settings.autostopper = false
               log('Will no longer stop Double-UP on a Lucky Roll.')
            else
               settings.autostopper = true
               log('Will stop Double-UP on a Lucky Roll.')
            end
        elseif cmd[1]:lower() == "luckyinfo" then
            if settings.luckyinfo then
               settings.luckyinfo = false
               log('Lucky/Unlucky Info will no longer be displayed.')
            else
               settings.luckyinfo = true
               log('Lucky/Unlucky Info will now be displayed.')
            end
        end
        config.save(settings, 'all')
    end
end)

--This is done because GearSwap swaps out too fast, and sometimes things aren't reported in memory.
--Therefore, we store it within rolltracker so we can do the check locally.
windower.register_event('incoming chunk', function(id, data)
     if id == 0x050 then
        local packet = packets.parse('incoming', data)
        local slot = windower.ffxi.get_items(packet['Inventory Bag'])[packet['Inventory Index']]
        gearTable[packet['Equipment Slot']] = slot ~= nil and slot.id or 0
    elseif id == 0x0DD then
        local packetParty = packets.parse('incoming', data)

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
        -- Okay, this goes 1-11 boost, Bust effect, Effect, Lucky, Unlucky, +1 Phantom Roll Effect, Job Bonus, Bonus Equipment and Effect,
        ['Allies\''] =      {6,7,17,9,11,13,15,17,17,5,17,'?','% Skillchain Damage',3,10, 1,{nil,0},{6,11120, 27084, 27085, 5}},                      -- Needs Eval
        ['Avenger\'s'] =    {'?','?','?','?','?','?','?','?','?','?','?','?',' Counter Rate',4,8, 0,{nil,0}},
        ['Beast'] =         {64,80,96,256,112,128,160,32,176,192,320,'0','% Pet: Attack Bonus',4,8, 32,{'bst',100}},                                  -- /1024 Confirmed
        ['Blitzer\'s'] =    {2,3.4,4.5,11.3,5.3,6.4,7.2,8.3,1.5,10.2,12.1,'-3','% Attack delay reduction',4,9, 1,{nil,0},{4,11080, 26772, 26773, 5}}, -- Limited Testing for Bust, Needs more data for sure probably /1024
        ['Bolter\'s'] =     {0.3,0.3,0.8,0.4,0.4,0.5,0.5,0.6,0.2,0.7,1.0,'0','% Movement Speed',3,9, 0.2,{nil,0}},
        ['Caster\'s'] =     {6,15,7,8,9,10,5,11,12,13,20,'-10','% Fast Cast',2,7, 3,{nil,0},{7, 11140, 27269, 27269, 10}},
        ['Chaos'] =         {64,80,96,256,112,128,160,32,176,192,320,"-9.76",'% Attack!', 4,8, 32,{'drk',100}},                                       -- /1024 Confirmed
        ['Choral'] =        {8,42,11,15,19,4,23,27,31,35,50,'+25','- Spell Interruption Rate',2,6, 4,{'brd',25}},                                     -- SE listed Values and hell if I'm testing this
        ['Companion\'s'] =  {{4,20},{20,50},{6,20},{8,20},{10,30},{12,30},{14,30},{16,40},{18,40},{3,10},{25,60},'0',' Pet: Regen/Regain',2,10, {2,5},{nil,0}},
        ['Corsair\'s'] =    {10, 11, 11, 12, 20, 13, 15, 16, 8, 17, 24,'-6','% Experience Bonus',5,9, 2,{'cor',5}},                                   -- Needs Eval on Bust/Job Bonus
        ['Courser\'s'] =    {'?','?','?','?','?','?','?','?','?','?','?','?',' Snapshot',3,9, 0,{nil,0}},                                             -- 11160, 27443, 27444
        ['Dancer\'s'] =     {3,4,12,5,6,7,1,8,9,10,16,'-4',' Regen',3,7, 2,{'dnc',4}},                                                                -- Confirmed
        ['Drachen'] =       {10,13,15,40,18,20,25,5,28,30,50,'0',' Pet: Accuracy Bonus',4,8, 5,{'drg',15}},                                           -- Confirmed
        ['Evoker\'s'] =     {1,1,1,1,3,2,2,2,1,3,4,'-1',' Refresh!',5,9, 1,{'smn',1}},                                                                -- Confirmed
        ['Fighter\'s'] =    {2,2,3,4,12,5,6,7,1,9,18,'-4','% Double-Attack!',5,9, 1,{'war',5}},
        ['Gallant\'s'] =    {48,60,200,72,88,104,32,120,140,160,240,'-11.72','% Defense Bonus',3,7, 24,{'pld',120}},                                  -- /1024 Confirmed
        ['Healer\'s'] =     {3,4,12,5,6,7,1,8,9,10,16,'-4','% Cure Potency Received',3,7, 1,{'whm',4}},                                               -- Confirmed
        ['Hunter\'s'] =     {10,13,15,40,18,20,25,5,28,30,50,'-15',' Accuracy Bonus',4,8, 5,{'rng',15}},                                              -- Confirmed
        ['Magus\'s'] =      {5,20,6,8,9,3,10,13,14,15,25,'-8',' Magic Defense Bonus',2,6, 2,{'blu',8}},
        ['Miser\'s'] =      {30,50,70,90,200,110,20,130,150,170,250,'0',' Save TP',5,7, 15,{nil,0}},
        ['Monk\'s'] =       {8,10,32,12,14,15,4,20,22,24,40,'-?',' Subtle Blow', 3,7, 4,{'mnk',10}},
        ['Naturalist\'s'] = {6,7,15,8,9,10,5,11,12,13,20,'-5','% Enhancing Magic Duration',3,7, 1,{'geo',5}},                                         -- Confirmed
        ['Ninja'] =         {10,13,15,40,18,20,25,5,28,30,50,'-15',' Evasion Bonus',4,8, 5,{'nin',15}},                                               -- Confirmed
        ['Puppet'] =        {5,8,35,11,14,18,2,22,26,30,40,'-8',' Pet: MAB/MAcc',3,7, 3,{'pup',12}},
        ['Rogue\'s'] =      {2,2,3,4,12,5,6,6,1,8,14,'-6','% Critical Hit Rate!',5,9, 1,{'thf',5}},
        ['Runeist\'s'] =    {10,13,15,40,18,20,25,5,28,30,50,'-15',' Evasion Bonus',4,8, 5,{'run',15}},                                               -- Needs Eval
        ['Samurai'] =       {8,32,10,12,14,4,16,20,22,24,40,'-10',' Store TP Bonus',2,6, 4,{'sam',10}},                                               -- Confirmed 1(Was bad),2,3,4,5,6,7,8,11 (I Wing Test)
        ['Scholar\'s'] =    {2,10,3,4,4,1,5,6,7,7,12,'-3','% Conserve MP',2,6, 1,{'sch',3}},                                                          --Needs Eval Source ATM: JP Wiki
        ['Tactician\'s'] =  {10,10,10,10,30,10,10,0,20,20,40,'-10',' Regain',5,8, 2,{nil,0},{5, 11100, 26930, 26931, 10}},                            -- Confirmed
        ['Warlock\'s'] =    {10,13,15,40,18,20,25,5,28,30,50,'-15',' Magic Accuracy Bonus',4,8, 5,{'rdm',15}}, -- 
        ['Wizard\'s'] =     {4,6,8,10,25,12,14,17,2,20,30, "-10",' MAB',5,9, 2,{'blm',10}},
    }

    rollInfo = {}
    for key, val in pairs(rollInfoTemp) do
        rollInfo[res.job_abilities:with('english', key .. ' Roll').id] = {key, unpack(val)}
    end

    settings = config.load(defaults)
end)

windower.register_event('load', 'login', function()
    isLucky = false
    rollPlusBonus = false
    lastRoll = 0
    player = windower.ffxi.get_player()
end)

windower.register_event('incoming text', function(old, new, color)
    --Hides Battlemod
    if old:match("Roll.* The total.*") or old:match('.*Roll.*' .. string.char(0x81, 0xA8)) or old:match('.*uses Double.*The total') and color ~= 123 then
        return true
    end

    --Hides Vanilla
    if old:match('.* receives the effect of .* Roll.') ~= nil then
        return true
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
                windower.add_to_chat(158,'Lucky roll!')
                luckChat = string.char(31,158).." (Lucky!)"
            elseif rollNum == rollInfo[rollID][16] then
                luckChat = string.char(31,167).." (Unlucky!)"
            end


            if rollNum == 12 and #rollMembers > 0 then
                windower.add_to_chat(1, string.char(31,167)..amountHit..'Bust! '..chat.controls.reset..chars.implies..' '..membersHit..' '..chars.implies..' ('..rollInfo[rollID][rollNum+1]..rollInfo[rollID][14]..')')
            else
                windower.add_to_chat(1, amountHit..membersHit..chat.controls.reset..' '..chars.implies..' '..rollInfo[rollID][1]..' Roll '..chars['circle' .. rollNum]..luckChat..string.char(31,13)..' (+'..rollBonus..')'..BustRate(rollNum, rollActor)..ReportRollInfo(rollID, rollActor))
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
        rollPlusBonus = false
        gearBonus = false
        jobBonus = false
    end

    --I'm handling one roll a bit odd, so I need to deal with it separately.
    --Which is stupid, I know, but look at how I've done most of this.
    --Note: Rostam, Lanun Knife, and Comm. Knife do not check for Augment Path.
    --Item Name         ID      Roll+
    --Rostam            21581   8
    --Lanun Knife       21580   7
    --Regal Necklace    26038   7
    --Comm. Knife       21579   6
    --Barataria Ring    28548   5
    --Merirosvo Ring    28547   3
    if rollName == "Companion\'s" then
        local hpVal = rollVal[1]
        local tpVal = rollVal[2]
        if gearTable[0] == 21581 or rollPlusBonus then
            hpVal =  hpVal + (rollInfo[rollid][17][1]*8)
            tpVal = tpVal  + (rollInfo[rollid][17][2]*8)
        elseif gearTable[0] == 21580 or gearTable[9] == 26038 or rollPlusBonus then
            hpVal =  hpVal + (rollInfo[rollid][17][1]*7)
            tpVal = tpVal  + (rollInfo[rollid][17][2]*7)
            rollPlusBonus = true
        elseif gearTable[0] == 21579 or rollPlusBonus then
            hpVal =  hpVal + (rollInfo[rollid][17][1]*6)
            tpVal = tpVal  + (rollInfo[rollid][17][2]*6)
        elseif gearTable[13] == 28548 or gearTable[14]== 28548 or rollPlusBonus then
            hpVal =  hpVal + (rollInfo[rollid][17][1]*5)
            tpVal = tpVal  + (rollInfo[rollid][17][2]*5)
            rollPlusBonus = true
        elseif gearTable[13] == 28547 or gearTable[14] == 28547 or rollPlusBonus then
            hpVal =  hpVal + (rollInfo[rollid][17][1]*3)
            tpVal = tpVal  + (rollInfo[rollid][17][2]*3)
            rollPlusBonus = true
        end
        return "Pet:"..hpVal.." Regen".." +"..tpVal.." Regain"
    end

    --If there's no Roll Val can't add to it
    if rollVal ~= '?' then
        if gearTable[0] == 21581 or rollPlusBonus then
            rollVal = rollVal + (rollInfo[rollid][17]*8)
            rollPlusBonus = true
        elseif gearTable[0] == 21580 or gearTable[9] == 26038 or rollPlusBonus then
            rollVal = rollVal + (rollInfo[rollid][17]*7)
            rollPlusBonus = true
        elseif gearTable[0] == 21579 or rollPlusBonus then
            rollVal = rollVal + (rollInfo[rollid][17]*6)
            rollPlusBonus = true
        elseif gearTable[13] == 28548 or gearTable[14] == 28548 or rollPlusBonus then
            rollVal = rollVal + (rollInfo[rollid][17]*5)
            rollPlusBonus = true
        elseif gearTable[13] == 28547 or gearTable[14] == 28547 or rollPlusBonus then
            rollVal = rollVal + (rollInfo[rollid][17]*3)
            rollPlusBonus = true
        end
    end

        --Handle Job Bonus
    if (rollInfo[rollid][18][1] ~= nil) then
        --Add Job is in party check
       if jobBonus then
          rollVal = rollVal + rollInfo[rollid][18][2]
        else
          jobBonus = true
          rollVal = rollVal + rollInfo[rollid][18][2]
        end
    end

    --Handle Emp +2, 109 and 119 gear bonus
    if (rollInfo[rollid][19] ~= nil) then
        local bonusVal = (gearTable[rollInfo[rollid][19][1]] == rollInfo[rollid][19][2] or gearTable[rollInfo[rollid][19][1]] == rollInfo[rollid][19][3] or gearTable[rollInfo[rollid][19][1]] ==  rollInfo[rollid][19][4]) and rollInfo[rollid][19][5] or 0
       if gearBonus == true then
          rollVal = rollVal + rollInfo[rollid][19][5]
       else
          gearBonus = true
          rollVal = rollVal + bonusVal
        end
    end

    -- Convert Bolter's to Movement Speed based on 5.0 being 100%
    if (rollName == "Bolter\'s") then
        rollVal = '%.0f':format(100*((5+rollVal) / 5 - 1))
    end

    --Convert Beast/Chaos/Gallant's to % with 2 decimals
    if (rollName == "Chaos") or (rollName == "Gallant\'s") or (rollName == "Beast") then
        rollVal = '%.2f':format(rollVal/1024 * 100)
    end

    return rollVal..rollInfo[rollid][14]
end


function BustRate(rollNum, rollActor)
    if rollNum <= 5 or rollNum == 11 or rollActor ~= player.id or settings.bust == 0 then
        return ''
    end
    return '\7  [Chance to Bust]: ' .. '%.1f':format((rollNum-5)*16.67) .. '%'
end

--Display Lucky/Unlucky #s and check if it's already been reported once.
reportedOnce = false
function ReportRollInfo(rollID, rollActor)
    if rollActor ~= player.id or not settings.luckyinfo then
        return ''
    elseif reportedOnce then
        reportedOnce = false
        return ''
    else
        reportedOnce = true
        return '\7  '..rollInfo[rollID][1]..' Roll\'s Lucky #: ' ..rollInfo[rollID][15]..' Unlucky #: '..rollInfo[rollID][16]
    end
end

--Checks to see if the below event has ran more than twice to enable busting
ranMultiple = false
windower.register_event('outgoing text', function(original, modified)
    cleaned = windower.convert_auto_trans(original)
    modified = original
    if cleaned:match('/jobability \"?Double.*Up') or cleaned:match('/ja \"?Double.*Up') then
        if isLucky and settings.autostopper and rollActor == player.id then
            windower.add_to_chat(159,'Attempting to Doubleup on a Lucky Roll: Re-double up to continue.')
            isLucky = false
            modified = ""
        end
    end

    if settings.fold == 1 and (cleaned:match('/jobability \"?Fold') or cleaned:match('/ja \"?Fold')) then
        local count = 0
        local canBust = false

        --Check to see how many buffs are active
        local cor_buffs = S(player.buffs) * buffId
        canBust = cor_buffs:contains(res.buffs:with('name', 'Bust').id) or cor_buffs:length() > 1
        if canBust or ranMultiple then
            modified = cleaned
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
