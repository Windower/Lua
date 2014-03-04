--Copyright (c) 2014, Sebyg666
--All rights reserved.
 
--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:
 
--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.
 
--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
_addon.name = 'SubTarget'
_addon.version = '1.0'
_addon.author = 'Sebyg666'
_addon.commands = {'SubTarget','STa'}
 
require('tables')
require('logger')
require('strings')

 
toggle = false
 
windower.register_event('addon command', function(command, ...)
    command = command or 'help'
    
    if command == 'help' then
        print(' The correct functionality is:')
        print(' Command "GO":')
        print('     subtarget|sta go mule_name spell_name')
        print('      - Main usage.')
        print('       - create an ingame macro with 2 lines')
        print('              - line 1: /target <stal>')
        print('              - line 2: /con sta go mule_name spell_name')
        print('       - This sends your mule the spell + the target selected from <stal>') 
        print(' Command "TOGGLE":')
        print('       subtarget|sta toggle')
        print('       - turns on|off ingame text verification for debugging.')

 
    elseif command == 'go' then
        local name
        local lastst = windower.ffxi.get_mob_by_target('lastst')
        if not lastst then
                name = L{...}[-1]
                print('Last sub target does not exist.')
                print('Setting last sub to the recipient of the send command.')
        else    
            name = lastst.name
        end
        if toggle then
            log('Command to send-> "send ' .. table.concat({...}, ' ') .. ' ' .. name ..'".')
        end
        windower.send_command('send ' .. table.concat({...}, ' ') .. ' ' .. name)
 
    elseif command == 'toggle' then
        toggle = not toggle
        log('Text now ' .. (toggle and 'on' or 'off'))
 
    end
end)