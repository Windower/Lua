_addon.name = 'Scan'
_addon.version = '0.1'
_addon.command = 'scan'
_addon.author = 'Byrth'

windower.register_event('addon command',function (...)
    term = table.concat({...}, ' ')
	local broken = split(term, ' ')
	if broken[1] ~= nil then
		if broken[1]:upper() == "HELP" then
			write('scan position <x> <y> : moves the scan text box')
			write('scan help : Shows this!')
		end
		
		if broken[1]:upper() == "POSITION" then
			if broken[3] ~= nil then
				tb_set_location('scan_box',broken[2],broken[3])
			end
		end
	end
end)

windower.register_event('load',function ()
	tb_create('scan_box')
	tb_set_bg_color('scan_box',200,30,30,30)
	tb_set_color('scan_box',255,200,200,200)
	tb_set_location('scan_box',900,704)
	tb_set_visibility('scan_box',1)
	tb_set_bg_visibility('scan_box',1)
	tb_set_text('scan_box','No target / Default')
end)

windower.register_event('unload',function ()
	tb_delete('scan_box')
end)

windower.register_event('target change',function (targId)
	local currentmob = get_mob_by_index(targId)
	if currentmob ~= nil then
		if currentmob['id'] == nil then
			tb_set_text('scan_box','No target / Default')
		else
			tb_set_text('scan_box','mob_type:'..currentmob['mob_type']..'  model_size:'..currentmob['model_size']..'  targId:'..targId..'  id:'..currentmob['id'])
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
