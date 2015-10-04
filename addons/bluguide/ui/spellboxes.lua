local sbx = {}
buttons = require("ui/buttons")
texts = require("texts")
spellbuttons = require("ui/spellbuttons")


local default_settings = {
    text = { size = 10, font = 'Lucida Console' },
    bg = { alpha = 120, red = 0, green = 0, blue = 0, visible = true },
    flags = {draggable = false}
}

local header_settings = {
    text = { size = 10, font = 'Lucida Console',},
    bg = { alpha = 200, red = 0, green = 100, blue = 100, visible = false },
}

function sbx.new(name, filter, namefn)
    local me = { name = name, x = 0, y = 0, splist = {}, collapsed = false}
        
    me.bg = texts.new("                        ", default_settings)
    
    me.header = buttons.new(string.format('- %-24s', me.name), header_settings)
    me.header.bold(false)
    me.header.color(255, 255, 255)
    me.header.bg_color(0, 100, 100)
    me.header.left_click = function() collapse(me) end
    me.header.hover_on = function() show_bg(me) end
    me.header.hover_off = function() hide_bg(me) end
    
    local linenum = 1
    local totalpoints = 0
    for k, v in pairs(spellinfo) do
        if filter(v) and v.level <= setspells.limits.level then
            local buttonname = nil
            if namefn ~= nil then
                buttonname = namefn(v)
            end
            buttonname = buttonname or v.name
            me.splist[#me.splist+1] = spellbuttons.new(string.format('  %-22s %i', buttonname, v.cost), v.id, v.cost, me.x, me.y + (linenum * lineheight))
            me.splist[#me.splist]:update()
            linenum = linenum + 1
        end
    end

    if #me.splist > 0 then return setmetatable(me, {__index = sbx}) end
end

function sbx.update(me)
    local vspace = "                          "
    for _, v in pairs(me.splist) do
        v:update()
        if not me.collapsed then
            vspace = vspace.."\n    "
        end
    end

    me.bg:text(vspace)
end

function sbx.bottom(me)
    if not me.collapsed then
        return me.y + ((1 + #me.splist) * lineheight)
    else
        return me.y + lineheight
    end
end

function sbx.left(me)
    return me.x 
end

function sbx.show(me)
    if not me.collapsed then
        for _, v in pairs(me.splist) do
            v:show()
        end
    end
    me.bg:show()
    me.header.show()
end

function sbx.pos(me, x, y)
    me.x = x
    me.y = y
    me.bg:pos(x, y)
    me.header.pos(x, y)
    local by = 0
    for i = 1, #me.splist do
        by = by + lineheight
        me.splist[i]:pos(x, y+by)
    end
end

function sbx.hide(me)
    for _, v in pairs(me.splist) do
        v:hide()
    end
    me.header.hide()
    me.bg:hide()
end

function show_bg(me)
    me.header.bg_visible(true)
end

function hide_bg(me)
    me.header.bg_visible(false)
end

function collapse(me)
    me.collapsed = not me.collapsed
    if me.collapsed then
        me.header.text:text(string.format('+ %-24s', me.name))
        me.header.bold(true)
        for _, v in pairs(me.splist) do
            v:hide()
        end
        me:update()
    else
        me.header.text:text(string.format('- %-24s', me.name))
        me.header.bold(false)
        for _, v in pairs(me.splist) do
            v:show()
        end
    end
    update()
end

return sbx

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
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. (c) 2015, Anissa
--All rights reserved.