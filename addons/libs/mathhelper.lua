--[[
A few math helper functions.
]]

-- Rounds to prec decimal digits. Accepts negative numbers for precision.
function math.round(num, prec)
	local mult = 10^(prec or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- Returns the sign of num, -1 for a negative number, +1 for a positive number and 0 for 0.
function math.sgn(num)
	return num/math.abs(num)
end

-- Returns true, if num is even, false otherwise.
function math.even(num)
	return num%2 == 0
end

-- Returns true, if num is odd, false otherwise.
function math.odd(num)
	return num%2 == 1
end

-- Adds two numbers.
function math.sum(val1, val2)
	return val1+val2
end

-- Multiplies two numbers.
function math.mult(val1, val2)
	return val1*val2
end
