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
_addon.version = '2.0.2'
_addon.command = 'dp'

require('tables')

local res = require 'resources'
local config = require('config')
local texts = require('texts')

-- Global Variables
local self = nil
local abilitylist = nil
local MaxDistance = 25
local option = "Default"
local showabilities = false
local showheight = false
local height_upper_threshold = 8.5
local height_lower_threshold = -7.5
local decimal_format = "%.2f"

-- Performance Variables
local last_update = 0
local update_interval = 0.1 -- Updates 10 times a second (0.1s delay)

-- Color Constants for Text Objects (RGB)
local COLOR_BLUE   = {0, 191, 255}
local COLOR_GREEN  = {0, 255, 0}
local COLOR_YELLOW = {255, 255, 0}
local COLOR_WHITE  = {255, 255, 255}
local COLOR_RED    = {255, 0, 0}

-- Static Range Multipliers
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

-- Ranged Weapon Data
local RangedData = {
    Gun = {
        trueshot_max = 4.3189,
        trueshot_min = 3.0209,
        square_max   = 6.8199,
        square_min   = 2.2219
    },
    Bow = {
        trueshot_max = 9.5199,
        trueshot_min = 6.02,
        square_max   = 14.5199,
        square_min   = 4.62
    },
    Xbow = {
        trueshot_max = 8.3999,
        trueshot_min = 5.0007,
        square_max   = 11.7199,
        square_min   = 3.6199
    }
}

local defaults = {}
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

local settings = config.load(defaults)
local distance = texts.new('${value}', settings.main) 
local petdistance = texts.new('${value||%.2f}', settings.pettxt)
local abilities = texts.new('${value}', settings.abilitytxt)
local height = texts.new('${value||%.2f}', settings.heighttxt)

function displayabilities(dist, master_pet_distance, s, t)
    -- OPTIMIZATION: Using a table to build strings is much faster than '..' concatenation
    local list_lines = {} 
    table.insert(list_lines, 'Abilities:\n')
    
    if abilitylist then 
      for key, ability in pairs(abilitylist) do
        local ability_en = res.job_abilities[ability].en
        local ability_name = res.job_abilities[ability].name
        local ability_type = res.job_abilities[ability].type
        local ability_targets = res.job_abilities[ability].targets
        local ability_distance = res.job_abilities[ability].range
        
        if dist and ability_name and (ability_type == 'JobAbility' or ability_type == 'PetCommand' or ability_type == 'BloodPactRage' or ability_type == 'BloodPactWard' or ability_type == 'Monster' or ability_type == 'Step') and ability_en ~= "Flourishes II" then 
            if ability_targets.Self ~= true then
                if dist < (t.model_size + ability_distance * range_mult[ability_distance] + s.model_size) and dist ~= 0 then 
                    table.insert(list_lines, '\\cs(0,255,0)'..ability_name..'\\cs(255,255,255)\n')
                else
                    table.insert(list_lines, '\\cs(255,255,255)'..ability_name..'\n')
                end
            end
        end
      end
    end
    abilities.value = table.concat(list_lines) -- Combine all lines at once
    abilities:visible(showabilities)
end

function check_job()
    if not self then return end
    windower.add_to_chat(8,'*****Distance Plus Job Selection: '..self.main_job..'*****')
    
    if self.main_job == 'RDM' or self.main_job == 'BLM' or self.main_job == 'GEO' or self.main_job == 'SCH' or self.main_job == 'WHM' or self.main_job == 'BRD'  then
        option = "Magic"
        windower.add_to_chat(8,'[Distance Plus] Mode: Magic Distances ON. ')
        MaxDistance = 20     
    elseif self.main_job == 'COR' then
        windower.add_to_chat(8,'[Distance Plus] Mode: Gun - Ranged Distances ON. - Refer to Legend //dp')
        option = "Gun"
        MaxDistance = 25
    elseif self.main_job == 'RNG' then
        windower.add_to_chat(8,'RANGER: Use //dp Bow, //dp XBow, or //dp Gun')
        windower.add_to_chat(8,'[Distance Plus] Mode: Default.')
        option = "Default"
        MaxDistance = 25
    elseif self.main_job == 'NIN' then
        option = "Ninjutsu"
        windower.add_to_chat(8,'[Distance Plus] Mode: Ninjutsu.')
    else
        windower.add_to_chat(8,'[Distance Plus] Mode: Default.')
        option = "Default"
        MaxDistance = 25
    end
end

