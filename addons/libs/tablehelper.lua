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
	if t == nil then
		return
	end
	
	-- Sets T's metatable's index to the table namespace, which will take effect for all T-tables.
	-- This makes every function that tables have also available for T-tables.
	return setmetatable(t, {__index = table, __add = table.extend})
end

_libs = T(_libs)

-- Checks if a table is an array, only having sequential integer keys.
function table.isarray(t)
	local count = 0
	for _, _ in pairs(t) do
		count = count + 1
	end
	
	return count == #t
end

-- Returns the number of elements in a table.
function table.length(t)
	if t:isarray() then
		return #t
	end
	
	local count = 0
	for _, _ in pairs(t) do
		count = count + 1
	end
	
	return count
end

-- Returns the first element of an array, or the element at position n, if provided.
function table.first(t, n)
	n = n or 1
	return t[n]
end

-- Returns the last element of an array, or the element at position length-n, if provided.
function table.last(t, n)
	n = n or 1
	n = n - 1
	return t[#t-n]
end

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
function table.append(t, val, bla)
	t[#t+1] = val
	return t
end

-- Appends an array table to the end of another array table.
function table.extend(t, t_extend)
	if type(t_extend) ~= 'table' then
		return t:append(t_extend)
	end
	for _, val in ipairs(t_extend) do
		t:append(val)
	end
	
	return t
end

-- Returns the number of element in the table that satisfy fn. If fn is not a function, counts the number of occurrences of fn.
function table.count(t, fn)
	if type(fn) ~= 'function' then
		if type(fn) == nil then
			fn = boolean.exists
		else
			fn = functools.equals(fn)
		end
	end
	
	count = 0
	for _, val in pairs(t) do
		if fn(val) == true then
			count = count + 1
		end
	end
	
	return count
end

-- Removes all elements from a table.
function table.clear(t)
	t = T{}
	
	return t
end

-- Merges two dictionary tables and returns the result. Keys from the new table will overwrite keys.
function table.update(t, t_update, recursive, maxrec, rec)
	if t_update == nil then
		return t
	end
	
	recursive = recursive or false
	maxrec = maxrec or -1
	rec = rec or 0
	
	for key, val in pairs(t_update) do
		if t[key] ~= nil and recursive and rec ~= maxrec and type(t[key]) == 'table' and type(val) == 'table' then
			t[key] = T(t[key]):update(T(val), true, maxrec, rec + 1)
		else
			t[key] = val
		end
	end
	
	return t
end

-- Merges two dictionary tables and returns the results. Keys from the new table will not overwrite existing keys.
function table.amend(t, t_amend, recursive, maxrec, rec)
	if t_amend == nil then
		return t
	end
	
	recursive = recursive or false
	maxrec = maxrec or -1
	rec = rec or 0
	
	for key, val in pairs(t_amend) do
		if t[key] ~= nil and recursive and rec ~= maxrec and type(t[key]) == 'table' and type(val) == 'table' then
			t[key] = T(t[key]):amend(T(val), true, maxrec, rec + 1)
		elseif t[key] == nil then
			t[key] = val
		end
	end
	
	return t
end

-- Searches elements of a table for an element. If, instead of an element, a function is provided, will search for the first element to satisfy that function.
function table.find(t, el)
	local fn
	if type(el) ~= 'function' then
		fn = functools.equals(el)
	else
		fn = el
	end
	
	for key, val in pairs(t) do
		if fn(val) then
			return key, val
		end
	end
end

-- Returns the keys of a table in an array.
function table.keyset(t)
	local res = T{}
	for key, _ in pairs(t) do
		res:append(key)
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
				res:extend(T(val):flatten(recursive))
			else
				res:extend(val)
			end
		else
			res:append(val)
		end
	end
	
	return res
end

-- Returns true if all key-value pairs in t_eq equal all key-value pairs in t.
function table.equals(t, t_eq)
	local seen = T{}
	for key, val in pairs(t) do
		if t_eq[key] ~= val then
			return false
		end
		seen[key] = true
	end
	
	for key, val in pairs(t_eq) do
		if seen[key] == nil then
			return false
		end
	end
	
	return true
end

-- Removes and returns an element from t.
function table.delete(t, el)
	for key, val in pairs(t) do
		if val == el then
			if type(key) == 'number' then
				T(t):remove(key)
				return
			else
				local val = t[key]
				t[key] = nil
				return val
			end
		end
	end
end

-- Searches keys of a table according to a function fn. Returns the key and value, if found.
-- Searches keys of a table for an element. If, instead of an element, a function is provided, will search for the first element to satisfy that function.
function table.keyfind(t, fn)
	for key, val in pairs(t) do
		if fn(key) then
			return key, val
		end
	end
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

-- Backs up old table sorting function.
table._bak_sort = table.sort

-- Returns a sorted table.
function table.sort(t, ...)
	T(t):_bak_sort(...)
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

-- Returns an array containing values from start to finish. If no finish is specified, returns table.range(1, start)
function table.range(start, finish, step)
	if finish == nil then
		start, finish = 1, start
	end
	
	step = step or 1
	
	local res = T{}
	for key = start, finish, step do
		res:append(key)
	end
	
	return res
end

-- Backs up old table concat function.
table._bak_concat = table.concat

-- Concatenates all objects of a table. Converts to string, if not already so.
function table.concat(t, str)
	return T(t):map(tostring):_bak_concat(str)
end

-- Concatenates all elements with a whitespace in between.
function table.sconcat(t)
	return T(t):concat(' ')
end

-- Sum up all elements of a table.
function table.sum(t)
	return T(t):reduce(math.sum, 0)
end

-- Multiply all elements of a table.
function table.mult(t)
	return T(t):reduce(math.mult, 1)
end

-- Check if table is empty.
function table.isempty(t)
	return next(t) == nil
end
