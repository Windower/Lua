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

-- Returns a partially applied function, depending on the number of arguments provided.
function functools.curry(fn, ...)
	local args = T{...}
	return function(...)
		return fn(args:extend(T{...}):unpack())
	end
end

-- Returns a closure over the argument el that returns true, if its argument equals el.
function functools.equals(...)
	local args = T{...}
	return function(...)
		return args:equals(T{...})
	end
end

-- Returns a negation function of a boolean function.
function functools.negate(fn)
	return function(...)
		return not (true == fn(...))
	end
end

-- Returns the identity function.
function functools.identity()
	return function(...)
		return ...
	end
end

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
	return num%2 == 0
end

-- Returns true, if num is odd, false otherwise.
function math.odd(num)
	return num%2 == 1
end

-- Adds two numbers.
function math.sum(val1, val2)
	return val1+val2
end

-- Multiplies two numbers.
function math.mult(val1, val2)
	return val1*val2
end

--[[
	Table functions
]]

-- Applies function fn to all elements of the table and returns the resulting table.
function table.map(t, fn)
	local res = T{}
	for key, val in pairs(t) do
		-- Evaluate fn with the element and store it.
		res[key] = fn(val)
	end
	
	return res
end

-- Flattens a table by splicing all nested tables in at their respective position.
function table.flatten(t, recursive)
	recursive = recursive or true
	
	local res = T{}
	for key, val in ipairs(t) do
		if type(val) == 'table' then
			if recursive then
				res:extend(val:flatten(true))
			else
				res:extend(val)
			end
		else
			res:append(val)
		end
	end
	
	return res
end

-- Analogon to table.map, but for array-tables. Possibility to include nil values.
function table.arrmap(t, fn)
	local res = T{}
	for key = 1, #t do
		-- Evaluate fn with the element and store it.
		res[key] = fn(t[key])
	end
	
	return res
end

-- Returns a table with all elements from t that satisfy the condition fn, or don't satisfy condition fn, if reverse is set to true. Defaults to false.
function table.filter(t, fn, reverse)
	reverse = reverse or false
	
	local res = T{}
	for key, val in pairs(t) do
		-- Only copy if fn(val) evaluates to true
		if not (reverse == fn(val)) then
			res[key] = val
		end
	end
	
	return res
end

-- Returns a table with all elements from t whose keys satisfy the condition fn, or don't satisfy condition fn, if reverse is set to true. Defaults to false.
function table.filterkey(t, fn, reverse)
	reverse = reverse or false
	
	local res = T{}
	for key, val in pairs(t) do
		-- Only copy if fn(key) evaluates to true
		if not (reverse == fn(key)) then
			res[key] = val
		end
	end
	
	return res
end

-- Returns the result of applying the function fn to the first two elements of t, then again on the result and the next element from t, until all elements are accumulated.
-- init is an optional initial value to be used. If provided, init and t[1] will be compared first, otherwise t[1] and t[2].
function table.reduce(t, fn, init)
	t = T(t)
	
	-- Return the initial argument if table is empty
	if t:isempty() then
		return init
	end
	
	-- Set the accumulator variable to the init value (which can be nil as well)
	local acc = init
	for key, val in pairs(t) do
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
