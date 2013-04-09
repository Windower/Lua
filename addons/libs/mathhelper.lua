--[[
A few math helper functions.
]]

_libs = _libs or {}
_libs.mathhelper = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'

-- Order of digits in an for higher base math
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
	return num/math.abs(num)
end

-- Backs up the old log function.
math._bak_log = math.log

-- Returns an arbitrary-base logarithm. Defaults to e.
function math.log(val, base)
	if base == nil then
		base = math.e
	end
	return math._bak_log(val)/math._bak_log(base)
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
	return '0x'..math.tobase(val, 16)
end

-- Converts a number val to a string in base base.
function math.tobase(val, base)
	if base == nil or base == 10 or val == 0 then
		return tostring(val)
	end
	
	local num = math.abs(val)
	
	local str = T{}
	while num > 0 do
		str:insert(math.digitorder:at(num % base + 1))
		num = math.floor(num / base)
	end
	if math.sgn(val) == -1 then
		str:insert('-')
	end
	
	return str:reverse():concat()
end
