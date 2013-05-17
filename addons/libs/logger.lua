--[[
This library provides a set of functions to aid in debugging.
]]

_libs = _libs or {}
_libs.logger = true
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
_libs.colors = _libs.colors or require 'colors'

local logger = {}
logger.defaults = {}

-- Set up, based on addon.
logger.defaults.logtofile = false
logger.defaults.defaultfile = 'lua.log'
logger.defaults.logcolor = 207
logger.defaults.errorcolor = 167
logger.defaults.warningcolor = 200
logger.defaults.noticecolor = 160

--[[
	Local functions
]]

local arrstring
local captionlog

-- Returns a concatenated string list, separated by whitespaces, for the chat output function.
-- Converts any kind of object type to a string, so it's type-safe.
-- Concatenates all provided arguments with whitespaces.
function arrstring(...)
	local str = ''
	local args = {...}
	for i = 1, select('#', ...) do
		if i > 1 then
			str = str..' '
		end
		str = str..tostring(args[i])
	end
	return str
end

-- Prints the arguments provided to the FFXI chatlog, in the same color used for Campaign/Bastion alerts and Kupower messages. Can be changed below.
function captionlog(msg, msgcolor, ...)
	local caption = _addon and _addon.name or ''
	
	if msg ~= nil then
		caption = caption..' '..msg
	end
	
	if #caption > 0 then
		if logger.settings.logtofile == true then
			flog(nil, caption..':', ...)
			return
		end
		caption = (caption..':'):color(msgcolor)..' '
	end
	
	local str = ''
	if select('#', ...) == 0 or ... == '' then
		str = ' '
	else
		str = arrstring(...):gsub('\t', (' '):rep(4))
	end
	
	for _, line in ipairs(str:split('\n')) do
		add_to_chat(logger.settings.logcolor, caption..line..'\x1E\x01')
	end
end

function log(...)
	captionlog(nil, logger.settings.logcolor, ...)
end

function error(...)
	captionlog('Error', logger.settings.errorcolor, ...)
end

function warning(...)
	captionlog('Warning', logger.settings.warningcolor, ...)
end

function notice(...)
	captionlog('Notice', logger.settings.noticecolor, ...)
end

-- Prints the arguments provided to a file, analogous to log(...) in functionality.
-- If the first argument ends with '.log', it will print to that output file, otherwise to 'lua.log' in the addon directory.
function flog(filename, ...)
	filename = filename or logger.settings.defaultfile
	
	local fh, err = io.open(lua_base_path..filename, 'a')
	if fh == nil then
		if err ~= nil then
			error('File error:', err)
		else
			error('File error:', 'Unknown error.')
		end
	else
		fh:write(os.date('%Y-%m-%d %H:%M:%S')..'| '..arrstring(...)..'\n')
		fh:close()
	end
end

-- Returns a string representation of a table in explicit Lua syntax: {...}
function table.tostring(t)
	if next(t) == nil then
		return '{}'
	end
	
	keys = keys or false
	
	-- Iterate over table.
	local tstr = ''
	local kt = {}
	for key in pairs(t) do
		kt[#kt+1] = key
	end
	table.sort(kt)
	
	for i, key in ipairs(kt) do
		val = t[key]
		-- Check for nested tables
		if type(val) == 'table' then
			valstr = table.tostring(val)
		else
			if type(val) == 'string' then
				valstr = '"'..val..'"'
			else
				valstr = tostring(val)
			end
		end
		
		-- Append to the string.
		if tonumber(key) then
			tstr = tstr..valstr
		else
			tstr = tstr..key..'='..valstr
		end
		
		-- Add comma, unless it's the last value.
		if next(kt, i) ~= nil then
			tstr = tstr..', '
		end
	end
	
	-- Output the result, enclosed in braces.
	return '{'..tstr..'}'
end

_meta = _meta or {}
_meta.T = _meta.T or {}
_meta.T.__tostring = table.tostring

-- Prints a string representation of a table in explicit Lua syntax: {...}
function table.print(t, keys)
	log(table.tostring(t, keys))
end

-- Returns a vertical string representation of a table in explicit Lua syntax, with every element in its own line:
--- {
---     ...
--- }
function table.tovstring(t, keys, indentlevel)
	if next(t) == nil then
		return '{}'
	end
	
	indentlevel = indentlevel or 0
	keys = keys or false
	
	local indent = (' '):rep(indentlevel*4)
	local tstr = '{\n'
	local kt = {}
	for key in pairs(t) do
		kt[#kt+1] = key
	end
	table.sort(kt)
	
	for i, key in pairs(kt) do
		val = t[key]
		-- Check for nested tables
		if type(val) == 'table' then
			valstr = table.tovstring(val, keys, indentlevel+1)
		else
			if type(val) == 'string' then
				valstr = '"'..val..'"'
			else
				valstr = tostring(val)
			end
		end
		
		-- Append one line with indent.
		if not keys and tonumber(key) then
			tstr = tstr..indent..'    '..valstr
		else
			tstr = tstr..indent..'    '..key..'='..valstr
		end
		
		-- Add comma, unless it's the last value.
		if next(kt, i) ~= nil then
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
function table.vprint(t, keys)
	log(table.tovstring(t, keys))
end

-- Load logger settings (has to be after the logging functions have been defined, so those work in the config and related files).
-- This checks if the config library has been loaded, if so, it will reload it to wipe the settings. Otherwise it will unload after it's done.
local loaded = _libs.config ~= nil

if loaded then
	local old_config = package.loaded.config
	package.loaded.config = nil
end

local config = require 'config'

logger.settings = config.load('../libs/logger.xml', logger.defaults)

config = nil
package.loaded.config = nil

if loaded then
	package.loaded.config = old_config
end

collectgarbage()

