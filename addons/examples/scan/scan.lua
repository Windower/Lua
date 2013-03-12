function event_addon_command(...)
    term = table.concat({...}, ' ')
	local broken = split(term, ' ')
	if broken[1] ~= nil then
		if broken[1]:upper() == "HELP" then
			write('scan position <x> <y> : moves the scan text box')
			write('scan help : Shows this!')
		end
		
		if broken[1]:upper() == "POSITION" then
			if broken[3] ~= nil then
				send_command('text set scan_box position '..broken[2]..' '..broken[3])
			end
		end
	end
end

function event_load()
	send_command('alias scan lua c scan')
	send_command('load text')
	send_command('text verbose 0')
	write('The text plugin has had its verbose level has been set to 0. Only errors will be mentioned')
	send_command('text create scan_box')
	send_command('text set scan_box bg 30 30 30 200')
	send_command('text set scan_box fg 200 200 200 255')
	send_command('text set scan_box position 900 704')
	send_command('text set scan_box show')
	send_command('text set scan_box showbg')
	send_command('text set scan_box text "No target / Default"')
end

function event_unload()
	send_command('unalias scan')
	send_command('text delete scan_box')
end

function event_target_change(targId)
	local currentmob = get_mob_by_target_id(targId)
	if currentmob ~= nil then
		if currentmob['id'] == nil then
			send_command('text set scan_box text "No target / Default"')
		else
			send_command('text set scan_box text "'..'mob_type:'..currentmob['mob_type']..'  model_size:'..currentmob['model_size']..'  targId:'..targId..'  id:'..currentmob['id']..'"')
		end
	end
end

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