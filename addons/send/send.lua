function event_addon_command(...)
    term = table.concat({...}, ' ')
	send_ipc_message(term)
end

function event_load()
	send_command('alias send lua c send')
end

function event_unload()
	send_command('unalias send')
end

function event_ipc_message(msg)
	broken = split(msg, ' ')
	
	qual = table.remove(broken,1)
	player = get_player()
	if qual:lower()==player["name"]:lower() then
		if broken ~= nil then
			relevant_msg(table.concat(broken,' '))
		end
	end
	if qual:upper() == player["main_job"]:upper() then
		if broken ~= nil then
			relevant_msg(table.concat(broken,' '))
		end
	end
end

function split(msg, match)
	length = msg:len()
	splitarr = {}
	u = 1
	while u < length do
		nextanch = msg:find(match,u)
		if nextanch ~= nil then
			splitarr[#splitarr+1] = msg:sub(u,nextanch-1)
			if nextanch~=length then
				u = nextanch+1
			else
				u = length
			end
		else
			splitarr[#splitarr+1] = msg:sub(u,length)
			u = length
		end
	end
	return splitarr
end

function relevant_msg(msg)
	if msg:sub(1,1)=='/' then
		send_command('input '..msg)
	else
		send_command(msg)
	end

end