--[[
A list of deciphered packets and their meaning, with a short description.
When size is 0x00 it means the size is either unknown or varies.
]]

local packets = {}

_libs = _libs or {}
_libs.packets = packets
_libs.lists = _libs.lists or require('lists')
_libs.maths = _libs.maths or require('maths')
_libs.strings = _libs.strings or require('strings')
_libs.functions = _libs.functions or require('functions')

require('pack')

if not warning then
    warning = print+{_addon.name and '%s warning:':format(_addon.name) or 'Warning:'}
end

--[[
    Packet database. Feel free to correct/amend it wherever it's lacking.
]]

packets.data = require('packets/data')
packets.fields = require('packets/fields')

--[[
    Lengths for C data types.
]]

local type_lengths = {
    ['unsigned char']   = 1,
    ['unsigned short']  = 2,
    ['unsigned int']    = 4,
    ['unsigned long']   = 8,
    ['signed char']     = 1,
    ['signed short']    = 2,
    ['signed int']      = 4,
    ['signed long']     = 8,
    ['char']            = 1,
    ['short']           = 2,
    ['int']             = 4,
    ['long']            = 8,
    ['bool']            = 1,
    ['float']           = 4,
    ['double']          = 8,
    ['data']            = 1,
}
setmetatable(type_lengths, {__index = function(t, k)
    local type, count = k:match('([%a%s]+)%[(%d+)%]')
    if type and rawget(type_lengths, type) then
        return tonumber(count)*type_lengths[type]
    end

    return nil
end})

local dummy = {name='Unknown', description='No data available.'}

-- C type information
local function make_val(ctype, ...)
    if ctype == 'unsigned int' or ctype == 'unsigned short' or ctype == 'unsigned char' or ctype == 'unsigned long' then
        return tonumber(L{...}:reverse():map(string.zfill-{2}..math.tohex):concat(), 16)
    end

    return data
end

-- Type identifiers as declared in lpack.c
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
pack_ids = setmetatable(pack_ids, {__index = function(t, k)
    local type, number = k:match('(.-)%s*%[(%d+)%]')
    if type then
        local pack_id = rawget(t, type)
        if pack_id then
            if type == 'char' then
                return 'S'..number  -- Windower exclusive
            else
                return pack_id..number
            end
        end
    end

    type = k:match('(.-)%s*%*')
    if type then
        local pack_id = rawget(t, type)
        if pack_id then
            if type == 'char' then
                return 'z'
            else
                return pack_id..'*'
            end
        end
    end

    return nil
end})

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
    local res = {}
    res._id, res._size, res._sequence = data:unpack('b9b7H')
    res._size = res._size * 4
    res._raw = data
    res._dir = dir
    res._name = packets.data[dir][res._id].name
    res._description = packets.data[dir][res._id].description
    res._data = data:sub(5)

    local fields = packets.fields.get(dir, res._id, data)
    if not fields or #fields == 0 then
        return res
    end

    local pack_str = fields:map(table.lookup-{pack_ids, 'ctype'}):concat()

    for key, val in ipairs({res._data:unpack(pack_str)}) do
        local field = fields[key]
        if field then
            res[field.label] = field.enc and val:decode(field.enc) or val
        end
    end

    return res
end

function packets.new(dir, id, values)
    values = values or {}

    local packet = {}
    packet._id = id
    packet._dir = dir
    packet._sequence = 0

    local fields = packets.fields.get(packet._dir, packet._id)
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

            elseif rawget(pack_ids, field.ctype) or field.ctype:startswith('bit') then
                packet[field.label] = 0

            elseif field.ctype:startswith('char') or field.ctype:startswith('data') then
                packet[field.label] = ''

            else
                warning('Bad packet! Unknown packet C type:', field.ctype)
                packet._error = true

            end
        end
    end

    return setmetatable(packet, {__tostring = function(p)
        local res = p._dir:capitalize()..' packet 0x'..p._id:hex():zfill(3)..' ('..(p._name and p._name or 'Unrecognized packet')..'):'

        local raw = packets.build(p)
        for field in fields:it() do
            res = res .. '\n' .. field.label .. ': ' .. tostring(p[field.label]) .. (field.fn and '(' .. field.fn(p[field.label], raw) .. ')' or '')
        end

        return res
    end})
end

-- Returns binary data from a packet
function packets.build(packet)
    local fields = packets.fields.get(packet._dir, packet._id, packet._raw)
    if not fields then
        error('Packet 0x'..packet._id:hex():zfill(3)..' not recognized, unable to build.')
        return nil
    end

    local pack_string = fields:map(table.lookup-{pack_ids, 'ctype'}):concat()
    local data_string = pack_string:pack(fields:map(table.lookup-{packet, 'label'}):unpack())
    while #data_string % 4 ~= 0 do
        data_string = data_string .. 0:char()
    end

    return 'b9b7H':pack(packet._id, 1 + #data_string / 4, packet._sequence) .. data_string
end

-- Injects a packet built with packets.new
function packets.inject(packet)
    if packet._error then
        error('Bad packet, cannot inject')
        return nil
    end

    local fields = packets.fields.get(packet._dir, packet._id, packet._raw)
    if not fields then
        error('Packet 0x'..packet._id:hex():zfill(3)..' not recognized, unable to send.')
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
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
