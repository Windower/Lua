--[[
A library providing sets as a data structure.
]]

_libs = _libs or {}
_libs.sets = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'

set = {}

_meta = _meta or {}
_meta.S = {}
_meta.S.__index = function(s, x) if set[x] ~= nil then return set[x] else return T(s)[x] end end
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

function set.length(s)
	local count = 0
	
	for _ in pairs(s) do
		count = count + 1
	end
	
	return count
end

_meta.S.__len = set.length

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

function set.remove(s1, s2)
	if type(s2) ~= 'table' then
		s2 = S(s2)
	end
	
	s = {}
	
	for el in pairs(s1) do
		s[el] = (not rawget(s2, el) and true) or nil
	end
	
	return setmetatable(s, _meta.S)
end

_meta.S.__sub = set.remove

function set.diff(s1, s2)
	s = {}
	for el in pairs(s1) do
		s[el] = (not rawget(s2, el) and true) or nil
	end
	for el in pairs(s2) do
		s[el] = (not rawget(s1, el) and true) or nil
	end
	
	return setmetatable(s, _meta.S)
end

_meta.S.__pow = set.diff

function set.contains(s, el)
	return rawget(s, el) == true
end

function set.add(s, el)
	s[el] = true
end

function set.remove(s, el)
	s[el] = nil
end

function set.it(s)
	return coroutine.wrap(function()
		for el in pairs(s) do
			coroutine.yield(el)
		end
	end)
end

function set.tostring(s)
	res = '{'
	for el in pairs(s) do
		res = res..el
		if next(s, el) then
			res = res..', '
		end
	end
	
	return res..'}'
end

_meta.S.__tostring = set.tostring

