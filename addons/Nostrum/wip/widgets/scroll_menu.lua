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

local scrolling_text_menu = {}
local meta = {}

_libs = _libs or {}
_libs.scrolling_text_menu = scrolling_text_menu

_libs.scrolling_text = _libs.scrolling_text or  require('widgets/scroll_text')
local scroll_text = _libs.scrolling_text

_meta = _meta or {}
_meta.scrolling_text_menu = _meta.scrolling_text_menu or {}
_meta.scrolling_text_menu.__class = 'ScrollTextMenu'
_meta.scrolling_text_menu.__index = function(t, k) return scrolling_text_menu[k] or scroll_text[k] end

local prims = _libs.prims

local amend
amend = function(settings, defaults)
    for key, val in pairs(defaults) do
        if type(val) == 'table' then
            settings[key] = amend(settings[key] or {}, val)
        elseif settings[key] == nil then
            settings[key] = val
        end
    end

    return settings
end

local default_settings = {
    color = {
        highlight = {125, 131, 199, 99},
    },
    text = {
        font = 'Consolas',
        size = 10,
        lines = {},
        color_formatting = {},
        lines_to_display = 12,
        line_height = 16,
    },
    pos = {0, 0},
    w = 150,
    fit = {x = false, y = false},
}

function scrolling_text_menu.new(settings)    
    local m = settings or {}
    
    m = amend(m, default_settings)
    
    m.selected = 0
    m.state = false
    m.events = {}

    local t = scroll_text.new(settings)
    
    t.highlight = prims.new({
        pos = m.pos,
        w = m.w,
        color = {unpack(m.color.highlight)},
        visible = m.visible,
        })

    m.color = nil

    meta[t] = m
    
    if _libs.widgets then
        scroll_text.register_event(t, 'left click', function(x, y)
            local m = meta[t]
            local n = math.floor((y - m.pos[2])/t:line_height()) + t:list_position()

            local text = t:line(n)

            local events = m.events['menu selection']
            
            if not events then return end
            
            for i = 1,events.n do
                events[i](n, text)
            end        
        end)
        
        scroll_text.register_event(t, 'move', function(x, y)
            local m = meta[t]
            local n = math.floor((y - scroll_text.pos_y(t))/t:line_height()) + 1
            
            scrolling_text_menu.selected(t, n)
        end)
    end
    
    return setmetatable(t, _meta.scrolling_text_menu)
end

function scrolling_text_menu.destroy(t)
    t.highlight:destroy()
    scrolling_text.destroy(t)
    
    meta[t] = nil
end

function scrolling_text_menu.show(t)
    scroll_text.show(t)
    t.highlight:show()
    
    meta[t].visible = true
end

function scrolling_text_menu.hide(t)
    t.highlight:hide()
    scroll_text.hide(t)
    
    meta[t].visible = false
end

function scrolling_text_menu.open(t, n)
    local m = meta[t]
    
    scroll_text.open(t, n)
    local l = scroll_text.line_height(t)
    t.highlight:height(l)
    t.highlight:pos_y(scroll_text.pos_y(t) + (m.selected <= scroll_text.range(t) and m.selected or 0) * l)

    m.state = true
end

function scrolling_text_menu.close(t)
    scroll_text.close(t)
    t.highlight:hide()

    local m = meta[t]
    m.selected = 0
    m.state = false
end

function scrolling_text_menu.visible(t, visible)
    if visible == nil then
        return meta[t].visible
    end
    
    t.highlight:visible(visible)
    scroll_text.visible(t, visible)
    
    meta[t].visible = visible
end

function scrolling_text_menu.width(t, width)
    if width then
        t.highlight:width(width)
    end
    
    return scroll_text.width(t, width)
end

function scrolling_text_menu.is_open(t)
    return meta[t].state
end

function scrolling_text_menu.selected(t, n)
    if not n then return meta[t].selected + 1 end
    
    local m = meta[t]
    m.selected = (n - 1) % scroll_text.range(t)
    
    t.highlight:pos_y(scroll_text.pos_y(t) + m.selected * t.highlight:height())
end

function scrolling_text_menu.pos(t, x, y)
    if y then
        t.highlight:pos(x, y + meta[t].selected * t.highlight:height())
    end
    
    return scroll_text.pos(t, x, y)
end

function scrolling_text_menu.pos_x(t, x)
    if x then
        t.highlight:pos_x(x)
    end

    return scroll_text.pos_x(t, x)
end

function scrolling_text_menu.pos_y(t, y)
    if y then
        t:pos(t:pos_x(), y)
    else
        return scroll_text.pos_y(t)
    end
end

return scrolling_text_menu
