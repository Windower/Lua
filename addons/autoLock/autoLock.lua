-- 
-- autoLock v1.0
-- 
-- Copyright ©2015, bangerang
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
-- * Redistributions of source code must retain the above copyright
--   notice, this list of conditions and the following disclaimer.
-- * Redistributions in binary form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
-- * Neither the name of autoLock nor the names of its contributors may be 
--   used to endorse or promote products derived from this software without
--   specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL ReaperX BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
--
-- Automatically equips a gear set and uses the /lockstyle command when leaving town.
-- This addon requires the Gearswap addon.
--
-- To use this addon create a gear set titled sets.lockstyle in your job.lua file.
-- Ex:
-- 		sets.lockstyle = {
--			head="Raider's Bonnet +2",
--			body="Raider's Vest +2",hands="Raider's Armlets +2",
--			legs="Raider's Culottes +2",feet="Raider's Poulaines +2"}
--
--

_addon.name = "autoLock"
_addon.author = "bangerang"
_addon.version = "1.0"
_addon.commands = {'al', 'autolock'}
_addon.language = 'english'

require('luau')
config = require('config')

defaults = {}
defaults.zoneDelay = 10
defaults.keyBind = '^x'
defaults.autoLock = true
defaults.ignoreZones = S{
    "Ru'Lude Gardens", "Upper Jeuno", "Lower Jeuno", "Port Jeuno", "Port Windurst", "Windurst Waters", "Windurst Woods", "Windurst Walls",
    "Heavens Tower", "Port San d'Oria", "Northern San d'Oria", "Southern San d'Oria", "Chateau d'Oraguille", "Port Bastok", "Bastok Markets",
    "Bastok Mines", "Metalworks", "Aht Urhgan Whitegate", "Tavnazian Safehold", "Nashmau", "Selbina", "Mhaura", "Norg", "Rabao", "Kazham",
    "Eastern Adoulin", "Western Adoulin", "Leafallia", "Celennia Memorial Library", "Mog Garden"}

settings = config.load(defaults)

tokens = {}
tokens.lockstyle = false

windower.send_command('bind %s al':format(settings.keyBind))
windower.send_command('input /lockstyle off')

function al_output(msg)
    prefix = 'autoLock: '
    windower.add_to_chat(209, prefix..msg)
end

-- Accepts a boolean value and returns an appropriate string value. i.e. true -> 'on'
function booltostr(bool)
    local str = ''
    if bool then
        str = 'on'
        return str
    elseif not bool then
        str = 'off'
        return str
    else
        print('Boolean to string: unknown error.')
    end
end

function command_lockstyle()
	if tokens.lockstyle then
		windower.send_command('input /lockstyle off')
		coroutine.sleep(1)
	end
	windower.send_command('gs equip sets.lockstyle;wait 1.5;input /lockstyle on')
	tokens.lockstyle = true
	coroutine.sleep(3)
	windower.send_command('gs c update')
end

function auto_lockstyle()
	if settings.ignoreZones:contains(res.zones[windower.ffxi.get_info().zone].english) then
		tokens.lockstyle = false
		return false
	end
	if settings.autoLock then
		coroutine.sleep(settings.zoneDelay)
		if tokens.lockstyle then
			windower.send_command('input /lockstyle off')
			coroutine.sleep(1)
		end
		windower.send_command('gs equip sets.lockstyle;wait 1.5;input /lockstyle on')
		tokens.lockstyle = true
		coroutine.sleep(3)
		windower.send_command('gs c update')
	end
	return true
end

windower.register_event('zone change', auto_lockstyle)
windower.register_event('addon command', function(command, ...)
    command = command and command:lower()
    params = L{...}:map(string.lower)

    if command == 'help' or command == 'h' then
		al_output('autoLock v'.._addon.version..". Author: ".._addon.author)
		al_output('//al [options]')
		al_output('   help : display this help text')
		al_output('   autolock [ on | off ] : toggle auto lockstyle upon zone change')
		al_output('   delay [seconds] : sets delay when zoning.')
		al_output('   bind [keybind] : sets keybind for addon.')
		al_output('     Examples: ^a is Ctrl+A, !f3 is Alt+F3, @= is Winkey+=')
		al_output('        //al bind ^a, //al bind !f3, //al bind @=')
	elseif command == 'autolock' then
		if params[1] == 'on' then
			settings.autoLock = true
			al_output('Autolock on zone is now %s.':format(booltostr(settings.autoLock)))
		elseif params[1] == 'off' then
			settings.autoLock = false
			al_output('Autolock on zone is now %s.':format(booltostr(settings.autoLock)))
		else
			al_output('Invalid argument. Usage: //al autolock [ on | off ]')
		end
	elseif command == 'bind' then
		if params[1] then
			windower.send_command('unbind %s':format(settings.keyBind))
			settings.keyBind = params[1]
			windower.send_command('bind %s al':format(settings.keyBind))
			al_output('Toggle keybind set to: %s':format(settings.keyBind))
		else
			al_output('Missing argument. Example: //al bind @= (^ for Ctrl,! for Alt, @ for Winkey)')
		end
	elseif command == 'delay' then
		if tonumber(params[1]) ~= nil then
			settings.zoneDelay = tonumber(params[1])
			al_output('Zone delay set to %fs':format(settings.zoneDelay))
		else
			al_output('Invalid argument: Number of seconds. Usage: //al delay 10')
		end
	else
		command_lockstyle()
	end
end)

windower.register_event('unload', function()
	windower.send_command('unbind %s':format(settings.keyBind))
end)
