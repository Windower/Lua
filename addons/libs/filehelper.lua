--[[
File handler.
]]

_libs = _libs or {}
_libs.filehelper = true
_libs.logger = _libs.logger or require 'logger'
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'

local file = T{}

-- Create a new file object. Accepts a variable number of paths, which it will
function file.new(path)
	if path == nil then
		return setmetatable(T{}, {__index = file})
	end
	
	local f = setmetatable(T{}, {__index = file})
	f:set(path)

	return f
end

-- Creates a new file. Creates path, if necessary.
function file.create(f)
	local fh = io.open(lua_base_path..f.path, 'w')
	fh:write('')
	fh:close()

	return f
end

-- Sets the file to a path value.
function file.set(f, path, create)
	create = create or false
	
	f.path = path

	if create then
		if not file.exists(path) then
			notice('New file: '..path)
			f:create()
		end
	end

	return f
end

-- Check if file exists. There's no better way, it would seem.
function file.exists(f)
	local path
	if type(f) == 'string' then
		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot check file.'
		end

		path = f.path
	end

	local fh = io.open(lua_base_path..path, 'r')
	if fh ~= nil then
		fh:close()
		return true
	end

	return false
end

-- Checks existance of a number of paths, returns the first that exists.
function file.check(...)
	return select(2, T{...}:find(file.exists))
end

-- Read from file and return string of the contents.
function file.read(f)
	local path
	if type(f) == 'string' then
		if not file.exists(f) then
			return nil, 'File \''..f..'\' not found, cannot read.'
		end

		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot write.'
		end

		if not f:exists() then
			return nil, 'File \''..f.path..'\' not found, cannot read.'
		end

		path = f.path
	end

	local fh = io.open(lua_base_path..f.path, 'r')
	content = fh:read('*all*')
	fh:close()

	return content
end

-- Read from file and return lines of the contents in a table.
function file.lines(f)
	local path
	if type(f) == 'string' then
		if not file.exists(f) then
			return nil, 'File \''..f..'\' not found, cannot read.'
		end

		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot write.'
		end

		if not f:exists() then
			return nil, 'File \''..f.path..'\' not found, cannot read.'
		end

		path = f.path
	end

	local lines = T{}
	for line in io.lines(lua_base_path..path) do
		lines:append(line)
	end

	return lines
end

-- Write to file. Overwrites everything within the file, if present.
function file.write(f, content)
	local path
	if type(f) == 'string' then
		if not file.exists(f) then
			return nil, 'File \''..f..'\' not found, cannot write.'
		end

		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot write.'
		end

		if not f:exists() then
			return nil, 'File \''..f.path..'\' not found, cannot write.'
		end

		path = f.path
	end
	
	local fh = io.open(lua_base_path..path, 'w')
	fh:write(content)
	fh:close()

	return f
end

-- Append to file. Sets a newline per default, unless newline is set to false.
function file.append(f, content, newline)
	local path
	if type(f) == 'string' then
		if not file.exists(f) then
			return nil, 'File \''..f..'\' not found, cannot write.'
		end

		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot write.'
		end

		if f.path == nil then
			return nil, 'No file path set, cannot write.'
		end

		if not f:exists() then
			return nil, 'File \''..f.path..'\' not found, cannot write.'
		end

		path = f.path
	end

	newline = newline or true

	if newline then
		content = '\n'..content
	end
	local fh = io.open(lua_base_path..path, 'a')
	fh.write(content)
	fh:close()

	return f
end

return file
