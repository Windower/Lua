--Copyright (c) 2014, Byrthnoth
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

texts = require 'texts'
config = require 'config'
require 'sets'
res = require 'resources'
require 'statics'
messages = require 'message_ids'
require 'pack'

_addon.name = 'PointWatch'
_addon.author = 'Byrth'
_addon.version = 0.150811
_addon.command = 'pw'

settings = config.load('data\\settings.xml',default_settings)
config.register(settings,initialize)

box = texts.new('${current_string}',settings.text_box_settings,settings)
box.current_string = ''
box:show()

initialize()

windower.register_event('incoming chunk',function(id,org,modi,is_injected,is_blocked)
    if is_injected then return end
    if id == 0x29 then -- Action Message, used in Abyssea for xp
        local val = org:unpack('I',0xD)
        local msg = org:unpack('H',0x19)%1024
        exp_msg(val,msg)
    elseif id == 0x2A then -- Resting message
        local zone = 'z'..windower.ffxi.get_info().zone
        if settings.options.message_printing then
            print('Message ID: '..(org:unpack('H',0x1B)%2^14))
        end
        
        if messages[zone] then
            local msg = org:unpack('H',0x1B)%2^14
            for i,v in pairs(messages[zone]) do
                if tonumber(v) and v + messages[zone].offset  == msg then
                    local param_1 = org:unpack('I',0x9)
                    local param_2 = org:unpack('I',0xD)
                    local param_3 = org:unpack('I',0x11)
                    local param_4 = org:unpack('I',0x15)
                    -- print(param_1,param_2,param_3,param_4) -- DEBUGGING STATEMENT -------------------------
                    if zone_message_functions[i] then
                        zone_message_functions[i](param_1,param_2,param_3,param_4)
                    end
                    if i:contains("visitant_status_") then
                        abyssea.update_time = os.clock()
                    end
                end
            end
        end
    elseif id == 0x2D then
        local val = org:unpack('I',0x11)
        local msg = org:unpack('H',0x19)%1024
        exp_msg(val,msg)
    elseif id == 0x55 then
        if org:byte(0x85) == 3 then
            local dyna_KIs = math.floor((org:byte(6)%64)/2) -- 5 bits (32, 16, 8, 4, and 2 originally -> shifted to 16, 8, 4, 2, and 1)
            dynamis._KIs = {
                ['Crimson'] = dyna_KIs%2 == 1,
                ['Azure'] = math.floor(dyna_KIs/2)%2 == 1,
                ['Amber'] = math.floor(dyna_KIs/4)%2 == 1,
                ['Alabaster'] = math.floor(dyna_KIs/8)%2 == 1,
                ['Obsidian'] = math.floor(dyna_KIs/16) == 1,
            }
            if dynamis_map[dynamis.zone] then
                dynamis.time_limit = 3600
                for KI,TE in pairs(dynamis_map[dynamis.zone]) do
                    if dynamis._KIs[KI] then
                        dynamis.time_limit = dynamis.time_limit + TE*60
                    end
                end
                update_box()
            end
        end
    elseif id == 0x61 then
        xp.current = org:unpack('H',0x11)
        xp.tnl = org:unpack('H',0x13)
        accolades.current = math.floor(org:byte(0x5A)/4) + org:byte(0x5B)*2^6 + org:byte(0x5C)*2^14
    elseif id == 0x63 and org:byte(5) == 2 then
        lp.current = org:unpack('H',9)
        lp.number_of_merits = org:byte(11)%128
        lp.maximum_merits = org:byte(0x0D)%128
    elseif id == 0x63 and org:byte(5) == 5 then
        local offset = windower.ffxi.get_player().main_job_id*6+13 -- So WAR (ID==1) starts at byte 19
        cp.current = org:unpack('H',offset)
        cp.number_of_job_points = org:unpack('H',offset+2)
    elseif id == 0x110 then
        sparks.current = org:unpack('I',5)
    elseif id == 0xB and box:visible() then
        zoning_bool = true
        box:hide()
    elseif id == 0xA and zoning_bool then
        zoning_bool = nil
        box:show()
    end
end)

