--[[
Adds some tools for functional programming. Amends various other namespaces by functions used in a functional context, when they don't make sense on their own.
]]

_libs = _libs or {}
_libs.functools = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'

--[[
	Purely functional
]]

functools = {}

-- The empty function.
function functools.empty()
end

-- The identity function.
function functools.identity(...)
	return ...
end

-- Returns a partially applied function, depending on the number of arguments provided.
function functools.apply(fn, args)
	return function(...)
		return fn(T(args):copy():extend(T{...}):unpack())
	end
end

-- Returns a partially applied function, with the argument provided at the end.
function functools.endapply(fn, args)
	return function(...)
		return fn(T{...}:extend(T(args):copy()):unpack())
	end
end

-- Returns a function that calls a provided chain of functions in right-to-left order.
function functools.pipe(fn1, fn2)
	return function(...)
		return fn1(fn2(...))
	end
end

-- Returns a closure over the argument el that returns true, if its argument equals el.
function functools.equals(el)
	return function(cmp)
		return el == cmp
	end
end

-- Returns a negation function of a boolean function.
function functools.negate(fn)
	return function(...)
		return not (true == fn(...))
	end
end

-- Evaluates a function and returns a value as well as store it in a variable of the provided name.
function functools.tee(str, val)
	_G[str] = val
	return val
end

-- Returns a function that returns a subset of the provided function's elements according to a table slice.
-- * i == nil:	Returns all elements as a table
-- * j == nil:	Returns all elements from i until the end
function functools.slice(fn, i, j)
	return function(...)
		return T{fn(...)}:slice(i, j):unpack()
	end
end

-- Returns the ith element of a function.
function functools.select(fn, i)
	return functools.slice(fn, i, i)
end

-- Assigns a metatable on functions to introduce certain function operators.
-- * fn+{...} partially applies a function to arguments.
-- * fn-{...} partially applies a function to arguments from the end.
-- * fn1..fn2 pipes input from fn2 to fn1.
debug.setmetatable(functools.empty, {
	__index = functools.select,
	__add = functools.apply,
	__sub = functools.endapply,
	__concat = functools.pipe,
	__unm = functools.negate,
})

debug.getmetatable('').__mod = functools.tee

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
function math.sum(val1, val2)
	return val1 + val2
end

-- Multiplies two numbers.
function math.mult(val1, val2)
	return val1 * val2
end

--[[
	Table functions
]]

-- Returns an attribute of a table.
function table.get(t, att)
	return rawget(t, att)
end

-- Applies function fn to all elements of the table and returns the resulting table.
function table.map(t, fn)
	local res = T{}
	for key, val in pairs(t) do
		-- Evaluate fn with the element and store it.
		res[key] = fn(val)
	end

	return res
end

-- Analogon to table.map, but for array-tables. Possibility to include nil values.
-- DEPRECATED: Use Lists instead
function table.arrmap(t, fn)
	local res = T{}
	for key = 1, #t do
		-- Evaluate fn with the element and store it.
		res[key] = fn(t[key])
	end

	return res
end

-- Returns a table with all elements from t that satisfy the condition fn, or don't satisfy condition fn, if reverse is set to true. Defaults to false.
function table.filter(t, fn)
	if type(fn) ~= 'function' then
		fn = functools.equals(fn)
	end
	
	local res = T{}
	if T(t):isarray() then
		for _, val in ipairs(t) do
			if fn(val) then
				res:append(val)
			end
		end
	else
		for key, val in pairs(t) do
			-- Only copy if fn(val) evaluates to true
			if fn(val) then
				res[key] = val
			end
		end
	end

	return res
end

-- Returns a table with all elements from t whose keys satisfy the condition fn, or don't satisfy condition fn, if reverse is set to true. Defaults to false.
function table.filterkey(t, fn)
	if type(fn) ~= 'function' then
		fn = functools.equals(fn)
	end
	
	local res = T{}
	for key, val in pairs(t) do
		-- Only copy if fn(key) evaluates to true
		if fn(key) then
			res[key] = val
		end
	end

	return res
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
