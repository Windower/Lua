--Copyright © 2021, Elidyr
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of Autoex nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL Elidyr BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


_addon.name = 'autoex'
_addon.author = 'Elidyr'
_addon.version = '1.20210812'
_addon.command = 'ax'

require('tables')
require('strings')
require('logger')

local player = false
local packets = require('packets')
local res = require('resources')
local files = require('files')
local events = {build={}, registered={}, helpers={}}
local triggers = {hp={}, mp={}}
local color = '50,220,175'
local event_names = {
    'login','logout','chat','time','invite','login','gainbuff','losebuff','day','moon','zone','lvup','lvdown','gainexp','chain','weather','status','examined','noammo','tp','hp','hpp','lowhp','criticalhp','hpmax','hpplt','hppgt','mp','mpp','lowmp','criticalmp','mpmax','mpplt','mppgt'
}

-- XML Parsing.
local parse = function(content)
    local content = content or false
    local events = {}
    local captures = {

        ['header'] = '(<xml version="[%d%.]+">)',
        ['start'] = '<autoexec>',
        ['import'] = '<import>(.*)([.xml])</import>',
        ['event'] = '<register event="([%w%_]+)" silent="([truefalse]+)" runonce="([truefalse]+)">(.*)</register>',
        ['start'] = '</autoexec>',

    }
    if not content then
        return false
    end

    for c in content:it() do
        c = c:gsub('&lt;', '<'):gsub('&gt;', '>')
        
        if c:match(captures['import']) then
            local t = T{c:match(captures['import'])}
            
            if t and t[1] then
                table.insert(events, {name="import", file=t[1]})
            end

        elseif c:match(captures['event']) then
            local t = T{c:match(captures['event'])}

            if t and t[1] and t[2] and t[3] and t[4] then
                table.insert(events, {name=t[1]:lower(), silent=t[2]:lower(), once=t[3]:lower(), command=t[4]:lower()})
            end

        end

    end
    return events

end

-- Simple round funciton.
math.round = function(num)
    if num >= 0 then 
        return math.floor(num+.5)
    else 
        return math.ceil(num-.5)
    end
end

windower.register_event('load', 'login', function(...)
    player = windower.ffxi.get_player()

    -- Build the convert directory and settings directory.
    local convert = files.new('/convert/instructions.lua')
    local settings = files.new(('/settings/%s.lua'):format(player.name))
    if not convert:exists() then
        convert:write('-- COPY ALL YOUR OLD XML FILES THAT YOU WANT TO CONVERT, IN TO THE "CONVERT" FOLDER, AND FOLLOW THE IN GAME HELP.\n-- //ax help\n-- //ax convert <file_name>')

    end

    if not settings:exists() then
        settings:write(('return %s'):format(T({}):tovstring()))

    elseif settings:exists() then
        events.helpers['load'](player.name)
        
    end

end)

windower.register_event('logout', function(...)
    player = false

end)

