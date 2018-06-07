texts = require("texts")
spellbuttons = require("ui/spellbuttons")
spelllist = {}
display = {}

local function get_limits()
    local player = windower.ffxi.get_player()
    local slots = 0
    local points = 0
    local gifts = 0
    local level = 0
    
    if player.main_job == "BLU" then
        if player.main_job_level > 70 then
            slots = 20
        else
            slots = (math.floor((player.sub_job_level + 9) / 10) * 2) + 4
        end
        
        points = (math.floor((player.main_job_level + 9) / 10) * 5) + 5
        if player.main_job_level >= 75 then
            points = points + player.merits.assimilation
            if player.main_job_level == 99 then
                points = points + player.job_points.blu.blue_magic_point_bonus
            end
        end
        level = player.main_job_level
    elseif player.sub_job == "BLU" then
        points = (math.floor((player.sub_job_level + 9) / 10) * 5) + 5
        slots = (math.floor((player.sub_job_level + 9) / 10) * 2) + 4
        level = player.sub_job_level
    end
        
    local jobpointsspent = player.job_points.blu.jp_spent
    if jobpointsspent >= 1200 then
        gifts = 2
    elseif jobpointsspent >= 100 then
        gifts = 1
    end
        
    spelllist.limits = { slots = slots, points = points, level = level }
    spelllist.gifts = gifts
    spelllist.learned = windower.ffxi.get_spells()
end

function spelllist.create(px, py, updatefn)
    local textsettings = { 
        text = { size = 10, font = 'Lucida Console' },
        bg = { alpha = 120, red = 0, green = 0, blue = 0, visible = true },
        flags = { draggable = false },
        pos = {x = px, y = py} }
    
    slots = texts.new("Slots: 0/20 Points: 0/70", textsettings)
    x = px
    y = py
    slots:pos(px, py)
    slots:show()
    
    spelllist.slots = 0
    spelllist.points = 0
    spelllist.update = updatefn
    get_limits()
    
    t = get_set_spells()
    if not t.spells then return end
    for _,v in pairs(t.spells) do
        spelllist.add(v)
    end
end

function get_set_spells()
    local player = windower.ffxi.get_player()
    local t = {}
    if player.main_job == "BLU" then
        t = windower.ffxi.get_mjob_data()
    elseif player.sub_job == "BLU" then
        t = windower.ffxi.get_sjob_data()
    end
    return t
end

function spelllist.add(spell)
    spelllist[spell] = true
    spelllist.slots = spelllist.slots + 1
    spelllist.points = spelllist.points + spellinfo[spell].cost
    
    local newspell = spellbuttons.new(string.format('%-24s %i', spellinfo[spell].name, spellinfo[spell].cost), spell, spellinfo[spell].cost, x, y + spelllist.slots * lineheight)
    if spellinfo[spell].element == 0 then --fire
        newspell:color(255, 0, 0)
    elseif spellinfo[spell].element == 1 then --ice
        newspell:color(180, 180, 255)
    elseif spellinfo[spell].element == 2 then --wind
        newspell:color(0, 255, 0)
    elseif spellinfo[spell].element == 3 then --earth
        newspell:color(255, 255, 0)
    elseif spellinfo[spell].element == 4 then --thunder
        newspell:color(255, 0, 255)
    elseif spellinfo[spell].element == 5 then --water
        newspell:color(100, 100, 255)
    elseif spellinfo[spell].element == 6 then --light
        newspell:color(235, 235, 255)
    elseif spellinfo[spell].element == 7 then --dark
        newspell:color(180, 180, 180)
    elseif spellinfo[spell].element == 15 then --physical
        newspell:color(200, 100, 0)
    end
    
    newspell:show()
    display[spell] = newspell
    
    spelllist.sort()
    
    local t = get_set_spells()
    for i = 1, spelllist.limits.slots do
        if t.spells[i] == nil then 
            windower.ffxi.set_blue_magic_spell(spell, i) 
            return 
        end
    end
end

function spelllist.remove(spell)
    display[spell]:destroy()
    display[spell] = nil
    
    spelllist[spell] = nil
    
    spelllist.slots = spelllist.slots - 1
    spelllist.points = spelllist.points - spellinfo[spell].cost
    
    spelllist.sort()
    
    
    local t = get_set_spells()
    for i = 1, spelllist.limits.slots do
        if t.spells[i] == spell then 
            windower.ffxi.remove_blue_magic_spell(i)
            
            return 
        end
    end
    
end

function spelllist.sort()
    local pos = 1
    vspace = "\n"
    for _, v in pairs(display) do
        vspace = vspace.."\n"
        v:pos(x, y + (pos*lineheight))
        v:update()
        pos = pos + 1
    end
    slots:text(string.format('Slots: %2i/%2i Points: %2i/%2i', spelllist.slots, spelllist.limits.slots, spelllist.points, spelllist.limits.points)..vspace)
    spelllist.update()
end

function spelllist.toggle(spell)
    if spelllist[spell] then
        spelllist.remove(spell)
    else
        spelllist.add(spell)
    end
end

return spelllist

--Copyright © 2015, Anissa
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of bluGuide nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL ANISSA BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
