--[[
A list of deciphered packets and their meaning, with a short description.
When size is 0x00 it means the size is either unknown or varies.
]]

_libs = _libs or {}
_libs.packets = true
_libs.lists = _libs.lists or require 'lists'
_libs.mathhelper = _libs.mathhelper or require 'mathhelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
_libs.functools = _libs.functools or require 'functools'

require 'pack'

local packets = {}
packets.data = require 'packets/data'
packets.fields = require 'packets/fields'

--[[
	Packet database. Feel free to correct/amend it wherever it's lacking.
]]

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
pack_ids['bool'] = 'B'
pack_ids['unsigned char'] = 'b'
pack_ids['unsigned short'] = 'H'
pack_ids['unsigned int'] = 'I'
pack_ids['unsigned long'] = 'L'
pack_ids['signed char'] = 'c'
pack_ids['signed short'] = 'h'
pack_ids['signed int'] = 'i'
pack_ids['signed long'] = 'L'
pack_ids['char'] = 'c'
pack_ids['short'] = 'h'
pack_ids['int'] = 'i'
pack_ids['long'] = 'l'
pack_ids['float'] = 'f'
pack_ids['double'] = 'd'
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
end})

-- Constructor for packets (both injected and parsed).
-- If data is a string it parses an existing packet, otherwise it will create
-- a new packet table for injection. In that case, data can ba an optional
-- table containing values to initialize the packet to.
-- Example usage:
--      local packet = packets.out(0x050, {
-- 	        ['Inventory ID'] = 27,
--          ['Equip Slot'] = 15
--      })
--      packets.inject(packet)
function packets.incoming(id, data)
	if data and type(data) == 'string' then
		return packets.parse(id, 'incoming', data)
	end

	return packets.new(id, 'incoming', data)
end

function packets.outgoing(id, data)
	if type(data) == 'string' then
		return packets.parse(id, 'outgoing', data)
	end

	return packets.new(id, 'outgoing', data)
end

function packets.parse(id, mode, data)
	local res = {}
	res._raw = data
    res._mode = mode
	res._name = packets[mode][id].name
	res._description = packets[mode][id].description
	res._id = id
	res._size = 4*math.floor(data:byte(2)/2)
	res._sequence = data:byte(3,3) + data:byte(4, 4)*2^8
	res._data = data:sub(5)

	local fields = packets.fields[mode][id]
	if #fields == 0 then
		return res
	end

	local keys = fields:map(table.get-{'label'})
	local pack_str = '<'..fields:map((function(ct) return pack_ids[ct] end)..table.get-{'ctype'}):concat()

	for key, val in ipairs({res._data:unpack(pack_str)}) do
		if keys[key] then
			res[keys[key]] = val
		end
	end

	return res
end

function packets.new(id, mode, values)
	values = values or {}

	local packet = {}
	packet._id = id
	packet._mode = mode

	local fields = packets.fields[mode][id]
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
			elseif field.ctype:match('char%s*%[%d+%]') then
				packet[field.label] = ''
			else
				warning('Unknown packet C type:', field.ctype)
			end
		end
	end

	return packet
end

-- Returns binary data from a packet
function packets.build(packet)
	local fields = packets.fields[packet._mode][packet._id]
	local pack_string = fields:map(table.index+{pack_ids}..table.get-{'ctype'}):concat()
    return pack_string:pack(fields:map(table.get+{packet}..table.get-{'label'}):unpack())
end

-- Injects a packet built with packets.new
function packets.inject(packet)
	local fields = packets.fields[packet._mode][packet._id]
	if not fields then
		error('Packet 0x'..packet._id:hex():zfill(3)..' not recognized, unable to send.')
		return
	end

	packet._data = packets.build(packet)

	log(packet._data:hex(' '))
	if packet._mode == 'incoming' then
		log(windower.packets.inject_incoming(packet._id, packet._data):hex())
	elseif packet._mode == 'outgoing' then
		log(windower.packets.inject_outgoing(packet._id, packet._data):hex())
	else
		error('Error sending packet, no mode specified. Please specify \'incoming\' or \'outgoing\'.')
	end
end

return packets
