--[[
    A library providing advanced list support and better optimizations for list-based operations.
]]

_libs = _libs or {}

require('tables')

local table = _libs.tables

list = {}

local list = list

_libs.lists = list

_raw = _raw or {}
_raw.table = _raw.table or {}

_meta = _meta or {}
_meta.L = {}

_meta.L.__index = function(l, k)
    if type(k) == 'number' then
        k = k < 0 and l.n + k + 1 or k

        return rawget(l, k)
    end

    return list[k] or table[k]
end

_meta.L.__newindex = function(l, k, v)
    if type(k) == 'number' then
        k = k < 0 and l.n + k + 1 or k

        if k >= 1 and k <= l.n then
            rawset(l, k, v)
        else
            (warning or print)('Trying to assign outside of list range (%u/%u): %s':format(k, l.n, tostring(v)))
        end

    else
        (warning or print)('Trying to assign to non-numerical list index:', k)

    end
end
_meta.L.__class = 'List'

function L(t)
    local l
    if class(t) == 'Set' then
        l = L{}

        for el in pairs(t) do
            l:append(el)
        end
    else
        l = t or {}
    end

    l.n = #l
    return setmetatable(l, _meta.L)
end

function list.empty(l)
    return l.n == 0
end

function list.length(l)
    return l.n
end

function list.flat(l)
    for key = 1, l.n do
        if type(rawget(l, key)) == 'table' then
            return false
        end
    end

    return true
end

function list.equals(l1, l2)
    if l1.n ~= l2.n then
        return false
    end

    for key = 1, l.n do
        if rawget(l1, key) ~= rawget(l2, key) then
            return false
        end
    end

    return true
end

function list.append(l, el)
    l.n = l.n + 1
    return rawset(l, l.n, el)
end

function list.last(l, i)
    return rawget(l, l.n - ((i or 1) - 1))
end

function list.insert(l, i, el)
    l.n = l.n + 1
    table.insert(l, i, el)
end

function list.remove(l, i)
    i = i or l.n
    local res = rawget(l, i)

    for key = i, l.n do
        rawset(l, key, rawget(l, key + 1))
    end

    l.n = l.n - 1
    return res
end

function list.extend(l1, l2)
    local n1 = l1.n
    local n2 = l2.n
    for k = 1, n2 do
        rawset(l1, n1 + k, rawget(l2, k))
    end

    l1.n = n1 + n2
    return l1
end

_meta.L.__add = function(l1, l2)
    return L{}:extend(l1):extend(l2)
end

function list.contains(l, el)
    for key = 1, l.n do
        if rawget(l, key) == el then
            return true
        end
    end

    return false
end

function list.count(l, fn)
    local count = 0
    if type(fn) ~= 'function' then
        for i = 1, l.n do
            if rawget(l, i) == fn then
                count = count + 1
            end
        end
    else
        for i = 1, l.n do
            if fn(rawget(l, i)) then
                count = count + 1
            end
        end
    end

    return count
end

function list.concat(l, str, from, to)
    str = str or ''
    from = from or 1
    to = to or l.n
    local res = ''

    for key = from, to do
        local val = rawget(l, key)
        if val then
            res = res..tostring(val)
            if key < l.n then
                res = res..str
            end
        end
    end

    return res
end

function list.with(l, attr, val)
    for i = 1, l.n do
        local el = rawget(l, i)
        if type(el) == 'table' and rawget(el, attr) == val then
            return el
        end
    end
end

function list.map(l, fn)
    local res = {}

    for key = 1, l.n do
        res[key] = fn(rawget(l, key))
    end

    res.n = l.n
    return setmetatable(res, _meta.L)
end

function list.filter(l, fn)
    local res = {}

    local key = 0
    local val
    for okey = 1, l.n do
        val = rawget(l, okey)
        if fn(val) == true then
            key = key + 1
            rawset(res, key, val)
        end
    end

    res.n = key
    return setmetatable(res, _meta.L)
end

