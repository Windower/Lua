--[[
Copyright © 2017, Sammeh of Quetzalcoatl
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of DistancePlus nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sammeh BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'DistancePlus'
_addon.author = 'Sammeh'
_addon.version = '1.3.0.10'
_addon.command = 'dp'

-- 1.3.0.2 Fixed up nil's per recommendation on submission to Windower 
-- 1.3.0.3 Replaced all tabs for 4 spaces to normalize indentations.
-- 1.3.0.4 Moving some expensive functions to on-load vs per-render.
-- 1.3.0.5 Implement config plugin.
-- 1.3.0.6 Fix ability list on job change.
-- 1.3.0.7 Implement ranged fix w/o ja_distance
-- 1.3.0.8 Wasn't refreshing 'self' upon job change.  Fixed up spacing.
-- 1.3.0.9 Fixup MaxDecimal from config plugin addition.
-- 1.3.0.10  Changed slightly some variable scopes for lower mem usage.

require('tables')

res = require 'resources'
config = require('config')
texts = require('texts')

defaults = {}
defaults.main = {}
defaults.main.pos = {}
defaults.main.pos.x = -178
defaults.main.pos.y = 21
defaults.main.text = {}
defaults.main.text.font = 'Arial'
defaults.main.text.size = 14
defaults.main.flags = {}
defaults.main.flags.right = true

defaults.pettxt = {}
defaults.pettxt.pos = {}
defaults.pettxt.pos.x = -178
defaults.pettxt.pos.y = 45
defaults.pettxt.text = {}
defaults.pettxt.text.font = 'Arial'
defaults.pettxt.text.size = 14
defaults.pettxt.flags = {}
defaults.pettxt.flags.right = true


defaults.abilitytxt = {}
defaults.abilitytxt.pos = {}
defaults.abilitytxt.pos.x = -80
defaults.abilitytxt.pos.y = 45
defaults.abilitytxt.text = {}
defaults.abilitytxt.text.font = 'Arial'
defaults.abilitytxt.text.size = 10
defaults.abilitytxt.flags = {}
defaults.abilitytxt.flags.right = true

defaults.heighttxt = {}
defaults.heighttxt.pos = {}
defaults.heighttxt.pos.x = -238
defaults.heighttxt.pos.y = 21
defaults.heighttxt.text = {}
defaults.heighttxt.text.font = 'Arial'
defaults.heighttxt.text.size = 14
defaults.heighttxt.flags = {}
defaults.heighttxt.flags.right = true

height_upper_threshold = 8.5
height_lower_threshold = -7.5


settings = config.load(defaults)
distance = texts.new('${value||%.2f}', settings.main)
petdistance = texts.new('${value||%.2f}', settings.pettxt)
abilities = texts.new('${value}', settings.abilitytxt)
height = texts.new('${value||%.2f}', settings.heighttxt)


option = "Default"
showabilities = false
showheight = false

function displayabilities(distance,master_pet_distance,s,t)
    local range_mult = {
        [2] = 1.55,
        [3] = 1.490909,
        [4] = 1.44,
        [5] = 1.377778,
        [6] = 1.30,
        [7] = 1.15,
        [8] = 1.25,
        [9] = 1.377778,
        [10] = 1.45,
        [11] = 1.454545454545455,
        [12] = 1.666666666666667,
    }
    local list = 'Abilities:\n'
    if abilitylist then 
      for key,ability in pairs(abilitylist) do
        ability_en = res.job_abilities[ability].name
        ability_type = res.job_abilities[ability].type
        ability_targets = res.job_abilities[ability].targets
        ability_distance = res.job_abilities[ability].range
        if distance and ability_en and (ability_type == 'JobAbility' or ability_type == 'PetCommand' or ability_type == 'BloodPactRage' or ability_type == 'BloodPactWard' or ability_type == 'Monster' or ability_type == 'Step') and ability_en ~= "Flourishes II" then 
            if ability_targets.Self ~= true then
                if distance < (t.model_size + ability_distance * range_mult[ability_distance] + s.model_size) and distance ~= 0 then 
                    list = list..'\\cs(0,255,0)'..ability_en..'\\cs(255,255,255)'..'\n'
                else
                    list = list..'\\cs(255,255,255)'..ability_en..'\n'
                end
            --[[ too much crap on screen!!! 
            elseif ability_targets.Self == true and (ability_type == 'Monster' or ability_type == 'PetCommand') and master_pet_distance then
                if master_pet_distance < (4 + s.model_size + t.model_size) and distance ~= 0 then 
                    list = list..'\\cs(0,255,0)'..ability_en..'\\cs(255,255,255)'..'\n'
                else
                    list = list..'\\cs(255,255,255)'..ability_en..'\n'
                end
            --]]
            end
        end
      end
    end
    abilities.value = list
    abilities:visible(showabilities)
end

function check_job()
    windower.add_to_chat(8,'*****DP Job Selection:'..self.main_job..'*****')
    if self.main_job == 'RDM' or self.main_job == 'BLM' or self.main_job == 'GEO' or self.main_job == 'SCH' or self.main_job == 'WHM' or self.main_job == 'BRD'  then
        option = "Magic"
        windower.add_to_chat(8,'Mode: Magic.')
        windower.add_to_chat(8,' White = Can not cast.')
        windower.add_to_chat(8,' Green = Casting Range')
        MaxDistance = 20     
    elseif self.main_job == 'COR' then
        windower.add_to_chat(8,'Mode: Gun.')
        windower.add_to_chat(8,' White  = Can not shoot.')
        windower.add_to_chat(8,' Yellow = Ranged Attack Capable (No Buff)')
        windower.add_to_chat(8,' Green  = Shoots Squarely (Good)')
        windower.add_to_chat(8,' Blue   = True Shot (Best)')
        option = "Gun"
        MaxDistance = 25
    elseif self.main_job == 'RNG' then
        windower.add_to_chat(8,'RANGER should do //dp Bow, //dp XBow, or //dp Gun')
        windower.add_to_chat(8,'Mode: Default.')
        option = "Default"
        MaxDistance = 25
    elseif self.main_job == 'NIN' then
        option = "Ninjutsu"
        windower.add_to_chat(8,'Mode: Ninjutsu.')
        windower.add_to_chat(8,' White = Can not cast.')
        windower.add_to_chat(8,' Green = Casting Range')
    else
        windower.add_to_chat(8,'Mode: Default.')
        option = "Default"
        MaxDistance = 25
    end
end


windower.register_event('prerender', function()
    local t = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
    local s = windower.ffxi.get_mob_by_target('me')
    if windower.ffxi.get_mob_by_target('pet') then
        pet = windower.ffxi.get_mob_by_target('pet')
    else
        pet = nil
    end
    if pet and self.main_job ~= 'DRG' then
        if self.main_job == 'BST' then
            local PetMaxDistance = 4
            local pettargetdistance = PetMaxDistance + pet.model_size + s.model_size
            if pet.model_size > 1.6 then 
                pettargetdistance = PetMaxDistance + pet.model_size + s.model_size + 0.1
            end
            if pet.distance:sqrt() < pettargetdistance then
                petdistance:color(0,255,0) -- Green
            else
                petdistance:color(255,255,255) -- White
            end
        --else
        -- may add some stuff here for SMN    
        end
        petdistance.value = pet.distance:sqrt()
        petdistance:visible(pet ~= nil)
    else 
        petdistance:visible(false)
    end
    if t then
        if pet then 
            displayabilities(t.distance:sqrt(),pet.distance:sqrt(),s,t)
        else
            displayabilities(t.distance:sqrt(),nil,s,t)
        end
        if t.distance:sqrt() == 0 then
            distance:color(255,255,255)
        else
        if option == 'Default' then
            distance:color(255,255,255)
        elseif option == 'Bow' then
            MaxDistance = 25
            trueshotmax = s.model_size + t.model_size + 9.5199
            trueshotmin = s.model_size + t.model_size + 6.02
            squareshot_far_max = s.model_size + t.model_size + 14.5199
            squareshot_close_min = s.model_size + t.model_size + 4.62
            if t.model_size > 1.6 then 
                trueshotmax = trueshotmax + 0.1
                trueshotmin = trueshotmin + 0.1
                squareshot_far_max = squareshot_far_max + 0.1
                squareshot_close_min = squareshot_close_min + 0.1
            end
            if t.distance:sqrt() < MaxDistance and (t.distance:sqrt() > squareshot_far_max or t.distance:sqrt() < squareshot_close_min) then 
                distance:color(255,255,0) -- Yellow (No Ranged Boost)
            elseif (t.distance:sqrt() <= squareshot_far_max and t.distance:sqrt() > trueshotmax) or (t.distance:sqrt() < trueshotmin and t.distance:sqrt() >= squareshot_close_min) then 
                distance:color(0,255,0) -- Green   (Square Shot)
            elseif (t.distance:sqrt() <= trueshotmax and t.distance:sqrt() >= trueshotmin) then
                distance:color(0,0,255) -- Blue  (Strikes True)
            else 
                distance:color(255,255,255) -- White  (Can't Shoot)
            end
        elseif option == 'Xbow' then
            MaxDistance = 25
            trueshotmax = s.model_size + t.model_size + 8.3999
            trueshotmin = s.model_size + t.model_size + 5.0007
            squareshot_far_max = s.model_size + t.model_size + 11.7199
            squareshot_close_min = s.model_size + t.model_size + 3.6199
            if t.model_size > 1.6 then 
                trueshotmax = trueshotmax + 0.1
                trueshotmin = trueshotmin + 0.1
                squareshot_far_max = squareshot_far_max + 0.1
                squareshot_close_min = squareshot_close_min + 0.1
            end
            if t.distance:sqrt() < MaxDistance and (t.distance:sqrt() > squareshot_far_max or t.distance:sqrt() < squareshot_close_min) then 
                distance:color(255,255,0) -- Yellow (No Ranged Boost)
            elseif (t.distance:sqrt() <= squareshot_far_max and t.distance:sqrt() > trueshotmax) or (t.distance:sqrt() < trueshotmin and t.distance:sqrt() >= squareshot_close_min) then 
                distance:color(0,255,0) -- Green   (Square Shot)
            elseif (t.distance:sqrt() <= trueshotmax and t.distance:sqrt() >= trueshotmin) then
                distance:color(0,0,255) -- Blue  (Strikes True)
            else 
                distance:color(255,255,255) -- White  (Can't Shoot)
            end
        elseif option == 'Gun' then
            MaxDistance = 25
            trueshotmax = s.model_size + t.model_size + 4.3189
            trueshotmin = s.model_size + t.model_size + 3.0209
            squareshot_far_max = s.model_size + t.model_size + 6.8199
            squareshot_close_min = s.model_size + t.model_size + 2.2219
            if t.model_size > 1.6 then 
                trueshotmax = trueshotmax + 0.1
                trueshotmin = trueshotmin + 0.1
                squareshot_far_max = squareshot_far_max + 0.1
                squareshot_close_min = squareshot_close_min + 0.1
            end
            if t.distance:sqrt() < MaxDistance and (t.distance:sqrt() > squareshot_far_max or t.distance:sqrt() < squareshot_close_min) then 
                distance:color(255,255,0) -- Yellow (No Ranged Boost)
            elseif (t.distance:sqrt() <= squareshot_far_max and t.distance:sqrt() > trueshotmax) or (t.distance:sqrt() < trueshotmin and t.distance:sqrt() >= squareshot_close_min) then 
                distance:color(0,255,0) -- Green   (Square Shot)
            elseif (t.distance:sqrt() <= trueshotmax and t.distance:sqrt() >= trueshotmin) then
                distance:color(0,0,255) -- Blue  (Strikes True)
            else 
                distance:color(255,255,255) -- White  (Can't Shoot)
            end
        elseif option == 'Magic' then
            MaxDistance = 20
            if t.model_size > 2 then 
                MaxDistance = MaxDistance + 0.1
            elseif  math.floor(t.model_size * 10) == 44 then 
                MaxDistance = 20.0666
            elseif math.floor(t.model_size * 10) == 53 then 
                MaxDistance = 20
            end
            targetdistance = MaxDistance + t.model_size + s.model_size
            if t.distance:sqrt() < targetdistance then
                distance:color(0,255,0) -- Green
            else
                distance:color(255,255,255) -- White can't Cast
            end
        elseif option == 'Ninjutsu' then
            MaxDistance = 16.1
            if t.model_size > 2 then 
                MaxDistance = MaxDistance + 0.1
            elseif  math.floor(t.model_size * 10) == 44 then 
                MaxDistance = 16.1
            elseif math.floor(t.model_size * 10) == 53 then 
                MaxDistance = 16.1
            end
            targetdistance = MaxDistance + t.model_size + s.model_size
            if t.distance:sqrt() < targetdistance then
                distance:color(0,255,0) -- Green
            else
                distance:color(255,255,255) -- White can't Cast
            end
        else
              distance:color(255,255,255)
        end
        end
        distance.value = t.distance:sqrt()
        
        height.value = t.z - s.z
        if (t.z - s.z) >= height_upper_threshold or (t.z - s.z) <= height_lower_threshold then
            height:color(0,255,0) -- green
        else
            height:color(255,0,0) -- red
        end
        
    end
     distance:visible(t ~= nil)
    height:visible(t ~= nil and showheight)
end)


windower.register_event('addon command', function(command)
    if command:lower() == 'help' then
        windower.add_to_chat(8,'DistancePlus: Valid Modes are //DP <command>:')
        windower.add_to_chat(8,' Gun, Bow, Xbow, Magic, JA')
        windower.add_to_chat(8,' MaxDecimal    - Expand MaxDecimal for Max Accuracy. DP Calculates to the Thousand')
        windower.add_to_chat(8,' Default     - Reset to Defaults')
        windower.add_to_chat(8,' Pets         - Not a command.  If a pet is out another dialog will pop up with distance between you and Pet.')
    elseif command:lower() == 'gun' then
        windower.add_to_chat(8,'Mode: Gun.')
        windower.add_to_chat(8,' White  = Can not shoot.')
        windower.add_to_chat(8,' Yellow = Ranged Attack Capable (No Buff)')
        windower.add_to_chat(8,' Green  = Shoots Squarely (Good)')
        windower.add_to_chat(8,' Blue   = True Shot (Best)')
        option = "Gun"
    elseif command:lower() == 'xbow' then
        option = "Xbow"
        windower.add_to_chat(8,'Mode: XBOW.')
        windower.add_to_chat(8,' White  = Can not shoot.')
        windower.add_to_chat(8,' Yellow = Ranged Attack Capable (No Buff)')
        windower.add_to_chat(8,' Green  = Shoots Squarely (Good)')
        windower.add_to_chat(8,' Blue   = True Shot (Best)')
    elseif command:lower() == 'bow' then
        option = "Bow"
        windower.add_to_chat(8,'Mode: BOW.')
        windower.add_to_chat(8,' White  = Can not shoot.')
        windower.add_to_chat(8,' Yellow = Ranged Attack Capable (No Buff)')
        windower.add_to_chat(8,' Green  = Shoots Squarely (Good)')
        windower.add_to_chat(8,' Blue   = True Shot (Best)')
    elseif command:lower() == 'magic' then
        option = "Magic"
        windower.add_to_chat(8,'Mode: Magic.')
        windower.add_to_chat(8,' White = Can not cast.')
        windower.add_to_chat(8,' Green = Casting Range')
    elseif command:lower() == 'ninjutsu' then
        option = "Ninjutsu"
        windower.add_to_chat(8,'Mode: Ninjutsu.')
        windower.add_to_chat(8,' White = Can not cast.')
        windower.add_to_chat(8,' Green = Casting Range')
    elseif command:lower() == 'default' then
       windower.add_to_chat(8,'Mode: Default.')
       option = "Default"
       MaxDistance = 25
       distance:visible(false)
       distance = texts.new('${value||%.2f}', settings.main)
    elseif command:lower() == 'maxdecimal' then
       distance:visible(false)
       distance = texts.new('${value||%.12f}', settings.main)
    elseif command:lower() == 'abilitylist' or command:lower() == 'ja' then
        if showabilities then
            showabilities = false
        else
            windower.add_to_chat(8,'Mode: JA.')
            showabilities = true
            displayabilities()
        end
    elseif command:lower() == 'height' then
        showheight = true
    end
end)

windower.register_event('job change', function()
    coroutine.sleep(2) -- sleeping because jobchange too fast doesn't show new abilities
    self = windower.ffxi.get_player()
    check_job()
    abilitylist = windower.ffxi.get_abilities().job_abilities
    abilities:visible(false)
    abilities.value = ""
    displayabilities()
end)

windower.register_event('load', function()
    if windower.ffxi.get_player() then 
        coroutine.sleep(2) -- sleeping because jobchange too fast doesn't show new abilities
        self = windower.ffxi.get_player()
        check_job()
        abilitylist = windower.ffxi.get_abilities().job_abilities
        displayabilities()
    end
end)


windower.register_event('login', function()
    coroutine.sleep(2) -- sleeping because jobchange too fast doesn't show new abilities
    self = windower.ffxi.get_player()
    check_job()
    abilitylist = windower.ffxi.get_abilities().job_abilities
    displayabilities()
end)
