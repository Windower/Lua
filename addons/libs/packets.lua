--[[
A library to facilitate packet usage 
]]

_libs = _libs or {}

require('lists')
require('maths')
require('strings')
require('functions')
require('pack')

local list, math, string, functions = _libs.lists, _libs.maths, _libs.strings
local table = require('table')

local packets = {}

_libs.packets = packets

if not warning then
    warning = print+{_addon.name and '%s warning:':format(_addon.name) or 'Warning:'}
end

__meta = __meta or {}
__meta.Packet = {__tostring = function(packet)
    local res = '%s packet 0x%.3X (%s):':format(packet._dir:capitalize(), packet._id, packet._name or 'Unrecognized packet')

    local raw = packets.build(packet)
    for field in packets.fields(packet._dir, packet._id, raw):it() do
        res = '%s\n%s: %s':format(res, field.label, tostring(packet[field.label]))
        if field.fn then
            res = '%s (%s)':format(res, tostring(field.fn(packet[field.label], raw)))
        end
    end

    return res
end}

--[[
    Packet database. Feel free to correct/amend it wherever it's lacking.
]]

packets.data = require('packets/data')
packets.raw_fields = require('packets/fields')

--[[
    Lengths for C data types.
]]

local sizes = {
    ['unsigned char']   =  8,
    ['unsigned short']  = 16,
    ['unsigned int']    = 32,
    ['unsigned long']   = 64,
    ['signed char']     =  8,
    ['signed short']    = 16,
    ['signed int']      = 32,
    ['signed long']     = 64,
    ['char']            =  8,
    ['short']           = 16,
    ['int']             = 32,
    ['long']            = 64,
    ['bool']            =  8,
    ['float']           = 32,
    ['double']          = 64,
    ['data']            =  8,
    ['bit']             =  1,
    ['boolbit']         =  1,
}

-- This defines whether to treat a type with brackets at the end as an array or something special
local non_array_types = S{'bit', 'data', 'char'} 

-- Pattern to match variable size array
local pointer_pattern = '(.+)%*'
-- Pattern to match fixed size array
local array_pattern = '(.+)%[(.+)%]'

-- Function returns number of bytes, bits, items and type name
local parse_type = function(field)
    local ctype = field.ctype

    if ctype:endswith('*') then
        return nil, 1, ctype:match(pointer_pattern):trim()
    end

    local type, count_str = ctype:match(array_pattern)
    type = (type or ctype):trim()

    local array = not non_array_types:contains(type)
    local count_num =  count_str and count_str:number() or 1
    local type_count = count_str and array and count_num or 1

    local bits = (array and type_count or count_num) * sizes[type];

    return bits, type_count, type
end

local size
size = function(fields, count)
    -- A single field
    if fields.ctype then
        local bits, type_count, type = parse_type(fields)
        return bits or count * sizes[type]
    end

    -- A reference field
    if fields.ref then
        return size(fields.ref, count) * (fields.count == '*' and count or fields.count)
    end

    return fields:reduce(function(acc, field)
        return acc + size(field, count)
    end, 0)
end

