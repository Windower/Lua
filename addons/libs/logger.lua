--[[
This library provides a set of functions to aid in debugging.
]]

_libs = _libs or {}
_libs.logger = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
_libs.colors = _libs.colors or require 'colors'
local config = require 'config'
_libs.config = _libs.config or (config ~= nil)
local files = require 'filehelper'
_libs.filehelper = _libs.filehelper or (files ~= nil)

_addon = _addon or T{}

local logger = T{}
logger.settings = T{}
local file

-- Set up, based on addon.
logger.settings.logtofile = logger.settings.logtofile or false
logger.settings.defaultfile = logger.settings.defaultfile or 'lua.log'
logger.settings.logcolor = logger.settings.logcolor or 207
logger.settings.errorcolor = logger.settings.errorcolor or 167
logger.settings.warningcolor = logger.settings.warningcolor or 200
logger.settings.noticecolor = logger.settings.noticecolor or 160

--[[
	Local functions
]]

local arrstring
local captionlog

-- Returns a concatenated string list, separated by whitespaces, for the chat output function.
-- Converts any kind of object type to a string, so it's type-safe.
-- Concatenates all provided arguments with whitespaces.
function arrstring(...)
	return T{...}:arrmap(tostring):sconcat()
end

-- Prints the arguments provided to the FFXI chatlog, in the same color used for Campaign/Bastion alerts and Kupower messages. Can be changed below.
function captionlog(msg, msgcolor, ...)
	local caption = T{}
	if _addon.name ~= nil then
		caption:append(_addon.name)
	end
	if msg ~= nil then
		caption:append(msg)
	end
	if #caption > 0 then
		if logger.settings.logtofile == true then
			flog(caption:sconcat()..':', ...)
			return
		end
		caption = (caption:sconcat()..':'):color(msgcolor)..' '
	else
		caption = ''
	end
	
	local str = ''
	if select('#', ...) == 0 or T{...}[1] == '' then
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
	local f
	if filename ~= nil then
		f = files.new(filename)
	elseif filename == nil then
		f = file
	end
	
	local _, err = f:append(os.date('%Y-%m-%d %H:%M:%S')..'| '..arrstring(...))
	if err ~= nil then
		error('File error:', err)
	end
end

-- Returns a string representation of a table in explicit Lua syntax: {...}
function table.tostring(t)
	t = T(t)
	if t:isempty() then
		return '{}'
	end
	
	keys = keys or false
	
	-- Iterate over table.
	local tstr = ''
	local kt = t:keyset():sort()
	for _, key in ipairs(kt) do
		val = t[key]
		-- Check for nested tables
		if type(val) == 'table' then
			valstr = T(val):tostring()
		else
			if type(val) == 'string' then
				valstr = val:enclose('"')
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
		if kt:last() ~= key then
			tstr = tstr..', '
		end
	end
	
	-- Output the result, enclosed in braces.
	return '{'..tstr..'}'
end

-- Prints a string representation of a table in explicit Lua syntax: {...}
function table.print(t, keys)
	log(T(t):tostring(keys))
end

-- Returns a vertical string representation of a table in explicit Lua syntax, with every element in its own line:
--- {
---     ...
--- }
function table.tovstring(t, keys, indentlevel)
	t = T(t)
	if t:isempty() then
		return '{}'
	end
	
	indentlevel = indentlevel or 0
	keys = keys or false
	
	local indent = (' '):rep(indentlevel*4)
	local tstr = '{'..'\n'
	local tk = t:keyset():sort()
	for _, key in pairs(tk) do
		val = t[key]
		-- Check for nested tables
		if type(val) == 'table' then
			val = T(val)
			valstr = val:tovstring(keys, indentlevel+1)
		else
			if type(val) == 'string' then
				valstr = val:enclose('"')
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
		if tk:last() ~= key then
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
	log(T(t):tovstring(keys))
end

-- Load logger settings (has to be after the logging functions have been defined, so those work in the config and related files).
logger.settings = config.load('../libs/logger.xml', logger.settings)
file = files.new(logger.settings.defaultfile, true)
config.reset()