-- Helper Function: Returns Color AND Status Text
local function get_ranged_status(mode, dist, t_size, s_size)
    local data = RangedData[mode]
    if not data then return COLOR_WHITE, "" end

    local model_offset = t_size + s_size
    local correction = (t_size > 1.6) and 0.1 or 0
    
    local ts_max = model_offset + data.trueshot_max + correction
    local ts_min = model_offset + data.trueshot_min + correction
    local sq_max = model_offset + data.square_max + correction
    local sq_min = model_offset + data.square_min + correction
    
    if dist < sq_min then
         return COLOR_RED, "Critical Penalty"  
    elseif dist > sq_max and dist < MaxDistance then
         return COLOR_YELLOW, "Distance Penalty" 
    elseif (dist <= sq_max and dist > ts_max) or (dist < ts_min and dist >= sq_min) then
        return COLOR_GREEN, "Square Shot"
    elseif (dist <= ts_max and dist >= ts_min) then
        return COLOR_BLUE, "True Shot"
    else
        return COLOR_WHITE, "Out of Range"
    end
end

windower.register_event('prerender', function()
    -- PERFORMANCE THROTTLE: Only run this logic 10 times a second
    if os.clock() - last_update < update_interval then
        return
    end
    last_update = os.clock()

    local t = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
    local s = windower.ffxi.get_mob_by_target('me')
    local pet = windower.ffxi.get_mob_by_target('pet') 

    if pet and self.main_job ~= 'DRG' then
        if self.main_job == 'BST' then
            local PetMaxDistance = 4
            local pettargetdistance = PetMaxDistance + pet.model_size + s.model_size
            if pet.model_size > 1.6 then 
                pettargetdistance = pettargetdistance + 0.1
            end
            if pet.distance:sqrt() < pettargetdistance then
                petdistance:color(COLOR_GREEN[1], COLOR_GREEN[2], COLOR_GREEN[3])
            else
                petdistance:color(COLOR_WHITE[1], COLOR_WHITE[2], COLOR_WHITE[3])
            end
        end
        petdistance.value = pet.distance:sqrt()
        petdistance:visible(true)
    else 
        petdistance:visible(false)
    end
    
    if t then
        local dist = t.distance:sqrt()
        
        if pet then 
            displayabilities(dist, pet.distance:sqrt(), s, t)
        else
            displayabilities(dist, nil, s, t)
        end
        
        local status_text = ""
        
        if dist == 0 then
            distance:color(COLOR_WHITE[1], COLOR_WHITE[2], COLOR_WHITE[3])
        else
            if option == 'Default' then
                distance:color(COLOR_WHITE[1], COLOR_WHITE[2], COLOR_WHITE[3])
            
            elseif RangedData[option] then
                MaxDistance = 25
                local rgb, text = get_ranged_status(option, dist, t.model_size, s.model_size)
                distance:color(rgb[1], rgb[2], rgb[3])
                status_text = text
                
            elseif option == 'Magic' or option == 'Ninjutsu' then
                local limit = (option == 'Magic') and 20 or 16.1
                if t.model_size > 2 then limit = limit + 0.1
                elseif math.floor(t.model_size * 10) == 44 then limit = (option=='Magic') and 20.0666 or 16.1
                elseif math.floor(t.model_size * 10) == 53 then limit = (option=='Magic') and 20 or 16.1
                end
                
                if dist < (limit + t.model_size + s.model_size) then
                    distance:color(COLOR_GREEN[1], COLOR_GREEN[2], COLOR_GREEN[3])
                else
                    distance:color(COLOR_WHITE[1], COLOR_WHITE[2], COLOR_WHITE[3])
                end
            else
                distance:color(COLOR_WHITE[1], COLOR_WHITE[2], COLOR_WHITE[3])
            end
        end
        
        if status_text ~= "" then
            distance.value = string.format(decimal_format .. " %s", dist, status_text)
        else
            distance.value = string.format(decimal_format, dist)
        end
        
        height.value = t.z - s.z
        if (t.z - s.z) >= height_upper_threshold or (t.z - s.z) <= height_lower_threshold then
            height:color(COLOR_GREEN[1], COLOR_GREEN[2], COLOR_GREEN[3])
        else
            height:color(COLOR_RED[1], COLOR_RED[2], COLOR_RED[3])
        end
        
    end
    distance:visible(t ~= nil)
    height:visible(t ~= nil and showheight)
end)

