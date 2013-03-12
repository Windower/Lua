function math.round(num, prec)
	local mult = 10^(prec or 0)
	return math.floor(num * mult + 0.5) / mult
end

function math.sgn(num)
	return num/math.abs(num)
end

function math.even(num)
	return num%2 == 0
end

function math.odd(num)
	return num%2 == 1
end

function math.sum(val1, val2)
	return val1+val2
end

function math.mult(val1, val2)
	return val1*val2
end
