--[[
Copyright (c) 2013, 2015, Ikonic
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of ChatPorter nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL IKONIC BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


_addon.name = 'ChatPorter'
_addon.version = '1.39'
_addon.author = 'Ikonic'
_addon.commands = {'ChatPorter','cp'}

require('tables')
require('strings')
require('chat')
config = require('config')
require('logger')

defaults = T{}
defaults.usechatporter = true

defaults.linkshell = T{}
defaults.linkshell.displaychat = true
defaults.linkshell.color = 41 -- 41, 70, 158, 204
defaults.linkshell.show = true
defaults.linkshell.lines = 8
defaults.linkshell.alpha = 255
defaults.linkshell.red = 152
defaults.linkshell.green = 251
defaults.linkshell.blue = 152
defaults.linkshell.fontname = "Arial"
defaults.linkshell.fontsize = 8
defaults.linkshell.x = 150
defaults.linkshell.y = 505

defaults.party = T{}
defaults.party.displaychat = true
defaults.party.color = 207 -- 207
defaults.party.show = true
defaults.party.lines = 8
defaults.party.alpha = 255
defaults.party.red = 0
defaults.party.green = 191
defaults.party.blue = 255
defaults.party.fontname = "Arial"
defaults.party.fontsize = 8
defaults.party.x = 150
defaults.party.y = 390

defaults.tell = T{}
defaults.tell.displaychat = true
defaults.tell.color = 200 -- 208
defaults.tell.show = true
defaults.tell.lines = 8
defaults.tell.alpha = 255
defaults.tell.red = 255
defaults.tell.green = 0
defaults.tell.blue = 255
defaults.tell.fontname = "Arial"
defaults.tell.fontsize = 8
defaults.tell.x = 150
defaults.tell.y = 100

defaults.ffochat = T{}
defaults.ffochat.displaychat = false
defaults.ffochat.color = 167
defaults.ffochat.show = false
defaults.ffochat.lines = 8
defaults.ffochat.alpha = 255
defaults.ffochat.red = 255
defaults.ffochat.green = 0
defaults.ffochat.blue = 0
defaults.ffochat.fontname = "Arial"
defaults.ffochat.fontsize = 4
defaults.ffochat.x = 380
defaults.ffochat.y = 300

settings = config.load(defaults)

showlinkshell = T{}
showparty = T{}
showtell = T{}
showffochat = T{}

specialChar = "|"
lastTellFrom = ""

playerResolution = T{}
playerResolution.x = windower.get_windower_settings().x_res
playerResolution.y = windower.get_windower_settings().y_res

windower.register_event('load',function ()
	windower.text.create("showlinkshell")
	windower.text.create("showparty")
	windower.text.create("showtell")
	windower.text.create("showffochat")
	windower.send_command('alias l2 lua command ChatPorter l2')
	windower.send_command('alias p2 lua command ChatPorter p2')
	windower.send_command('alias t2 lua command ChatPorter t2')
	windower.send_command('alias r2 lua command ChatPorter r2')
	windower.send_command('alias f1 lua command ChatPorter f1')
	windower.send_command('alias f2 lua command ChatPorter f2')
	windower.send_command('alias f3 lua command ChatPorter f3')
	windower.send_command('alias f4 lua command ChatPorter f4')
	windower.send_command('alias f5 lua command ChatPorter f5')
	windower.add_to_chat(160,' Type '..string.color('//cp help',204,160)..' for a list of possible commands.')
end)

windower.register_event('load', 'login', 'linkshell change', function()
	local player = windower.ffxi.get_player()
	if player then
		playerName = player.name
		LSname = player.linkshell
	end
end)

windower.register_event('unload',function ()
	windower.text.delete("showlinkshell")
	windower.text.delete("showparty")
	windower.text.delete("showtell")
	windower.text.delete("showffochat")
	windower.send_command('unalias l2')
	windower.send_command('unalias p2')
	windower.send_command('unalias t2')
	windower.send_command('unalias r2')
	windower.send_command('unalias f1')
	windower.send_command('unalias f2')
	windower.send_command('unalias f3')
	windower.send_command('unalias f4')
	windower.send_command('unalias f5')
end)

windower.register_event('login',function (name)
	settings = config.load(defaults)
	show("linkshell")
	show("party")
	show("tell")
	show("ffochat")
	LSname = windower.ffxi.get_player().linkshell;
	playerName = windower.ffxi.get_player().name;
end)

function addon_command(...)
	local args = {...}
	local dummysettings = table.copy(settings)
	if args[1] ~= nil then
		comm = args[1]:lower()
		if comm == 'help' then
			if args[2] == nil or (args[2] ~= "detail" and args[2] ~= "textbox") then
				windower.add_to_chat(55,_addon.name.." v".._addon.version..' possible commands:')
				windower.add_to_chat(160,' '..string.color('//ChatPorter',204,160)..' and '..string.color('//cp',204,160)..' are both valid commands.')
				windower.add_to_chat(160,' '..string.color('//cp help',204,160)..' : Lists this menu.')
				windower.add_to_chat(160,' '..string.color('//cp status',204,160)..' : Shows current configuration.')
				windower.add_to_chat(160,' '..string.color('//cp textbox',204,160)..' : Shows current textbox configurations.')
				windower.add_to_chat(160,' '..string.color('//cp colors',204,160)..' : Shows possible color codes.')
				windower.add_to_chat(160,' '..string.color('//cp toggle',204,160)..' : Toggles ChatPorter on/off.')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t] [toggle|displaychat]',204,160)..' : Toggles linkshell|party|tell messages from showing or not.')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t] color #',204,160)..' : Sets color of l|p|t text (acceptable values of 1-255).')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] show',204,160)..' : Toggles l|p|t textboxes from showing.')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] [fontname|fn, lines, fontsize|fs, x, y, alpha|a, red|r, green|g, blue|b] #',204,160)..' : Sets l|p|t textbox specifics.')
				windower.add_to_chat(160,' '..string.color('//[l2|p2|t2 name|r2] message',204,160)..' : Sends message from second character to linkshell|party|tell|reply.')
				windower.add_to_chat(160,' '..string.color('//[f#|cp f#] message',204,160)..' : Sends message from second character to ffochat channel.')
				windower.add_to_chat(160,' '..string.color('//cp help detail',204,160)..' : Shows detailed ChatPorter commands.')
				windower.add_to_chat(160,' '..string.color('//cp help textbox',204,160)..' : Shows detailed textbox commands.')
			elseif args[2] == "detail" then
				windower.add_to_chat(55,' ChatPorter detailed commands:')
				windower.add_to_chat(160,' '..string.color('//l2 message',204,160)..' : Sends message from second character to linkshell.')
				windower.add_to_chat(160,' '..string.color('//p2 message',204,160)..' : Sends message from second character to party.')
				windower.add_to_chat(160,' '..string.color('//t2 name message',204,160)..' : Sends message from second character to name in tell.')
				windower.add_to_chat(160,' '..string.color('//r2 message',204,160)..' : Sends reply message from second character.')
				windower.add_to_chat(160,' '..string.color('//f# message',204,160)..' : Sends message from second character to FFOChat channel #. Works for 1-5.')
				windower.add_to_chat(160,' '..string.color('//cp f# message',204,160)..' : Same as f#, but for any #.')
			elseif args[2] == "textbox" then
				windower.add_to_chat(55,'ChatPorter textbox commands:')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] [toggle|displaychat]',204,160)..' : Toggles linkshell|party|tell|ffochat messages from showing or not.')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t] color #',204,160)..' : Sets color of l|p|t text (acceptable values of 1-255).')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] show',204,160)..' : Toggles l|p|t|f textboxes from showing.')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] clear',204,160)..' : Clears l|p|t|f textbox.')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] lines #',204,160)..' : Sets # of lines to show in textbox.')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] [fontname|fn] *',204,160)..' : Sets fontname for textbox.')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] [fontsize|fs] #',204,160)..' : Sets fontsize for textbox.')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] x #',204,160)..' : Sets x coordinate for textbox (acceptable values: 10-'.. playerResolution.x-10 ..').')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] y #',204,160)..' : Sets y coordinate for textbox (acceptable values: 10-'.. playerResolution.y-10 ..').')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] [alpha|a] #',204,160)..' : Sets alpha (transparency) for textbox (acceptable values: 1-255; 0=fully transparent, 255=fully visible).')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] [red|r] #',204,160)..' : Sets red value for RGB color of text in textbox.')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] [green|g] #',204,160)..' : Sets green value for RGB color of text in textbox.')
				windower.add_to_chat(160,' '..string.color('//cp [l|p|t|f] [blue|b] #',204,160)..' : Sets blue value for RGB color of text in textbox.')
			end
		elseif comm == 'status' then
			showStatus()
		elseif comm == 'textbox' then
			showStatus('textbox')
		elseif comm == 'colors' then
			showColors()
		elseif comm == 'toggle' then
			settings.usechatporter = not settings.usechatporter
			showStatus('usechatporter')
		elseif S({'l2','p2','t2','r2'}):contains(comm) or comm:match('^f%d%d?$') then
			com2 = table.remove(args,1)
			com2mess = table.sconcat(args)
			com2mess = string.gsub(com2mess,"\n","\\\92\110")
			if comm == 'l2' then
				windower.send_ipc_message(specialChar.."l2:"..LSname..specialChar..playerName..specialChar..com2mess)
			elseif comm == 'p2' then
				windower.send_ipc_message(specialChar.."p2:"..""..specialChar..playerName..specialChar..com2mess)
			elseif comm == 't2' then
				windower.send_ipc_message(specialChar.."t2:"..playerName..specialChar..playerName..specialChar..com2mess)
			elseif comm == 'r2' then
				windower.send_ipc_message(specialChar.."r2:"..playerName..specialChar..playerName..specialChar..com2mess)
			elseif string.first(comm, 1) == 'f' then
				windower.send_ipc_message(specialChar.."f:"..string.at(comm,2)..specialChar..playerName..specialChar..com2mess)
			end
		elseif comm == "l" or comm == "p" or comm == "t" or comm == "f" then
			com2 = args[2]
			if com2 == nil then
				com2 = "toggle"
			end
			if comm == "l" then
				comm = "linkshell"
			elseif comm == "p" then
				comm = "party"
			elseif comm == "t" then
				comm = "tell"
			elseif comm == "f" then
				comm = "ffochat"
			end
			com3 = args[3]
			com3num = tonumber(args[3])

			if com2 == "toggle" or com2 == "displaychat" then
				settings[comm].displaychat = not settings[comm].displaychat
				showStatus('display'..comm..'chat')
			elseif com2 == "show" then
				settings[comm][com2] = not settings[comm][com2]
				windower.add_to_chat(160," Setting "..comm.." textbox to display: "..string.color(onOffPrint(settings[comm][com2]),204,160))
			elseif com2 == "clear" then
				_G['show'..comm] = {}
			elseif com2 == "fontname" or com2 == "fn" then
				if com3 ~= nil then
					com3 = table.slice(args,3)
					com3 = tostring(table.sconcat(com3))
					settings[comm].fontname = com3
					windower.add_to_chat(160," Setting fontname: "..string.color(com3,204,160))
				else
					settings[comm].fontname = defaults[comm].fontname
					windower.add_to_chat(160," No fontname specified; setting default fontname.")
				end
			elseif com2 == "lines" then
				if com3num > 8 or com3num < 1 then
					settings[comm][com2] = 8
					windower.add_to_chat(160," Invalid setting. Lines must be a value from 1-8. Setting max value.")
				else
					settings[comm][com2] = com3num
					windower.add_to_chat(160," Setting lines for "..comm.." textbox: "..string.color(tostring(com3num),204,160))
				end
			elseif com2 == "fontsize" or com2 == "fs" then
				if com3num ~= nil and com3num >= 4 and com3num <= 144 then
					settings[comm].fontsize = com3num
					windower.add_to_chat(160," Setting fontsize for "..comm.." textbox: "..string.color(tostring(com3num),204,160))
				else
					settings[comm].fontsize = defaults[comm].fontsize
					windower.add_to_chat(160," Invalid fontsize; acceptable values: 4-144. Setting to default.")
				end
			elseif com2 == "x" or com2 == "y" then
				if com3num ~= nil and com3num >= 10 and com3num <= playerResolution[com2] - 10 then
					settings[comm][com2] = com3num
					windower.add_to_chat(160," Setting "..com2.." value for "..comm.." textbox: "..string.color(tostring(com3num),204,160))
				else
					settings[comm][com2] = defaults[comm][com2]
					windower.add_to_chat(160," Invalid "..com2.." value; acceptable values: 10-".. playerResolution[com2]-10 ..". Setting to default.")
				end
			elseif S({'color','alpha','a','red','r','green','g','blue','b'}):contains(com2) then
				if com2 == "a" then
					com2 = "alpha"
				elseif com2 == "r" then
					com2 = "red"
				elseif com2 == "g" then
					com2 = "green"
				elseif com2 == "b" then
					com2 = "blue"
				end
				if (com3num ~= nil) and (com3num >= 1 and com3num <= 255) then
					settings[comm][com2] = com3num
					if com2 == "color" then
						windower.add_to_chat(160," Setting "..com2.." for "..comm..": "..string.color(tostring(com3num),204,160))
					else
						windower.add_to_chat(160," Setting "..com2.." value for "..comm.." textbox: "..string.color(tostring(com3num),204,160))
					end
				else
					settings[comm][com2] = defaults[comm][com2]
					windower.add_to_chat(160," Invalid "..com2.." value; acceptable values: 1-255. Setting default.")
				end
