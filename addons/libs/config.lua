--[[
    Functions that facilitate loading, parsing, manipulating and storing of config files.
]]

local config = {}

_libs = _libs or {}
_libs.config = config
_libs.tables = _libs.tables or require('tables')
_libs.sets = _libs.sets or require('sets')
_libs.strings = _libs.strings or require('strings')
_libs.xml = _libs.xml or require('xml')
_libs.files = _libs.files or require('files')

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
    if type(filename) ~= 'string' then
        filename, confdict = 'data/settings.xml', filename
    end

    local confdict_mt = getmetatable(confdict) or _meta.T
    local settings = setmetatable(table.copy(confdict or {}), {__class = 'Settings', __index = function(t, k)
        if config[k] ~= nil then
            return config[k]
        elseif confdict_mt then
            return confdict_mt.__index[k]
        end
    end})
    -- Settings member variables, in separate struct
    local meta = {}
    meta.file = _libs.files.new()
    meta.original = T{global = T{}}
    meta.chars = S{}
    meta.comments = T{}
    meta.refresh_obj = T{}
    meta.refresh_fn = L{}

    settings_map[settings] = meta

    -- Load addon config file (Windower/addon/<addonname>/data/settings.xml).
    local filepath = filename
    if not _libs.files.exists(filepath) then
        meta.file:set(filepath, true)
        meta.original.global = table.copy(settings)
        config.save(settings, 'all')

        return settings
    end

    meta.file:set(filepath)

    return parse(settings)
end

-- Reloads the settings for the provided table. Needs to be the same table that was assigned to with config.load.
function config.reload(settings)
    if not settings_map[settings] then
        error('Config reload error: unknown settings table.')
        return
    end

    parse(settings)

    for fn, obj in settings_map[settings].refresh_obj:it() do
        fn(obj, settings)
    end
    for fn in settings_map[settings].refresh_fn:it() do
        fn(settings)
    end
end

-- Resolves to the correct parser and calls the respective subroutine, returns the parsed settings table.
function parse(settings)
    local parsed = T{}
    local err
    meta = settings_map[settings]

    if not meta then print(debug.traceback()) end
    if meta.file.path:endswith('.json') then
        parsed = _libs.json.read(meta.file)

    elseif meta.file.path:endswith('.xml') then
        parsed, err = _libs.xml.read(meta.file)

        if parsed == nil then
            if err ~= nil then
                error(err)
            else
                error('XML error: Unkown error.')
            end
            return settings
        end

        parsed = settings_table(parsed, settings)
    end
    -- Determine all characters found in the settings file.
    meta.chars = parsed:keyset() - S{'global'}
    meta.original = T{}

    if table.empty(settings) then
        for char in (meta.chars + S{'global'}):it() do
            meta.original[char] = table.update(table.copy(settings), parsed[char], true)
        end

        local full_parsed = parsed.global

        if windower.ffxi.get_info().logged_in then
            full_parsed = full_parsed:update(parsed[windower.ffxi.get_player().name:lower()], true)
        end

        return settings:update(full_parsed, true)
    end

    -- Update the global settings with the per-player defined settings, if they exist. Save the parsed value for later comparison.
    for char in (meta.chars + S{'global'}):it() do
        meta.original[char] = merge(table.copy(settings), parsed[char], char)
    end
    for char in meta.chars:it() do
        meta.original[char] = table_diff(meta.original.global, meta.original[char]) or T{}
    end

    local full_parsed = parsed.global

    if windower.ffxi.get_info().logged_in then
        full_parsed = full_parsed:update(parsed[windower.ffxi.get_player().name:lower()], true)
    end

    return merge(settings, full_parsed)
end

