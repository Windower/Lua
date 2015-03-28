-- 
-- AutoLockstyle v1.0.1
-- 
-- Copyright ©2015, Bangerang
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
-- * Neither the name of autolock nor the names of its contributors may be 
--   used to endorse or promote products derived from this software without
--   specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL Bangerang BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
--
-- Automatically equips a gear set and uses the /lockstyle command when changing zone.
-- For full functionality, this addon requires the use of the Gearswap addon.
--
-- To use a predefined lockstyle set, create a gear set titled sets.lockstyle 
-- in your job.lua file. Alternatively, change the lock_set setting to the desired
-- set. Be warned that this set name will be used across all job.lua files, as
-- autolock does not currently support lockstyle sets on a per job basis.
--
-- Ex:
--         sets.lockstyle = {
--            head="Raider's Bonnet +2",
--            body="Raider's Vest +2",hands="Raider's Armlets +2",
--            legs="Raider's Culottes +2",feet="Raider's Poulaines +2"}
--
--
    
_addon.name = "AutoLockstyle"
_addon.author = "Bangerang"
_addon.version = "1.0.1"
_addon.commands = {'al', 'autolockstyle'}
_addon.language = 'english'

require('luau')
config = require('config')

defaults = {}
defaults.lock_set = 'sets.lockstyle'
defaults.zone_delay = 10
defaults.key_bind = '^x'
defaults.auto_lock = true
defaults.ignore_zones = S{
    "Ru'Lude Gardens", "Upper Jeuno", "Lower Jeuno", "Port Jeuno", "Port Windurst", "Windurst Waters", "Windurst Woods", "Windurst Walls",
    "Heavens Tower", "Port San d'Oria", "Northern San d'Oria", "Southern San d'Oria", "Chateau d'Oraguille", "Port Bastok", "Bastok Markets",
    "Bastok Mines", "Metalworks", "Aht Urhgan Whitegate", "Tavnazian Safehold", "Nashmau", "Selbina", "Mhaura", "Norg", "Rabao", "Kazham",
    "Eastern Adoulin", "Western Adoulin", "Leafallia", "Celennia Memorial Library", "Mog Garden"}

settings = config.load(defaults)

tokens = {}
tokens.lock_style = false

windower.send_command('bind %s al':format(settings.key_bind))
windower.send_command('input /lockstyle off')

function al_output(msg)
    prefix = 'AutoLockstyle: '
    windower.add_to_chat(209, prefix..msg)
end

-- Accepts a boolean value and returns an appropriate string value. i.e. true -> 'on'
function bool_to_str(bool)
    return bool and 'on' or 'off'
end

function command_lockstyle()
    if tokens.lock_style then
        windower.send_command('input /lockstyle off')
        coroutine.sleep(1)
    end
    windower.send_command('gs equip %s;wait 1.5;input /lockstyle on':format(settings.lock_set))
    tokens.lock_style = true
    coroutine.sleep(3)
    windower.send_command('gs c update')
end

function auto_lockstyle()
    if settings.ignore_zones:contains(res.zones[windower.ffxi.get_info().zone].english) then
        tokens.lock_style = false
        return false
    end
    if settings.auto_lock then
        coroutine.sleep(settings.zone_delay)
        if tokens.lock_style then
            windower.send_command('input /lockstyle off')
            coroutine.sleep(1)
        end
        windower.send_command('gs equip %s;wait 1.5;input /lockstyle on':format(settings.lock_set))
        tokens.lock_style = true
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
        al_output(_addon.name..' v'.._addon.version..". Author: ".._addon.author)
        al_output('//al [options]')
        al_output('   help : display this help text.')
        al_output('   auto [ on | off ] : toggle auto lockstyle upon zone change.  (%s)':format(bool_to_str(settings.auto_lock)))
        al_output('   lockset [gearset] : sets name of lockstyle gear set.  (%s)':format(settings.lock_set))
        al_output('   delay [seconds] : sets delay when zoning.  (%.1fs)':format(settings.zone_delay))
        al_output('   bind [keybind] : sets keybind.  (%s)':format(settings.key_bind))
        al_output('     Examples: //al bind ^a, //al bind !f3, //al bind @=')
        al_output('        ^a is Ctrl+A, !f3 is Alt+F3, @= is Winkey+=')
    elseif command == 'auto' then
        if params[1] == 'on' then
            settings.autolock = true
            config.save(settings)
            al_output('Autolock on zone is now %s.':format(bool_to_str(settings.auto_lock)))
        elseif params[1] == 'off' then
            settings.autolock = false
            al_output('Autolock on zone is now %s.':format(bool_to_str(settings.auto_lock)))
        else
            error('Invalid argument. Usage: //al auto [ on | off ]')
        end
    elseif command == 'bind' then
        if params[1] then
            windower.send_command('unbind %s':format(settings.key_bind))
            settings.key_bind = params[1]
            config.save(settings)
            windower.send_command('bind %s al':format(settings.key_bind))
            al_output('Toggle key_bind set to: %s':format(settings.key_bind))
        else
            error('Missing argument. Example: //al bind @= (^ for Ctrl, ! for Alt, @ for Winkey)')
        end
    elseif command == 'delay' then
        if tonumber(params[1]) ~= nil then
            settings.zone_delay = tonumber(params[1])
            config.save(settings)
            al_output('Zone delay set to %.1fs.':format(math.floor(settings.zone_delay)))
        else
            error('Invalid argument: Number of seconds. Usage: //al delay 10')
        end
    elseif command == 'lockset' then
        if params[1] then
            settings.lock_set = params[1]
            config.save(settings)
            al_output('Lockstyle set is now: &s':format(settings.lock_set))
        else
            error('Missing argument. Example: //al lockset sets.lockstyle')
        end
    else
        command_lockstyle()
    end
end)

windower.register_event('unload', function()
    windower.send_command('unbind %s':format(settings.key_bind))
end)
