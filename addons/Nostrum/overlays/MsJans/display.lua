--[[Copyright © 2014-2017, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Nostrum nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL trv BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

local display = {}
local meta = {}

_meta = _meta or {}
_meta.display = {__index = display}

function display.new(bin)
    meta[bin] = {
        in_range = true,
        in_sight = true,
    }
    return setmetatable(bin, _meta.display)
end

function display:in_range()
    if not meta[self].in_range then
        meta[self].in_range = true
        
        self.name:bold(true)
    end
end

function display:out_of_range()
    if meta[self].in_range then
        meta[self].in_range = false
        
        self.name:bold(false)
    end
end

function display:out_of_sight()
    meta[self].in_sight = false
    self.name:italic(true)
end

function display:in_sight()
    meta[self].in_sight = true
    self.name:italic(false)
end

function display:link(player)
    meta[self].link = player
end

function display:refresh()
    local m = meta[self]
    local player = m.link
    
    if player.out_of_zone then
        self:out_of_zone()
    else
        self:in_zone()
    end
    
    if player.out_of_sight then
        self:out_of_sight()
    else
        self:in_sight()
    end
    
    self:draw_name(player.name)
end

function display:unlink()
    meta[self].link = nil
end

function display:in_zone()
    local player = meta[self].link
    
    self:draw_hp(player.hp)
    self:draw_mp(player.mp)
    self:draw_tp(player.tp)
    self:draw_hpp(player.hpp, 101) -- force color update
    self:draw_mpp(player.mpp)
    
    self.tp:visible(true)
    self.mp:visible(true)
    self.hp:visible(true)
    self.hpp:visible(true)
    self.phpp:visible(true)
    self.pmpp:visible(true)

    if player.out_of_range then
        self:out_of_range()
    else
        self:in_range()
    end
end

function display:out_of_zone()
    self.tp:visible(false)
    self.mp:visible(false)
    self.hp:visible(false)
    self.hpp:visible(false)
    self.phpp:visible(false)
    self.pmpp:visible(false)
    self:out_of_range()
    self:out_of_sight()
end

function display:destroy()
    meta[self] = nil
    
    self.tp:destroy()
    self.mp:destroy()
    self.hp:destroy()
    self.hpp:destroy()
    self.phpp:destroy()
    self.pmpp:destroy()
    self.name:destroy()

    self.tp = nil
    self.mp = nil
    self.hp = nil
    self.hpp = nil
    self.phpp = nil
    self.pmpp = nil
    self.name = nil
end

function display:hide()
    self.tp:visible(false)
    self.mp:visible(false)
    self.hp:visible(false)
    self.hpp:visible(false)
    self.phpp:visible(false)
    self.pmpp:visible(false)
    self.name:visible(false)
end

function display:show()
    if not meta[self].link.out_of_zone then
        self.tp:visible(true)
        self.mp:visible(true)
        self.hp:visible(true)
        self.hpp:visible(true)
        self.phpp:visible(true)
        self.pmpp:visible(true)
        self.name:visible(true)        
    end
    
    self.name:show()
end

function display:draw_hp(n)
    self.hp:text(tostring(n))
end

function display:draw_mp(n)
    self.mp:text(tostring(n))
end

function display:draw_hpp(new, old)
    self.hpp:text(tostring(new))

    local quarter = math.ceil(new/25)
    local obj = self.phpp

    obj:width(new/100 * settings.prim.bar_width)
    
    if new ~= 0 and quarter ~= math.ceil(old/25) then
        local color = settings.prim.hp[quarter*25]
        
        obj:argb(color.a, color.r, color.g, color.b)
    end
end

function display:draw_mpp(n)
    self.pmpp:width(n/100 * settings.prim.bar_width)
end

function display:draw_tp(n)
    self.tp:text(tostring(n))
end

function display:draw_name(s)
    local truncate_length = settings.text.name.truncate
    
    self.name:text(string.sub(s, 1, truncate_length) .. (#s > truncate_length and '̤' or ''))
end

function display:draw_zone(n)

end

return display
