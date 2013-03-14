function event_addon_command(...)
    local term = table.concat({...}, ' ')
	a,b,targeff = string.find(term,'Send it out ([%w%s%c]+)5')
	if targeff ~= nil then
		send_it_out(targeff)
	end
end

function event_load()
	stat_array={}
	slow_spells={Protect=1,Shell=1}
end

function event_incoming_text(original, modified, color)
	local a
	local b
	local targetchar
	local effect
	a,b,targetchar,effect = string.find(original,"([%w]+) gains the effect of ([%w%s%c]+)\46")
	
	if effect~=nil then
		if stat_array[effect..'send_single'] ~= 1 then
			if stat_array[effect]==nil then
				local lines = split(original,'\7')
				if stat_array[effect]~=nil then
					write(stat_array[effect])
				end
				stat_array[effect]={lines[1], color}
				local delay = 0
				if slow_spells[effect]~=nil then
					delay = 5
				else
					delay = 2
				end
				send_command('wait '..delay..';lua c aoebgone Send it out '..effect..'5')
			end
			local j=stat_array[effect]
			j[#j+1]=targetchar
			
			modified = ''
		else
			modified = original
			stat_array[effect..'send_single'] = nil
		end
	end
	
	return modified, color
end

function send_it_out(n)
	output = stat_array[n][1]..'\7'..stat_array[n][3]
	for i,v in pairs(stat_array[n]) do
		if i > 3 then
			if i <= #stat_array[n]-1 then
				output = output..', '
			elseif i == #stat_array[n] then
				output = output..' and '
			end
			output = output..v
		end
	end
	col = stat_array[n][2]
	if #stat_array[n]>3 then
		stat_array[n]=nil
		add_to_chat(col,output..' gain the effect of '..n..'.')
	else
		stat_array[n]=nil
		stat_array[n..'send_single']=1
		add_to_chat(col,output..' gains the effect of '..n..'.')
	end
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