local parse
parse = function(fields, data, index, max, lookup, depth)
    depth = depth or 0
    max = max == '*' and 0 or max or 1
    index = index or 32

    local res = L{}
    local count = 0
    local length = 8 * #data
    while index < length do
        count = count + 1

        local parsed = L{}
        local parsed_index = index
        for field in fields:it() do
            if field.ctype then
                -- A regular type field
                field = table.copy(field)
                local bits, type_count, type = parse_type(field)

                if not non_array_types:contains(type) and (not bits or type_count > 1) then
                    -- An array field with more than one entry, reparse recursively
                    field.ctype = type
                    local ext, new_index = parse(L{field}, data, parsed_index, not bits and '*' or type_count, nil, depth + 1)
                    parsed = parsed + ext
                    parsed_index = new_index
                else
                    -- A non-array field or an array field with one entry
                    if max ~= 1 then
                        -- Append indices to labels
                        if lookup then
                            -- Look up index name in provided table
                            local resource = lookup[1][count + lookup[2] - 1]
                            field.label = '%s %s':format(resource and resource.name or 'Unknown %d':format(count + lookup[2] - 1), field.label)
                        else
                            -- Just increment numerically
                            field.label = '%s %d':format(field.label, count)
                        end
                    end

                    if parsed_index % 8 ~= 0 and type ~= 'bit' and type ~= 'boolbit' then
                        -- Adjust to byte boundary, if non-bit type
                        parsed_index = 8 * (parsed_index / 8):ceil()
                    end

                    if not bits then
                        -- Determine length for pointer types (*)
                        type_count = ((length - parsed_index) / sizes[type]):floor()
                        bits = sizes[type] * type_count

                        field.ctype = '%s[%u]':format(type, type_count)

                        count = max
                    end

                    field.type = type
                    field.index = parsed_index
                    field.length = bits
                    field.count = type_count

                    parsed:append(field)
                    parsed_index = parsed_index + bits
                end
            else
                -- A reference field, call the parser recursively
                local type_count = field.count
                if not type_count then
                    -- If reference count not explicitly given it must be contained in the packet data
                    type_count = data:byte(field.count_ref + 1)
                end

                local ext, new_index = parse(field.ref, data, parsed_index, type_count, field.lookup, depth + 1)
                parsed = parsed + ext
                parsed_index = new_index
            end
        end

        if parsed_index <= length then
            -- Only add parsed chunk, if within length boundary
            res = res + parsed
            index = parsed_index
        else
            count = max
        end

        if count == max then
            break
        end
    end

    return res, index
end

-- Arguments are:
--  dir     'incoming' or 'outgoing'
--  id      Packet ID
--  data    Binary packet data, nil if creating a blank packet
--  ...     Any parameters taken by a packet constructor function
--          If a packet has a variable length field (e.g. char* or ref with count='*') the last value in here must be the count of that field
function packets.fields(dir, id, data, ...)
    local fields = packets.raw_fields[dir][id]

    if type(fields) == 'function' then
        fields = fields(data, ...)
    end

    if not fields then
        return nil
    end

    if not data then
        local argcount = select('#', ...)
        local bits = size(fields, argcount > 0 and select(argcount, ...) or nil)
        data = 0:char():rep(4 + 4 * ((bits or 0) / 32):ceil())
    end

    return parse(fields, data)
end

local dummy = {name='Unknown', description='No data available.'}

-- Type identifiers as declared in lpack.c
-- Windower uses an adjusted set of identifiers
-- This is marked where applicable
local pack_ids = {}
pack_ids['bit']             = 'b'   -- Windower exclusive
pack_ids['boolbit']         = 'q'   -- Windower exclusive
pack_ids['bool']            = 'B'   -- Windower exclusive
pack_ids['unsigned char']   = 'C'   -- Originally 'b', replaced by 'bit' for Windower
pack_ids['unsigned short']  = 'H'
pack_ids['unsigned int']    = 'I'
pack_ids['unsigned long']   = 'L'
pack_ids['signed char']     = 'c'
pack_ids['signed short']    = 'h'
pack_ids['signed int']      = 'i'
pack_ids['signed long']     = 'L'
pack_ids['char']            = 'c'
pack_ids['short']           = 'h'
pack_ids['int']             = 'i'
pack_ids['long']            = 'l'
pack_ids['float']           = 'f'
pack_ids['double']          = 'd'
pack_ids['data']            = 'A'

local make_pack_string = function(field)
    local ctype = field.ctype

    if pack_ids[ctype] then
        return pack_ids[ctype]
    end

    local type_name, number = ctype:match(array_pattern)
    if type_name then
        number = tonumber(number)
        local pack_id = pack_ids[type_name]
        if pack_id then
            if type_name == 'char' then
                return 'S' .. number  -- Windower exclusive
            else
                return pack_id .. number
            end
        end
    end

    type_name = ctype:match(pointer_pattern)
    if type_name then
        local pack_id = pack_ids[type_name]
        if pack_id then
            if type_name == 'char' then
                return 'z'
            else
                return pack_id .. '*'
            end
        end
    end

    return nil
end

