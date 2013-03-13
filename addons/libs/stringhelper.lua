--[[
A few string helper functions.
]]

require 'tablehelper'

-- Returns the character at position pos. Negative positions are counted from the opposite end.
function string.at(str, pos)
	return str.sub(pos, pos)
end

-- Splits a string into a table by a separator pattern. Empty strings are ignored.
function string.split(str, sep)
	local res = T{}
	local i = 1
	while i < #str do
		-- Find the next occurence of sep.
		local startpos, endpos = str:find(sep, i)
		-- If found, get the substring and append it to the table.
		if startpos ~= nil then
			matchstr = str:slice(i, startpos-1)
			-- Ignore empty string
			if #matchstr > 0 then
				res:append(matchstr)
			end
			i = endpos + 1
		-- If not found, no more separaters to split, append the remaining string.
		else
			res:append(str:slice(i))
			break
		end
	end
	
	return res
end

-- Alias to string.sub, with some syntactic sugar.
function string.slice(str, from, to)
	return str:sub(from or 1, to or #str)
end
