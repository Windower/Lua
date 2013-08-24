--[[
A few string helper functions.
]]

_libs = _libs or {}
_libs.stringhelper = true
_libs.functools = _libs.functools or require('functools')

_meta = _meta or {}

debug.getmetatable('').__index = function(str, k)
    return string[k] or type(k) == 'number' and math.abs(k) <= #str and string.sub(str, k, k) or nil
end
debug.getmetatable('').__unm = functools.negate..functools.equals

-- Returns the character at position pos. Negative positions are counted from the opposite end.
function string.at(str, pos)
    return str:sub(pos, pos)
end

-- Returns the character at position pos. Defaults to 1 to return the first character.
function string.first(str, offset)
    offset = offset or 1
    return str:sub(offset, offset)
end

-- Returns the character at position #str-pos. Defaults to 0 to return the last character.
function string.last(str, offset)
    offset = offset or 1
    return str:sub(-offset, -offset)
end

-- Returns true if the string contains a substring.
function string.contains(str, sub)
    return str:find(sub, nil, true)
end

-- Splits a string into a table by a separator pattern.
function string.psplit(str, sep, maxsplit, include)
    maxsplit = maxsplit or 0

    return str:split(sep, maxsplit, include, false)
end

-- Splits a string into a table by a separator string.
function string.split(str, sep, maxsplit, include, pattern)
    if not sep or sep == '' then
        local res = {}
        local key = 0
        for c in str:gmatch('.') do
            key = key + 1
            res[key] = c
        end

        if _meta.L then
            res.n = key
            return setmetatable(res, _meta.L)
        end

        return setmetatable(res, _meta.T and _meta.T or nil)
    end

    maxsplit = maxsplit or 0
    if pattern == nil then
        pattern = true
    end

    local res = {}
    local key = 0
    local i = 1
    local startpos, endpos
    local match
    while i <= #str + 1 do
        -- Find the next occurence of sep.
        startpos, endpos = str:find(sep, i, pattern)
        -- If found, get the substring and append it to the table.
        if startpos then
            match = str:sub(i, startpos - 1)
            key = key + 1
            res[key] = match

            if include then
                key = key + 1
                res[key] = str:sub(startpos, endpos)
            end

            -- If maximum number of splits reached, return
            if key == maxsplit - 1 then
                key = key + 1
                res[key] = str:sub(endpos + 1)
                break
            end
            i = endpos + 1
        -- If not found, no more separators to split, append the remaining string.
        else
            key = key + 1
            res[key] = str:sub(i)
            break
        end
    end

    if _meta.L then
        res.n = key
        return setmetatable(res, _meta.L)
    end

    return setmetatable(res, _meta.T and _meta.T or nil)
end

