_addon.name = 'passitem'
_addon.author = 'Ihina'
_addon.version = '1.0.0.0'
_addon.command = 'passitem'

res = require('resources')
config = require('config')
require('logger')
packets = require('packets')

items = {2955, 2956, 1127, 2957, 1126}
settings = config.load(items)



function trigger(...)
	local packet = packets.incoming(...)
	--check(packet['Pool Index'], packet['Item ID'])
	
	
end

function check(slot_index, item_id)
	for func in s:it() do
		if code[func]:contains(item_id) then
			windower.ffxi[func .. '_item'](slot_index)
			return
		end
	end
end

windower.register_event('incoming chunk', trigger:cond(function(id) return id == 0x01E end)) 

function findID(name)
     return res.items:name(windower.wc_match-{name}):keyset() + res.items:name_full(windower.wc_match-{name}):keyset()    
end   




windower.register_event('incoming text', function(str)
	if last[str] then
		if not settings.ShowOne then
			return true
		else
			if os.clock() - last[str] < .75 then
				return true
			else
				last[str] = os.clock()
			end
		end
	end
end)
