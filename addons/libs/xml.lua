--[[
Small implementation of a fully-featured XML reader.
]]

_libs = _libs or {}
_libs.xml = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
local files = require 'filehelper'
_libs.filehelper = _libs.filehelper or files ~= nil

local xml = {}
-- Define singleton XML characters that can delimit inner tag strings.
xml.singletons = '=" \n\r\t/>?'
xml.unescapes = T{
	amp = '&',
	gt = '>',
	lt = '<',
	quot = '"',
	apos = '\''
}
xml.escapes = T{
	['&'] = 'amp',
	['>'] = 'gt',
	['<'] = 'lt',
	['"'] = 'quote',
	['\''] = 'apos'
}

local spaces = {' ', '\n', '\t', '\r'}

-- Takes a numbered XML entity as second argument and converts it to the corresponding symbol.
-- Only used internally to index the xml.unescapes table.
function xml.entity_unescape(_, entity)
	if entity:startswith('#x') then
		return string.char(tonumber(entity:slice(3), 16))
	elseif entity:startswith('#') then
		return string.char(tonumber(entity:slice(2)))
	else
		return entity
	end
end

function string.xml_unescape(str)
	return (str:gsub("&(.-);", xml.entities))
end

function string.xml_escape(str)
	local function xml_sub(c)
		if xml.escapes:containskey(c) then
			return '&'..xml.escapes[c]..';'
		end
		return c
	end
	
	return str:gsub('.', xml_sub)
end

xml.entities = setmetatable(xml.unescapes, {__index=xml.entity_unescape})

-- Takes a filename and tries to parse the XML in it, after a validity check.
function xml.read(file)
	if type(file) == 'string' then
		file = files.new(file)
	end
	
	if not file:exists() then
		return xml.error('File not found: '..file.path)
	end
	
	return xml.parse(file:read())
end

-- Returns nil as the parsed table and an additional error message with an optional line number.
function xml.error(message, line)
	if line == nil then
		return nil, 'XML error: '..message
	end
	return nil, 'XML error, line '..line..': '..message
end

-- Collapses spaces and xml_unescapes XML entities.
function xml.pcdata(str)
	return str:xml_unescape():spaces_collapse()
end

function xml.attribute(str)
	return str:gsub('%s', ' '):xml_unescape()
end

-- TODO
function xml.validate_headers(headers)
	return true
end

-- Parsing function. Gets a string representation of an XML object and outputs a Lua table or an error message.
function xml.parse(content)
	local quote = nil
	local headers = T{xmlhead='', dtds=T{}}
	local tag = ''
	local index = 0
	local mode = 'outer'
	local line = 1
	for c in content:it() do
		if c == '\n' then
			line = line + 1
		end
		
		index = index + 1
		if mode == 'quote' then
			tag = tag..c
			if c == quote then
				quote = nil
				mode = 'inner'
			end
		
		elseif mode == 'outer' then
			if not c:match('%s') then
				if c == '<' then
					mode = 'inner'
					tag = c
				else
					return xml.error('Malformatted XML headers.')
				end
			end
			
		elseif mode == 'inner' then
			tag = tag..c
			if c == '\'' or c == '"' then
				quote = c
				mode = 'quote'
			elseif c == '>' then
				if tag:at(2) == '?' then
					headers['xmlhead'] = tag
					tag = ''
				elseif tag:at(2) == '!' then
					headers['dtds']:append(tag)
					tag = ''
				else
					index = index - #tag + 1
					break
				end
				mode = 'outer'
			end
		end
	end
	
	if not xml.validate_headers(headers) then
		return xml.error('Invalid XML headers.')
	end
	
	local tokens, err = xml.tokenize(content:slice(index):trim(), line)
	if tokens == nil then
		return nil, err
	end
	
	return xml.classify(tokens, headers)
end

