--[[
Adds some tools for functional programming. Amends various other namespaces by functions used in a functional context, when they don't make sense on their own.
]]

_libs = _libs or {}
_libs.functions = true

--[[
    Purely functional
]]

functions = {}

-- The empty function.
function functions.empty()
end

debug.setmetatable(functions.empty, functions)

-- The identity function.
function functions.identity(...)
    return ...
end

-- Returns a partially applied function, depending on the number of arguments provided.
function functions.apply(fn, args)
    return function(...)
        local key = #args + 1
        for _, arg in ipairs({...}) do
            args[key] = arg
            key = key + 1
        end
        return fn(unpack(args))
    end
end

-- Returns a partially applied function, with the argument provided at the end.
function functions.endapply(fn, args)
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

-- tostring wrapper
function functions.string(fn)
    return tostring(fn)
end

local function index(fn, key)
    if type(key) == 'number' then
        return fn.select(key)
    elseif rawget(functions, key) then
        return function(...)
            return functions[key](fn, ...)
        end
    end

    return nil
end

-- Assigns a metatable on functions to introduce certain function operators.
-- * fn+{...} partially applies a function to arguments.
-- * fn-{...} partially applies a function to arguments from the end.
-- * fn1..fn2 pipes input from fn2 to fn1.
debug.setmetatable(functions.empty, {
    __index = index,
    __add = functions.apply,
    __sub = functions.endapply,
    __concat = functions.pipe,
    __unm = functions.negate,
    __class = 'Function'
})

--[[
    Logic functions
Mainly used to pass as arguments.
]]

boolean = {}

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
    return val1 ~= val2
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

-- Accesses a table key. Invoked metamethods.
function table.index(t, key)
    return t[key]
end

-- Returns an attribute of a table.
function table.get(t, att)
    return t[att]
end

-- Returns an attribute of a table without invoking metamethods.
function table.rawget(t, att)
    return rawget(t, att)
end

-- Sets an attribute of a table to a specified value.
function table.set(t, att, val)
    t[att] = val
    return t
end

-- Sets an attribute of a table to a specified value, without invoking metamethods.
function table.rawset(t, att, val)
    rawset(t, att, val)
    return t
end

-- Applies function fn to all elements of the table and returns the resulting table.
function table.map(t, fn)
    local res = {}
    for key, val in pairs(t) do
        -- Evaluate fn with the element and store it.
        res[key] = fn(val)
    end

    return setmetatable(res, getmetatable(t))
end

-- Returns a table with all elements from t that satisfy the condition fn, or don't satisfy condition fn, if reverse is set to true. Defaults to false.
function table.filter(t, fn)
    if type(fn) ~= 'function' then
        fn = functions.equals(fn)
    end

    local res = {}
    for key, val in pairs(t) do
        -- Only copy if fn(val) evaluates to true
        if fn(val) then
            res[key] = val
        end
    end

    return setmetatable(res, getmetatable(t))
end

-- Returns a table with all elements from t whose keys satisfy the condition fn, or don't satisfy condition fn, if reverse is set to true. Defaults to false.
function table.filterkey(t, fn)
    if type(fn) ~= 'function' then
        fn = functions.equals(fn)
    end

    local res = {}
    for key, val in pairs(t) do
        -- Only copy if fn(key) evaluates to true
        if fn(key) then
            res[key] = val
        end
    end

    return setmetatable(res, getmetatable(t))
end

-- Returns the result of applying the function fn to the first two elements of t, then again on the result and the next element from t, until all elements are accumulated.
-- init is an optional initial value to be used. If provided, init and t[1] will be compared first, otherwise t[1] and t[2].
function table.reduce(t, fn, init)
    -- Return the initial argument if table is empty
    if not next(t) then
        return init
    end

    -- Set the accumulator variable to the init value (which can be nil as well)
    local acc = init
    for _, val in pairs(t) do
        -- If the accumulator is nil, which can only happen on the first iteration and if no initial value was provided, set acc to the first value val.
        if acc == nil then
            acc = val
        -- If not, which will hold true for all subsequent values, apply the funtion to the accumulated value and the next table value and store the result.
        else
            acc = fn(acc, val)
        end
    end

    return acc
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
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