-- Constructor for packets (both injected and parsed).
-- If data is a string it parses an existing packet, otherwise it will create
-- a new packet table for injection. In that case, data can ba an optional
-- table containing values to initialize the packet to.
-- 
-- Example usage
--  Injection:
--      local packet = packets.new('outgoing', 0x050, {
--          ['Inventory Index'] = 27,   -- 27th item in the inventory
--          ['Equipment Slot'] = 15     -- 15th slot, left ring
--      })
--      packets.inject(packet)
--
--  Injection (Alternative):
--      local packet = packets.new('outgoing', 0x050)
--      packet['Inventory Index'] = 27  -- 27th item in the inventory
--      packet['Equipment Slot'] = 15   -- 15th slot, left ring
--      packets.inject(packet)
-- 
--  Parsing:
--      windower.register_event('outgoing chunk', function(id, data)
--          if id == 0x0B6 then -- outgoing /tell
--              local packet = packets.parse('outgoing', data)
--              print(packet['Target Name'], packet['Message'])
--          end
--      end)
function packets.parse(dir, data)
    local rem = #data % 4
    if rem ~= 0 then
        data = data .. 0:char():rep(4 - rem)
    end

    local res = setmetatable({}, __meta.Packet)
    res._id, res._size, res._sequence = data:unpack('b9b7H')
    res._size = res._size * 4
    res._raw = data
    res._dir = dir
    res._name = packets.data[dir][res._id].name
    res._description = packets.data[dir][res._id].description
    res._data = data:sub(5)

    local fields = packets.fields(dir, res._id, data)
    if not fields or #fields == 0 then
        return res
    end

    local pack_str = fields:map(make_pack_string):concat()

    for key, val in ipairs({res._data:unpack(pack_str)}) do
        local field = fields[key]
        if field then
            res[field.label] = field.enc and val:decode(field.enc) or val
        end
    end

    return res
end

function packets.new(dir, id, values, ...)
    values = values or {}

    local packet = setmetatable({}, __meta.Packet)
    packet._id = id
    packet._dir = dir
    packet._sequence = 0
    packet._args = {...}

    local fields = packets.fields(packet._dir, packet._id, nil, ...)
    if not fields then
        warning('Packet 0x%.3X not recognized.':format(id))
        return packet
    end

    for field in fields:it() do
        packet[field.label] = values[field.label]

        -- Data not set
        if not packet[field.label] then
            if field.const then
                packet[field.label] = field.const

            elseif field.ctype == 'bool' or field.ctype == 'boolbit' then
                packet[field.label] = false

            elseif sizes[field.ctype] or field.ctype:startswith('bit') then
                packet[field.label] = 0

            elseif field.ctype:startswith('char') or field.ctype:startswith('data') then
                packet[field.label] = ''

            else
                warning('Bad packet! Unknown packet C type:', field.ctype)
                packet._error = true

            end
        end
    end

    return packet
end

-- Returns binary data from a packet
function packets.build(packet)
    local fields = packets.fields(packet._dir, packet._id, packet._raw, unpack(packet._args or {}))
    if not fields then
        error('Packet 0x%.3X not recognized, unable to build.':format(packet._id))
        return nil
    end

    local pack_string = fields:map(make_pack_string):concat()
    local data = pack_string:pack(fields:map(table.lookup-{packet, 'label'}):unpack())
    local rem = #data % 4
    if rem ~= 0 then
        data = data .. 0:char():rep(4 - rem)
    end

    return 'b9b7H':pack(packet._id, 1 + #data / 4, packet._sequence) .. data
end

-- Injects a packet built with packets.new
function packets.inject(packet)
    if packet._error then
        error('Bad packet, cannot inject')
        return nil
    end

    local fields = packets.fields(packet._dir, packet._id, packet._raw)
    if not fields then
        error('Packet 0x%.3X not recognized, unable to send.':format(packet._id))
        return nil
    end

    packet._raw = packets.build(packet)

    if packet._dir == 'incoming' then
        windower.packets.inject_incoming(packet._id, packet._raw)
    elseif packet._dir == 'outgoing' then
        windower.packets.inject_outgoing(packet._id, packet._raw)
    else
        error('Error sending packet, no direction specified. Please specify \'incoming\' or \'outgoing\'.')
    end
end

return packets

--[[
Copyright © 2013-2015, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