-- Tokenizer. Reads a string and returns an array of lines, each line with a number of valid XML tokens. Valid tokens include:
-- * <\w+(:\w+)?	Tag names, possibly including namespace
-- * </\w+>?		Tag endings
-- * />				Single tag endings
-- * ".*(?!")\"		Attribute values
-- * \w+(:\w+)?		Attribute names, possibly including namespace
-- * .*(?!<)		PCDATA
-- * .*(?!\]\]>)	CDATA
function xml.tokenize(content, line)
	local current = ''
	local tokens = T{}
	for i = 1, line do
		tokens:append(T{})
	end
	
	local quote = nil
	local mode = 'inner'
	for c in content:slice(startpos):it() do
		-- Only useful for a line count, to produce more accurate debug messages.
		if c == "\n" then
			tokens:append(T{})
		end
		
		if mode == 'quote' then
			if c == quote then
				tokens:last():append('"'..xml.pcdata(current)..'"')
				current = ''
				mode = 'tag'
			else
				current = current..c
			end
			
		elseif mode == 'comment' then
			current = current..c
			if c == '>' and current:endswith('-->' ) then
				if current:slice(5, -4):contains('--') then
					return xml.error('Invalid token \'--\' within comment.', tokens:line())
				end
				tokens:last():append(current)
				current = ''
				mode = 'inner'
			end
			
		elseif mode == 'inner' then
			if c == '<' then
				tokens:last():append(xml.pcdata(current))
				current = '<'
				mode = 'tag'
			else
				current = current..c
			end
			
		elseif mode == 'cdata' then
			current = current..c
			if c == '>' and current:endswith(']]>') then
				tokens:last():append(current)
				current = ''
				mode = 'inner'
			end
			
		else
			if xml.singletons:contains(c) then
				if c:isin(spaces) then
					if current:length() > 0 then
						tokens:last():append(current)
						current = ''
					end
					
				elseif c == '=' then
					if current:length() > 0 then
						tokens:last():append(current)
					end
					tokens:last():append('=')
					current = ''
					
				elseif c == '"' or c == '\'' then
					quote = c
					mode = 'quote'
					
				elseif c == '/' then
					if current:startswith('<') and current:length() > 1 then
						tokens:last():append(current)
						current = ''
					end
					current = current..c
					
				elseif c == '>' then
					current = current..c
					tokens:last():append(current)
					current = ''
					mode = 'inner'
					
				else
					xml.error('Unexpected token \''..c..'\'.', tokens:length())
				end
				
			else
				if c:match('[%w%d-_%.%:![%]]') ~= nil then
					current = current..c
					if c == '-' and current == '<!-' then
						mode = 'comment'
					elseif c == '[' and current == '<![CDATA[' then
						mode = 'cdata'
					end
				else
					return xml.error('Unexpected character \''..c..'\'.', tokens:length())
				end
			end
		end
	end
	
	for line, array in ipairs(tokens) do
		tokens[line] = array:filter(-string.isempty)
	end
	
	return tokens
end

-- Definition of a DOM object.
local dom = T{}
function dom.new(t)
	return T{type='', name='', namespace=nil, value=nil, children=T{}}:update(t)
end

-- Returns the name of the element and the namespace, if present.
function xml.get_namespace(token)
	local splits = token:split(':')
	if #splits > 2 then
		return
	elseif #splits == 2 then
		return splits[2], splits[1]
	end
	return token
end

