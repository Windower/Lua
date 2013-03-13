function event_addon_command(...)
    local term = table.concat({...}, ' ')
	a,b,targeff = string.find(term,'Send it out ([%w]+)')
	if targeff ~= nil then
		send_it_out(targeff)
	end
end

function event_load()
	stat_array={}
	sending=0
end

function event_incoming_text(original, modified, color)
	a,b,targetchar,effect = string.find(original,'([%w]+) gains the effect of ([%w%s]+).')
	if sending==1 then 
		sending=0
		return modified,color
	end
	
	if effect~=nil then
		if stat_array[effect]==nil then
			local lines = split(original,'\7')
			stat_array[effect]={lines[1], color}
			send_command('wait .5;lua c aoebgone Send it out '..effect)
		end
		current_buff=1
		local j=stat_array[effect]
		j[#j+1]=targetchar
		
		modified = ''
	end
	
	return modified, color
end

function split(msg, match)
	local length = msg:len()
	local splitarr = {}
	local u = 1
	while u < length do
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
			u = length
		end
	end
	return splitarr
end

function send_it_out(n)
	output = stat_array[n][1]..'\7'
	for i,v in pairs(stat_array[n]) do
		if i > 3 then
			if i < #stat_array[n]-1 then
				output = output..', '
			elseif i == #stat_array[n] then
				output = output..' and '
			end
			output = output..v
		elseif i==3 then
			output = output..v
		end
	end
	if #stat_array[n]>1 then
		add_to_chat(stat_array[n][2],output..' gain the effect of '..n..'.')
	else
		add_to_chat(stat_array[n][2],output..' gains the effect of '..n..'.')
	end
	stat_array[n]=nil
	sending=1
end