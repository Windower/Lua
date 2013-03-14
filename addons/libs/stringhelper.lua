--[[
A few string helper functions.
]]

require 'tablehelper'

debug.getmetatable("").__index = string;

-- Returns the character at position pos. Negative positions are counted from the opposite end.
function string.at(str, pos)
	return str:sub(pos, pos)
end

-- Splits a string into a table by a separator pattern. Empty strings are ignored.
function string.split(str, sep, maxsplit)
	maxsplit = maxsplit or 0
	
	local res = T{}
	local i = 1
	while i <= #str do
		-- Find the next occurence of sep.
		local startpos, endpos = str:find(sep, i)
		-- If found, get the substring and append it to the table.
		if startpos ~= nil then
			matchstr = string.slice(str, i, startpos-1)
			-- Ignore empty string
			if #matchstr > 0 then
				res:append(matchstr)
				-- If maximum number of splits reached, return
				if #res == maxsplit - 1 then
					res:append(str:slice(endpos + 1))
					break
				end
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

-- Removes leading and trailing whitespaces and similar characters (tabs, newlines, etc.)
function string.trim(str)
	return str:match('^%s*(.-)%s*$')
end

-- Returns the same string with the first letter capitalized
function string.uc_first(str)
	return str:at(1):upper()..str:slice(2)
end

-- Returns the same string with the first letter of every word capitalized
function string.capitalize(str)
	return str:split(' '):map(string.uc_first):sconcat()
end