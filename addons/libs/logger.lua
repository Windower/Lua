--[[
This library provides a set of functions to aid in debugging.
]]

require 'tablehelper'
require 'stringhelper'

function arrstring(...)
	return T{...}:arrmap(tostring):sconcat()
end

-- Prints the arguments provided to the FFXI chatlog, in the same color used for Campaign/Bastion alerts and Kupower messages. Can be changed below.
-- Converts any kind of object type to a string, so it's type-safe.
-- Concatenates all provided arguments with whitespaces.
function log(...)
	add_to_chat(160, arrstring(...))
end

function flog(...)
	local f = io.open(lua_base_path..'lua.log', 'a')
	f:write(os.date('%Y-%m-%d %H:%M:%S')..'| '..arrstring(...).."\n")
	f:close()
end

-- Returns a string representation of a table in explicit Lua syntax: {...}
function table.tostring(t)
	-- Convert all values to strings, to make sure everything is ready for string concatenation.
	local t = T(t)
	local tstr = ''
	
	-- Iterate over table.
	for key, val in pairs(t) do
		-- Check for nested tables
		if type(val) == 'table' then
			valstr = T(val):tostring()
		else
			valstr = tostring(val)
		end
		
		-- Append to the string.
		tstr = tstr..key..'='..valstr
		
		-- Add comma, unless it's the last value.
		if next(t, key) ~= nil then
			tstr = tstr..', '
		end
	end
	
	-- Output the result, enclosed in braces.
	return '{'..tstr..'}'
end

-- Prints a string representation of a table in explicit Lua syntax: {...}
function table.print(t)
	log(T(t):tostring())
end

-- Returns a vertical string representation of a table in explicit Lua syntax, with every element in its own line:
--- {
---     ...
--- }
function table.tovstring(t, indentlevel)
	indentlevel = indentlevel or 0
	-- Convert all values to strings, to make sure everything is ready for string concatenation.
	local t = T(t)
	local tstr = ''
	
	local indent = (' '):rep(indentlevel*4)
	tstr = tstr..'{'.."\n"
	for key, val in pairs(t) do
		-- Check for nested tables
		if type(val) == 'table' then
			valstr = T(val):tovstring(indentlevel+1)
		else
			valstr = tostring(val)
		end
		
		-- Append one line with indent.
		tstr = tstr..indent..'    '..key..'='..valstr
		
		-- Add comma, unless it's the last value.
		if next(t, key) ~= nil then
			tstr = tstr..', '
		end
		
		tstr = tstr.."\n"
	end
	tstr = tstr..indent..'}'
	
	return tstr
end

-- Prints a vertical string representation of a table in explicit Lua syntax, with every element in its own line:
--- {
---     ...
--- }
function table.vprint(t)
	T(t):tovstring():split("\n"):arrmap(log)
end
