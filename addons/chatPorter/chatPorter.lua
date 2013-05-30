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
_addon.name = 'chatPorter'
_addon.version = '1.11'
_addon.author = 'Ragnarok.Ikonic'

require 'tablehelper'
require 'stringhelper'

myChars = {"Ikonic", "Vivika", "Icinoki", "Vicassina", "Xynia", "Ayka"};

LSname = get_player().linkshell;
playerName = get_player().name;
specialChar = "|";
lastTellFrom = "";

LScolor = 41; -- 41, 70, 158, 204
Pcolor = 207; -- 207
Tcolor = 200; -- 208

UseChatPorter = 1;
DisplayPartyChat = 1;
DisplayLinkshellChat = 1;
DisplayTellChat = 1;

chatPorterValues = T{};
chatPorterValues.UseChatPorter = T{};
chatPorterValues.UseChatPorter.Name = "UseChatPorter";
chatPorterValues.UseChatPorter.Value = true;
chatPorterValues.DisplayPartyChat = T{};
chatPorterValues.DisplayPartyChat.Name = "DisplayPartyChat";
chatPorterValues.DisplayPartyChat.Value = true;
chatPorterValues.DisplayLinkshellChat = T{};
chatPorterValues.DisplayLinkshellChat.Name = "DisplayLinkshellChat";
chatPorterValues.DisplayLinkshellChat.Value = true;
chatPorterValues.DisplayTellChat = T{};
chatPorterValues.DisplayTellChat.Name = "DisplayTellChat";
chatPorterValues.DisplayTellChat.Value = true;

function event_load()
	send_command('alias chatPorter lua command chatPorter')
	send_command('alias cp lua command chatPorter')
	send_command('alias l2 lua command chatPorter l')
	send_command('alias p2 lua command chatPorter p')
	send_command('alias t2 lua command chatPorter t')
	send_command('alias r2 lua command chatPorter r')
	send_command('alias f1 lua command chatPorter f1')
	send_command('alias f2 lua command chatPorter f2')
	send_command('alias f3 lua command chatPorter f3')
	send_command('alias f4 lua command chatPorter f4')
	send_command('alias f5 lua command chatPorter f5')
	add_to_chat(55, "Loading ".._addon.name.." v".._addon.version.." (written by ".._addon.author..")")
	event_addon_command('help');
--	showStatus();
	showStatusArray();
end

function event_unload()
	send_command('unalias chatPorter')
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
    if args[2] ~= nil then
        comm = args[1]
		com2 = table.remove(args,1)
		com2 = table.concat(args, ' ')
--		add_to_chat(160, "second word: "..com2);
		if comm:lower() == 'l' then
--			add_to_chat(160, "l2 message: '"..com2.."'");
			send_ipc_message(specialChar.."l2:"..LSname..specialChar..playerName..specialChar..com2);
--			add_to_chat(160,specialChar.."l2:"..LSname..specialChar..playerName..specialChar..com2);
		elseif comm:lower() == 'p' then
--			add_to_chat(160, "p2 message: '"..com2.."'");
			send_ipc_message(specialChar.."p2:"..""..specialChar..playerName..specialChar..com2);
--			add_to_chat(160,specialChar.."p2:"..""..specialChar..playerName..specialChar..com2);
		elseif comm:lower() == 't' then
--			add_to_chat(160, "t2 message: '"..com2.."'");
			send_ipc_message(specialChar.."t2:"..playerName..specialChar..playerName..specialChar..com2);
--			add_to_chat(160,specialChar.."t2:"..playerName..specialChar..playerName..specialChar..com2);
		elseif comm:lower() == 'r' then
--			add_to_chat(160, "r2 message: '"..com2.."'");
			send_ipc_message(specialChar.."r2:"..playerName..specialChar..playerName..specialChar..com2);
--			add_to_chat(160,specialChar.."r2:"..playerName..specialChar..playerName..specialChar..com2);
		elseif string.first(comm:lower(), 1) == 'f' then
			send_ipc_message(specialChar.."f:"..string.at(comm,2)..specialChar..playerName..specialChar..com2);
--			add_to_chat(160,specialChar.."f:"..string.at(comm,2)..specialChar..playerName..specialChar..com2);
		end
    elseif args[1] ~= nil then
        comm = args[1]
        if comm:lower() == 'help' then
            add_to_chat(55,_addon.name.." v".._addon.version..' possible commands:')
			add_to_chat(55,'     //chatPorter and //cp are both valid commands.')
            add_to_chat(55,'     //chatPorter help   : Lists this menu.')
			add_to_chat(55,'     //chatPorter status : Shows current configuration.')
            add_to_chat(55,'     //chatPorter toggle : Toggles chatPorter on/off.')
