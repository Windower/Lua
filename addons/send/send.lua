function event_addon_command(...)
    term = table.concat({...}, ' ')
	broken_init = split(term, ' ')
	qual = table.remove(broken_init,1)
	player = get_player()
	if qual:lower()==player['name']:lower() then
		if broken_init ~= nil then
			relevant_msg(table.concat(broken_init,' '))
		end
	elseif qual:lower()=='@all' or qual:lower()=='@'..player['main_job']:lower() then
		if broken_init ~= nil then
			relevant_msg(table.concat(broken_init,' '))
		end
		send_ipc_message(term)
	else
		send_ipc_message(term)
	end
end

function event_load()
	send_command('alias send lua c send')
end

function event_unload()
	send_command('unalias send')
end

function event_ipc_message(msg)
	broken = split(msg, ' ')
	
	if #broken < 2 then return end
	
	qual = table.remove(broken,1)
	player = get_player()
	if qual:lower()==player["name"]:lower() then
		relevant_msg(table.concat(broken,' '))
	end
	if string.char(qual:byte(1)) == '@' then
		arg = string.char(qual:byte(2, qual:len()))
		if arg:upper() == player["main_job"]:upper() then
			if broken ~= nil then
				relevant_msg(table.concat(broken,' '))
			end
		elseif arg:upper() == 'ALL' then
			if broken ~= nil then
				relevant_msg(table.concat(broken,' '))
			end
		elseif arg:upper() == 'OTHERS' then
			if broken ~= nil then
				relevant_msg(table.concat(broken,' '))
			end
		end
	end

end

function split(msg, match)
	local length = msg:len()
	local splitarr = {}
	local u = 1
	while u <= length do
		local nextanch = msg:find(match,u)
		if nextanch ~= nil then
			splitarr[#splitarr+1] = msg:sub(u,nextanch-match:len())
			if nextanch~=length then
				u = nextanch+match:len()
			else
				u = length
			end
		else
			splitarr[#splitarr+1] = msg:sub(u,length)
			u = length+1
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
	

	if msg:sub(1,2)=='//' then
		send_command(msg:sub(3))
	elseif msg:sub(1,1)=='/' then
		send_command('input '..msg)
	elseif msg:sub(1,3)=='atc' then
		add_to_chat(55,msg:sub(5))
	else
		send_command(msg)
	end

end
