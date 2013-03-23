--[[
A few string helper functions.
]]

_libs = _libs or {}
_libs.stringhelper = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.functools = _libs.functools or require 'functools'
_libs.mathhelper = _libs.mathhelper or require 'mathhelper'

debug.getmetatable("").__index = string

-- Returns the character at position pos. Negative positions are counted from the opposite end.
function string.at(str, pos)
	return str:slice(pos, pos)
end

-- Returns the character at position #str-pos. Defaults to 0 to return the last character.
function string.last(str, offset)
	offset = offset or 1
	return str:at(-offset)
end

-- Returns true if the string contains a substring.
function string.contains(str, sub)
	return str:find(sub, nil, true)
end

-- Splits a string into a table by a separator pattern. Empty strings are ignored.
function string.psplit(str, sep, maxsplit)
	maxsplit = maxsplit or 0
	
	return str:split(sep, maxsplit, false)
end

-- Splits a string into a table by a separator string. Empty strings are ignored.
function string.split(str, sep, maxsplit, pattern)
	maxsplit = maxsplit or 0
	if pattern == nil then
		pattern = true
	end
	
	local res = T{}
	local i = 1
	while i <= #str do
		-- Find the next occurence of sep.
		local startpos, endpos = str:find(sep, i, pattern)
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
	-- Create table for the characters, for faster checking.
	local charset = chars:charset()
	
	function subchar(c)
		if charset:containskey(c) then
			return ''
		end
		return c
	end
	
	return str:map(subchar)
end

-- Returns a table keyed with all characters from the string. Mainly used for O(1) membership checking with table.containskey.
function string.charset(str)
	local charset = T{}
	for c in str:gmatch('.') do
		charset[c] = true
	end
	
	return charset
end

-- Checks it the string starts with the specified substring.
function string.startswith(str, substr)
	return str:slice(1, #substr) == substr
end

-- Checks it the string ends with the specified substring.
function string.endswith(str, substr)
	return str:slice(-#substr) == substr
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
	return str:at(1):upper()..str:slice(2)
end

-- Returns the same string with the first letter of every word capitalized.
function string.capitalize(str)
	return str:split(' '):map(string.uc_first):sconcat()
end

-- Returns the string padded with zeroes until the length is len.
function string.zfill(str, len)
	return (('0'):rep(len)..str):slice(-len)
end

-- Converts a string in base base to a number.
function string.todec(numstr, base)
	-- Create a table of allowed values according to base and how much each is worth.
	local digits = T{}
	local val = 0
	for c in math.digitorder:gmatch('.') do
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
function string.isin(str, ...)
	return T{...}:flatten():contains(str)
end

-- Checks if a string is empty
function string.isempty(str)
	return #str == 0
end

-- Counts the occurrences of a substring in a string.
function string.count(str, sub)
	return str:pcount(sub:gsub('[[%]%%^$*().-+]', '%%%1'))
end

-- Counts the occurrences of a pattern in a string.
function string.pcount(str, pat)
	local _, count = str:gsub(pat, '')
	return count
end