--            add_to_chat(55,'     //chatPorter off    : Turns off chatPorter.')
            add_to_chat(55,'     //chatPorter p      : Toggles using chatPorter for party chat.')
            add_to_chat(55,'     //chatPorter l      : Toggles using chatPorter for linkshell chat.')
            add_to_chat(55,'     //chatPorter t      : Toggles using chatPorter for tell chat.')
			add_to_chat(55,'     //l2 message        : Sends message from second character to linkshell.')
			add_to_chat(55,'     //p2 message        : Sends message from second character to party.')
			add_to_chat(55,'     //t2 name message   : Sends message from second character to name in tell.')
			add_to_chat(55,'     //r2 message        : Sends reply message from second character.')
			add_to_chat(55,'     //f# message        : Sends message from second character to FFOChat channel #.  Works for 1-5.')
			add_to_chat(55,'     //cp f# message     : Same as f#, but for any #.')
		elseif comm:lower() == 'status' then
            showStatusArray();
        elseif comm:lower() == 'toggle' then
			chatPorterValues.UseChatPorter.Value = not chatPorterValues.UseChatPorter.Value;
			showStatusArray(chatPorterValues.UseChatPorter);
        elseif comm:lower() == 'p' then
			chatPorterValues.DisplayPartyChat.Value = not chatPorterValues.DisplayPartyChat.Value;
			showStatusArray(chatPorterValues.DisplayPartyChat);
        elseif comm:lower() == 'l' then
			chatPorterValues.DisplayLinkshellChat.Value = not chatPorterValues.DisplayLinkshellChat.Value;
			showStatusArray(chatPorterValues.DisplayLinkshellChat);
        elseif comm:lower() == 't' then
			chatPorterValues.DisplayTellChat.Value = not chatPorterValues.DisplayTellChat.Value;
			showStatusArray(chatPorterValues.DisplayTellChat);
		elseif comm:lower() == 'reset' then
			add_to_chat(160, _addon.name.." v".._addon.version.." resetting stats.");
            reset();
        elseif comm:lower() == 'exit' then
			send_command('lua u chatPorter')
        elseif comm:lower() == 'test' then
			send_command('input /l testing chatPorter on Linkshell')
        elseif comm:lower() == 'test2' then
			send_command('input /p testing chatPorter on Party')
        elseif comm:lower() == 'test3' then
			send_command('input /t <me> testing chatPort on Tell')
        elseif comm:lower() == 'test4' then

        elseif comm:lower() == 'test5' then
			DisplayTellChat = not DisplayTellChat;
			add_to_chat(160,"DisplayTellChat new value: "..DisplayTellChat);
			showStatus(DisplayTellChat);
		elseif comm:lower() == 'test6' then
			chatPorterValues.UseChatPorter.Value = -chatPorterValues.UseChatPorter.Value;
			showStatusArray(chatPorterValues.UseChatPorter);
		elseif comm:lower() == 'test7' then
			chatPorterValues.UseChatPorter.Value = not chatPorterValues.UseChatPorter.Value;
			showStatusArray(chatPorterValues.UseChatPorter);
		elseif comm:lower() == 'test8' then
			send_command("cp l hey, how are you doing today? i'm doing great!");
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

function showStatusArray(var)
--	add_to_chat(160,"show status array");
	if (var ~= nul) then
		add_to_chat(160,var.Name..": "..onOffPrint(var.Value));
	else
		var = chatPorterValues.UseChatPorter;
		add_to_chat(160,var.Name..": "..onOffPrint(var.Value));
		var = chatPorterValues.DisplayPartyChat;
		add_to_chat(160,var.Name..": "..onOffPrint(var.Value));
		var = chatPorterValues.DisplayLinkshellChat;
		add_to_chat(160,var.Name..": "..onOffPrint(var.Value));
		var = chatPorterValues.DisplayTellChat;
		add_to_chat(160,var.Name..": "..onOffPrint(var.Value));
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
--	add_to_chat(14,bleh);
	return bleh;
end




function toggle(varName, displayNew, chatColor)
	if (displayNew == nul) then
		displayNew = "n";
	else
		displayNew = "y";
	end
	if (chatColor == nul) then
		chatColor = "160";
	end
	if (varName ~= nul) then
		if (varName == 1) then
			varName = 0;
			if (displayNew == "y") then
				add_to_chat(chatColor,varName..": OFF");
			end
		else
			varName = 1;
			if (displayNew == "y") then
				add_to_chat(chatColor,varName..": ON");
			end
		end
	else
		add_to_chat(160,"Missing variable to toggle.");
	end
	return varName
end

function event_ipc_message(msg)
--add_to_chat(160,"..."..msg.."...");
	if (chatPorterValues.UseChatPorter.Value == true) then
		if (string.find(msg, "|(%w+):(%w*)|(%a+)|(.+)")) then
--			add_to_chat(160,"does this hit?");
			a,b,chatMode,senderLSname,senderName,message = string.find(msg, "|(%w+):(%w*)|(%a+)|(.+)")
