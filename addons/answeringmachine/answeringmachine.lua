
_addon = {}
_addon.commands = {'answeringmachine','am'}
_addon.name = 'AnsweringMachine'
_addon.author = 'Byrth'
_addon.version = '1.0'

windower.register_event('addon command',function (...)
	term = table.concat({...}, ' ')
	local broken = split(term, ' ')
	if broken[1] ~= nil then
		if broken[1]:upper() == "CLEAR" then
			if broken[2] == nil then
				tell_table = {}
				recording = {}
				add_to_chat(4,'Answering Machine>> Blanking the recordings')
			elseif tell_table[broken[2]:upper()]~=nil then
				add_to_chat(4,'Answering Machine>> Deleting messages from '..uc_first(broken[2]))
				tell_table[broken[2]:upper()]=nil
				recording[broken[2]:upper()]=nil
			else
				add_to_chat(5,'Cancel error: Could not find specified player in tell history')
			end
		end
		
		if broken[1]:upper() == "LIST" then
			for i,v in pairs(tell_table) do
				add_to_chat(5,v..' messages from '..uc_first(i))
			end
		end

		if broken[1]:upper() == "PLAY" then
			if broken[2] ~= nil then
				if tell_table[broken[2]:upper()] ~= nil then
					local num = tell_table[broken[2]:upper()]
					if num == 1 then
						add_to_chat(5,'1 message from '..uc_first(broken[2]))
					else
						add_to_chat(5,num..' messages from '..uc_first(broken[2]))
					end
					for n = 1,num do
						local tablekey = recording[broken[2]:upper()]
						add_to_chat(4,uc_first(broken[2])..'>> '..tablekey[n])
					end
				end
			else
				add_to_chat(4,'Answering Machine>> Playing back all messages')
				for i,v in pairs(tell_table) do
					if v == 1 then
						add_to_chat(5,'1 message from '..uc_first(i))
					else
						add_to_chat(5,v..' messages from '..uc_first(i))
					end
					for n = 1,v do
						local tablekey = recording[i]
						add_to_chat(4,uc_first(i)..'>> '..tablekey[n])
					end
				end
			end
		end
		
		if broken[1]:upper() == "HELP" then
			write('am clear <name> : Clears current messages, or only messages from <name> if provided')
			write('am help : Lists these commands!')
			write('am list : Lists the names of people who have sent you tells')
			write('am msg <message> : Sets your away message, which will be sent to non-GMs only once after plugin load or message clear')
			write('am play <name> : Plays current messages, or only messages from <name> if provided')
		end
		
		
		if broken[1]:upper() == "MSG" then
			local msg_interp = broken
			table.remove(msg_interp,1)
			if msg_interp ~= nil then
				away_msg=table.concat(msg_interp,' ')
				add_to_chat(5,'Message set to: '..away_msg)
			end
		end
	end
end)

windower.register_event('load',function ()
	tell_table = {}
	recording = {}
end)

windower.register_event('chat message',function(message,player,mode,isGM)
	if mode==3 then
		if tell_table[player:upper()] ~= nil then
			tell_table[player:upper()] = tell_table[player:upper()]+1
			local playertab = recording[player:upper()]
			playertab[#playertab+1] = message
		else
			tell_table[player:upper()] = 1
			recording[player:upper()] = {message}
			if away_msg ~= nil then
				if isGM ~= 1 then
					send_command('@input /tell '..player..' '..away_msg)
				end
			end
		end
	end
end)

function split(msg, match)
	local length = msg:len()
	local splitarr = {}
	local u = 1
	while u < length do
		local nextanch = msg:find(match,u)
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

function uc_first(msg)
	local length = msg:len()
	local first_char = msg:sub(1,1)
	local rest = msg:sub(2,length)
	return first_char:upper()..rest:lower()
end
