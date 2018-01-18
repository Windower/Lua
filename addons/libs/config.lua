--[[
    Functions that facilitate loading, parsing, manipulating and storing of config files.
]]

_libs = _libs or {}

require('tables')
require('sets')
require('lists')
require('strings')

local table, set, list, string = _libs.tables, _libs.sets, _libs.lists, _libs.strings
local xml = require('xml')
local files = require('files')
local json = require('json')

local config = {}

_libs.config = config

local error = error or print+{'Error:'}
local warning = warning or print+{'Warning:'}
local notice = notice or print+{'Notice:'}
local log = log or print

-- Map for different config loads.
local settings_map = T{}

--[[ Local functions ]]

local parse
local merge
local settings_table
local settings_xml
local nest_xml
local table_diff

-- Loads a specified file, or alternatively a file 'settings.xml' in the current addon/data folder.
function config.load(filepath, defaults)
    if type(filepath) ~= 'string' then
        filepath, defaults = 'data/settings.xml', filepath
    end

    local confdict_mt = getmetatable(defaults) or _meta.T
    local settings = setmetatable(table.copy(defaults or {}), {__class = 'Settings', __index = function(t, k)
        if config[k] ~= nil then
            return config[k]
        end

        return confdict_mt.__index[k]
    end})

    -- Settings member variables, in separate struct
    local meta = {}
    meta.file = files.new(filepath, true)
    meta.original = T{global = table.copy(settings)}
    meta.chars = S{}
    meta.comments = {}
    meta.refresh = T{}
    meta.cdata = S{}

    settings_map[settings] = meta

    -- Load addon config file (Windower/addon/<addonname>/data/settings.xml).
    if not meta.file:exists() then
        config.save(settings, 'all')
    end

    return parse(settings)
end

-- Reloads the settings for the provided table. Needs to be the same table that was assigned to with config.load.
function config.reload(settings)
    if not settings_map[settings] then
        error('Config reload error: unknown settings table.')
        return
    end

    parse(settings)

    for t in settings_map[settings].refresh:it() do
        t.fn(settings, unpack(t.args))
    end
end

-- Resolves to the correct parser and calls the respective subroutine, returns the parsed settings table.
function parse(settings)
    local parsed = T{}
    local err
    local meta = settings_map[settings]

    if meta.file.path:endswith('.json') then
        parsed = json.read(meta.file)

    elseif meta.file.path:endswith('.xml') then
        parsed, err = xml.read(meta.file)

        if not parsed then
            error(err or 'XML error: Unknown error.')
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
        local player = windower.ffxi.get_player()
        if player then
            full_parsed = full_parsed:update(parsed[player.name:lower()], true)
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

    local player = windower.ffxi.get_player()
    if player then
        full_parsed = full_parsed:update(parsed[player.name:lower()], true)
    end

    return merge(settings, full_parsed)
end

