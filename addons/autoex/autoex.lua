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
_addon.version = '1.20210814'
_addon.command = 'ax'

require('tables')
require('strings')
require('logger')

local player = false
local packets = require('packets')
local res = require('resources')
local files = require('files')
local events = {build={}, registered={}, helpers={}, logic={}}
local triggers = {hp={}, mp={}}
local map = {
    ['load']='load',['unload']='unload', ['login']='login', ['logout']='logout', ['chat']='chat message', ['time']='time change', ['invite']='party invite', ['jobchange']='job change', ['jobchangefull']='job change', ['gainbuff']='gain buff', ['losebuff']='lose buff',
    ['day']='day change', ['moon']='moon change', ['moonpct']='moon change', ['zone']='zone change', ['lvup']='level up', ['lvdown']='level down', ['gainexp']='gain experience', ['chain']='gain experience', ['weather']='weather change', ['status']='status change',
    ['examined']='examined', ['noammo']='outgoing chunk', ['tp']='tp change', ['hp']='hp change', ['hpp']='hpp change', ['lowhp']='hpp change', ['criticalhp']='hpp change', ['hpmax']='hp change', ['hpplt']='hpp change', ['hppgt']='hpp change',
    ['mp']='mp change', ['mpp']='mpp change', ['lowmp']='mpp change', ['criticalmp']='mpp change', ['mpmax']='mp change', ['mpplt']='mpp change', ['mppgt']='mpp change'
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

local isSilent = function(silent, ...) 
    local t = T{...}
    if silent then
        return true
    end
    print(('%s :: Command ► <%s> [ Once: %s ]'):format(t[1]:upper(), t[2], tostring(t[3]):upper()))

end
    
local destroy = function(once, remove)
    if not once then
        return
    end
    windower.unregister_event(events.registered[remove].id)

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

    else
        print('That file does not exist!')

    end

end

events.helpers['migrate'] = function()
    local f = files.new(('../../plugins/AutoExec/%s.xml'):format('AutoExec'))
    if f:exists() then
        local n = files.new(('/settings/%s.lua'):format('autoexec'))
        n:write(('return %s'):format(T(parse(f)):tovstring()))
    
    else
        print("Could not find 'AutoExec.xml' in plugins folder!")

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

    else
        print('Unable to load that file!')

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
                    
                    for match, event in pairs(map) do
                        
                        if windower.wc_match(match, name) and events.logic[match] then
                            events.helpers['create'](map[match], v.name, v.command, v.silent, v.once, match)
                        end

                    end

                elseif name:lower() ~= 'import' then
                    
                    if events.logic[name] then
                        events.helpers['create'](map[name], v.name, v.command, v.silent, v.once, name)

                    else
                        print(string.format('%s is not a valid event! [ v.name ]', tostring(name)))

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

        for _,v in ipairs(events.build) do
        
            if v.name then
                local split = v.name:split('_')
                
                if split[1] then
                    local name = split[1]
                    
                    if name:match('[%*%?%|]') then
                        
                        for match, event in pairs(map) do
                            
                            if windower.wc_match(match, name) and events.logic[match] then
                                events.helpers['create'](map[event], v.name, v.command, v.silent, v.once, match)
                            end
    
                        end
    
                    elseif name:lower() ~= 'import' then
                        
                        if events.logic[name] then
                            events.helpers['create'](map[name], v.name, v.command, v.silent, v.once, name)
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

    end    

end

events.helpers['create'] = function(register, event, command, silent, once, match)
    local once = once == 'true' and true or false
    local silent = silent == 'true' and true or false
    local match = match or false
    
    if register and event then
        local split = event:split('_')

        if events.logic[match] then
            local name = string.format('%s:%s', event, T(events.registered):length() + 1)
            
            events.registered[name] = {event=match, id=windower.register_event(register, function(...)
                events.logic[match](T{...} or false, split, command, once)

            end)}
            isSilent(silent, event, command, once)

            if not events.registered[name] then
                print(string.format('Failed to register event! [ %s / %s ]', tostring(register), tostring(event)))
            end

        end

    else
        print(string.format('Failed to create event! [ %s / %s ]', tostring(register), tostring(event)))

    end    

end

events.logic['login'] = function(...)
    local self = T{...}
    
    if #self == 4 then
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local name = o.data[1]
            
            if name then
                local c = o.command:gsub('{NAME}', name)
                
                if windower.wc_match(name:lower(), o.string[2]:lower()) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end
events.logic['logout'] = events.logic['login']

events.logic['jobchange'] = function(...)
    local self = T{...}
    
    if #self == 4 then
        local jobs = res.jobs
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if #o.data == 4 and o.string[2] then
            local t = o.string[2]:split('/')
            
            if t[1] and t[2] then
                local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
                local job = {main=t[1]:lower(), sub=t[2]:lower()}

                if jobs[o.data[1]] and jobs[o.data[3]] then
                    local c = o.command:gsub('{MAIN_FULL}', jobs[o.data[1]].en):gsub('{MAIN_SHORT}', jobs[o.data[1]].ens):gsub('{SUB_FULL}', jobs[o.data[3]].en):gsub('{SUB_SHORT}', jobs[o.data[3]].ens):gsub('{MAIN_LV}', o.data[2]):gsub('{SUB_LV}', a[4])
                    local l = {main=jobs[o.data[1]].en:lower(), sub=jobs[o.data[3]].en:lower(), fmain=string.format('%s%s', jobs[o.data[1]].en:lower(), o.data[2]), fsub=string.format('%s%s', jobs[o.data[3]].en:lower(), a[4])}
                    local s = {main=jobs[o.data[1]].ens:lower(), sub=jobs[o.data[3]].ens:lower(), fmain=string.format('%s%s', jobs[o.data[1]].ens:lower(), o.data[2]), fsub=string.format('%s%s', jobs[o.data[3]].ens:lower(), a[4])}
                
                    if (windower.wc_match(l.main, job.main) or windower.wc_match(s.main, job.main)) and (windower.wc_match(l.sub, job.sub) or windower.wc_match(s.sub, job.sub)) then
                        windower.send_command(c)
                        destroy(o.once, unregister)

                    elseif (windower.wc_match(l.fmain, job.main) or windower.wc_match(s.fmain, job.main)) and (windower.wc_match(l.fsub, job.sub) or windower.wc_match(s.fsub, job.sub)) then
                        windower.send_command(c)
                        destroy(o.once, unregister)

                    end

                end

            end

        end

    end

end
events.logic['jobchangefull'] = events.logic['jobchange']

events.logic['chat'] = function(...)
    local self = T{...}
    
    if #self == 4 then
        local chats = res.chat
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.data[2] and o.data[3] and o.string[2] and o.string[3] and o.string[4] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local message = o.data[1]
            local sender = o.data[2]
            local mode = o.data[3]

            do
                local c = o.command:gsub('{SENDER}', sender):gsub('{MODE}', chats[mode].en):gsub('{MATCH}', o.string[4])

                if windower.wc_match(chats[mode].en:lower(), o.string[2]) and windower.wc_match(sender:lower(), o.string[3]:lower()) and windower.wc_match(message:lower(), o.string[4]:lower()) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end

events.logic['time'] = function(...)
    local self = T{...}
    
    if #self == 4 then
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.data[2] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local temp = o.string[2]:split('.')
            local new = o.data[1]
            local old = o.data[2]

            if temp[1] and temp[2] then
                local time = {h=tonumber(temp[1]), m=tonumber(temp[2])}
                local h = {new=tonumber(math.floor(new/60)), old=tonumber(math.floor(old/60))}
                local m = {new=tonumber(math.round(((new/60)-n_hour)*60)), old=tonumber(math.round(((old/60)-o_hour)*60))}
                local command = command:gsub('{NEW_HOUR}', h.new):gsub('{NEW_MINUTE}', m.new):gsub('{OLD_HOUR}', h.old):gsub('{OLD_MINUTE}', m.old)

                if windower.wc_match(h.new, time.h) and windower.wc_match(m.new, time.m) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end

events.logic['invite'] = function(...)
    local self = T{...}
    
    if #self == 4 then
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local sender = o.data[1]

            do
                local c = o.command:gsub('{SENDER}', sender)

                if windower.wc_match(sender:lower(), o.string[2]) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end

events.logic['gainbuff'] = function(...)
    local self = T{...}
    
    if #self == 4 then
        local buffs = res.buffs
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local id = o.data[1]

            if buffs[id] then
                local c = o.command:gsub('{ID}', buffs[id].id):gsub('{NAME}', buffs[id].en)

                if windower.wc_match(buffs[id].en:lower(), o.string[2]:lower()) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end
events.logic['losebuff'] = events.logic['gainbuff']

events.logic['day'] = function(...)
    local self = T{...}
    
    if #self == 4 then
        local days = res.days
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.data[2] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local new = o.data[1]
            local old = o.data[2]

            if days[new] and days[old] then
                local c = o.command:gsub('{NEW}', days[new].en):gsub('{OLD}', days[old].en)

                if windower.wc_match(days[new].en:lower(), o.string[2]:lower()) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end

events.logic['moon'] = function(...)
    local self = T{...}
    
    if #self == 4 then
        local phases = res.moon_phases
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}
        
        if o.data[1] and o.data[2] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            
            if events.registered[unregister].event == 'moon' then
                local new = o.data[1]
                local old = o.data[2]
                
                if moons[new] and moons[old] then
                    local c = o.command:gsub('{NEW}', moons[new].en):gsub('{OLD}', moons[old].en)
    
                    if windower.wc_match(moons[new].en:lower(), o.string[2]:lower()) then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end
    
                end

            elseif events.registered[unregister].event == 'moonpct' then
                local moon = windower.ffxi.get_info().moon
                
                if moon then
                    local c = o.command:gsub('{PERCENT}', moon)
    
                    if windower.wc_match(moon, o.string[2]:lower()) then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end
    
                end

            end

        end

    end