windower.register_event('zone change',function(new,old)
    if res.zones[new].english:sub(1,7) == 'Dynamis' then
        dynamis.entry_time = os.clock()
        abyssea.update_time = 0
        abyssea.time_remaining = 0
        dynamis.time_limit = 3600
        dynamis.zone = new
        cur_func,loadstring_err = loadstring("current_string = "..settings.strings.dynamis)
    elseif res.zones[new].english:sub(1,7) == 'Abyssea' then
        abyssea.update_time = os.clock()
        abyssea.time_remaining = 5
        dynamis.entry_time = 0
        dynamis.time_limit = 0
        dynamis.zone = 0
        cur_func,loadstring_err = loadstring("current_string = "..settings.strings.abyssea)
    else
        abyssea.update_time = 0
        abyssea.time_remaining = 0
        dynamis.entry_time = 0
        dynamis.time_limit = 0
        dynamis.zone = 0
        cur_func,loadstring_err = loadstring("current_string = "..settings.strings.default)
    end
    if not cur_func or loadstring_err then
        cur_func = loadstring("current_string = ''")
        error(loadstring_err)
    end
end)

windower.register_event('addon command',function(...)
    local commands = {...}
    local first_cmd = table.remove(commands,1):lower()
    if approved_commands[first_cmd] and #commands >= approved_commands[first_cmd].n then
        local tab = {}
        for i,v in ipairs(commands) do
            tab[i] = tonumber(v) or v
            if i <= approved_commands[first_cmd].n and type(tab[i]) ~= approved_commands[first_cmd].t then
                print('Pointwatch: texts library command ('..first_cmd..') requires '..approved_commands[first_cmd].n..' '..approved_commands[first_cmd].t..'-type input'..(approved_commands[first_cmd].n > 1 and 's' or ''))
                return
            end
        end
        texts[first_cmd](box,unpack(tab))
        settings.text_box_settings = box._settings
        config.save(settings)
    elseif first_cmd == 'reload' then
        windower.send_command('lua r pointwatch')
    elseif first_cmd == 'unload' then
        windower.send_command('lua u pointwatch')
    elseif first_cmd == 'reset' then
        initialize()
    elseif first_cmd == 'message_printing' then
        settings.options.message_printing = not settings.options.message_printing
        print('Pointwatch: Message printing is '..tostring(settings.options.message_printing)..'.')
    elseif first_cmd == 'eval' then
        assert(loadstring(table.concat(commands, ' ')))()
    end
end)

windower.register_event('prerender',function()
    if frame_count%30 == 0 and box:visible() then
        update_box()
    end
    frame_count = frame_count + 1
end)

function update_box()
    if not windower.ffxi.get_info().logged_in or not windower.ffxi.get_player() then
        box.current_string = ''
        return
    end
    cp.rate = analyze_points_table(cp.registry)
    xp.rate = analyze_points_table(xp.registry)
    if dynamis.entry_time ~= 0 and dynamis.entry_time+dynamis.time_limit-os.clock() > 0 then
        dynamis.time_remaining = os.date('!%H:%M:%S',dynamis.entry_time+dynamis.time_limit-os.clock())
        dynamis.KIs = X_or_O(dynamis._KIs.Crimson)..X_or_O(dynamis._KIs.Azure)..X_or_O(dynamis._KIs.Amber)..X_or_O(dynamis._KIs.Alabaster)..X_or_O(dynamis._KIs.Obsidian)
    elseif abyssea.update_time ~= 0 then
        local time_less_then = math.floor((os.clock() - abyssea.update_time)/60)
        abyssea.time_remaining = abyssea.time_remaining-time_less_then
        if time_less_then >= 1 then
            abyssea.update_time = os.clock()
        end
    else
        dynamis.time_remaining = 0
        dynamis.KIs = ''
    end
    assert(cur_func)()
    
    if box.current_string ~= current_string then
        box.current_string = current_string
    end
end

function X_or_O(bool)
    if bool then return 'O' else return 'X' end
end

