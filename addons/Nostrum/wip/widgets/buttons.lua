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

local buttons = {}
local meta = {}

_libs = _libs or {}
_libs.buttons = buttons

_meta = _meta or {}
_meta.buttons = _meta.buttons or {}
_meta.buttons.__class = 'Button'
_meta.buttons.__index = buttons

function buttons.new(x, y, w, h, visible)
    local t = {}
    meta[t] = {}
    
    local m = meta[t]
    
    m.x1 = x
    m.y1 = y
    m.w = w
    m.h = h
    m.x2 = x + w
    m.y2 = y + h
    m.state = false
    m.events = {}
    m.visible = visible
    
    return setmetatable(t, _meta.buttons)
end

function buttons.destroy(t)
    meta[t] = nil
end

function buttons.visible(t, bool)
    if bool == nil then
        return meta[t].visible
    end
    
    meta[t].visible = bool
end

function buttons.hide(t)
    t:visible(false)
end

function buttons.show(t)
    t:visible(true)
end

function buttons.pos(t, x, y)
    if not y then
        return meta[t].x1, meta[t].y1
    end
    
    local m = meta[t]
    
    m.x1 = x
    m.y1 = y
    m.x2 = x + m.w
    m.y2 = y + m.h
end

function buttons.pos_y(t, y)
    if not y then
        return meta[t].y1
    end
    
    local m = meta[t]
    
    m.y1 = y
    m.y2 = y + h
end

function buttons.pos_x(t, x)
    if not x then
        return meta[t].x1
    end
    
    local m = meta[t]
    
    m.x1 = x
    m.x2 = x + h
end

function buttons.width(t, width)
    if not width then
        return meta[t].w
    end
    
    local m = meta[t]
    
    m.w = width
    m.x2 = m.x1 + width
end

function buttons.height(t, height)
    if not height then
        return meta[t].h
    end
    
    local m = meta[t]
    
    m.h = height
    m.y2 = m.y1 + height
end

function buttons.activate(t)
    local events = meta[t].events.click
    
    if events then
        for i = 1,events.n do
            events[i]()
        end
    end
end

function buttons.press(t)
    local m = meta[t]
    m.state = true
    
    local events = m.events['left button down']
    
    if events then
        for i = 1,events.n do
            events[i]()
        end
    end

end

function buttons.release(t)
    local m = meta[t]
    m.state = false
    
    local events = m.events['left button up']
    
    if events then
        for i = 1,events.n do
            events[i]()
        end
    end
end

function buttons.hover(t, x, y)
    local m = meta[t]

    return  x >= m.x1
        and x < m.x2
        and y >= m.y1
        and y < m.y2
end

function buttons.state(t, state)
    if not state then return meta[t].state end
    
    meta[t].state = type(state) == 'boolean' and state
end

function buttons.events(t, event)
    local function_list = meta[t].events[event]
    if not function_list then return nil end
    
    local n = 0
    local m = function_list.n
    
    return function()
        n = n + 1
        local fn = function_list[n]
        
        -- handle holes in the list
        while not fn and n <= m do
            n = n + 1
            fn = function_list[n]
        end

        return fn
    end
end

function buttons.register_event(t, event, fn)
    local m = meta[t].events

    m[event] = m[event] or {n = 0}
    local n
    for i = 1, m[event].n do
        if not m[event][i] then
            n = i
            break
        end
    end
    if not n then
        n = m[event].n + 1
        m[event].n = n
    end
    m[event][n] = fn

    return n
end
 
function buttons.unregister_event(t, event, n)
    if not (events[event] and meta[t].events[event]) then
        return
    end

    if type(n) == 'number' then
        meta[t].events[event][n] = nil
    else
        for i = 1, meta[t].events[event].n do
            if meta[t].events[event][i] == n then
                meta[t].events[event][i] = nil
                return
            end
        end
    end
end

return buttons
