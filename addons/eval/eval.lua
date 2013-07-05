require "data\\bootstrap"

function event_load()
	send_command('alias eval lua c eval')
end

function event_unload()
	send_command('unalias eval')
end

function event_addon_command(...)
    inp = table.concat({...}, ' ')
	assert(loadstring(inp))()
end