windower.register_event('addon command', function(...)
    local commands = T{...}
    local command = commands[1] or false

    if command then
        local command = command:lower()

        if command == 'convert' and commands[2] then
            local fname = {}
            for i=2, #commands do
                table.insert(fname, commands[i])
            end
            events.helpers['convert'](table.concat(fname, ' '))

        elseif command == 'migrate' then
            events.helpers['migrate']()

        elseif command == 'load' and commands[2] then
            local fname = {}
            for i=2, #commands do
                table.insert(fname, commands[i])
            end

            events.helpers['clear'](function()
                events.helpers['load'](table.concat(fname, ' '))
            end)

        elseif command == 'r' or command == 'rl' or command == 'reload' then
            windower.send_command('lua r autoex')

        elseif command == 'h' or command == 'help' then
            local help = {
                
                ('\\cs(%s)Addon commands:\\cr'):format('20,255,180'),
                (' %s\\cs(%s)//ax convert <filename>\\cr\\cs(%s): Converts the .XML file in the /convert/ folder to Lua.\\cr'):format('':lpad(' ', 2), '100,200,100', '255,255,255'),
                (' %s\\cs(%s)//ax load <filename>\\cr\\cs(%s): Loads the .lua autoex in the /settings/ folder.\\cr'):format('':lpad(' ', 2), '100,200,100', '255,255,255'),
                (' %s\\cs(%s)//ax migrate\\cr\\cs(%s): Converts the default .XML file from the plugin and saves in to the addon folder.\\cr'):format('':lpad(' ', 2), '100,200,100', '255,255,255'),
                (' %s\\cs(%s)//ax reload\\cr\\cs(%s): Realoads Autoex addon. (Supports "r" & "rl" command)\\cr'):format('':lpad(' ', 2), '100,200,100', '255,255,255'),
                (' %s\\cs(%s)//ax help\\cr\\cs(%s): Displays help in the console. (Supports "h" command)\\cr'):format('':lpad(' ', 2), '100,200,100', '255,255,255'),
                ('\\cs(%s)If your .XML file uses <import>, then all xml files need to be converted prior to loading.\\cr'):format('20,255,180'),

            }
            print(table.concat(help, '\n'))

        elseif command == 'debug' then
            table.print(events.registered)

        end

    end

end)

events.helpers['convert'] = function(filename)
    if not filename then
        return false
    end
    
    local f = files.new(('/convert/%s.xml'):format(filename))
    if f:exists() then
        local n = files.new(('/settings/%s.lua'):format(filename))
        n:write(('return %s'):format(T(parse(f)):tovstring()))

    end

end

events.helpers['migrate'] = function()
    local f = files.new(('../../plugins/AutoExec/%s.xml'):format('AutoExec'))
    if f:exists() then
        local n = files.new(('/settings/%s.lua'):format('autoexec'))
        n:write(('return %s'):format(T(parse(f)):tovstring()))
    
    else
        print("Didn't find file!")

    end

end

events.helpers['load'] = function(filename)
    if not filename then
        return false
    end

    local f = files.new(('/settings/%s.lua'):format(filename))
    if f:exists() then
        local temp = dofile(('%s/settings/%s.lua'):format(windower.addon_path, filename))
        
        if temp then
        
            for i,v in pairs(temp) do
                table.insert(events.build, v)
            end
            events.helpers.build()

        end

    end

end

events.helpers['clear'] = function(callback)
    for _,v in pairs(events.registered) do
        windower.unregister_event(v.id)
    end
    events.build = {}
    triggers = {hp={}, mp={}}

    if callback and type(callback) == 'function' then
        callback()
    end

end

events.helpers['build'] = function()
    local imports = {}

    for _,v in ipairs(events.build) do
        
        if v.name then
            local split = v.name:split('_')
            
            if split[1] then
                local name = split[1]
                    
                if name:match('[%*%?%|]') then

                    for _,event in ipairs(event_names) do
                        
                        if windower.wc_match(event, name) and events.helpers[event] then
                            events.helpers[event](v.name, v.command, v.silent, v.once)

                        end

                    end

                elseif name:lower() ~= 'import' then
                    
                    if events.helpers[name] then
                        events.helpers[name](v.name, v.command, v.silent, v.once)

                    end

                elseif name:lower() == 'import' and v.file then
                    local n = files.new(('/settings/%s.lua'):format(v.file))

                    if n:exists() then
                        local temp = dofile(('%s/settings/%s.lua'):format(windower.addon_path, v.file))
                        
                        for i,v in pairs(temp) do
                            table.insert(imports, v)
                        end

                    end

                end

            end

        end

    end

    if imports and #imports > 0 then

        for _,v in ipairs(imports) do
            
            if v.name then
                local split = v.name:split('_')
                
                if split[1] then
                    local name = split[1]
                        
                    if name:match('[%*%?%|]') then
    
                        for _,event in ipairs(event_names) do
                            
                            if windower.wc_match(event, name) and events.helpers[event] then
                                events.helpers[event](v.name, v.command, v.silent, v.once)
    
                            end
    
                        end
    
                    elseif name:lower() ~= 'import' then
                        
                        if events.helpers[name] then
                            events.helpers[name](v.name, v.command, v.silent, v.once)
    
                        end
    
                    elseif name:lower() == 'import' and v.file then
                        local n = files.new(('/settings/%s.lua'):format(v.file))
    
                        if n:exists() then
                            table.insert(imports, dofile(('%s/settings/%s.lua'):format(windower.addon_path, v.file)))
                        end
    
                    end
    
                end
    
            end
    
        end

    end    