-- Merges two tables like update would, but retains type-information and tries to work around conflicts.
function merge(t, t_merge, path)
    path = type(path) == 'string' and T{path} or path

    local oldval
    local oldtype
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
                t[lkey] = setmetatable(table.copy(val), getmetatable(val) or _meta.T)
            else
                t[lkey] = val
            end

        else
            err = false
            oldval = rawget(t, key)
            oldtype = type(oldval)
            if oldtype == 'table' and type(val) == 'table' then
                local res = merge(oldval, val, path and path:copy()+key or nil)
                if class(oldval) == 'table' or class(oldval) == 'Table' then
                    t[key] = setmetatable(table.copy(res), _meta.T)
                elseif class(oldval) == 'List' then
                    t[key] = L(table.copy(res))
                elseif class(oldval) == 'Set' then
                    t[key] = S(table.copy(res))
                else
                    notice('This is not supposed to happen. A new data structure has not yet been added to config.lua')
                    t[key] = setmetatable(res, _meta.T)
                end

            elseif oldtype ~= type(val) then
                if oldtype == 'table' then
                    if type(val) == 'string' then
                        local res = table.map(val:split(','), string.trim)
                        if class and class(oldval) == 'Set' then
                            res = S(res)
                        elseif class and class(oldval) == 'Table' then
                            res = T(res)
                        end
                        t[key] = res
                    else
                        err = true
                    end

                elseif oldtype == 'number' then
                    local testdec = tonumber(val)
                    local testhex = tonumber(val, 16)
                    if testdec then
                        t[key] = testdec
                    elseif testhex then
                        t[key] = testhex
                    else
                        err = true
                    end

                elseif oldtype == 'boolean' then
                    if val == 'true' then
                        t[key] = true
                    elseif val == 'false' then
                        t[key] = false
                    else
                        err = true
                    end

                elseif oldtype == 'string' then
                    t[key] = val
                    err = true

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
            if table.containskey(confdict, key) then
                childdict = table.copy(confdict)
            else
                childdict = confdict
            end
            t[child.name:lower()] = settings_table(child, childdict, key)
        end
    end

    return t
end

-- Writes the passed config table to the spcified file name.
-- char defaults to windower.ffxi.get_player()['name']. Set to "all" to apply to all characters.
function config.save(t, char)
    if char ~= 'all' and not windower.ffxi.get_info().logged_in then
        return
    end

    char = (char or windower.ffxi.get_player()['name']):lower()
    meta = settings_map[t]

    if char == 'all' then
        char = 'global'
    elseif char ~= 'global' and not meta.chars:contains(char) then
        meta.chars:add(char)
        meta.original[char] = setmetatable({}, _meta.T)
    end

    meta.original[char]:update(t)
	
    if char == 'global' then
        meta.original = meta.original:key_filter('global')
    else
        meta.original.global:amend(meta.original[char], true)
        meta.original[char] = table_diff(meta.original.global, meta.original[char]) or setmetatable({}, _meta.T)

        if meta.original[char]:empty(true) then
            meta.original[char] = nil
            meta.chars:remove(char)
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
            if type(cmp) ~= type(val) then
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

    local chars = (meta.original:keyset() - S{'global'}):sort()
    for char in (L{'global'} + chars):it() do
        if char == 'global' and rawget(meta.comments, 'settings') ~= nil then
            str = str..'\t<!--\n'
            local comment_lines = rawget(meta.comments, 'settings'):split('\n')
            for comment in comment_lines:it() do
                str = str..'\t\t'..comment:trim()..'\n'
            end

            str = str..'\t-->\n'
        end

        str = str..'\t<'..char..'>\n'
        str = str..nest_xml(meta.original[char], meta)
        str = str..'\t</'..char..'>\n'
    end

    str = str..'</settings>\n'
    return str
end

-- Converts a table to XML without headers using appropriate indentation and comment spacing. Used in settings_xml.
function nest_xml(t, meta, indentlevel)
    indentlevel = indentlevel or 2
    local indent = (' '):rep(4*indentlevel)

    local inlines = T{}
    local fragments = T{}
    local maxlength = 0        -- For proper comment indenting
    keys = set.sort(table.keyset(t))
    local val
    for _, key in ipairs(keys) do
        val = rawget(t, key)
        if type(val) == 'table' and not (class(val) == 'List' or class(val) == 'Set') then
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
                val = list.format(val, 'csv')
            elseif class(val) == 'Set' then
                val = set.format(val, 'csv')
            elseif type(val) == 'table' then
                val = table.format(val, 'csv')
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

function config.register(settings, fn, obj)
    if obj then
        settings_map[settings].refresh_obj[obj] = fn
    else
        settings_map[settings].refresh_fn:append(fn)
    end
end

function config.unregister(settings, key)
    settings_map[settings].refresh[key] = nil
end

windower.register_event('load', 'logout', 'login', function()
    for _, settings in settings_map:it() do
        config.reload(settings)
    end
end)

return config

--[[
Copyright (c) 2013-2014, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
