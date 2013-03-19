--[[
This library provides a set of functions to aid in debugging.
]]

_libs = _libs or {}
_libs.logger = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
_libs.jsonreader = _libs.jsonreader or require 'jsonreader'
_libs.colors = _libs.colors or require 'colors'

_addon = _addon or T{}

_config_load = jsonreader.read('../libs/config.json') or jsonreader.read('../addons/libs/config.json') or T{}
_config = (_config or T{logger=T{}}):merge(_config_load)
local config = _config.logger

-- Set up, based on addon.
config.logtofile = config.logtofile or false
config.defaultfile = config.defaultfile or 'lua.log'
config.logcolor = config.logcolor or 207
config.errorcolor = config.errorcolor or 167
config.warningcolor = config.warningcolor or 200
config.noticecolor = config.noticecolor or 160

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
		if config.logtofile then
			flog(caption:sconcat()..':', ...)
			return
		end
		caption = (caption:sconcat()..':'):setcolor(msgcolor, config.logcolor)..' '
	else
		caption = ''
	end
	
	local str = ''
	if select('#', ...) == 0 or T{...}[1] == '' then
		str = ' '
	else
		str = arrstring(...)
	end
	add_to_chat(config.logcolor, caption..''..str)
end

function log(...)
	captionlog(nil, config.logcolor, ...)
end

function error(...)
	msg = 'Error'
	captionlog(msg, config.errorcolor, ...)
end

function warning(...)
	msg = 'Warning'
	captionlog(msg, config.warningcolor, ...)
end

function notice(...)
	msg = 'Notice'
	captionlog(msg, config.noticecolor, ...)
end

-- Prints the arguments provided to a file, analogous to log(...) in functionality.
-- If the first argument ends with '.log', it will print to that output file, otherwise to 'lua.log' in the addon directory.
function flog(filename, ...)
	if filename == nil then
		filename = config.defaultfile
	end
	local f = io.open(lua_base_path..filename, 'a')
	f:write(os.date('%Y-%m-%d %H:%M:%S')..'| '..arrstring(...).."\n")
	f:close()
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
			if next(val) then
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
	indentlevel = indentlevel or 0
	-- Convert all values to strings, to make sure everything is ready for string concatenation.
	local t = T(t)
	local tstr = ''
	
	local indent = (' '):rep(indentlevel*4)
	tstr = tstr..'{'.."\n"
	for key, val in pairs(t) do
		-- Check for nested tables
		if type(val) == 'table' then
			if next(val) then
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
