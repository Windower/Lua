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
	
	if broken:getn() < 2 then return end
	
	qual = table.remove(broken,1)
	player = get_player()
	if qual:lower()==player["name"]:lower() then
		if broken ~= nil then
			relevant_msg(table.concat(broken,' '))
		end
	end
	if string.char(qual:byte(1)) == '@' then
		arg = string.char(qual:byte(2, qual:len())
		if arg:upper() == player["main_job"]:upper() then
			if broken ~= nil then
				relevant_msg(table.concat(broken,' '))
			end
		elseif arg:upper == 'ALL' then
			if broken ~= nil then
				relevant_msg(table.concat(broken,' '))
			end
		elseif arg:upper == 'OTHERS' then
			if broken ~= nil then
				relevant_msg(table.concat(broken,' '))
			end
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
	local player = get_player()
	msg:gsub("<me>", player['name'])
	msg:gsub("<hp>", tostring(player['hp']))
	msg:gsub("<mp>", tostring(player['mp']))
	msg:gsub("<hpp>", tostring(player['hpp']))
	msg:gsub("<mpp>", tostring(player['mpp']))
	msg:gsub("<tp>", tostring(player['tp']))
	msg:gsub("<job>", player['main_job_full']..'/'..player['sub_job_full'])
	msg:gsub("<mjob>", player['main_job_full'])
	msg:gsub("<sjob>", player['sub_job_full'])
	

	if msg:sub(1,1)=='/' then
		send_command('input '..msg)
	else
		send_command(msg)
	end

end