--				showStatus(_G['settings['..comm..']['..com2..']'])
--				_G['show'..tbName]
			end
			if comm == "linkshell" or comm == "party" or comm == "tell" or comm == "ffochat" then
				show(comm)
				if com3 ~= nil and tostring(com3) ~= tostring(dummysettings[comm][com2]) then
--					settings:save('all') -- all characters
					settings:save() -- current character only
					windower.add_to_chat(55,"Saving "..string.color('ChatPorter',204,55).." settings.")
				elseif com2 == "show" or com2 == "toggle" or com2 == "displaychat" then
					settings:save() -- current character only
					windower.add_to_chat(55,"Saving "..string.color('ChatPorter',204,55).." settings.")
				end
			end
		elseif comm:lower() == 'vprint' then
			settings:vprint()
		elseif comm:lower() == 'print' then
			for key, value in pairs(settings) do
				log(key, value)
			end
		elseif comm:lower() == 'dummy' then
			dummysettings:vprint()
		elseif comm:lower() == 'pt' then
			showparty:vprint()
		elseif comm:lower() == 'test' then
			windower.add_to_chat(160, "")
			windower.send_command("input /p party 1")
			coroutine.sleep(1)
			windower.send_command("input /p party 2")
			coroutine.sleep(1)
			windower.send_command("input /p party 3")
			coroutine.sleep(1)
			windower.send_command("input /p party 4")
			coroutine.sleep(1)
			windower.send_command("input /p party 5")
			coroutine.sleep(1)
			windower.send_command("input /p party 6")
			coroutine.sleep(1)
			windower.send_command("input /p party 7")
			coroutine.sleep(1)
			windower.send_command("input /p party 8")
			coroutine.sleep(1)
			windower.send_command("input /t <me> tell 1")
			coroutine.sleep(1)
			windower.send_command("input /t <me> tell 2")
			coroutine.sleep(1)
			windower.send_command("input /t <me> tell 3")
			coroutine.sleep(1)
			windower.send_command("input /t <me> tell 4")
		else
			windower.add_to_chat(160, " Not a valid ".._addon.name.." v".._addon.version.." command. "..string.color('//cp help',204,160).." for a list of valid commands.")
			return
		end
	else
		addon_command('help')
	end
