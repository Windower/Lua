function event_addon_command(...)
	term = table.concat({...}, ' ')
	local broken = split(term, ' ')
	if broken[1] ~= nil then
		if broken[1]:upper() == "CLEAR" then
			tell_table = {}
			recording = {}
			add_to_chat(3,'Answering Machine>> Blanking the recordings')
		end
		
		if broken[1]:upper() == "LIST" then
			for i,v in pairs(tell_table) do
				add_to_chat(5,v..' messages from '..i)
			end
		end

		if broken[1]:upper() == "PLAY" then
			if broken[2] ~= nil then
				if tell_table[broken[2]] ~= nil then
					local num = tell_table[broken[2]]
					if num == 1 then
						add_to_chat(5,'1 message from '..broken[2])
					else
						add_to_chat(5,num..' messages from '..broken[2])
					end
					for n = 1,num do
						local tablekey = recording[broken[2]]
						add_to_chat(3,broken[2]..'>> '..tablekey[n])
					end
				end
			else
				add_to_chat(3,'Answering Machine>> Playing back all messages')
				for i,v in pairs(tell_table) do
					if v == 1 then
						add_to_chat(5,'1 message from '..i)
					else
						add_to_chat(5,v..' messages from '..i)
					end
					for n = 1,v do
						local tablekey = recording[i]
						add_to_chat(3,i..'>> '..tablekey[n])
					end
				end
			end
		end
		
		if broken[1]:upper() == "HELP" then
			write('am clear : Clears all messages')
			write('am play <name> : Plays current messages, or only messages from <name> if provided')
			write('am list : Lists the names of people who have sent you tells')
		end
	end
end

function event_load()
	send_command('alias am lua c answeringmachine')
	tell_table = {}
	recording = {}
end

function event_unload()
	send_command('unalias am')
end

function event_chat_message(isGM, mode, player, message)
	if mode==3 then
		if tell_table[player] ~= nil then
			tell_table[player] = tell_table[player]+1
			local playertab = recording[player]
			playertab[#playertab+1] = message
		else
			tell_table[player] = 1
			recording[player] = {message}
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