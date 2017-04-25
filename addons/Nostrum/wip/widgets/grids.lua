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

local grids = {}
local meta = {}
local groups = _libs.groups or require 'widgets/groups'

_libs = _libs or {}
_libs.grids = grids

_meta = _meta or {}
_meta.grids = _meta.grids or {}
_meta.grids.__index = function(t, k) return grids[k] or groups[k] end

local function call_events(object, event, ...)
    local it = object:events(event)
    local block_event = false
    
    if it then
        for fn in it do
            block_event = fn(...)
            
            if block_event then break end
        end
    end
    
    return block_event
end

function grids.new(x, y, cell_width, cell_height, rows, columns)
    local t = groups.new(x, y, columns*cell_width, rows*cell_height)
    local m = {}
    
    meta[t] = m
    
    m.events = {}
    m.r = rows
    m.c = columns
    m.w = cell_width
    m.h = cell_height
    
    for i = 1, rows do
        t[i] = {}
        --[[for j = 1, columns do
            t[i][j] = {}
        end--]]
    end

    
    if _libs.widgets then
        --[[grids.register_event(t, 'drop', function()
            local subwidgets = t._subwidgets
            local x, y = grids.pos(t)
            
            for i = 1, subwidgets.n do
                local object = subwidgets[i]
                if widgets.tracking(object) then
                    local offsets = m.offsets[object]
                    local _x, _y = x + offsets.x, y + offsets.y
                    
                    widgets.update_object(object, _x, _x + object:width() - 1, _y, _y + object:height() - 1)
                end
            end
        end)--]] -- duplicated code from groups?
        
        local events_with_x_y_data = {
            --'move', -- need to spoof focus change             ['focus change'] = true,
            'left click',
            'right click',    
            'middle click',
            'x button click',
            'left button down',
            'right button down',
            'left button up',
            'right button up',
            'middle button down',
            'middle button up',
            'scroll',
            'x button down',
            'x button up',
        }

        local function locate_object_in_contents(x, y)
            local pos_x, pos_y = groups.pos(t)
            local w, h = groups.width(t), groups.height(t)
            local floor = math.floor
            
            local r = floor((y - pos_y)/m.h) + 1
            local c = floor((x - pos_x)/m.w) + 1
            local object = t[r][c]

            return object and object:visible() and object:hover(x, y) and object
        end
        
        local function redirect_events(event, x, y, ...)
            local object = locate_object_in_contents(x, y)
            
            if object then
                return call_events(object, event, x, y, ...)
            end
        end
        
        local function move(x, y) -- some version of this should be moved to groups.
            local object = locate_object_in_contents(x, y)
            
            if object then
                if object._can_take_focus then
                    if object ~= t._focus then
                        local old_focus = t._focus
                        t._focus = object
                        
                        if old_focus then
                            call_events(old_focus, 'focus change', false)
                        end
                        
                        call_events(object, 'focus change', true)
                    end
                end
                
                return call_events(object, 'move', x, y)
            end
        end        
        
        for i = 1, #events_with_x_y_data do
            grids.register_event(t, events_with_x_y_data[i], function(...) return redirect_events(events_with_x_y_data[i], ...) end)
        end
        
        grids.register_event(t, 'move', move)
        grids.register_event(t, 'focus change', function(b)
            if not b then t._focus = nil end
        end)

    end
    
    return setmetatable(t, _meta.grids)
end

function grids.destroy(t)
    meta[t] = nil
    
    groups.destroy(t)
end

function grids.new_row(t)
    local m = meta[t]
    local n = m.r + 1
    local row = {}

    m.r = n    

    -- adjust group height
    groups.height(t, n * m.h)
    
    -- add a new row
    --[[for i = 1, m.c do
        row[i] = {}
    end--]]
    
    t[n] = row
end

function grids.remove_row(t)
    local m = meta[t]
    local n = m.r
    
    m.r = n - 1
    groups.height(t, m.r * m.h)
    
    t[n] = nil
end

function grids.new_column(t)
    local m = meta[t]
    local c = m.c + 1
    
    m.c = c
    
    -- adjust the group width    
    groups.width(t, c * m.w)
    
    -- add a new column to each row
    --[[for i = 1, m.r do
        t[i][c] = {}
    end--]]
end

function grids.remove_column(t)
    local m = meta[t]
    local c = m.c
    
    m.c = c - 1
    
    groups.width(t, m.c * m.w)

    for i = 1, m.r do
        t[i][c] = nil
    end
end

function grids.rows(t, n)
    if not n then return meta[t].r end
    
    local m = meta[t]
    local r = m.r
    
    m.r = n
    
    groups.height(t, n * m.h)
    
    if r ~= n then
        for i = r + 1, n do
            t[i] = {}
        end
        
        for i = n + 1, r do
            t[i] = nil
        end
    end
end

function grids.columns(t, n)
    if not n then return meta[t].c end
    
    local m = meta[t]
    local c = m.c
    
    m.c = n
    
    groups.width(t, n * m.w)
    
    if c ~= n then
        for i = 1, m.r do
            for j = n + 1, c do
                t[i][j] = nil
            end
        end
    end
end

function grids.snap(t, object, r, c)
    local m = meta[t]
    
    if r < 0 or r > m.r or c < 0 or c > m.c then return end
    
    local x, y = groups.pos(t)
    
    object:pos(x + (c - 1) * m.w, y + (r - 1) * m.h)
    t[r][c] = object
    groups.add(t, object)
end

function grids.events(t, event)
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

function grids.register_event(t, event, fn)
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
 
function grids.unregister_event(t, event, n)
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

return grids
