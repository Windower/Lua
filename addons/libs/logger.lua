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

local settings = T{}
local file

-- Set up, based on addon.
settings.logtofile = settings.logtofile or false
settings.defaultfile = settings.defaultfile or 'lua.log'
settings.logcolor = settings.logcolor or 207
settings.errorcolor = settings.errorcolor or 167
settings.warningcolor = settings.warningcolor or 200
settings.noticecolor = settings.noticecolor or 160

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
		if settings.logtofile == true then
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
		add_to_chat(settings.logcolor, caption..line..'\x1E\x01')
	end
end

function log(...)
	captionlog(nil, settings.logcolor, ...)
end

function error(...)
	captionlog('Error', settings.errorcolor, ...)
end

function warning(...)
	captionlog('Warning', settings.warningcolor, ...)
end

function notice(...)
	captionlog('Notice', settings.noticecolor, ...)
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
	-- Convert all values to strings, to make sure everything is ready for string concatenation.
	local t = T(t)
	local tstr = ''
	
	-- Iterate over table.
	for key, val in pairs(t) do
		-- Check for nested tables
		if type(val) == 'table' then
			if not val:isempty() then
				valstr = T(val):tostring()
			else
				valstr = '{}'
			end
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
		if next(t, key) ~= nil then
			tstr = tstr..', '
		end
	end
	
	-- Output the result, enclosed in braces.
	return '{'..tstr..'}'
end

-- Prints a string representation of a table in explicit Lua syntax: {...}
function table.print(t)
	log(T(t):tostring())
end

-- Returns a vertical string representation of a table in explicit Lua syntax, with every element in its own line:
--- {
---     ...
--- }
function table.tovstring(t, indentlevel)
	t = T(t)
	indentlevel = indentlevel or 0
	
	if t:isempty() then
		return '{}'
	end
	
	local indent = (' '):rep(indentlevel*4)
	local tstr = '{'.."\n"
	for key, val in pairs(t) do
		-- Check for nested tables
		if type(val) == 'table' then
			if not val:isempty() then
				valstr = T(val):tovstring(indentlevel+1)
			else
				valstr = '{}'
			end
		else
			if type(val) == 'string' then
				valstr = val:enclose('"')
			else
				valstr = tostring(val)
			end
		end
		
		-- Append one line with indent.
		if tonumber(key) then
			tstr = tstr..indent..'    '..valstr
		else
			tstr = tstr..indent..'    '..key..'='..valstr
		end
		
		-- Add comma, unless it's the last value.
		if next(t, key) ~= nil then
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
function table.vprint(t)
	T(t):tovstring():split("\n"):arrmap(log)
end

-- Load logger settings (has to be after the logging functions have been defined, so those work in the config and related files).
settings:update(config.load('../libs/logger.xml'))
file = files.new(settings.defaultfile, true)
