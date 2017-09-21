--[[
    A library providing advanced queue support and better optimizations for queue-based operations.
]]

_libs = _libs or {}

require('tables')

local table = _libs.tables

local queue = {}

_libs.queues = queue

_raw = _raw or {}
_raw.table = _raw.table or {}

_meta = _meta or {}
_meta.Q = {}
_meta.Q.__index = function(q, k)
    if type(k) == 'number' then
        if k < 0 then
            return rawget(q.data, q.back - k + 1)
        else
            return rawget(q.data, q.front + k - 1)
        end
    end

    return rawget(queue, k) or rawget(table, k)
end
_meta.Q.__newindex = function(q, k, v)
    error('Cannot assign queue value:', k)
end
_meta.Q.__class = 'Queue'

function Q(t)
    if class(t) == 'Set' then
        local q = Q{}

        for el in pairs(t) do
            q:push(el)
        end

        return q
    end

    local q = {}
    q.data = setmetatable(t, nil)
    q.front = 1
    if class(t) == 'List' then
        q.back = t.n + 1
    else
        q.back = #t + 1
    end

    return setmetatable(q, _meta.Q)
end

function queue.empty(q)
    return q.front == q.back
end

function queue.length(q)
    return q.back - q.front
end

function queue.push(q, el)
    rawset(q.data, q.back, el)
    q.back = q.back + 1
    return q
end

function queue.pop(q)
    if q:empty() then
        return nil
    end

    local res = rawget(q.data, q.front)
    rawset(q.data, q.front, nil)
    q.front = q.front + 1
    return res
end

function queue.insert(q, i, el)
    q.back = q.back + 1
    table.insert(q.data, q.front + i - 1, el)
    return q
end

function queue.remove(q, i)
    q.back = q.back - 1
    table.remove(q.data, q.front + i - 1)
    return q
end

function queue.it(q)
    local key = q.front - 1
    return function()
        key = key + 1
        return rawget(q.data, key), key
    end
end

function queue.clear(q)
    q.data = {}
    q.front = q.back
    return q
end

function queue.copy(q)
    local res = {}

    for key = q.front, q.back do
        rawset(res, key, rawget(q.data, key))
    end

    res.front = q.front
    res.back = q.back
    return setmetatable(res, _meta.Q)
end

function queue.reassign(q, qn)
    q:clear()

    for key = qn.front, qn.back do
        rawset(q, key, rawget(qn.data, key))
    end

    q.front = qn.front
    q.back = qn.back
    return q
end

function queue.sort(q, ...)
    _raw.table.sort(q.data, ...)
    return q
end

function queue.tostring(q)
    local str = '|'

    for key = q.front, q.back - 1 do
        if key > q.front then
            str = str .. ' < '
        end
        str = str .. tostring(rawget(q.data, key))
    end

    return str .. '|'
end

_meta.Q.__tostring = queue.tostring

--[[
Copyright © 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
