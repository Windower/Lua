--Copyright © 2014, Byrthnoth
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

texts = require('texts')
config = require('config')
require('sets')
res = require('resources')
require('statics')
messages = require('message_ids')
packets = require('packets')
require('pack')
require('chat')

_addon.name = 'PointWatch'
_addon.author = 'Byrth'
_addon.version = 0.240420
_addon.command = 'pw'

settings = config.load('data\\settings.xml',default_settings)
config.register(settings,initialize)

box = texts.new('${current_string}',settings.text_box_settings,settings)
box.current_string = ''
box:show()

granule_KIs = res.key_items:en(function(x) return x:endswith('granules of time') end):map(function(ki)
    return {
        id=ki.id,
        type=math.floor(ki.id/0x200),
        offset=ki.id%0x200,
        name=ki.en:match('%w+'):ucfirst(),
    }
end)

packet_initiators = L{0x02A,0x055,0x061,0x063,0x110}
packet_handlers = {
    [0x029] = function(org) -- Action Message, used in Abyssea for xp
        local p = packets.parse('incoming',org)
        exp_msg(p['Param 1'],p['Message'])
    end,
    [0x02A] = function(org) -- Resting message
        local p = packets.parse('incoming',org)
        local zone = 'z'..windower.ffxi.get_info().zone

        if messages[zone] then
            local msg = bit.band(p['Message ID'], 16383)
            for i,v in pairs(messages[zone]) do
                if tonumber(v) and v + messages[zone].offset == msg then
                    -- print(p['Param 1'],p['Param 2'],p['Param 3'],p['Param 4']) -- DEBUGGING STATEMENT -------------------------
                    if zone_message_functions[i] then
                        zone_message_functions[i](p['Param 1'],p['Param 2'],p['Param 3'],p['Param 4'])
                    end
                    if i:contains("visitant_status_") then
                        abyssea.update_time = os.clock()
                    end
                end
            end
        end
    end,
    [0x02D] = function(org)
        local p = packets.parse('incoming',org)
        exp_msg(p['Param 1'],p['Message'])
    end,
    [0x055] = function(org)
        local p = packets.parse('incoming',org)
        --print(p['Type'],p['Key item available'], p['Key item available']:byte(1),p['Key item available']:byte(2))
        for _,ki in pairs(granule_KIs) do
            if p['Type'] == ki.type then
                local byte = p['Key item available']:byte(math.floor(ki.offset/8)+1)
                local flag = bit.band(bit.rshift(byte, ki.offset % 8), 1)
                --print('byte', byte, 'offset', ki.offset % 8, 'flag', flag)
                if flag == 1 then
                    dynamis._KIs[ki.name] = true
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
            end
        end
    end,
    [0x061] = function(org)
        local p = packets.parse('incoming',org)
        xp.current = p['Current EXP']
        xp.tnl = p['Required EXP']
        xp.job = res.jobs[p['Main Job']].name
        xp.job_abbr = res.jobs[p['Main Job']].name_short
        xp.job_level = p['Main Job Level']
        xp.sub_job = res.jobs[p['Sub Job']].name
        xp.sub_job_abbr = res.jobs[p['Sub Job']].name_short
        xp.sub_job_level = p['Sub Job Level']
        accolades.current = p['Unity Points']
        ep.current = p['Current Exemplar Points']
        ep.tnml = p['Required Exemplar Points']
        ep.master_level = tnml[p['Required Exemplar Points']]
        ep.synced_master_level = p['Master Level']
    end,
    [0x063] = function(org)
        local p = packets.parse('incoming',org)
        if p['Order'] == 2 then
            lp.current = p['Limit Points']
            lp.number_of_merits = p['Merit Points']
            lp.maximum_merits = p['Max Merit Points']
        elseif p['Order'] == 5 then
            local player = windower.ffxi.get_player()
            if player then
                local job = player.main_job_full
                cp.current = p[job..' Capacity Points']
                cp.number_of_job_points = p[job..' Job Points']
            end
        end
    end,
    [0x110] = function(org)
        local p = packets.parse('incoming',org)
        sparks.current = p['Sparks Total']
    end,
    [0xB] = function(org)
        zoning_bool = true
        box:hide()
    end,
    [0xA] = function(org)
        zoning_bool = nil
        box:show()
    end,
}

initialize()

windower.register_event('incoming chunk',function(id,org,modi,is_injected,is_blocked)
    if is_injected or is_blocked then return end
    local handler = packet_handlers[id]
    if handler then
        handler(org,modi)
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
        settings.text_box_settings = box.settings()
        config.save(settings)
    elseif first_cmd == 'reload' then
        windower.send_command('lua r pointwatch')
    elseif first_cmd == 'unload' then
        windower.send_command('lua u pointwatch')
    elseif first_cmd == 'reset' then
        initialize()
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
    ep.rate = analyze_points_table(ep.registry)
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
    elseif msg == 809 or msg == 810 then
        ep.registry[t] = (ep.registry[t] or 0) + val
        if ep.tnml and ep.current >= ep.tnml then
            ep.current = ep.current - ep.tnml
        end
    end
    update_box()
end

function max_color(str,val,max,r,g,b)
    return val >= max and tostring(str):text_color(r,g,b) or tostring(str) or ""
end
