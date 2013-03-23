--Copyright (c) 2013, Byrthnoth
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


function event_load()
	stat_array={}
	slow_spells={Protect=5,Shell=5,Regen=5}
	slow_spells['Blaze Spikes'] = 5
	slow_spells['Ice Spikes'] = 5
	slow_spells['Shock Spikes'] = 5
	slow_spells['Klimaform'] = 5
	allow = 1
	prevline = ''
	line_full = 'Full line is not loading'
	line_nouser = 'No User line is not loading'
	line_nodmg = 'No Damage line is not loading'
	color_arr={p0='\x1F\x02',p1='\x1F\x03',p2='\x1F\x04',p3='\x1F\x05',p4='\x1F\x06',p5='\x1F\x01',
	a10='\x1F\x02',a11='\x1F\x03',a12='\x1F\x04',a13='\x1F\x05',a14='\x1F\x06',a15='\x1F\x01',
	a20='\x1F\x02',a21='\x1F\x03',a22='\x1F\x04',a23='\x1F\x05',a24='\x1F\x06',a25='\x1F\x01',
	mob='\x1F\xA7', mobdmg='\x1F\x08', mydmg='\x1F\x08', partydmg='\x1F\x08', allydmg='\x1F\x08', otherdmg='\x1F\x08'}
    send_command('alias bm lua c battlemod cmd')
	options_load()
end

function options_load()
	local f = io.open(lua_base_path..'data/settings.txt', "r")
	if f == nil then
		local g = io.open(lua_base_path..'data/settings.txt', "w")
		g:write('Release Date: 1:10 AM, 3-23-12\46')
		g:write('Author Comment: This document is whitespace sensitive, which means that you need the same number of spaces between things as exist in this initial settings file\46\n')
		g:write('Author Comment: It looks at the first two words separated by spaces and then takes anything as the value in question if the first two words are relevant\46\n')
		g:write('Author Comment: If you ever mess it up so that it does not work, you can just delete it and battlemod will regenerate it upon reload\46\n')
		g:write('Author Comment: For the output customization lines, \36\123user\125 denotes a value to be replaced. The options are user, damg, abil, and targ\46\n')
		g:write('Author Comment: Options for the other modes are either true or false\46\n')
		g:write('Author Comment: Colors are customizable based on party / alliance position. Use the colortest command to view the available colors\46\n')
		g:write('File Settings: Fill in below\n')
		g:write('Output Full: \91\36\123user\125\93 \36\123damg\125 \36\123abil\125 \x81\xA8 \36\123targ\125\n')
		g:write('Output NoUser: \36\123abil\125 \36\123damg\125 \x81\xA8 \36\123targ\125\n')
		g:write('Output NoDamg: \91\36\123user\125\93 \36\123abil\125 \x81\xA8 \36\123targ\125\n')
		g:write('Condense Battle: true\nCondense Buffs: true\nComma Mode: false\nOxford Comma: true\nColorful Names: true\nSuper Silence: true\nTarget Number: true\n')
		g:write('Color p0: 2\nColor p1: 3\nColor p2: 4\nColor p3: 5\nColor p4: 6\nColor p5: 1\n')
		g:write('Color a10: 2\nColor a11: 3\nColor a12: 4\nColor a13: 5\nColor a14: 6\nColor a15: 1\n')
		g:write('Color a20: 2\nColor a21: 3\nColor a22: 4\nColor a23: 5\nColor a24: 6\nColor a25: 1\n')
		g:write('Color mob: 167\nColor mobdmg: 8\nColor mydmg: 8\nColor partydmg: 8\nColor allydmg: 8\nColor otherdmg: 8')
		g:close()
		line_full = '\91\36\123user\125\93 \36\123damg\125 \36\123abil\125 \x81\xA8 \36\123targ\125'
		line_nouser = '\36\123abil\125 \36\123damg\125 \x81\xA8 \36\123targ\125'
		line_nodmg = '\91\36\123user\125\93 \36\123abil\125 \x81\xA8 \36\123targ\125'
		commamode= false
		oxford = true
		targetnumber = true
		colorful = true
		cancelmulti = true
		condensebattle = true
		condensebuffs = true
		write('Default settings file created')
		add_to_chat(12,'Battlemod created a settings file and loaded!')
	else
		f:close()
		for curline in io.lines(lua_base_path..'data/settings.txt') do
			local splat = split(curline,' ')
			local cmd = ''
			if splat[2] ~=nil then
				cmd = (splat[1]..' '..splat[2]):gsub(':',''):lower()
			end
			if cmd == 'output full' then
				table.remove(splat,2)
				table.remove(splat,1)
				line_full = table.concat(splat,' ')
			elseif cmd == 'output nouser' then
				table.remove(splat,2)
				table.remove(splat,1)
				line_nouser = table.concat(splat,' ')
			elseif cmd == 'output nodamg' then
				table.remove(splat,2)
				table.remove(splat,1)
				line_nodmg = table.concat(splat,' ')
			elseif cmd == 'comma mode' then
				commamode = str2bool(splat[3])
			elseif cmd == 'oxford comma' then
				oxford = str2bool(splat[3])
			elseif cmd == 'colorful names' then
				colorful = str2bool(splat[3])
			elseif cmd == 'super silence' then
				cancelmulti = str2bool(splat[3])
			elseif cmd == 'target number' then
				targetnumber = str2bool(splat[3])
			elseif cmd == 'condense battle' then
				condensebattle = str2bool(splat[3])
			elseif cmd == 'condense buffs' then
				condensebuffs = str2bool(splat[3])
			elseif splat[1]:lower() == 'color' then
				color_arr[splat[2]:gsub(':',''):lower()] = colconv(splat[3],splat[2]:gsub(':',''))
			end
		end
		add_to_chat(12,'Battlemod read from a settings file and loaded!')
	end
	output_arr = {}
