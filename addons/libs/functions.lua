--[[
    Adds some tools for functional programming. Amends various other namespaces by functions used in a functional context, when they don't make sense on their own.
]]

_libs = _libs or {}

local string, math, table, coroutine = require('string'), require('math'), require('table'), require('coroutine')

functions = {}
boolean = {}

_libs.functions = functions

local functions, boolean = functions, boolean

-- The empty function.
functions.empty = function() end

debug.setmetatable(false, {__index = function(_, k)
    return boolean[k] or (_raw and _raw.error or error)('"%s" is not defined for booleans':format(tostring(k)), 2)
end})

for _, t in pairs({functions, boolean, math, string, table}) do
    t.fn = function(val)
        return function()
            return val
        end
    end
end

-- The identity function.
function functions.identity(...)
    return ...
end

-- Returns a function that returns a constant value.
function functions.const(val)
    return function()
        return val
    end
end

-- A function calling function.
function functions.call(fn, ...)
    return fn(...)
end

-- A function that executes the provided function if the provided condition is met.
function functions.cond(fn, check)
    return function(...)
        return check(...) and fn(...) or nil
    end
end

-- 
function functions.args(fn, ...)
    local args = {...}
    return function(...)
        local res = {}
        for key, arg in ipairs(args) do
            if type(arg) == 'number' then
                rawset(res, key, select(arg, ...))
            else
                rawset(res, key, arg(...))
            end
        end
        return fn(unpack(res))
    end
end

-- Returns a function fully applied to the provided arguments.
function functions.prepare(fn, ...)
    local args = {...}
    return function()
        return fn(unpack(args))
    end
end

-- Returns a partially applied function, depending on the number of arguments provided.
function functions.apply(fn, ...)
    local args = {...}
    return function(...)
        local res = {}
        for key, arg in ipairs(args) do
            res[key] = arg
        end
        local key = #args
        for _, arg in ipairs({...}) do
            key = key + 1
            res[key] = arg
        end
        return fn(unpack(res))
    end
end

-- Returns a partially applied function, with the argument provided at the end.
function functions.endapply(fn, ...)
    local args = {...}
    return function(...)
        local res = {...}
        local key = #res
        for _, arg in ipairs(args) do
            key = key + 1
            res[key] = arg
        end
        return fn(unpack(res))
    end
end

-- Returns a function that calls a provided chain of functions in right-to-left order.
function functions.pipe(fn1, fn2)
    return function(...)
        return fn1(fn2(...))
    end
end

-- Returns a closure over the argument el that returns true, if its argument equals el.
function functions.equals(el)
    return function(cmp)
        return el == cmp
    end
end

-- Returns a negation function of a boolean function.
function functions.negate(fn)
    return function(...)
        return not (true == fn(...))
    end
end

-- Returns the ith element of a function.
function functions.select(fn, i)
    return function(...)
        return select(i, fn(...))
    end
end

-- Returns an iterator over the results of a function.
function functions.it(fn, ...)
    local res = {fn(...)}
    local key = 0
    return function()
        key = key + 1
        return res[key]
    end
end

-- Schedules the current function to run delayed by the provided time in seconds
function functions.schedule(fn, time, ...)
    coroutine.schedule(fn:prepare(...), time)
end

-- Returns a function that, when called, will execute the underlying function delayed by the provided number of seconds
function functions.delay(fn, time, ...)
    local args = {...}

    return function()
        fn:schedule(time, unpack(args))
    end
end

-- Returns a wrapper table representing the provided function with additional functions:
function functions.loop(fn, interval, cond)
    if interval <= 0 then
        return
    end

    if type(cond) == 'number' then
        cond = function()
            local i = 0
            local lim = cond
            return function()
                i = i + 1
                return i <= lim
            end
        end()
    end
    cond = cond or true:fn()

    return coroutine.schedule(function()
        while cond() do
            fn()
            coroutine.sleep(interval)
        end
    end, 0)
end

--[[
    Various built-in wrappers
]]

-- tostring wrapper
function functions.string(fn)
    return tostring(fn)
end

-- type wrapper
function functions.type(fn)
    return type(fn)
end

-- class wrapper
function functions.class(fn)
    return class(fn)
end

local function index(fn, key)
    if type(key) == 'number' then
        return fn:select(key)
    elseif rawget(functions, key) then
        return function(...)
            return functions[key](...)
        end
    end

    (_raw and _raw.error or error)('"%s" is not defined for functions':format(tostring(key)), 2)
end

local function add(fn, args)
    return fn:apply(unpack(args))
end

local function sub(fn, args)
    return fn:endapply(unpack(args))
end

-- Assigns a metatable on functions to introduce certain function operators.
-- * fn+{...} partially applies a function to arguments.
-- * fn-{...} partially applies a function to arguments from the end.
-- * fn1..fn2 pipes input from fn2 to fn1.

debug.setmetatable(functions.empty, {
    __index = index,
    __add = add,
    __sub = sub,
    __concat = functions.pipe,
    __unm = functions.negate,
    __class = 'Function'
})

--[[
    Logic functions
Mainly used to pass as arguments.
]]

-- Returns true if element is true.
function boolean._true(val)
    return val == true
end

