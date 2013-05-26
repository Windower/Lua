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
_meta.L.__index = function(l, k) if list[k] ~= nil then return list[k] else return T(l)[k] end end
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

function list.last(l, i)
	return l[l.n - (i and i - 1 or 0)]
end

function list.insert(l, i, el)
	l.n = l.n + 1
	table.insert(l, i, el)
end

function list.remove(l, i)
	i = i or l.n
	local res = l[i]
	
	for key = i, l.n do
		l[key] = l[key + 1]
	end
	
	l.n = l.n - 1
	return res
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

function list.concat(l, str)
	str = str or ''
	local res = ''
	
	for key = 1, l.n do
		res = res..tostring(rawget(l, key))
		if key < l.n then
			res = res..str
		end
	end
	
	return res
end

function list.clear(l)
	for key in ipairs(l) do
		l[key] = nil
	end
	
	l.n = 0
	return l
end

function list.with(l, attr, val)
	for _, el in ipairs(l) do
		if type(el) == 'table' and rawget(el, attr) == val then
			return el
		end
	end
end

function list.iwith(l, attr, val)
	local cel
	val = val:lower()
	for _, el in ipairs(l) do
		if type(el) == 'table' then
			cel = rawget(el, attr)
			if type(cel) == 'string' and cel:lower() == val then
				return el
			end
		end
	end
end

function list.map(l, fn)
	local res = {}

	for key, val in ipairs(l) do
		res[key] = fn(val)
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
			res[key] = val
		end
	end
	
	res.n = key
	return setmetatable(res, _meta.L)
end

function list.reduce(l, fn, init)
	local acc = init
	for _, val in ipairs(l) do
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
	local val
	local flat
	local n2
	for k1 = 1, l.n do
		val = l[key]
		if type(val) == 'table' then
			if rec then
				flat = list.flatten(val, rec)
				n2 = flat.n
				for k2 = 1, n2 do
					res[key + k2] = flat[k2]
				end
				key = key + n2
			else
				n2 = #val
				for k2 = 1, n2 do
					res[key + k2] = val[k2]
				end
			end
			key = key + n2
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
		return l[key], key
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
	local key = 0
	for i = from, to do
		key = key + 1
		res[key] = l[i]
	end

	res.n = key
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

	res.n = n
	return setmetatable(res, _meta.L)
end

function list.range(n)
	local res = {}
	
	for key = 1, n do
		res[key] = key
	end
	
	res.n = n
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