end

function str2bool(input)
	if input:lower() == 'true' then
		return true
	elseif input:lower() == 'false' then
		return false
	else
		write('This setting is not a suitable boolean value\46 Please use true or false: '..input)
		return false
	end
end

function colconv(str,key)
	local out
	strnum = tonumber(str)
	if strnum == 7 or strnum == 262 then
		write('You have an invalid color '..key)
		return string.char(0x1F,1)
	end
	if strnum >= 256 and strnum < 509 then
		strnum = strnum - 254
		out = string.char(0x1E,strnum)
	elseif strnum >0 then
		out = string.char(0x1F,strnum)
	else
		write('You have an invalid color '..key)
		out = string.char(0x1F,1)
	end
	return out
end

function event_addon_command(...)
    local term = table.concat({...}, ' ')
    local splitarr = split(term,' ')
	if splitarr[1] == 'cmd' then
		if splitarr[2] ~= nil then
			if splitarr[2]:lower() == 'commamode' then
				commamode = not commamode
				write('Comma Mode flipped!')
			elseif splitarr[2]:lower() == 'oxford' then
				oxford = not oxford
				write('Oxford Mode flipped!')
			elseif splitarr[2]:lower() == 'targetnumber' then
				targetnumber = not targetnumber
				write('Target Number flipped!')
			elseif splitarr[2]:lower() == 'colorful' then
				colorful = not colorful
				write('Colorful mode flipped!')
			elseif splitarr[2]:lower() == 'cancelmulti' then
				cancelmulti = not canclemulti
				write('Multi-canceling flipped!')
			elseif splitarr[2]:lower() == 'condensebattle' then
				condensebattle = not condensebattle
				write('Condensed Battle text flipped!')
			elseif splitarr[2]:lower() == 'condensebuffs' then
				condensebuffs = not condensebuffs
				write('Condensed Buffs text flipped!')
			elseif splitarr[2]:lower() == 'colortest' then
				for i = 0, 32 do
						local line = ''
						for j = 1, 16 do
								local n = i * 16 + j
								if n >= 0 and n <= 509 then
										if n == 253 or n == 507 then -- block \x1E\xFD and \x1F\xFD
												loc_col = '\031\001'
										elseif n == 7 or n == 261 then -- block \x1E\x07 and \x1F\x07
												loc_col = '\031\001'
										elseif n <= 255 then
												loc_col = string.char(0x1F, n)
										else
												loc_col = string.char(0x1E, n - 254)
										end
										line = line..loc_col..string.format('%03d ', n)
								end
						end
						add_to_chat(1, line)
				end
				write('Colors Tested!')
			elseif splitarr[2]:lower() == 'help' then
				write('Battlemod has 9 commands')
				write(' 1. help --- shows this menu')
				write(' 2. colortest --- Shows the 509 possible colors for use with the settings file')
				write('Big Toggles:')
				write(' 3. condensebuffs --- Condenses Area of Effect buffs, Default = True')
				write(' 4. condensebattle --- Condenses battle logs according to your settings file, Default = True')
				write(' 5. cancelmulti --- Cancles multiple consecutive identical lines, Default = True')
				write('Sub Toggles:')
				write(' 6. oxford --- Toggle use of oxford comma, Default = True')
				write(' 7. commamode --- Toggle comma-only mode, Default = False')
				write(' 8. targetnumber --- Toggle target number display, Default = True')
				write(' 9. colorful --- Colors the output by alliance member, Default = True')
			end
		end
	else
		local a,b,targeff,gn = string.find(term,'Send it out ([%w%s\39]+)5(%w+)6')
		
		if targeff ~= nil then
			send_it_out(targeff,gn)
		end
		
		if splitarr[1] == 'allow' then
			prevline = ''
			allow = 1
		end
	end
