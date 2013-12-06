packets,fields = require 'packets'
require 'tablehelper'
require 'mathhelper'

windower.register_event('load',function()
	indyarr = {'00','10','20','30','40','50','60','70','80','90','A0','B0','C0','D0','E0','F0','G0','H0','I0','J0','K0'}
	f = io.open(windower.addon_path..'data/'..tostring(os.clock())..'.log','w+')
	print(tostring(f))
	incoming = packets.data.incoming
	outgoing = packets.data.outgoing
	verbose = true
	incoming_bl = T{0x00D,0x00E,0x017,0x067,0x0DF,0x050,0x057,0x063,0x038}
	outgoing_bl = T{0x015,0x0B5,0x050}
	--incoming_record_only = 0x038
	--outgoing_record_only = 0x50
	local player = windower.ffxi.get_player()
	local petstuff = ''
	if windower.ffxi.get_mob_by_id(player['id'])['pet_index'] ~= 0 then
		print(windower.ffxi.get_mob_by_id(player['id'])['pet_index'])
		local petinfo = windower.ffxi.get_mob_by_index(windower.ffxi.get_mob_by_id(player['id'])['pet_index'])
		petstuff = ' Pet ID: '..Dec2Hex(petinfo['id'])..' Pet Index: '..Dec2Hex(petinfo['index'])
	end
	f:write('Player ID: '..Dec2Hex(player['id'])..' Index: '..Dec2Hex(player['index'])..petstuff..'\n\n')
	f:flush()
end)

windower.register_event('unload',function()
	io.close(f)
end)

windower.register_event('incoming chunk',function(id,data)
	if incoming_record_only then
		if incoming_record_only == id then
			write_packet('Incoming',incoming,id,data)
		end
	elseif (not incoming_bl:contains(id)) then
		write_packet('Incoming',incoming,id,data)
	end
end)

windower.register_event('outgoing chunk',function(id,data)
	if outgoing_record_only then
		if outgoing_record_only == id then
			write_packet('Outgoing',outgoing,id,data)
		end
	elseif (not outgoing_bl:contains(id)) then
		write_packet('Outgoing',outgoing,id,data)
	end
end)

windower.register_event('incoming text',function(original,modified,color)
	if color ~= 8 then
		f:write(tostring(os.date('%Y-%m-%dT%H:%M:%S'))..'  Text ('..color..'): '..original..'\n\n')
		f:flush()
	end
end)

function str2hex(str)
	local sixteen = 4
	local ind = 1
	local hex = string.char(0x1F,167)..'  XX  00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F'..string.char(0x1E,0x01)..'\n  '..string.char(0x1F,167)..indyarr[ind]..string.char(0x1E,0x01)..'  xx xx xx xx '
	while #str > 0 do
		local hb = Dec2Hex(string.byte(str, 1, 1))
		if #hb < 2 then hb = '0' .. hb end
		hex = hex .. hb .. ' '
		str = string.sub(str, 2)
		if sixteen == 15 and #str ~= 0 then
			ind = ind+1
			hex = hex .. '\n  '..string.char(0x1F,167)..indyarr[ind]..string.char(0x1E,0x01)..'  '
			sixteen = 0
		else
			sixteen = sixteen + 1
		end
	end
	return hex
end

function Dec2Hex(nValue)
		if nValue == nil then return '' end
		if type(nValue) == "string" then
			nValue = tonumber(nValue);
		end
		nHexVal = string.format("%X", nValue);  -- %X returns uppercase hex, %x gives lowercase letters
		sHexVal = nHexVal.."";
		return sHexVal;
end

function write_packet(packet_type,array,id,data)
	local length,sequency,content
	length = math.floor(data:byte(2)/2)*4
	sequence = data:byte(3,4)
	content = data:sub(5,#data)

	if not array[id] or array[id].name == 'Unknown' then
		local assemble = tostring(os.date('%H:%M:%S'))..'  Unidentified '..packet_type..' Packet:'..(Dec2Hex(id) or 'nil')..' Length:'..length..' Sequence:'..sequence..' Content:\n'..(str2hex(content) or 'nil')
		f:write(assemble..'\n\n')
		f:flush()
		add_to_chat(8,assemble)
	elseif verbose then
		f:write(tostring(os.date('%H:%M:%S'))..'  '..packet_type..' Packet: '..array[id].name..' Content: \n'..(str2hex(content) or 'nil')..'\n\n')
		f:flush()
	end
end