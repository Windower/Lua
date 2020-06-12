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
    * Neither the name of Blist nor the
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


_addon.name = 'Blist'
_addon.author = 'Ragnarok.Ikonic'
_addon.version = '1.2.0.1'

require 'tables'
require 'strings'
require 'chat/colors'
local config = require 'config'
require 'logger'

local defaults = T{}
defaults.useblist = true
defaults.linkshell = true
defaults.party = true
defaults.tell = true
defaults.emote = true
defaults.say = true
defaults.shout = true
defaults.bazaar = true
defaults.examine = true
defaults.mutedcolor = 57

settings = T{}
members = T{}

windower.register_event('load',function()
	settings = config.load(defaults)
	members = config.load("data/members.xml",members)
	windower.send_command('alias blist lua command blist')
	windower.send_command('alias bl lua command blist')
	windower.add_to_chat(55, "Loading ".._addon.name.." v".._addon.version.." (written by ".._addon.author..")")
	windower.add_to_chat(160,'  Type '..string.color('//blist help',204,160)..' for a list of possible commands.')
end)

windower.register_event('unload',function()
	windower.send_command('unalias blist')
	windower.send_command('unalias bl')
	windower.add_to_chat(55, "Unloading ".._addon.name.." v".._addon.version..".")
end)

windower.register_event('login',function (name)
	settings = config.load(defaults)
	windower.add_to_chat(160,"Loading "..string.color(_addon.name,55,160).." settings for "..windower.ffxi.get_player().name..".")
end)

