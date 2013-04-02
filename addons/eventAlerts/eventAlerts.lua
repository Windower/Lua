--[[
EventAlerts v1.2
Copyright (c) 2013, Ricky Gall All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    Neither the name of the organization nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]
function event_load()
	scrolled = 0
	currline = 0
	firstrun = 0
	tracking = {}
	settings = {}
	mobs = {}
	prims = {}
	player = get_player()
	settingsPath = lua_base_path..'data/'
	settingsFile = settingsPath..'settings-'..player['name']..'.xml'
	if not file_exists(settingsFile) then
		firstrun = 1
		local f = io.open(settingsFile,"w")
		f:write("<?xml version=\"1.0\"?>\n")
		f:write("<!--File Created by eventAlerts.lua-->\n\n")
		f:write("\t<settings>\n")
		f:write("\t\t<posx>300</posx>\n")
		f:write("\t\t<posy>300</posy>\n")
		f:write("\t\t<bgalpha>200</bgalpha>\n")
		f:write("\t\t<bgred>0</bgred>\n")
		f:write("\t\t<bggreen>0</bggreen>\n")
		f:write("\t\t<bgblue>0</bgblue>\n")
		f:write("\t\t<textfont>Arial</textfont>\n")
		f:write("\t\t<textsize>12</textsize>\n")
		f:write('\t\t<textred>255</textred>\n')
		f:write('\t\t<textgreen>255</textgreen>\n')
		f:write('\t\t<textblue>255</textblue>\n')
		f:write("\t\t<chatlines>5</chatlines>\n")
		f:write("\t\t<duration>7</duration>\n")
		f:write("\t\t<mobs>Qilin,Lofty,Celaeno</mobs>\n")
		f:write("\t\t<dangerwords>Deadly Hold,Thundaga IV</dangerwords>\n")
		f:write("\t</settings>")
		io.close(f)
	end
	send_command('alias eAlert lua c eventAlerts')
	if firstrun == 1 then send_command('eAlert help') end
	send_command('wait 3;eAlert create')
end

function event_unload()
	eAlert_delete()
end

function event_login()
	player = get_player()
end

function event_addon_command(...)
    local args = {...}
	if args[1] ~= nil then
		comm = args[1]
		list = ''
		if comm:lower() == 'help' then
			add_to_chat(55,' EventAlerts loaded! You have access to the following commands:')
			add_to_chat(55,' 1. eAlert bgcolor <alpha> <red> <green> <blue> --Sets the color of the box.')
			add_to_chat(55,' 2. eAlert text <red> <green> <blue> --Sets text color.')
			add_to_chat(55,' 2. eAlert font <size> <name> --Sets text font and size.')
			add_to_chat(55,' 3. eAlert pos <posx> <posy> --Sets position of box.')
			add_to_chat(55,' 4. eAlert duration <seconds> --Sets the timeout on the notices.')
			add_to_chat(55,' 5. eAlert track <mobname> --Adds mob to the tracking list.')
			add_to_chat(55,' 6. eAlert danger <dangerword> --Adds danger word to list.')
			add_to_chat(55,' 7. eAlert unload --Save settings and close EventAlerts.')
			add_to_chat(55,' 8. eAlert reset --resets the box back to empty.')
			add_to_chat(55,' 9. eAlert help --Shows this menu.')
		elseif comm:lower() == 'create' then
			eAlert_create()
		elseif comm:lower() == 'unload' then
			send_command('lua u eAlert')
		elseif comm:lower() == 'bgcolor' then
			tb_set_bg_color('eAlert',args[2],args[3],args[4],args[5])
			settings['bgalpha'] = args[2]
			settings['bgred'] = args[3]
			settings['bggreen'] = args[4]
			settings['bgblue'] = args[5]
		elseif comm:lower() == 'pos' then
			tb_set_location('eAlert',args[2],args[3])
			settings['posx'] = args[2]
			settings['posy'] = args[3]
		elseif comm:lower() == 'text' then
			tb_set_color('eAlert',255,args[2],args[3],args[4])
			settings['textred'] = args[2]
			settings['textgreen'] = args[3]
			settings['textblue'] = args[4]
		elseif comm:lower() == 'font' then
			font = ''
			local p
			for p = 3, #args do
				font = font..args[p]
				if p < #args then font = font..' ' end
			end
			settings['textfont'] = font
			settings['textsize'] = args[2]
			tb_set_font('eAlert',font,args[2])
		elseif comm:lower() == 'duration' then
			settings['duration'] = args[2]
		elseif comm:lower() == 'track' then
			local q
			for q = 2, #args do
				list = list..args[q]
				if q < #args then list = list..' ' end
			end
			settings['mobs'] = settings['mobs']..','..list
		elseif comm:lower() == 'danger' then
			local r
			for r = 2, #args do
				list = list..args[r]
				if r< #args then list = list..' ' end
			end
			settings['dangerwords'] = settings['dangerwords']..','..list
		elseif comm:lower() == 'duration' then
			settings['duration'] = args[2]
		elseif comm:lower() == 'warnoff' then
			table.remove(prims,1)
			prim_delete(args[2])
		elseif comm:lower() == 'timeout' then
			table.remove(tracking,1)
			currline = #tracking
			eAlert_refresh()
		elseif comm:lower() == 'reset' then
			tb_delete('eAlert')
			eAlert_create()
		else
			return
		end
	end
end

function eAlert_create()
	for line in io.lines(settingsFile) do
		local g,h,key,value = string.find(line,'<(%w+)>(.*)</%1>')
		if value ~= nil then
			settings[key] = value
		end
	end
	eAlert_set()
end

function eAlert_set()
	tb_create('eAlert')
	if firstrun == 1 then 
		tb_set_text('eAlert','eAlert')
	end
	if settings ~= nil then
		tb_set_bg_color('eAlert',settings['bgalpha'],settings['bgred'],settings['bggreen'],settings['bgblue'])
		tb_set_bg_visibility('eAlert',true)
		tb_set_color('eAlert',255,settings['textred'],settings['textgreen'],settings['textblue'])
		tb_set_font('eAlert',settings['textfont'],settings['textsize'])
		tb_set_location('eAlert',settings['posx'],settings['posy'])
		tb_set_visibility('eAlert',true)
	end
end

function eAlert_refresh()
	text = ''
	for u = 1, #tracking do
		text = text..tracking[u]
		if u < #tracking then
			text = text..'\n'
		end
	end
	tb_set_text('eAlert',text)
end

function eAlert_delete()
	add_to_chat(55,'EventAlerts closing and saving settings')
	local f, fname = open_temp_file(settingsPath.."tmp@@@.txt")
	f:write("<?xml version=\"1.0\"?>\n")
	f:write("<!--File Created by eventAlerts.lua-->\n\n")
	f:write("\t<settings>\n")
	f:write("\t\t<posx>"..settings['posx'].."</posx>\n")
	f:write("\t\t<posy>"..settings['posy'].."</posy>\n")
	f:write("\t\t<bgalpha>"..settings['bgalpha'].."</bgalpha>\n")
	f:write("\t\t<bgred>"..settings['bgred'].."</bgred>\n")
	f:write("\t\t<bggreen>"..settings['bggreen'].."</bggreen>\n")
	f:write("\t\t<bgblue>"..settings['bgblue'].."</bgblue>\n")
	f:write("\t\t<textfont>"..settings['textfont'].."</textfont>\n")
	f:write("\t\t<textsize>"..settings['textsize'].."</textsize>\n")
	f:write("\t\t<textred>"..settings['textred'].."</textred>\n")
	f:write("\t\t<textgreen>"..settings['textgreen'].."</textgreen>\n")
	f:write("\t\t<textblue>"..settings['textblue'].."</textblue>\n")
	f:write("\t\t<chatlines>"..settings['chatlines'].."</chatlines>\n")
	f:write("\t\t<duration>"..settings['duration'].."</duration>\n")
	f:write("\t\t<mobs>"..settings['mobs'].."</mobs>\n")
	f:write("\t\t<dangerwords>"..settings['dangerwords'].."</dangerwords>\n")
	f:write("\t</settings>")
	io.close(f)
	local r,es = os.rename(settingsFile,settingsPath..'tmp2.txt')
	if not r then write(es) end
	local e,rs = os.rename(fname,settingsFile)
	if not e then write(rs) end
	local r,es = os.remove(settingsPath..'tmp2.txt')
	if not r then write(es) end
	local h
	for h = 1, #prims do
		prim_delete(prims[h])
	end
	tb_delete('eAlert')
	send_command('unalias eAlert')
end

function mobcheck(name)
	mobs = split(settings['mobs'], ',')
	for inc = 1, #mobs do
		local a = string.find(name:lower(),mobs[inc]:lower())
		if a ~= nil then
			return true
		end
	end
	return false
end

function dangercheck(str)
	danger = split(settings['dangerwords'], ',')
	for inc = 1, #danger do
		local a = string.find(str:lower(),danger[inc]:lower())
		if a ~= nil then
			return true
		end
	end
	return false
end

function event_incoming_text(old,new,color)
	local start1,end1,mobname1,tpmove = string.find(old,'([%w%s]+) readies ([%w%s]+)%p')
	local start2,end2,mobname2,spell = string.find(old,'([%w%s]+) starts casting ([%w%s]+)%p')
	local start3,end3,mobname3,debuff1 = string.find(old,'([%w%s]+) is no longer (%w+)%p')
	local start4,end4,mobname4,gr,debuff2 = string.find(old,'([%w%s]+) (%w+) the effect of ([%w%s]+)')
	local start5,end5,mobname5,buff1 = string.find(old,'([%w%s]+)\'s (%w+) effect wears off%p')
	local start6,end6,player1 = string.find(old,'(%w+)\'s attack devastates the fiend%p')
	local start7,end7,blue1,red1 = string.find(old,'Blue: (%d+)%% / Red: (%d+)%%')
	local start8,end8,blue2 = string.find(old,'Blue: (%d+)')
	local start9,end9,red2 = string.find(old,'Red: (%d+)')
	local start0,end0,player2,rollname1,total1 = string.find(old,'(%w+) uses ([%w%s\']+)Roll.*comes to ([%d]+)')
	local starta1,enda1,player3,rollname2,total2 = string.find(old,'(%w+) uses Double%-Up..The total for (.*) increases to (%d+)%p')
	local starta2,enda2,mobname9,total3 = string.find(old,'Treasure Hunter effectiveness against (.*) increases to (%d+)%p')
	local starta3,enda3,type1,skill = string.find(old,'The fiend appears(.*)vulnerable to ([%w%s]+)!')
	line = nil
	text = ''
	color2 = ''
	cres = ''
	fi = false
	if mobname1 ~= nil then
		if dangercheck(old) then
			color2 = '\\cs(255,100,100)'
			cres = '\\cr'
			fi = true
		end
		if mobcheck(mobname1) then line = " "..color2..mobname1..' readies '..tpmove..'.'..cres..' ' end
	elseif mobname2 ~= nil then
		if dangercheck(old) then
			color2 = '\\cs(255,100,100)'
			cres = '\\cr'
			fi = true
		end
		if mobcheck(mobname2) then line = " "..color2..mobname2..' starts casting '..spell..'.'..cres..' ' end
	elseif mobname3 ~= nil then
		if mobcheck(mobname3) then line = " "..mobname3..' is no longer '..debuff1..'. ' end
	elseif mobname4 ~= nil then
		if mobcheck(mobname4) then line = " "..mobname4..' '..gr..' the effect of '..debuff2..'. ' end
	elseif mobname5 ~= nil then
		if mobcheck(mobname5) then line = " "..mobname5..'\'s '..buff1..' effect wears off. ' end
	elseif player1 ~= nil then
		line = " "..player1..'\'s attack devastates the fiend. '
	elseif blue2 ~= nil and blue1 == nil then
		line = " "..'Blue: '..blue2..'% '
	elseif red2 ~= nil and blue1 == nil then
		line = " "..'Red: '..red2..'% '
	elseif blue1 ~= nil then
		line = " "..'Blue: '..blue1..'% / Red: '..red1..'% '
	elseif player2 ~= nil then
		line = " "..player2..': '..rollname1..'Roll Total: '..total1..' '
	elseif player3 ~= nil then
		line = " "..player3..': '..rollname2..' Total: '..total2..' '
	elseif mobname9 ~= nil then
		line = ' Treasure Hunter against '..mobname9..': '..total3..' '
	elseif type1 ~= nil then
		if type1 == ' highly ' then
			color2 = '\\cs(255,100,100)'
			cres = '\\cr'
			type2 = ' 3!!!'
		elseif type1 == ' extremely ' then
			color2 = '\\cs(255,255,100)'
			cres = '\\cr'
			type2 = ' 5!!!!!'
		else
			color2 = '\\cs(255,255,255)'
			cres = '\\cr'
			type2 = ' 1!'
		end
		line = " "..color2..skill..type2..cres..' '
	end
	if line ~= nil then
		tracking[#tracking+1] = line
		
		currline = #tracking
		eAlert_refresh()
		send_command('wait '..settings['duration']..';eAlert timeout')
		if fi then flashimage() end
	end
	return new,color
end

function flashimage()
	name = 'eAlert'..tostring(math.random(10000000,99999999))
	prims[#prims+1] = name
	prim_create(name)
	prim_set_color(name,255,255,255,255)
	prim_set_fit_to_texture(name,false)
	prim_set_texture(name,lua_base_path..'data/warning.png')
	--assumes your icons are stored with the name you pass in windower/addons/<youraddon>/data
	prim_set_repeat(name,1,1)
	prim_set_visibility(name,true)
	prim_set_position(name,settings['posx']-30,settings['posy']-10)
	prim_set_size(name,30,30)
	send_command('wait '..settings['duration']..';eAlert warnoff '..name)
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then 
		local q,r = io.close(f)
		if not q then write(r) end
		return true 
	else
		return false 
	end
end

function open_temp_file(template)
	local handle
	local fname
	assert(string.match(template, "@@@"), 
		"ERROR open_temp_file: template must contain \"%%%\".")
	while true do
		fname = string.gsub(template, "@@@", tostring(math.random(10000000,99999999)))
		handle = io.open(fname, "r")
		if not handle then
			handle = io.open(fname, "w")
			break
		end
		io.close(handle)
		io.write(".")   -- Shows collision, comment out except for diagnostics
	end
	return handle, fname
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