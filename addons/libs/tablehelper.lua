--[[
A few table helper functions, in addition to a new T-table interface, which enables method indexing on tables.

To define a T-table with explicit values use T{...}, to convert an existing table t, use T(t). To access table methods of a T-table t, use t:methodname(args).

Some functions, such as table.map(t, fn), are optimized for arrays. These functions have the same name as the regular functions, but preceded with an "arr", such as table.arrmap(t, fn). These are only needed, if explicit nil handling between keys is required, that is, if nil is an actual value in the table. This case is very rare, and should not normally be needed. Argument lists are an example of their application.
]]

_libs = _libs or {}
_libs.tablehelper = true
_libs.mathhelper = _libs.mathhelper or require 'mathhelper'
_libs.functools = _libs.functools or require 'functools'

_raw = _raw or {}
_raw.table = _raw.table or {}
_raw.table = setmetatable(_raw.table, {__index=table})

--[[
	Signatures
]]

_meta = _meta or {}
_meta.T = _meta.T or {}
_meta.T.__index = table
_meta.T.__class = 'Table'

_meta.N = {}
_meta.N.__class = 'Nil'

-- Constructor for T-tables.
-- t = T{...} for explicit declaration.
-- t = T(regular_table) to cast to a T-table.
function T(t)
	t = t or {}
	if class(t) == 'Set' then
		local res = T{}
		
		for el in pairs(s) do
			res:append(s)
		end
		
		t = res
	end
	
	-- Sets T's metatable's index to the table namespace, which will take effect for all T-tables.
	-- This makes every function that tables have also available for T-tables.
	return setmetatable(t, _meta.T)
end

function N()
	return setmetatable({}, _meta.N)
end

function class(o)
	local mt = getmetatable(o)
	
	return mt and mt.__class or type(o)
end

_libs = T(_libs)
_meta = T(_meta)

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

-- Returns the last element of an array, or the element at position (length-n+1), if n provided.
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
function table.append(t, val)
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

_meta.T.__add = table.extend

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
	for key in pairs(t) do
		t[key] = nil
	end

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
		if t[key] ~= nil and recursive and rec ~= maxrec and type(t[key]) == 'table' and type(val) == 'table' and not table.isarray(val) then
			t[key] = table.update(t[key], val, true, maxrec, rec + 1)
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

	local cmp
	for key, val in pairs(t_amend) do
		if t[key] ~= nil and recursive and rec ~= maxrec and type(t[key]) == 'table' and type(val) == 'table' and not table.isarray(val) then
			t[key] = table.amend(t[key], val, true, maxrec, rec + 1)
		elseif t[key] == nil then
			t[key] = val
		end
	end

	return t
end

