function event_load()
	stat_array={}
	slow_spells={Protect=5,Shell=5,Regen=5}
	slow_spells['Blaze Spikes'] = 5
	slow_spells['Ice Spikes'] = 5
	slow_spells['Shock Spikes'] = 5
	slow_spells['Klimaform'] = 5
    commamode= false
    oxford = true
	targetnumber = true
	colorful = true
	cancelmulti = true
	criticalhits = true
	allow = 1
	prevline = ''
	color_arr={p0=2,p1=3,p2=4,p3=5,p4=6,p5=1,
	a10=2,a11=3,a12=4,a13=5,a14=6,a15=1,
	a20=2,a21=3,a22=4,a23=5,a24=6,a25=1}
    send_command('alias aoe lua c aoebgone cmd')
end

function event_unload()
	send_command('unalias aoe')
end

function event_addon_command(...)
    local term = table.concat({...}, ' ')
    local splitarr = split(term,' ')
	if splitarr[1] == 'cmd' then
		if splitarr[2] ~= nil then
			if splitarr[2]:lower() == 'commamode' then
				commamode = not commamode
				write('Comma Mode flipped!')
			end
			 
			if splitarr[2]:lower() == 'oxford' then
				oxford = not oxford
				write('Oxford Mode flipped!')
			end
			 
			if splitarr[2]:lower() == 'targetnumber' then
				targetnumber = not targetnumber
				write('Target Number flipped!')
			end
			 
			if splitarr[2]:lower() == 'colorful' then
				colorful = not colorful
				write('Colorful mode flipped!')
			end
			 
			if splitarr[2]:lower() == 'cancelmulti' then
				cancelmulti = not canclemulti
				write('Multi-canceling flipped!')
			end
			 
			if splitarr[2]:lower() == 'criticalhits' then
				criticalhits = not criticalhits
				write('Critical Hits flipped!')
			end

			if splitarr[2]:lower() == 'help' then
				write('AoEBgone has 3 possible commands')
				write(' 1. Help --- shows this menu')
				write('The following are defaulted off:')
				write(' 2. oxford --- Toggle use of oxford comma, Default = True')
				write(' 3. commamode --- Toggle comma-only mode, Default = False')
				write(' 4. targetnumber --- Toggle target number display, Default = True')
				write(' 5. colorful --- Colors the output by alliance member, Default = True')
				write(' 6. cancelmulti --- Cancles multiple consecutive identical lines, Default = True')
				write(' 7. criticalhits --- Combines critical hits into a single line, Default = True')
			end
		end
	else
		local a,b,targeff,gn = string.find(term,'Send it out ([%w%s\39]+)5(%w+)6')
		
		if targeff ~= nil then
			send_it_out(targeff,gn)
		end
		
		if splitarr[1] == 'allow' then
			--write('Got Here!')
			prevline = ''
			allow = 1
		end
	end
end

function event_incoming_text(original, modified, color)
	if cancelmulti then
		if color%256>17 then
			if original == prevline then
				modified = ''
				if allow == 1 then
					send_command('wait 1;lua c aoebgone allow')
					allow = 0
				end
			else
				prevline = original
			end
		end
	end
	
	local a,b,target,effect,c,d,e,f,gn
	local polarity = nil
	a,b,target,polarity,effect = string.find(original,"([%w]+) (%w+)s the effect of ([%w%s\39]+)\46")
	if a==nil then
		c,d,target,effect = string.find(original,"([%w]+)\39s ([%w%s\39]+) effect wears off\46")
--		if criticalhits then
--			if c==nil then
--				e,f,player = string.find(original,"(%w+) scores a critical hit!")
--				if e ~= nil then
--					local temp_strarr = split(original,string.char(7))
--					modified = table.concat(temp_strarr,' ')
--				end
--			end
--		end
--		write((color%256)..'  msg: '..original)
--		if criticalhits then
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
					delay = slow_spells[effect]
				else
					delay = 1.2
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
	col = string.char(0x1F,stat_array[n][2]%256)
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