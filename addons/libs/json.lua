--[[
Small implementation of a JSON file reader.
]]

_libs = _libs or {}

require('tables')
require('lists')
require('sets')
require('strings')

local table, list, set, string = _libs.tables, _libs.lists, _libs.sets, _libs.strings
local files = require('files')

local json = {}

_libs.json = json

-- Define singleton JSON characters that can delimit strings.
local singletons = '{}[],:'
local key_types = S{'string', 'number'}
local value_types = S{'boolean', 'number', 'string', 'nil'}

-- Takes a filename and tries to parse the JSON in it, after a validity check.
function json.read(file)
    if type(file) == 'string' then
        file = files.new(file)
    end

    if not file:exists() then
        return json.error('File not found: \''..file.path..'\'')
    end

    return json.parse(file:read())
end

-- Returns nil as the parsed table and an additional error message with an optional line number.
function json.error(message, line)
    if line == nil then
        return nil, 'JSON error: '..message
    end
    return nil, 'JSON error, line '..line..': '..message
end

-- Returns a Lua value based on a string.
-- Recognizes all valid atomic JSON values: booleans, numbers, strings and null.
-- Object and error groupings will be eliminated during the classifying process.
-- If stripquotes is set to true, quote characters delimiting strings will be stripped.
function json.make_val(str, stripquotes)
    stripquotes = true and (stripquotes ~= false)

    str = str:trim()
    if str == '' then
        return nil
    elseif str == 'true' then
        return true
    elseif str == 'false' then
        return false
    elseif str == 'null' then
        return nil
    elseif stripquotes and (str:enclosed('\'') or str:enclosed('"')) then
        return str:slice(2, -2)
    end

    str = str:gsub('\\x([%w%d][%w%d])', string.char..tonumber-{16})

    return tonumber(str) or str
end

-- Parsing function. Gets a string representation of a JSON object and outputs a Lua table or an error message.
function json.parse(content)
    return json.classify(json.tokenize(content))
end

-- Tokenizer. Reads a string and returns an array of lines, each line with a number of valid JSON tokens. Valid tokens include:
-- * \w+    Keys or values
-- * :        Key indexer
-- * ,        Value separator
-- * \{\}    Dictionary start/end
-- * \[\]    List start/end
function json.tokenize(content)
    -- Tokenizer. Reads the string by characters and finds word boundaries, returning an array of tokens to be interpreted.
    local current = nil
    local tokens = L{L{}}
    local quote = nil
    local comment = false
    local line = 1

    content = content:trim()
    local length = #content
    if content:sub(length, length) == ',' then
        content = content:sub(1, length - 1)
        length = length - 1
    end

    local first = content:sub(1, 1)
    local last = content:sub(length, length)
    if first ~= '[' and first ~= '{' then
        return json.error('Invalid JSON format. Document needs to start with \'{\' (object) or \'[\' (array).')
    end

    if not (first == '[' and last == ']' or first == '{' and last == '}') then
        return json.error('Invalid JSON format. Document starts with \''..first..'\' but ends with \''..last..'\'.')
    end

    local root
    if first == '[' then
        root = 'array'
    else
        root = 'object'
    end

    content = content:sub(2, length - 1)

    for c in content:it() do
        -- Only useful for a line count, to produce more accurate debug messages.
        if c == '\n' then
            line = line + 1
            comment = false
            tokens:append(L{})
        end

        -- If the quote character is set, don't parse but syntax, but instead just append to the string until the same quote character is encountered.
        if quote ~= nil then
            current = current..c
            -- If the quote character is found, append the parsed string and reset the parsing values.
            if quote == c then
                tokens[line]:append(json.make_val(current))
                current = nil
                quote = nil
            end
        elseif not comment then
            -- If the character is a singleton character, append the previous token and this one, reset the parsing values.
            if singletons:contains(c) then
                if current ~= nil then
                    tokens[line]:append(json.make_val(current))
                    current = nil
                end
                tokens[line]:append(c)
            -- If a quote character is found, start a quoting session, see alternative condition.
            elseif c == '"' or c == '\'' and current == nil then
                quote = c
                current = c
            -- Otherwise, just append
            elseif not c:match('%s') or current ~= nil then
                -- Ignore comments. Not JSON conformant.
                if c == '/' and current ~= nil and current:last() == '/' then
                    current = current:slice(1, -2)
                    if current == '' then
                        current = nil
                    end
                    comment = true
                else
                    current = current or ''
                    current = current..c
                end
            end
        end
    end

    return tokens, root
