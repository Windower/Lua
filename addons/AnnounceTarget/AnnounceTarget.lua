-- Copyright © 2015, JoshK6656, Sechs
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of AdherentBuffs nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL JoshK6656, Sechs BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
config = require ('config')
require ('logger')
 
_addon.name     = 'AnnounceTarget'
_addon.author   = 'JoshK6656, Sechs'
_addon.version  = '1.2'
_addon.commands = {'announcetarget','at'}
 
defaults = T{}
 
defaults.AnnounceMode = 'party' --this can be say/party/linkshell/linkshell2/shout/echo/s/p/l/l2/sh
defaults.AutoAnnounce = false
 
settings = config.load(defaults)
 
adherent_maps = {['Steadfast Adherent']="PLD, DEF+", ['Furtive Adherent']="WHM, MDB+", ['Occult Adherent']="WAR, EVA+",
		['Fleet Adherent']="WAR, Haste+", ['Brawny Adherent']="DRK, ATK+", ['Martial Adherent']="DRK,Regain+",
		['Honed Adherent']="RDM, Fast Cast+", ['Insidious Adherent']="RDM, MEVA+", ['Hexbreaking Adherent']="BLM, MAB+"}
chatmodes = S{'say','party','linkshell','linkshell2','shout','echo','s','p','l','l2','sh'}
false_values = S{'false','off','f','0'}
true_values = S{'true','on','t','1'}
moblist = S{}
		
windower.register_event('addon command', function (command,...)
	command = command and command:lower() or 'help'
	local args = T{...}
	if command == 'reload' then
		windower.send_command('lua reload AnnounceTarget')
	elseif command == 'unload' then
		windower.send_command('lua unload AnnounceTarget')
	elseif command == 'chatmode' or command == 'cm' then
		if args[1] ~= nil and chatmodes:contains(args[1]) then
			windower.add_to_chat(038,' ***** Chat Mode changed to "'..args[1]..'" *****')
			settings.AnnounceMode = args[1]
			config.save(settings)
		else
			windower.add_to_chat(038,' ***** That is not a valid chat mode *****')
		end
	elseif command == 'announce' or command == 'a' then
		announce(1)
	elseif command == 'autoannounce' or command == 'aa' then
		local value = args[1] and args[1]:lower() or nil
		if not value then
			settings.AutoAnnounce = not settings.AutoAnnounce
		elseif false_values:contains(value) or true_values:contains(value) then
			settings.AutoAnnounce = not false_values:contains(args[1]:lower())
		else
			windower.add_to_chat(038,' ***** "'..args[1]..'" is not a valid setting for AutoAnnounce *****')
			return
		end
		windower.add_to_chat(038,' ***** AutoAnnounce changed to "'..tostring(settings.AutoAnnounce)..'" *****')
		config.save(settings)
	elseif command == 'clear' or command == 'c' then
		moblist:clear()
	elseif command == 'help' then
		windower.add_to_chat(038,' *** '.._addon.name..' v'.._addon.version..' - Authors: '.._addon.author..' ***')
		windower.add_to_chat(038,' help -> Displays this message')
		windower.add_to_chat(038,' chatmode -> Changes chat output mode. Available settings: say/party/linkshell/linkshell2/shout/echo')
		windower.add_to_chat(038,' autoannounce -> Turns AutoAnnounce on or off. Accepted settings: on/true/false/off')
		windower.add_to_chat(038,' announce -> Manually announces for the current target')
		windower.add_to_chat(038,' clear -> Clears the list of announced mobs during AutoAnnounce mode on')
	end
end)

function announce(mode)
	local mob = windower.ffxi.get_mob_by_target('t')
	if mob ~= nil and adherent_maps[mob.name] then 
		windower.send_command('input /'..settings.AnnounceMode..' '..mob.name..' buff is ==> '..adherent_maps[mob.name]..'')
	elseif mode == 1 then
		windower.add_to_chat(038,' ***** Target is not an Adherent *****')
	end
end

windower.register_event('target change',function(...)
	if settings.AutoAnnounce == true then
		local mob = windower.ffxi.get_mob_by_target('t')
		if mob ~= nil and not moblist:contains(mob.id) then
			announce(0)
			moblist:add(mob.id)
		end
	end
end)

windower.register_event('zone change',function(...)
	moblist:clear()
end)