end

windower.register_event('addon command',addon_command)

windower.register_event('linkshell change',function (linkshell)
	LSname = windower.ffxi.get_player().linkshell;
end)

function showStatus(var)
	if (var ~= nul) and var ~= "textbox" then
		if var == "usechatporter" then
			windower.add_to_chat(160," UseChatPorter: " .. string.color(onOffPrint(settings.usechatporter),204,160))
		elseif var == "displaylinkshellchat" then
			windower.add_to_chat(160," DisplayLinkshellChat: " .. string.color(onOffPrint(settings.linkshell.displaychat),204,160))
		elseif var == "displaypartychat" then
			windower.add_to_chat(160," DisplayPartyChat: " .. string.color(onOffPrint(settings.party.displaychat),204,160))
		elseif var == "displaytellchat" then
			windower.add_to_chat(160," DisplayTellChat: " .. string.color(onOffPrint(settings.tell.displaychat),204,160))
		elseif var == "linkshellcolor" then
			windower.add_to_chat(160," LinkshellColor: " .. string.color(tostring(settings.linkshell.color),204,160))
		elseif var == "partycolor" then
			windower.add_to_chat(160," PartyColor: " .. string.color(tostring(settings.party.color),204,160))
		elseif var == "tellcolor" then
			windower.add_to_chat(160," TellColor: " .. string.color(tostring(settings.tell.color),204,160))
		end
	elseif var == "textbox" then
		windower.add_to_chat(55, "ChatPorter textbox settings: "..string.color('linkshell',settings.linkshell.color,160).." | "..string.color('party',settings.party.color,160).." | "..string.color('tell',settings.tell.color,160).." | "..string.color('ffochat',settings.ffochat.color,160))
