--[[
ohShi v1.25
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
	mobFile = settingsPath..'mobList.xml'
	if not file_exists(settingsFile) then
		firstrun = 1
		createDefaults('settings')
	end
	if not file_exists(mobFile) then
		createDefaults('mobList')
	end
	send_command('alias ohShi lua c ohShi')
	if firstrun == 1 then send_command('ohShi help') end
	send_command('wait 3;ohShi create')
end

function event_unload()
	ohShi_delete()
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
			add_to_chat(55,' ohShi loaded! You have access to the following commands:')
			add_to_chat(55,' 1. ohShi bgcolor <alpha> <red> <green> <blue> --Sets the color of the box.')
			add_to_chat(55,' 2. ohShi text <red> <green> <blue> --Sets text color.')
			add_to_chat(55,' 2. ohShi font <size> <name> --Sets text font and size.')
			add_to_chat(55,' 3. ohShi pos <posx> <posy> --Sets position of box.')
			add_to_chat(55,' 4. ohShi duration <seconds> --Sets the timeout on the notices.')
			add_to_chat(55,' 5. ohShi track <vw/legion/other/abyssea/meebles> <mobname> --Adds mob to the tracking list.')
			add_to_chat(55,' 6. ohShi danger <spell/ws> <dangerword> --Adds danger word to list.')
			add_to_chat(55,' 7. ohShi unload --Save settings and close ohShi.')
			add_to_chat(55,' 8. ohShi reset --Resets the box back to empty.')
			add_to_chat(55,' 9. ohShi help --Shows this menu.')
		elseif comm:lower() == 'create' then
			ohShi_create()
		elseif comm:lower() == 'unload' then
			send_command('lua u ohShi')
		elseif comm:lower() == 'bgcolor' then
			tb_set_bg_color('ohShi',args[2],args[3],args[4],args[5])
			settings['bgalpha'] = args[2]
			settings['bgred'] = args[3]
			settings['bggreen'] = args[4]
			settings['bgblue'] = args[5]
		elseif comm:lower() == 'pos' then
			tb_set_location('ohShi',args[2],args[3])
			settings['posx'] = args[2]
			settings['posy'] = args[3]
		elseif comm:lower() == 'text' then
			tb_set_color('ohShi',255,args[2],args[3],args[4])
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
			tb_set_font('ohShi',font,args[2])
		elseif comm:lower() == 'duration' then
			settings['duration'] = args[2]
		elseif comm:lower() == 'track' then
			if args[2] == 'vw' then
				tm = 'voidwatch'
			elseif args[2] == 'legion' then
				tm = 'legion'
			elseif args[2] == 'other' then
				tm = 'other'
			elseif args[2] == 'meebles' then
				tm = 'meebles'
			elseif args[2] == 'abyssea' then
				tm = 'abyssea'
			end
			if tm ~= nil then
				local q
				for q = 3, #args do
					list = list..args[q]
					if q < #args then list = list..' ' end
				end
				settings[tm] = settings[tm]..','..list
			else
				add_to_chat(55,'Proper Syntax: //ohShi track <vw/legion/other/abyssea/meebles> <mobname>')
			end
		elseif comm:lower() == 'danger' then
			if args[2] == 'spells' then
				td = 'spells'
			elseif args[2] == 'ws' then
				td = 'weaponskills'
			end
			if td ~= nil then
				local r
				for r = 2, #args do
					list = list..args[r]
					if r < #args then list = list..' ' end
				end
				settings[td] = settings[td]..','..list
			else
				add_to_chat(55,'Proper Syntax: //ohShi danger <spell/ws> <dangerword>')
			end
		elseif comm:lower() == 'duration' then
			settings['duration'] = args[2]
		elseif comm:lower() == 'warnoff' then
			table.remove(prims,1)
			prim_delete(args[2])
		elseif comm:lower() == 'timeout' then
			table.remove(tracking,1)
			currline = #tracking
			ohShi_refresh()
		elseif comm:lower() == 'reset' then
			tb_delete('ohShi')
			ohShi_create()
		else
			return
		end
	end
end

function ohShi_create()
	for line in io.lines(settingsFile) do
		local g,h,key,value = string.find(line,'<(%w+)>(.*)</%1>')
		if value ~= nil then
			settings[key] = value
		end
	end
	for line2 in io.lines(mobFile) do
		local g,h,key,value = string.find(line2,'<(%w+)>(.*)</%1>')
		if value ~= nil then
			settings[key] = value
		end
	end
	ohShi_set()
end

function ohShi_set()
	tb_create('ohShi')
	if firstrun == 1 then 
		tb_set_text('ohShi','ohShi')
	end
	if settings ~= nil then
		tb_set_bg_color('ohShi',settings['bgalpha'],settings['bgred'],settings['bggreen'],settings['bgblue'])
		tb_set_bg_visibility('ohShi',true)
		tb_set_color('ohShi',255,settings['textred'],settings['textgreen'],settings['textblue'])
		tb_set_font('ohShi',settings['textfont'],settings['textsize'])
		tb_set_location('ohShi',settings['posx'],settings['posy'])
		tb_set_visibility('ohShi',true)
	end
end

function ohShi_refresh()
	text = ''
	for u = 1, #tracking do
		text = text..tracking[u]
		if u < #tracking then
			text = text..'\n'
		end
	end
	tb_set_text('ohShi',text)
end

function ohShi_delete()
	add_to_chat(55,'ohShi closing and saving settings')
	save_settings()
	save_moblist()
	local h
	for h = 1, #prims do
		prim_delete(prims[h])
	end
	tb_delete('ohShi')
	send_command('unalias ohShi')
end

function mobcheck(name)
	vw = split(settings['voidwatch'], ',') 
	lg = split(settings['legion'], ',') 
	ot = split(settings['other'], ',') 
	mb = split(settings['meebles'], ',') 
	ab = split(settings['abyssea'], ',')
	for inc = 1, #vw do
		local a = string.find(name:lower(),vw[inc]:lower())
		if a ~= nil then
			return true
		end
	end
	for inc = 1, #lg do
		local b = string.find(name:lower(),lg[inc]:lower())
		if b ~= nil then
			return true
		end
	end
	for inc = 1, #ot do
		local c = string.find(name:lower(),ot[inc]:lower())
		if c ~= nil then
			return true
		end
	end
	for inc = 1, #ab do
		local c = string.find(name:lower(),ab[inc]:lower())
		if c ~= nil then
			return true
		end
	end
	for inc = 1, #mb do
		local c = string.find(name:lower(),mb[inc]:lower())
		if c ~= nil then
			return true
		end
	end
	return false
end

function dangercheck(str)
	spells = split(settings['spells'], ',')
	ws = split(settings['weaponskills'], ',')
	for inc = 1, #spells do
		local a = string.find(str:lower(),spells[inc]:lower())
		if a ~= nil then
			return true
		end
	end
	for inc = 1, #ws do
		local b = string.find(str:lower(),ws[inc]:lower())
		if b ~= nil then
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
		ohShi_refresh()
		send_command('wait '..settings['duration']..';ohShi timeout')
		if fi then flashimage() end
	end
	return new,color
end

function flashimage()
	name = 'ohShi'..tostring(math.random(10000000,99999999))
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
	send_command('wait '..settings['duration']..';ohShi warnoff '..name)
end

function createDefaults(str)
	if str == 'settings' then
		local f = io.open(settingsFile,"w")
		f:write("<?xml version=\"1.0\"?>\n")
		f:write("<!--File Created by ohShi.lua-->\n\n")
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
		f:write("\t</settings>")
		io.close(f)
	elseif str == 'mobList' then
		local f2 = io.open(mobFile,'w')
		f2:write("<?xml version=\"1.0\"?>\n")
		f2:write("<!--File Created by ohShi.lua-->\n\n")
		f2:write("\t<mobList>\n")
		f2:write("\t\t<voidwatch>Qilin,Celaeno,Morta,Bismarck,Ig-Alima,Kalasutrax,Ocythoe,Gaunab,Hahava,Cherufe,Botulus Rex,Taweret,Agathos,Goji,Gugalanna,Gasha,Giltine,Mellonia,Kaggen,Akvan,Pil,Belphoebe,Kholomodumo,Aello,Uptala,Sarbaz,Shah,Wazir,Asb,Rukh,Provenance Watcher</voidwatch>\n")
		f2:write("\t\t<legion>Veiled,Lofty,Soaring,Mired,Paramount</legion>\n")
		f2:write("\t\t<other>Tiamat,Khimaira,Khrysokhimaira,Cerberus,Dvergr,Bloodthirsty,Hydra,Enraged,Odin</other>\n")
		f2:write("\t\t<meebles>Goldwing,Silagilith,Surtr,Dreyruk,Samursk,Umagrhk,Izyx,Grannus,Svaha,Melisseus</meebles>\n")
		f2:write("\t\t<abyssea>Alfard,Orthrus,Apademak,Carabosse,Glavoid,Isgebind</abyssea>\n")
		f2:write("\t</mobList>\n")
		f2:write("\t<dangerwords>\n")
		f2:write("\t\t<spells>Death,Meteor,Kaustra,Breakga,Thundaga IV,Thundaja,Firaga IV,Firaja,Aeroga IV,Aeroja,Blizzaga IV,Blizzaja,Stonega IV,Stoneja</spells>\n")
		f2:write("\t\t<weaponskills>Zantetsuken,Geirrothr,Astral Flow,Chainspell,Beastruction,Mandible Massacre,Oblivion's Mantle,Divesting Gale,Frog,Danse,Raksha Stance,Yama's,Ballistic Kick,Eradicator,Arm Cannon,Gorge,Extreme Purgitation,Slimy Proposal,Rancid Reflux,Provenance Watcher starts,Pawn's Penumbra,Gates,Fulmination,Nerve,Thundris</weaponskills>\n")
		f2:write("\t</dangerwords>\n")
		io.close(f2)
	end
end

function save_settings()
	local f, fname = open_temp_file(settingsPath.."tmpst@@@.txt")
	f:write("<?xml version=\"1.0\"?>\n")
	f:write("<!--File Created by ohShi.lua-->\n\n")
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
	f:write("\t</settings>")
	io.close(f)
	local r,es = os.rename(settingsFile,settingsPath..'tmpst.txt')
	if not r then write(es) end
	local e,rs = os.rename(fname,settingsFile)
	if not e then write(rs) end
	local r,es = os.remove(settingsPath..'tmpst.txt')
	if not r then write(es) end
end

function save_moblist()
	local f, fname = open_temp_file(settingsPath.."tmpml@@@.txt")
	f:write("<?xml version=\"1.0\"?>\n")
	f:write("<!--File Created by ohShi.lua-->\n\n")
	f:write("\t<mobList>\n")
	f:write("\t\t<voidwatch>"..settings['voidwatch'].."</voidwatch>\n")
	f:write("\t\t<legion>"..settings['legion'].."</legion>\n")
	f:write("\t\t<other>"..settings['other'].."</other>\n")
	f:write("\t\t<meebles>"..settings['meebles'].."</meebles>\n")
	f:write("\t\t<abyssea>"..settings['abyssea'].."</abyssea>\n")
	f:write("\t</mobList>\n")
	f:write("\t<dangerwords>\n")
	f:write("\t\t<spells>"..settings['spells'].."</spells>\n")
	f:write("\t\t<weaponskills>"..settings['weaponskills'].."</weaponskills>\n")
	f:write("\t</dangerwords>\n")
	io.close(f)
	local r,es = os.rename(mobFile,settingsPath..'tmpml.txt')
	if not r then write(es) end
	local e,rs = os.rename(fname,mobFile)
	if not e then write(rs) end
	local r,es = os.remove(settingsPath..'tmpml.txt')
	if not r then write(es) end
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