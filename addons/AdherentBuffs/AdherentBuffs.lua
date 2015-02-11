-- Copyright © 2015, Mafai, Sechs
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
-- DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

config = require ('config')

_addon.name     = 'AdherentBuffs'
_addon.author   = 'Mafai, Sechs'
_addon.version  = '1.03'
_addon.commands = {'adherentbuffs','ab'}

defaults = T{}

--this can be say / party / linkshell / linkshell 2 / shout / s / p / l / l2 / sh
defaults.announcemode = 'party'

settings = config.load(defaults)

adherent_maps = {['Steadfast Adherent']="PLD, DEF+", ['Furtive Adherent']="WHM, MDB+", ['Occult Adherent']="WAR, EVA+",
		['Fleet Adherent']="WAR, Haste+", ['Brawny Adherent']="DRK, ATK+", ['Martial Adherent']="DRK,Regain+",
		['Honed Adherent']="RDM, Fast Cast+", ['Insidious Adherent']="RDM, MEVA+", ['Hexbreaking Adherent']="BLM, MAB+", ['Sechs']="Sechs is a sexy Galka"}

chatmodes = S{'say','party','linkshell','linkshell2','shout','s','p','l','l2','sh'}
		
windower.register_event('addon command', function (command,...)
	command = command and command:lower() or 'help'
	local args = T{...}
	if command == 'reload' then
		windower.send_command('lua unload AdherentBuffs; lua load AdherentBuffs')
	elseif command == 'unload' then
		windower.send_command('lua unload AdherentBuffs')
	elseif command == 'chatmode' or command == 'cm' then
		if chatmodes:contains(args[1]) and args[1] ~= nil then
			windower.add_to_chat(053,' ***** Chat Mode Changed to "'..args[1]..'" *****')
			settings.announcemode = args[1]
			config.save(settings)
		else
			windower.add_to_chat(053,' ***** That is not a valid chat mode *****')
		end
	elseif command == 'announce' or 'a' then
		local mob = windower.ffxi.get_mob_by_target('t')
		if mob ~= nil and adherent_maps[mob.name] then 
			windower.send_command('input /'..settings.announcemode..' '..name..' buff is ==> '..adherent_maps[name]..'')
		else
			windower.add_to_chat(053,' ***** Target is not an Adherent *****')
		end
	end
end)
