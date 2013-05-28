--[[
Functions that facilitate loading, parsing and storing of config files.
]]

_libs = _libs or {}
_libs.config = true
_libs.logger = _libs.logger or require 'logger'
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
local xml = require 'xml'
_libs.xml = _libs.xml or (xml ~= nil)
local files = require 'filehelper'
_libs.filehelper = _libs.filehelper or (files ~= nil)

local config = {}
local file = files.new()
local original = T{['global'] = T{}}
local chars = T{}
local comments = T{}

--[[
	Local functions
]]

local parse
local merge
local settings_table
local settings_xml
local nest_xml
local table_diff

-- Loads a specified file, or alternatively a file 'settings.xml' in the current addon/data folder.
-- Writes all configs to _config.
function config.load(filename, confdict, overwrite)
	if type(filename) == 'table' then
		confdict, filename, overwrite = filename, nil, confdict
	elseif type(filename) == 'boolean' then
		filename, overwrite = nil, filename
	elseif type(confdict) == 'boolean' then
		confdict, overwrite = nil, confdict
	end
	confdict = T(confdict):copy()
	overwrite = overwrite or false
	
	local confdict_mt = getmetatable(confdict)
	confdict = setmetatable(confdict, {__index = function(t, x) if config[x] ~= nil then return config[x] else return confdict_mt.__index[x] end end})
	
	-- Load addon config file (Windower/addon/<addonname>/data/settings.xml).
	local filepath = filename or files.check('data/settings.xml')
	if filepath == nil then
		file:set(filename or 'data/settings.xml', true)
		original['global'] = confdict:copy()
		confdict:save()
		return confdict
	end
	file:set(filepath)

	local err
	confdict, err = parse(file, confdict, overwrite)

	if err ~= nil then
		error(err)
	end
	
	collectgarbage()
	
	return confdict
end

-- Resolves to the correct parser and calls the respective subroutine, returns the parsed settings table.
function parse(file, confdict, update)
	local parsed = T{}
	local err
	if file.path:endswith('.json') then
		parsed = json.read(file)
	elseif file.path:endswith('.xml') then
		parsed, err = xml.read(file)
		if parsed == nil then
			if err ~= nil then
				error(err)
			else
				error('XML error: Unkown error.')
			end
			return T{}
		end
		parsed = settings_table(parsed, confdict)
	end
	
	-- Determine all characters found in the settings file.
	chars = parsed:keyset():filter(-'global')
	original = T{}
	
	if update or confdict:isempty() then
		for char in (L{'global'}+chars):it() do
			original[char] = confdict:copy():update(parsed[char], true)
		end
		return confdict:update(parsed['global']:update(parsed[get_player()['name']:lower()], true), true)
	end
	
	-- Update the global settings with the per-player defined settings, if they exist. Save the parsed value for later comparison.
	for _, char in ipairs(T{'global'}+chars) do
		original[char] = merge(confdict:copy(), parsed[char], char)
	end
	
	return merge(confdict, parsed['global']:update(parsed[get_player()['name']:lower()], true))
end

-- Merges two tables like update would, but retains type-information and tries to work around conflicts.
function merge(t, t_merge, path)
	if t_merge == nil then
		return t
	end
	
	path = (type(path) == 'string' and T{path}) or path

	local oldval
	local err
	for key, val in pairs(t_merge) do
		if not rawget(t, key) then
			if type(val) == 'table' then
				t[key] = T(val)
			else
				t[key] = val
			end
		end
		
		err = false
		oldval = rawget(t, key)
		if type(oldval) == 'table' and type(val) == 'table' then
			local res = merge(oldval, val, path and path:copy()+key or nil)
			if class(oldval) == 'table' or class(oldval) == 'Table' then
				t[key] = setmetatable(res, _meta.T)
			elseif class(oldval) == 'List' then
				t[key] = L(res)
			elseif class(oldval) == 'Set' then
				t[key] = S(res)
			else
				notice('This is supposed to happen. A new data structure has not yet been added to config.lua')
				t[key] = setmetatable(res, _meta.T)
			end
		elseif type(oldval) ~= type(val) then
			if type(oldval) == 'table' then
				if type(val) == 'string' then
					local res = list.map(val:split(','), string.trim)
					if class and class(oldval) == 'Set' then
						res = S(res)
					elseif class and class(oldval) == 'Table' then
						res = T(res)
					end
					t[key] = res
				else
					err = true
				end
			elseif type(oldval) == 'number' then
				local testdec = tonumber(val)
				local testhex = tonumber(val, 16)
				if testdec then
					t[key] = testdec
				elseif testhex then
					t[key] = testhex
				else
					err = true
				end
			elseif type(oldval) == 'boolean' then
				if val == 'true' then
					t[key] = true
				elseif val == 'false' then
					t[key] = false
				else
					err = true
				end
			elseif type(oldval) == 'string' then
				t[key] = val
			else
				err = true
			end
		else
			t[key] = val
		end
		
		if err then
			if path then
				notice('Could not safely merge values for \''..path:concat('/')..'/'..key..'\', '..type(oldval)..' expected (default: '..tostring(oldval)..'), got '..type(val)..' ('..tostring(val)..').')
			end
			t[key] = val
		end
	end

	return t
end

