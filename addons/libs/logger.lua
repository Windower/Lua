--[[
This library provides a set of functions to aid in debugging.
]]

_libs = _libs or {}

require('strings')
require('chat')

local string, chat = _libs.strings, _libs.chat
local table = require('table')

local logger = {}

_libs.logger = logger

_raw = _raw or {}

-- Set up, based on addon.
logger.defaults = {}
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
        str = str .. tostring(args[i])
    end

    return str
end

-- Prints the arguments provided to the FFXI chatlog, in the same color used for Campaign/Bastion alerts and Kupower messages. Can be changed below.
function captionlog(msg, msgcolor, ...)
    local caption = table.concat({_addon and _addon.name, msg}, ' ')

    if #caption > 0 then
        if logger.settings.logtofile then
            flog(nil, caption .. ':', ...)
            return
        end
        caption = (caption .. ':'):color(msgcolor) .. ' '
    end

    local str = ''
    if select('#', ...) == 0 or ... == '' then
        str = ' '
    else
        str = arrstring(...):gsub('\t', (' '):rep(4))
    end

    for _, line in ipairs(str:split('\n')) do
        windower.add_to_chat(logger.settings.logcolor, caption .. windower.to_shift_jis(line) .. _libs.chat.controls.reset)
    end
end

function log(...)
    captionlog(nil, logger.settings.logcolor, ...)
end

_raw.error = error
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

    local fh, err = io.open(windower.addon_path..filename, 'a')
    if fh == nil then
        if err ~= nil then
            error('File error:', err)
        else
            error('File error:', 'Unknown error.')
        end
    else
        fh:write(os.date('%Y-%m-%d %H:%M:%S') .. '| ' .. arrstring(...) .. '\n')
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
    k = 0
    for key in pairs(t) do
        k = k + 1
        kt[k] = key
    end
    table.sort(kt, function(x, y)
        if type(x) == 'number' and type(y) == 'string' then
            return true
        elseif type(x) == 'string' and type(y) == 'number' then
            return false
        end

        return x<y
    end)

    for i, key in ipairs(kt) do
        val = t[key]
        -- Check for nested tables
        if type(val) == 'table' then
            if val.tostring then
                valstr = val:tostring()
            else
                valstr = table.tostring(val)
            end
        else
            if type(val) == 'string' then
                valstr = '"' .. val .. '"'
            else
                valstr = tostring(val)
            end
        end

        -- Append to the string.
        if tonumber(key) then
            tstr = tstr .. valstr
        else
            tstr = tstr .. tostring(key) .. '=' .. valstr
        end

        -- Add comma, unless it's the last value.
        if next(kt, i) ~= nil then
            tstr = tstr .. ', '
        end
    end

    -- Output the result, enclosed in braces.
    return '{' .. tstr .. '}'
end

_meta = _meta or {}
_meta.T = _meta.T or {}
_meta.T.__tostring = table.tostring

-- Prints a string representation of a table in explicit Lua syntax: {...}
function table.print(t, keys)
    if t.tostring then
        log(t:tostring(keys))
    else
        log(table.tostring(t, keys))
    end
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
    k = 0
    for key in pairs(t) do
        k = k + 1
        kt[k] = key
    end
    table.sort(kt, function(x, y)
        return type(x) ~= type(y) and type(x) == 'number' or type(x) == 'number' and type(y) == 'number' and x < y
    end)

    for i, key in pairs(kt) do
        val = t[key]
        
        local function sanitize(val)
            local ret
            if type(val) == 'string' then
                ret = '"' .. val:gsub('"','\\"') .. '"'
            else
                ret = tostring(val)
            end
            return ret
        end
        
        -- Check for nested tables
        if type(val) == 'table' then
            if val.tovstring then
                valstr = val:tovstring(keys, indentlevel + 1)
            else
                valstr = table.tovstring(val, keys, indentlevel + 1)
            end
        else
            valstr = sanitize(val)
        end

        -- Append one line with indent.
        if not keys and tonumber(key) then
            tstr = tstr .. indent .. '    ' .. '[' .. sanitize(key) .. ']=' .. valstr
        else
            tstr = tstr .. indent .. '    ' .. '[' .. sanitize(key) .. ']=' .. valstr
        end

        -- Add comma, unless it's the last value.
        if next(kt, i) ~= nil then
            tstr = tstr .. ', '
        end

        tstr = tstr .. '\n'
    end
    tstr = tstr .. indent .. '}'

    return tstr
end

-- Prints a vertical string representation of a table in explicit Lua syntax, with every element in its own line:
--- {
---     ...
--- }
function table.vprint(t, keys)
    if t.tovstring then
        log(t:tovstring(keys))
    else
        log(table.tovstring(t, keys))
    end
end

-- Load logger settings (has to be after the logging functions have been defined, so those work in the config and related files).
local config = require('config')

logger.settings = config.load('../libs/logger.xml', logger.defaults)

return logger

--[[
Copyright © 2013-2014, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