--		windower.add_to_chat(160, " displaychat: "..string.color(onOffPrint(settings.linkshell.displaychat),settings.linkshell.color,160).." | "..string.color(onOffPrint(settings.party.displaychat),settings.party.color,160).." | "..string.color(onOffPrint(settings.tell.displaychat),settings.tell.color,160).." | "..string.color(onOffPrint(settings.ffochat.displaychat),settings.ffochat.color,160))
--		windower.add_to_chat(160, " color: "..string.color(tostring(settings.linkshell.color),settings.linkshell.color,160).." | "..string.color(tostring(settings.party.color),settings.party.color,160).." | "..string.color(tostring(settings.tell.color),settings.tell.color,160).." | "..string.color(tostring(settings.ffochat.color),settings.ffochat.color,160))
		windower.add_to_chat(160, " show: "..string.color(onOffPrint(settings.linkshell.show),settings.linkshell.color,160).." | "..string.color(onOffPrint(settings.party.show),settings.party.color,160).." | "..string.color(onOffPrint(settings.tell.show),settings.tell.color,160).." | "..string.color(onOffPrint(settings.ffochat.show),settings.ffochat.color,160))
		windower.add_to_chat(160, " lines: "..string.color(tostring(settings.linkshell.lines),settings.linkshell.color,160).." | "..string.color(tostring(settings.party.lines),settings.party.color,160).." | "..string.color(tostring(settings.tell.lines),settings.tell.color,160).." | "..string.color(tostring(settings.ffochat.lines),settings.ffochat.color,160))
		windower.add_to_chat(160, " fontname: "..string.color(settings.linkshell.fontname,settings.linkshell.color,160).." | "..string.color(settings.party.fontname,settings.party.color,160).." | "..string.color(settings.tell.fontname,settings.tell.color,160).." | "..string.color(settings.ffochat.fontname,settings.ffochat.color,160))
		windower.add_to_chat(160, " fontsize: "..string.color(tostring(settings.linkshell.fontsize),settings.linkshell.color,160).." | "..string.color(tostring(settings.party.fontsize),settings.party.color,160).." | "..string.color(tostring(settings.tell.fontsize),settings.tell.color,160).." | "..string.color(tostring(settings.ffochat.fontsize),settings.ffochat.color,160))
		windower.add_to_chat(160, " x: "..string.color(tostring(settings.linkshell.x),settings.linkshell.color,160).." | "..string.color(tostring(settings.party.x),settings.party.color,160).." | "..string.color(tostring(settings.tell.x),settings.tell.color,160).." | "..string.color(tostring(settings.ffochat.x),settings.ffochat.color,160))
		windower.add_to_chat(160, " y: "..string.color(tostring(settings.linkshell.y),settings.linkshell.color,160).." | "..string.color(tostring(settings.party.y),settings.party.color,160).." | "..string.color(tostring(settings.tell.y),settings.tell.color,160).." | "..string.color(tostring(settings.ffochat.y),settings.ffochat.color,160))
		windower.add_to_chat(160, " alpha: "..string.color(tostring(settings.linkshell.alpha),settings.linkshell.color,160).." | "..string.color(tostring(settings.party.alpha),settings.party.color,160).." | "..string.color(tostring(settings.tell.alpha),settings.tell.color,160).." | "..string.color(tostring(settings.ffochat.alpha),settings.ffochat.color,160))
		windower.add_to_chat(160, " red: "..string.color(tostring(settings.linkshell.red),settings.linkshell.color,160).." | "..string.color(tostring(settings.party.red),settings.party.color,160).." | "..string.color(tostring(settings.tell.red),settings.tell.color,160).." | "..string.color(tostring(settings.ffochat.red),settings.ffochat.color,160))
		windower.add_to_chat(160, " green: "..string.color(tostring(settings.linkshell.green),settings.linkshell.color,160).." | "..string.color(tostring(settings.party.green),settings.party.color,160).." | "..string.color(tostring(settings.tell.green),settings.tell.color,160).." | "..string.color(tostring(settings.ffochat.green),settings.ffochat.color,160))
		windower.add_to_chat(160, " blue: "..string.color(tostring(settings.linkshell.blue),settings.linkshell.color,160).." | "..string.color(tostring(settings.party.blue),settings.party.color,160).." | "..string.color(tostring(settings.tell.blue),settings.tell.color,160).." | "..string.color(tostring(settings.ffochat.blue),settings.ffochat.color,160))
	else
