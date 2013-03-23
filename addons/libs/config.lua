--[[
Functions that facilitate loading, parsing and storing of config files.
]]

_libs = _libs or {}
_libs.config = true
_libs.logger = _libs.logger or require 'logger'
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
local json = require 'json'
_libs.json = _libs.json or (json ~= nil)
local xml = require 'xml'
_libs.xml = _libs.xml or (xml ~= nil)
local files = require 'filehelper'
_libs.filehelper = _libs.filehelper or (files ~= nil)

local config = T(config) or T{}
local file = files.new()
local original = nil
local chars = T{}
local comments = T{}

-- Loads a specified file, or alternatively a file 'settings.json' or 'settings.xml' in the current addon folder.
-- Writes all configs to _config.
function config.load(filename)
	-- Sets paths depending on whether it's a script or addon loading this file.
	local filepath = filename or files.check('data/settings.json', 'data/settings.xml')
	if filepath == nil then
		notice('No settings file found.')
		return T{}
	end
	local file = files.new(filepath)

	-- Load addon/script config file (Windower/addon/<addonname>/config.json for addons and Windower/scripts/<name>-config.json).
	local config_load, err = config.parse(file)

	if config_load == nil then
		if err ~= nil then
			error(err)
		else
			error('Unknown error trying to parse file: '..file.path)
		end
		return T{}
	end
	
	return config_load
end

-- Resolves to the correct parser and calls the respective subroutine, returns the parsed settings table.
function config.parse(file)
	local parsed = T{}
	local err
	if file.path:endswith('.json') then
		parsed = json.read(file)
	elseif file.path:endswith('.xml') then
		parsed, err = xml.read(file)
		if parsed == nil then
			if err ~= nil then
				error('XML error:', err)
			else
				error('XML error: Unkown error.')
			end
			return T{}
		end
		parsed = xml.settings_table(parsed)
	end
	
	-- Determine all characters found in the settings file.
	chars = parsed:keyset():filter(functools.negate(functools.equals('global')))
	
	-- Update the global settings with the per-player defined settings, if they exist. Save the parsed value for later comparison.
	original = parsed:copy()
	
	return parsed['global']:update(parsed[get_player()['name']:lower()])
end

-- Parses a settings struct from a DOM tree.
function xml.settings_table(node, key)
	key = key or 'settings'
	
	local t = T{}
	if node.type ~= 'tag' then
		return t
	end
	
	if not node.children:all(function (n) return n.type == 'tag' or n.type == 'comment' end) and not (#node.children == 1 and node.children[1].type == 'text') then
		error('Malformatted settings file.')
		return t
	end
	
	if #node.children == 1 and node.children[1].type == 'text' then
		local val = node.children[1].value
		if val:lower() == 'false' then
			return false
		elseif val:lower() == 'true' then
			return true
		else
			local num = tonumber(val)
			if num ~= nil then
				return num
			end
		end
		
		return val
	end
	
	for _, child in ipairs(node.children) do
		if child.type == 'comment' then
			comments[key] = child.value
		elseif child.type == 'tag' then
			key = child.name:lower()
			t[child.name:lower()] = xml.settings_table(child, key)
		end
	end
	
	return t
end

-- Writes the passed config table to the spcified file name.
-- char defaults to get_player()['name']. Set to "all" to apply to all characters.
function config.save(t, char)
	if not file:exists() then
--		error('No settings file specified.')
--		return
	end
	
	char = (char or get_player()['name']):lower()
	if char == 'all' then
		char = 'global'
	elseif not chars:contains(char) then
		chars:append(char)
		original[char] = T{}
	end
	
	original[char]:update(t)
	
	local check
	if char == 'global' then
		check = chars
	else
		check = chars:filter(functools.negate(functools.equals(loc)))
	end
	
	for _, char in ipairs(check) do
 		for key, val in pairs(original[char]) do
			if val == original['global'][key] then
				original[char][key] = nil
			end
		end
		
		if original[char]:isempty() then
			original[char] = nil
		end
	end
	
	file:write(config.settings_xml(t))
end

-- Converts a settings table to a XML representation.
function config.settings_xml(settings)
	local str = '<?xml version="1.1" ?>\n'
	str = str..'<settings>\n'
	
	for char, t in pairs(settings) do
		str = str..'\t<'..char..'>\n'
		str = str..config.nest_xml(t, 2)
		str = str..'\t</'..char..'>\n'
	end
	
	str = str..'</settings>\n'
	return str
end

-- Converts a table to XML without headers using appropriate indentation and comment spacing. Used in config.settings_xml.
function config.nest_xml(t, indentlevel)
	indentlevel = indentlevel or 0
	local indent = ('\t'):rep(indentlevel)
	
	local inlines = T{}
	local fragments = T{}
	local maxlength = 0
	for key, val in pairs(t) do
		if type(val) == 'table' then
			fragments:append(indent..'<'..key..'>\n')
			if comments[key] ~= nil then
				local c = ('<!-- '..comments[key]:trim()..' -->'):split('\n')
				local pre = ''
				for _, cstr in pairs(c) do
					fragments:append(indent..pre..cstr:trim()..'\n')
					pre = '\t '
				end
			end
			fragments:append(config.nest_xml(val, indentlevel + 1))
			fragments:append(indent..'</'..key..'>\n')
		else
			fragments:append(indent..'<'..key..'>'..tostring(val)..'</'..key..'>')
			local length = #fragments:last() - #indent
			if length > maxlength then
				maxlength = length
			end
			inlines[#fragments] = key
		end
	end
	
	for frag_key, key in pairs(inlines) do
		if comments[key] ~= nil then
			fragments[frag_key] = fragments[frag_key]..('\t'):rep(math.ceil((maxlength - #fragments[frag_key])/4) + 1)..'<!--'..comments[key]..'-->'
		end
		
		fragments[frag_key] = fragments[frag_key]..'\n'
	end
	
	return fragments:concat()
end

return config
