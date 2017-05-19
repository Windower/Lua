--[[
Library for a matrix data structure and operations defined on it.
]]

_libs = _libs or {}

require('tables')
require('maths')
require('vectors')

local table, math, vector = _libs.tables, _libs.maths, _libs.vectors

matrix = {}

_libs.matrices = matrix

_meta = _meta or {}
_meta.M = _meta.M or {}
_meta.M.__index = matrix
_meta.M.__class = 'Matrix'

-- Constructor for vectors.
-- matrix.m is the row-dimension
-- matrix.n is the column-dimension
function M(t)
    t.rows, t.cols = #t, #t[1]
    return setmetatable(t, _meta.M)
end

-- Returns a transposed matrix.
function matrix.transpose(m)
    local res = {}
    for i, row in ipairs(m) do
        for j, val in ipairs(row) do
            res[j][i] = val
        end
    end

    res.rows, res.cols = m.cols, m.rows
    return res
end

-- Returns the identity matrix of dimension n.
function matrix.identity(n)
    local res = {}
    for i = 1, n do
        res[i] = {}
        for j = 1, n do
            res[i][j] = i == j and 1 or 0
        end
    end

    res.rows, res.cols = n, n
    return setmetatable(res, _meta.M)
end

-- Returns the row and column number of the matrix.
function matrix.dimensions(m)
    return m.rows, m.cols
end

-- Returns the vector of the diagonal of m.
function matrix.diag(m)
    local res = {}
    for i, row in ipairs(m) do
        res[i] = row[i]
    end

    res.n = m.rows
    return setmetatable(res, _meta.V)
end

-- Return a matrix scaled by a constant.
function matrix.scale(m, k)
    local res = {}
    for i, row in ipairs(m) do
        res[i] = {}
        for j, val in ipairs(row) do
            res[i][j] = val*k
        end
    end

    res.rows, res.cols = m.rows, m.cols
    return setmetatable(res, _meta.M)
end

-- Returns m scaled by -1 (every value negated.
function matrix.negate(m)
    return m:scale(-1)
end

_meta.M.__unm = matrix.negate

-- Returns the nth row of a matrix as a vector.
function matrix.row(m, n)
    return V(m[n], n)
end

-- Returns the nth column of a matrix as a vector.
function matrix.column(m, n)
    local res = {}
    for i, col in ipairs(m) do
        res[i] = col[n]
    end

    res.n = m.m
    return setmetatable(res, _meta.V)
end

-- Returns the determinant of a matrix.
function matrix.det(m)
    if m.rows == 2 then
        return m[1][1]*m[2][2] - m[1][2]*m[2][1]
    end

    local acc = 0
    for i, val in ipairs(m[1]) do
        acc = acc + (-1)^i * m:exclude(1, i):det()
    end

    return acc
end

-- Returns a matrix with one row and column excluded.
function matrix.exclude(m, exrow, excol)
    local res = {}
    local ik = 1
    local jk = 1
    for i, row in ipairs(m) do
        if i ~= exrow then
            res[ik] = {}
            for j, val in ipairs(row) do
                if j ~= excol then
                    res[ik][jk] = val
                    jk = jk + 1
                end
            end
            ik = ik + 1
        end
    end
end

-- Returns two matrices added.
function matrix.add(m1, m2)
    local res = {}
    for i, row in ipairs(m1) do
        res[i] = {}
        for j, val in ipairs(row) do
            res[i][j] = val + m2[i][j]
        end
    end

    res.rows, res.cols = m1.rows, m1.cols
    return setmetatable(res, _meta.M)
end

_meta.M.__add = matrix.add

-- Returns m1 subtracted by m2.
function matrix.subtract(m1, m2)
    local res = {}
    for i, row in ipairs(m1) do
        res[i] = {}
        for j, val in ipairs(row) do
            res[i][j] = val - m2[i][j]
        end
    end

    res.rows, res.cols = m1.rows, m1.cols
    return setmetatable(res, _meta.M)
end

_meta.M.__sub = matrix.subtract

-- Return a matrix multiplied by another matrix or vector.
function matrix.multiply(m1, m2)
    local res = {}

    local cols = {}
    for i, col in ipairs(m2[1]) do
        cols[i] = {}
    end
    for i, row in ipairs(m2) do
        for j, val in ipairs(row) do
            cols[j][i] = val
        end
    end

    local acc
    for i, row in ipairs(m1) do
        res[i] = {}
        for c, col in ipairs(cols) do
            acc = 0
            for j, val in ipairs(col) do
                 acc = acc + m1[i][c]*m2[j][c]
            end

            res[i][c] = acc
        end
    end

    res.rows, res.cols = m1.rows, m2.cols
    return setmetatable(res, _meta.M)
end

_meta.M.__mul = matrix.multiply

-- Returns an inline string representation of the matrix.
function matrix.tostring(m)
    local str = '['
    for i, row in ipairs(m) do
        if i > 1 then
            str = str..', '
        end
        str = str..'['

        for j, val in ipairs(row) do
            if j > 1 then
                str = str..', '
            end
            str = str..tostring(val)
        end
        str = str..']'
    end

    return str..']'
end

_meta.M.__tostring = matrix.tostring

-- Returns a multiline string representation of the matrix.
function matrix.tovstring(m)
    local str = ''
    for i, row in ipairs(m) do
        if i > 1 then
            str = str..'\n'
        end
        for j, val in ipairs(row) do
            if j > 1 then
                str = str..' '
            end
            str = str..tostring(val)
        end
    end

    return str
end

function matrix.vprint(m)
    if log then
        log(m:tovstring())
    end
end

--[[
Copyright © 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
