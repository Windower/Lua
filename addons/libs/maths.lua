--[[
    A few math helper functions.
]]

_libs = _libs or {}

require('functions')

local functions = _libs.functions
local string = require('string')

local math = require('math')

_libs.maths = math

_raw = _raw or {}
_raw.math = setmetatable(_raw.math or {}, {__index = math})

debug.setmetatable(0, {
    __index = function(_, k)
        return math[k] or (_raw and _raw.error or error)('"%s" is not defined for numbers':format(tostring(k)), 2)
    end
})

-- Order of digits for higher base math
local digitorder = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'}

-- Constants
math.e = 1:exp()
math.tau = 2 * math.pi
math.phi = (1 + 5:sqrt())/2

-- Rounds to prec decimal digits. Accepts negative numbers for precision.
function math.round(num, prec)
    local mult = 10^(prec or 0)
    return ((num * mult + 0.5) / mult):floor()
end

-- Returns the sign of num, -1 for a negative number, +1 for a positive number and 0 for 0.
function math.sgn(num)
    return num > 0 and 1 or num < 0 and -1 or 0
end

-- Backs up the old log function.
_raw.math.log = math.log

-- Returns an arbitrary-base logarithm. Defaults to e.
function math.log(val, base)
    if not base then
        return _raw.math.log(val)
    end

    return _raw.math.log(val)/_raw.math.log(base)
end

-- Returns a binary string representation of val.
function math.binary(val)
    return val:base(2)
end

-- Returns a octal string representation of val.
function math.octal(val)
    return val:base(8)
end

-- Returns a hex string representation of val.
function math.hex(val)
    return val:base(16)
end

-- Converts a number val to a string in base base.
function math.base(val, base)
    if base == nil or base == 10 or val == 0 then
        return val:string()
    elseif base == 1 then
        return '1':rep(val)
    end

    local num = val:abs()

    local res = {}
    local key = 1
    local pos
    while num > 0 do
        pos = num % base + 1
        res[key] = digitorder[pos]
        num = (num / base):floor()
        key = key + 1
    end

    local str = ''
    local n = key - 1
    for key = 1, n do
        str = str..res[n - key + 1]
    end

    if val < 0 then
        str = '-'..str
    end

    return str
end

-- tostring wrapper.
math.string = tostring

-- string.char wrapper, to allow method-like calling on numbers.
math.char = string.char

function math.degree(v)
    return 360 * v / math.tau
end

function math.radian(v)
    return math.tau * v / 360
end

--[[
Copyright © 2013-2014, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
