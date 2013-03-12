function math.round(num, prec)
	local mult = 10^(prec or 0)
	return math.floor(num * mult + 0.5) / mult
end

function math.sgn(num)
	return num/math.abs(num)
end