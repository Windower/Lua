--[[
A list of deciphered packets and their meaning, with a short description.
When size is 0x00 it means the size is either unknown or varies.
]]

_libs = _libs or {}
_libs.packets = true
_libs.lists = _libs.lists or require('lists')
_libs.mathhelper = _libs.mathhelper or require('mathhelper')
_libs.stringhelper = _libs.stringhelper or require('stringhelper')
_libs.functools = _libs.functools or require('functools')

require('pack')

--[[
    Packet database. Feel free to correct/amend it wherever it's lacking.
]]

local packets = {}
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
}
setmetatable(type_lengths, {__index = function(t, k)
    local type, count = k:match('([%a%s]+)%[(%d+)%]')
    if type and rawget(type_lengths, type) then
        return tonumber(count)*type_lengths[type]
    end
end})

local dummy = {name='Unknown', description='No data available.'}

-- C type information
local function make_val(ctype, ...)
    if ctype == 'unsigned int' or ctype == 'unsigned short' or ctype == 'unsigned char' or ctype == 'unsigned long' then
        return tonumber(L{...}:reverse():map(string.zfill-{2}..math.tohex):concat(), 16)
    else
        return data
    end
end

-- Type identifiers as declared in lpack.c
local pack_ids = {}
pack_ids['bool']            = 'B'
pack_ids['unsigned char']   = 'b'
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
pack_ids = setmetatable(pack_ids, {__index = function(t, k)
    local type, number = k:match('(.-)%s*%[(%d+)%]')
    if type then
        local pack_id = rawget(t, type)
        if pack_id then
            if type == 'char' then
                return 'S'..number
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
                return 'S*'
            else
                return pack_id..'*'
            end
        end
    end
end})

-- Constructor for packets (both injected and parsed).
-- If data is a string it parses an existing packet, otherwise it will create
-- a new packet table for injection. In that case, data can ba an optional
-- table containing values to initialize the packet to.
-- 
-- Example usage
--  Injection:
--      local packet = packets.outgoing(0x050, {
--          ['Inventory ID'] = 27,  -- 27th item in the inventory
--          ['Equip Slot'] = 15     -- 15th slot, left ring
--      })
--      packets.inject(packet)
-- 
--  Parsing:
--      windower.register_event('outgoing chunk', function(id, data)
--          if id == 0x0B6 then -- outgoing /tell
--              
--          end
--      end)
function packets.incoming(id, data)
    if data and type(data) == 'string' then
        return packets.parse('incoming', id, data)
    end

    return packets.new('incoming', id, data)
end

function packets.outgoing(id, data)
    if type(data) == 'string' then
        return packets.parse('outgoing', id, data)
    end

    return packets.new('outgoing', id, data)
end

function packets.parse(dir, id, data)
    local res = {}
    res._id = id
    res._raw = data
    res._dir = dir
    res._name = packets.data[dir][id].name
    res._description = packets.data[dir][id].description
    res._size = 4*math.floor(data:byte(2)/2)
    res._sequence = data:byte(3,3) + data:byte(4, 4)*2^8
    res._data = data:sub(5)

    local fields = packets.fields.get(dir, id, data)
    if not fields or #fields == 0 then
        return res
    end

    local pack_str = fields:map(table.index+{pack_ids}..table.get-{'ctype'}):concat()

    for key, val in ipairs({res._data:unpack(pack_str)}) do
        local field = fields[key]
        if not field then
            print(key, pack_str)
        else
            res[field.label] = field.enc and val:decode(6, field.enc) or val
        end
    end

    return res
end

function packets.new(dir, id, values)
    values = values or {}

    local packet = {}
    packet._id = id
    packet._dir = dir

    local fields = packets.fields.get(packet._dir, packet._id)
    if not fields then
        warning('Packet 0x'..id:hex():zfill(3)..' not recognized.')
        return packet
    end

    for field in fields:it() do
        packet[field.label] = values[field.label]

        -- Data not set
        if not packet[field.label] then
            if field.const then
                packet[field.label] = field.const

            elseif field.ctype == 'bool' then
                packet[field.label] = false

            elseif rawget(pack_ids, field.ctype) then
                packet[field.label] = 0

            elseif field.ctype:match('char%s*%[%d+%]') or field.ctype:match('char%s*%*') then
                packet[field.label] = ''

            else
                warning('Bad packet! Unknown packet C type:', field.ctype)
                packet._error = true

            end
        end
    end

    return setmetatable(packet, {__tostring = function(p)
        local res = p._dir:capitalize()..' packet 0x'..p._id:hex():zfill(3)..' ('..(p._name and p._name or 'Unrecognized packet')..'):'

        for field, value in pairs(packet) do
            if not field:startswith('_') then
                res = res..'\n'..field..': '..tostring(value)
            end
        end

        return res
    end})
end

-- Returns binary data from a packet
function packets.build(packet)
    local fields = packets.fields.get(packet._dir, packet._id, packet._raw)
    if not fields then
        error('Packet 0x'..packet._id:hex():zfill(3)..' not recognized, unable to build.')
        return
    end

    -- 'I' for the 4 byte header
    -- It's zeroed, as it will be filled out when injected
    local pack_string = 'I'..fields:map(table.index+{pack_ids}..table.get-{'ctype'}):concat()
    return pack_string:pack(0, fields:map(table.get+{packet}..table.get-{'label'}):unpack())
end

-- Injects a packet built with packets.new
function packets.inject(packet)
    if packet._error then
        error('Bad packet, cannot inject')
        return
    end

    local fields = packets.fields.get(packet._dir, packet._id, packet._raw)
    if not fields then
        error('Packet 0x'..packet._id:hex():zfill(3)..' not recognized, unable to send.')
        return
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
