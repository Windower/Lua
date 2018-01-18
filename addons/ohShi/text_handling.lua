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

texts = require 'texts'

--Create the textbox
function initText()
    ohShi_tb = texts.new(settings)
    tracking:append('ohShi initialized ')
    textUpdate()
    coroutine.schedule(remText, settings.duration or 7)
end

--Removes first line of a textbox
function remText()
    if tracking:length() > 0 then
        table.remove(tracking,1)
        textUpdate()
    end
end

--Add text to textbox. Anytime text is added this is called.
function addText(name, abtype, abil, dMob, dangerous)
   if tracking:length() > 9 then 
      tracking:clear()
      textUpdate()
   end
    if abtype == 'ws' then
        abil = tonumber(abil)
        doit = true
        if abil <= 255 then
            abilname = res.weapon_skills[abil].english
        else
            abilname = res.monster_abilities[abil].english
        end
    elseif abtype == 'spell' then
        abil = tonumber(abil)
        doit = true
        abilname = res.spells[abil].english
    elseif abtype == 'roll' then
        abil = tonumber(abil)
        doit = true
        abilname = res.job_abilities[abil].english .. ' [' .. dMob .. ']'
        dMob = nil
        dangerous = nil
    elseif name == 'vulnerable' then
        if dMob == ' extremely ' then
            tracking:append(' \\cs(255,100,100)Weakness 5: '..dangerous:capitalize()..'\\cr')
        elseif dMob == ' highly ' then
            tracking:append(' \\cs(255,100,100)Weakness 3: '..dangerous:capitalize()..'\\cr')
        else
            tracking:append(' Weakness 1: '..dangerous:capitalize())
        end
    elseif name == 'bluered' then
        tracking:append(' Blue: '..dMob..'% Red: '..dangerous..'%')
    elseif name == 'red' then
        tracking:append(' Red: '..dMob..'%')
    elseif name == 'blue' then
        tracking:append(' Blue: '..dMob..'%')
    elseif name == 'devastates' then
        tracking:append(' Fiend devastated by: '..dMob)
    elseif name == 'victory' then
        tracking:append(' Key to Victory: '..dMob)
    else
        tracking:append(' '..name)
    end
    if doit then
        local str = name..': '..abilname
        if dangerous or dMob then
            tracking:append(' \\cs(255,100,100)'..str..'\\cr')
            flashImage()
        else
            tracking:append(' '..str)
        end
    end
    coroutine.schedule(remText, settings.duration or 7)
    textUpdate()
end

--Called anytime text is added to the tracking table
--Refreshes the textbox and hides/shows it if needed.
function textUpdate()
    if #tracking > 0 then
        local txt = ''
        for inc = 1, #tracking do
            txt = txt..tracking[inc]
            if inc < #tracking then
                txt = txt..'\n'
            end
        end
        ohShi_tb:text(txt)
        ohShi_tb:show()
    else
        ohShi_tb:text('')
        ohShi_tb:hide()
    end
end

--image handling
--This function is used to flash the warning image
--when a danger tp/spell is used.
function flashImage()
    local name = 'ohShi'..tostring(math.random(10000000,99999999))
    prims:add(name)
    windower.prim.create(name)
    windower.prim.set_color(name,255,255,255,255)
    windower.prim.set_fit_to_texture(name,false)
    windower.prim.set_texture(name,windower.addon_path..'data/warning.png')
    windower.prim.set_repeat(name,1,1)
    windower.prim.set_visibility(name,true)
    windower.prim.set_position(name,settings.pos.x-30,settings.pos.y-10)
    windower.prim.set_size(name,30,30)
    coroutine.schedule(deleteImage:prepare(name), settings.duration or 7)
end

--Called to delete the image after it's time is up.
function deleteImage(str)
    prims:remove(str)
    windower.prim.delete(str)
end
