--[[
Small implementation of a JSON file reader.
]]

_libs = _libs or {}
_libs.json = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
local files = require 'filehelper'
_libs.filehelper = _libs.filehelper or (files ~= nil)

json = {}
-- Define singleton JSON characters that can delimit strings.
json.singletons = '{}[],:'

-- Takes a filename and tries to parse the JSON in it, after a validity check.
function json.read(file)
	if type(file) == 'string' then
		file = files.new(file)
	end
	
	if not file:exists() then
		return json.error('File not found: \''..file.path..'\'')
	end
	
	return json.parse(file:read())
end

-- Returns nil as the parsed table and an additional error message with an optional line number.
function json.error(message, line)
	if line == nil then
		return nil, 'JSON error: '..message
	end
	return nil, 'JSON error, line '..line..': '..message
end

-- Returns a Lua value based on a string.
-- Recognizes all valid atomic JSON values: booleans, numbers, strings and null.
-- Object and error groupings will be eliminated during the classifying process.
-- If stripquotes is set to true, quote characters delimiting strings will be stripped.
function json.make_val(str, stripquotes)
	stripquotes = stripquotes or true

	str = str:trim()
	if str == '' then
		return nil
	elseif str == 'true' then
		return true
	elseif str == 'false' then
		return false
	elseif str == 'null' then
		return nil
	elseif stripquotes and (str:enclosed('\'') or str:enclosed('"')) then
		return str:slice(2, -2)
	end
	
	str = str:gsub('\\x([%w%d][%w%d])', string.char..(tonumber-{16}))
	
	return tonumber(str) or str
end

-- Parsing function. Gets a string representation of a JSON object and outputs a Lua table or an error message.
function json.parse(content)
	return json.classify(json.tokenize(content))
end

-- Tokenizer. Reads a string and returns an array of lines, each line with a number of valid JSON tokens. Valid tokens include:
-- * \w+	Keys or values
-- * :		Key indexer
-- * ,		Value separator
-- * \{\}	Dictionary start/end
-- * \[\]	List start/end
function json.tokenize(content)
	-- Tokenizer. Reads the string by characters and finds word boundaries, returning an array of tokens to be interpreted.
	local current = nil
	local tokens = T{T{}}
	local quote = nil
	local comment = false
	local line = 1
	for c in content:it() do
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
				tokens[line]:append(json.make_val(current))
				current = nil
				quote = nil
			end
		elseif not comment then
			-- If the character is a singleton character, append the previous token and this one, reset the parsing values.
			if json.singletons:contains(c) then
				if current ~= nil then
					tokens[line]:append(json.make_val(current))
					current = nil
				end
				tokens[line]:append(c)
			-- If a quote character is found, start a quoting session, see alternative condition.
			elseif c:isin('\'', '"') and current == nil then
				quote = c
				current = c
			-- Otherwise, just append
			elseif not c:match('%s') or current ~= nil then
				-- Ignore comments. Not JSON conformant.
				if c == '/' and current ~= nil and current:last() == '/' then
					current = current:slice(1, -2)
					comment = true
				else
					current = current or ''
					current = current..c
				end
			end
		end
	end
	
	return tokens
end

--
function json.classify(tokens)
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
	-- Classifier. Iterates through the tokens and assigns meaning to them. Determines scoping and creates objects and arrays.
	for line, array in pairs(tokens) do
		for pos, token in pairs(array) do
			if token == '{' then
				if modes:last() == 'colon' or modes:last() == 'new' and scopes:last() == 'array' then
					parsed:append(T{})
					scopes:append('object')
					modes:append('new')
				else
					return json.error('Unexpected token \'{\'.', line)
				end
			elseif token == '}' then
				if modes:last() == 'value' or modes:last() == 'new' then
					modes:remove()
					scopes:remove()
					if modes:last() == 'colon' then
						parsed:last(2)[keys:remove()] = parsed:remove()
					elseif modes:last() == 'new' and scopes:last() == 'array' then
						parsed:last():append(parsed:remove())
					else
						return json.error('Unexpected token \'}\'.', line)
					end
					modes[#modes] = 'value'
				else
					return json.error('Unexpected token \'}\'.', line)
				end
			elseif token == '[' then
				if modes:last() == 'colon' or modes:last() == 'new' and scopes:last() == 'array' then
					parsed:append(T{})
					scopes:append('array')
					modes:append('new')
				else
					return json.error('Unexpected token \'{\'.', line)
				end
			elseif token == ']' then
				if modes:last() == 'value' or modes:last() == 'new' then
					modes:remove()
					scopes:remove()
					if modes:last() == 'colon' then
						parsed[#parsed-1][keys:remove()] = parsed:remove()
					elseif modes:last() == 'new' and scopes:last() == 'array' then
						parsed:last():append(parsed:remove())
					else
						return json.error('Unexpected token \'}\'.', line)
					end
					modes[#modes] = 'value'
				else
					return json.error('Unexpected token \'}\'.', line)
				end
			elseif token == ':' then
				if modes:last() == 'key' then
					modes[#modes] = 'colon'
				else
					return json.error('Unexpected token \':\'.', line)
				end
			elseif token == ',' then
				if modes:last() == 'value' then
					modes[#modes] = 'new'
				else
					return json.error('Unexpected token \',\'.', line)
				end
			elseif type(token):isin('string', 'number') and modes:last() == 'new' and scopes:last() == 'object' then
				keys:append(token)
				modes[#modes] = 'key'
			elseif type(token):isin('boolean', 'number', 'string', 'null') then
				if modes:last() == 'colon' then
					parsed:last()[keys:remove()] = token
					modes[#modes] = 'value'
				elseif modes:last() == 'new' then
					if scopes:last() == 'array' then
						parsed:last():append(token)
						modes[#modes] = 'value'
					else
						return json.error('Unexpected token \''..token..'\'.', line)
					end
				else
					return json.error('Unexpected token \''..token..'\'.', line)
				end
			else
				return json.error('Unkown token parsed. You should never see this. Token type: '..type(token), line)
			end
		end
	end
	
	if parsed:isempty() then
		return json.error('No JSON found.')
	end
	if #parsed > 1 then
		return json.error('Invalid nesting, missing closing tags.')
	end

	return parsed:remove()
end

return json
