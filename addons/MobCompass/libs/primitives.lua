--[[
Copyright (c) 2013 Sebastien Gomez
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of MobCompass nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sebastien Gomez BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

local bucket = {}
local hidden = false
local primitives = {}

for _, cat in pairs({'text', 'prim'}) do
    local t = {}
    bucket[cat] = t

    local bin = windower[cat]
    local create = bin.create
    local visibility = bin.set_visibility
    local delete = bin.delete

    windower[cat].create = function(name)
        create(name)
        t[name] = true -- prim/text are drawn by default
        if hidden then visibility(name, false) end
    end

    windower[cat].set_visibility = function(name, visible)
        if not hidden then
            visibility(name, visible)
        end

        t[name] = visible
    end

    windower[cat].delete = function(name)
        delete(name)
        t[name] = nil
    end

    windower[cat].rawset_visibility = visibility
end

-- In order for this library to function properly, _addon.name must be defined and unique among loaded addons
local get_name
do
    local n = 0
    get_name = function(cat)
        n = n + 1
        return (_addon and _addon.name or '') .. '_' .. cat .. '_' .. tostring(n)
    end
end

function primitives.new(cat, settings)
    local name = get_name(cat)

    cat = windower[cat]
    cat.create(name)

    if settings then
        for func, args in pairs(settings) do
            local primitive_function = cat[func]

            if primitive_function then
                if type(args) == 'table' then
                    primitive_function(name, unpack(args))
                else
                    primitive_function(name, args)
                end
            end
        end
    end

    return function(func, ...)
        return cat[func](name, ...) -- need to return (e.g. get_extents)
    end
end

function primitives.low_level_visibility(b)
    hidden = not b
    for name, is_visible in pairs(bucket.prim) do
        windower.prim.rawset_visibility(name, b and is_visible)
    end
    for name, is_visible in pairs(bucket.text) do
        windower.text.rawset_visibility(name, b and is_visible)
    end
end

function primitives.count()
    local n = 0
    for _ in pairs(bucket.text) do
        n = n + 1
    end
    for _ in pairs(bucket.prim) do
        n = n + 1
    end

    return n
end

function primitives.destroy_all()
    for name in pairs(bucket.text) do
        windower.text.delete(name)
    end
    for name in pairs(bucket.prim) do
        windower.prim.delete(name)
    end
end

function primitives.hidden()
    return hidden
end

windower.text.set_position = windower.text.set_location

windower.register_event('unload', function()
    for name in pairs(bucket.prim) do
        windower.prim.delete(name)
    end
    for name in pairs(bucket.text) do
        windower.text.delete(name)
    end
end)

windower.register_event('zone change', function()
    primitives.low_level_visibility(true)
end)

windower.register_event('outgoing chunk', function(id)
    if id == 0xD then
        primitives.low_level_visibility(false)
    end
end)

windower.register_event('status change', function(new, old)
    if new == 4 then
        primitives.low_level_visibility(false)
    elseif old == 4 then
        primitives.low_level_visibility(true)
    end
end)

windower.register_event('login', function()
    primitives.low_level_visibility(true)
end)

windower.register_event('logout', function()
    primitives.low_level_visibility(false)
end)

return primitives

