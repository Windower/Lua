function string.at(str, pos)
	return str.sub(pos, pos)
end

function string.split(str, sep)
	local res = {}
	local i = 0
	while i <= #str do
		local startpos, endpos = str:find(sep, i)
		if startpos ~= 1 then
			if startpos ~= nil then
				res[#res+1] = str:sub(i, startpos-1)
				i = endpos + 1
			else
				res[#res+1] = str:sub(i, #str)
				break
			end
		else
			i = i + 1
		end
	end
	return res
end

function string.slice(str, from, to)
	return str:sub(from, to)
end
