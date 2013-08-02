--[[
Vectors for operations in a d-dimensional space.
]]

_libs = _libs or {}
_libs.vectors = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.mathhelper = _libs.mathhelper or require 'mathhelper'

vector = {}

_meta = _meta or {}
_meta.V = {}
_meta.V.__index = vector
_meta.V.__class = 'Vector'

-- Constructor for vectors. Optionally provide length n, to avoid computing the length.
function V(t, n)
	t.n = n or #t
	return setmetatable(t, _meta.V)
end

-- Creates a zero-vector of dimension n.
function vector.zero(n)
	return vector.fill(n, 0)
end

-- Creates a vector of dimension n with all values set to k.
function vector.fill(n, k)
	local res = {}
	for i = 1, n do
		res[i] = k
	end

	res.n = n
	return setmetatable(res, _meta.V)
end

-- Creates a euclidean unit vector of dimension n for axis i.
function vector.unit(n, i)
	local res = {}
	for j = 1, n do
		res[j] = i == j and 1 or 0
	end

	res.n = n
	return setmetatable(res, _meta.V)
end

-- Returns the length of a vector measured from 0.
function vector.length(v)
	local length = 0
	for _, val in ipairs(v) do
		length = length + val^2
	end

	return math.sqrt(length)
end

-- Returns a vector in the same direction as v, normalized to length one.
function vector.normalize(v)
	return v:scale(1/v:length())
end

-- Returns the dimension of a vector. Constant.
function vector.dimension(v)
	return v.n
end

-- Returns the dot product between two vectors.
function vector.dot(v1, v2)
	local res = 0
	for i, val1 in ipairs(v1) do
		res = res + val1*v2[i]
	end

	return res
end

_meta.V.__mul = function(x, y) if type(x) == 'number' then return y:scale(x) elseif type(y) == 'number' then return x:scale(y) else return x:dot(y) end end

-- Returns the cross product of two R^3 vectors.
function vector.cross(v1, v2)
	local res = {}
	res[1] = v1[2]*v2[3] - v1[3]*v2[2]
	res[2] = v1[3]*v2[1] - v1[1]*v2[3]
	res[3] = v1[1]*v2[2] - v1[2]*v2[1]

	res.n = 3
	return setmetatable(res, _meta.V)
end

-- Returns v multiplied by k.
function vector.scale(v, k)
	local res = {}
	for i, val in ipairs(v) do
		res[i] = val*k
	end

	res.n = v.n
	return setmetatable(res, _meta.V)
end

-- Returns the opposite vector of v.
function vector.negate(v)
	return vector.scale(v, -1)
end

_meta.V.__unm = vector.negate

-- Returns v1 added to v2.
function vector.add(v1, v2)
	local res = {}
	for i, val in ipairs(v1) do
		res[i] = val+v2[i]
	end

	res.n = v1.n
	return setmetatable(res, _meta.V)
end

_meta.V.__add = vector.add

-- Returns v1 subtracted by v2.
function vector.subtract(v1, v2)
	local res = {}
	for i, val in ipairs(v1) do
		res[i] = val-v2[i]
	end

	res.n = v1.n
	return setmetatable(res, _meta.V)
end

_meta.V.__sub = vector.subtract

-- Returns the vector in string format: (...)
function vector.tostring(v)
	local str = '('
	for i, val in ipairs(v) do
		if i > 1 then
			str = str..', '
		end
		str = str..tostring(val)
	end

	return str..')'
end

_meta.V.__tostring = vector.tostring

function vector.tovstring(v)
	local str = ''
	for i, val in ipairs(v) do
		if i > 1 then
			str = str..'\n'
		end
		str = str..tostring(val)
	end

	return str
end

function vector.vprint(v)
	log(v:tovstring())
end