--		windower.add_to_chat(160," UseChatPorter: " .. string.color(onOffPrint(settings.usechatporter),204,160))
--		windower.add_to_chat(160," DisplayLinkshellChat: " .. string.color(onOffPrint(settings.linkshell.displaychat),204,160))
--		windower.add_to_chat(160," DisplayPartyChat: " .. string.color(onOffPrint(settings.party.displaychat),204,160))
--		windower.add_to_chat(160," DisplayTellChat: " .. string.color(onOffPrint(settings.tell.displaychat),204,160))
--		windower.add_to_chat(160," DisplayFFOChat: " .. string.color(onOffPrint(settings.ffochat.displaychat),204,160))
--		windower.add_to_chat(160," LinkshellColor: " .. string.color(tostring(settings.linkshell.color),204,160))
--		windower.add_to_chat(160," PartyColor: " .. string.color(tostring(settings.party.color),204,160))
--		windower.add_to_chat(160," TellColor: " .. string.color(tostring(settings.tell.color),204,160))
--		windower.add_to_chat(160," TellColor: " .. string.color(tostring(settings.ffochat.color),204,160))
		windower.add_to_chat(55, "ChatPorter status: "..string.color('linkshell',settings.linkshell.color,160).." | "..string.color('party',settings.party.color,160).." | "..string.color('tell',settings.tell.color,160).." | "..string.color('ffochat',settings.ffochat.color,160))
		windower.add_to_chat(160, " DisplayChat: "..string.color(onOffPrint(settings.linkshell.displaychat),settings.linkshell.color,160).." | "..string.color(onOffPrint(settings.party.displaychat),settings.party.color,160).." | "..string.color(onOffPrint(settings.tell.displaychat),settings.tell.color,160).." | "..string.color(onOffPrint(settings.ffochat.displaychat),settings.ffochat.color,160))
		windower.add_to_chat(160, " Color: "..string.color(tostring(settings.linkshell.color),settings.linkshell.color,160).." | "..string.color(tostring(settings.party.color),settings.party.color,160).." | "..string.color(tostring(settings.tell.color),settings.tell.color,160).." | "..string.color(tostring(settings.ffochat.color),settings.ffochat.color,160))
		windower.add_to_chat(160, " UseChatPorter: " .. string.color(onOffPrint(settings.usechatporter),204,160))
	end