-- Alias to string.sub, with some syntactic sugar.
function string.slice(str, from, to)
    return str:sub(from or 1, to or #str)
end

-- Inserts a string into a given section of another string.
function string.splice(str, from, to, str2)
    return str:sub(1, from - 1)..str2..str:sub(to + 1)
end

-- Casts a little endian encoded number from a data string.
function string.number_cast(str)
    local res = 0

    local length = #str
    for c in ipairs({string.byte(str)}) do
        length = length - 1
        res = res + c * 0x100^length
    end

    return res
end

-- Returns a monowidth hex representation of each character of a string, optionally with a separator between chars.
function string.hex(str, sep, from, to)
    return str:slice(from, to):split():map(string.zfill-{2}..math.hex..string.byte):concat(sep or '')
end

-- Returns a monowidth binary representation of every char of the string, optionally with a separator between chars.
function string.binary(str, sep, from, to)
    return str:slice(from, to):split():map(string.zfill-{8}..math.binary..string.byte):concat(sep or '')
end

-- Returns a string parsed from a hex-represented string.
function string.parse_hex(str)
    return (str:gsub('%s*0x', ''):gsub('[^%w]', ''):gsub('%w%w', string.char..tonumber-{16}))
end

-- Returns a string parsed from a binary-represented string.
function string.parse_binary(str)
    return (str:gsub('%s*0b', ''):gsub('[^%w]', ''):gsub(('[01]'):rep(8), string.char..tonumber-{2}))
end

-- Returns an iterator, that goes over every character of the string.
function string.it(str)
    return str:gmatch('.')
end

-- Removes leading and trailing whitespaces and similar characters (tabs, newlines, etc.).
function string.trim(str)
    return str:match('^%s*(.-)%s*$')
end

-- Collapses all types of spaces into exactly one whitespace
function string.spaces_collapse(str)
    return str:gsub('%s+', ' '):trim()
end

-- Removes all characters in chars from str.
function string.stripchars(str, chars)
    return (str:gsub('['..chars:escape()..']', ''))
end

-- Returns the length of a string.
function string.length(str)
    return #str
end

-- Checks it the string starts with the specified substring.
function string.startswith(str, substr)
    return str:sub(1, #substr) == substr
end

-- Checks it the string ends with the specified substring.
function string.endswith(str, substr)
    return str:sub(-#substr) == substr
end

-- Checks if string is enclosed in start and finish. If only one argument is provided, it will check for that string both at the beginning and the end.
function string.enclosed(str, start, finish)
    finish = finish or start
    return str:startswith(start) and str:endswith(finish)
end

-- Returns a string with another string prepended.
function string.prepend(str, pre)
    return pre..str
end

-- Returns a string with another string appended.
function string.append(str, post)
    return str..post
end

-- Encloses a string in start and finish. If only one argument is provided, it will enclose it with that string both at the beginning and the end.
function string.enclose(str, start, finish)
    finish = finish or start
    return start..str..finish
end

-- Returns the same string with the first letter capitalized.
function string.ucfirst(str)
    return str:sub(1, 1):upper()..str:sub(2)
end

-- Returns the same string with the first letter of every word capitalized.
function string.capitalize(str)
    local res = {}

    for _, val in ipairs(str:split(' ')) do
        res[#res + 1] = val:ucfirst()
    end

    return table.concat(res, ' ')
end

-- Takes a padding character pad and pads the string str to the left of it, until len is reached. pad defaults to a space.
function string.lpad(str, pad, len)
    pad = pad or ' '
    return (pad:rep(len)..str):sub(-(len > #str and len or #str))
end

-- Takes a padding character pad and pads the string str to the right of it, until len is reached. pad defaults to a space.
function string.rpad(str, pad, len)
    pad = pad or ' '
    return (str..pad:rep(len)):sub(1, -(len > #str and len or #str))
end

-- Returns the string padded with zeroes until the length is len.
function string.zfill(str, len)
    return str:lpad('0', len)
end

-- Converts a string in base base to a number.
function string.todec(numstr, base)
    -- Create a table of allowed values according to base and how much each is worth.
    local digits = {}
    local val = 0
    for c in ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'):gmatch('.') do
        digits[c] = val
        val = val + 1
        if val == base then
            break
        end
    end

    local index = base^(#numstr-1)
    local acc = 0
    for c in numstr:gmatch('.') do
        acc = acc + digits[c]*index
        index = index/base
    end

    return acc
end

-- Checks if a string is in a table.
-- DEPRECATED: Use (table|list|set).contains instead
function string.isin(str, t)
    for _, arg in pairs(t) do
        if arg == str then
            return true
        end
    end

    return false
end

-- Checks if a string is empty.
function string.empty(str)
    return str == ''
end

-- Returns a slug of a string.
function string.slug(str)
    return str
        :gsub(' I', '1')
        :gsub(' II', '2')
        :gsub(' III', '3')
        :gsub(' IV', '4')
        :gsub(' V', '5')
        :gsub('[^%w]', '')
        :lower()
end

-- Returns a string with Lua pattern characters escaped.
function string.escape(str)
    return (str:gsub('[[%]%%^$*()%.%+?-]', '%%%1'))
end

-- Returns a Lua pattern from a wildcard string (with ? and * as placeholders for one and many characters respectively).
function string.wildcard(str)
    return (str:gsub('[[%]%%^$()%+-.]', '%%%1'):gsub('*', '.*'):gsub('?', '.'))
end

-- Returns true if the string matches a wildcard pattern.
string.wmatch = windower.wc_match

-- Includes the | operator in the pattern for alternative matches in string.find.
function string.mfind(str, full_pattern, ...)
    local patterns = full_pattern:split('|')

    local found = {}
    for pattern in ipairs(patterns) do
        local new_found = {str:find(pattern, ...)}
        if not found[1] or new_found[1] and new_found[1] < found[1] then
            found = new_found
        end
    end

    return unpack(found)
end

-- Includes the | operator in the pattern for alternative matches in string.match.
function string.mmatch(str, full_pattern, ...)
    local patterns = full_pattern:split('|')

    local found = {}
    local index = nil
    for pattern in ipairs(patterns) do
        local start = {str:find(pattern, ...)}
        if start and (not index or start < index) then
            found = {str:match(pattern, ...)}
            index = start
        end
    end

    return unpack(found)
end

-- Includes the | operator in the pattern for alternative matches in string.gsub.
function string.mgsub(str, full_pattern, ...)
    local patterns = full_pattern:split('|')

    for pattern in ipairs(patterns) do
        str = str:gsub(pattern, ...)
    end

    return str
end

-- A string.find wrapper for wildcard patterns.
function string.wcfind(str, pattern, ...)
    return str:find(pattern:wildcard(), ...)
end

-- A string.match wrapper for wildcard patterns.
function string.wcmatch(str, pattern, ...)
    return str:match(pattern:wildcard(), ...)
end

-- A string.gmatch wrapper for wildcard patterns.
function string.wcgmatch(str, pattern, ...)
    return str:gmatch(pattern:wildcard(), ...)
end

-- A string.gsub wrapper for wildcard patterns.
function string.wcgsub(str, pattern, ...)
    return str:gsub(pattern:wildcard(), ...)
end

-- Returns a case-insensitive pattern for a given (non-pattern) string. For patterns, see string.ipattern.
function string.istring(str)
    return (str:gsub('%a', function(c) return '['..c:upper()..c:lower()..']' end))
end

-- Returns a case-insensitive pattern for a given pattern.
function string.ipattern(str)
    local res = ''
    local percent = false
    local val
    for c in str:it() do
        if c == '%' then
            percent = not percent
            res = res..c
        elseif not percent then
            val = string.byte(c)
            if val > 64 and val <= 90 or val > 96 and val <= 122 then
                res = res..'['..c:upper()..c:lower()..']'
            else
                res = res..c
            end
        else
            percent = false
            res = res..c
        end
    end

    return res
end

-- A string.find wrapper for case-insensitive patterns.
function string.ifind(str, pattern, ...)
    return str:find(pattern:ipattern(), ...)
end

-- A string.match wrapper for case-insensitive patterns.
function string.imatch(str, pattern, ...)
    return str:match(pattern:ipattern(), ...)
end

-- A string.gmatch wrapper for case-insensitive patterns.
function string.igmatch(str, pattern, ...)
    return str:gmatch(pattern:ipattern(), ...)
end

-- A string.gsub wrapper for case-insensitive patterns.
function string.igsub(str, pattern, ...)
    if not ... then print(debug.traceback()) end
    return str:gsub(pattern:ipattern(), ...)
end

-- A string.find wrapper for case-insensitive wildcard patterns.
function string.iwcfind(str, pattern, ...)
    return str:wcfind(pattern:ipattern(), ...)
end

-- A string.match wrapper for case-insensitive wildcard patterns.
function string.iwcmatch(str, pattern, ...)
    return str:wcmatch(pattern:ipattern(), ...)
end

-- A string.gmatch wrapper for case-insensitive wildcard patterns.
function string.iwcgmatch(str, pattern, ...)
    return str:wcgmatch(pattern:ipattern(), ...)
end

-- A string.gsub wrapper for case-insensitive wildcard patterns.
function string.iwcgsub(str, pattern, ...)
    return str:wcgsub(pattern:ipattern(), ...)
end

-- Returns a string with all instances of ${str} replaced with either a table or function lookup.
function string.keysub(str, sub)
    return str:gsub('${(.-)}', sub)
end

-- Counts the occurrences of a substring in a string.
function string.count(str, sub)
    return str:pcount(sub:escape())
end

-- Counts the occurrences of a pattern in a string.
function string.pcount(str, pat)
    return string.gsub[2](str, pat, '')
end

-- Splits the original string into substrings of equal size (except for possibly the last one)
function string.chunks(str, size)
    local res = {}
    local key = 0
    for i = 1, #str, size do
        key = key + 1
        rawset(res, key, str:sub(i, i + size - 1))
    end

    if _libs.lists then
        res.n = key
        return setmetatable(res, _meta.L)
    else
        return res
    end
end

-- Returns a string decoded given the appropriate information.
function string.decode(str, bits, charset)
    if type(charset) == 'string' then
        charset = charset:split()
    end
    return str:binary():chunks(bits):map(table.get+{charset}..tonumber-{2}):concat()
end

-- Returns a plural version of a string, if the provided table contains more than one element.
-- Defaults to appending an s, but accepts an option string as second argument which it will the string with.
function string.plural(str, t, replace)
    if type(t) == 'number' and t > 1 or #t > 1 then
        return replace or str..'s'
    end

    return str
end

-- Returns a formatted item list for use in natural language representation of a number of items.
-- The second argument specifies how the trailing element is handled:
-- * and: Appends the last element with an "and" instead of a comma. [Default]
-- * csv: Appends the last element with a comma, like every other element.
-- * oxford: Appends the last element with a comma, followed by an and.
-- The third argument specifies an optional output, if the table is empty.
function table.format(t, trail, subs)
    local l = #t
    if l == 0 then
        return subs or ''
    elseif l == 1 then
        return t[next(t)]
    end

    trail = trail or 'and'

    local last
    if trail == 'and' then
        last = ' and '
    elseif trail == 'csv' then
        last = ', '
    elseif trail == 'oxford' then
        last = ', and '
    else
        warning('Invalid format for table.format: \''..trail..'\'.')
    end

    return t:slice(1, -2):concat(', ')..last..t:last()
end

--[[
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