end
events.logic['moonpct'] = events.logic['moon']

events.logic['zone'] = function(...)
    local self = T{...}
    
    if #self == 4 then
        local zones = res.zones
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.data[2] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local new = o.data[1]
            local old = o.data[2]

            if zones[new] and zones[old] then
                local c = o.command:gsub('{NEW}', zones[new].en):gsub('{OLD}', zones[old].en)

                if windower.wc_match(zones[new].en:lower(), o.string[2]:lower()) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end

events.logic['lvup'] = function(...)
    local self = T{...}
    
    if #self == 4 then
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local level = o.data[1]

            do
                local c = o.command:gsub('{LEVEL}', level)

                if windower.wc_match(level, o.string[2]) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end
events.logic['lvdown'] = events.logic['lvup']

events.logic['gainexp'] = function(...)
    local self = T{...}
    
    if #self == 4 then
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.data[2] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local amount = o.data[1]
            local chain = o.data[2]

            if events.registered[unregister].event == 'gainexp' then
                local c = o.command:gsub('{XP}', amount):gsub('{CHAIN}', chain)

                if windower.wc_match(amount, o.string[2]) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            elseif events.registered[unregister].event == 'chain' then
                local c = o.command:gsub('{XP}', amount):gsub('{CHAIN}', chain)

                if windower.wc_match(chain, o.string[2]) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end
