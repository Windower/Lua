--[[
A few math helper functions.
]]

_libs = _libs or {}
_libs.mathhelper = true

_raw = _raw or {}
_raw.math = _raw.math or {}
_raw.math = setmetatable(_raw.math, {__index=math})

debug.setmetatable(0, {__index=math})

-- Order of digits for higher base math
math.digitorder = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'

-- Constants
math.e = math.exp(1)

-- Rounds to prec decimal digits. Accepts negative numbers for precision.
function math.round(num, prec)
	local mult = 10^(prec or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- Returns the sign of num, -1 for a negative number, +1 for a positive number and 0 for 0.
function math.sgn(num)
	return num > 0 and 1 or num < 0 and -1 or 0
end

-- Backs up the old log function.
_raw.math.log = math.log

-- Returns an arbitrary-base logarithm. Defaults to e.
function math.log(val, base)
	if base == nil then
		base = math.e
	end
	return _raw.math.log(val)/_raw.math.log(base)
end

-- Returns a binary string representation of val.
function math.tobinary(val)
	return math.tobase(val, 2)
end

-- Returns a octal string representation of val.
function math.tooctal(val)
	return math.tobase(val, 8)
end

-- Returns a hex string representation of val.
function math.tohex(val)
	return math.tobase(val, 16)
end

-- Converts a number val to a string in base base.
function math.tobase(val, base)
	if base == nil or base == 10 or val == 0 then
		return tostring(val)
	end
	
	local num = math.abs(val)
	
	local res = {}
	local key = 1
	local pos
	while num > 0 do
		pos = num % base + 1
		res[key] = math.digitorder:sub(pos, pos)
		num = math.floor(num / base)
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

