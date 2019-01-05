--[[
    Small implementation of a fully-featured XML reader.
]]

_libs = _libs or {}

require('tables')
require('lists')
require('sets')
require('strings')

local table, list, set, string = _libs.tables, _libs.lists, _libs.sets, _libs.strings
local files = require('files')

local xml = {}

_libs.xml = xml

-- Local functions
local entity_unescape
local xml_error
local pcdata
local attribute
local validate_headers
local tokenize
local get_namespace
local classify
local make_namespace_name

-- Define singleton XML characters that can delimit inner tag strings.
local singletons = '=" \n\r\t/>'
local unescapes = T{
    amp = '&',
    gt = '>',
    lt = '<',
    quot = '"',
    apos = '\''
}
local escapes = T{
    ['&'] = 'amp',
    ['>'] = 'gt',
    ['<'] = 'lt',
    ['"'] = 'quot',
    ['\''] = 'apos'
}

local spaces = S{' ', '\n', '\t', '\r'}

-- Takes a numbered XML entity as second argument and converts it to the corresponding symbol.
-- Only used internally to index the unescapes table.
function entity_unescape(_, entity)
    if entity:startswith('#x') then
        return entity:sub(3):number(16):char()
    elseif entity:startswith('#') then
        return entity:sub(2):number():char()
    else
        return entity
    end
end

local entities = setmetatable(unescapes, {__index = entity_unescape})

function string.xml_unescape(str)
    return (str:gsub("&(.-);", entities))
end

function string.xml_escape(str)
    return str:gsub('.', function(c)
        if escapes:containskey(c) then
            return '&'..escapes[c]..';'
        end
        return c
    end)
end

-- Takes a filename and tries to parse the XML in it, after a validity check.
function xml.read(file)
    if type(file) == 'string' then
        file = _libs.files.new(file)
    end

    if not file:exists() then
        return xml_error('File not found: '..file.path)
    end

    return xml.parse(file:read())
end

-- Returns nil as the parsed table and an additional error message with an optional line number.
function xml_error(message, line)
    if line == nil then
        return nil, 'XML error: '..message
    end
    return nil, 'XML error, line '..line..': '..message
end

-- Collapses spaces and xml_unescapes XML entities.
function pcdata(str)
    return str:xml_unescape():spaces_collapse()
end

function attribute(str)
    return str:gsub('%s', ' '):xml_unescape()
end

-- TODO
function validate_headers(headers)
    return true
end

-- Parsing function. Gets a string representation of an XML object and outputs a Lua table or an error message.
function xml.parse(content)
    local quote = nil
    local headers = T{xmlhead='', dtds=T{}}
    local tag = ''
    local index = 0
    local mode = 'outer'
    local line = 1
    
    -- Parse XML header
    for c in content:it() do
        if c == '\n' then
            line = line + 1
        end

        index = index + 1
        if mode == 'quote' then
            tag = tag..c
            if c == quote then
                quote = nil
                mode = 'inner'
            end

        elseif mode == 'outer' then
            if not c:match('%s') then
                if c == '<' then
                    mode = 'inner'
                    tag = c
                else
                    return xml_error('Malformatted XML headers.')
                end
            end

        elseif mode == 'inner' then
            tag = tag..c
            if c == '\'' or c == '"' then
                quote = c
                mode = 'quote'
            elseif c == '>' then
                if tag[2] == '?' then
                    headers['xmlhead'] = tag
                    tag = ''
                elseif tag[2] == '!' then
                    headers['dtds']:append(tag)
                    tag = ''
                else
                    index = index - #tag + 1
                    break
                end
                mode = 'outer'
            end
        end
    end

    if not validate_headers(headers) then
        return xml_error('Invalid XML headers.')
    end

    local tokens, err = tokenize(content:sub(index):trim(), line)
    if tokens == nil then
        return nil, err
    end

    return classify(tokens, headers)
end