events.logic['chain'] = events.logic['gainexp']

events.logic['weather'] = function(...)
    local self = T{...}
    
    if #self == 4 then
        local weathers = res.weather
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local id = o.data[1]

            if weathers[id] then
                local c = o.command:gsub('{WEATHER}', weathers[id].en)

                if windower.wc_match(weathers[id].en:lower(), o.string[2]:lower()) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end

events.logic['status'] = function(...)
    local self = T{...}

    if #self == 4 then
        local statuses = res.statuses
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.data[2] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local new = o.data[1]
            local old = o.data[2]

            if statuses[new] and statuses[old] then
                local c = o.command:gsub('{NEW}', statuses[new].en):gsub('{OLD}', statuses[old].en)
                
                if windower.wc_match(statuses[new].en:lower(), o.string[2]:lower()) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end

events.logic['examined'] = function(...)
    local self = T{...}

    if #self then
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local name = o.data[1]

            do
                local c = o.command:gsub('{NAME}', name)
                
                if windower.wc_match(name:lower(), o.string[2]:lower()) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end

events.logic['noammo'] = function(...)
    local self = T{...}

    if #self then
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.data[2] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local id = o.data[1]
            local og = o.data[2]

            if id == 0x050 then
                local packed = packets.parse('outgoing', og)

                if packed['Equip Slot'] == 3 and packed['Item Index'] == 0 then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end

