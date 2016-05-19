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
        default = "xp.current..'/'..xp.tnl..'XP   '..lp.current..'/'..lp.tnm..'LP ['..lp.number_of_merits..'/'..lp.maximum_merits..']   XP/hr:'..string.format('%.1f',math.floor(xp.rate/100)/10)..'k   '..cp.current..'/'..cp.tnjp..'CP ['..cp.number_of_job_points..']   CP/hr:'..string.format('%.1f',math.floor(cp.rate/100)/10)..'k'",
        dynamis = "xp.current..'/'..xp.tnl..'XP   '..lp.current..'/'..lp.tnm..'LP ['..lp.number_of_merits..'/'..lp.maximum_merits..']   XP/hr:'..string.format('%.1f',math.floor(xp.rate/100)/10)..'k   '..cp.current..'/'..cp.tnjp..'CP ['..cp.number_of_job_points..']   '..dynamis.KIs..'  '..dynamis.time_remaining",
        abyssea = "xp.current..'/'..xp.tnl..'XP   '..lp.current..'/'..lp.tnm..'LP ['..lp.number_of_merits..'/'..lp.maximum_merits..']   XP/hr:'..string.format('%.1f',math.floor(xp.rate/100)/10)..'k   Amber:'..(abyssea.amber or 0)..'/Azure:'..(abyssea.azure or 0)..'/Ruby:'..(abyssea.ruby or 0)..'/Pearlescent:'..(abyssea.pearlescent or 0)..'/Ebon:'..(abyssea.ebon or 0)..'/Silvery:'..(abyssea.silvery or 0)..'/Golden:'..(abyssea.golden or 0)..'/Time Remaining:'..(abyssea.time_remaining or 0)"
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
    },
    options = {
        message_printing = false,
    },
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
    }
    
    lp = {
        registry = xp.registry,
        current = 0,
        tnm = 10000,
        number_of_merits = 0,
        maximum_merits = 30,
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
    
end
