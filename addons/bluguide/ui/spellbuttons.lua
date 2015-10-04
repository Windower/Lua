local spbt = {}
buttons = require("ui/buttons")

local default_settings = {
    text = { size = 10, font = 'Lucida Console',},
    bg = { alpha = 200, red = 0, green = 100, blue = 100, visible = false },
}

function spbt.new(label, spell, cost, x, y)
    local me = { spell = spell, cost = cost}
    me.settings = default_settings
    me.settings.pos = { x = x, y = y }
    me.set = {red = 100, green = 255, blue = 100 }
    me.disabled = true
    me.button = buttons.new(label, me.settings)
    me.button.left_click = function() toggle_spell(me) end
    me.button.hover_on = function() hover_on(me) end
    me.button.hover_off = function() hover_off(me) end
    return setmetatable(me, {__index = spbt})
end

function spbt.update(me)
    if setspells[me.spell] ~= nil then
        me.button.color(me.set.red, me.set.green, me.set.blue)
        me.disabled = false
    elseif not setspells.learned[me.spell] then
        me.button.color(150, 150, 150)
        me.disabled = true
    elseif setspells.limits.points - setspells.points < me.cost or setspells.slots == setspells.limits.slots then        
        me.button.color(255, 100, 100)
        me.disabled = true
    else
        me.button.color(255, 255, 255)
        me.disabled = false
    end
end

function spbt.show(me)
    me.button.show()
end

function spbt.hide(me)
    me.button.hide()
end

function spbt.destroy(me)
    me.button.destroy(me.button)
    me = nil
end

function spbt.pos(me, x, y)
    me.button.pos(x, y)
end

function hover_on(me)
    me.button.bg_visible(true)
end

function hover_off(me)
    me.button.bg_visible(false)
end

function spbt.color(me,r,g,b)
    me.button.color(r,g,b)
    me.set.red = r
    me.set.green = g
    me.set.blue = b
end

function toggle_spell(me)
    if not me.disabled then
        setspells.toggle(me.spell) 
    end
end

return spbt

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