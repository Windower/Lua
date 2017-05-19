--[[
File handler.
]]

_libs = _libs or {}

require('strings')
require('tables')

local string, table = _libs.strings, _libs.tables

local files = {}

_libs.files = files

-- Create a new file object.
function files.new(path, create)
    return setmetatable({_create = create == true or nil, path = path}, {__index = files})
end

-- Creates a new file. Creates path, if necessary.
function files.create(f)
    f:create_path()
    local fh = io.open(windower.addon_path .. f.path, 'w')
    fh:write('')
    fh:close()

    f._create = nil

    return f
end

-- Check if file exists. There's no better way, it would seem.
function files.exists(f)
    local path

    if type(f) == 'string' then
        path = f
    else
        if not f.path then
            return nil, 'No file path set, cannot check file.'
        end

        path = f.path
    end

    return windower.file_exists(windower.addon_path .. path)
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
            return nil, 'File \'' .. f .. '\' not found, cannot read.'
        end

        path = f
    else
        if not f.path then
            return nil, 'No file path set, cannot write.'
        end

        if not f:exists() then
            if f._create then
                return ''
            else
                return nil, 'File \'' .. f.path .. '\' not found, cannot read.'
            end
        end

        path = f.path
    end

    local fh = io.open(windower.addon_path .. path, 'r')
    local content = fh:read('*all*')
    fh:close()

    -- Remove byte order mark for UTF-8, if present
    if content:sub(1, 3) == string.char(0xEF, 0xBB, 0xBF) then
        content = content:sub(4)
    end

    return content
end

-- Creates a directory.
function files.create_path(f)
    local path
    if type(f) == 'string' then
        path = f
    else
        if not f.path then
            return nil, 'No file path set, cannot create directories.'
        end

        path = f.path:match('(.*)[/\\].-')

        if not path then
            return nil, 'File path already in addon directory: ' .. windower.addon_path .. f.path
        end
    end

    newpath = windower.addon_path
    for dir in path:psplit('[/\\]'):filter(-''):it() do
        newpath = newpath .. dir .. '/'

        if not windower.dir_exists(newpath) then
            local res, err = windower.create_dir(newpath)
            if not res then
                if err then
                    return nil, err .. ': ' .. newpath
                end

                return nil, 'Unknown error trying to create path ' .. newpath
            end
        end
    end

    return newpath
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
            return nil, 'File \'' .. f .. '\' not found, cannot read.'
        end

        path = f
    else
        if not f.path then
            return nil, 'No file path set, cannot write.'
        end

        if not f:exists() then
            if f._create then
                return ''
            else
                return nil, 'File \'' .. f.path .. '\' not found, cannot read.'
            end
        end

        path = f.path
    end

    return io.lines(windower.addon_path .. path)
end

-- Write to file. Overwrites everything within the file, if present.
function files.write(f, content, flush)
    local path
    if type(f) == 'string' then
        if not files.exists(f) then
            return nil, 'File \'' .. f .. '\' not found, cannot write.'
        end

        path = f
    else
        if not f.path then
            return nil, 'No file path set, cannot write.'
        end

        if not f:exists() then
            if f.path then
                (_libs.logger and notice or print)('New file: ' .. f.path)
                f:create()
            else
                return nil, 'File \'' .. f.path .. '\' not found, cannot write.'
            end
        end

        path = f.path
    end

    if type(content) == 'table' then
        content = table.concat(content)
    end

    local fh = io.open(windower.addon_path .. path, 'w')
    fh:write(content)
    if flush then
        fh:flush()
    end
    fh:close()

    return f
end

-- Append to file. Sets a newline per default, unless newline is set to false.
function files.append(f, content, flush)
    local path
    if type(f) == 'string' then
        if not files.exists(f) then
            return nil, 'File \'' .. f .. '\' not found, cannot write.'
        end

        path = f
    else
        if not f.path then
            return nil, 'No file path set, cannot write.'
        end

        if not f:exists() then
            if f._create then
                (_libs.logger and notice or print)('New file: ' .. f.path)
                f:create()
            else
                return nil, 'File \'' .. f.path .. '\' not found, cannot write.'
            end
        end

        path = f.path
    end

    local fh = io.open(windower.addon_path .. path, 'a')
    fh:write(content)
    if flush then
        fh:flush()
    end
    fh:close()

    return f
end

return files

--[[
Copyright © 2013-2014, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
