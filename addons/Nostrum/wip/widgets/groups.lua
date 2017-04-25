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

local groups = {}
local meta = {}

_libs = _libs or {}
_libs.groups = groups

_meta = _meta or {}
_meta.groups = _meta.groups or {}
_meta.groups.__index = groups

function groups.new(x, y, w, h)
    local t = {}
    local m = {}
    
    meta[t] = m
    
    m.offsets = {}
    m.events = {}
    m.visible = true -- ?
    m.x1, m.y1, m.w, m.h = x, y, w, h
    m.x2, m.y2 = m.x1 + m.w - 1, m.y1 + m.h - 1
    
    t._subwidgets = {}
    t.n = 0
    
    t._ignored = {}
    
    if _libs.widgets then
        groups.register_event(t, 'drop', function()
            local subwidgets = t._subwidgets
            local x, y = groups.pos(t)
            
            for object in pairs(subwidgets) do
                if widgets.tracking(object) then
                    local offsets = m.offsets[object]
                    local _x, _y = x + offsets.x, y + offsets.y
                    
                    widgets.update_object(object, _x, _x + object:width() - 1, _y, _y + object:height() - 1)
                end
            end
        end)
    end
    
    return setmetatable(t, _meta.groups)
end

function groups.destroy(t)
    meta[t] = nil
    
    t._subwidgets = nil
    t._ignored = nil
end

function groups.hover(t, x, y)
    local m = meta[t]

    return m.x1 <= x
        and m.x2 >= x
        and m.y1 <= y
        and m.y2 >= y
end

function groups.pos(t, x, y)
    local m = meta[t]
    
    if not y then return m.x1, m.y1 end
    
    for object in pairs(t._subwidgets) do
        local offsets = m.offsets[object]

        object:pos(x + offsets.x, y + offsets.y)
    end
    
    m.x1, m.y1 = x, y
    m.x2, m.y2 = x + m.w - 1, y + m.h - 1
end

function groups.pos_x(t, x)
    if not x then return meta[t].x1 end
    
    local m = meta[t]
    
    for object in pairs(t._subwidgets) do
        local offsets = m.offsets[object]
        
        object:pos_x(x + offsets.x)
    end
    
    m.x1 = x
    m.x2 = x + m.w - 1
end

function groups.pos_y(t, y)
    if not y then return meta[t].y1 end
    
    local m = meta[t]
    
    for object in pairs(t._subwidgets) do
        local offsets = m.offsets[object]
        
        object:pos_y(y + offsets.y)
    end
    
    m.y1 = y
    m.y2 = y + m.h - 1
end

function groups.add(t, object)
    local m = meta[t]
    local x, y = object:pos()

    x, y = x - m.x1, y - m.y1
    
    m.offsets[object] = {x=x, y=y}
    
    t._subwidgets[object] = true
    
    object._group = t
end

function groups.remove(t, object)
    if not object then return end
    
    t._ignored[object] = nil
    
    local m = meta[t]
    
    t._subwidgets[object] = nil
end

function groups.contains(t, object)
    return t._subwidgets[object]
end

function groups.ignore_visibility(t, object, bool)
    t._ignored[object] = bool or nil
end

function groups.visible(t, bool)
    if bool == nil then
        return meta[t].visible
    end
    
    local m = meta[t]
    
    m.visible = bool
    
    for obj in pairs(t._subwidgets) do
        if not t._ignored[obj] then
            obj:visible(bool)
        end
    end
end

function groups.width(t, w)
    if not w then return meta[t].w end
    
    local m = meta[t]
    
    m.w = w
    m.x2 = m.x1 + w - 1
end

function groups.height(t, h)
    if not h then return meta[t].h end
    
    local m = meta[t]
    
    m.h = h
    m.y2 = m.y1 + h - 1
end

function groups.hide(t)
    groups.visible(t, false)
end

function groups.show(t)
    groups.visible(t, true)
end

function groups.detach(t, object)
    -- Remove the _group key from the object so that the widgets library
    -- won't drag the entire group if the object is grabbed.
    -- The object remains in the group.

    object._group = object._group == t and nil or object._group
end

function groups.events(t, event)
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

function groups.register_event(t, event, fn)
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
 
function groups.unregister_event(t, event, n)
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

return groups
