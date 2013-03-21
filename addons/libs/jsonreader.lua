--[[
Small implementation of a JSON file reader.
]]

_libs = _libs or {}
_libs.jsonreader = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'

jsonreader = {}
-- Define singleton JSON characters that can delimit strings.
jsonreader.singleton = '{}[],:'

-- Constructor.
function jsonreader.new()
	return setmetatable({}, {__index = jsonreader})
end

-- Takes a filename and tries to parse the json in it, after a validity check.
function jsonreader.read(filename)
	local file, err = io.open(lua_base_path..filename, 'r')
	if err ~= nil then
		return jsonreader.error(err)
	end
	local content = file:read("*all")
	file:close()
	return jsonreader.parse(content)
end

-- Returns nil as the parsed table and an additional error message with an optional line number.
function jsonreader.error(message, line)
	if line == nil then
		return nil, 'JSONReader error: '..message
	end
	return nil, 'JSONReader error, line '..line..': '..message
end

-- Parsing function. Gets a string and outputs a Lua table or an error message.
function jsonreader.parse(content)
	-- Returns a Lua value based on a string.
	-- Recognizes all valid atomic JSON values: booleans, numbers, strings and null.
	-- Object and error groupings will be eliminated during the classifying process.
	function makeval(str)
		str = str:trim()
		if str == '' then
			return nil
		elseif str == 'true' then
			return true
		elseif str == 'false' then
			return false
		elseif str == 'null' then
			return nil
		elseif str:enclosed('\'') or str:enclosed('"') then
			return str:slice(2, -2)
		end
		return tonumber(str) or str
	end
	
	-- Tokenizer. Reads the string by characters and assigns finds word boundaries, returning an array of tokens to be interpreted.
	local current = nil
	local tokens = T{T{}}
	local quote = nil
	local line = 1
	local comment = false
	for c in content:gmatch('.') do
		-- Only useful for a line count, to produce more accurate debug messages.
		if c == "\n" then
			line = line + 1
			comment = false
			tokens:append(T{})
		end
		
		-- If the quote character is set, don't parse but syntax, but instead just append to the string until the same quote character is encountered.
		if quote ~= nil then
			current = current..c
			-- If the quote character is found, append the parsed string and reset the parsing values.
			if quote == c then
				tokens[line]:append(makeval(current))
				current = nil
				quote = nil
			end
		elseif not comment then
			-- If the character is a singleton character, append the previous token and this one, reset the parsing values.
			if jsonreader.singleton:find(c, nil, true) then
				if current ~= nil then
					tokens[line]:append(makeval(current))
					current = nil
				end
				tokens[line]:append(c)
			-- If a quote character is found, start a quoting session, see alternative condition.
			elseif T{'\'', '"'}:contains(c) and current == nil then
				quote = c
				current = c
			-- Otherwise, just append
			elseif not c:match('%s') or current ~= nil then
				-- Ignore comments. Not JSON conformant.
				if c == '/' and current ~= nil and current:at(#current) == '/' then
					current = current:slice(1, -2)
					comment = true
				else
					current = current or ''
					current = current..c
				end
			end
		end
	end
	
	-- Scopes and their domains:
	-- * 'object': Object scope, delimited by '{' and '}' as well as global scope
	-- * 'array': Array scope, delimited by '[' and ']'
	local scopes = T{'object'}
	-- Possible modes and triggers:
	-- * 'new': After an opening brace, bracket, comma or at the start, expecting a new element
	-- * 'key': After reading a key
	-- * 'colon': After reading a colon
	-- * 'value': After reading or having scoped a value (either an object, or an array for the latter)
	local modes = T{'new'}
	
	local parsed = T{T{}}
	local keys = T{}
	-- Classifier. Iterate through the tokens and assign meaning to them. Determine scoping and create objects and arrays.
	for line, array in pairs(tokens) do
		for pos, token in pairs(array) do
			if token == '{' then
				if modes[#modes] == 'colon' or modes[#modes] == 'new' and scopes[#scopes] == 'array' then
					parsed:append(T{})
					scopes[#scopes+1] = 'object'
					modes:append('new')
				else
					return jsonreader.error('Unexpected token \'{\'.', line)
				end
			elseif token == '}' then
				if modes[#modes] == 'value' or modes[#modes] == 'new' then
					modes:remove()
					scopes:remove()
					if modes[#modes] == 'colon' then
						parsed[#parsed-1][keys:remove()] = parsed:remove()
					elseif modes[#modes] == 'new' and scopes[#scopes] == 'array' then
						parsed[#parsed]:append(parsed:remove())
					else
						return jsonreader.error('Unexpected token \'}\'.', line)
					end
					modes[#modes] = 'value'
				else
					return jsonreader.error('Unexpected token \'}\'.', line)
				end
			elseif token == '[' then
				if modes[#modes] == 'colon' or modes[#modes] == 'new' and scopes[#scopes] == 'array' then
					parsed:append(T{})
					scopes[#scopes+1] = 'array'
					modes:append('new')
				else
					return jsonreader.error('Unexpected token \'{\'.', line)
				end
			elseif token == ']' then
				if modes[#modes] == 'value' or modes[#modes] == 'new' then
					modes:remove()
					scopes:remove()
					if modes[#modes] == 'colon' then
						parsed[#parsed-1][keys:remove()] = parsed:remove()
					elseif modes[#modes] == 'new' and scopes[#scopes] == 'array' then
						parsed[#parsed]:append(parsed:remove())
					else
						return jsonreader.error('Unexpected token \'}\'.', line)
					end
					modes[#modes] = 'value'
				else
					return jsonreader.error('Unexpected token \'}\'.', line)
				end
			elseif token == ':' then
				if modes[#modes] == 'key' then
					modes[#modes] = 'colon'
				else
					return jsonreader.error('Unexpected token \':\'.', line)
				end
			elseif token == ',' then
				if modes[#modes] == 'value' then
					modes[#modes] = 'new'
				else
					return jsonreader.error('Unexpected token \',\'.', line)
				end
			elseif type(token) == 'string' and modes[#modes] == 'new' and scopes[#scopes] == 'object' then
				keys:append(token)
				modes[#modes] = 'key'
			elseif T{'boolean', 'number', 'string', 'null'}:contains(type(token)) then
				if modes[#modes] == 'colon' then
					parsed[#parsed][keys:remove()] = token
					modes[#modes] = 'value'
				elseif modes[#modes] == 'new' then
					if scopes[#scopes] == 'array' then
						parsed[#parsed]:append(token)
						modes[#modes] = 'value'
					else
						return jsonreader.error('Unexpected token "'..token..'".', line)
					end
				else
					return jsonreader.error('Unexpected token "'..token..'".', line)
				end
			else
				return jsonreader.error('Unkown token parsed. You should never see this. Token type: '..type(token), line)
			end
		end
	end
	
	if parsed:isempty() then
		return jsonreader.error('No JSON found.')
	end
	if #parsed > 1 then
		return jsonreader.error('Invalid nesting, missing closing tags.')
	end
	
	return parsed:remove()
end