-- Merges two tables like update would, but retains type-information and tries to work around conflicts.
function merge(t, t_merge, path)
    path = type(path) == 'string' and T{path} or path

    local keys = {}
    for key in pairs(t) do
        keys[tostring(key):lower()] = key
    end

    if not t_merge then
        return t
    end
    
    for lkey, val in pairs(t_merge) do
        local key = keys[lkey:lower()]
        if not key then
            if type(val) == 'table' then
                t[lkey] = setmetatable(table.copy(val), getmetatable(val) or _meta.T)
            else
                t[lkey] = val
            end

        else
            local err = false
            local oldval = rawget(t, key)
            local oldtype = type(oldval)

            if oldtype == 'table' and type(val) == 'table' then
                t[key] = merge(oldval, val, path and path:copy() + key or nil)

            elseif oldtype ~= type(val) then
                if oldtype == 'table' then
                    if type(val) == 'string' then
                        -- Single-line CSV parser, can possible refactor this to tables.lua
                        local res = {}
                        local current = ''
                        local quote = false
                        local last
                        for c in val:gmatch('.') do
                            if c == ',' and not quote then
                                res[#res + 1] = current
                                current = ''
                                last = nil
                            elseif c == '"' then
                                if last == '"' then
                                    current = current .. c
                                    last = nil
                                else
                                    last = '"'
                                end

                                quote = not quote
                            else
                                current = current .. c
                                last = c
                            end
                        end
                        res[#res + 1] = current

                        -- TODO: Remove this after a while, not standard compliant
                        -- Currently needed to not mess up existing settings
                        res = table.map(res, string.trim)

                        if class then
                            if class(oldval) == 'Set' then
                                res = S(res)
                            elseif class(oldval) == 'List' then
                                res = L(res)
                            elseif class(oldval) == 'Table' then
                                res = T(res)
                            end
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
                    if type(val) == 'table' and not next(val) then
                        t[key] = ''
                    else
                        t[key] = val
                        err = true
                    end

                else
                    err = true
                end

            else
                t[key] = val
            end

            if err then
                if path then
                    warning('Could not safely merge values for \'%s/%s\', %s expected (default: %s), got %s (%s).':format(path:concat('/'), key, class(oldval), tostring(oldval), class(val), tostring(val)))
                end
                t[key] = val
            end
        end
    end

    return t
end

-- Parses a settings struct from a DOM tree.
function settings_table(node, settings, key, meta)
    settings = settings or T{}
    key = key or 'settings'
    meta = meta or settings_map[settings]

    local t = T{}
    if node.type ~= 'tag' then
        return t
    end

    if not node.children:all(function(n)
        return n.type == 'tag' or n.type == 'comment'
    end) and not (#node.children == 1 and node.children[1].type == 'text') then
        error('Malformatted settings file.')
        return t
    end

    -- TODO: Type checking necessary? merge should take care of that.
    if #node.children == 1 and node.children[1].type == 'text' then
        local val = node.children[1].value
        if node.children[1].cdata then
            meta.cdata:add(key)
            return val
        end

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
            if table.containskey(settings, key) then
                childdict = table.copy(settings)
            else
                childdict = settings
            end
            t[child.name:lower()] = settings_table(child, childdict, key, meta)
        end
    end

    return t
end

-- Writes the passed config table to the spcified file name.
-- char defaults to windower.ffxi.get_player().name. Set to "all" to apply to all characters.
function config.save(t, char)
    if char ~= 'all' and not windower.ffxi.get_info().logged_in then
        return
    end

    char = (char or windower.ffxi.get_player().name):lower()
    local meta = settings_map[t]

    if char == 'all' then
        char = 'global'
    elseif char ~= 'global' and not meta.chars:contains(char) then
        meta.chars:add(char)
        meta.original[char] = T{}
    end

    meta.original[char]:update(t)

    if char == 'global' then
        meta.original = T{global = meta.original.global}
        meta.chars = S{}
    else
        meta.original.global:amend(meta.original[char], true)
        meta.original[char] = table_diff(meta.original.global, meta.original[char]) or T{}

        if meta.original[char]:empty(true) then
            meta.original[char] = nil
            meta.chars:remove(char)
        end
    end

    meta.file:write(settings_xml(meta))
end

-- Returns the table containing only elements from t_new that are different from t and not nil.
function table_diff(t, t_new)
    local res = T{}
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
                            res[key] = val
                        end
                    elseif table.isarray(val) and table.isarray(cmp) then
                        if not table.equals(cmp, val) then
                            res[key] = val
                        end
                    else
                        res[key] = table_diff(cmp, val)
                    end
                elseif cmp ~= val then
                    res[key] = val
                end
            end
        end
    end

    return not table.empty(res) and res or nil
end

-- Converts a settings table to a XML representation.
function settings_xml(meta)
    local lines = L{}
    lines:append('<?xml version="1.1" ?>')
    lines:append('<settings>')

    local chars = (meta.original:keyset() - S{'global'}):sort()
    for char in (L{'global'} + chars):it() do
        if char == 'global' and meta.comments.settings then
            lines:append('    <!--')
            local comment_lines = meta.comments.settings:split('\n')
            for comment in comment_lines:it() do
                lines:append('        %s':format(comment:trim()))
            end

            lines:append('    -->')
        end

        lines:append('    <%s>':format(char))
        lines:append(nest_xml(meta.original[char], meta))
        lines:append('    </%s>':format(char))
    end

    lines:append('</settings>')
    lines:append('')
    return lines:concat('\n')
end

-- Converts a table to XML without headers using appropriate indentation and comment spacing. Used in settings_xml.
function nest_xml(t, meta, indentlevel)
    indentlevel = indentlevel or 2
    local indent = (' '):rep(4*indentlevel)

    local inlines = T{}
    local fragments = T{}
    local maxlength = 0        -- For proper comment indenting
    local keys = set.sort(table.keyset(t))
    local val
    for _, key in ipairs(keys) do
        val = t[key]
        if type(val) == 'table' and not (class(val) == 'List' or class(val) == 'Set') then
            fragments:append('%s<%s>':format(indent, key))
            if meta.comments[key] then
                local c = '<!-- %s -->':format(meta.comments[key]:trim()):split('\n')
                local pre = ''
                for cstr in c:it() do
                    fragments:append('%s%s%s':format(indent, pre, cstr:trim()))
                    pre = '\t '
                end
            end
            fragments:append(nest_xml(val, meta, indentlevel + 1))
            fragments:append('%s</%s>':format(indent, key))

        else
            if class(val) == 'List' then
                val = list.format(val, 'csv')
            elseif class(val) == 'Set' then
                val = set.format(val, 'csv')
            elseif type(val) == 'table' then
                val = table.format(val, 'csv')
            elseif type(val) == 'string' and meta.cdata:contains(tostring(key):lower()) then
                val = '<![CDATA[%s]]>':format(val)
            else
                val = tostring(val)
            end

            if val == '' then
                fragments:append('%s<%s />':format(indent, key))
            else
                fragments:append('%s<%s>%s</%s>':format(indent, key, meta.cdata:contains(tostring(key):lower()) and val or val:xml_escape(), key))
            end
            local length = fragments:last():length() - indent:length()
            if length > maxlength then
                maxlength = length
            end
            inlines[fragments:length()] = key
        end
    end

    for frag_key, key in pairs(inlines) do
        if meta.comments[key] then
            fragments[frag_key] = '%s%s<!-- %s -->':format(fragments[frag_key], ' ':rep(maxlength - fragments[frag_key]:trim():length() + 1), meta.comments[key])
        end
    end

    return fragments:concat('\n')
end

function config.register(settings, fn, ...)
    local args = {...}
    local key = tostring(args):sub(8)
    settings_map[settings].refresh[key] = {fn=fn, args=args}
    return key
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
Copyright © 2013-2015, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
