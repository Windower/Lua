--[[
A library providing sets as a data structure.
]]

_libs = _libs or {}
_libs.sets = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.functools = _libs.functools or require 'functools'

set = {}

_meta = _meta or {}
_meta.S = {}
_meta.S.__index = function(s, x) if set[x] ~= nil then return set[x] else return table[x] end end
_meta.S.__class = 'Set'

function S(t)
	t = t or {}
	local s = {}

	if class(t) == 'List' then
		for _, val in ipairs(t) do
			s[val] = true
		end
	else
		for _, val in pairs(t) do
			s[val] = true
		end
	end

	return setmetatable(s, _meta.S)
end

function set.empty(s)
	return next(s) == nil
end

function set.length(s)
	local count = 0

	for _ in pairs(s) do
		count = count + 1
	end

	return count
end

_meta.S.__len = set.length

function set.flat(s)
	for el in pairs(s) do
		if type(el) == 'table' then
			return false
		end
	end

	return true
end

function set.equals(s1, s2)
	for el in pairs(s1) do
		if not rawget(s2, el) then
			return false
		end
	end

	for el in pairs(s2) do
		if not rawget(s1, el) then
			return false
		end
	end

	return true
end

_meta.S.__eq = set.equals

function set.union(s1, s2)
	if type(s2) ~= 'table' then
		s2 = S{s2}
	end

	s = {}

	for el in pairs(s1) do
		s[el] = true
	end
	for el in pairs(s2) do
		s[el] = true
	end

	return setmetatable(s, _meta.S)
end

_meta.S.__add = set.union

function set.intersection(s1, s2)
	s = {}
	for el in pairs(s1) do
		s[el] = rawget(s2, el)
	end

	return setmetatable(s, _meta.S)
end

_meta.S.__mul = set.intersection

function set.diff(s1, s2)
	if type(s2) ~= 'table' then
		s2 = S(s2)
	end

	s = {}

	for el in pairs(s1) do
		s[el] = (not rawget(s2, el) and true) or nil
	end

	return setmetatable(s, _meta.S)
end

_meta.S.__sub = set.diff

function set.sdiff(s1, s2)
	s = {}
	for el in pairs(s1) do
		s[el] = (not rawget(s2, el) and true) or nil
	end
	for el in pairs(s2) do
		s[el] = (not rawget(s1, el) and true) or nil
	end

	return setmetatable(s, _meta.S)
end

_meta.S.__pow = set.sdiff

function set.contains(s, el)
	return rawget(s, el) == true
end

function set.find(s, fn)
    if type(fn) ~= 'function' then
        fn = functools.equals(fn)
    end
    
    for el in pairs(s) do
        if fn(el) then
            return el
        end
    end
end

function set.add(s, el)
	rawset(s, el, true)
end

function set.remove(s, el)
	rawset(s, el, nil)
end

function set.it(s)
	local key = nil
	return function()
		key = next(s, key)
		return key
	end
end

function set.clear(s)
	for el in pairs(s) do
		rawset(s, el, nil)
	end

	return s
end

function set.copy(s)
	local res = {}

	for el in pairs(s) do
		res[el] = true
	end

	return setmetatable(res, _meta.S)
end

function set.reassign(s, sn)
	return s:clear():union(sn)
end

function set.tostring(s)
	local res = '{'
	for el in pairs(s) do
		res = res..el
		if next(s, el) ~= nil then
			res = res..', '
		end
	end

	return res..'}'
end

_meta.S.__tostring = set.tostring

function set.tovstring(s)
	local res = '{\n'
	for el in pairs(s) do
		res = res..'\t'..tostring(el)
		if next(s, el) then
			res = res..','
		end
		res = res..'\n'
	end

	return res..'}'
end

function set.sort(s, ...)
	if _libs.lists then
		return L(s):sort(...)
	end

	return T(s):sort(...)
end

function set.map(s, fn)
	local res = {}

	for el in pairs(s) do
		res[fn(el)] = true
	end

	return setmetatable(res, _meta.S)
end

function set.filter(s, fn)
	local res = {}
	for el in pairs(s) do
		res[el] = fn(el) == true or nil
	end

	return setmetatable(res, _meta.S)
end

function set.reduce(s, fn, init)
	local acc = init
	for el in pairs(s) do
		if acc == nil then
			acc = el
		else
			acc = fn(acc, el)
		end
	end

	return acc
end

function set.concat(s, str)
	str = str or ''
	local res = ''

	for el in pairs(s) do
		res = res..tostring(s)
		if next(s, el) then
			res = res..str
		end
	end

	return res
end

function set.format(s, trail, subs)
	local l
	if s:empty() then
		return subs or ''
	elseif #s == 1 then
		return '{'..tostring(next(s))..'}'
	elseif _libs.lists then
		l = L(s)
	else
		l = T(s)
	end

	trail = trail or 'and'

	local last
	if trail == 'and' then
		last = ' and '
	elseif trail == 'csv' then
		last = ', '
	elseif trail == 'oxford' then
		last = ', and '
	else
		warning('Invalid format for table.format: \''..trail..'\'.')
	end

	return l:slice(1, -2):concat(', ')..last..l:last()
end
