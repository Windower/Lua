
_addon = {}
_addon.version = '0.1'
_addon.name = 'Daze'
_addon.commands = {'daze'}

function event_addon_command(...)
    term = table.concat({...}, ' ')
	local broken = split(term, ' ')
	if broken[1] ~= nil then
		if broken[1]:upper() == "HELP" then
			write('daze position <x> <y> : moves the daze text box')
			write('daze help : Shows this!')
		end
		
		if broken[1]:upper() == "POSITION" then
			if broken[3] ~= nil then
				tb_set_location('daze_box',broken[2],broken[3])
			end
		end
	end
end

function event_load()
	send_command('@alias daze lua c daze')
	tb_create('daze_box')
	tb_set_bg_color('daze_box',200,30,30,30)
	tb_set_color('daze_box',255,200,200,200)
	tb_set_location('daze_box',100,702)
	tb_set_visibility('daze_box',1)
	tb_set_bg_visibility('daze_box',1)
	tb_set_font('daze_box','Arial',10)
	daze_tab = {}
	local targId=get_player()
	currentmob = get_mob_by_index(targId['target_index'])
	update_box()
end

function event_unload()
	send_command('@unalias daze')
	tb_delete('daze_box')
end

function event_target_change(targId)
	currentmob = get_mob_by_index(targId)
	update_box()
end

function event_action(act)
	if act['category'] == 6 then
		local dazetype = ''
		local level = 0
		if act['param'] == 201 then --Quickstep
			dazetype = 'Lethargic Daze'
		elseif act['param'] == 202 then -- Box Step
			dazetype='Sluggish Daze'
		elseif act['param'] == 203 then -- Stutter Step
			dazetype='Weakened Daze'
		elseif act['param'] == 312 then -- Feather Step
			dazetype='Bewildered Daze'
		end
		level = act['targets'][1]['actions'][1]['param']
		if level == 0 then
			level = nil
		end
		local current_tab = daze_tab[currentmob['id']]
		if current_tab == nil then current_tab = {} end
		current_tab[dazetype]=level
		daze_tab[currentmob['id']] = current_tab
		update_box()
	end
end

function event_zone_change(fromId,from,toId,to)
	daze_tab = {}
	update_box()
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

function update_box()
	if currentmob['id'] == nil then
		tb_set_text('daze_box','No Target')
	elseif currentmob['id'] == 0 then
		tb_set_text('daze_box','No Target')
	else
		local dazes = daze_tab[currentmob['id']]
		local outext = ''
		if dazes ~= nil then
			for i,v in pairs(dazes) do
				outext = outext..i..' (lv.'..v..')  '
			end
			if outext == '' then
				tb_set_text('daze_box','No dazes present')
			else
				tb_set_text('daze_box',outext)
			end
		else
			tb_set_text('daze_box','No dazes present')
		end
	end
end
