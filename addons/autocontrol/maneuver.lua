--[[
Copyright (c) 2013, Ricky Gall
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


local texts = require 'texts'
threshItems = T
    {[16281]=5  -- Buffoon's Collar
    ,[16282]=5  -- Buffoon's Collar +1
    ,[11101]=40 -- Cirque Farsetto +2
    ,[11201]=20 -- Cirque Farsetto +1
    ,[14930]=5  -- Pup. Dastanas
    ,[15030]=5  -- Pup. Dastanas +1
    ,[27960]=5  -- Foire Dastanas
    ,[27981]=5  -- Foire Dastanas +1
    ,[28634]=5  -- Dispersal Mantle
    ,[26933]=40 -- Kara. Farsetto +1
    ,[26932]=40 -- Kara. Farsetto
    }
heat = T{}
heat.Fire = 0
heat.Ice = 0
heat.Wind = 0
heat.Earth = 0
heat.Thunder = 0
heat.Water = 0
heat.Light = 0
heat.Dark = 0
timer = T{}
timer.Fire = 0
timer.Ice = 0
timer.Wind = 0
timer.Earth = 0
timer.Thunder = 0
timer.Water = 0
timer.Light = 0
timer.Dark = 0
threshold = 30
running = 0
maneuver = 1
lastMan = 'none'
autoabils = T{}
autoabils[1688] = {name='Shield Bash', recast=180}
autoabils[1689] = {name='Strobe', recast=30}
autoabils[1690] = {name='Shock Absorber', recast=180}
autoabils[1691] = {name='Flashbulb', recast=45}
autoabils[1692] = {name='Mana Converter', recast=180}
autoabils[1755] = {name='Reactive Shield', recast=65}
autoabils[1765] = {name='Eraser', recast=30}
autoabils[1812] = {name='Economizer', recast=180}
autoabils[1876] = {name='Replicator', recast=60}
autoabils[2489] = {name='Heat Capacitator', recast=90}
autoabils[2490] = {name='Barrage Turbine', recast=180}
autoabils[2491] = {name='Disruptor', recast=60}

str =        'Fire:     \\cs(${colFire|255,255,255})${Fire|0}\\cr - ${timeFire|0}s - ${olFire|0}%'
str = str..'\nIce:      \\cs(${colIce|255,255,255})${Ice|0}\\cr - ${timeIce|0}s - ${olIce|0}%'
str = str..'\nWind:     \\cs(${colWind|255,255,255})${Wind|0}\\cr - ${timeWind|0}s - ${olWind|0}%'
str = str..'\nEarth:    \\cs(${colEarth|255,255,255})${Earth|0}\\cr - ${timeEarth|0}s - ${olEarth|0}%'
str = str..'\nThunder:  \\cs(${colThunder|255,255,255})${Thunder|0}\\cr - ${timeThunder|0}s - ${olThunder|0}%'
str = str..'\nWater:    \\cs(${colWater|255,255,255})${Water|0}\\cr - ${timeWater|0}s - ${olWater|0}%'
str = str..'\nLight:    \\cs(${colLight|255,255,255})${Light|0}\\cr - ${timeLight|0}s - ${olLight|0}%'
str = str..'\nDark:     \\cs(${colDark|255,255,255})${Dark|0}\\cr - ${timeDark|0}s - ${olDark|0}%'

Burden_tb = texts.new(str, settings)

windower.register_event("action", function(act)
    if mjob_id == 18 then
        local abil_ID = act['param']
        local actor_id = act['actor_id']
        local player = T(windower.ffxi.get_player())
        local pet_index = windower.ffxi.get_mob_by_id(windower.ffxi.get_player()['id'])['pet_index']
        
        if act['category'] == 6 and actor_id == player.id and S{136,139,141,142,143,144,145,146,147,148,309,310}:contains(abil_ID) then
            if S{141, 142, 143, 144, 145, 146, 147, 148}:contains(abil_ID) and maneuvertimers then
                windower.send_command('timers c "Maneuver: '..maneuver..'" 60 down')
                if maneuver > 2 then
                    maneuver = 1
                else
                    maneuver = maneuver + 1
                end
            end
            if abil_ID == 141 then
                lastMan = 'Fire'
                heatupdate('Fire',1)
            elseif abil_ID == 142 then
                lastMan = 'Ice'
                heatupdate('Ice',1)
            elseif abil_ID == 143 then
                lastMan = 'Wind'
                heatupdate('Wind',1)
            elseif abil_ID == 144 then
                lastMan = 'Earth'
                heatupdate('Earth',1)
            elseif abil_ID == 145 then
                lastMan = 'Thunder'
                heatupdate('Thunder',1)
            elseif abil_ID == 146 then
                lastMan = 'Water'
                heatupdate('Water',1)
            elseif abil_ID == 147 then
                lastMan = 'Light'
                heatupdate('Light',1)
            elseif abil_ID == 148 then
                lastMan = 'Dark'
                heatupdate('Dark',1)
            elseif abil_ID == 309 then
                windower.send_command('@timers d Overloaded!')
                heatupdate()
            elseif abil_ID == 136 or abil_ID == 310 then -- Activate or Deus Ex Automata
                if settings.burdentracker then
                  Burden_tb:show()
                end
                decay = get_decay()
                activate_burden()
            elseif abil_ID == 139 then
                zero_all()
                windower.send_command('@timers d Overloaded!')
                text_update_loop('stop')
                Burden_tb:hide()
            end
        elseif S{1688,1689,1690,1691,1692,1755,1765,1812,1876,2489,2490,2491}:contains(abil_ID-256) 
               and windower.ffxi.get_mob_by_id(actor_id)['index'] == pet_index 
               and pet_index ~= nil then
                local abil = abil_ID - 256
                windower.send_command('@timers c "'..autoabils[abil].name..'" '..autoabils[abil].recast..' up')
        end
        
    end
end)

function heatupdate(element, maneuver)
    if mjob_id == 18 then
        local first = false
        if maneuver ~= nil and element ~= nil then
            decay = get_decay()
            threshold = get_threshold()
            if heat[element] == 0 then first = true end
            heat[element] = heat[element] + get_jaheat()
            
            if heat[element] >= threshold then
                Burden_tb['col'..element] = '255,0,255'
            else
                Burden_tb['col'..element] = '255,255,255'
            end
            Burden_tb[element] = heat[element]
            timer[element] = math.ceil(heat[element]/decay)*3
            Burden_tb['time'..element] = math.round(timer[element])
            local tempol = (.05+(.01*(heat[element]-threshold)))*100
            if tempol < 0 or heat[element] < threshold then tempol = 0 end
            Burden_tb['ol'..element] = tempol
            if first then timer_start(element) end
        else
            for key,_ in pairs(timer) do
                heat[key] = math.round(heat[key]/2)
                Burden_tb[key] = heat[key]
                timer[key] = math.ceil(heat[key]/decay)*3
                Burden_tb['time'..key] = math.round(timer[key])
                local tempol = (.05+(.01*(heat[key]-threshold)))*100
                if tempol < 0 or heat[key] < threshold then tempol = 0 end
                Burden_tb['ol'..key] = tempol
            end
        end
    end
end

function get_decay()
    if mjob_id == 18 then
        local newdecay
        if T(windower.ffxi.get_mjob_data().attachments):contains(8610) then
            local mans = 0
            local buffs = windower.ffxi.get_player().buffs
            for z = 1, #buffs do
                if buffs[z] == 305 then
                    mans = mans + 1
                end
            end
            if mans == 3 then newdecay = 6
            elseif mans == 2 then newdecay = 5
            elseif mans == 1 then newdecay = 4
            else newdecay = 2 
            end
        else
            newdecay = 1
        end
        return newdecay
    end
end

function get_jaheat()
    if mjob_id == 18 then
        local baseheat = 20
        local updatedheat = 0
        local bonusheat = 0
        if T(windower.ffxi.get_mjob_data()['attachments']):contains(8485) then
            local mans = 0
            local buffs = windower.ffxi.get_player()['buffs']
            for z = 1, #buffs do
                if buffs[z] == 301 then
                    mans = mans + 1
                end
            end
            if mans == 3 then bonusheat = 10
            elseif mans == 2 then bonusheat = 9
            elseif mans == 1 then bonusheat = 8
            else bonusheat = 3 
            end
        end
        updatedheat = baseheat + bonusheat
        return updatedheat
    end
end

function get_threshold()
    if mjob_id == 18 then
        local newthreshold = 0
        local basethreshold = 30
        local items = windower.ffxi.get_items()
        local bonus = 0
        local slots = {'hands', 'body', 'neck', 'back'}
        for i, s in ipairs(slots) do
            if items.equipment[s] ~= 0 then
                local item = threshItems[items.inventory[items.equipment[s]].id] or threshItems[items.wardrobe[items.equipment[s]].id]
                if item ~= nil then
                    bonus = bonus + item
                end
            end
        end
        newthreshold = basethreshold + bonus
        return newthreshold
    end
end

function update_element(ele)
    if mjob_id == 18 then
        heat[ele] = heat[ele] - decay
        if heat[ele] < 0 then heat[ele] = 0 end
        
        if heat[ele] > threshold then
            Burden_tb['col'..ele] = '255,0,255'
        else
            Burden_tb['col'..ele] = '255,255,255'
        end
        Burden_tb[ele] = heat[ele]
        timer[ele] = math.ceil(heat[ele]/decay)*3
        Burden_tb['time'..ele] = math.round(timer[ele])
        local tempol = (.05+(.01*(heat[ele]-threshold)))*100
        if tempol < 0 or heat[ele] < threshold then tempol = 0 end
        Burden_tb['ol'..ele] = tempol
        if heat[ele] > 0 then
            windower.send_command('@wait 3;lua i autocontrol update_element '..ele)
        end
    end
end

function activate_burden()
    if mjob_id == 18 then
        threshold = 30
        for key, _ in pairs(heat) do
            heat[key] = 35
            Burden_tb[key] = 35
            
            if heat[key] > threshold then
                Burden_tb['col'..key] = '255,0,255'
            else
                Burden_tb['col'..key] = '255,255,255'
            end
            timer[key] = math.ceil(35/decay) * 3
            Burden_tb['time'..key] = math.round(timer[key])
            local tempol = (.05+(.01*(heat[key]-threshold)))*100
            if tempol < 0 or heat[key] < threshold then tempol = 0 end
            Burden_tb['ol'..key] = tempol

            windower.send_command('lua i autocontrol timer_start '..key)
        end
        if running ~= 1 then text_update() end
    end
end

function text_update()
    if mjob_id == 18 then
        Burden_tb:update()
        windower.send_command('@wait 1;lua i autocontrol text_update_loop start')
        running = 1
    end
end

function text_update_loop(str)
    if mjob_id == 18 then
        if str == 'start' and running == 1 and not petlessZones:contains(windower.ffxi.get_info().zone) then
            for key, _ in pairs(heat) do
                timer[key] = timer[key] - 1
                if timer[key] < 1 then timer[key] = 0 end
                
                if heat[key] > threshold then
                    Burden_tb['col'..key] = '255,0,255'
                else
                    Burden_tb['col'..key] = '255,255,255'
                end
                Burden_tb['time'..key] = timer[key]
                local tempol = (.05+(.01*(heat[key]-threshold)))*100
                if tempol < 0 or heat[key] < threshold then tempol = 0 end
                Burden_tb['ol'..key] = tempol
            end
            Burden_tb:update()
            
            local player_mob = windower.ffxi.get_mob_by_id(windower.ffxi.get_player()['id'])
            if player_mob then
                if player_mob['pet_index']
                   and player_mob['pet_index'] ~= 0 then 
                    windower.send_command('@wait 1;lua i autocontrol text_update_loop start')
                    running = 1
                end
            end
        elseif str == 'stop' then running = 0 end
    end
end

windower.register_event('gain buff', function(id)
    if mjob_id == 18 then
        if id == 305 then 
            decay = get_decay()
        end
        if id == 299 then
            windower.send_command('@timers c Overloaded! '..heat[lastMan]-threshold..' down')
        end
    end
end)

windower.register_event('lose buff', function(id)
    if mjob_id == 18 then
        if id == 305 then 
            decay = get_decay()
        end
        if id == 299 then
            windower.send_command('@timers d Overloaded!')
        end
    end
end)

function timer_start(ele)
    if mjob_id == 18 then
        windower.send_command('@wait 3;lua i autocontrol update_element '..ele)
    end
end

windower.register_event('job change', function(mj)
    mjob_id = mj
    if mjob_id ~= 18 or petlessZones:contains(windower.ffxi.get_info().zone) then 
        Burden_tb:hide()
        text_update_loop('stop')
    end
end)

function zero_all()
    for key,val in pairs(heat) do
        Burden_tb[key] = 0
        timer[key] = 0
        Burden_tb['time'..key] = 0 
        Burden_tb['col'..key] = '255,255,255'
        Burden_tb['ol'..key] = tempol
    end
end

function zone_check(to)
    to = tonumber(to)
    if mjob_id == 18 then
        if petlessZones:contains(to) then 
            text_update_loop('stop')
            zero_all()
            Burden_tb:hide()
            return
        else
            local player_mob = windower.ffxi.get_mob_by_target('me')
            if player_mob then
                if player_mob.pet_index
                   and player_mob.pet_index ~= 0 then 
                     if settings.burdentracker then
                       Burden_tb:show()
                     end
                    activate_burden()
                end
            else
                windower.send_command('@wait 10;lua i autocontrol zone_check ' .. to)
            end
        end
    end
end

windower.register_event('zone change', zone_check)
    
windower.register_event('time change', function()
    if mjob_id == 18 then
        decay = get_decay()
    end
end)
