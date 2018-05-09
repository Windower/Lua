--[[
Copyright © 2018 Iminiillusions of Asura (Formerly of Quetzalcoatl).
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Skillup nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Iminiillusions BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]



_addon.name = 'skillup'
_addon.author = 'Iminiillusions of Asura (Formerly of Quetzalcoatl)'
_addon.version = '1.0.1'
_addon.commands = {'skillup','su','skill'}


require('chat')

delay = 6.5  -- how much delay in between spells

spell_list = T{ --What spells each type of skillup uses
	['healing'] = {
		'Cure', 
		'Cure II'
		},
	['enhancing'] = {
		'Protect',
		'Protect II'
		},
	['blu'] = {
		'Pollen',
		'Wild Carrot'
		},
	['geo'] = {
		'Indi-Poison',
		'Indi-Voidance',
		}
	['brd'] = {
		"Knight's Minne",
		'Army Paeon',
		},
	['nin'] = {
		'Utsusemi: Ichi',
		'Utsusemi: Ni',
		},
	
}


continue = false

windower.register_event('addon command', function(command, skill)
		if command == 'help' then
			display_help()
		elseif command == 'stop' then
			continue = false
		elseif command == 'start' then
			continue = true
			skill_up(skill)
		end
end)

function skill_up(skill) --The logic to actually start the skillup
	while continue do 
		for i,v, spell in pairs(spell_list[skill]) do
			windower.send_command('input /ma '..v..' <me>')
			coroutine.sleep(delay)
		end
	end
end

function display_help()
	windower.add_to_chat(7, 'SkillUp v. 1.0.1 by Iminiillusions of Asura (Formerly of Quetzalcoatl)')
	windower.add_to_chat(7, 'Usage: //skillup start healing | enhancing | blu | geo| brd | nin')
	windower.add_to_chat(7, 'To Stop: //skillup stop')
	windower.add_to_chat(7, 'Command alias: /sc')
end