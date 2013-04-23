--[[
A few string helper functions.
]]

_libs = _libs or {}
_libs.stringhelper = true
_libs.functools = _libs.functools or require 'functools'

debug.getmetatable('').__index = string
debug.getmetatable('').__unm = functools.negate..functools.equals

-- Returns the character at position pos. Negative positions are counted from the opposite end.
function string.at(str, pos)
	return str:sub(pos, pos)
end

-- Returns the character at position pos. Defaults to 1 to return the first character.
function string.first(str, offset)
	offset = offset or 1
	return str:sub(offset, offset)
end

-- Returns the character at position #str-pos. Defaults to 0 to return the last character.
function string.last(str, offset)
	offset = offset or 1
	return str:sub(-offset, -offset)
end

-- Returns true if the string contains a substring.
function string.contains(str, sub)
	return str:find(sub, nil, true)
end

-- Splits a string into a table by a separator pattern.
function string.psplit(str, sep, maxsplit)
	maxsplit = maxsplit or 0
	
	return str:split(sep, maxsplit, false)
end

-- Splits a string into a table by a separator string.
function string.split(str, sep, maxsplit, pattern)
	maxsplit = maxsplit or 0
	if pattern == nil then
		pattern = true
	end
	
	local res = {}
	local i = 1
	while i <= #str + 1 do
		-- Find the next occurence of sep.
		local startpos, endpos = str:find(sep, i, pattern)
		-- If found, get the substring and append it to the table.
		if startpos ~= nil then
			matchstr = string.slice(str, i, startpos-1)
			res[#res+1] = matchstr
			-- If maximum number of splits reached, return
			if #res == maxsplit - 1 then
				res[#res+1] = str:slice(endpos + 1)
				break
			end
			i = endpos + 1
		-- If not found, no more separaters to split, append the remaining string.
		else
			res[#res+1] = str:slice(i)
			break
		end
	end
	
	return res
end

-- Alias to string.sub, with some syntactic sugar.
function string.slice(str, from, to)
	return str:sub(from or 1, to or #str)
end

-- Returns an iterator, that goes over every character of the string.
function string.it(str)
	return str:gmatch('.')
end

-- Removes leading and trailing whitespaces and similar characters (tabs, newlines, etc.).
function string.trim(str)
	return str:match('^%s*(.-)%s*$')
end

-- Collapses all types of spaces into exactly one whitespace
function string.spaces_collapse(str)
	return str:gsub('%s+', ' '):trim()
end

-- Removes all characters in chars from str.
function string.stripchars(str, chars)
	return str:gsub('['..chars..']', '')
end

-- Checks it the string starts with the specified substring.
function string.startswith(str, substr)
	return str:sub(1, #substr) == substr
end

-- Checks it the string ends with the specified substring.
function string.endswith(str, substr)
	return str:sub(-#substr) == substr
end

-- Returns the length of a string.
function string.length(str)
	return #str
end

-- Checks if string is enclosed in start and finish. If only one argument is provided, it will check for that string both at the beginning and the end.
function string.enclosed(str, start, finish)
	finish = finish or start
	return str:startswith(start) and str:endswith(finish)
end

-- Encloses a string in start and finish. If only one argument is provided, it will enclose it with that string both at the beginning and the end.
function string.enclose(str, start, finish)
	finish = finish or start
	return start..str..finish
end

-- Returns the same string with the first letter capitalized.
function string.ucfirst(str)
	return str:sub(1, 1):upper()..str:sub(2)
end

-- Returns the same string with the first letter of every word capitalized.
function string.capitalize(str)
	local res = {}
	
	for _, val in ipairs(str:split(' ')) do
		res[#res + 1] = val:ucfirst()
	end
	
	return table.concat(res, ' ')
end

-- Takes a padding character pad and pads the string str to the left of it, until len is reached. pad defaults to a space.
function string.lpad(str, pad, len)
	pad = pad or ' '
	return (pad:rep(len)..str):sub(-len)
end

-- Takes a padding character pad and pads the string str to the right of it, until len is reached. pad defaults to a space.
function string.rpad(str, pad, len)
	pad = pad or ' '
	return (str..pad:rep(len)):sub(1, len)
end

-- Returns the string padded with zeroes until the length is len.
function string.zfill(str, len)
	return str:lpad('0', len)
end

-- Converts a string in base base to a number.
function string.todec(numstr, base)
	-- Create a table of allowed values according to base and how much each is worth.
	local digits = {}
	local val = 0
	for c in ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'):gmatch('.') do
		digits[c] = val
		val = val + 1
		if val == base then
			break
		end
	end
	
	local index = base^(#numstr-1)
	local acc = 0
	for c in numstr:gmatch('.') do
		acc = acc + digits[c]*index
		index = index/base
	end
	
	return acc
end

-- Checks if a string is in a table.
function string.isin(str, t)
	for _, arg in pairs(t) do
		if arg == str then
			return true
		end
	end
	
	return false
end

-- Checks if a string is empty
function string.isempty(str)
	return str == ''
end

-- Returns a string with Lua pattern characters escaped.
function string.escape(str)
	return str:gsub('[[%]%%^$*().-+]', '%%%1')
end

-- Counts the occurrences of a substring in a string.
function string.count(str, sub)
	return str:pcount(sub:escape())
end

-- Counts the occurrences of a pattern in a string.
function string.pcount(str, pat)
	return string.gsub[2](str, pat, '')
end

-- Returns a formatted item list for use in natural language representation of a number of items.
-- The second argument specifies how the trailing element is handled:
-- * and: Appends the last element with an and instead of a comma. [Default]
-- * csv: Appends the last element with a comma, like every other element.
-- * oxford: Appends the last element with a comma, followed by an and.
-- The third argument specifies an optional output, if the table is empty.
function table.format(t, trail, subs)
	local l = #t
	if l == 0 then
		return subs or ''
	elseif l == 1 then
		return t[next(t)]
	end
	
	trail = trail or 'and'
	
	local last
	if trail == 'and' then
		last = ' and '
	elseif trail == 'csv' then
		last = ', '
	elseif trail == 'oxford' then
		last = ', and '
	else
		warning('Invalid format for table.format: \''..trail..'\'.')
	end
	
	return t:slice(1, -2):concat(', ')..last..t:last()
end