end

events.helpers['login'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local player = split[2]

        events.registered[event] = {event=event, id=windower.register_event('login', function(name)
            local command = command:gsub('{NAME}', name)
            
            if windower.wc_match(name:lower(), player:lower()) then
                windower.send_command(command)
                
                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}
        
        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['logout'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local player = split[2]

        events.registered[event] = {event=event, id=windower.register_event('login', function(name)
            local command = command:gsub('{NAME}', name)

            if windower.wc_match(name:lower(), player:lower()) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['jobchange'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local temp = split[2]:split('/')

        if temp[1] and temp[2] then
            local job = {main=temp[1]:lower(), sub=temp[2]:lower()}
            local jobs = res.jobs

            events.registered[event] = {event=event, id=windower.register_event('job change', function(m_id, m_lv, s_id, s_lv)

                if job and jobs and jobs[m_id] and jobs[s_id] then
                    local command = command:gsub('{MAIN_FULL}', jobs[m_id].en):gsub('{MAIN_SHORT}', jobs[m_id].ens):gsub('{SUB_FULL}', jobs[s_id].en):gsub('{SUB_SHORT}', jobs[s_id].ens):gsub('{MAIN_LV}', m_lv):gsub('{SUB_LV}', s_lv)
                    local l = {main=jobs[m_id].en:lower(), sub=jobs[s_id].en:lower()}
                    local s = {main=jobs[m_id].ens:lower(), sub=jobs[s_id].ens:lower()}

                    if (windower.wc_match(l.main, job.main) or windower.wc_match(s.main, job.main)) and (windower.wc_match(l.sub, job.sub) or windower.wc_match(s.sub, job.sub)) then
                        windower.send_command(command)
                    
                        if once then
                            windower.unregister_event(events.registered[event].id)
                        end

                    end

                end

            end)}

            if not silent then
                print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
            end

        end

    end

end

events.helpers['jobchangefull'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local temp = split[2]:split('/')

        if temp[1] and temp[2] then
            local job = {main=temp[1]:lower(), sub=temp[2]:lower()}
            local jobs = res.jobs

            events.registered[event] = {event=event, id=windower.register_event('job change', function(m_id, m_lv, s_id, s_lv)

                if job and jobs and jobs[m_id] and jobs[s_id] then
                    local command = command:gsub('{MAIN_FULL}', jobs[m_id].en):gsub('{MAIN_SHORT}', jobs[m_id].ens):gsub('{SUB_FULL}', jobs[s_id].en):gsub('{SUB_SHORT}', jobs[s_id].ens):gsub('{MAIN_LV}', m_lv):gsub('{SUB_LV}', s_lv)
                    local l = {main=string.format('%s%s', jobs[m_id].en:lower(), m_lv), sub=string.format('%s%s', jobs[s_id].en:lower(), s_lv)}
                    local s = {main=string.format('%s%s', jobs[m_id].ens:lower(), m_lv), sub=string.format('%s%s', jobs[s_id].ens:lower(), s_lv)}

                    if (windower.wc_match(l.main, job.main) or windower.wc_match(s.main, job.main)) and (windower.wc_match(l.sub, job.sub) or windower.wc_match(s.sub, job.sub)) then
                        windower.send_command(command)
                    
                        if once then
                            windower.unregister_event(events.registered[event].id)
                        end

                    end

                end

            end)}

            if not silent then
                print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
            end

        end

    end

end

events.helpers['chat'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')
    
    if event and command and split[2] and split[3] and split[4] then
        local m = split[2]
        local player = split[3]
        local find = split[4]
        
        events.registered[event] = {event=event, id=windower.register_event('chat message', function(message, sender, mode)
            local chats = res.chat
            
            if m and player and find and chats[mode] and windower.wc_match(chats[mode].en:lower(), m:lower()) then
                local command = command:gsub('{SENDER}', sender):gsub('{MODE}', chats[mode].en):gsub('{MATCH}', find)

                if windower.wc_match(sender:lower(), player:lower()) and windower.wc_match(message:lower(), find:lower()) then
                    windower.send_command(command)

                    if once then
                        windower.unregister_event(events.registered[event].id)
                    end

                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['time'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local temp = split[2]:split('.')

        if temp and temp[1] and temp[2] then
            local time = {h=tonumber(temp[1]), m=tonumber(temp[2])}

            events.registered[event] = {event=event, id=windower.register_event('time change', function(new, old)
                local n_hour = tonumber(math.floor(new/60))
                local n_minute = tonumber(math.round(((new/60)-n_hour)*60))
                local o_hour = tonumber(math.floor(old/60))
                local o_minute = tonumber(math.round(((old/60)-o_hour)*60))
                local command = command:gsub('{NEW_HOUR}', n_hour):gsub('{NEW_MINUTE}', n_minute):gsub('{OLD_HOUR}', o_hour):gsub('{OLD_MINUTE}', o_minute)

                if windower.wc_match(n_hour, time.h) and windower.wc_match(n_minute, time.m) then
                    windower.send_command(command)

                    if once then
                        windower.unregister_event(events.registered[event].id)
                    end

                end

            end)}

            if not silent then
                print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
            end

        end

    end

end

events.helpers['invite'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local player = split[2]

        events.registered[event] = {event=event, id=windower.register_event('party invite', function(sender)
            local command = command:gsub('{SENDER}', sender)

            if player and sender and windower.wc_match(sender:lower(), player:lower()) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['gainbuff'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local buff = split[2]
        
        events.registered[event] = {event=event, id=windower.register_event('gain buff', function(id)
            local b = res.buffs[id]
            
            if buff and b and b.en and windower.wc_match((b.en):lower(), (buff):lower()) then
                local command = command:gsub('{ID}', b.id):gsub('{NAME}', b.en)

                if command then
                    windower.send_command(command)

                    if once then
                        windower.unregister_event(events.registered[event].id)
                    end

                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['losebuff'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local buff = split[2]
        
        events.registered[event] = {event=event, id=windower.register_event('lose buff', function(id)
            local buffs = res.buffs
            
            if buff and buffs and buffs[id] then
                local command = command:gsub('{ID}', buffs[id].id):gsub('{NAME}', buffs[id].en)

                if windower.wc_match(buffs[id].en:lower(), buff:lower()) then
                    windower.send_command(command)

                    if once then
                        windower.unregister_event(events.registered[event].id)
                    end

                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['day'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local day = split[2]

        events.registered[event] = {event=event, id=windower.register_event('day change', function(new, old)
            local days = res.days

            if day and days and days[new] and days[old] then
                local command = command:gsub('{NEW}', days[new].en):gsub('{OLD}', days[old].en)

                if windower.wc_match(days[new].en:lower(), day:lower()) then
                    windower.send_command(command)

                    if once then
                        windower.unregister_event(events.registered[event].id)
                    end

                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['moon'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local phase = split[2]
        local moon = windower.ffxi.get_info().moon_phase

        events.registered[event] = {event=event, id=windower.register_event('moon change', function(new, old)
            local moons = res.moon_phases

            if phase and moon and new and old and moons[new] and moons[old] then
                local command = command:gsub('{NEW}', moons[new].en):gsub('{OLD}', moons[old].en)

                if windower.wc_match(moons[new].en:lower(), phase:lower()) then
                    windower.send_command(command)

                    if once then
                        windower.unregister_event(events.registered[event].id)
                    end

                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['moonpct'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local percent = split[2]
        local moon = windower.ffxi.get_info().moon

        events.registered[event] = {event=event, id=windower.register_event('moon change', function(_)
            local moons = res.moon_phases

            if percent and moon then
                local command = command:gsub('{PERCENT}', moon)

                if windower.wc_match(moon, percent) then
                    windower.send_command(command)

                    if once then
                        windower.unregister_event(events.registered[event].id)
                    end

                end

            end
            

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['zone'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local zone  = split[2]
        local zones = res.zones

        events.registered[event] = {event=event, id=windower.register_event('zone change', function(new, old)
            
            if zones and zone and zones[new] and zones[old] then
                local command = command:gsub('{NEW}', zones[new].en):gsub('{OLD}', zones[old].en)

                if windower.wc_match(zones[new].en:lower(), zone:lower()) then
                    windower.send_command(command)

                    if once then
                        windower.unregister_event(events.registered[event].id)
                    end

                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['lvup'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local new = split[2]

        events.registered[event] = {event=event, id=windower.register_event('level up', function(level)
            local command = command:gsub('{LEVEL}', level)

            if new and level and windower.wc_match(level, new) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['lvdown'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local new = split[2]

        events.registered[event] = {event=event, id=windower.register_event('level down', function(level)
            local command = command:gsub('{LEVEL}', level)

            if new and level and windower.wc_match(level, new) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['gainexp'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local xp = split[2]

        events.registered[event] = {event=event, id=windower.register_event('gain experience', function(amount)
            local command = command:gsub('{XP}', amount)

            if xp and amount and windower.wc_match(amount, xp) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['chain'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local number = split[2]

        events.registered[event] = {event=event, id=windower.register_event('gain experience', function(amount, chain)
            local command = command:gsub('{XP}', amount):gsub('{CHAIN}', chain)

            if number and chain and windower.wc_match(chain, number) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['weather'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local weather = split[2]

        events.registered[event] = {event=event, id=windower.register_event('weather change', function(id)
            local weathers = res.weather

            if weather and id and weathers[id] then
                local command = command:gsub('{WEATHER}', weathers[id].en)

                if windower.wc_match(weathers[id].en:lower(), weather:lower()) then
                    windower.send_command(command)

                    if once then
                        windower.unregister_event(events.registered[event].id)
                    end

                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['status'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local status = split[2]

        events.registered[event] = {event=event, id=windower.register_event('status change', function(new, old)
            local statuses = res.statuses

            if status and statuses and new and old and statuses[new] and statuses[old] then
                local command = command:gsub('{NEW}', statuses[new].en):gsub('{OLD}', statuses[old].en)

                if windower.wc_match(statuses[new].en:lower(), status) then
                    windower.send_command(command)

                    if once then
                        windower.unregister_event(events.registered[event].id)
                    end

                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['examined'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local player = split[2]

        events.registered[event] = {event=event, id=windower.register_event('examined', function(name)
            local command = command:gsub('{PLAYER}', name)

            if player and name and windower.wc_match(name:lower(), player:lower()) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['noammo'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false

    if event and command then

        events.registered[event] = {event=event, id=windower.register_event('outgoing chunk', function(id, original)

            if id == 0x050 then
                local packed = packets.parse('outgoing', original)
                
                if packed['Equip Slot'] == 3 and packed['Item Index'] == 0 then    
                    windower.send_command(command)

                    if once then
                        windower.unregister_event(events.registered[event].id)
                    end

                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['tp'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local percent = split[2]

        events.registered[event] = {event=event, id=windower.register_event('tp change', function(new, old)
            local command = command:gsub('{NEW}', new):gsub('{OLD}', old)

            if percent and new and windower.wc_match(new, percent) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['unload'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command then

        events.registered[event] = {event=event, id=windower.register_event('unload', function()
            windower.send_command(command)

            if once then
                windower.unregister_event(events.registered[event].id)
            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['hp'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local hp = split[2]

        events.registered[event] = {event=event, id=windower.register_event('hp change', function(new, old)
            local command = command:gsub('{NEW}', new):gsub('{OLD}', old)
            
            if hp and new and windower.wc_match(new, hp) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['hpp'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local hpp = split[2]

        events.registered[event] = {event=event, id=windower.register_event('hpp change', function(new, old)
            local command = command:gsub('{NEW}', new):gsub('{OLD}', old)
            
            if hpp and new and old and windower.wc_match(new, hpp) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['lowhp'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command then

        events.registered[event] = {event=event, id=windower.register_event('hpp change', function(new, old)
            local command = command:gsub('{NEW}', new):gsub('{OLD}', old)
            
            if new and old and old >= 40 and new < 20 then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['criticalhp'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command then

        events.registered[event] = {event=event, id=windower.register_event('hpp change', function(new, old)
            local command = command:gsub('{NEW}', new):gsub('{OLD}', old)
            
            if new and old and old >= 20 and new < 5 then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['hpmax'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local hp = split[2]

        events.registered[event] = {event=event, id=windower.register_event('hp change', function(new, old)
            local command = command:gsub('{NEW}', new):gsub('{OLD}', old)
            
            if hp and new and old and windower.wc_match(windower.ffxi.get_player()['vitals'].max_hp, hp) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['mp'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local mp = split[2]

        events.registered[event] = {event=event, id=windower.register_event('mp change', function(new, old)
            local command = command:gsub('{NEW}', new):gsub('{OLD}', old)
            
            if mp and new and windower.wc_match(new, mp) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['mpp'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local hpp = split[2]

        events.registered[event] = {event=event, id=windower.register_event('mpp change', function(new, old)
            local command = command:gsub('{NEW}', new):gsub('{OLD}', old)
            
            if mpp and new and old and windower.wc_match(new, mpp) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['lowmp'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command then

        events.registered[event] = {event=event, id=windower.register_event('mpp change', function(new, old)
            local command = command:gsub('{NEW}', new):gsub('{OLD}', old)
            
            if new and old and old >= 40 and new < 20 then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['criticalmp'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command then

        events.registered[event] = {event=event, id=windower.register_event('mpp change', function(new, old)
            local command = command:gsub('{NEW}', new):gsub('{OLD}', old)
            
            if new and old and old >= 20 and new < 5 then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['mpmax'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command and split[2] then
        local mp = split[2]

        events.registered[event] = {event=event, id=windower.register_event('mp change', function(new, old)
            local command = command:gsub('{NEW}', new):gsub('{OLD}', old)
            
            if mp and new and old and windower.wc_match(windower.ffxi.get_player()['vitals'].max_mp, mp) then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['hpplt76'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command then

        events.registered[event] = {event=event, id=windower.register_event('hpp change', function(new)
            
            if new and new < 76 then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['hppgt75'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command then

        events.registered[event] = {event=event, id=windower.register_event('hpp change', function(new)
            
            if new and new > 75 then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['mpplt50'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command then

        events.registered[event] = {event=event, id=windower.register_event('mpp change', function(new)
            
            if new and new < 50 then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end

events.helpers['mppgt49'] = function(event, command, silent, once)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local split = event:split('_')

    if event and command then

        events.registered[event] = {event=event, id=windower.register_event('mpp change', function(new)
            
            if new and new > 49 then
                windower.send_command(command)

                if once then
                    windower.unregister_event(events.registered[event].id)
                end

            end

        end)}

        if not silent then
            print(('%s registered! Command: <%s> [ Once: %s ]'):format(event:upper(), command, tostring(once)))
        end

    end

end