--[[
			add_to_chat(41,"chatMode: "..chatMode);
			add_to_chat(41,"senderLSname: "..senderLSname);
			add_to_chat(41,"senderName: "..senderName);
			add_to_chat(41,"message: "..message);
]]--
			if (chatMode == "t") and (chatPorterValues.DisplayTellChat.Value == true) then
--				add_to_chat(14,"tell ... playerName: "..playerName);
				if (playerName ~= senderName) then
					add_to_chat(Tcolor,"[t] "..senderName..">>"..senderLSname.." "..message);
				else	
					-- this should never fire, only here for testing
					if table.contains(myChars, senderName) then
						add_to_chat(Tcolor,"(telltesting)[t] "..senderName..">>"..senderLSname.." "..message);
					end
				end
		
			elseif (chatMode == "p") and (chatPorterValues.DisplayPartyChat.Value == true) then
--				add_to_chat(160,"party...");
				if (T(get_party()):with('name', senderName) == nil) then
					add_to_chat(Pcolor,"[p] ".."("..senderName..") "..message);
--				else
					-- this should never fire, only here for testing
--					add_to_chat(Pcolor,"(partytest)[p] ".."("..senderName..") "..message);
				end
		
			elseif (chatMode == "l") and (chatPorterValues.DisplayLinkshellChat.Value == true) then
--				add_to_chat(160,"linkshell...");
				if (senderLSname ~= LSname) then
					add_to_chat(LScolor,"["..senderLSname.."] <"..senderName.."> "..message);
--				else
					-- this should fire if both chars have same LS, only here for testing
--					add_to_chat(LScolor,"(linkshelltest)["..senderLSname.."] <"..senderName.."> "..message);
--					add_to_chat(160,"senderLSname: "..senderLSname..", LSname: "..LSname);
				end
			elseif (chatMode == "l2") then
				send_command("input /l "..message);
			elseif (chatMode == "p2") then
				send_command("input /p "..message);
			elseif (chatMode == "t2") then
				send_command("input /t "..message);
			elseif (chatMode == "r2") then
				send_command("input /t "..lastTellFrom.." "..message);
			elseif (chatMode == "f") then
				send_command("input /"..senderLSname.." "..message);
			end
		end
	end
end

function event_incoming_text(original, modified, mode)
	if (playerName == nil) then
		playerName = get_player().name;
		add_to_chat(160,"playerName is nil");
	end
	if (LSname == nil) then
		LSname = get_player().linkshell;
		add_to_chat(160,"LSname is nil");
	end

	if (mode == 6) then -- linkshell (me)
--		add_to_chat(14,"(event_incoming_text)this is mode: "..mode);
--		add_to_chat(160,original);
		if (string.find(original, "<(%a+)> (.+)")) then
			a,b,player,message = string.find(original, "<(%a+)> (.+)")
			send_ipc_message(specialChar.."l:"..LSname..specialChar..player..specialChar..message);
--			add_to_chat(160,specialChar.."l:"..LSname..specialChar..player..specialChar..message);
		end
	--end
	
	elseif (mode == 5) then -- party (me)
--		add_to_chat(14,"(event_incoming_text)this is mode: "..mode);
--		add_to_chat(160,original);
		if (string.find(original, "%((%a+)%) (.+)")) then
			a,b,player,message = string.find(original, "%((%a+)%) (.+)")
			send_ipc_message(specialChar.."p:"..""..specialChar..player..specialChar..message);
--			add_to_chat(160,specialChar.."p:"..""..specialChar..player..specialChar..message);
		end
	--end

	elseif (mode == 4) then -- tell (out)
--		add_to_chat(14,"(event_incoming_text)this is mode: "..mode);
--		add_to_chat(160,"mode:4..."..original.."...");
		if (string.find(original, ">>(%a+) : (.+)")) then
			a,b,player,message = string.find(original, ">>(%a+) : (.+)")
			send_ipc_message(specialChar.."t:"..player..specialChar..playerName..specialChar..message);
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
--	add_to_chat(14,"(event_chat_message)this is mode: "..mode);
--[[
3 = tell
4 = party
5 = linkshell

	|t:from|senderName|message
]]--

	if (mode == 3) then -- tell
		send_ipc_message(specialChar.."t:"..playerName..specialChar..player..specialChar..message);
--		add_to_chat(160,specialChar.."t:"..playerName..specialChar..player..specialChar..message);
			lastTellFrom = player;
--			add_to_chat(160,"lastTellFrom: "..lastTellFrom);
	elseif (mode == 5) then -- linkshell
		send_ipc_message(specialChar.."l:"..LSname..specialChar..player..specialChar..message);
--		add_to_chat(160,specialChar.."l:"..LSname..specialChar..player..specialChar..message);
	elseif (mode == 4) then -- party
		send_ipc_message(specialChar.."p:"..""..specialChar..player..specialChar..message);
--		add_to_chat(160,specialChar.."p:"..""..specialChar..player..specialChar..message);
	end
end

--[[

possible port to ffochat LSchannel
save and read settings to settings.xml
ability to change color settings

]]--

