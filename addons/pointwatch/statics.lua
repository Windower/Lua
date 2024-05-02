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


--Default settings file:
default_settings = {
    strings = {
        default = "string.format('%d/%dXP %sMerits XP/hr:%.1fk %sJP CP/hr:%.1fk ML%d %d/%dEP EP/hr:%.1fk',xp.current,xp.tnl,max_color('%5.2f':format(math.floor(lp.current/lp.tnm*100)/100+lp.number_of_merits),lp.current/lp.tnm+lp.number_of_merits,lp.maximum_merits,58,147,191),math.floor(xp.rate/100)/10,max_color('%6.2f':format(math.floor(cp.current/cp.tnjp*100)/100+cp.number_of_job_points),cp.current/cp.tnjp+cp.number_of_job_points,500,58,147,191),math.floor(cp.rate/100)/10,ep.master_level,ep.current,ep.tnml,math.floor(ep.rate/100)/10)",
        dynamis = "string.format('%d/%dXP %sMerits XP/hr:%.1fk %sJP CP/hr:%.1fk ML%d %d/%dEP %s  %s',xp.current,xp.tnl,max_color('%5.2f':format(math.floor(lp.current/lp.tnm*100)/100+lp.number_of_merits),lp.current/lp.tnm+lp.number_of_merits,lp.maximum_merits,58,147,191),math.floor(xp.rate/100)/10,max_color('%6.2f':format(math.floor(cp.current/cp.tnjp*100)/100+cp.number_of_job_points),cp.current/cp.tnjp+cp.number_of_job_points,500,58,147,191),math.floor(cp.rate/100)/10,ep.master_level,ep.current,ep.tnml,dynamis.KIs,dynamis.time_remaining or 0)",
        abyssea = "string.format('%d/%dXP %sMerits XP/hr:%.1fk %sJP CP/hr:%.1fk ML%d %d/%dEP Amber:%d Azure:%d Ruby:%d Pearl:%d Ebon:%d Silver:%d Gold:%d Time-Remaining:%d',xp.current,xp.tnl,max_color('%5.2f':format(math.floor(lp.current/lp.tnm*100)/100+lp.number_of_merits),lp.current/lp.tnm+lp.number_of_merits,lp.maximum_merits,58,147,191),math.floor(xp.rate/100)/10,max_color('%6.2f':format(math.floor(cp.current/cp.tnjp*100)/100+cp.number_of_job_points),cp.current/cp.tnjp+cp.number_of_job_points,500,58,147,191),math.floor(cp.rate/100)/10,ep.master_level,ep.current,ep.tnml,abyssea.amber or 0,abyssea.azure or 0,abyssea.ruby or 0,abyssea.pearlescent or 0,abyssea.ebon or 0,abyssea.silvery or 0,abyssea.golden or 0,abyssea.time_remaining or 0)",
    },
    text_box_settings = {
        pos = {
            x = 0,
            y = 0,
        },
        bg = {
            alpha = 255,
            red = 0,
            green = 0,
            blue = 0,
            visible = true
        },
        flags = {
            right = false,
            bottom = false,
            bold = false,
            italic = false
        },
        padding = 0,
        text = {
            size = 12,
            font = 'Consolas',
            fonts = {},
            alpha = 255,
            red = 255,
            green = 255,
            blue = 255
        }
    }
}

-- Approved textbox commands:
approved_commands = S{'show','hide','pos','pos_x','pos_y','font','size','pad','color','alpha','transparency','bg_color','bg_alpha','bg_transparency'}
approved_commands = {show={n=0},hide={n=0},pos={n=2,t='number'},pos_x={n=1,t='number'},pos_y={n=1,t='number'},
    font={n=2,t='string'},size={n=1,t='number'},pad={n=1,t='number'},color={n=3,t='number'},alpha={n=1,t='number'},
    transparency={n=1,t='number'},bg_color={n=3,t='number'},bg_alpha={n=1,t='number'},bg_transparency={n=1,t='number'}}