-- Returns false if element is false.
function boolean._false(val)
    return val == false
end

-- Returns the negation of a value.
function boolean._not(val)
    return not val
end

-- Returns true if both values are true.
function boolean._and(val1, val2)
    return val1 and val2
end

-- Returns true if either value is true.
function boolean._or(val1, val2)
    return val1 or val2
end

-- Returns true if element exists.
function boolean._exists(val)
    return val ~= nil
end

-- Returns true if two values are the same.
function boolean._is(val1, val2)
    return val1 == val2
end

--[[
    Math functions
]]

-- Returns true, if num is even, false otherwise.
function math.even(num)
    return num % 2 == 0
end

-- Returns true, if num is odd, false otherwise.
function math.odd(num)
    return num % 2 == 1
end

-- Adds two numbers.
function math.add(val1, val2)
    return val1 + val2
end

-- Multiplies two numbers.
function math.mult(val1, val2)
    return val1 * val2
end

-- Subtracts one number from another.
function math.sub(val1, val2)
    return val1 - val2
end

-- Divides one number by another.
function math.div(val1, val2)
    return val1 / val2
end

--[[
    Table functions
]]

-- Returns an attribute of a table.
function table.get(t, ...)
    local res = {}
    for i = 1, select('#', ...) do
        rawset(res, i, t[select(i, ...)])
    end
    return unpack(res)
end

-- Returns an attribute of a table without invoking metamethods.
function table.rawget(t, ...)
    local res = {}
    for i = 1, select('#', ...) do
        rawset(res, i, rawget(t, select(i, ...)))
    end
    return unpack(res)
end

-- Sets an attribute of a table to a specified value.
function table.set(t, ...)
    for i = 1, select('#', ...), 2 do
        t[select(i, ...)] = select(i + 1, ...)
    end
    return t
end

-- Sets an attribute of a table to a specified value, without invoking metamethods.
function table.rawset(t, ...)
    for i = 1, select('#', ...), 2 do
        rawset(t, select(i, ...), select(i + 1, ...))
    end
    return t
end

-- Looks up the value of a table element in another table
function table.lookup(t, ref, key)
    return ref[t[key]]
end

table.it = function()
    local it = function(t)
        local key

        return function()
            key = next(t, key)
            return t[key], key
        end
    end

    return function(t)
        local meta = getmetatable(t)
        if not meta then
            return it(t)
        end

        local index = meta.__index
        if index == table then
            return it(t)
        end

        local fn = type(index) == 'table' and index.it or index(t, 'it') or it
        return (fn == table.it and it or fn)(t)
    end
end()

-- Applies function fn to all values of the table and returns the resulting table.
function table.map(t, fn)
    local res = {}
    for value, key in table.it(t) do
        -- Evaluate fn with the element and store it.
        res[key] = fn(value)
    end

    return setmetatable(res, getmetatable(t))
end

-- Applies function fn to all keys of the table, and returns the resulting table.
function table.key_map(t, fn)
    local res = {}
    for value, key in table.it(t) do
        res[fn(key)] = value
    end

    return setmetatable(res, getmetatable(t))
end

-- Returns a table with all elements from t that satisfy the condition fn, or don't satisfy condition fn, if reverse is set to true. Defaults to false.
function table.filter(t, fn)
    if type(fn) ~= 'function' then
        fn = functions.equals(fn)
    end

    local res = {}
    for value, key in table.it(t) do
        -- Only copy if fn(val) evaluates to true
        if fn(value) then
            res[key] = value
        end
    end

    return setmetatable(res, getmetatable(t))
end

-- Returns a table with all elements from t whose keys satisfy the condition fn, or don't satisfy condition fn, if reverse is set to true. Defaults to false.
function table.key_filter(t, fn)
    if type(fn) ~= 'function' then
        fn = functions.equals(fn)
    end

    local res = {}
    for value, key in table.it(t) do
        -- Only copy if fn(key) evaluates to true
        if fn(key) then
            res[key] = value
        end
    end

    return setmetatable(res, getmetatable(t))
end

-- Returns the result of applying the function fn to the first two elements of t, then again on the result and the next element from t, until all elements are accumulated.
-- init is an optional initial value to be used. If provided, init and t[1] will be compared first, otherwise t[1] and t[2].
function table.reduce(t, fn, init)
    -- Set the accumulator variable to the init value (which can be nil as well)
    local acc = init
    for value in table.it(t) do
        if init then
            acc = fn(acc, value)
        else
            acc = value
            init = true
        end
    end

    return acc
end

-- Return true if any element of t satisfies the condition fn.
function table.any(t, fn)
    for value in table.it(t) do
        if fn(value) then
            return true
        end
    end

    return false
end

-- Return true if all elements of t satisfy the condition fn.
function table.all(t, fn)
    for value in table.it(t) do
        if not fn(value) then
            return false
        end
    end

    return true
end

--[[
    String functions.
]]

-- Checks for exact string equality.
function string.eq(str, strcmp)
    return str == strcmp
end

-- Checks for case-insensitive string equality.
function string.ieq(str, strcmp)
    return str:lower() == strcmp:lower()
end

-- Applies a function to every character of str, concatenates the result.
function string.map(str, fn)
    return (str:gsub('.', fn))
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
