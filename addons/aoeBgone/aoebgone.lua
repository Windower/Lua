function event_addon_command(...)
    local term = table.concat({...}, ' ')
	a,b,targeff = string.find(term,'Send it out ([%w%s\39]+)5')
	
	if targeff ~= nil then
		send_it_out(targeff)
	end
     
    if term:lower() == 'commamode' then
        commamode = not commamode
    end
     
    if term:lower() == 'oxford' then
        oxford = not oxford
    end
     
    if term:lower() == 'targetnumber' then
        targetnumber = not targetnumber
    end

	if term:lower() == 'help' then
		write('AoEBgone has 3 possible commands')
		write(' 1. Help --- shows this menu')
		write('The following are defaulted off:')
		write(' 2. oxford --- Toggle use of oxford comma')
		write(' 3. commamode --- Toggle comma-only mode.')
		write(' 4. targetnumber --- Toggle target number display.')
	end
end

function event_load()
	stat_array={}
	slow_spells={Protect=1,Shell=1}
    commamode= false
    oxford = false
	targetnumber = false
    send_command('alias aoe lua c aoebgone')
end

function event_unload()
	send_command('unalias aoe')
end

function event_incoming_text(original, modified, color)
	local a
	local b
	local target
	local polarity
	local effect
	a,b,target,polarity,effect = string.find(original,"([%w]+) (%w+)s the effect of ([%w%s\39]+)\46")
	if effect~=nil then
		if stat_array[effect..'send_single'] ~= 1 then
			if stat_array[effect]==nil then
				local lines={}
				lines = split(original,'\7')
				table.remove(lines,#lines)
				stat_array[effect]={table.concat(lines,'\7'), color}
				stat_array[effect..' pol'] = polarity
				local delay = 0
				if slow_spells[effect]~=nil then
					delay = 5
				else
					delay = 1
				end
				send_command('wait '..delay..';lua c aoebgone Send it out '..effect..'5')
			end
			local j=stat_array[effect]
			j[#j+1]=target

			modified = ''
		else
			modified = original
			stat_array[effect..'send_single'] = nil
		end
	end

	return modified, color
end

function send_it_out(n)
	output = stat_array[n][1]..'\7'
	if targetnumber then
		if #stat_array[n] > 3 then
			output = output.."\91"..(#stat_array[n]-2).."\93 "
		end
	end
	output = output..stat_array[n][3]
	for i,v in pairs(stat_array[n]) do
		if i > 3 then
			if i <= #stat_array[n]-1 then
				output = output..', '
			elseif i == #stat_array[n] then
				if commamode then
					output = output..', '
				else
					if oxford then
						if #stat_array[n] >4 then
							output = output..','
						end
					end
					output = output..' and '
				end	
			end
			output = output..v
		end
	end
	col = stat_array[n][2]
	
	if #stat_array[n]>3 then
		stat_array[n]=nil
		add_to_chat(col,output..' '..stat_array[n..' pol']..' the effect of '..n..'.')
	else
		stat_array[n]=nil
		stat_array[n..'send_single']=1
		add_to_chat(col,output..' '..stat_array[n..' pol']..'s the effect of '..n..'.')
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