-- Merges two tables like update would, but retains type-information and tries to work around conflicts.
function table.merge(t, t_merge, splitchar, silent)
	if t_merge == nil then
		return t
	end
	
	splitchar = splitchar or ','
	silent = silent or false

	local oldval
	for key, val in pairs(t_merge) do
		oldval = t[key]
		if val ~= nil then
			if type(oldval) == 'table' and type(val) == 'table' then
				t[key] = table.merge(oldval, val)
			elseif type(oldval) ~= type(val) then
				if type(oldval) == 'table' then
					if type(val) == 'string' then
						t[key] = table.map(val:split(splitchar), string.trim)
					elseif not silent then
						notice('Could not safely merge values (key '..key..'):', oldval, '|', val, '|')
					end
				elseif type(oldval) == 'number' then
					local testdec = tonumber(val)
					local testhex = tonumber(val, 16)
					if testdec then
						t[key] = testdec
					elseif testhex then
						t[key] = testhex
					elseif not silent then
						notice('Could not safely merge values (key '..key..'):', oldval, '|', val, '|')
					end
				elseif type(oldval == 'boolean') then
					if val == 'true' then
						t[key] = true
					elseif val == 'false' then
						t[key] = false
					elseif not silent then
						notice('Could not safely merge values (key '..key..'):', oldval, '|', val, '|')
					end
				elseif type(oldval == 'string') then
					t[key] = val
				elseif not silent then
					notice('Could not safely merge values (key '..key..'):', oldval, '|', val, '|')
				end
			else
				t[key] = val
			end
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
	local res = {}
	for key, _ in pairs(t) do
		res[#res + 1] = key
	end

	return T(res)
end

-- Flattens a table by splicing all nested tables in at their respective position.
function table.flatten(t, recursive)
	recursive = true and (recursive ~= false)
	
	local res = {}
	local key = 1
	local flat = {}
	for key, val in ipairs(t) do
		if type(val) == 'table' then
			if recursive then
				flat = table.flatten(val, recursive)
				table.extend(res, flat)
				key = key + #flat
			else
				table.extend(res, val)
				key = key + #val
			end
		else
			res[key] = val
			key = key + 1
		end
	end

	return T(res)
end

-- Returns true if all key-value pairs in t_eq equal all key-value pairs in t.
function table.equals(t, t_eq)
	local seen = {}
	
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
				return table.remove(t, key)
			else
				local ret = t[key]
				t[key] = nil
				return ret
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
	local n  = #t
	
	from = from or 1
	if from < 0 then
		-- Modulo the negative index, to get it back into range.
		from = (from % n) + 1
	end
	to = to or n
	if to < 0 then
		-- Modulo the negative index, to get it back into range.
		to = (to % n) + 1
	end

	-- Copy relevant elements into a blank T-table.
	local res = {}
	local key = 1
	for i = from, to do
		res[key] = t[i]
		key = key + 1
	end

	return setmetatable(res, getmetatable(t) or _meta.T)
end

-- Replaces t[from, to] with the contents of st and returns the table.
function table.splice(t, from, to, st)
	local n1 = #t
	local n2 = #st
	local tcpy = table.copy(t)

	for stkey = 1, n2 do
		tkey = from + stkey - 1
		t[tkey] = st[stkey]
	end

	for cpykey = to + 1, n1 do
		newkey = cpykey + n2 - (to - from) - 1
		t[newkey] = tcpy[cpykey]
	end

	local nn = #t
	for rmkey = nn - (to - from) + n2, nn do
		t[rmkey] = nil
	end

	t = res

	return t
end

-- Returns a reversed array.
function table.reverse(t)
	local res = T{}
	
	local n = #t
	local rkey = n
	for key = 1, n do
		res[key] = t[rkey]
		rkey = rkey - 1
	end

	return res
end

-- Returns an array removed of all duplicates.
function table.set(t)
	local seen = {}
	local res = {}
	local key = 1
	for _, val in ipairs(t) do
		if seen[val] == nil then
			res[key] = val
			key = key + 1
			seen[val] = true
		end
	end

	return setmetatable(res, getmetatable(t) or _meta.T)
end

-- Backs up old table sorting function.
_raw.table.sort = table.sort

-- Returns a sorted table.
function table.sort(t, ...)
	_raw.table.sort(t, ...)
	return setmetatable(t, getmetatable(t) or _meta.T)
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
	local res = {}
	-- Convert a (possible) dictionary into an array.
	local i = 1
	for key, val in pairs(t) do
		res[i] = val
		i = i + 1
	end

	return table.unpack(res)
end

-- Returns a deepcopy of the table, including metatable and recursed over nested tables.
function table.copy(t)
	local res = {}
	for key, val in pairs(t) do
		-- If a value is a table, recursively copy that.
		if type(val) == 'table' then
			val = table.copy(val)
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

	local res = {}
	for key = start, finish, step do
		res[key] = key
	end

	return T(res)
end

-- Splits an array into an array of arrays of fixed length.
function table.chunks(t, size)
	return table.range(math.ceil(t:length()/size)):map(function(i) return t:slice(size*(i - 1) + 1, size*i) end)
end

-- Backs up old table concat function.
_raw.table.concat = table.concat

-- Concatenates all objects of a table. Converts to string, if not already so.
function table.concat(t, str)
	return _raw.table.concat(table.map(t, tostring), str)
end

-- Concatenates all elements with a whitespace in between.
function table.sconcat(t)
	return table.concat(t, ' ')
end

-- Check if table is empty.
function table.isempty(t)
	return next(t) == nil
end

-- Sum up all elements of a table.
function table.sum(t)
	return table.reduce(t, math.sum, 0)
end

-- Multiply all elements of a table.
function table.mult(t)
	return table.reduce(t, math.mult, 1)
end

-- Returns the minimum element of the table.
function table.min(t)
	return table.reduce(t, math.min)
end

-- Returns the maximum element of the table.
function table.min(t)
	return table.reduce(t, math.max)
end