function addon_command(...)
	local args = {...}
	local dummysettings = table.copy(settings)
	if args[1] ~= nil then
		comm = args[1]:lower()
        if comm == 'help' then
			windower.add_to_chat(55,_addon.name.." v".._addon.version..' possible commands:')
			windower.add_to_chat(160,'  '..string.color('//Blist',204,160)..' and '..string.color('//bl',204,160)..' are both valid commands.')
			windower.add_to_chat(160,'  '..string.color('//bl help',204,160)..' : Lists this menu.')
			windower.add_to_chat(160,'  '..string.color('//bl status',204,160)..' : Shows current configuration.')
			windower.add_to_chat(160,'  '..string.color('//bl list',204,160)..' : Displays blacklist.')
			windower.add_to_chat(160,'  '..string.color('//bl useblist|linkshell|party|tell|emote|say|shout|bazaar|examine',204,160)..' : Toggles using '.._addon.name..' for said chat mode.')
			windower.add_to_chat(160,'  '..string.color('//bl mutedcolor #',204,160)..' : Sets color for muted communication.  Valid values 1-255.')
			windower.add_to_chat(160,'  '..string.color('//bl add|update name # hidetype reason',204,160)..' : Adds to or updates a user on your blist.')
			windower.add_to_chat(160,'  '..string.color('  name',204,160)..' = name of person you want to blist')
			windower.add_to_chat(160,'  '..string.color('  #',204,160)..' = number of days to blist said person; 0 = forever')
			windower.add_to_chat(160,'  '..string.color('  hidetype',204,160)..' = how blacklisted you want said person to be; valid options: hard, soft, muted')
			windower.add_to_chat(160,'  '..string.color('    hard',204,160)..' = full blist, nothing gets through')
			windower.add_to_chat(160,'  '..string.color('    soft',204,160)..' = message saying conversation from name was blocked')
			windower.add_to_chat(160,'  '..string.color('    muted',204,160)..' = message comes through, but in a different color')
			windower.add_to_chat(160,'  '..string.color('  reason',204,160)..' = reason why you are adding said person to blist')
			windower.add_to_chat(160,'  '..string.color('//bl delete|remove name',204,160)..' : Removes a user from your blist.')
			windower.add_to_chat(160,'  '..string.color('//bl qa name [reason]',204,160)..' : Adds a user to your blist w/o requiring extra details (reason is optional).')
		elseif comm == 'status' then
            showStatus()
		elseif comm == 'list' then
			windower.add_to_chat(160,string.color("Name",56).." | "..
			string.color("TempTime",3).." | "..
			string.color("HideType",settings.mutedcolor).." | "..
			string.color("Reason",59).." | "..
			string.color("Date Added",29))
			for i,v in pairs(members) do
				if members[i].hidetype ~= "delete" then
				windower.add_to_chat(160,string.color(tostring(i),56) .. " | " ..
				string.color(tostring(members[i].temptime),3) .. " | " .. 
				string.color(tostring(members[i].hidetype),settings.mutedcolor) .. " | " .. 
				string.color(tostring(members[i].reason),59) .. " | " .. 
				string.color(tostring(members[i].date),29)
				)
				end
			end
		elseif comm == "add" or comm == "update" then
			if type(args[2]:match("(%a+)")) ~= "string" 
			or type(tonumber(args[3]:match("(%d+)"))) ~= "number"
			or S({'hard','soft','muted'}):contains(args[4]:lower()) ~= true
			then
				windower.add_to_chat(160,"Invalid format; use the following: "..string.color("//bl "..comm.." name temptime hidetype reason",204,160))
			else
				com2 = args[2] -- name
				com3 = tonumber(args[3]) -- temptime
				com4 = args[4]:lower() -- hidetype
				if args[5] ~= nil then
					com5 = table.slice(args,5)
					com5mess = tostring(table.sconcat(com5))
				else
					com5mess = nil
				end

				local addTemp = T{}
				addTemp[com2] = {}
				addTemp[com2].reason = com5mess
				addTemp[com2].date = os.date("%x", date)
				addTemp[com2].temptime = com3
				addTemp[com2].hidetype = com4
			
				members = members:update(addTemp)
				members:save('all')
				windower.send_ipc_message("blist reload members")
				windower.add_to_chat(160,"Updating "..string.color(args[2],56,160).." entry on "..string.color(_addon.name,55,160)..".")
			end
		elseif comm == "qa" then
			if type(args[2]:match("(%a+)")) ~= "string" then
				windower.add_to_chat(160,"Invalid format; use the following: "..string.color("//bl qa <name> %[reason%]",204,160))
			else
				com2 = args[2] -- name
				if args[3] ~= nil then
					com3 = table.slice(args,3)
					com3mess = tostring(table.sconcat(com3))
				else
					com3mess = nil
				end

				local addTemp = T{}
				addTemp[com2] = {}
				addTemp[com2].reason = com3mess
				addTemp[com2].date = os.date("%x", date)
				addTemp[com2].temptime = 0
				addTemp[com2].hidetype = "hard"
			
				members = members:update(addTemp)
				members:save('all')
				windower.send_ipc_message("blist reload members")
				windower.add_to_chat(160,"Updating "..string.color(string.ucfirst(args[2]),56,160).." entry on "..string.color(_addon.name,55,160)..".")
			end
		elseif comm == "remove" or comm == "delete" then
			if members[args[2]] ~= nil then
				windower.add_to_chat(160,"Removing "..string.color(args[2],56,160).." from "..string.color(_addon.name,55,160)..".")
				members[args[2]].hidetype = "delete"
				members:save('all')
				windower.send_ipc_message("blist reload members")
			else
				windower.add_to_chat(160,"User "..string.color(args[2],56,160).." not in "..string.color(_addon.name,55,160).." database; cannot remove.")
			end
		elseif comm == "mutedcolor" or comm == "color" then
			com2num = tonumber(args[2])
			if (com2num ~= nil) and (com2num >= 1 and com2num <= 255) then
				settings[comm] = com2num
			else
				settings[comm] = defaults[comm]
				windower.add_to_chat(160,"  Invalid "..string.color(comm,settings.mutedcolor,160).." value; acceptable values: 1-255.  Setting default.")
			end
			showStatus(comm)
			if tostring(com2num) ~= tostring(dummysettings[comm]) then
				settings:save() -- current character only
				windower.add_to_chat(55,"Saving "..string.color(_addon.name,204,55).." settings.")
			end
		elseif S({'useblist','linkshell','party','tell','emote','say','shout','bazaar','examine'}):contains(comm) then
			settings[comm] = not settings[comm]
			showStatus(comm)
			if tostring(com2) ~= tostring(dummysettings[comm]) then
				settings:save() -- current character only
				windower.add_to_chat(55,"Saving "..string.color(_addon.name,204,55).." settings.")
			end
			
		elseif comm == "settings" then
			settings:vprint()
			
		else
			windower.add_to_chat(160, "  Not a valid ".._addon.name.." v".._addon.version.." command.  "..string.color('//bl help',204,160).." for a list of valid commands.")
			return
        end
	else
		addon_command('help')
	end
end

windower.register_event('addon command',addon_command)