-- Parses a settings struct from a DOM tree.
function settings_table(node, confdict, key)
	confdict = confdict or T{}
	key = key or 'settings'
	
	local t = T{}
	if node.type ~= 'tag' then
		return t
	end
	
	if not node.children:all(function (n) return n.type == 'tag' or n.type == 'comment' end) and not (#node.children == 1 and node.children[1].type == 'text') then
		error('Malformatted settings file.')
		return t
	end
	
	if node.children:length() == 1 and node.children[1].type == 'text' then
		local val = node.children[1].value
		if val:lower() == 'false' then
			return false
		elseif val:lower() == 'true' then
			return true
		end
		
		local num = tonumber(val)
		if num ~= nil then
			return num
		end
		
		return val
	end
	
	for _, child in ipairs(node.children) do
		if child.type == 'comment' then
			comments[key] = child.value:trim()
		elseif child.type == 'tag' then
			key = child.name:lower()
			local childdict
			if confdict:containskey(key) then
				childdict = confdict:copy()
			else
				childdict = confdict
			end
			t[child.name:lower()] = settings_table(child, childdict, key)
		end
	end
	
	return t
end

-- Writes the passed config table to the spcified file name.
-- char defaults to get_player()['name']. Set to "all" to apply to all characters.
function config.save(t, char)
	char = (char or get_player()['name']):lower()
	if char == 'all' then
		char = 'global'
	elseif not chars:contains(char) then
		chars:append(char)
		original[char] = T{}
	end
	
	original[char]:update(t)
	
	if char == 'global' then
		original = original:filterkey('global')
	else
		original[char] = table_diff(original['global'], original[char]) or T{}
		
		if original[char]:isempty() then
			original[char] = nil
			chars:delete(char)
		end
	end
	
	file:write(settings_xml(original))
end

-- Returns the table containing only elements from t_new that are different from t and not nil.
function table_diff(t, t_new)
	local res = T{}
	local cmp
	
	for key, val in pairs(t_new) do
		cmp = t[key]
		if cmp ~= nil then
			if type(cmp) ~= type(val) then
				warning('Mismatched setting types for key \''..key..'\':', type(cmp), type(val))
			else
				if type(val) == 'table' then
					val = T(val)
					cmp = T(cmp)
					if val:isarray() and cmp:isarray() then
						if not val:equals(cmp) then
							res[key] = val
						end
					else
						res[key] = table_diff(cmp, val)
					end
				elseif cmp ~= val then
					res[key] = val
				end
			end
		end
	end
	
	if res:isempty() then
		return nil
	end
	
	return res
end

-- Converts a settings table to a XML representation.
function settings_xml(settings)
	local str = '<?xml version="1.1" ?>\n'
	str = str..'<settings>\n'
	
	chars = settings:keyset():filter(-functools.equals('global')):sort()
	for char in (L{'global'}+chars):it() do
		if char == 'global' and comments['settings'] ~= nil then
			str = str..'\t<!--\n'
			local comment_lines = comments['settings']:split('\n')
			for comment in comment_lines:it() do
				str = str..'\t\t'..comment:trim()..'\n'
			end
			str = str..'\t-->\n'
		end
		str = str..'\t<'..char..'>\n'
		str = str..nest_xml(settings[char], 2)
		str = str..'\t</'..char..'>\n'
	end
	
	str = str..'</settings>\n'
	return str
end

-- Converts a table to XML without headers using appropriate indentation and comment spacing. Used in settings_xml.
function nest_xml(t, indentlevel)
	indentlevel = indentlevel or 0
	local indent = ('\t'):rep(indentlevel)
	
	local inlines = T{}
	local fragments = T{}
	local maxlength = 0		-- For proper comment indenting
	keys = t:keyset():sort()
	local val
	for _, key in ipairs(keys) do
		val = rawget(t, key)
		if type(val) == 'table' and not (class(val) == 'List' or T(val):isarray()) then
			fragments:append(indent..'<'..key..'>\n')
			if comments[key] ~= nil then
				local c = ('<!-- '..comments[key]:trim()..' -->'):split('\n')
				local pre = ''
				for cstr in c:it() do
					fragments:append(indent..pre..cstr:trim()..'\n')
					pre = '\t '
				end
			end
			fragments:append(nest_xml(val, indentlevel + 1))
			fragments:append(indent..'</'..key..'>\n')
		else
			if class(val) == 'List' then
				val = val:format('csv')
			elseif type(val) == 'table' then
				val = T(val):format('csv')
			else
				val = tostring(val)
			end
			if val == '' then
				fragments:append(indent..'<'..key..' />')
			else
				fragments:append(indent..'<'..key..'>'..val:xml_escape()..'</'..key..'>')
			end
			local length = fragments:last():length() - indent:length()
			if length > maxlength then
				maxlength = length
			end
			inlines[fragments:length()] = key
		end
	end
	
	for frag_key, key in pairs(inlines) do
		if rawget(comments, key) ~= nil then
			fragments[frag_key] = fragments[frag_key]..(' '):rep(maxlength - fragments[frag_key]:trim():length() + 1)..'<!-- '..comments[key]..' -->'
		end
		
		fragments[frag_key] = fragments[frag_key]..'\n'
	end
	
	return fragments:concat()
end

-- Resets all data. Always use when loading within a library.
function config.reset()
	config = T(config) or T{}
	file = files.new()
	original = T{['global'] = T{}}
	chars = T{}
	comments = T{}
end

return config