end

function onOffPrint(bleh)
	if (bleh ~= nul) then
		if (bleh == 1) or (bleh == true) then
			bleh = "ON";
		else
			bleh = "OFF";
		end
	else
		bleh = "OFF";
	end
	return bleh;
end

function showColors()
	colors = {}
	colors[1] = 'Menu > Font Colors > Chat > Immediate vicinity ("Say")'
	colors[2] = 'Menu > Font Colors > Chat > Wide area ("Shout")'
	colors[3] = 'Menu > Font Colors > Chat > Extremely wide area ("Yell")'
	colors[4] = 'Menu > Font Colors > Chat > Tell target only ("Tell")'
	colors[5] = 'Menu > Font Colors > Chat > All party members ("Party")'
	colors[6] = 'Menu > Font Colors > Chat > Linkshell group ("Linkshell")'
	colors[7] = 'Menu > Font Colors > Chat > Emotes'
	colors[8] = 'Menu > Font Colors > System > Calls for help'
	colors[17] = 'Menu > Font Colors > Chat > Messages ("Message")'
	colors[142] = 'Menu > Font Colors > Chat > NPC Conversations' -- 143?
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

	UsedColors = {9,10,11,12,13,14,15,16,17,18,20,21,22,23,24,25,26,27,31,32,33,34,35,40,41,42,43,51,52,55,58,62,64,65,66,67,68,69,70,71,72,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,122,127,128,129,130,131,132,133,134,135,136,137,138,139,140,144,145,146,147,148,149,150,151,152,153,162,163,164,165,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,205,208,253,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,284,285,286,287,292,293,294,295,300,301,302,303,308,309,310,311,316,317,318,319,324,325,326,327,332,333,334,335,340,341,342,343,344,345,346,347,348,349,350,351,355,357,358,360,361,363,366,369,372,374,375,378,381,384,395,406,409,412,415,416,418,421,424,437,450,453,456,458,459,462,479,490,493,496,499,500,502,505,507,508}
	makeArray = T{}
	for v = 1, 255, 1 do
		if colors[v] ~= nil then
			windower.add_to_chat(v, string.rep(0,3-#tostring(v))..v.." - "..colors[v])
		else
			if table.contains(UsedColors,v) ~= true then
--				makeArray[#makeArray+1] = "\x1F"..string.char(v)..string.rep(0,3-#tostring(v))..v.."\x1F"..string.char(160)
				makeArray[#makeArray+1] = string.char(0x1F,v)..string.rep(0,3-#tostring(v))..v..string.char(0x1F,v)..string.char(160)
			end
		end
	end
	windower.add_to_chat(160,table.sconcat(makeArray))
--	makeArray:vprint()
end

function show(tbName)
	if #_G['show'..tbName] > 8 then
		table.remove(_G["show"..tbName],1)
	end
	windower.text.set_bg_color("show"..tbName, 200, 30, 30, 30)
	if #_G['show'..tbName] == 0 then
		windower.text.set_bg_visibility("show"..tbName, false)
	else
		windower.text.set_bg_visibility("show"..tbName, true)
	end
	windower.text.set_color("show"..tbName, settings[tbName].alpha, settings[tbName].red, settings[tbName].green, settings[tbName].blue)
	windower.text.set_font("show"..tbName, settings[tbName].fontname)
	windower.text.set_font_size("show"..tbName, settings[tbName].fontsize)
	windower.text.set_location("show"..tbName, settings[tbName].x, settings[tbName].y)
	windower.text.set_visibility("show"..tbName, settings[tbName].show)
	if #_G['show'..tbName] <= settings[tbName].lines then
		start = 1
	else
		start = #_G['show'..tbName]-settings[tbName].lines+1
	end
	windower.text.set_text("show"..tbName, " " ..table.concat(table.slice(_G['show'..tbName], start, #_G['show'..tbName]), '\n '))
	
--	windower.text.set_bg_border_size("show"..tbName, 1)
--	windower.text.set_bold("show"..tbName, false)
--	windower.text.set_italic("show"..tbName, false)
--	windower.text.set_right_justified("show"..tbName, false)
--	windower.text.set_stroke_color("show"..tbName, 255, 100, 100, 100)
--	windower.text.set_stroke_width("show"..tbName, 1)
end

windower.register_event('ipc message',function (msg)
	if (settings.usechatporter == true) then
		if (string.find(msg, "|(%w+):(%w*)|(%a+)|(.+)")) then
			a,b,chatMode,senderLSname,senderName,message = string.find(msg, "|(%w+):(%w*)|(%a+)|(.+)")
			if (chatMode == "l") and (settings.linkshell.displaychat == true) then
				if (senderLSname ~= LSname) then
					windower.add_to_chat(settings.linkshell.color,"["..senderLSname.."] <"..senderName.."> "..message)
					showlinkshell[#showlinkshell +1] = " ["..senderLSname.."] <"..senderName.."> "..message:strip_format().." "
					show("linkshell")
				end
			elseif (chatMode == "t") and (settings.tell.displaychat == true) then
				if (playerName ~= senderLSname) and (playerName ~= senderName) then
					windower.add_to_chat(settings.tell.color,"[t] "..senderName..">>"..senderLSname.." "..message)
				end
			elseif (chatMode == "p") and (settings.party.displaychat == true) then
				if (T(windower.ffxi.get_party()):with('name', senderName) == nil) then
					windower.add_to_chat(settings.party.color," ("..senderName..") "..message)
					showparty[#showparty +1] = " ("..senderName..") "..message:strip_format():trim().." "
					show("party")
				end
			elseif (chatMode == "l2") then
				windower.send_command("input /l "..message)
			elseif (chatMode == "p2") then
				windower.send_command("input /p "..message)
			elseif (chatMode == "t2") then
				windower.send_command("input /t "..message)
			elseif (chatMode == "r2") then
				windower.send_command("input /t "..lastTellFrom.." "..message)
			elseif (chatMode == "f") then
				windower.send_command("input /"..senderLSname.." "..message)
			end
		end
	end
end)

windower.register_event('incoming text',function (original, modified, mode)
	if (playerName == nil) then
		playerName = windower.ffxi.get_player().name
	end
	if (LSname == nil) then
		LSname = windower.ffxi.get_player().linkshell
	end

--[[
	function inTable(tbl, item)
		for key, value in pairs(tbl) do
			if value == item then return key end
		end
		return false
	end

	tbl = {12, 4, 13, 5, 14, 6, 214, 213, 212, 9, 1, 10, 2, 11, 3, 15, 7, 208, 121, 123, 204, 206, 90, 91, 127, 161, 138, 0, 207, 136, 160}

	if (mode ~= 206) then
		if inTable(tbl, mode) then
		else
			windower.send_command("input /echo mode: " .. mode .. " message: " .. original)
			print(' cp mode: '..mode..' message: '..original)
		end
	end
]]--

	if (mode == 6) or (mode == 14) or (mode == 213) or (mode == 214) then -- linkshell
		if (string.find(original:strip_format(), "%[(%d+)%]<(%a+)> (.+)")) then
			a,b,lsnum,player,message = string.find(original:strip_format(), "%[(%d+)%]<(%a+)> (.+)")
			windower.send_ipc_message(specialChar.."l:"..LSname..specialChar..player..specialChar..message)
			showlinkshell[#showlinkshell +1] = " ["..lsnum.."]<"..player.."> "..message:strip_format():trim().." "
			show("linkshell")
		end
	elseif (mode == 5) or (mode == 13) then -- party
		if (string.find(original:strip_format(), "%((%a+)%) (.+)")) then
			a,b,player,message = string.find(original:strip_format(), "%((%a+)%) (.+)")
			windower.send_ipc_message(specialChar.."p:"..""..specialChar..player..specialChar..message)
			showparty[#showparty +1] = " ("..player..") "..message:strip_format():trim().." "
			show("party")
		end
	elseif (mode == 4) or (mode == 12) then -- tell
		if (string.find(original:strip_format(), ">>(%a+) : (.+)")) then -- incoming
			a,b,player,message = string.find(original:strip_format(), ">>(%a+) : (.+)")
			lastTellFrom = player;
			windower.send_ipc_message(specialChar.."t:"..player..specialChar..playerName..specialChar..message)
			showtell[#showtell +1] = " >>"..player.." : "..message:strip_format():trim().." "
			show("tell")
		elseif (string.find(original:strip_format(), "(%a+)>> (.+)")) then -- outgoing
			a,b,player,message = string.find(original:strip_format(), "(%a+)>> (.+)")
			windower.send_ipc_message(specialChar.."t:"..playerName..specialChar..player..specialChar..message)
			showtell[#showtell +1] = " "..player..">> "..message:strip_format():trim().." "
			show("tell")
		end
	end
		
	if (string.find(original:strip_format(), "%[(%d+):#(%a+)%](.+): (.+)")) then
		a,b,channum,chanchan,player,message = string.find(original:strip_format(), "%[(%d+):#(%a+)%](.+): (.+)")
--		windower.send_ipc_message(specialChar.."f:"..player..specialChar..playerName..specialChar..message)
		showffochat[#showffochat +1] = " "..original:strip_format():trim().." "
		show("ffochat")
	end

--[[
tell: in 12, out 4
party: in 13, out 5
linkshell: in 14, out 6
linkshell2: in 214, out 213
unity: in 212, out 212

say: in 9, out 1
shout: in 10, out 2
yell: in 11, out 3
emote: in 15, out 7
	
3: ffochat channel
208: examines
121: browse and leaving bazaar
123: no party members message
204: player comments (seacom)
206: echo
90, 91, 127: uses an item
110: synergy overload
52: starts casting warp
64: casts warp
161: conquest results
138: bought from bazaar
0: player title
136: logout message
200: server welcome message
217: ls2 message
205: ls message
157: command error

--]]
end)
