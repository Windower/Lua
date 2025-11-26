local JsonHelper = {
}

function indentStr(count)
	local str= ''
	if (count > 0) then
		for i = 1, count do
			str = str..'\t'
		end
	end
	return str
end

function spairs(t, order)
	-- collect the keys
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end

	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys
	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end

	-- return the iterator function
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

function JsonHelper:decodeObject(str, index)
	local obj = {}
	local token, next_index, err
	while index ~= nil do
		token, next_index, err = JsonHelper:getNextToken(str, index)
		if err ~= nil then
			return obj, next_index, err
		end
		if token == '}' then
			-- End of object
			break
		elseif token == ',' then
			-- comma separator, do nothing
			index = next_index
		elseif type(token) ~= 'string' then
			return obj, next_index, "%d, Invalid token %s, expecting string key":format(index, tostring(token))
		else
			local key = token
			local value
			index = next_index
			token, next_index, err = JsonHelper:getNextToken(str, index)
			if err ~= nil then
				break
			end
			if token ~= ':' then
				return obj, next_index, "%d, Invalid token %s, expecting ':'":format(index, tostring(token))
			end
			index = next_index
			token, next_index, err = JsonHelper:getNextToken(str, index)
			if err ~= nil then
				break
			end
			if token == '{' then
				value, next_index, err = JsonHelper:decodeObject(str, next_index)
			elseif token == '[' then
				value, next_index, err = JsonHelper:decodeList(str, next_index)
			else
				value = token
			end
			if err ~= nil or value == nil then
				break
			end
			obj[key] = value
			index = next_index
		end
	end
	return obj, next_index, err
end

function JsonHelper:decodeList(str, index)
	local list = L{}
	local token, value, next_index, err
	while index ~= nil do
		token, next_index, err = JsonHelper:getNextToken(str, index)
		if err ~= nil then
			return obj, next_index, err
		end
		if token == '{' then
			value, next_index, err = JsonHelper:decodeObject(str, next_index)
			if err ~= nil or value == nil then
				break
			end
			list:append(value)
		elseif token == ',' then
			-- comma separator, skip
			index = next_index
		elseif token == ']' then
			-- end of array
			index = next_index
			break
		elseif L{'}','[',':'}:contains(token) then
			err = "%d, unexpected token %s, expecting array element":format(index, token)
			break
		else
			value, next_index, err = JsonHelper:getNextToken(str, index)
			if err ~= nil or value == nil then
				break
			end
			list:append(value)
		end
		index = next_index
	end
	return list, next_index, err
end

function JsonHelper:getNextToken(str, index)
	local index = str:find('[^%s]', index)
	local value, end_index
	local char = str:sub(index, index)
	-- print("getNextToken index %d byte %s":format(index, char))
	if L{'{','}','[',']',',',':'}:contains(char) then
		value = char
		end_index = (index < str:len()) and (index + 1) or nil
	elseif L{'\'','"'}:contains(char) then
		local start_quote = char
		end_index = str:find(start_quote, index+1)
		while (str:sub(end_index - 1, end_index - 1) == '\\') do
			-- Continue searching if previous character is escape
			end_index = str:find(start_quote, end_index+1)
		end
		if end_index == nil then
			return nil, end_index, "%d: Cannot find string termination quote %s":format(index, start_quote)
		end
		if end_index > index + 1 then
			value = str:sub(index + 1, end_index - 1)
		end
		-- Strip escape character
		value = value:gsub('\\\"','\"')
		end_index = (end_index < str:len()) and (end_index + 1) or nil
	else
		end_index = str:find('[%s,%{%}%:%[%]]', index)
		value = str:sub(index, end_index - 1)
		-- print("getNextToken index %d end_index %d value %s":format(index, end_index, tostring(value)))
		if value:match('true') then
			value = true
		elseif value:match('false') then
			value = false
		else
			local num = tonumber(value)
			if (num == nil) then
				return nil, end_index, "%d: Invalid number %s":format(index, value)
			end
			value = num
		end
	end
	if end_index and end_index > str:len() then
		end_index = nil
	end
	return value, end_index, nil
end

function JsonHelper:decodeJson(str)
	if type(str) ~= 'string' then
		return nil, "decodeJson Invalid input type %s":format(type(str))
	end
	local index = 1;
	local obj, end_index, err;
	local token, end_index, err = JsonHelper:getNextToken(str, index)
	if err ~= nil then
		return nil, err
	end
	if token == '{' then
		obj, index, err = JsonHelper:decodeObject(str, end_index)
	else
		obj = nil
		err = "%d, Invalid token %s encountered, expecting {":format(index, tostring(token))
	end
	return obj, err
end

function JsonHelper:fromJson(val)
	if type(val) == 'string' then
		-- return json.parse(val)
		return JsonHelper:decodeJson(val)
	end
	return {}
end

function JsonHelper:toJson(val, indent)
	indent = indent or 0
	local str = T{}
	if type(val) == 'table' and not (class(val) == 'List' or class(val) == 'Set') then
		if (table.length(val) > 0) then
			local list = T{}
			for key, value in spairs(val) do
				local json = JsonHelper:toJson(value, indent+1)
				list:append("\"%s\" : %s":format(tostring(key):gsub('\"', '\\\"'), json))
			end
			str:append('{')
			str:append(indentStr(indent+1)..list:concat(',\n'..indentStr(indent+1)))
			str:append(indentStr(indent)..'}')
		else
			str:append('{}')
		end
	elseif (class(val) == 'List') then
		if (table.length(val) > 0) then
			local list = T{}
			local isObj = false
			for key, value in pairs(val) do
				if type(key) ~= 'string' or key ~= 'n' then
					list:append("%s":format(JsonHelper:toJson(value, indent+1)))
					if not isObj and type(value) == 'table' then
						isObj = true
					end
				end
			end
			if isObj then
				str:append('['..list:concat(',\n'..indentStr(indent+1))..']')
			else
				str:append('['..list:concat(', ')..']')
			end
		else
			str:append('[]')
		end
	elseif (class(val) == 'Set') then
		if (table.length(val) > 0) then
			local list = T{}
			for key, value in pairs(val) do
				if (S{'number','boolean'}:contains(type(value))) then
					list:append("%s":format(JsonHelper:toJson(key, indent+1)))
				else
					list:append("%s":format(JsonHelper:toJson(value, indent+1)))
				end
			end
			table.sort(list)
			str:append('['..list:concat(',')..']')
		else
			str:append('[]')
		end
	elseif (type(val) == 'string') then
		str:append('"'..val:gsub('\"', '\\\"') ..'"')
	else
		str:append(val)
	end
	return str:concat('\n')
end

return JsonHelper