function showStatus(var)
	if var == "mutedcolor" then
		windower.add_to_chat(160,"  Muted"..string.color("Color",settings.mutedcolor,160)..": " .. string.color(tostring(settings.mutedcolor),204,160))
	elseif var == "useblist" then
		windower.add_to_chat(160,"  UseBlist: " .. string.color(onOffPrint(settings[var]),204,160))
	elseif var ~= nul then
		windower.add_to_chat(160,"  UseBlistOn"..var:ucfirst()..": " .. string.color(onOffPrint(settings[var]),204,160))
	else
		windower.add_to_chat(160,"  UseBlist: " .. string.color(onOffPrint(settings.useblist),204,160))
		windower.add_to_chat(160,"  UseBlistOnLinkshell: " .. string.color(onOffPrint(settings.linkshell),204,160))
		windower.add_to_chat(160,"  UseBlistOnParty: " .. string.color(onOffPrint(settings.party),204,160))
		windower.add_to_chat(160,"  UseBlistOnTell: " .. string.color(onOffPrint(settings.tell),204,160))
		windower.add_to_chat(160,"  UseBlistOnEmote: " .. string.color(onOffPrint(settings.emote),204,160))
		windower.add_to_chat(160,"  UseBlistOnSay: " .. string.color(onOffPrint(settings.say),204,160))
		windower.add_to_chat(160,"  UseBlistOnShout: " .. string.color(onOffPrint(settings.shout),204,160))
		windower.add_to_chat(160,"  UseBlistOnBazaar: " .. string.color(onOffPrint(settings.bazaar),204,160))
		windower.add_to_chat(160,"  UseBlistOnExamine: " .. string.color(onOffPrint(settings.examine),204,160))
		windower.add_to_chat(160,"  Muted"..string.color("Color",settings.mutedcolor,160)..": " .. string.color(tostring(settings.mutedcolor),204,160))
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

windower.register_event('ipc message',function (msg)
	if msg == "blist reload members" then
		members = config.load("data/members.xml",members)
--		windower.add_to_chat(160, "Reloading members database.")
	end
end)

windower.register_event('incoming text',function (original, modified, mode)
	if settings.useblist == true then
		name = "blist"
		if mode == 14 and settings.linkshell == true then -- linkshell (others)
			a,z,name = string.find(original,'<(%a+)> ')
		elseif mode == 13 and settings.party == true then -- party (others)
			a,z,name = string.find(original,'%((%a+)%) ')
		elseif mode == 12 and settings.tell == true then -- tell (in)
			a,z,name = string.find(original,'(%a+)>> ')
		elseif (mode == 15 or mode == 7) and settings.emote == true then -- emote
			a,z,name = string.find(original,'(%a+) ')
		elseif mode == 1 and settings.say == true then -- say
			a,z,name = string.find(original,'(%a+) ')
		elseif mode == 2 and settings.shout == true then -- shout
			a,z,name = string.find(original,'(%a+) ')
		elseif mode == 121 and settings.bazaar == true then -- bazaar
			a,z,name,filler = string.find(original,'(%a+) (.*) bazaar%.')
		elseif mode == 208 and settings.examine == true then -- examine
			a,z,name = string.find(original,'(%a+) examines you%.')
		else
			name = "blist"
		end
		if name ~= nil then
			name = name:lower()
		else
			name = "blist"
		end
		
		if name ~= "blist" and 
		name ~= nil and 
		members[name] ~= nil and
		members[name].hidetype ~= "delete" then
			local pattern = "(%d+)%/(%d+)%/(%d+)"
			local xmonth, xday, xyear = members[name].date:match(pattern)
			local blah = tonumber(members[name].temptime)
			if #xyear < 4 then
				xyear = tonumber("20"..tostring(xyear))
			end
			local convertedT = os.time({year = xyear, month = xmonth, day = xday+blah})
			local nowTime = os.time()
			if nowTime > convertedT and members[name].temptime ~= 0 then
				members[name].hidetype = "delete"
				members:save('all')
				windower.send_ipc_message("blist reload members")
			end
			
			if members[name].hidetype == "delete" then
				modified = original
			elseif members[name].hidetype == "hard" or #members[name].hidetype == 0 then
				modified = ''
			elseif members[name].hidetype == "soft" then
				modified = _addon.name.." blocked message from "..string.ucfirst(name).."."
			elseif members[name].hidetype == "muted" then
				modified = string.color(original:trim(),settings.mutedcolor)
			else
				members[name].hidetype = "hard"
				members:save('all')
				windower.send_ipc_message("blist reload members")
				modified = ''
			end
		end
		return modified
	end
end)