events.logic['tp'] = function(...)
    local self = T{...}

    if #self then
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local new = o.data[1]
            local old = o.data[2]

            do
                local c = o.command:gsub('{NEW}', new):gsub('{OLD}', old)
                
                if windower.wc_match(new, o.string[2]) then
                    windower.send_command(c)
                    destroy(o.once, unregister)
                end

            end

        end

    end

end

events.logic['load'] = function(...)
    local self = T{...}

    if #self == 4 and #self[1] == 0 then
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.string[1] then
            windower.send_command(c)
            destroy(o.once, string.format('%s:%s', o.string[1], T(events.registered):length()))

        end

    end

end
events.logic['unload'] = events.logic['load']

events.logic['hp'] = function(...)
    local self = T{...}

    if #self == 4 then
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.data[2] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local new = o.data[1]
            local old = o.data[2]

            do
                local c = o.command:gsub('{NEW}', new):gsub('{OLD}', old)
                
                if registered.events[unregister].event == 'hp' then
                
                    if windower.wc_match(new, o.string[2]) then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                elseif registered.events[unregister].event == 'hpmax' then

                    if windower.wc_match(windower.ffxi.get_player()['vitals'].max_hp, o.string[2]) then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                end

            end

        end

    end

end
events.logic['hpmax'] = events.logic['hp']

events.logic['hpp'] = function(...)
    local self = T{...}

    if #self == 4 then
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.data[2] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local new = o.data[1]
            local old = o.data[2]

            do
                local c = o.command:gsub('{NEW}', new):gsub('{OLD}', old)
                
                if registered.events[unregister].event == 'hpp' then
                
                    if windower.wc_match(new, o.string[2]) then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                elseif registered.events[unregister].event == 'lowhp' then

                    if old >= 40 and new < 20 and windower.wc_match(new, o.string[2]) then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                elseif registered.events[unregister].event == 'criticalhp' then

                    if old >= 20 and new < 5 and windower.wc_match(new, o.string[2]) then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                elseif registered.events[unregister].event == 'hpplt76' then

                    if new < 76 then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                elseif registered.events[unregister].event == 'hppgt75' then

                    if new > 75 then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                end

            end

        end

    end

end
events.logic['lowhp'] = events.logic['hpp']
events.logic['criticalhp'] = events.logic['hpp']
events.logic['hpplt76'] = events.logic['hpp']
events.logic['hppgt75'] = events.logic['hpp']

events.logic['mp'] = function(...)
    local self = T{...}

    if #self == 4 then
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.data[2] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local new = o.data[1]
            local old = o.data[2]

            do
                local c = o.command:gsub('{NEW}', new):gsub('{OLD}', old)
                
                if registered.events[unregister].event == 'mp' then
                
                    if windower.wc_match(new, o.string[2]) then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                elseif registered.events[unregister].event == 'mpmax' then

                    if windower.wc_match(windower.ffxi.get_player()['vitals'].max_mp, o.string[2]) then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                end

            end

        end

    end

end
events.logic['mpmax'] = events.logic['mp']

events.logic['mpp'] = function(...)
    local self = T{...}

    if #self == 4 then
        local o = {data=self[1], string=self[2], command=self[3], once=self[4]}

        if o.data[1] and o.data[2] and o.string[2] then
            local unregister = string.format('%s:%s', o.string[1], T(events.registered):length())
            local new = o.data[1]
            local old = o.data[2]

            do
                local c = o.command:gsub('{NEW}', new):gsub('{OLD}', old)
                
                if registered.events[unregister].event == 'mpp' then
                
                    if windower.wc_match(new, o.string[2]) then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                elseif registered.events[unregister].event == 'lowmp' then

                    if old >= 40 and new < 20 and windower.wc_match(new, o.string[2]) then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                elseif registered.events[unregister].event == 'criticalmp' then

                    if old >= 20 and new < 5 and windower.wc_match(new, o.string[2]) then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                elseif registered.events[unregister].event == 'mpplt50' then

                    if new < 50 then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                elseif registered.events[unregister].event == 'mppgt49' then

                    if new > 49 then
                        windower.send_command(c)
                        destroy(o.once, unregister)
                    end

                end

            end

        end

    end

end
events.logic['lowmp'] = events.logic['mpp']
events.logic['criticalmp'] = events.logic['mpp']
events.logic['mpplt50'] = events.logic['mpp']
events.logic['mppgt49'] = events.logic['mpp']