windower.register_event('addon command', function(command)
    command = command or 'help'
    local cmd = command:lower()

    if cmd == 'help' then
        windower.add_to_chat(207, 'Distance Plus Commands:')
        windower.add_to_chat(207, '  //dp gun|bow|xbow : Ranged modes')
        windower.add_to_chat(207, '  //dp magic|nin    : Caster modes')
        windower.add_to_chat(207, '  //dp default      : Reset to standard')
        windower.add_to_chat(207, '  //dp ja      : Show Job Abilities available against target')
        windower.add_to_chat(207, '  //dp height  : Vertical Distance')
        windower.add_to_chat(207, '  ')		
        windower.add_to_chat(207, '  --- Ranged Color Legend ---')
        windower.add_to_chat(207, '  Blue:   True Shot (Bonus Damage!)') 
        windower.add_to_chat(158, '  Green:  Square Shot (Normal Damage)') 
        windower.add_to_chat(36,  '  Yellow: Distance Penalty (Too Far)') 
        windower.add_to_chat(167, '  Red:    Critical Penalty (Too Close!)')
        windower.add_to_chat(8,   '  White:  Out of Range') 
        windower.add_to_chat(207, '  ')		
        windower.add_to_chat(207, '  --- Magic Color Legend ---')
        windower.add_to_chat(158, '  Green:  Within Range to Cast')
        windower.add_to_chat(8,   '  White:  Out of Range') 
        windower.add_to_chat(207, '  ')
        windower.add_to_chat(207, '  --- Weapon Skill Mechanics ---')
        windower.add_to_chat(8,   '  Physical WS (E.g. Last Stand): Needs True Shot (Blue)')
        windower.add_to_chat(8,   '  Magical WS (E.g. Wildfire):   Ignores Distance Rules')
        windower.add_to_chat(207, '  ')
        
    elseif cmd == 'gun' then
        option = "Gun"
        windower.add_to_chat(8,'[Distance Plus] Mode: Gun - Refer to Ranged Color Legend //dp')
    elseif cmd == 'bow' then
        option = "Bow"
        windower.add_to_chat(8,'[Distance Plus] Mode: Bow - Refer to Ranged Color Legend //dp')
    elseif cmd == 'xbow' then
        option = "Xbow"
        windower.add_to_chat(8,'[Distance  Plus] Mode: Xbow - Refer to Ranged Color Legend //dp')
    elseif cmd == 'magic' then
        option = "Magic"
        windower.add_to_chat(8,'[Distance Plus] Mode: Magic - Refer to Magic Color Legend //dp')
    elseif cmd == 'nin' or cmd == 'ninjutsu' then
        option = "Ninjutsu"
        windower.add_to_chat(8,'[Distance Plus] Mode: Ninjutsu')
    elseif cmd == 'default' then
       option = "Default"
       MaxDistance = 25
       decimal_format = "%.2f"
       windower.add_to_chat(8,'[Distance Plus] Mode: Default reset.')
    elseif cmd == 'maxdecimal' then
       decimal_format = "%.12f"
       windower.add_to_chat(8,'[Distance Plus] Max Decimals enabled.')
    elseif cmd == 'abilitylist' or cmd == 'ja' then
        showabilities = not showabilities
        if showabilities then
            windower.add_to_chat(8,'[Distance Plus] Job Abilities: ON')
            displayabilities()
        else
            windower.add_to_chat(8,'[Distance Plus] Job Abilities: OFF')
            abilities:visible(false)
        end
    elseif cmd == 'height' then
        showheight = not showheight
        if showheight then
            windower.add_to_chat(8,'[Distance Plus] Height Indicator: ON')
        else
            windower.add_to_chat(8,'[Distance Plus] Height Indicator: OFF')
            height:visible(false)
        end
    else
        windower.add_to_chat(8,'[Distance Plus] Unknown command. Type //dp help for list.')
    end
end)

windower.register_event('job change', function()
    coroutine.sleep(2)
    self = windower.ffxi.get_player()
    check_job()
    abilitylist = windower.ffxi.get_abilities().job_abilities
    abilities:visible(false)
    abilities.value = ""
    displayabilities()
end)

windower.register_event('load', function()
    if windower.ffxi.get_player() then 
        coroutine.sleep(2)
        self = windower.ffxi.get_player()
        check_job()
        abilitylist = windower.ffxi.get_abilities().job_abilities
        displayabilities()
    end
end)


windower.register_event('login', function()
    coroutine.sleep(2)
    self = windower.ffxi.get_player()
    check_job()
    abilitylist = windower.ffxi.get_abilities().job_abilities
    displayabilities()
end)