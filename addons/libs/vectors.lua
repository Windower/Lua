--[[
Vectors for operations in a d-dimensional space.
]]

_libs = _libs or {}

require('tables')
require('maths')

local table, math = _libs.tables, _libs.maths

vector = {}

_libs.vectors = vector

_meta = _meta or {}
_meta.V = {}
_meta.V.__index = vector
_meta.V.__class = 'Vector'

-- Constructor for vectors. Optionally provide dimension n, to avoid computing the dimension from the table.
function V(t, n)
    local res = {}
    res.n = n or t.n or #t
    for i = 1, res.n do
        res[i] = t[i]
    end

    return setmetatable(res, _meta.V)
end

_meta.V.__unp = V:args(1)

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

-- Returns the dimension of v. Constant.
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

-- Returns v multiplied by k, i.e. all elements multiplied by the same factor.
function vector.scale(v, k)
    local res = {}
    for i, val in ipairs(v) do
        res[i] = val*k
    end

    res.n = v.n
    return setmetatable(res, _meta.V)
end

-- Returns the vector pointing in the opposite direction of v with the same length.
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

-- Returns the angle described by two vectors (in radians).
function vector.angle(v1, v2)
    return ((v1 * v2) / (v1:length() * v2:length())):acos()
end

-- Returns a normalized 2D vector from a radian value.
-- Note that this goes against mathematical convention, which commonly makes the radian go counter-clockwise.
-- This function, instead, goes clockwise, i.e. it will return *(0, -1)* for ''π/2''.
-- This is done to match the game's internal representation, which has the X axis pointing east and the Y axis pointing south.
function vector.from_radian(r)
    return V{r:cos(), -r:sin()}
end

-- Returns the radian that describes the direction of the vector.
function vector.to_radian(v)
    return (v[2] < 0 and 1 or -1) * v:normalize()[1]:acos()
end

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

--[[
Copyright © 2013-2014, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
