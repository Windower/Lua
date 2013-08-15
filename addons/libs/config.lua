--[[
Functions that facilitate loading, parsing, manipulating and storing of config files.
]]

local config = {}

_libs = _libs or {}
_libs.config = config
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
_libs.xml = _libs.xml or require 'xml'
_libs.filehelper = _libs.filehelper or require 'filehelper'

if not _libs.logger then
	error = print
	warning = print
	notice = print
	log = print
end

-- Map for different config loads.
local settings_map = T{}

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
function config.load(filename, confdict)
	if type(filename) == 'table' then
		filename, confdict = nil, filename
	end

	confdict = setmetatable(table.copy(confdict), getmetatable(confdict) or _meta.T)

	local confdict_mt = getmetatable(confdict)
	confdict = setmetatable(confdict, {__class = 'Settings', __index = function(t, k)
		if config[k] ~= nil then
			return config[k]
		elseif confdict_mt then
			return confdict_mt.__index[k]
		end
	end})

	-- Settings member variables, in separate struct
	local meta = {}
	meta.file = _libs.filehelper.new()
	meta.original = T{['global'] = T{}}
	meta.chars = T{}
	meta.comments = T{}

	settings_map[confdict] = meta

	-- Load addon config file (Windower/addon/<addonname>/data/settings.xml).
	local filepath = filename or 'data/settings.xml'
	if not _libs.filehelper.exists(filepath) then
		meta.file:set(filename or 'data/settings.xml', true)
		meta.original['global'] = confdict:copy()
		config.save(confdict)

		return confdict
	end

	meta.file:set(filepath)

	local err
	confdict, err = parse(confdict)

	if err ~= nil then
		error(err)
	end

	return confdict
end

-- Resolves to the correct parser and calls the respective subroutine, returns the parsed settings table.
function parse(confdict)
	local parsed = T{}
	local err
	meta = settings_map[confdict]

	if meta.file.path:endswith('.json') then
		parsed = json.read(meta.file)

	elseif meta.file.path:endswith('.xml') then
		parsed, err = _libs.xml.read(meta.file)

		if parsed == nil then
			if err ~= nil then
				error(err)
			else
				error('XML error: Unkown error.')
			end
			return confdict
		end

		parsed = settings_table(parsed, confdict)
	end

	-- Determine all characters found in the settings file.
	meta.chars = parsed:keyset() - S{'global'}
	meta.original = T{}

	if table.empty(confdict) then
		for char in (meta.chars + S{'global'}):it() do
			meta.original[char] = confdict:copy():update(parsed[char], true)
		end

		return confdict:update(parsed['global']:update(parsed[get_player()['name']:lower()], true), true)
	end

	-- Update the global settings with the per-player defined settings, if they exist. Save the parsed value for later comparison.
	for char in (meta.chars + S{'global'}):it() do
		meta.original[char] = merge(confdict:copy(), parsed[char], char)
	end

	return merge(confdict, parsed['global']:update(parsed[get_player()['name']:lower()], true))
end

-- Merges two tables like update would, but retains type-information and tries to work around conflicts.
function merge(t, t_merge, path)
	path = (type(path) == 'string' and T{path}) or path

	local oldval
	local err

	local keys = {}
	for key in pairs(t) do
		keys[key:lower()] = key
	end

	local key
	for lkey, val in pairs(t_merge) do
		key = keys[lkey:lower()]
		if key == nil then
			if type(val) == 'table' then
				t[lkey] = setmetatable(val, _meta.T)
			else
				t[lkey] = val
			end

		else
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
					notice('This is not supposed to happen. A new data structure has not yet been added to config.lua')
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
					warning('Could not safely merge values for \''..path:concat('/')..'/'..key..'\', '..type(oldval)..' expected (default: '..tostring(oldval)..'), got '..type(val)..' ('..tostring(val)..').')
				end
				t[key] = val
			end
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

	-- TODO: Type checking necessary? merge should take care of that.
	if #node.children == 1 and node.children[1].type == 'text' then
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

	for child in node.children:it() do
		if child.type == 'comment' then
			meta.comments[key] = child.value:trim()
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
	meta = settings_map[t]

	if char == 'all' then
		char = 'global'
	elseif not meta.chars:contains(char) then
		meta.chars:append(char)
		meta.original[char] = T{}
	end

	meta.original[char]:update(t)

	if char == 'global' then
		meta.original = meta.original:filterkey('global')
	else
		meta.original.global:amend(meta.original[char])
		meta.original[char] = table_diff(meta.original['global'], meta.original[char]) or setmetatable({}, _meta.T)

		if meta.original[char]:empty(true) then
			meta.original[char] = nil
			meta.chars:delete(char)
		end
	end

	meta.file:write(settings_xml(meta))
end

-- Returns the table containing only elements from t_new that are different from t and not nil.
function table_diff(t, t_new)
	local res = setmetatable({}, _meta.T)
	local cmp

	for key, val in pairs(t_new) do
		cmp = t[key]
		if cmp ~= nil then
			if class(cmp) ~= class(val) then
				warning('Mismatched setting types for key \''..key..'\':', type(cmp), type(val))
			else
				if type(val) == 'table' then
					if class(val) == 'Set' or class(val) == 'List' then
						if not cmp:equals(val) then
							rawset(res, key, val)
						end
					elseif table.isarray(val) and table.isarray(cmp) then
						if not table.equals(cmp, val) then
							rawset(res, key, val)
						end
					else
						rawset(res, key, table_diff(cmp, val))
					end
				elseif cmp ~= val then
					rawset(res, key, val)
				end
			end
		end
	end

	return (not table.empty(res) and res) or nil
end

-- Converts a settings table to a XML representation.
function settings_xml(meta)
	local str = '<?xml version="1.1" ?>\n'
	str = str..'<settings>\n'
	local settings = meta.original

	meta.chars = (settings:keyset() - S{'global'}):sort()
	for char in (L{'global'}+meta.chars):it() do
		if char == 'global' and rawget(meta.comments, 'settings') ~= nil then
			str = str..'\t<!--\n'
			local comment_lines = rawget(meta.comments, 'settings'):split('\n')
			for comment in comment_lines:it() do
				str = str..'\t\t'..comment:trim()..'\n'
			end

			str = str..'\t-->\n'
		end

		str = str..'\t<'..char..'>\n'
		str = str..nest_xml(settings[char], meta, 2)
		str = str..'\t</'..char..'>\n'
	end

	str = str..'</settings>\n'
	return str
end

-- Converts a table to XML without headers using appropriate indentation and comment spacing. Used in settings_xml.
function nest_xml(t, meta, indentlevel)
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
			if rawget(meta.comments, key) ~= nil then
				local c = ('<!-- '..rawget(meta.comments, key):trim()..' -->'):split('\n')
				local pre = ''
				for cstr in c:it() do
					fragments:append(indent..pre..cstr:trim()..'\n')
					pre = '\t '
				end
			end
			fragments:append(nest_xml(val, meta, indentlevel + 1))
			fragments:append(indent..'</'..key..'>\n')

		else
			if class(val) == 'List' then
				val = val:format('csv')
			elseif class(val) == 'Set' then
				val = val:sort():format('csv')
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
		if rawget(meta.comments, key) ~= nil then
			fragments[frag_key] = fragments[frag_key]..(' '):rep(maxlength - fragments[frag_key]:trim():length() + 1)..'<!-- '..meta.comments[key]..' -->'
		end

		fragments[frag_key] = fragments[frag_key]..'\n'
	end

	return fragments:concat()
end

return config
