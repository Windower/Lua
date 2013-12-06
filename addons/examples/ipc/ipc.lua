windower.register_event('addon command',function (...)
    term = table.concat({...}, ' ')
	windower.send_ipc_message(term)
end)

windower.register_event('load',function ()
	windower.send_command('alias ipc lua c ipc')
end}

windower.register_event('unload',function ()
	windower.send_command('unalias ipc')
end}

windower.register_event('ipc message',function (msg)
	windower.add_to_chat(5, msg)
end}