-- Dynamis TE lists:
city_table = {Crimson=10,Azure=10,Amber=10,Alabaster=15,Obsidian=15}
other_table = {Crimson=10,Azure=10,Amber=10,Alabaster=10,Obsidian=20}

-- Mapping of zone ID to TE list:
dynamis_map = {[185]=city_table,[186]=city_table,[187]=city_table,[188]=city_table,
    [134]=other_table,[135]=other_table,[39]=other_table,[40]=other_table,[41]=other_table,[42]=other_table}

-- Master Level EP table
tnml = {
    [2500] = 0,
    [5550] = 1,
    [8721] = 2,
    [11919] = 3,
    [15122] = 4,
    [18327] = 5,
    [21532] = 6,
    [24737] = 7,
    [27942] = 8,
    [31147] = 9,
    [41205] = 10,
    [48130] = 11,
    [53677] = 12,
    [58618] = 13,
    [63292] = 14,
    [67848] = 15,
    [72353] = 16,
    [76835] = 17,
    [81307] = 18,
    [85775] = 19,
    [109112] = 20,
    [127014] = 21,
    [141329] = 22,
    [153277] = 23,
    [163663] = 24,
    [173018] = 25,
    [181692] = 26,
    [189917] = 27,
    [197845] = 28,
    [205578] = 29,
    [258409] = 30,
    [307400] = 31,
    [353012] = 32,
    [395651] = 33,
    [435673] = 34,
    [473392] = 35,
    [509085] = 36,
    [542995] = 37,
    [575336] = 38,
    [606296] = 39,
    [769426] = 40,
    [951369] = 41,
    [1154006] = 42,
    [1379407] = 43,
    [1629848] = 44,
    [1907833] = 45,
    [2216116] = 46,
    [2557728] = 47,
    [2936001] = 48,
    [3354601] = 49,
    [3817561] = 50
}

-- Not technically static, but sets the initial values for all features:
function initialize()
    cp = {
        registry = {},
        current = 0,
        rate = 0,
        total = 0,
        tnjp = 30000,
        number_of_job_points = 0,
        maximum_job_points = 500,
    }

    xp = {
        registry = {},
        total = 0,
        rate = 0,
        current = 0,
        tnl = 0,
        job = 0,
        job_abbr = 0,
        job_level = 0,
        sub_job = 0,
        sub_job_abbr = 0,
        sub_job_level = 0,
    }
    
    lp = {
        registry = xp.registry,
        current = 0,
        tnm = 10000,
        number_of_merits = 0,
        maximum_merits = 30,
    }

    ep = {
        registry = {},
        current = 0,
        rate = 0,
        tnml = 0,
        master_level = 0,
        synced_master_level = 0;
    }
    
    sparks = {
        current = 0,
        maximum = 99999,
    }
    
    accolades = {
        current = 0,
        maximum = 99999,
    }
    
    abyssea = {
        amber = 0,
        azure = 0,
        ruby = 0,
        pearlescent = 0,
        ebon = 0,
        silvery = 0,
        golden = 0,
        update_time = 0,
        time_remaining = 0,
    }
    
    local info = windower.ffxi.get_info()
    
    frame_count = 0
    
    dynamis = {
        KIs = '',
        _KIs = {},
        entry_time = 0,
        time_limit = 0,
        zone = 0,
    }
    if info.logged_in and res.zones[info.zone].english:sub(1,7) == 'Dynamis' then
        cur_func = loadstring("current_string = "..settings.strings.dynamis)
        setfenv(cur_func,_G)
        dynamis.entry_time = os.clock()
        dynamis.zone = info.zone
        windower.add_to_chat(123,'Loading PointWatch in Dynamis results in an inaccurate timer. Number of KIs is displayed.')
    elseif info.logged_in then
        cur_func = loadstring("current_string = "..settings.strings.default)
        setfenv(cur_func,_G)
    end
    for _,id in ipairs(packet_initiators) do
        local handler = packet_handlers[id]
        if handler then
            local last = windower.packets.last_incoming(id)
            if last then
                handler(last)
            end
        end
    end
end