-- Tokenizer. Reads a string and returns an array of lines, each line with a number of valid XML tokens. Valid tokens include:
-- * <\w+(:\w+)?    Tag names, possibly including namespace
-- * </\w+>?        Tag endings
-- * />                Single tag endings
-- * ".*(?!")\"        Attribute values
-- * \w+(:\w+)?        Attribute names, possibly including namespace
-- * .*(?!<)        PCDATA
-- * .*(?!\]\]>)    CDATA
function tokenize(content, line)
    local current = ''
    local tokens = L{}
    for i = 1, line do
        tokens:append(L{})
    end

    local quote = nil
    local mode = 'inner'
    for c in content:it() do
        -- Only useful for a line count, to produce more accurate debug messages.
        if c == '\n' then
            tokens:append(L{})
        end

        if mode == 'quote' then
            if c == quote then
                tokens:last():append('"'..current..'"')
                current = ''
                mode = 'tag'
            else
                current = current..c
            end

        elseif mode == 'comment' then
            current = current..c
            if c == '>' and current:endswith('-->' ) then
                if current:sub(5, -4):contains('--') then
                    return xml_error('Invalid token \'--\' within comment.', #tokens)
                end
                tokens:last():append(current)
                current = ''
                mode = 'inner'
            end

        elseif mode == 'inner' then
            if c == '<' then
                tokens:last():append(current:trim())
                current = '<'
                mode = 'tag'
            else
                current = current..c
            end

        elseif mode == 'cdata' then
            current = current..c
            if c == '>' and current:endswith(']]>') then
                tokens:last():append(current)
                current = ''
                mode = 'inner'
            end

        else
            if singletons:contains(c) then
                if spaces:contains(c) then
                    if #current > 0 then
                        tokens:last():append(current)
                        current = ''
                    end

                elseif c == '=' then
                    if #current > 0 then
                        tokens:last():append(current)
                    end
                    tokens:last():append('=')
                    current = ''

                elseif c == '"' or c == '\'' then
                    quote = c
                    mode = 'quote'

                elseif c == '/' then
                    if current:startswith('<') and current:length() > 1 then
                        tokens:last():append(current)
                        current = ''
                    end
                    current = current..c

                elseif c == '>' then
                    current = current..c
                    tokens:last():append(current)
                    current = ''
                    mode = 'inner'

                else
                    return xml_error('Unexpected token \''..c..'\'.', tokens:length())
                end

            else
                if c:match('[%w%d-_%.%:![%]]') ~= nil then
                    current = current..c
                    if c == '-' and current == '<!-' then
                        mode = 'comment'
                    elseif c == '[' and current == '<![CDATA[' then
                        mode = 'cdata'
                    end
                else
                    return xml_error('Unexpected character \''..c..'\'.', tokens:length())
                end
            end
        end
    end

    for array, line in tokens:it() do
        tokens[line] = array:filter(-'')
    end

    return tokens
end

-- Definition of a DOM object.
local dom = T{}
function dom.new(t)
    return T{
        type = '',
        name = '',
        namespace = nil,
        value = nil,
        children = L{},
        cdata = nil
    }:update(t)
end

-- Returns the name of the element and the namespace, if present.
function get_namespace(token)
    local splits = token:split(':')
    if #splits > 2 then
        return
    elseif #splits == 2 then
        return splits[2], splits[1]
    end
    return token
end

-- Classifies the tokens parsed by tokenize into valid XML values, and returns a DOM hierarchy.
function classify(tokens, var)
    if tokens == nil then
        return nil, var
    end

    -- This doesn't do anything yet.
    local headers = var

    local mode = 'inner'
    local parsed = L{dom.new()}
    local name = nil
    for line, intokens in ipairs(tokens) do
        for _, token in ipairs(intokens) do
            if token:startswith('<![CDATA[') then
                parsed:last().children:append(dom.new({type = 'text', value = token:sub(10, -4), cdata = true}))

            elseif token:startswith('<!--') then
                parsed:last().children:append(dom.new({type = 'comment', value = token:sub(5, -4)}))

            elseif token:startswith('</') then
                if token:sub(3, -2) == parsed:last(1).name then
                    parsed:last(2).children:append(parsed:remove())
                else
                    return xml_error('Mismatched tag ending: '..token, line)
                end

            elseif token:startswith('<') then
                if token:endswith('>') then
                    name, namespace = get_namespace(token:sub(2, -2))
                else
                    name, namespace = get_namespace(token:sub(2))
                end
                if name == nil then
                    return xml_error('Invalid namespace definition.', line)
                end
                namespace = namespace or ''

                parsed:append(dom.new({type = 'tag', name = name, namespace = namespace}))
                name, namespace = nil, nil
                if token:endswith('>') then
                    mode = 'inner'
                else
                    mode = 'tag'
                end

            elseif token:endswith('/>') then
                if mode == 'tag' then
                    parsed:last(2).children:append(parsed:remove())
                    mode = 'inner'
                else
                    return xml_error('Illegal token inside a tag: '..token, line)
                end

            elseif token:endswith('>') then
                if mode ~= 'tag' then
                    return xml_error('Unexpected token \'>\'.', line)
                end
                mode = 'inner'

            elseif token == '=' then
                if mode ~= 'eq' then
                    return xml_error('Unexpected \'=\'.')
                end
                mode = 'value'

            else
                if mode == 'tag' then
                    if parsed:last().children:find(function (el) return el.type == 'attribute' and el.name == token end) ~= nil then
                        return xml_error('Attribute '..token..' already defined. Multiple assignment not allowed.', line)
                    end
                    name, namespace = get_namespace(token)
                    namespace = tmpnamespace or parsed:last(1).namespace
                    mode = 'eq'

                elseif mode == 'value' then
                    parsed:last().children:append(dom.new({
                        type = 'attribute',
                        name = name,
                        namespace = namespace,
                        value = attribute(token:sub(2,-2))
                    }))
                    name = nil
                    namespace = ''
                    mode = 'tag'

                elseif mode == 'inner' then
                    parsed:last().children:append(dom.new({
                        type = 'text',
                        value = pcdata(token)
                    }))
                end
            end
        end
    end

    local roots = parsed:remove().children
    if #roots > 1 then
        return xml_error('Multiple root elements not allowed.')
    elseif #roots == 0 then
        return xml_error('Missing root element not allowed.')
    end

    return roots[1]
end

-- Returns a non-shitty XML representation:
-- Tree of nodes, each node can be a tag or a value. A tag has a name, list of attributes and children.
-- In case of a node, the following is provided:
-- * type node.value:       Value of node. Only provided if type was set.
-- * list node.children:    List of child nodes (tag or text nodes)
-- * string node.name:      Name of the tag
-- * iterator node.it:      Function that iterates over all children
-- * table node.attributes: Dictionary containing all attributes
function table.undomify(node, types)
    local node_type = types and types[node.name] or nil
    local res = T{}
    res.attributes = T{}
    local children = L{}
    local ctype

    for _, child in ipairs(node.children) do
        ctype = child.type
        if ctype == 'attribute' then
            res.attributes[child.name] = child.value
        elseif ctype == 'tag' then
            children:append(child:undomify(types))
        elseif ctype == 'text' then
            children:append(child.value)
        end
    end

    if node_type then
        local val = children[1] or ''
        if node_type == 'set' then
            res.children = val:split(','):map(string.trim):filter(-'')
            res.value = S(children)
        elseif node_type == 'list' then
            res.value = val:split(','):map(string.trim):filter(-'')
            res.children = res.value
        elseif node_type == 'number' then
            res.value = tonumber(val)
            res.children = L{res.value}
        elseif node_type == 'boolean' then
            res.value = val == 'true'
            res.children = L{res.value}
        end
    end

    if res.children == nil then
        res.children = children
    end

    res.get = function(t, val)
        for child in t.children:it() do
            if child.name == val then
                return child
            end
        end
    end

    res.name = node.name

    return setmetatable(res, {__index = function(t, k)
        return t.children[k]
    end})
end

-- Returns a namespace-formatted string of a DOM node.
function make_namespace_name(node)
    if node.namespace ~= '' then
        return node.namespace..':'..node.name
    end

    return node.name
end

-- Convert a DOM hierarchy to well-formed XML.
function xml.realize(node, indentlevel)
    if node.type ~= 'tag' then
        return xml_error('Only DOM objects of type \'tag\' can be realized to XML.')
    end

    indentlevel = indentlevel or 0
    local indent = ('\t'):rep(indentlevel)
    local str = indent..'<'..make_namespace_name(node)

    local attributes = T{}
    local children = T{}
    local childtypes = T{}
    for _, child in ipairs(node.children) do
        if child.type == 'attribute' then
            attributes:append(child)
        elseif child.type ~= 'attribute' then
            children:append(child)
            childtypes[child.type] = true
        else
            return xml_error('Unknown type \''..child.type..'\'.')
        end
    end

    if #attributes ~= 0 then
        for _, attribute in ipairs(attributes) do
            local nsstring = ''
            if attribute.namespace ~= node.namespace then
                nsstring = make_namespace_name(attribute)
            else
                nsstring = attribute.name
            end
            str = str..' '..nsstring..'="'..attribute.value:xml_escape()..'"'
        end
    end

    if #children == 0 then
        str = str..' />\n'
        return str
    end
    str = str..'>\n'

    local innerindent = '\t'..indent
    for _, child in ipairs(children) do
        if child.type == 'text' then
            if child.value:match('%s%s') or child.value:match('^%s') or child.value:match('%s$') then
                str = str..innerindent..'<![CDATA['..child.value..']]>\n'
            else
                str = str..innerindent..child.value:xml_escape()..'\n'
            end
        elseif child.type == 'comment' then
            str = str..innerindent..'<!--'..child.value:xml_escape()..'-->\n'
        else
            str = str..indent..xml.realize(child, indentlevel + 1)
        end
    end

    str = str..indent..'</'..node.name..'>\n'

    return str
end

-- Make an XML representation of a table.
function table.to_xml(t, indentlevel)
    indentlevel = indentlevel or 0
    local indent = (' '):rep(4*indentlevel)

    local str = ''
    for key, val in pairs(t) do
        if type(key) == 'number' then
            key = 'node'
        end
        if type(val) == 'table' and next(val) then
            str = str..indent..'<'..key..'>\n'
            str = str..table.to_xml(val, indentlevel + 1)..'\n'
            str = str..indent..'</'..key..'>\n'
        else
            if type(val) == 'table' then
                val = ''
            end
            str = str..indent..'<'..key..'>'..val:xml_escape()..'</'..key..'>\n'
        end
    end

    return str
end

return xml

--[[
Copyright © 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
