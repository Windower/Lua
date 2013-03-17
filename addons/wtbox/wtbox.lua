function event_load()
	scrolled = 0
	currline = 0
	wtchats = {'WTBox'}
	settings = {}
	player = get_player()
	if not file_exists(lua_base_path.."settings.xml") then
		local f = io.open(lua_base_path.."settings.xml","w")
		f:write("<?xml version=\"1.0\"?>\n")
		f:write("<!--File Created by wtbox.lua-->\n\n")
		f:write("\t<settings>\n")
		f:write("\t\t<posx>300</posx>\n")
		f:write("\t\t<posy>300</posy>\n")
		f:write("\t\t<bgalpha>200</bgalpha>\n")
		f:write("\t\t<bgred>0</bgred>\n")
		f:write("\t\t<bggreen>0</bggreen>\n")
		f:write("\t\t<bgblue>0</bgblue>\n")
		f:write("\t\t<textsize>12</textsize>\n")
		f:write('\t\t<textred>255</textred>\n')
		f:write('\t\t<textgreen>255</textgreen>\n')
		f:write('\t\t<textblue>255</textblue>\n')
		f:write("\t\t<chatlines>5</chatlines>\n")
		f:write("\t</settings>")
		io.close(f)
	end
	send_command('alias wtbox lua c wtbox')
	send_command('wtbox help')
	send_command('wait 3;wtbox create')
end

function event_addon_command(...)
    local args = table.concat({...}, ' ')
	local broken = split(args,' ')
	if broken[1] ~= nil then
		comm = broken[1]
		if comm:lower() == 'help' then
			add_to_chat(55,'WeaknessTrackerBox loaded! You have access to the following commands:')
			add_to_chat(55,' 1. wtbox bgcolor <alpha> <red> <green> <blue> --Sets the color of the box.')
			add_to_chat(55,' 2. wtbox text <size> <red> <green> <blue> --Sets text color and size.')
			add_to_chat(55,' 3. wtbox pos <posx> <posy> --Sets position of box.')
			add_to_chat(55,' 4. wtbox unload --Save settings and close wtbox.')
			add_to_chat(55,' 5. wtbox reset --resets the box back to empty.')
			add_to_chat(55,' 6. wtbox help --Shows this menu.')
		elseif comm:lower() == 'create' then
			wtbox_create()
		elseif comm:lower() == 'unload' then
			wtbox_delete()
		elseif comm:lower() == 'bgcolor' then
			tb_set_bg_color('wtcbox',broken[2],broken[3],broken[4],broken[5])
			settings['bgalpha'] = broken[2]
			settings['bgred'] = broken[3]
			settings['bggreen'] = broken[4]
			settings['bgblue'] = broken[5]
		elseif comm:lower() == 'pos' then
			tb_set_location('wtcbox',broken[2],broken[3])
			settings['posx'] = broken[2]
			settings['posy'] = broken[3]
		elseif comm:lower() == 'text' then
			tb_set_font('wtcbox','Arial',broken[2])
			tb_set_color('wtcbox',255,broken[3],broken[4],broken[5])
			settings['textsize'] = broken[2]
			settings['textred'] = broken[3]
			settings['textgreen'] = broken[4]
			settings['textblue'] = broken[5]
		elseif comm:lower() == 'reset' then
			tb_delete('wtcbox')
			wtbox_create()
		else
			return
		end
	end
end
	
function event_unload()
	add_to_chat(55,'WTBox closing and saving settings')
end

function wtbox_create()
	for line in io.lines(lua_base_path..'settings.xml') do
		local g,h,key,value = string.find(line,'<(%w+)>(%d+)</%1>')
		if value ~= nil then
			settings[key] = value
		end
	end
	tb_create('wtcbox')
	tb_set_text('wtcbox','WTBox')
	if settings ~= nil then
		tb_set_bg_color('wtcbox',settings['bgalpha'],settings['bgred'],settings['bggreen'],settings['bgblue'])
		tb_set_bg_visibility('wtcbox',true)
		tb_set_color('wtcbox',255,settings['textred'],settings['textgreen'],settings['textblue'])
		tb_set_font('wtcbox','Times New Roman',settings['textsize'])
		tb_set_location('wtcbox',settings['posx'],settings['posy'])
		tb_set_visibility('wtcbox',true)
	end
end

function wtbox_refresh()
	text = wtchats[1]..'\n'
	for u = currline - settings['chatlines'], currline do
		text = text..wtchats[currline]
	end
end

function wtbox_delete()
	local f = io.open(lua_base_path..'tmp.txt',"w")
	f:write("<?xml version=\"1.0\"?>\n")
	f:write("<!--File Created by wtbox.lua-->\n\n")
	f:write("\t<settings>\n")
	f:write("\t\t<posx>"..settings['posx'].."</posx>\n")
	f:write("\t\t<posy>"..settings['posy'].."</posy>\n")
	f:write("\t\t<bgalpha>"..settings['bgalpha'].."</bgalpha>\n")
	f:write("\t\t<bgred>"..settings['bgred'].."</bgred>\n")
	f:write("\t\t<bggreen>"..settings['bggreen'].."</bggreen>\n")
	f:write("\t\t<bgblue>"..settings['bgblue'].."</bgblue>\n")
	f:write("\t\t<textsize>"..settings['textsize'].."</textsize>\n")
	f:write("\t\t<textred>"..settings['textred'].."</textred>\n")
	f:write("\t\t<textgreen>"..settings['textgreen'].."</textgreen>\n")
	f:write("\t\t<textblue>"..settings['textblue'].."</textblue>\n")
	f:write("\t\t<chatlines>"..settings['chatlines'].."</chatlines>\n")
	f:write("\t</settings>")
	io.close(f)
	local r,es = os.rename(lua_base_path..'settings.xml',lua_base_path..'tmp2.txt')
	if not r then write(es) end
	local e,rs = os.rename(lua_base_path..'tmp.txt',lua_base_path..'settings.xml')
	if not e then write(rs) end
	local r,es = os.remove(lua_base_path..'tmp2.txt')
	if not r then write(es) end
	tb_delete('wtcbox')
	send_command('lua u wtbox')
end

function event_incoming_text(old,new,color)
	local c,d,he,stuff = string.find(old,'The fiend appears(.*)vulnerable to ([%w%s]+)!')
	if c ~= nil then
		if he == ' highly ' then
			wtchats[#wtchats+1] = "\\cs(255,100,100)"..stuff.." 3!!!\\cr\n"
		elseif he == ' extremely ' then
			wtchats[#wtchats+1] = "\\cs(255,255,255)"..stuff.." 5!!!!!\\cr\n"
		else
			wtchats[#wtchats+1] = "\\cs(100,175,255)"..stuff.."1!\\cr\n"
		end
		if #wtchats < 7 then
			i = 2
		else
			i = #wtchats - settings['chatlines']
		end
		text = wtchats[1]..'\n'
		for u = i, #wtchats do
				text = text..wtchats[u] 
		end
		currline = #wtchats
		tb_set_text('wtcbox', text)
		wtbox_refresh()
	end
	return new,color
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