function list.flatten(l, rec)
    rec = true and (rec ~= false)

    local res = {}
    local key = 0
    local val
    local flat
    local n2
    for k1 = 1, l.n do
        val = rawget(l, k1)
        if type(val) == 'table' then
            if rec then
                flat = list.flatten(val, rec)
                n2 = flat.n
                for k2 = 1, n2 do
                    rawset(res, key + k2, rawget(flat, k2))
                end
            else
                if class(val) == 'List' then
                    n2 = val.n
                else
                    n2 = #val
                end
                for k2 = 1, n2 do
                    rawset(res, key + k2, rawget(val, k2))
                end
            end
            key = key + n2
        else
            key = key + 1
            rawset(res, key, val)
        end
    end

    res.n = key
    return setmetatable(res, _meta.L)
end

function list.it(l)
    local key = 0
    return function()
        key = key + 1
        return rawget(l, key), key
    end
end

function list.equals(l1, l2)
    if l1.n ~= l2.n then
        return false
    end

    for key = 1, l1.n do
        if rawget(l1, key) ~= rawget(l2, key) then
            return false
        end
    end

    return true
end

function list.slice(l, from, to)
    local n = l.n

    from = from or 1
    if from < 0 then
        from = (from % n) + 1
    end

    to = to or n
    if to < 0 then
        to = (to % n) + 1
    end

    local res = {}
    local key = 0
    for i = from, to do
        key = key + 1
        rawset(res, key, rawget(l, i))
    end

    res.n = key
    return setmetatable(res, _meta.L)
end

function list.splice(l1, from, to, l2)
    -- TODO
    (_raw.error or error)('list.splice is not yet implemented.')
end

function list.clear(l)
    for key = 1, l.n do
        rawset(l, key, nil)
    end

    l.n = 0
    return l
end

function list.copy(l, deep)
    deep = deep ~= false and true
    local res = {}

    for key = 1, l.n do
        local value = rawget(l, key)
        if deep and type(value) == 'table' then
            res[key] = (not rawget(value, copy) and value.copy or table.copy)(value)
        else
            res[key] = value
        end
    end

    res.n = l.n
    return setmetatable(res, _meta.L)
end

function list.reassign(l, ln)
    l:clear()

    for key = 1, ln.n do
        rawset(l, key, rawget(ln, key))
    end

    l.n = ln.n
    return l
end

_raw.table.sort = _raw.table.sort or table.sort

function list.sort(l, ...)
    _raw.table.sort(l, ...)
    return l
end

function list.reverse(l)
    local res = {}

    local n = l.n
    local rkey = n
    for key = 1, n do
        rawset(res, key, rawget(l, rkey))
        rkey = rkey - 1
    end

    res.n = n
    return setmetatable(res, _meta.L)
end

function list.range(n, init)
    local res = {}

    for key = 1, n do
        rawset(res, key, init or key)
    end

    res.n = n
    return setmetatable(res, _meta.L)
end

function list.tostring(l)
    local str = '['

    for key = 1, l.n do
        if key > 1 then
            str = str..', '
        end
        str = str..tostring(rawget(l, key))
    end

    return str..']'
end

_meta.L.__tostring = list.tostring

function list.format(l, trail, subs)
    if l.n == 0 then
        return subs or ''
    end

    trail = trail or 'and'

    local last
    if trail == 'and' then
        last = ' and '
    elseif trail == 'or' then
        last = ' or '
    elseif trail == 'list' then
        last = ', '
    elseif trail == 'csv' then
        last = ','
    elseif trail == 'oxford' then
        last = ', and '
    elseif trail == 'oxford or' then
        last = ', or '
    else
        warning('Invalid format for table.format: \''..trail..'\'.')
    end

    local res = ''
    for i = 1, l.n do
        local add = tostring(l[i])
        if trail == 'csv' and add:match('[,"]') then
            res = res .. add:gsub('"', '""'):enclose('"')
        else
            res = res .. add
        end

        if i < l.n - 1 then
            if trail == 'csv' then
                res = res .. ','
            else
                res = res .. ', '
            end
        elseif i == l.n - 1 then
            res = res .. last
        end
    end

    return res
end

--[[
Copyright © 2013-2015, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
