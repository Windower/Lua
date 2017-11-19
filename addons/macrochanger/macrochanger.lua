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
--DISCLAIMED. IN NO EVENT SHALL BANGGUGYANGU OR HARRISON PICKETT BE LIABLE FOR
--ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
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
require('options')
res = require('resources')
require('strings')

function addon_command (...)
    local args = {...}
    local i = 1
    while i < #args + 1 do
        if args[i] == 'help' then
            options.help()
			return
        elseif options[args[i]] then
            options[args[i]](args[i+1])
            i = i + 2
        else
            windower.add_to_chat(17, 'Unknown parameter: '..args[i])
            options.help()
            return
        end
    end
end

function job_change (main,_,subj,_)
    if settings.default then
        options.notice() 
    elseif settings.enabled then
        local job
        local mjob = res.jobs[main].english_short
        local sjob = res.jobs[subj].english_short
        if mjob and sjob and settings.macros[(mjob..'_'..sjob):lower()] then
            job = mjob..'_'..sjob
        elseif mjob and settings.macros[(mjob):lower()] then
            job = mjob
        else
            if sjob then job = mjob..' or '..mjob..'_'..sjob else job = mjob end
            windower.add_to_chat(17, 'No Auto Macro Settings Available for '..job..'.')
            return
        end
        if ((book == 'disabled') or (page == 'disabled')) then
            windower.add_to_chat(17, 'Auto Macro Switching Disabled for ' .. job ..'.')
        else
            local page = settings.macros[(job):lower()].page
            local book = settings.macros[(job):lower()].book
            windower.add_to_chat(17, 'Changing macros to Book: ' .. book .. ' and Page: ' .. page .. '. Job Changed to ' .. job)
            windower.send_command('input /macro book '..book..';wait 0.2;input /macro set '..page..';')
        end
    else
        windower.add_to_chat(17, 'Auto Macro Switching Disabled for All Jobs.')
    end
end


defaults = {
    default = true,
    enabled = false
}
settings = config.load(defaults)

windower.register_event('addon command', addon_command)
windower.register_event('job change', job_change)
