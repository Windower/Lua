packets = require('packets')

_addon.name = 'AllSeeingEye'
_addon.version = '1.0'
_addon.author = 'Project Tako'


windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)
	if (id == 14) then
		--packet = packets.parse('incoming', data)	
		local _packet = data:sub(1, 32)
		
		status = data:byte(0x21)
		if (status == 2 or status == 6 or status == 7) then
			_packet = _packet..'0'
			_packet = _packet..data:sub(34, 34)
			_packet = _packet..'0'
			_packet = _packet..data:sub(36, 41)
			_packet = _packet..'0'
			_packet = _packet..data:sub(43)
		else
			_packet = data
		end
		
		return _packet
	end
	
end)