end

function event_incoming_text(original, modified, color)
	local redcol = color%256
	if cancelmulti then
		if redcol >17 then
			if original == prevline then
				a,b = string.find(original,'You buy the')
				c,b = string.find(original,' bought ')
				d,b = string.find(original,'You find a ')
				if a==nil and c==nil then
					modified = ''
					if allow == 1 then
						send_command('wait 5;lua c battlemod allow')
						allow = 0
					end
				end
			else
				prevline = original
			end
		end
	end
	
	if condensebuffs then
		if redcol == 191 or redcol == 56 or redcol == 64 or redcol==101 or redcol==111 then
			local a,b,target,effect,c,d,e,f,gn
			local polarity = nil
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
							delay = slow_spells[effect]
						else
							delay = 1.2
						end
						send_command('wait '..delay..';lua c battlemod Send it out '..effect..'5'..gn..'6')
					end
					stat_array[effect][#stat_array[effect]+1] = target

					modified = ''
				else
					modified = original
					stat_array[effect..'send_single'] = nil
				end
			end
			
		end
	end
	
	if condensebattle then
		if redcol == 20 or redcol == 21 or redcol == 25 or redcol == 26 or redcol == 28 or redcol == 29 or redcol == 32 or redcol == 33 or redcol == 40 or redcol == 41 or redcol == 163 or redcol == 164 then
			local takes,a,targ1,dmg1 = string.find(original,"([%w%s]+) takes? (%d+) points of damage\46")
			local uses,a,user1,abil1 = string.find(original,"([%w%s]+) uses? (%u[%w%s\39\58]+)\46?\44?")
			local casts,a,user4,abil2 = string.find(original,"([%w%s]+) casts? (%u[%w%s\39\58]+)\46")
			local crit,a,user2 = string.find(original,"([%w%s]+)\39?s? ?r?a?n?g?e?d? ?a?t?t?a?c?k? scores? a critical hit!")
			local hits,a,user3,targ2,dmg2 = string.find(original,"([%w%s]+)\39?s? ?r?a?n?g?e?d? ?a?t?t?a?c?k? hits? ([%w%s]+) for (%d+) points of damage\46")
			local ranged,a = string.find(original,"ranged attack")
			local skillchain,a,abil3 = string.find(original,'Skillchain: (%w+)\46')
			local counter,a,targ3,user6 = string.find(original,'([%w%s]+)\39?s? attack is countered by ([%w%s]+)\46')
			local spikes,a,user7,dmg3,targ4 = string.find(original,'([%w%s]+)\39?s? spikes deal (%d+) points? of damage to ([%w%s]+)\46')
			local addeffect,a,targ5,dmg4 = string.find(original,'Additional effect: ([%w%s]+) takes (%d+) additional points? of damage\46')
			local addeffect2,a,effect = string.find(original,' and is (%w+)\46')
			local misses,a,user8,targ6 = string.find(original,'([%w%s]+)\39?s? ?r?a?n?g?e?d? ?a?t?t?a?c?k? misse?s? ([%w%s]+)\46')
			local parry,a,user9,targ7 = string.find(original,'([%w%s]+) parries ([%w%s]+)\39?s? attack')
			local dodge,a,user10,targ8 = string.find(original,'([%w%s]+) dodges ([%w%s]+)\39?s? attack')
			
			output_arr['targ'] = targ1 or targ2 or targ3 or targ4 or targ5 or targ6 or targ7 or targ8 or ''
			output_arr['damg'] = dmg1 or dmg2 or dmg3 or dmg4 or ''
			output_arr['user'] = user1 or user2 or user3 or user4 or user5 or user6 or user7 or user8 or user9 or user10 or ''
			output_arr['abil'] = abil1 or abil2 or abil3 or ''
			
			output_arr['user'] = the_check(output_arr['user'])
			output_arr['targ'] = the_check(output_arr['targ'])
			
			local col = string.char(0x1F,redcol)
			if colorful then
				if redcol == 28 or redcol == 29 or redcol == 32 or redcol == 33 then
					output_arr['targ'] = name_col('',output_arr['targ'],col)
					if output_arr['user'] ~= '' then
						output_arr['user'] = color_arr['mob']..output_arr['user']..col
					end
					if output_arr['damg'] ~= '' then
						output_arr['damg'] = color_arr['mobdmg']..output_arr['damg']..col
					end
				else
					output_arr['targ'] = color_arr['mob']..output_arr['targ']..col
					if output_arr['user'] ~= '' then
						output_arr['user'] = name_col('',output_arr['user'],col)
					end
					if output_arr['damg'] ~= '' then
						if redcol== 20 then
							output_arr['damg'] = color_arr['mydmg']..output_arr['damg']..col
						end
						if redcol== 25 then
							output_arr['damg'] = color_arr['partydmg']..output_arr['damg']..col
						end
						if redcol== 40 then
							output_arr['damg'] = color_arr['otherdmg']..output_arr['damg']..col
						end
						if redcol== 163 then
							output_arr['damg'] = color_arr['allydmg']..output_arr['damg']..col
						end
					end
				end
			end
			if misses~=nil then
				if output_arr['abil'] ~= '' then
					output_arr['abil'] = output_arr['abil']..' Miss'
				else
					output_arr['abil'] = 'Miss'
				end
			elseif crit~=nil then
				output_arr['abil'] = 'Critical'
			end
			
			if ranged~=nil then
				output_arr['abil'] = output_arr['abil']..' RA'
			elseif counter~= nil then
				output_arr['abil']='Counter'
			elseif parry~= nil then
				output_arr['abil']='Parry'
			elseif dodge~= nil then
				output_arr['abil']='Dodge'
			elseif spikes~= nil then
				output_arr['abil']='Spikes'
			elseif addeffect~= nil then
				output_arr['abil']='Add\46 Eff\46'
			elseif output_arr['abil']=='' then
				if output_arr['user'] == '' then
					output_arr['abil']=output_arr['abil']..'AoE'
				else
					output_arr['abil']=output_arr['abil']..'Hit'
				end
			end
			
			if addeffect2 ~= nil then
				output_arr['targ']=output_arr['targ']..' \40'..effect..'\41'
			end
			
			if takes~=nil or hits~=nil or spikes ~= nil or addeffect ~=nil or misses ~= nil or parry ~= nil or dodge~=nil then
				if output_arr['user']=='' then
					modified=line_nouser:gsub('$\123(%w+)\125',bounce)
				elseif output_arr['damg'] == '' then
					modified=line_nodmg:gsub('$\123(%w+)\125',bounce)
				else
					modified=line_full:gsub('$\123(%w+)\125',bounce)
				end
			end
			
			output_arr = {}
		end
	end
	return modified,color
end

function bounce(word)
	if output_arr[word]~=nil then
		return output_arr[word]
	else
		return '$'..word
	end
end

function the_check(str)
	local outstr
	local a,b = string.find(str:lower(),'the ')
	if a==1 then
		outstr = str:sub(b+1,str:len())
	else
		outstr = str
	end
	return outstr
end

function send_it_out(n,modus)
	local output = stat_array[n][1]..'\7'
	stat_array[n] = eliminate_duplicates(stat_array[n])
	if targetnumber then
		if #stat_array[n] > 3 then
			output = output.."\91"..(#stat_array[n]-2).."\93 "
		end
	end
	
	if colorful then
		party = get_party()
	end
	local col = string.char(0x1F,stat_array[n][2]%256)
	local colnm = stat_array[n][2]
	output = name_col(output,stat_array[n][3],col)
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
			output = name_col(output,v,col)
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

function name_col(basestr,name,basecol)
	local party = get_party()
	local modbase = ''
	for r,s in pairs(party) do
		if s['name'] == name and colorful then
			modbase = basestr..color_arr[r]..name..basecol
		end
	end
	if modbase == '' then
		modbase = basestr..name
	end
	return modbase
end

function split(msg, match)
	local length = msg:len()
	local splitarr = {}
	local u = 1
	while u <= length do
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
			u = length+1
		end
	end
	return splitarr
end

function eliminate_duplicates(tab)
	for i,v in pairs(tab) do
		for n,q in pairs(tab) do
			if tab[i] == tab[n] and i ~= n then
				table.remove(tab,n)
			end
		end
	end
	return tab
end

function event_unload()
	send_command('unalias aoe')
end