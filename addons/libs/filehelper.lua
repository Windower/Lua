--[[
File handler.
]]

local files = {}

_libs = _libs or {}
_libs.filehelper = files
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'

local createfile = false

-- Create a new file object. Accepts a variable number of paths, which it will
function files.new(path, create)
	create = true and (create ~= false)

	if path == nil then
		return setmetatable(T{}, {__index = files})
	end

	local f = setmetatable(T{}, {__index = files})
	f:set(path, create)

	return f
end

-- Creates a new file. Creates path, if necessary.
function files.create(f)
	f:create_path()
	local fh = io.open(lua_base_path..f.path, 'w')
	fh:write('')
	fh:close()

	return f
end

-- Sets the file to a path value.
function files.set(f, path, create)
	create = true and (create ~= false)
	createfile = create

	f.path = path

	return f
end

-- Check if file exists. There's no better way, it would seem.
function files.exists(f)
	local path

	if type(f) == 'string' then
		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot check file.'
		end

		path = f.path
	end

	return file_exists(lua_base_path..path)
end

-- Checks existance of a number of paths, returns the first that exists.
function files.check(...)
	return table.find[2]({...}, files.exists)
end

-- Read from file and return string of the contents.
function files.read(f)
	local path
	if type(f) == 'string' then
		if not files.exists(f) then
			return nil, 'File \''..f..'\' not found, cannot read.'
		end

		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot write.'
		end

		if not f:exists() then
			if createfile then
				return ''
			else
				return nil, 'File \''..f.path..'\' not found, cannot read.'
			end
		end

		path = f.path
	end

	local fh = io.open(lua_base_path..path, 'r')
	content = fh:read('*all*')
	fh:close()

	-- Remove byte order mark for UTF-8, if present
	if content:startswith(string.char(0xEF, 0xBB, 0xBF)) then
		return content:sub(4)
	end

	return content
end

-- Creates a directory.
function files.create_path(f)
	local path
	if type(f) == 'string' then
		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot create directories.'
		end

		path = f.path:match('(.*)[/\\].-')

		if not path then
			return nil, 'File path already in addon directory: '..lua_base_path..path
		end
	end

	new_path = lua_base_path
	for dir in path:psplit('[/\\]'):filter(-''):it() do
		new_path = new_path..'/'..dir

		if not dir_exists(new_path) then
			local res, err = create_dir(new_path)
			if not res then
				if err ~= nil then
					return nil, err..': '..new_path
				end

				return nil, 'Unknown error trying to create path '..new_path
			end
		end
	end

	return new_path
end

-- Read from file and return lines of the contents in a table.
function files.readlines(f)
	return files.read(f):split('\n')
end

-- Return an iterator over the lines of a file.
function files.it(f)
	local path
	if type(f) == 'string' then
		if not files.exists(f) then
			return nil, 'File \''..f..'\' not found, cannot read.'
		end

		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot write.'
		end

		if not f:exists() then
			if createfile then
				return ''
			else
				return nil, 'File \''..f.path..'\' not found, cannot read.'
			end
		end

		path = f.path
	end

	return coroutine.wrap(function()
		for l in io.lines(lua_base_path..path) do
			coroutine.yield(l)
		end
	end)
end

-- Write to file. Overwrites everything within the file, if present.
function files.write(f, content, flush)
	local path
	if type(f) == 'string' then
		if not files.exists(f) then
			return nil, 'File \''..f..'\' not found, cannot write.'
		end

		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot write.'
		end

		if not f:exists() then
			if createfile then
				notice('New file: '..f.path)
				f:create()
			else
				return nil, 'File \''..f.path..'\' not found, cannot write.'
			end
		end

		path = f.path
	end

	if type(content) == 'table' then
		content = table.concat(content)
	end

	local fh = io.open(lua_base_path..path, 'w')
	fh:write(content)
	if flush then
		fh:flush()
	end
	fh:close()

	return f
end

-- Write array to file. Overwrites everything within the file, if present
function files.writelines(f, lines)
	return files.write(f, table.concat(lines, '\n'))
end

-- Append to file. Sets a newline per default, unless newline is set to false.
function files.append(f, content, flush)
	local path
	if type(f) == 'string' then
		if not files.exists(f) then
			return nil, 'File \''..f..'\' not found, cannot write.'
		end

		path = f
	else
		if f.path == nil then
			return nil, 'No file path set, cannot write.'
		end

		if not f:exists() then
			if createfile then
				notice('New file: '..f.path)
				f:create()
			else
				return nil, 'File \''..f.path..'\' not found, cannot write.'
			end
		end

		path = f.path
	end

	local fh = io.open(lua_base_path..path, 'a')
	fh:write(content)
	if flush then
		fh:flush()
	end
	fh:close()

	return f
end

-- Append an array of lines to file. Sets a newline per default, unless newline is set to false.
function files.appendlines(f, lines, newline)
	return files.append(f, table.concat(lines, '\n'), newline)
end

return files
