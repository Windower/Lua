--Copyright © 2013, Banggugyangu
--Copyright © 2017, Banggugyangu & Harrison Pickett
--All rights reserved.
--
--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:
--
--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of MacroChanger nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.
--
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

_addon.name = 'MacroChanger'
_addon.author = 'Banggugyangu'
_addon.version = '1.0.0.2r0'
_addon.commands = {'mc','macrochanger'}

config = require('config')
res = require('resources')
require('strings')

function addon_command (...)
    local args = {...}
    if args[1]:lower() == 'disableall' then
        if args[2]:lower() == 'on' then
            settings.globaldisable = 1
            windower.add_to_chat(17, 'All automated macro switching disabled.')
        elseif args[2]:lower() == 'off' then
            settings.globaldisable = 0
            windower.add_to_chat(17, 'Automated macro switching enabled.')
        end
     elseif args[1]:lower() == 'help' then
         windower.add_to_chat(17, 'MacroChanger Commands:')
         windower.add_to_chat(17, 'disableall [on|off]')
         windower.add_to_chat(17, '     on - Disables all automated macro switching')
         windower.add_to_chat(17, '     off - Enables all automated macro switching not disabled individually')
         windower.add_to_chat(17, '     Resets to what is stored in settings upon unloading of addon.    To Permanently change, please change the option in the settings file.')
     end
end

function job_change (main,_,sub,_)
    if settings.globaldisable == 0 then
        local job
        local mjob = res.jobs[main].english_short
        local sjob = res.jobs[sub].english_short
        if mjob and sjob and settings.macros[(mjob..'_'..sjob):lower()] then
            job = mjob..'_'..sjob
        elseif mjob and settings.macros[(mjob):lower()] then
            job = mjob
        else
            if sjob then job = mjob..' or '..mjob..'_'..sjob else job = mjob end
            windower.add_to_chat(17, '         No Auto Macro Settings Available for '..job..'.')
            return
        end
        if ((book == 'disabled') or (page == 'disabled')) then
            windower.add_to_chat(17, '         Auto Macro Switching Disabled for ' .. job ..'.')
        else
            local page = settings.macros[(job):lower()].page
            local book = settings.macros[(job):lower()].book
            windower.add_to_chat(17, '         Changing macros to Book: ' .. book .. ' and Page: ' .. page .. '. Job Changed to ' .. job)
            windower.send_command('input /macro book '..book..';wait 0.2;input /macro set '..page..';')
        end
    else
        windower.add_to_chat(17, '         Auto Macro Switching Disabled for All Jobs.')
    end
end

function login (name)
    local defaults = {
        character = '',
        globaldisable = 0,
        macros = {
            war = {book = 1, page = 1},
        },
    }
    settings = config.load(defaults)
    if name then
        coroutine.sleep(2)
        job_change()
    end
end

settings = {}
windower.register_event('addon command', addon_command)
windower.register_event('job change', job_change)
windower.register_event('login', login)
windower.register_event('load', login)