end

-- Takes a list of tokens and analyzes it to construct a valid Lua object from it.
function json.classify(tokens, root)
    if tokens == nil then
        return tokens, root
    end

    local scopes = L{root}

    -- Scopes and their domains:
    -- * 'object': Object scope, delimited by '{' and '}' as well as global scope
    -- * 'array': Array scope, delimited by '[' and ']'
    -- Possible modes and triggers:
    -- * 'new': After an opening brace, bracket, comma or at the start, expecting a new element
    -- * 'key': After reading a key
    -- * 'colon': After reading a colon
    -- * 'value': After reading or having scoped a value (either an object, or an array for the latter)
    local modes = L{'new'}

    local parsed
    if root == 'object' then
        parsed = L{T{}}
    else
        parsed = L{L{}}
    end

    local keys = L{}
    -- Classifier. Iterates through the tokens and assigns meaning to them. Determines scoping and creates objects and arrays.
    for array, line in tokens:it() do
        for token, pos in array:it() do
            if token == '{' then
                if modes:last() == 'colon' or modes:last() == 'new' and scopes:last() == 'array' then
                    parsed:append(T{})
                    scopes:append('object')
                    modes:append('new')
                else
                    return json.error('Unexpected token \'{\'.', line)
                end
            elseif token == '}' then
                if modes:last() == 'value' or modes:last() == 'new' then
                    modes:remove()
                    scopes:remove()
                    if modes:last() == 'colon' then
                        parsed:last(2)[keys:remove()] = parsed:remove()
                    elseif modes:last() == 'new' and scopes:last() == 'array' then
                        parsed:last():append(parsed:remove())
                    else
                        return json.error('Unexpected token \'}\'.', line)
                    end
                    modes[#modes] = 'value'
                else
                    return json.error('Unexpected token \'}\'.', line)
                end
            elseif token == '[' then
                if modes:last() == 'colon' or modes:last() == 'new' and scopes:last() == 'array' then
                    parsed:append(T{})
                    scopes:append('array')
                    modes:append('new')
                else
                    return json.error('Unexpected token \'{\'.', line)
                end
            elseif token == ']' then
                if modes:last() == 'value' or modes:last() == 'new' then
                    modes:remove()
                    scopes:remove()
                    if modes:last() == 'colon' then
                        parsed[#parsed-1][keys:remove()] = parsed:remove()
                    elseif modes:last() == 'new' and scopes:last() == 'array' then
                        parsed:last():append(parsed:remove())
                    else
                        return json.error('Unexpected token \'}\'.', line)
                    end
                    modes[#modes] = 'value'
                else
                    return json.error('Unexpected token \'}\'.', line)
                end
            elseif token == ':' then
                if modes:last() == 'key' then
                    modes[#modes] = 'colon'
                else
                    return json.error('Unexpected token \':\'.', line)
                end
            elseif token == ',' then
                if modes:last() == 'value' then
                    modes[#modes] = 'new'
                else
                    return json.error('Unexpected token \',\'.', line)
                end
            elseif key_types:contains(type(token)) and modes:last() == 'new' and scopes:last() == 'object' then
                keys:append(token)
                modes[#modes] = 'key'
            elseif value_types:contains(type(token)) then
                if modes:last() == 'colon' then
                    parsed:last()[keys:remove()] = token
                    modes[#modes] = 'value'
                elseif modes:last() == 'new' then
                    if scopes:last() == 'array' then
                        parsed:last():append(token)
                        modes[#modes] = 'value'
                    else
                        return json.error('Unexpected token \''..token..'\'.', line)
                    end
                else
                    return json.error('Unexpected token \''..token..'\'.', line)
                end
            else
                return json.error('Unkown token parsed. You should never see this. Token type: '..type(token), line)
            end
        end
    end

    if parsed:empty() then
        return json.error('No JSON found.')
    end
    if #parsed > 1 then
        return json.error('Invalid nesting, missing closing tags.')
    end

    return parsed:remove()
end

return json

--[[
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
