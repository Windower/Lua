--Copyright (c) 2013, Krizz
--All rights reserved.
--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:
--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of salvage2 nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.
--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL KRIZZ BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'salvage2'
_addon.version = 0.1
_addon.command = 's2'
_addon.author = 'Bahamut.Krizz'

require('tables')
require('strings')
require('maths')
require('logger')
texts = require ('texts')
config = require('config')
-----------------------------


--variables
pathos_ident = {'Main Weapon/Sub-Weapon restriction', 'Ranged Weapon/Ammo restriction', 'Head/Neck equipment restriction', 'Body equipment restriction', 'Hand equipment restriction', 'Earrings/Rings restriction', 'Back/Waist equipment restriction', 'Leg/Foot equipment restriction', 'Support Job restriction', 'Job Abilities restriction', 'Spellcasting restriction', 'Max HP Down', 'Max MP Down', 'STR Down', 'DEX Down', 'AGI Down', 'MND Down', 'INT Down', 'CHR Down', 'VIT Down'}
pathos_short = {'Weapon', 'Ranged', 'Head/Neck', 'Body', 'Hand', 'Earrings/Rings', 'Back/Waist', 'Leg/Foot', 'Support Job', 'Job Abilities', 'Spellcasting', 'MaxHP', 'MaxMP', 'STR', 'DEX', 'AGI', 'MND', 'INT', 'CHR', 'VIT'}
salvage_zones = S{73, 74, 75, 76}

defaults = {}
defaults.pos = {}
defaults.pos.x = 1000
defaults.pos.y = 150
defaults.color = {}
defaults.color.alpha = 200
defaults.color.red = 200
defaults.color.green = 200
defaults.color.blue = 200
defaults.bg = {}
defaults.bg.alpha = 200
defaults.bg.red = 30
defaults.bg.green = 30
defaults.bg.blue = 30

settings = config.load(defaults)
salvage_box2 = texts.new('No pathos', settings)

windower.register_event('addon command',function (...)
local params = {...};
    if #params < 1 then
        return
    end
    if params[1] then
        if params[1]:lower() == "help" then
            print('Salvage2 available commands:')
            print('s2 help : Shows this help message')
            print('s2 pos <x> <y> : Positions the list')
            print('s2 [hide/show] : Hides the box')
            print('s2 timer [start/stop] : Starts or stops the zone timer')
            print('s2 remove <pathos> : Removes the pathos from the remaining list')
        elseif params[1]:lower() == "pos" then
            if params[3] then
                local posx, posy = tonumber(params[2]), tonumber(params[3])
                windower.text.set_location('salvage_box2', posx, posy)
            end
        elseif params[1]:lower() == "hide" then
            salvage_box2:hide()
        elseif params[1]:lower() == "show" then
            salvage_box2:show()
        elseif params[1]:lower() == "timer" then
            if params[2] == "start" then
                windower.send_command('timers c Remaining 6000 up')
            elseif params[2] == "stop" then
                windower.send_command('timers d Remaining')
            end
        elseif params[1]:lower() == "debug" then
            if params[2]:lower() == "start" then
                    windower.send_command('timers c Remaining 6000 up')
                    settings_create()
                    salvage_box2:show()
                    initialize()
            elseif params[2]:lower() == "stop" then
                    windower.send_command('timers d Remaining')
                    salvage_box2:hide()
            end
        elseif params[1]:lower() == "remove" then
            for i=1, #pathos_short  do
                if pathos_short[i]:lower() == params[2]:lower() then
                    pathos_ident[pathos_ident[i]] = 0
                    initialize()
                end
            end
        end
    end
end)

windower.register_event('login', function(name)
    player = name
end)

function settings_create()
    --    get player's name
    player = windower.ffxi.get_player()['name']
    --  set all pathos as needed
    for i=1, #pathos_ident  do
        if pathos_ident[i] ~= nil then
            pathos_ident[pathos_ident[i]] = 1
        end
    end
end

windower.register_event('zone change', function(id)
    if salvage_zones:contains(id) then
        windower.send_command('timers c Remaining 6000 up')
        settings_create()
        initialize()
        salvage_box2:show()
    else
        windower.send_command('timers d Remaining')
        settings_create()
        initialize()
        salvage_box2:hide()
    end
end)

windower.register_event('incoming text',function (original, new, color)
    original = original:strip_format()
    local pathos, name = original:match('(.*) removed for (%w+)')
    if pathos ~= nil then
        --print('Pathos found '..pathos)
        if name == player then
            for i=1, #pathos_ident  do
                if pathos_ident[i]:lower() == pathos:lower() then
                    if pathos_ident[pathos_ident[i]] == 1 then
                        pathos_ident[pathos_ident[i]] = 0
                        initialize()
                    end
                end
            end
        end
        return new, color
    end
end)

function initialize()
    pathos_remain = (" Pathos Remaining: \n ")
    for i=1, #pathos_ident  do
        if pathos_ident[pathos_ident[i]] == 1 then
            item = pathos_short[i]
            pathos_remain = (pathos_remain..item..' \n ')
        end
    end
    salvage_box2:text(pathos_remain)
    if pathos_remain == (" Pathos Remaining: \n ") then
        salvage_box2:hide()
    end
end

windower.register_event('unload',function ()
    windower.text.delete('salvage_box2')
    windower.send_command('timers d Remaining')
end )