function analyze_points_table(tab)
    local t = os.clock()
    local running_total = 0
    local maximum_timestamp = 29
    for ts,points in pairs(tab) do
        local time_diff = t - ts
        if t - ts > 600 then
            tab[ts] = nil
        else
            running_total = running_total + points
            if time_diff > maximum_timestamp then
                maximum_timestamp = time_diff
            end
        end
    end
    
    local rate
    if maximum_timestamp == 29 then
        rate = 0
    else
        rate = math.floor((running_total/maximum_timestamp)*3600)
    end
    
    return rate
end

zone_message_functions = {
    amber_light = function(p1,p2,p3,p4)
        abyssea.amber = math.min(abyssea.amber + 8,255)
    end,
    azure_light = function(p1,p2,p3,p4)
        abyssea.azure = math.min(abyssea.azure + 8,255)
    end,
    ruby_light = function(p1,p2,p3,p4)
        abyssea.ruby = math.min(abyssea.ruby + 8,255)
    end,
    pearlescent_light = function(p1,p2,p3,p4)
        abyssea.pearlescent = math.min(abyssea.pearlescent + 5,230)
    end,
    ebon_light = function(p1,p2,p3,p4)
        abyssea.ebon = math.min(abyssea.ebon + p1+1,200) -- NM kill = 1, faint = 1, mild = 2, strong = 3
    end,
    silvery_light = function(p1,p2,p3,p4)
        abyssea.silvery = math.min(abyssea.silvery + 5*(p1+1),200) -- faint = 5, mild = 10, strong = 15
    end,
    golden_light = function(p1,p2,p3,p4)
        abyssea.golden = math.min(abyssea.golden + 5*(p1+1),200) -- faint = 5, mild = 10, strong = 15
    end,
    pearl_ebon_gold_silvery = function(p1,p2,p3,p4)
        abyssea.pearlescent = p1
        abyssea.ebon = p2
        abyssea.golden = p3
        abyssea.silvery = p4
    end,
    azure_ruby_amber = function(p1,p2,p3,p4)
        abyssea.azure = p1
        abyssea.ruby = p2
        abyssea.amber = p3
    end,
    visitant_status_gain = function(p1,p2,p3,p4)
        abyssea.time_remaining = p1
    end,
    visitant_status_update = function(p1,p2,p3,p4)
        abyssea.time_remaining = p1
    end,
    visitant_status_wears_off = function(p1,p2,p3,p4)
        abyssea.time_remaining = p1
    end,
    visitant_status_extend = function(p1,p2,p3,p4)
        abyssea.time_remaining = abyssea.time_remaining + p1
    end,
}

function exp_msg(val,msg)
    local t = os.clock()
    if msg == 718 or msg == 735 then
        cp.registry[t] = (cp.registry[t] or 0) + val
        cp.total = cp.total + val
        cp.current = cp.current + val
        if cp.current > cp.tnjp and cp.number_of_job_points ~= cp.maximum_job_points then
            cp.number_of_job_points = math.min(cp.number_of_job_points + math.floor(cp.current/cp.tnjp),cp.maximum_job_points)
            cp.current = cp.current%cp.tnjp
        end
    elseif msg == 8 or msg == 105 then
        xp.registry[t] = (xp.registry[t] or 0) + val
        xp.total = xp.total + val
        xp.current = math.min(xp.current + val,55999)
        -- 98 to 99 is 56000 XP, so 55999 is the most you can ever have
        if xp.current > xp.tnl then
            -- I have capped all jobs, but I assume that a 0x61 packet is sent after you
            -- level up, which will update the TNL and make this adjustment meaningless.
            xp.current = xp.current - xp.tnl
        end
    elseif msg == 371 or msg == 372 then
        lp.registry[t] = (lp.registry[t] or 0) + val
        lp.current = lp.current + val
        if lp.current >= lp.tnm and lp.number_of_merits ~= lp.maximum_merits then
            -- Merit Point gained!
            lp.number_of_merits = math.min(lp.number_of_merits + math.floor(lp.current/lp.tnm),lp.maximum_merits)
            lp.current = lp.current%lp.tnm
        else
            -- If a merit point was not gained, 
            lp.current = math.min(lp.current,lp.tnm-1)
        end
    end
    update_box()
end
