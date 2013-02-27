function event_addon_command(...)
    term = table.concat({...}, ' ')
	
	send_ipc_message(term)
end

function event_load()
	send_command('alias ipc lua c ipc')
end

function event_unload()
	send_command('unalias ipc')
end

function event_ipc_message(msg)
	add_to_chat(5, msg)
end