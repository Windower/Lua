--[[
A library providing advanced list support and better optimizations for list-based operations.
]]

_libs = _libs or {}
_libs.lists = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'

_raw = _raw or {}
_raw.table = _raw.table or {}

list = {}

_meta = _meta or {}
_meta.L = {}
_meta.L.__index = function(l, x) if list[x] ~= nil then return list[x] else return T(l)[x] end end
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

function list.length(l)
	return l.n
end

_meta.L.__len = list.length

function list.append(l, el)
	l.n = l.n + 1
	l[l.n] = el
end

function list.insert(l, i, el)
	l.n = l.n + 1
	table.insert(l, i, el)
end

function list.remove(l, i)
	i = i or l.n
	local res = l[i]
	if res == nil then
		return nil
	end
	
	l.n = l.n - 1
	
	return table.remove(l, i)
end

function list.extend(l1, l2)
	local n1 = l1.n
	local n2 = l2.n
	for k = 1, n2 do
		l1[n1 + k] = l2[k]
	end
	
	l1.n = n1 + n2
	return l1
end

function list.contains(l, el)
	for _, val in ipairs(l) do
		if val == el then
			return true
		end
	end
	
	return false
end

function list.count(l, fn)
	local count = 0
	if type(fn) ~= 'function' then
		for _, val in ipairs(l) do
			if val == fn then
				count = count + 1
			end
		end
	else
		for _, val in ipairs(l) do
			if fn(val) then
				count = count + 1
			end
		end
	end
	
	return count
end

function list.clear(l)
	for key in ipairs(l) do
		l[key] = nil
	end
	
	l.n = 0
	return l
end

function list.map(l, fn)
	local res = {}
	
	for key, val in ipairs(l) do
		res[key] = fn(val)
	end
	
	return setmetatable(res, _meta.L)
end

function list.filter(l, fn)
	local res = {}
	
	local key = 0
	for _, val in ipairs(l) do
		if fn(val) == true then
			key = key + 1
			res[key] = val
		end
	end
	
	res.n = key
	return setmetatable(res, _meta.L)
end

function list.reduce(l, fn, init)
	local acc = init
	for _, val in ipairs(t) do
		if acc == nil then
			acc = val
		else
			acc = fn(acc, val)
		end
	end
	
	return acc
end

function list.flatten(l, rec)
	rec = true and (rec ~= false)
	
	local res = {}
	local key = 1
	local flat
	for key, val in ipairs(l) do
		if type(val) == 'table' then
			if rec then
				flat = list.flatten(val, rec)
				list.extend(res, flat)
				key = key + flat.n
			else
				list.extend(res, val)
				if class(val) == 'List' then
					key = key + val.n
				else
					key = key + #val
				end
			end
		else
			res[key] = val
			key = key + 1
		end
	end

	res.n = key
	return setmetatable(res, _meta.L)
end

function list.it(l)
	local key = 0
	return function()
		key = key + 1
		return l[key]
	end
end

function list.equals(l1, l2)
	if l1.n ~= l2.n then
		return false
	end
	
	for key, val in ipairs(l1) do
		if val ~= l2[key] then
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
	local key = 1
	for i = from, to do
		res[key] = l[i]
		key = key + 1
	end
	
	return setmetatable(res, _meta.L)
end

function list.splice(l1, from, to, l2)
	-- TODO
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
		res[key] = l[rkey]
		rkey = rkey - 1
	end

	return setmetatable(res, _meta.L)
end

function list.any(l, fn)
	for _, val in ipairs(l) do
		if fn(val) == true then
			return true
		end
	end

	return false
end

function list.all(l, fn)
	for _, val in ipairs(l) do
		if fn(val) ~= true then
			return false
		end
	end

	return true
end

function list.tostring(l)
	local str = '['
	
	for key, val in ipairs(l) do
		if key > 1 then
			str = str..', '
		end
		str = str..tostring(val)
	end
	
	return str..']'
end

_meta.L.__tostring = list.tostring