-- Classifies the tokens parsed by tokenize into valid XML values, and returns a DOM hierarchy.
function xml.classify(tokens, var)
	if tokens == nil then
		return nil, var
	end
	
	-- This doesn't do anything yet.
	local headers = var
	
	local mode = 'inner'
	local parsed = T{dom.new()}
	local name = nil
	for line, intokens in ipairs(tokens) do
		for _, token in ipairs(intokens) do
			if token:startswith('<![CDATA[') then
				parsed:last().children:append(dom.new(T{type = 'text', value = token:slice(10, -4)}))
				
			elseif token:startswith('<!--') then
				parsed:last().children:append(dom.new(T{type = 'comment', value = token:slice(5, -4)}))
				
			elseif token:startswith('</') then
				if token:slice(3, -2) == parsed:last(1).name then
					parsed:last(2).children:append(parsed:remove())
				else
					return xml.error('Mismatched tag ending: '..token, line)
				end
				
			elseif token:startswith('<') then
				if token:endswith('>') then
					name, namespace = xml.get_namespace(token:slice(2, -2))
				else
					name, namespace = xml.get_namespace(token:slice(2))
				end
				if name == nil then
					return xml.error('Invalid namespace definition.', line)
				end
				namespace = namespace or ''

				parsed:append(dom.new(T{type = 'tag', name = name, namespace = namespace}))
				name, namespace = nil, nil
				if token:endswith('>') then
					mode = 'inner'
				else
					mode = 'tag'
				end
				
			elseif token:endswith('/>') then
				if mode == 'tag' then
					parsed:last(2).children:append(parsed:remove())
					mode = 'inner'
				else
					return xml.error('Illegal token inside a tag: '..token, line)
				end
				
			elseif token:endswith('>') then
				if mode ~= 'tag' then
					return xml.error('Unexpected token \'>\'.', line)
				end
				mode = 'inner'
				
			elseif token == '=' then
				if mode ~= 'eq' then
					return xml.error('Unexpected \'=\'.')
				end
				mode = 'value'
				
			else
				if mode == 'tag' then
					if parsed:last().children:find(function (el) return el.type == 'attribute' and el.name == token end) ~= nil then
						return xml.error('Attribute '..token..' already defined. Multiple assignment not allowed.', line)
					end
					name, namespace = xml.get_namespace(token)
					namespace = tmpnamespace or parsed:last(1).namespace
					mode = 'eq'
					
				elseif mode == 'value' then
					parsed:last().children:append(dom.new(T{type = 'attribute', name = name, namespace = namespace, value = token:slice(2,-2)}))
					name = nil
					namespace = ''
					mode = 'tag'
					
				elseif mode == 'inner' then
					parsed:last().children:append(dom.new(T{type = 'text', value = token}))
				end
			end
		end
	end
	
	local roots = parsed:remove().children
	if #roots > 1 then
		return xml.error('Multiple root elements not allowed.')
	elseif #roots == 0 then
		return xml.error('Missing root element not allowed.')
	end
	
	return roots[1]
end

-- Returns a namespace-formatted string of a DOM node.
function xml.make_namespace_name(node)
	if node.namespace ~= '' then
		return node.namespace..':'..node.name
	end
	
	return node.name
end

-- Convert a DOM hierarchy to well-formed XML.
function xml.realize(node, indentlevel)
	if node.type ~= 'tag' then
		return xml.error('Only DOM objects of type \'tag\' can be realized to XML.')
	end
	
	indentlevel = indentlevel or 0
	local indent = ('\t'):rep(indentlevel)
	local str = indent..'<'..xml.make_namespace_name(node)
	
	local attributes = T{}
	local children = T{}
	local childtypes = T{}
	for _, child in ipairs(node.children) do
		if child.type == 'attribute' then
			attributes:append(child)
		elseif child.type ~= 'attribute' then
			children:append(child)
			childtypes[child.type] = true
		else
			return xml.error('Unknown type \''..child.type..'\'.')
		end
	end
	
	if #attributes ~= 0 then
		for _, attribute in ipairs(attributes) do
			local nsstring = ''
			if attribute.namespace ~= node.namespace then
				nsstring = xml.make_namespace_name(attribute)
			else
				nsstring = attribute.name
			end
			str = str..' '..nsstring..'="'..attribute.value:xml_escape()..'"'
		end
	end
	
	if #children == 0 then
		str = str..' />\n'
		return str
	end
	str = str..'>\n'
	
	local innerindent = '\t'..indent
	for _, child in ipairs(children) do
		if child.type == 'text' then
			str = str..innerindent..child.value:xml_escape()..'\n'
		elseif child.type == 'comment' then
			str = str..innerindent..'<!--'..child.value:xml_escape()..'-->\n'
		else
			str = str..indent..xml.realize(child, indentlevel + 1)..'\n'
		end
	end
	
	str = str..indent..'</'..node.name..'>\n'
	
	return str
end

-- Make an XML representation of a table.
function table.to_xml(t, indentlevel)
	indentlevel = indentlevel or 0
	local indent = ('\t'):rep(indentlevel)
	
	local str = ''
	for key, val in pairs(t) do
		if type(key) == 'number' then
			key = 'node'
		end
		if type(val) == 'table' and next(val) then
			str = str..indent..'<'..key..'>\n'
			str = str..T(val):to_xml(indentlevel + 1)..'\n'
			str = str..indent..'</'..key..'>\n'
		else
			if type(val) == 'table' then
				val = ''
			end
			str = str..indent..'<'..key..'>'..val:xml_escape()..'</'..key..'>\n'
		end
	end
	
	return str
end

return xml
