--[[
Copyright (c) 2013, Ikonic
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of chatPorter nor the
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

_addon = {}
_addon.name = 'ChatPorter'
_addon.version = '1.21'
_addon.author = 'Ragnarok.Ikonic'

require 'tablehelper'
require 'stringhelper'
require 'colors'
local config = require 'config'
require 'logger'

local defaults = T{}
defaults.usechatporter = true
defaults.displaylinkshellchat = true
defaults.displaypartychat = true
defaults.displaytellchat = true
defaults.lscolor = 41 -- 41, 70, 158, 204
defaults.pcolor = 207 -- 207
defaults.tcolor = 200 -- 208

settings = T{}

LSname = get_player().linkshell
playerName = get_player().name
specialChar = "|"
lastTellFrom = ""

function event_load()
	settings = config.load(defaults)
	send_command('alias ChatPorter lua command ChatPorter')
	send_command('alias cp lua command ChatPorter')
	send_command('alias l2 lua command ChatPorter l')
	send_command('alias p2 lua command ChatPorter p')
	send_command('alias t2 lua command ChatPorter t')
	send_command('alias r2 lua command ChatPorter r')
	send_command('alias f1 lua command ChatPorter f1')
	send_command('alias f2 lua command ChatPorter f2')
	send_command('alias f3 lua command ChatPorter f3')
	send_command('alias f4 lua command ChatPorter f4')
	send_command('alias f5 lua command ChatPorter f5')
	add_to_chat(55, "Loading ".._addon.name.." v".._addon.version.." (written by ".._addon.author..")")
	event_addon_command('help');
	showStatus();
end

function event_unload()
	settings:save('all') -- all characters
--	settings:save() -- current character only

	send_command('unalias ChatPorter')
	send_command('unalias cp')
	send_command('unalias l2')
	send_command('unalias p2')
	send_command('unalias t2')
	send_command('unalias r2')
	send_command('unalias f1')
	send_command('unalias f2')
	send_command('unalias f3')
	send_command('unalias f4')
	send_command('unalias f5')
	add_to_chat(55, "Unloading ".._addon.name.." v".._addon.version..".")
end

function event_login(name)
	LSname = get_player().linkshell;
	playerName = get_player().name;
--	add_to_chat(160,"Refreshing data...");
--	add_to_chat(160,"LSname: "..LSname);
--	add_to_chat(160,"playerName: "..playerName);
end

function event_addon_command(...)
    local args = {...}
    if (args[2] ~= nil) then
        comm = args[1]
		if comm ~= "color" then
			com2 = table.remove(args,1)
			com2 = table.concat(args, ' ')
			if comm:lower() == 'l' then
				send_ipc_message(specialChar.."l2:"..LSname..specialChar..playerName..specialChar..com2);
			elseif comm:lower() == 'p' then
				send_ipc_message(specialChar.."p2:"..""..specialChar..playerName..specialChar..com2);
			elseif comm:lower() == 't' then
				send_ipc_message(specialChar.."t2:"..playerName..specialChar..playerName..specialChar..com2);
			elseif comm:lower() == 'r' then
				send_ipc_message(specialChar.."r2:"..playerName..specialChar..playerName..specialChar..com2);
			elseif string.first(comm:lower(), 1) == 'f' then
				send_ipc_message(specialChar.."f:"..string.at(comm,2)..specialChar..playerName..specialChar..com2);
			end
		else
			com2 = args[2]
			com3 = tonumber(args[3])
			if com2 == 'l' then
				if (com3 ~= nil) and (com3 >= 1 and com3 <= 255) then
					settings.lscolor = com3
				else
					add_to_chat(160,"Color must be within range of 1 - 255; setting default color.")
					settings.lscolor = defaults.lscolor
				end
				showStatus('lscolor')
			elseif com2 == 'p' then
				if (com3 ~= nil) and (com3 >= 1 and com3 <= 255) then
					settings.pcolor = com3
				else
					add_to_chat(160,"Color must be within range of 1 - 255; setting default color.")
					settings.pcolor = defaults.pcolor
				end
				showStatus('pcolor')
			elseif com2 == 't' then
				if (com3 ~= nil) and (com3 >= 1 and com3 <= 255) then
					settings.tcolor = com3
				else
					add_to_chat(160,"Color must be within range of 1 - 255; setting default color.")
					settings.tcolor = defaults.tcolor
				end
				showStatus('tcolor')
			end
			
		end
    elseif args[1] ~= nil then
        comm = args[1]
        if comm:lower() == 'help' then
            add_to_chat(55,_addon.name.." v".._addon.version..' possible commands:')
			add_to_chat(55,'     //ChatPorter and //cp are both valid commands.')
            add_to_chat(55,'     //cp help         : Lists this menu.')
			add_to_chat(55,'     //cp status       : Shows current configuration.')
			add_to_chat(55,'     //cp colors       : Shows possible color codes.')
            add_to_chat(55,'     //cp toggle       : Toggles ChatPorter on/off.')
            add_to_chat(55,'     //cp l            : Toggles using ChatPorter for linkshell chat.')
			add_to_chat(55,'     //cp color l #    : Sets color for linkshell chat from second character.')
            add_to_chat(55,'     //cp p            : Toggles using ChatPorter for party chat.')
			add_to_chat(55,'     //cp color p #    : Sets color for party chat from second character.')
            add_to_chat(55,'     //cp t            : Toggles using ChatPorter for tell chat.')
			add_to_chat(55,'     //cp color t #    : Sets color for tell chat from second character.')
			add_to_chat(55,'     //l2 message      : Sends message from second character to linkshell.')
			add_to_chat(55,'     //p2 message      : Sends message from second character to party.')
			add_to_chat(55,'     //t2 name message : Sends message from second character to name in tell.')
			add_to_chat(55,'     //r2 message      : Sends reply message from second character.')
			add_to_chat(55,'     //f# message      : Sends message from second character to FFOChat channel #.  Works for 1-5.')
			add_to_chat(55,'     //cp f# message   : Same as f#, but for any #.')
		elseif comm:lower() == 'status' then
            showStatus()
        elseif comm:lower() == 'toggle' then
			settings.usechatporter = not settings.usechatporter
			showStatus('usechatporter')
        elseif comm:lower() == 'l' then
			settings.displaylinkshellchat = not settings.displaylinkshellchat
			showStatus('displaylinkshellchat')
        elseif comm:lower() == 'p' then
			settings.displaypartychat = not settings.displaypartychat
			showStatus('displaypartychat')
        elseif comm:lower() == 't' then
			settings.displaytellchat = not settings.displaytellchat
			showStatus('displaytellchat')
		elseif comm:lower() == 'reset' then
			add_to_chat(160, _addon.name.." v".._addon.version.." resetting stats.")
            reset()
        elseif comm:lower() == 'exit' then
			send_command('lua u ChatPorter')
        elseif comm:lower() == 'vprint' then
			settings:vprint()
        elseif comm:lower() == 'print' then
			for key, value in pairs(settings) do 
				log(key, value)
			end
		elseif comm:lower() == 'colors' then
			showColors()
        else
            return
        end
	else
		event_addon_command('help')
    end
end

function event_linkshell_change(linkshell)
	LSname = get_player().linkshell;
end

function showStatus(var)
	if (var ~= nul) then
		if var == "usechatporter" then
			add_to_chat(160,"   UseChatPorter: " .. string.color(onOffPrint(settings.usechatporter),204,160))
		elseif var == "displaylinkshellchat" then
			add_to_chat(160,"   DisplayLinkshellChat: " .. string.color(onOffPrint(settings.displaylinkshellchat),204,160))
		elseif var == "displaypartychat" then
			add_to_chat(160,"   DisplayPartyChat: " .. string.color(onOffPrint(settings.displaypartychat),204,160))
		elseif var == "displaytellchat" then
			add_to_chat(160,"   DisplayTellChat: " .. string.color(onOffPrint(settings.displaytellchat),204,160))
		elseif var == "lscolor" then
			add_to_chat(160,"   LinkshellColor: " .. string.color(tostring(settings.lscolor),204,160))
		elseif var == "pcolor" then
			add_to_chat(160,"   PartyColor: " .. string.color(tostring(settings.pcolor),204,160))
		elseif var == "tcolor" then
			add_to_chat(160,"   TellColor: " .. string.color(tostring(settings.tcolor),204,160))
		end
	else
		add_to_chat(160,"   UseChatPorter: " .. string.color(onOffPrint(settings.usechatporter),204,160))
		add_to_chat(160,"   DisplayLinkshellChat: " .. string.color(onOffPrint(settings.displaylinkshellchat),204,160))
		add_to_chat(160,"   DisplayPartyChat: " .. string.color(onOffPrint(settings.displaypartychat),204,160))
		add_to_chat(160,"   DisplayTellChat: " .. string.color(onOffPrint(settings.displaytellchat),204,160))
		add_to_chat(160,"   LinkshellColor: " .. string.color(tostring(settings.lscolor),204,160))
		add_to_chat(160,"   PartyColor: " .. string.color(tostring(settings.pcolor),204,160))
		add_to_chat(160,"   TellColor: " .. string.color(tostring(settings.tcolor),204,160))
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

	makeArray = T{}
	for v = 3, 255, 1 do
		if colors[v] ~= nil then
            add_to_chat(v, string.rep(0,3-#tostring(v))..v.." - "..colors[v])
		else
			if v ~= 253 then
				makeArray[#makeArray+1] = "\x1F"..string.char(v)..string.rep(0,3-#tostring(v))..v.."\x1F"..string.char(160)
			end
		end
	end
	add_to_chat(160,table.sconcat(makeArray))
	--makeArray:vprint()
end

function event_ipc_message(msg)
	if (settings.usechatporter == true) then
		if (string.find(msg, "|(%w+):(%w*)|(%a+)|(.+)")) then
			a,b,chatMode,senderLSname,senderName,message = string.find(msg, "|(%w+):(%w*)|(%a+)|(.+)")
			if (chatMode == "t") and (settings.displaytellchat == true) then
				if (playerName ~= senderName) then
					add_to_chat(settings.tcolor,"[t] "..senderName..">>"..senderLSname.." "..message)
				end
			elseif (chatMode == "p") and (settings.displaypartychat == true) then
				if (T(get_party()):with('name', senderName) == nil) then
					add_to_chat(settings.pcolor,"[p] ".."("..senderName..") "..message)
				end
			elseif (chatMode == "l") and (settings.displaylinkshellchat == true) then
				if (senderLSname ~= LSname) then
					add_to_chat(settings.lscolor,"["..senderLSname.."] <"..senderName.."> "..message)
				end
			elseif (chatMode == "l2") then
				send_command("input /l "..message)
			elseif (chatMode == "p2") then
				send_command("input /p "..message)
			elseif (chatMode == "t2") then
				send_command("input /t "..message)
			elseif (chatMode == "r2") then
				send_command("input /t "..lastTellFrom.." "..message)
			elseif (chatMode == "f") then
				send_command("input /"..senderLSname.." "..message)
			end
		end
	end
end

function event_incoming_text(original, modified, mode)
	if (playerName == nil) then
		playerName = get_player().name
	end
	if (LSname == nil) then
		LSname = get_player().linkshell
	end

	if (mode == 6) then -- linkshell (me)
		if (string.find(original, "<(%a+)> (.+)")) then
			a,b,player,message = string.find(original, "<(%a+)> (.+)")
			send_ipc_message(specialChar.."l:"..LSname..specialChar..player..specialChar..message)
		end
	
	elseif (mode == 5) then -- party (me)
		if (string.find(original, "%((%a+)%) (.+)")) then
			a,b,player,message = string.find(original, "%((%a+)%) (.+)")
			send_ipc_message(specialChar.."p:"..""..specialChar..player..specialChar..message)
		end

	elseif (mode == 4) then -- tell (out)
		if (string.find(original, ">>(%a+) : (.+)")) then
			a,b,player,message = string.find(original, ">>(%a+) : (.+)")
			send_ipc_message(specialChar.."t:"..player..specialChar..playerName..specialChar..message)
		end
	end
	
     --[[
         4: tell (out)
         12: tell (in)
         5: party (me)
         13: party (others)
         6: linkshell (me)
         14: linkshell (others)
     --]]
end

function event_chat_message(is_gm, mode, player, message)
--[[
3 = tell
4 = party
5 = linkshell

	|t:from|senderName|message
]]--

	if (mode == 3) then -- tell
		send_ipc_message(specialChar.."t:"..playerName..specialChar..player..specialChar..message)
		lastTellFrom = player;
	elseif (mode == 5) then -- linkshell
		send_ipc_message(specialChar.."l:"..LSname..specialChar..player..specialChar..message)
	elseif (mode == 4) then -- party
		send_ipc_message(specialChar.."p:"..""..specialChar..player..specialChar..message)
	end
end

--[[
possible port to ffochat LSchannel

add stuff to save based on character
add stuff to use settings based on character

]]--

