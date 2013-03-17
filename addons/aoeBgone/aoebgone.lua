function event_addon_command(...)
    local term = table.concat({...}, ' ')
	a,b,targeff,gn = string.find(term,'Send it out ([%w%s\39]+)5(%w+)6')
	
	
	if targeff ~= nil then
		send_it_out(targeff,gn)
	end
     
    if term:lower() == 'commamode' then
        commamode = not commamode
		write('Comma Mode flipped!')
    end
     
    if term:lower() == 'oxford' then
        oxford = not oxford
		write('Oxford Mode flipped!')
    end
     
    if term:lower() == 'targetnumber' then
        targetnumber = not targetnumber
		write('Target Number flipped!')
    end
     
    if term:lower() == 'colorful' then
        colorful = not colorful
		write('Colorful mode flipped!')
    end
     
    if term:lower() == 'cancelmulti' then
        cancelmulti = not canclemulti
		write('Multi-canceling flipped!')
    end

	if term:lower() == 'help' then
		write('AoEBgone has 3 possible commands')
		write(' 1. Help --- shows this menu')
		write('The following are defaulted off:')
		write(' 2. oxford --- Toggle use of oxford comma, Default = False')
		write(' 3. commamode --- Toggle comma-only mode, Default = False')
		write(' 4. targetnumber --- Toggle target number display, Default = True')
		write(' 5. colorful --- Colors the output by alliance member, Default = False')
		write(' 6. cancelmulti --- Cancles multiple consecutive identical lines, Default = True')
	end
end

function event_load()
	stat_array={}
	slow_spells={Protect=1,Shell=1}
    commamode= false
    oxford = false
	targetnumber = true
	colorful = false
	cancelmulti = true
	prevline = ''
	color_arr={p0=2,p1=3,p2=4,p3=6,p4=11,p5=170,
	a10=6,a11=7,a12=30,a13=206,a14=207,a15=224,
	a20=9,a21=8,a22=28,a23=38,a24=39,a25=185}
    send_command('alias aoe lua c aoebgone')
end

function event_unload()
	send_command('unalias aoe')
end

function event_incoming_text(original, modified, color)
	if cancelmulti then
		local tempcol = color%255
		if tempcol>17 then
			if tempcol~=121 then
				if original == prevline then
					modified = ''
				end
			end
		end
		prevline = original
	end
	local a
	local b
	local target
	local polarity = nil
	local effect
	local c
	local d
	local gn
	a,b,target,polarity,effect = string.find(original,"([%w]+) (%w+)s the effect of ([%w%s\39]+)\46")
	if a==nil then
		c,d,target,effect = string.find(original,"([%w]+)\39s ([%w%s\39]+) effect wears off\46")
	end
	if c ~= nil then
		gn = 'wears'
	elseif a~=nil then
		gn = 'adds'
	end
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
				send_command('wait '..delay..';lua c aoebgone Send it out '..effect..'5'..gn..'6')
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

function send_it_out(n,modus)
	output = stat_array[n][1]..'\7'
	if colorful then
		party = get_party()
	end
	if targetnumber then
		if #stat_array[n] > 3 then
			output = output.."\91"..(#stat_array[n]-2).."\93 "
		end
	end
	
	if colorful then
		for r,s in pairs(party) do
			if s['name'] == stat_array[n][3] then
				output = output..string.char(0x1F,color_arr[r])
			end
		end
	end
	
	output = output..stat_array[n][3]
	col = string.char(0x1F,stat_array[n][2])
	colnm = stat_array[n][2]
	for i,v in pairs(stat_array[n]) do
		if i > 3 then
			if i <= #stat_array[n]-1 then
				output = output..col..', '
			elseif i == #stat_array[n] then
				if commamode then
					output = output..col..', '
				else
					if oxford then
						if #stat_array[n] >4 then
							output = output..col..','
						end
					end
					output = output..col..' and '
				end	
			end
			local textcol
			if colorful then
				for r,s in pairs(party) do
					if s['name'] == v then
						output = output..string.char(0x1F,color_arr[r])
					end
				end
			end
			output = output..v
		end
	end
	if modus=='wears' then
		add_to_chat(colnm,output..col..'\39s '..n..' effect wears off.')
	elseif modus=='adds' then
		if #stat_array[n]>3 then
			add_to_chat(colnm,output..col..' '..stat_array[n..' pol']..' the effect of '..n..'.')
		else
			stat_array[n..'send_single']=1
			add_to_chat(colnm,output..col..' '..stat_array[n..' pol']..'s the effect of '..n..'.')
		end
	end
	stat_array[n..' pol']=nil
	stat_array[n]=nil
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