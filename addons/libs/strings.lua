--[[
    A few string helper functions.
]]

_libs = _libs or {}

require('functions')
require('maths')

local functions, math = _libs.functions, _libs.maths
local table = require('table')

local string = require('string')

_libs.strings = string

_raw = _raw or {}
_raw.error = _raw.error or error

_meta = _meta or {}

debug.setmetatable('', {
    __index = function(str, k)
        return string[k] or type(k) == 'number' and string.sub(str, k, k) or _raw.error('"%s" is not defined for strings':format(tostring(k)), 2)
    end,
    __unm = functions.negate .. functions.equals,
    __unp = functions.equals,
})

local enum = function(...)
    local res = {}
    for i = 1, select('#', ...) do
        local name = select(i, ...)
        res[name] = setmetatable({}, {__tostring = function() return 'enum: ' .. name end})
    end
    return res
end

string.encoding = enum('ascii', 'utf8', 'shift_jis', 'binary')

-- Returns a function that returns the string when called.
function string.fn(str)
    return functions.const(str)
end

-- Returns true if the string contains a substring.
function string.contains(str, sub)
    return str:find(sub, nil, true) ~= nil
end

-- Alias to string.sub, with some syntactic sugar.
function string.slice(str, from, to)
    return str:sub(from or 1, to or #str)
end

-- Inserts a string into a given section of another string.
function string.splice(str, from, to, str2)
    return str:sub(1, from - 1)..str2..str:sub(to + 1)
end

-- Returns an iterator, that goes over every character of the string. Handles Japanese text as well as special characters and auto-translate.
do
    local adjust_from = function(str, index)
        return
            not index and 1 or
            index < 0 and #str - index + 1 or
            index == 0 and 1 or
            index
    end

    local adjust_to = function(str, index)
        return
            not index and #str or
            index < 0 and #str - index + 1 or
            index
    end

    do
        local process = function(str, from, to, fn)
            local index = from
            return function()
                if index > to then
                    return nil
                end

                local length = fn(str:byte(index, index))
                if length == nil then
                    _raw.error('Invalid code point')
                end

                index = index + length
                return str:sub(index - length, index - 1)
            end
        end

        local iterators = {
            [string.encoding.ascii] = function(str, from, to)
                return str:sub(from, to):gmatch('.')
            end,
            [string.encoding.utf8] = function(str, from, to)
                return process(str, from, to, function(byte)
                    return
                        byte < 0x80 and 1 or
                        byte < 0xE0 and 2 or
                        byte < 0xF0 and 3 or
                        byte < 0xF8 and 4
                end)
            end,
            [string.encoding.shift_jis] = function(str, from, to)
                return process(str, from, to, function(byte)
                    return
                        (byte < 0x80 or byte >= 0xA1 and byte <= 0xDF) and 1 or
                        (byte >= 0x1E and byte <= 0x1F or byte >= 0x80 and byte <= 0x9F or byte >= 0xE0 and byte <= 0xEF or byte >= 0xFA and byte <= 0xFC) and 2 or
                        byte == 0xFD and 6
                end)
            end,
            [string.encoding.binary] = function(str, from, to)
                return str:sub(from, to):gmatch('.')
            end,
        }

        function string.it(str, encoding, from, to)
            if type(encoding) ~= 'table' then
                encoding, from, to = string.encoding.ascii, encoding, from
            end
            return iterators[encoding](str, from or 1, to or #str)
        end
    end

    local all = function() return true end
    local lower = function(b) return b >= 0x61 and b <= 0x7A end
    local upper = function(b) return b >= 0x41 and b <= 0x5A end
    local control = function(b) return b == 0x7F or b < 0x20 end
    local punctuation = function(b) return b >= 0x21 and b <= 0x2F or b >= 0x3A and b <= 0x40 or b >= 0x5B and b <= 0x60 or b >= 0x7B and b <= 0x7E end
    local letter = function(b) return lower(b) or upper(b) end
    local digit = function(b) return b >= 0x30 and b <= 0x39 end
    local space = function(b) return b == 0x20 or b == 0x0A or b == 0x07 or b == 0x09 end
    local hex = function(b) return b >= 0x30 and b <= 0x39 or b >= 0x41 and b <= 0x46 or b >= 0x63 and b <= 0x66 end
    local zero = function(b) return b == 0x00 end
    local utf8_letter = function(b) return not control(b) and not digit(b) and not punctuation(b) and not space(b) end
    local shift_jis_letter = function(b) return letter(b) or b >= 0xA1 and b <= 0xDF or b >= 0x823F and b <= 0x8491 or b >= 0x889F and b <= 0x9872 or b >= 0x989F and b <= 0xEAA4 end
    local none = function() return false end
    local classes = {
        [string.encoding.ascii] = {
            a = letter,
            c = control,
            d = digit,
            l = lower,
            p = punctuation,
            u = upper,
            s = space,
            w = function(b) return letter(b) or digit(b) end,
            x = hex,
            z = zero,
        },
        [string.encoding.utf8] = {
            a = utf8_letter,
            c = control,
            d = digit,
            l = lower,
            p = punctuation,
            u = upper,
            s = space,
            w = function(b) return utf8_letter(b) or digit(b) end,
            x = hex,
            z = zero,
        },
        [string.encoding.shift_jis] = {
            a = shift_jis_letter,
            c = function(b) return control(b) or b >= 0x1E00 and b <= 0x1FFF or b >= 0xFD00000000FD and b <= 0xFDFFFFFFFFFD end,
            d = digit,
            l = lower,
            p = function(b) return punctuation(b) or b >= 0x8140 and b <= 0x81FC or b >= 0x849F and b <= 0x84BE or b >= 0x8740 and b <= 0x849C end,
            u = upper,
            s = space,
            w = function(b) return shift_jis_letter(b) or digit(b) end,
            x = hex,
            z = zero,
        },
        [string.encoding.binary] = {
            a = none,
            c = none,
            d = none,
            l = none,
            p = none,
            u = none,
            s = none,
            w = none,
            x = none,
            z = zero,
        },
    }

    do
        local rawfind = string.find

        local findplain = function(str, pattern, encoding, from, to)
            local offset = #pattern - 1
            local index = from
            local search = pattern:it(encoding):pack()
            local length = #search
            for c in str:it(encoding, from, to - offset) do
                local position = 0
                for check in str:it(encoding, index, index + offset) do
                    position = position + 1
                    if check ~= search[position] then
                        break
                    end
                    if position == length then
                        return index, index + offset
                    end
                end
                index = index + #c
            end
            return nil, nil
        end

        local types = {
            capture = {},
            fixed = {},
            match = {},
            boundary = {},
            balanced = {},
        }

        local bytes = function(c)
            local value = 0
            for i = 1, #c do
                value = value * 0x100 + string.byte(c, i, i)
            end
            return value
        end

        local parse
        parse = function(iterator, class_lookup, level)
            level = level or 0
            local pattern = {}

            local count = 0
            local last = false
            local previous_char = nil
            for c in iterator do
                if last then
                    return '$ only valid at the end'
                end

                local previous = pattern[count]
                count = count + 1
                if (c == '-' or c == '?' or c == '*' or c == '+') and previous ~= nil and (previous.type == types.match or previous.type == types.fixed) and not previous.counter then
                    if previous.type == types.fixed then
                        if previous.value == previous_char then
                            count = count - 1
                        else
                            previous.value = previous.value:sub(1, #previous.value - #previous_char)
                        end
                        local compare = bytes(c)
                        pattern[count] = {
                            type = types.match,
                            value = function(b) return b == compare end,
                        }
                    else
                        count = count - 1
                    end
                    pattern[count].counter = c
                elseif c == '(' then
                    pattern[count] = {
                        type = types.capture,
                        value = parse(iterator, class_lookup, level + 1),
                    }
                elseif c == '.' then
                    pattern[count] = {
                        type = types.match,
                        value = all,
                    }
                elseif c == '[' then
                    local set = {}
                    local next = iterator()
                    while next ~= ']' do
                        local add = next == '%' and iterator() or next
                        if add == nil then
                            return 'missing \']\''
                        end
                        set[bytes(add)] = true
                        next = iterator()
                    end

                    pattern[count] = {
                        type = types.match,
                        value = function(b) return set[b] end,
                    }
                elseif c == '^' then
                    if count > 1 then
                        return '^ only valid at the start'
                    end

                    pattern[count] = {
                        type = types.boundary,
                        value = '^',
                    }
                elseif c == '$' then
                    last = true

                    pattern[count] = {
                        type = types.boundary,
                        value = '$',
                    }
                else
                    local single = nil
                    if c == '%' then
                        local next = iterator()
                        if next == nil then
                            return 'ends with \'%\''
                        end

                        if next == 'b' then
                            local open = iterator()
                            if open == nil then
                                return 'unbalanced pattern'
                            end
                            local close = iterator()
                            if close == nil then
                                return 'unbalanced pattern'
                            end
                            pattern[count] = {
                                type = types.balanced,
                                value = {open, close},
                            }
                        else
                            local fn = class_lookup[next]
                            if fn ~= nil then
                                pattern[count] = {
                                    type = types.match,
                                    value = fn,
                                }
                            else
                                single = next
                            end
                        end
                    elseif c == ')' and level > 0 then
                        break
                    else
                        single = c
                    end

                    if single ~= nil then
                        if previous ~= nil and previous.type == types.fixed then
                            previous.value = previous.value .. single
                            count = count - 1
                        else
                            pattern[count] = {
                                type = types.fixed,
                                value = single,
                            }
                        end
                    end
                end

                previous_char = c
            end

            return pattern
        end

        local match
        match = function(iterate, pos, pattern, index)
            if index == #pattern then
                return pos - 1
            end
            index = index + 1

            local current = pattern[index]
            local type = current.type
            local value = current.value
            local iterator = iterate(pos)

            if type == types.capture then
                local inner_pattern = value
                local inner_to, inner_captures = match(iterate, pos, inner_pattern, 0)
                if not inner_to then
                    return nil
                end

                local to, captures = match(iterate, inner_to + 1, pattern, index)
                if not to then
                    return nil
                end

                local allcaptures = {{pos, inner_to}, unpack(inner_captures or {})}
                local count = #allcaptures
                for i = 1, #(captures or {}) do
                    count = count + 1
                    allcaptures[count] = captures[i]
                end

                return to, allcaptures

            elseif type == types.fixed then
                local compare = value
                local compare_length = #compare
                local length = 0
                while length < compare_length do
                    local char = iterator()
                    if char == nil or char ~= compare:sub(length + 1, length + #char) then
                        return nil
                    end

                    pos = pos + #char
                    length = length + #char
                end

                return match(iterate, pos, pattern, index)

            elseif type == types.match then
                local check = function(c) return c ~= nil and value(bytes(c)) end
                local counter = current.counter
                if not counter then
                    local char = iterator()
                    if not check(char) then
                        return nil
                    end

                    return match(iterate, pos + #char, pattern, index)

                elseif counter == '-' then
                    local to, captures = match(iterate, pos, pattern, index)
                    while to == nil do
                        local char = iterator()
                        if char == nil or not check(char) then
                            return nil
                        end

                        to, captures = match(iterate, pos + #char, pattern, index)
                    end

                    return to, captures

                else
                    if counter == '?' then
                        local char = iterator()
                        if check(char) then
                            local to, captures = match(iterate, pos + #char, pattern, index)
                            if to then
                                return to, captures
                            end
                        end

                        return match(iterate, pos, pattern, index)

                    elseif counter == '*' then
                        local char = iterator()

                        local positions = {}
                        local count = 0
                        while (check(char)) do
                            local prev = positions[count] or pos
                            count = count + 1
                            positions[count] = prev + #char
                            char = iterator()
                        end

                        for i = count, 1, -1 do
                            local to, captures = match(iterate, positions[i], pattern, index)
                            if to then
                                return to, captures
                            end
                        end

                        return match(iterate, pos, pattern, index)

                    elseif counter == '+' then
                        local char = iterator()

                        local positions = {}
                        local count = 0
                        while (check(char)) do
                            local prev = positions[count] or pos
                            count = count + 1
                            positions[count] = prev + #char
                            char = iterator()
                        end

                        for i = count, 1, -1 do
                            local to, captures = match(iterate, positions[i], pattern, index)
                            if to then
                                return to, captures
                            end
                        end

                        return nil

                    end
                end

            elseif type == types.balanced then
                local char = iterator()
                local open, close = unpack(value)
                if char ~= open then
                    return nil
                end

                local count = 1
                repeat
                    pos = pos + #char
                    char = iterator()
                    if char == nil then
                        return nil
                    end

                    if char == open then
                        count = count + 1
                    elseif char == close then
                        count = count - 1
                    end
                until char == close and count == 0

                return match(iterate, pos + #close, pattern, index)

            elseif type == types.boundary then
                local char = iterator()
                if char ~= nil then
                    return nil
                end
                return match(iterate, pos, pattern, index)

            end
        end

        local pack = function(from, iterate, pattern, offset)
            local to, captures = match(iterate, from, pattern, offset or 0)
            if to == nil then
                return nil
            end

            return {
                from = from,
                to = to,
                captures = captures or {},
            }
        end

        local findpattern = function(iterate, length, pattern)
            local first = pattern[1]
            local matches
            if first.type == types.boundary and first.value == '^' then
                matches = pack(1, iterate, pattern, 1)
            else
                for i = 1, length do
                    matches = pack(i, iterate, pattern)
                    if matches then
                        break
                    end
                end
            end

            return matches
        end

        local encoding_mt = {
            __index = function(encoding_cache, rawpattern)
                local pattern = parse(rawpattern:it(encoding_cache.encoding), classes[encoding_cache.encoding])
                rawset(encoding_cache, rawpattern, pattern)
                return pattern
            end,
        }

        local pattern_cache = setmetatable({}, {
            __index = function(pattern_cache, encoding)
                local encoding_cache = setmetatable({ encoding = encoding }, encoding_mt)
                rawset(pattern_cache, encoding, encoding_cache)
                return encoding_cache
            end,
        })

        local find = function(plain, str, pattern, encoding, from, to)
            if plain then
                return findplain(str, pattern, encoding, from, to)
            else
                local offset = from - 1
                local matches = findpattern(function(pos) return str:it(encoding, pos + offset, to) end, to - offset, pattern_cache[encoding][pattern])
                if not matches then
                    return nil
                end

                for i = 1, #matches.captures do
                    local first, last = unpack(matches.captures[i])
                    matches.captures[i] = str:sub(first + offset, last + offset)
                end

                return matches.from + offset, matches.to + offset, unpack(matches.captures)
            end
        end

        function string.find(str, pattern, encoding, from, to, plain)
            if type(encoding) ~= 'table' then
                if type(from) == 'boolean' then
                    encoding, from, to, plain = string.encoding.ascii, encoding, nil, from
                else
                    encoding, from, to, plain = string.encoding.ascii, encoding, from, to
                end
            end

            if encoding == string.encoding.ascii and to == nil then
                return rawfind(str, pattern, from, plain)
            end

            return find(plain, str, pattern, encoding, adjust_from(str, from), adjust_to(str, to))
        end
    end

    do
        local rawmatch = string.match

        local process = function(str, first, last, ...)
            if not first then
                return nil
            end

            if select('#', ...) == 0 then
                return str:sub(first, last)
            end

            return ...
        end

        function string.match(str, pattern, encoding, from, to)
            if type(encoding) ~= 'table' then
                encoding, from, to = string.encoding.ascii, encoding, from
            end

            if encoding == string.encoding.ascii and to == nil then
                return rawmatch(str, pattern, from)
            end

            return process(str, string.find(str, pattern, adjust_from(str, from), false, encoding, adjust_to(str, to)))
        end
    end

    do
        local rawgmatch = string.gmatch

        function string.gmatch(str, pattern, encoding, from, to)
            if type(encoding) ~= 'table' then
                encoding, from, to = string.encoding.ascii, encoding, from
            end

            if encoding == string.encoding.ascii and to == nil then
                return rawgmatch(str, pattern)
            end

            to = adjust_to(str, to)

            local pos = adjust_from(str, from)
            local process = function(first, last, ...)
                if not first then
                    return nil
                end

                if last >= pos then
                    pos = last + 1
                else
                    local char = str:it(encoding, pos)()
                    pos = pos + #char
                end

                if select('#', ...) == 0 then
                    return str:sub(first, last)
                end

                return ...
            end

            return function()
                return process(string.find(str, pattern, encoding, pos, to))
            end
        end
    end

    do
        local rawgsub = string.gsub

        function string.gsub(str, pattern, repl, encoding, n, from, to)
            if type(encoding) ~= 'table' then
                encoding, n, from, to = string.encoding.ascii, encoding, n, from
            end

            if encoding == string.encoding.ascii and to == nil then
                return rawgsub(str, pattern, repl)
            end

            to = adjust_to(str, to)

            local repltype = type(repl)
            repl =
                repltype == 'function' and repl or
                repltype == 'table' and function(match) return repl[match] end or
                function() return repl end

            local fragments = {}
            local count = 0
            local pos = adjust_from(str, from)
            local first, last = string.find(str, pattern, encoding, pos, to)
            while first do
                count = count + 1
                fragments[count] = str:sub(pos, first - 1)
                count = count + 1
                fragments[count] = repl(str:sub(first, last))
                if count / 2 == n then
                    break
                end
                pos = last + 1
                first, last = string.find(str, pattern, encoding, pos, to)
            end

            return table.concat(fragments) .. str:sub(pos)
        end
    end

    do
        local rawsplit = function(str, sep, encoding, maxsplit, include, raw, from, to)
            if not sep or sep == '' then
                local res = {}
                local count = 0
                for c in str:it(encoding, from, to) do
                    count = count + 1
                    res[count] = c
                end

                return res, count
            end

            maxsplit = maxsplit or 0
            if raw == nil then
                raw = true
            end

            local res = {}
            local count = 0
            local pos = 1
            local startpos, endpos
            local match
            while pos <= to + 1 do
                startpos, endpos = str:find(sep, encoding, pos, to, raw)
                if not startpos then
                    count = count + 1
                    res[count] = str:sub(pos)
                    break
                end

                match = str:sub(pos, startpos - 1)
                count = count + 1
                res[count] = match

                if include then
                    count = count + 1
                    res[count] = str:sub(startpos, endpos)
                end

                if count == maxsplit - 1 then
                    count = count + 1
                    res[count] = str:sub(endpos + 1)
                    break
                end
                pos = endpos + 1
            end

            return res, count
        end

        -- Splits a string into a table by a separator string.
        function string.split(str, sep, encoding, maxsplit, include, raw, from, to)
            if type(encoding) ~= 'table' then
                encoding, maxsplit, include, raw, from, to = string.encoding.ascii, encoding, maxsplit, include, raw, from
            end

            local res, key = rawsplit(str, sep, encoding, maxsplit, include, raw, from or 1, to or #str)

            if _meta.L then
                res.n = key
                return setmetatable(res, _meta.L)
            end

            if _meta.T then
                return setmetatable(res, _meta.T)
            end

            return res
        end
    end
end

-- Splits a string into a table by a separator pattern.
function string.psplit(str, sep, maxsplit, include)
    maxsplit = maxsplit or 0

    return str:split(sep, maxsplit, include, false)
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

-- Takes a padding character pad and pads the string str to the left of it, until len is reached.
function string.lpad(str, pad, len)
    return (pad:rep(len) .. str):sub(-(len > #str and len or #str))
end

-- Takes a padding character pad and pads the string str to the right of it, until len is reached.
function string.rpad(str, pad, len)
    return (str .. pad:rep(len)):sub(1, len > #str and len or #str)
end

-- Returns the string padded with zeroes until the length is len.
function string.zfill(str, len)
    return str:lpad('0', len)
end

-- Checks if a string is empty.
function string.empty(str)
    return str == ''
end

(function()
    -- Returns a monowidth hex representation of each character of a string, optionally with a separator between chars.
    local hex = string.zfill-{2} .. math.hex .. string.byte
    function string.hex(str, sep, from, to)
        return str:slice(from, to):split():map(hex):concat(sep or '')
    end

    -- Returns a monowidth binary representation of every char of the string, optionally with a separator between chars.
    local binary = string.zfill-{8} .. math.binary .. string.byte
    function string.binary(str, sep, from, to)
        return str:slice(from, to):split():map(binary):concat(sep or '')
    end

    -- Returns a string parsed from a hex-represented string.
    local hex_r = string.char .. tonumber-{16}
    function string.parse_hex(str)
        local interpreted_string = str:gsub('0x', ''):gsub('[^%w]', '')
        if #interpreted_string % 2 ~= 0  then
            _raw.error('Invalid input string length', 2)
        end

        return (interpreted_string:gsub('%w%w', hex_r))
    end

    -- Returns a string parsed from a binary-represented string.
    local binary_r = string.char .. tonumber-{2}
    local binary_pattern = '[01]':rep(8)
    function string.parse_binary(str)
        local interpreted_string = str:gsub('0b', ''):gsub('[^01]', '')
        if #interpreted_string % 8 ~= 0 then
            _raw.error('Invalid input string length', 2)
        end

        return (interpreted_string:gsub(binary_pattern, binary_r))
    end
end)()

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
    for _, pattern in ipairs(patterns) do
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
    for _, pattern in ipairs(patterns) do
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

    for _, pattern in ipairs(patterns) do
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

-- Returns a string decoded given the appropriate encoding.
string.decode = function(str, encoding)
    return (str:binary():chunks(encoding.bits):map(table.get+{encoding.charset} .. tonumber-{2}):concat():gsub('%z.*$', ''))
end

-- Returns a string encoded given the appropriate encoding.
string.encode = function(str, encoding)
    local binary = str:map(string.zfill-{encoding.bits} .. math.binary .. table.find+{encoding.charset})
    if encoding.terminator then
        binary = binary .. encoding.terminator(str)
    end
    return binary:rpad('0', (#binary / 8):ceil() * 8):parse_binary()
end

-- Returns a plural version of a string, if the provided table contains more than one element.
-- Defaults to appending an s, but accepts an option string as second argument which it will the string with.
function string.plural(str, t, replace)
    if type(t) == 'number' and t > 1 or #t > 1 then
        return replace or str..'s'
    end

    return str
end

-- tonumber wrapper
function string.number(...)
    return tonumber(...)
end

-- Returns a formatted item list for use in natural language representation of a number of items.
-- The second argument specifies how the trailing element is handled:
-- * and: Appends the last element with an "and" instead of a comma. [Default]
-- * csv: Appends the last element with a comma, like every other element.
-- * oxford: Appends the last element with a comma, followed by an and.
-- The third argument specifies an optional output, if the table is empty.
function table.format(t, trail, subs)
    local first = next(t)
    if not first then
        return subs or ''
    end

    trail = trail or 'and'

    local last
    if trail == 'and' then
        last = ' and '
    elseif trail == 'or' then
        last = ' or '
    elseif trail == 'list' then
        last = ', '
    elseif trail == 'csv' then
        last = ','
    elseif trail == 'oxford' then
        last = ', and '
    elseif trail == 'oxford or' then
        last = ', or '
    else
        warning('Invalid format for table.format: \''..trail..'\'.')
    end

    local res = ''
    for k, v in pairs(t) do
        local add = tostring(v)
        if trail == 'csv' and add:match('[,"]') then
            res = res .. add:gsub('"', '""'):enclose('"')
        else
            res = res .. add
        end

        if next(t, k) then
            if next(t, next(t, k)) then
                if trail == 'csv' then
                    res = res .. ','
                else
                    res = res .. ', '
                end
            else
                res = res .. last
            end
        end
    end

    return res
end

--[[
Copyright © 2013-2015, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
