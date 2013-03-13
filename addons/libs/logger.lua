--[[
This library provides a set of functions to aid in debugging.
]]

require 'tablehelper'

-- Prints the arguments provided to the FFXI chatlog, in the same color used for Campaign/Bastion alerts and Kupower messages. Can be changed below.
-- Converts any kind of object type to a string, so it's type-safe.
-- Concatenates all provided arguments with whitespaces.
function log(...)
	local args = T{...}
	local strtable = T(args:map(tostring))
	add_to_chat(160, strtable:sconcat())
end

-- Prints a table in explicit Lua syntax: {...}
function table.print(t)
	-- Convert all values to strings, to make sure everything is ready for string concatenation.
	t = T(t):map(tostring)
	tstr = ''
	
	-- Iterate over table.
	for key, val in pairs(t) do
		-- Append to the string.
		tstr = tstr..key..'='..val
		
		-- Add commata, unless it's the last value.
		if next(t, key) ~= nil then
			tstr = tstr..', '
		end
	end
	
	-- Output the result, enclosed in braces.
	log('{'..tstr..'}')
end

-- Prints a table vertically in explicit Lua syntax, with every element in its own line:
--- {
---     ...
--- }
function table.vprint(t)
	-- Convert all values to strings, to make sure everything is ready for string concatenation.
	t = T(t):map(tostring)
	
	log('{')
	for key, val in pairs(t) do
		-- Output one line with indent.
		log('    '..key..'='..val)
	end
	log('}')
end
