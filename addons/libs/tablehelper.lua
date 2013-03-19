--[[
A few table helper functions, in addition to a new T-table interface, which enables method indexing on tables.

To define a T-table with explicit values use T{...}, to convert an existing table t, use T(t). To access table methods of a T-table t, use t:methodname(args).

Some functions, such as table.map(t, fn), are optimized for arrays. These functions have the same name as the regular functions, but preceded with an "arr", such as table.arrmap(t, fn). These are only needed, if explicit nil handling between keys is required, that is, if nil is an actual value in the table. This case is very rare, and should not normally be needed. Argument lists are an example of their application.
]]

_libs = _libs or {}
_libs.tablehelper = true
_libs.mathhelper = _libs.mathhelper or require 'mathhelper'
_libs.functools = _libs.functools or require 'functools'

-- Constructor for T-tables.
-- t = T{...} for explicit declaration.
-- t = T(regular_table) to cast to a T-table.
function T(t)
	-- Sets T's metatable's index to the table namespace, which will take effect for all T-tables.
	-- This makes every function that tables have also available for T-tables.
	return setmetatable(t, {__index = table})
end

_libs = T(_libs)

-- Returns true if searchval is in t.
function table.contains(t, searchval)
	for key, val in pairs(t) do
		if val == searchval then
			return true
		end
	end
	
	return false
end

-- Returns if the key searchkey is in t.
function table.containskey(t, searchkey)
	return t[searchkey] ~= nil
end

-- Appends an element to the end of an array table.
function table.append(t, val)
	t[#t+1] = val
	return t
end

-- Appends an array table to the end of another array table.
function table.extend(t, extt)
	for key, val in pairs(extt) do
		t[#t+1] = val
	end
	
	return t
end

-- Merges two dictionary tables and returns the result. Keys from the new table will overwrite old keys.
function table.merge(t, merget)
	if merget == nil then
		return t
	end
	for key, val in pairs(merget) do
		t[key] = val
	end
	
	return t
end

-- Returns a partial table sliced from t, equivalent to t[x:y] in certain languages.
-- Negative indices will be used to access the table from the other end.
function table.slice(t, from, to)
	from = from or 1
	if from < 0 then
		-- Modulo the negative index, to get it back into range.
		from = from%#t+1
	end
	to = to or #t
	if to < 0 then
		-- Modulo the negative index, to get it back into range.
		to = (to-1)%#t+1
	end
	
	-- Copy relevant elements into a blank T-table.
	local res = T{}
	for i = from, to do
		res[#res+1] = t[i]
	end
	
	return res;
end

-- Replaces t[from, to] with the contents of st and returns the table.
function table.splice(t, from, to, st)
	local tcpy = t:copy()
	
	for stkey = 1, #st do
		tkey = from + stkey - 1
		t[tkey] = st[stkey]
	end
	
	for cpykey = to+1, #tcpy do
		newkey = cpykey + #st - (to - from) - 1
		t[newkey] = tcpy[cpykey]
	end
	
	for rmkey = #t - (to - from) + #st, #t do
		t[rmkey] = nil
	end
	
	t = res
	
	return t
end

-- Returns a reversed table. Only works on arrays.
function table.reverse(t)
	local res = T{}
	for key = 1, math.ceil(#t/2) do
		if key == #t-key then
			res[key] = t[key]
		end
		res[key], res[#t-key+1] = t[#t-key+1], t[key]
	end
	
	return res
end

-- Returns an array removed of all duplicates.
function table.set(t)
	local seen = T{}
	local res = T{}
	for _, val in ipairs(t) do
		if seen[val] == nil then
			res:append(val)
			seen[val] = true
		end
	end
	
	return res
end

-- Returns a sorted set.
function table.sorted(t)
	local res = T(t)
	t:sort()
	return t
end

-- Return true if any element of t satisfies the condition fn.
function table.any(t, fn)
	for key, val in pairs(t) do
		if(fn(val) == true) then
			return true
		end
	end
	
	return false
end

-- Return true if all elements of t satisfy the condition fn.
function table.all(t, fn)
	for key, val in pairs(t) do
		if(fn(val) ~= true) then
			return false
		end
	end
	
	return true
end

-- Returns the values of the table, extracted into an argument list. Like unpack, but works on dictionaries as well.
function table.extract(t)
	local res = T{}
	-- Convert a (possible) dictionary into an array.
	for key, val in pairs(t) do
		res:append(val)
	end
	
	return res:unpack()
end

-- Returns a deepcopy of the table, including metatable and recursed over nested tables.
function table.copy(t)
	local res = T{}
	for key, val in pairs(t) do
		-- If a value is a table, recursively copy that.
		if type(val) == 'table' then
			val = T(val):copy()
		end
		res[key] = val
	end
	
	return setmetatable(res, getmetatable(t))
end

-- Concatenates all elements with a whitespace in between.
function table.sconcat(t)
	return table.concat(t, ' ')
end

-- Sum up all elements of a table.
function table.sum(t)
	return table.reduce(t, math.sum, 0)
end

-- Multiply all elements of a table.
function table.mult(t)
	return table.reduce(t, math.mult, 1)
end

-- Check if table is empty.
function table.isempty(t)
	return next(t) == nil
end
