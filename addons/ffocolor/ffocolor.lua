--[[
ffocolor v1.0
Copyright (c) 2012, Ricky Gall All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    Neither the name of the organization nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]
function event_load()
	startAddon()
end

function event_login()
	startAddon()
end

function event_logout()
	dosettings('save')
end

function event_unload()
	dosettings('save')
	add_to_chat(55,"FFOColor unloading and saving settings.")
	send_command('unalias ffocolor')
end

function event_addon_command(...)
    local args = table.concat({...}, ' ')
	local broken = split(args,' ')
	if broken[1] ~= nil then
		comm = broken[1]
		if comm:lower() == 'help' then
			add_to_chat(55,'FFOcolor loaded! You have access to the following commands:')
			add_to_chat(55,' 1. ffocolor hlcolor <color#> --Changes the highlight color')
			add_to_chat(55,' 2. ffocolor chattab <say/shout/linkshell/party/tell> --Changes the chattab')
			add_to_chat(55,' 3. ffocolor highlight <line/name> --Changes the line or your name color when you are talked about in ffochat')
			add_to_chat(55,' 4. ffocolor talkedc <color#> --Sets the color of the highlight for when you are talked about')
			add_to_chat(55,' 5. ffocolor watchname <name> -- Track another name')
			add_to_chat(55,' 6. ffocolor getcolors -- Show a list of color codes. Be aware this is 255 lines of text')
			add_to_chat(55,' 7. ffocolor unload --Save settings and close ffocolor.')
			add_to_chat(55,' 8. ffocolor help --Shows this menu.')
		elseif comm:lower() == 'talkedc' then
			settings['talkedc'] = broken[2]
		elseif comm:lower() == 'chattab' then
			settings['chatTab'] = broken[2]
		elseif comm:lower() == 'hlcolor' then
			settings['hlcolor'] = broken[2]
		elseif comm:lower() == 'highlight' then
			settings['highlight'] = broken[2]
		elseif comm:lower() == 'watchname' then
			names[#names+1] = broken[2]
			settings['namestowatch'] = settings['namestowatch']..','..broken[2]
		elseif comm:lower() == 'getcolors' then
			getcolors()
		elseif comm:lower() == 'unload' then
			send_command('lua u ffocolor')
		else
			return
		end
	end
end

function event_incoming_text(old,new,color)
	if old ~= former then
		tcol = string.char(31,settings['talkedc'])
		hcol = string.char(31,settings['hlcolor'])
		ccol = string.char(31,color)
		local a,b,txt = string.find(old,'%[%d+:#%w+%](.*):')
		write(txt or 'txt failed')
		if b~= nil then
			for i = 1, #chatTabs do
				if settings['chatTab']:lower() == chatTabs[i]:lower() then
					color = tabColor[i]
				end
			end
			fulltext = split(old,' ')
			new = ''
			for z = 1, #names do
				nametest = string.find(old:lower(),'('..names[z]:lower()..')')
				if nametest ~= nil then break end
			end
			for y = 1, #names do
				playertest = string.find(txt:lower(),'('..names[y]:lower()..')')
				if playertest ~= nil then break end
			end
			write(playertest or 'player test failed')
			write(nametest or 'name test failed')
			if nametest ~= nil then
				if playertest ~= nil then
					for u = 1, #fulltext do
						if u > 1 then
							new = new..' '
						end
						new = new..hcol..fulltext[u]
					end
				else
					if settings['highlight'] == 'name' then
						for u = 1, #fulltext do
							for x = 1, #names do
								wordtest = string.find(fulltext[u]:lower(),'('..names[x]:lower()..')')
								if wordtest ~= nil then break end
							end
							if u > 1 then
								new = new..' '
							end
							if wordtest == nil then
								new = new..hcol..fulltext[u]
							else
								new = new..tcol..fulltext[u]
							end
						end
					else
						for u = 1, #fulltext do
							if u > 1 then
								new = new..' '
							end
							new = new..tcol..fulltext[u]
						end
					end
				end
			else
				for u = 1, #fulltext do
					if u > 1 then
						new = new..' '
					end
					new = new..hcol..fulltext[u]
				end
			end
		end
	end
	return new,color
end

function dosettings(arg1)
	if arg1 == 'get' then
		for line in io.lines(settingsFile) do
			local g,h,key,value = string.find(line,'<(%w+)>([%w%d%p]+)</%1>')
			if value ~= nil then
				settings[key] = value
				write(key..'='..value)
			end
		end
		names = split(settings['namestowatch'],',')
	else
		local f = io.open(settingsPath..'tmp.txt',"w")
		f:write("<?xml version=\"1.0\"?>\n")
		f:write("<!--File Created by FFOColor.lua v1.0-->\n\n")
		f:write("\tThe numbers you get from that script are what you put in the color tags below\n-->")
		f:write("\t<settings>\n")
		f:write("\t\t<chatTab>"..settings['chatTab'].."</chatTab> --Chat tab for ffochat to show up in\n")
		f:write("\t\t<hlcolor>"..settings['hlcolor'].."</hlcolor> --Color to recolor ffochat text\n")
		f:write("\t\t<talkedc>"..settings['talkedc'].."</talkedc> --Color to highlight when you are talked about\n")
		f:write("\t\t<highlight>"..settings['highlight'].."</highlight> --Which to highlight when you are talked about\n")
		f:write("\t\t<namestowatch>"..settings['namestowatch'].."</namestowatch> -- Which names would you light using above method\n")
		f:write("\t</settings>")
		io.close(f)
		local r,es = os.rename(settingsFile,settingsPath..'tmp2.txt')
		if not r then write(es) end
		local e,rs = os.rename(settingsPath..'tmp.txt',settingsFile)
		if not e then write(rs) end
		local r,es = os.remove(settingsPath..'tmp2.txt')
		if not r then write(es) end
	end
end

function startAddon()
	player = get_player()
	settingsPath = lua_base_path..'data/'
	settingsFile = settingsPath..'settings-'..player['name']..'.xml'
	chatTabs = {'Say','Tell','Party','Linkshell','Shout'}
	tabColor = {'1','4','5','6','2'}
	settings = {}
	last = ''
	firstrun = 0
	former = ''
	if not file_exists(settingsFile) then
		firstrun = 1
		local f = io.open(settingsFile,"w")
		f:write("<?xml version=\"1.0\"?>\n")
		f:write("<!--File Created by FFOColor.lua v1.0-->\n\n")
		f:write("\t<settings>\n")
		f:write("\t\t<chatTab>Say</chatTab> --Chat tab for ffochat to show up in\n")
		f:write("\t\t<hlcolor>04</hlcolor> --Color to recolor ffochat text\n")
		f:write("\t\t<talkedc>167</talkedc> --Color to highlight when you are talked about\n")
		f:write("\t\t<highlight>line</highlight> --Which to highlight when you are talked about\n")
		f:write("\t\t<namestowatch>"..player['name'].."</namestowatch> -- Which names would you light using above method\n")
		f:write("\t</settings>")
		io.close(f)
	end
	send_command('alias ffocolor lua c ffocolor')
	dosettings('get')
	if firstrun == 1 then
		send_command('ffocolor help')
		add_to_chat(55,'FFOColor settings file created')
	end	
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

function getcolors()
	colors = {}
	colors[1] = 'Menu > Font Colors > Chat > Immediate vicinity ("Say")'
	colors[2] = 'Menu > Font Colors > Chat > Wide area ("Shout")'
	colors[4] = 'Menu > Font Colors > Chat > Tell target only ("Tell")'
	colors[5] = 'Menu > Font Colors > Chat > All party members ("Party")'
	colors[6] = 'Menu > Font Colors > Chat > Linkshell group ("Linkshell")'
	colors[7] = 'Menu > Font Colors > Chat > Emotes'
	colors[17] = 'Menu > Font Colors > Chat > Messages ("Message")'
	colors[142] = 'Menu > Font Colors > Chat > NPC Conversations'
	colors[20] = 'Menu > Font Colors > For Others > HP/MP others loose'
	colors[21] = 'Menu > Font Colors > For Others > Actions others evade'
	colors[22] = 'Menu > Font Colors > For Others > HP/MP others recover'
	colors[60] = 'Menu > Font Colors > For Others > Beneficial effects others are granted'
	colors[61] = 'Menu > Font Colors > For Others > Detrimental effects others receive'
	colors[63] = 'Menu > Font Colors > For Others > Effects others resist'
	colors[28] = 'Menu > Font Colors > For Self > HP/MP you loose'
	colors[29] = 'Menu > Font Colors > For Self > Actions you evade'
	colors[30] = 'Menu > Font Colors > For Self > HP/MP you recover'
	colors[56] = 'Menu > Font Colors > For Self > Beneficial effects you are granted'
	colors[57] = 'Menu > Font Colors > For Self > Detrimental effects you receive'
	colors[59] = 'Menu > Font Colors > For Self > Effects you resist'
	colors[8] = 'Menu > Font Colors > System > Calls for help'
	colors[50] = 'Menu > Font Colors > System > Standard battle messages'
	colors[121] = 'Menu > Font Colors > System > Basic system messages'

	for v = 0, 255, 1 do
		if(colors[v] ~= nil) then
			add_to_chat(v, "Color "..v.." - "..colors[v])
		else
			add_to_chat(v, "Color "..v.." - This is some random text to display the color.")
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